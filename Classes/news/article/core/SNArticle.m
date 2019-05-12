//
//  Article.m
//  sohunews
//
//  Created by zhu kuanxi on 5/18/11.
//  retainright 2011 sohu. All rights reserved.
//

#import "SNArticle.h"
#import "SNDBManager.h"
#import "SNURLDataResponse.h"
#import "SNNewsVideo.h"
#import "SNNewsAudio.h"
#import "SNNewsAdInfo.h"
#import "SNNewsVoteService.h"
#import "SNDatabase+newsAudio.h"
#import "RegexKitLite.h"
#import "GTMBase64.h"
#import "SNUserManager.h"
#import "SNCommentConfigs.h"
#import "SNURLJSONResponse.h"
#import <JsKitFramework/JsKitFramework.h>
#import "SNArticleRequest.h"


#define kImgSize				(3)//大图
#define kRecommendNewsCount     (3)

@interface SNArticle(private)
- (NSString*)locateNewsContentImgToLocalPath:(NSString*)newsContent termId:(NSString*)tId newspaperPath:(NSString *)newspaperPath;

@end

//新闻文章实体类
@implementation SNArticle

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Paper article
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Paper article

+ (id)newsWithNewsId:(NSString *)nId termId:(NSString *)tId userData:(NSDictionary *)userData {
	return [SNArticle newsWithNewsId:nId termId:tId userData:userData onLineMode:YES];
}

- (BOOL)isRollingNews {
	return nil == _termId;
}

- (void)saveAsCache {
	SNDebugLog(@"saveAsCache begin,thread = %@",[NSThread currentThread]);
	
	NewsArticleItem *cache = [[NewsArticleItem alloc] init];
	
	cache.newsId		= self.newsId;
	cache.title			= self.title;
	cache.from			= self.from;
    cache.newsMark      = self.newsMark;
    cache.originFrom    = self.originFrom;
    cache.originTitle   = self.originTitle;
	cache.time			= self.time;
	cache.updateTime	= self.updateTime;
	cache.content		= self.content;
	cache.preId			= self.preId;
	cache.nextId		= self.nextId;
    cache.cmtStatus     = self.comtStatus;
    cache.cmtHint       = self.comtHint;
    cache.cmtRead       = self.cmtRead;
    cache.nextNewsLink  = self.nextNewsLink;
    cache.nextNewsLink2 = self.nextNewsLink2;
	cache.termId		= self.termId;
	cache.channelId		= self.channelId;
	cache.commentNum	= self.commentNum;
	cache.link			= self.link;
	cache.shareContent	= self.shareContent;
    cache.shareImages   = self.newsImageItems;
	cache.thumbnailImages = self.thumbnailImages;
    cache.subId         = self.subId;
    cache.action        = self.action;
    cache.isPublished   = self.isPublished;
    cache.editNewsLink  = self.editNewsLink;
    cache.operators     = self.operators;
    cache.logoUrl       = self.logoUrl;
    cache.linkUrl       = self.linkUrl;
    cache.favour        = self.favour;
    cache.h5link        = self.h5link;
    cache.newsType      = self.newsType;
    cache.favIcon       = self.favIcon;
    cache.mediaName     = self.mediaName;
    cache.mediaLink     = self.mediaLink;
    cache.optimizeRead  = self.optimizeRead;
    cache.tagChannels   = self.tagChannelItems;
    cache.stocks        = self.stockItems;
    SNDebugLog(@"INFO: SELF: channelId %@, termId %@, CACHE: channelId %@, termId %@, newsId %@", 
               self.channelId, self.termId, cache.channelId, cache.termId, self.newsId);
    
    if (cache.channelId) {
        [[SNDBManager currentDataBase] addSingleNewsArticle:cache updateIfExist:YES withOption:ADDNEWSARTICLE_BY_CHANNELID];
        
        [[SNDBManager currentDataBase] markRollingNewsListItemAsReadAndNotExpiredByChannelId:cache.channelId newsId:cache.newsId];
        
        SNDebugLog(@"set rolling news read in cache=%@", cache.title);
        
    } else if (cache.termId) {
        [[SNDBManager currentDataBase] addSingleNewsArticle:cache updateIfExist:YES withOption:ADDNEWSARTICLE_BY_TERMID];
        
        [[SNDBManager currentDataBase] markRollingNewsListItemAsReadAndNotExpiredByChannelId:cache.termId newsId:cache.newsId];
    } else {
        [[SNDBManager currentDataBase] addSingleNewsArticle:cache updateIfExist:YES withOption:ADDNEWSARTICLE_BY_TERMID];
    }
    
    [[SNDBManager currentDataBase] addMultiNewsAudio:self.audios];
    // save votes cache
    SNDebugLog(@"voteXML=%@ \nvotesInfo=%@", self.voteXML, self.votesInfo);
    if ([self.voteXML length] > 0 && self.votesInfo != nil) {
        VotesInfo *voteInfo = [[VotesInfo alloc] init];
        voteInfo.newsID = cache.newsId;
        if (self.votesInfo.topicId) voteInfo.topicID = self.votesInfo.topicId;
        if (self.voteXML) voteInfo.voteXML = self.voteXML;
        voteInfo.isVoted = @"0";
        SNDebugLog(@"saveAsCache voteinfo=%@", voteInfo);
        [[SNDBManager currentDataBase] addOrUpdateOneVoteInfo:voteInfo];
    }
    SNDebugLog(@"save Paper Article Cache complete termId=%@ newsId=%@ pre=%@ next=%@ \n",
               cache.termId, cache.newsId, cache.preId, cache.nextId);
		
	
}

- (void)replaceVideoContentIfExists
{
    float opacity = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.8 : 1.0;
    for (SNNewsVideo *v in self.videos) {
        NSString *_videoPlaylist = @"";
        if (!!v && !!(v.srcArray) && v.srcArray.count > 0) {
            _videoPlaylist = [v.srcArray componentsJoinedByString:@","];
        }
        
        //lijian 2015.05.013 这里直接在div里强行加入了w、h两个设置，进行了按比例配置。css里的news_video就无效了
        NSInteger videoW = kAppScreenWidth - 28;
        NSInteger videoH = (NSInteger)videoW * 495 / 620;
        
        NSString *vHtml = [NSString stringWithFormat:@"<div poster=\"%@\" src=\"%@\" controls=\"controls\" webkit-playsinline=\"webkit-playsinline\" style=\"width:%ld;height:%ld\";'opacity:%f' playlist=\"%@\" name=\"%@\" vvId=\"%@\" playType=\"%d\" downloadType=\"%d\" shareContent=\"%@\" h5Url=\"%@\" wapUrl=\"%@\" autoplayVideo=\"%d\" site=\"%@\" site2=\"%@\" siteName=\"%@\" siteId=\"%@\" playById=\"%@\" playAd=\"%@\" adServer=\"%@\" class=\"news_video\" ></div>",
                           v.poster, @"", videoW,videoH,opacity, _videoPlaylist, v.name, v.vvId, v.playType, v.downloadType, v.share.content, v.share.h5Url, v.wapUrl, self.autoplayVideo, v.site, v.site2, v.siteName, v.siteId, v.playById, v.playAd, v.adServer];
        
        
        NSString *vId = [NSString stringWithFormat:@"<tvinfo_%@></tvinfo_%@>", v.vId, v.vId];
        self.content = [self.content stringByReplacingOccurrencesOfString:vId withString:vHtml];
    }
}

- (void)replaceAudioContentIfExists {
    for (SNNewsAudio *audio in self.audios) {
        NSString *aId = [NSString stringWithFormat:@"<sohuaudio_%@><sohuaudio_%@/>", audio.audioId, audio.audioId];
        NSString *aHtml = nil;
        if (!audio.name|| audio.name.length == 0 ||[@"null" isEqualToString:audio.name]) {
            aHtml = [NSString stringWithFormat:@"<div class=\"audioContainer\" style=\"height:70px;\" id=\"sohuaudio_%@\" src=\"%@\" name=\"%@\" playtime=\"%@\" size=\"%@\"></div>", audio.audioId, audio.url, audio.name, audio.playTime, audio.size];
        } else {
            aHtml = [NSString stringWithFormat:@"<div class=\"audioContainer\" id=\"sohuaudio_%@\" src=\"%@\" name=\"%@\" playtime=\"%@\" size=\"%@\"><div class=\"audioTitle\">%@</div></div>", audio.audioId, audio.url, audio.name, audio.playTime, audio.size,audio.name];
        }
        self.content = [self.content stringByReplacingOccurrencesOfString:aId withString:aHtml];
    }
}

- (void)replaceAdInfoContentIfExists {
    for (SNNewsAdInfo *adInfo in self.adInfos) {
        NSString *stringToReplace = [NSString stringWithFormat:@"<adInfo_%@></adInfo_%@>", adInfo.adId, adInfo.adId];

        NSString *htmlString;
        if (adInfo.isValid) {
            htmlString = [NSString stringWithFormat:@"<div class=\"news_adInfo\" id=\"adinfo_%@\" jsonString=\"%@\"></div>", adInfo.adId, [[adInfo toJsonString] stringByReplacingOccurrencesOfString:@"\"" withString:@"##"]];
        } else {
            htmlString = @"";
        }
        self.content = [self.content stringByReplacingOccurrencesOfString:stringToReplace withString:htmlString];
    }
}

- (NSArray *)parseAudioList:(TBXMLElement *)root {
    NSMutableArray *audioList = [NSMutableArray array];
    
    TBXMLElement *audioEles = [TBXML childElementNamed:kAudioInfos parentElement:root];
    if (audioEles != nil) {
        TBXMLElement *audio = [TBXML childElementNamed:kAudioInfo parentElement:audioEles];
        SNNewsAudio *newsAudio = [[SNNewsAudio alloc] init];
        newsAudio.newsId = self.newsId;
        newsAudio.termId = self.termId?self.termId:self.channelId;
        newsAudio.audioId = [TBXML textForElement:[TBXML childElementNamed:kId parentElement:audio]];
        newsAudio.name = [TBXML textForElement:[TBXML childElementNamed:kName parentElement:audio]];
        newsAudio.name = [newsAudio.name trim];
        newsAudio.url = [TBXML textForElement:[TBXML childElementNamed:kUrl parentElement:audio]];
        newsAudio.playTime = [TBXML textForElement:[TBXML childElementNamed:kPlayTime parentElement:audio]];
        newsAudio.size = [TBXML textForElement:[TBXML childElementNamed:kSize parentElement:audio]];
        [audioList addObject:newsAudio];
        
        while ((audio=[TBXML nextSiblingNamed:kAudioInfo searchFromElement:audio]) != nil) {
            SNNewsAudio *newsAudio = [[SNNewsAudio alloc] init];
            newsAudio.newsId = self.newsId;
            newsAudio.termId = self.termId?self.termId:self.channelId;
            newsAudio.audioId = [TBXML textForElement:[TBXML childElementNamed:kId parentElement:audio]];
            newsAudio.name = [TBXML textForElement:[TBXML childElementNamed:kName parentElement:audio]];
            newsAudio.name = [newsAudio.name trim];
            newsAudio.url = [TBXML textForElement:[TBXML childElementNamed:kUrl parentElement:audio]];
            newsAudio.playTime = [TBXML textForElement:[TBXML childElementNamed:kPlayTime parentElement:audio]];
            newsAudio.size = [TBXML textForElement:[TBXML childElementNamed:kSize parentElement:audio]];
            [audioList addObject:newsAudio];
        }
    }
    return audioList;
}

- (NSArray *)parseVideoList:(TBXMLElement *)root {
    NSMutableArray* videoList = [NSMutableArray array];
    
    TBXMLElement *videoEles = [TBXML childElementNamed:kTvInfos parentElement:root];
    if (videoEles != nil) {
        TBXMLElement *video = [TBXML childElementNamed:kTvInfo parentElement:videoEles];

        NSString *__autoplayVideo = [TBXML textForElement:[TBXML childElementNamed:@"autoplayVideo" parentElement:video]];
        self.autoplayVideo = (__autoplayVideo.length <= 0 || [__autoplayVideo integerValue] <= 0) ? NO : YES;
        
        SNNewsVideo *newsVideo   = [[SNNewsVideo alloc] init];
        newsVideo.vId = [TBXML textForElement:[TBXML childElementNamed:kId parentElement:video]];
        newsVideo.name = [TBXML textForElement:[TBXML childElementNamed:kTvName parentElement:video]];
        newsVideo.poster = [TBXML textForElement:[TBXML childElementNamed:kTvPic parentElement:video]];
        newsVideo.layout = [TBXML textForElement:[TBXML childElementNamed:kLayout parentElement:video]];
        newsVideo.playTime = [TBXML textForElement:[TBXML childElementNamed:kTvPlayTime parentElement:video]];
        newsVideo.vvId = [TBXML textForElement:[TBXML childElementNamed:kTvVid parentElement:video]];
        
        newsVideo.playType      = [[TBXML textForElement:[TBXML childElementNamed:@"playType" parentElement:video]] integerValue];
        newsVideo.downloadType  = [[TBXML textForElement:[TBXML childElementNamed:@"download" parentElement:video]] integerValue];
        newsVideo.wapUrl        = [TBXML textForElement:[TBXML childElementNamed:@"wapUrl" parentElement:video]];
        newsVideo.share         = [[SNVideoShare alloc] init];
        newsVideo.share.content = [TBXML textForElement:[TBXML childElementNamed:@"shareContent" parentElement:video]];
        newsVideo.share.h5Url   = [TBXML textForElement:[TBXML childElementNamed:@"h5Url" parentElement:video]];
        if (newsVideo.share.h5Url.length <= 0) {
            newsVideo.share.h5Url = @"";
        }
        
        newsVideo.site          = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kSite parentElement:video]];
        newsVideo.site2         = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kSite2 parentElement:video]];
        newsVideo.siteName      = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kSiteName parentElement:video]];
        newsVideo.siteId        = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kSiteId parentElement:video]];
        newsVideo.playById      = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kPlayById parentElement:video]];
        newsVideo.playAd        = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kPlayAd parentElement:video]];
        newsVideo.adServer      = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kAdServer parentElement:video]];
        
        NSString *_m3u8Source           = [TBXML textForElement:[TBXML childElementNamed:kTvUrlM3u8 parentElement:video]];
        NSString *_MP4VideosStr         = [TBXML textForElement:[TBXML childElementNamed:kTvUrlDivision parentElement:video]];
        NSArray  *_MP4VideosStrArray    = [_MP4VideosStr componentsSeparatedByString:@","];
        NSString *_defaultSource        = [TBXML textForElement:[TBXML childElementNamed:kTvUrl parentElement:video]];
        SNDebugLog(@"\n===============vid:%@, vvid:%@, name:%@ Video Sources:\nMp4:%@\nm3u8:%@\ndefaultSource:%@\n===============",
                   newsVideo.vId, newsVideo.vvId, newsVideo.name, _MP4VideosStrArray, _m3u8Source, _defaultSource);
        
        if (_m3u8Source.length > 0) {
            newsVideo.srcArray = [NSArray arrayWithObject:_m3u8Source];
            newsVideo.newsVideoSrcType = SNNewsVideoSrcType_M3U8;
            SNDebugLog(@"\n===vid:%@, vvid:%@, name:%@ USEING M3U8 VIDEO SOURCE:%@...", newsVideo.vId, newsVideo.vvId, newsVideo.name, newsVideo.srcArray);
        }
        else if (!!_MP4VideosStr && _MP4VideosStr.length>0 && _MP4VideosStrArray.count > 0) {
            newsVideo.srcArray = _MP4VideosStrArray;
            newsVideo.newsVideoSrcType = SNNewsVideoSrcType_MP4Fraction;
            SNDebugLog(@"\n===vid:%@, vvid:%@, name:%@ USEING MP4 VIDEO SOURCE:%@...", newsVideo.vId, newsVideo.vvId, newsVideo.name, newsVideo.srcArray);
        }
        else if (_defaultSource.length > 0) {
            newsVideo.srcArray = [NSArray arrayWithObject:_defaultSource];
            newsVideo.newsVideoSrcType = SNNewsVideoSrcType_TvUrl;
            SNDebugLog(@"\n===vid:%@, vvid:%@, name:%@, USEING DEFAULT VIDEO SOURCE:%@...", newsVideo.vId, newsVideo.vvId, newsVideo.name, newsVideo.srcArray);
        }
        [videoList addObject:newsVideo];
        
        while ((video=[TBXML nextSiblingNamed:kTvInfo searchFromElement:video]) != nil) {
            
            SNNewsVideo *newsVideo   = [[SNNewsVideo alloc] init];
            newsVideo.vId = [TBXML textForElement:[TBXML childElementNamed:kId parentElement:video]];
            newsVideo.name = [TBXML textForElement:[TBXML childElementNamed:kTvName parentElement:video]];
            newsVideo.poster = [TBXML textForElement:[TBXML childElementNamed:kTvPic parentElement:video]];
            newsVideo.layout = [TBXML textForElement:[TBXML childElementNamed:kLayout parentElement:video]];
            newsVideo.playTime = [TBXML textForElement:[TBXML childElementNamed:kTvPlayTime parentElement:video]];
            newsVideo.vvId = [TBXML textForElement:[TBXML childElementNamed:kTvVid parentElement:video]];
            
            newsVideo.playType      = [[TBXML textForElement:[TBXML childElementNamed:@"playType" parentElement:video]] integerValue];
            newsVideo.downloadType  = [[TBXML textForElement:[TBXML childElementNamed:@"download" parentElement:video]] integerValue];
            newsVideo.wapUrl        = [TBXML textForElement:[TBXML childElementNamed:@"wapUrl" parentElement:video]];
            newsVideo.share         = [[SNVideoShare alloc] init];
            newsVideo.share.content = [TBXML textForElement:[TBXML childElementNamed:@"shareContent" parentElement:video]];
            newsVideo.share.h5Url   = [TBXML textForElement:[TBXML childElementNamed:@"h5Url" parentElement:video]];
            if (newsVideo.share.h5Url.length <= 0) {
                newsVideo.share.h5Url = @"";
            }
            
            newsVideo.site          = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kSite parentElement:video]];
            newsVideo.site2         = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kSite2 parentElement:video]];
            newsVideo.siteName      = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kSiteName parentElement:video]];
            newsVideo.siteId        = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kSiteId parentElement:video]];
            newsVideo.playById      = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kPlayById parentElement:video]];
            newsVideo.playAd        = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kPlayAd parentElement:video]];
            newsVideo.adServer      = [TBXML textForElement:[TBXML childElementNamed:SNVideoConst_kAdServer parentElement:video]];
            
            NSString *_m3u8Source           = [TBXML textForElement:[TBXML childElementNamed:kTvUrlM3u8 parentElement:video]];
            NSString *_MP4VideosStr         = [TBXML textForElement:[TBXML childElementNamed:kTvUrlDivision parentElement:video]];
            NSArray  *_MP4VideosStrArray    = [_MP4VideosStr componentsSeparatedByString:@","];
            NSString *_defaultSource        = [TBXML textForElement:[TBXML childElementNamed:kTvUrl parentElement:video]];
            SNDebugLog(@"\n===============vid:%@, vvid:%@, name:%@ Video Sources:\nMp4:%@\nm3u8:%@\ndefaultSource:%@\n===============",
                       newsVideo.vId, newsVideo.vvId, newsVideo.name, _MP4VideosStrArray, _m3u8Source, _defaultSource);
            
            if (_m3u8Source.length > 0) {
                newsVideo.srcArray = [NSArray arrayWithObject:_m3u8Source];
                newsVideo.newsVideoSrcType = SNNewsVideoSrcType_M3U8;
                SNDebugLog(@"\n===vid:%@, vvid:%@, name:%@ USEING M3U8 VIDEO SOURCE:%@...", newsVideo.vId, newsVideo.vvId, newsVideo.name, newsVideo.srcArray);
            }
            else if (_MP4VideosStrArray.count > 0) {
                newsVideo.srcArray = _MP4VideosStrArray;
                newsVideo.newsVideoSrcType = SNNewsVideoSrcType_MP4Fraction;
                SNDebugLog(@"\n===vid:%@, vvid:%@, name:%@ USEING MP4 VIDEO SOURCE:%@...", newsVideo.vId, newsVideo.vvId, newsVideo.name, newsVideo.srcArray);
            }
            else if (_defaultSource.length > 0) {
                newsVideo.srcArray = [NSArray arrayWithObject:_defaultSource];
                newsVideo.newsVideoSrcType = SNNewsVideoSrcType_TvUrl;
                SNDebugLog(@"\n===vid:%@, vvid:%@, name:%@, USEING DEFAULT VIDEO SOURCE:%@...", newsVideo.vId, newsVideo.vvId, newsVideo.name, newsVideo.srcArray);
            }
            [videoList addObject:newsVideo];
        }
    }
    return videoList;
}

- (NSArray *)parseAdInfoList:(TBXMLElement *)root {
    NSMutableArray *adInfoList = [NSMutableArray array];
    
    TBXMLElement *adInfosElm = [TBXML childElementNamed:kNewsAdinfos parentElement:root];
    if (adInfosElm != nil) {
        TBXMLElement *adinfoElm = [TBXML childElementNamed:kNewsAdInfo parentElement:adInfosElm];
        SNNewsAdInfo *anAdInfo = [[SNNewsAdInfo alloc] init];
        anAdInfo.adId = [TBXML textForElement:[TBXML childElementNamed:kId parentElement:adinfoElm]];
        anAdInfo.adAppId = [TBXML textForElement:[TBXML childElementNamed:@"appId" parentElement:adinfoElm]];
        anAdInfo.adUrl = [TBXML textForElement:[TBXML childElementNamed:@"url_scheme" parentElement:adinfoElm]];
        anAdInfo.downloadUrl = [TBXML textForElement:[TBXML childElementNamed:@"download" parentElement:adinfoElm]];
        anAdInfo.iconOpenUrl = [TBXML textForElement:[TBXML childElementNamed:@"icon_open" parentElement:adinfoElm]];
        anAdInfo.iconDownloadUrl = [TBXML textForElement:[TBXML childElementNamed:@"icon_down" parentElement:adinfoElm]];
        anAdInfo.iconWidth = [TBXML textForElement:[TBXML childElementNamed:@"icon_w" parentElement:adinfoElm]];
        anAdInfo.iconHeight = [TBXML textForElement:[TBXML childElementNamed:@"icon_h" parentElement:adinfoElm]];
        [adInfoList addObject:anAdInfo];
        
        
        while ((adinfoElm = [TBXML nextSiblingNamed:kAdInfo searchFromElement:adinfoElm]) != nil) {
            TBXMLElement *adinfoElm = [TBXML childElementNamed:kAdInfo parentElement:adInfosElm];
            SNNewsAdInfo *anAdInfo = [[SNNewsAdInfo alloc] init];
            anAdInfo.adId = [TBXML textForElement:[TBXML childElementNamed:kId parentElement:adinfoElm]];
            anAdInfo.adAppId = [TBXML textForElement:[TBXML childElementNamed:@"appId" parentElement:adinfoElm]];
            anAdInfo.adUrl = [TBXML textForElement:[TBXML childElementNamed:@"url_scheme" parentElement:adinfoElm]];
            anAdInfo.downloadUrl = [TBXML textForElement:[TBXML childElementNamed:@"download" parentElement:adinfoElm]];
            anAdInfo.iconOpenUrl = [TBXML textForElement:[TBXML childElementNamed:@"icon_open" parentElement:adinfoElm]];
            anAdInfo.iconDownloadUrl = [TBXML textForElement:[TBXML childElementNamed:@"icon_down" parentElement:adinfoElm]];
            anAdInfo.iconWidth = [TBXML textForElement:[TBXML childElementNamed:@"icon_w" parentElement:adinfoElm]];
            anAdInfo.iconHeight = [TBXML textForElement:[TBXML childElementNamed:@"icon_h" parentElement:adinfoElm]];
            [adInfoList addObject:anAdInfo];
        }
    }
    
    return adInfoList;
}

+ (id)newsWithNewsId:(NSString *)nId termId:(NSString *)tId userData:(NSDictionary *)userData onLineMode:(BOOL)bOnLineMode {
    return [self newsWithNewsId:nId termId:tId userData:userData onLineMode:bOnLineMode newsPaperPath:nil];
}

+ (id)newsWithNewsId:(NSString *)nId termId:(NSString *)tId userData:(NSDictionary *)userData onLineMode:(BOOL)bOnLineMode newsPaperPath:(NSString*)newsPaperPath{
	
	if (!nId || !tId) {
		SNDebugLog(@"invalid newsId=%@, termId=%@", nId, tId);
		return nil;
	}
    
    NSInteger openType = [[userData objectForKey:kOpenType] integerValue];
	if (bOnLineMode) {
		
		NewsArticleItem *cache = [[SNDBManager currentDataBase] getNewsArticelByTermId:tId newsId:nId];
        
        //如果来自专题，则检查缓存是否过期
        SNSpecialNews *listItemCache = [[SNDBManager currentDataBase] getSpecialNewsByTermId:tId newsId:nId];
        BOOL needsRefresh = listItemCache ? [listItemCache.expired isEqualToString:@"1"] : NO;
		
        // 标题为空认为缓存无效，重新下载
        BOOL isValidCache = (cache && [cache.title isKindOfClass:[NSString class]] && cache.title.length > 0);
        
        // 检查article更新时间
        if (!needsRefresh && isValidCache && [SNUtility getApplicationDelegate].isNetworkReachable) {
            NSString *updateTime = [userData objectForKey:@"updateTime"];
            needsRefresh = [updateTime isKindOfClass:[NSString class]] && [cache.updateTime isKindOfClass:[NSString class]] && ![cache.updateTime isEqualToString:updateTime];
        }
        
        // openType不一致需要重新下载
        if(!needsRefresh && isValidCache && (openType != cache.openType))
        {
            needsRefresh = YES;
        }
        
		if (isValidCache && !needsRefresh) {
			
			SNDebugLog(@"Use news article cache termId=%@ newsId=%@ pre=%@ next=%@ \n content=%@", 
							cache.termId, cache.newsId, cache.preId, cache.nextId, cache.content);
            if (cache.link) {
                SNDebugLog(@"Cache article by link : %@", cache.link);
            }
//            SNDebugLog(@"Cache article by url : %@", [SNUtility addParamP1ToURL:url]);
			
			SNArticle *a = [[SNArticle alloc] init];
			
			a.newsId		= cache.newsId;
			a.title			= cache.title;
			a.from			= cache.from;
            a.newsMark      = cache.newsMark;
            a.originFrom    = cache.originFrom;
            a.originTitle   = cache.originTitle;
			a.time			= cache.time;
            a.updateTime    = cache.updateTime;
			a.content		= cache.content;
			a.preId			= cache.preId;
			a.nextId		= cache.nextId;
            a.nextNewsLink  = cache.nextNewsLink;
            a.nextNewsLink2 = cache.nextNewsLink2;
			a.termId		= cache.termId;
			a.commentNum	= cache.commentNum;
			a.link			= cache.link;
			a.shareContent  = cache.shareContent;
            a.subId         = cache.subId;
            a.action        = cache.action;
            a.isPublished   = cache.isPublished;
            a.editNewsLink  = cache.editNewsLink;
            a.operators     = cache.operators;
            a.comtStatus    = cache.cmtStatus;
            a.comtHint      = cache.cmtHint;
            a.cmtRead       = cache.cmtRead;
            a.logoUrl       = cache.logoUrl;
            a.linkUrl       = cache.linkUrl;
            a.favour        = cache.favour;
            a.h5link        = cache.h5link;
            a.newsType      = cache.newsType;
            a.openType      = cache.openType;
            a.favIcon       = cache.favIcon;
            a.mediaLink     = cache.mediaLink;
            a.mediaName     = cache.mediaName;
            a.optimizeRead  = cache.optimizeRead;
            a.tagChannelItems = cache.tagChannels;
            a.stockItems    = cache.stocks;
            NSArray *shareImageList = [[SNDBManager currentDataBase] getNewsImageByTermId:a.termId newsId:a.newsId];
            a.newsImageItems   = shareImageList;

            // 检查thumbnail
            cache.thumbnailImages = [[SNDBManager currentDataBase] getThumbnailUrlFromNewsContent:cache.content];
            a.thumbnailImages = cache.thumbnailImages;

            
            // load votesinfo cache
            a.votesInfo = [SNNewsVoteService votesInfoFromLocalDBByNewsID:a.newsId];
            a.audios = [[SNDBManager currentDataBase] getNewsAudioByTermId:tId newsId:nId];
            //SNDebugLog(@"content: %@", a.content);
			return a;
			
		} 
		//no cache
		else {
			NSString *url = nil;
            SNURLRequest *request = nil;
			NSData *data = nil;

            NSString *linkStr = [userData stringValueForKey:kLink defaultValue:nil];
            NSDictionary *linkParams = [SNUtility parseLinkParams:linkStr];
            
            if ((url = [linkParams stringValueForKey:kCDNUrl defaultValue:nil]) && url.length > 0) {
                url = [url URLDecodedString];
                request = [SNURLRequest requestWithURL:url delegate:self isParamP:NO];
            } else {
                url = [NSString stringWithFormat:kUrlNewsArticle, nId, tId, kRecommendNewsCount];
                
                if (userData) {
                    NSString *recommendParams = [userData objectForKey:@"recommendParams"];
                    if ([recommendParams length] > 0) {
                        url = [url stringByAppendingFormat:@"&%@", recommendParams];
                    }
                    
                    // 添加打开article的link所带的所有字段
                    url = [SNUtility strByAppendingParamsToUrl:url fromLink:userData];
                }
                request = [SNURLRequest requestWithURL:url delegate:self];
            }
			
            request.cachePolicy = TTURLRequestCachePolicyNoCache;
			request.response = [[SNURLDataResponse alloc] init];
			[request sendSynchronously];
			
			SNURLDataResponse *resp = request.response;
			data = resp.data;
			
			if (data) {
				SNArticle *a = [[SNArticle alloc] initWithNewsId:nId termId:tId XMLData:data openType:openType];
                a.favour = cache.favour;
                if (![a isValid]) {
                    SNDebugLog(@"article data failed: %@", [NSString stringWithUTF8String:[data bytes]]);
                    return nil;
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [a saveAsCache];
                });
				return a;
			} else {
				SNDebugLog(@"load article fail");
				return nil;
			}
		}
	} 
	//offline mode
	else {
		NewspaperItem *newspaper	= [[SNDBManager currentDataBase] getNewspaperByTermId:tId];
        if(newsPaperPath.length>0)
        {
            NSString *newsFileName	= [NSString stringWithFormat:@"%@_%@.xml",tId,nId];
            NSString *newsFilePath	= [newsPaperPath stringByAppendingPathComponent:newsFileName];
            
            NSFileManager *fm	= [NSFileManager defaultManager];
            if (newsFilePath && [fm fileExistsAtPath:newsFilePath]) {
                
                NSData *newsData	= [NSData dataWithContentsOfFile:newsFilePath];
                
                return [[SNArticle alloc] initWithNewsId:nId termId:tId XMLData:newsData openType:openType onLineMode:NO newsPaperPath:newsPaperPath];
            }
            else {
                SNDebugLog(@"newsWithNewsId : news file not exist,path = %@",newsFilePath);
            }
        } else if (newspaper != nil) {   
            NSString *paperPath = [newspaper realNewspaperPath];
            
            NSRange rangeLastPath	= [paperPath rangeOfString:@"/" options: NSBackwardsSearch];
            //SNDebugLog(paperPath);
            if (rangeLastPath.location == NSNotFound) {
                SNDebugLog(@"initNewsWebView : Invalid newspaper path,%@",paperPath);
            }
            else {
                NSString *newsFileName	= [NSString stringWithFormat:@"%@_%@.xml",tId,nId];
                NSString *newsFilePath	= [[paperPath substringToIndex:rangeLastPath.location]
                                           stringByAppendingPathComponent:newsFileName];
                
                NSFileManager *fm	= [NSFileManager defaultManager];
                if ([fm fileExistsAtPath:newsFilePath]) {
                    
                    NSData *newsData	= [NSData dataWithContentsOfFile:newsFilePath];
                    
                    return [[SNArticle alloc] initWithNewsId:nId termId:tId XMLData:newsData openType:openType onLineMode:NO];
                }
                else {
                    SNDebugLog(@"newsWithNewsId : news file not exist,path = %@",newsFilePath);
                }
            }
        }
		else {
			SNDebugLog(@"newsWithNewsId : Can't find newspaper,newsid = %@",nId);
            /**
             *  如果有网情况下离线模式，列表页会加载新的新闻，但是数据库里新闻内容是不存在的，所以有打不开新闻的bug，需要改变onlineMode重新获取新闻内容
             */
          return [SNArticle newsWithNewsId:nId termId:tId userData:userData onLineMode:YES newsPaperPath:nil];
		}
	}
	
	return nil;
}

- (id)initWithNewsId:(NSString *)nId termId:(NSString *)tId XMLData:(NSData *)xmlData openType:(NSInteger)openType{
	return [self initWithNewsId:nId termId:tId XMLData:xmlData openType:(NSInteger)openType onLineMode:YES];
}

- (id)initWithNewsId:(NSString *)nId termId:(NSString *)tId XMLData:(NSData *)xmlData openType:(NSInteger)openType onLineMode:(BOOL)bOnLineMode {
    return [self initWithNewsId:nId termId:tId XMLData:xmlData openType:(NSInteger)openType onLineMode:bOnLineMode newsPaperPath:nil];
}

- (id)initWithNewsId:(NSString *)nId termId:(NSString *)tId XMLData:(NSData *)xmlData openType:(NSInteger)openType onLineMode:(BOOL)bOnLineMode newsPaperPath:(NSString*)newsPaperPath{
	
	if (!xmlData) {
		SNDebugLog(@"News xml data is nil");
		return nil;
	}
	
	//SNDebugLog(@"article data: %@", [NSString stringWithUTF8String:[xmlData bytes]]);
	
	
	if (self=[super init]) {
		
        self.newsId = nId;
        self.termId = tId;
		
		TBXML *tbxml = [TBXML tbxmlWithXMLData:xmlData];
		
		TBXMLElement *root = tbxml.rootXMLElement;
		
		self.title		= [TBXML textForElement:[TBXML childElementNamed:kTitle parentElement:root]];		
		self.from		= [TBXML textForElement:[TBXML childElementNamed:kFrom parentElement:root]];
        self.originFrom = [TBXML textForElement:[TBXML childElementNamed:kOriginFrom parentElement:root]];
        self.newsMark   = [TBXML textForElement:[TBXML childElementNamed:kNewsMark parentElement:root]];
        self.originTitle= [TBXML textForElement:[TBXML childElementNamed:kOriginTitle parentElement:root]];
		self.time		= [TBXML textForElement:[TBXML childElementNamed:kTime parentElement:root]];
        self.updateTime = [TBXML textForElement:[TBXML childElementNamed:kUpdateTime parentElement:root]];
        self.comtStatus = [TBXML textForElement:[TBXML childElementNamed:kCmtStatus parentElement:root]];
        self.comtHint = [TBXML textForElement:[TBXML childElementNamed:kCmtHint parentElement:root]];
        self.h5link = [TBXML textForElement:[TBXML childElementNamed:kH5link parentElement:root]];
        if ([self.h5link rangeOfString:@"&amp;"].location != NSNotFound) {//去html编码  by huang
            self.h5link = [[self.h5link componentsSeparatedByString:@"&amp;"] componentsJoinedByString:@"&"];
        }

        self.favIcon = [TBXML textForElement:[TBXML childElementNamed:kFavIcon parentElement:root]];
        self.newsType = [[TBXML textForElement:[TBXML childElementNamed:kNewsType parentElement:root]] integerValue];
        self.cmtRead  = NO;
        self.favour = NO;
        self.voteXML    = [SNNewsVoteService getVotesXMLFromData:xmlData];
        self.openType = openType;
        TBXMLElement *httpHeader = [TBXML childElementNamed:kHttpHeader parentElement:root];
        if (httpHeader) {
            self.logoUrl = [TBXML textForElement:[TBXML childElementNamed:kLogoUrl parentElement:httpHeader]];
            self.linkUrl = [TBXML textForElement:[TBXML childElementNamed:kLinkUrl parentElement:httpHeader]];
            if ([self.linkUrl rangeOfString:@"&amp;"].location != NSNotFound) {//去html编码 by huang
                self.linkUrl = [[self.linkUrl componentsSeparatedByString:@"&amp;"] componentsJoinedByString:@"&"];
            }
        }
        TBXMLElement *media = [TBXML childElementNamed:kMedia parentElement:root];
        if(media)
        {
            self.mediaName = [TBXML textForElement:[TBXML childElementNamed:kMediaName parentElement:media]];
            self.mediaLink = [TBXML textForElement:[TBXML childElementNamed:kMediaLink parentElement:media]];
        }
        self.optimizeRead = [TBXML textForElement:[TBXML childElementNamed:kOptimizeRead parentElement:root]];
		NSString *newsContent	= [TBXML textForElement:[TBXML childElementNamed:kContent parentElement:root]];
		if (!bOnLineMode) {
			self.content	= [self locateNewsContentImgToLocalPath:newsContent termId:tId newspaperPath:newsPaperPath];
		}
		else {
			self.content	= newsContent;
		}
		
		self.commentNum	= [TBXML textForElement:[TBXML childElementNamed:kCommentNum parentElement:root]];		
		self.link		= [TBXML textForElement:[TBXML childElementNamed:kLink parentElement:root]];		
		self.shareContent = [TBXML textForElement:[TBXML childElementNamed:kShareContent parentElement:root]];
        
        NSMutableArray *tagChannelAry = [NSMutableArray array];
        TBXMLElement *tagChannels = [TBXML childElementNamed:kTagChannels parentElement:root];
        if (tagChannels != nil) {
            TBXMLElement *tagChannel = [TBXML childElementNamed:kTagChannel parentElement:tagChannels];
            if (tagChannel) {
                NewsTagChannelItem *tagChannelItem = [[NewsTagChannelItem alloc] init];
                TBXMLElement *tagName = [TBXML childElementNamed:kTagChannelName parentElement:tagChannel];
                TBXMLElement *tagLink = [TBXML childElementNamed:kTagChannelLink parentElement:tagChannel];
                tagChannelItem.name = [TBXML textForElement:tagName];
                tagChannelItem.link = [TBXML textForElement:tagLink];
                [tagChannelAry addObject:tagChannelItem];
                
                while ((tagChannel = [TBXML nextSiblingNamed:kTagChannel searchFromElement:tagChannel]) != nil) {
                    NewsTagChannelItem *tagChannelItem = [[NewsTagChannelItem alloc] init];
                    TBXMLElement *tagName = [TBXML childElementNamed:kTagChannelName parentElement:tagChannel];
                    TBXMLElement *tagLink = [TBXML childElementNamed:kTagChannelLink parentElement:tagChannel];
                    tagChannelItem.name = [TBXML textForElement:tagName];
                    tagChannelItem.link = [TBXML textForElement:tagLink];
                    [tagChannelAry addObject:tagChannelItem];
                }
            }
        }
        self.tagChannelItems = tagChannelAry;
        
        NSMutableArray *stocksAry = [NSMutableArray array];
        TBXMLElement *stocks = [TBXML childElementNamed:kStocks parentElement:root];
        if (stocks != nil) {
            TBXMLElement *stock = [TBXML childElementNamed:kStock parentElement:stocks];
            if (stock) {
                NewsStockItem *stockItem = [[NewsStockItem alloc] init];
                TBXMLElement *stockName = [TBXML childElementNamed:kStockName parentElement:stock];
                TBXMLElement *stockLink = [TBXML childElementNamed:kStockLink parentElement:stock];
                stockItem.name = [TBXML textForElement:stockName];
                stockItem.link = [TBXML textForElement:stockLink];
                [stocksAry addObject:stockItem];
                
                while ((stock = [TBXML nextSiblingNamed:kStock searchFromElement:stock]) != nil) {
                    NewsStockItem *stockItem = [[NewsStockItem alloc] init];
                    TBXMLElement *stockName = [TBXML childElementNamed:kStockName parentElement:stock];
                    TBXMLElement *stockLink = [TBXML childElementNamed:kStockLink parentElement:stock];
                    stockItem.name = [TBXML textForElement:stockName];
                    stockItem.link = [TBXML textForElement:stockLink];
                    [stocksAry addObject:stockItem];
                }
            }
        }
        self.stockItems = stocksAry;
        
        NSMutableArray* shareImagesAry    = [NSMutableArray array];
        TBXMLElement *images = [TBXML childElementNamed:kPhotos parentElement:root];
        if (images != nil) {
            TBXMLElement *image = [TBXML childElementNamed:kPhoto parentElement:images];
            if (image != nil) {
                NewsImageItem *shareImageItem   = [[NewsImageItem alloc] init];
                shareImageItem.termId           = self.termId;
                shareImageItem.newsId           = self.newsId;
                shareImageItem.type             = NEWSSHAREIMAGE_TYPE;
                
                TBXMLElement *pic = [TBXML childElementNamed:kPic parentElement:image];
                TBXMLElement *abstract = [TBXML childElementNamed:kAbstract parentElement:image];
                TBXMLElement *widthElement = [TBXML childElementNamed:kWidth parentElement:image];
                TBXMLElement *heightElement = [TBXML childElementNamed:kHeight parentElement:image];
                
                shareImageItem.url              = [TBXML textForElement:pic];
                NSString *abstractStr = [TBXML textForElement:abstract];
                if ([abstractStr isMatchedByRegex:@"(%[0-9a-f]{2})+" options:RKLCaseless inRange:NSMakeRange(0, abstractStr.length) error:nil]) {
                    abstractStr = [abstractStr URLDecodedString];
                }
                shareImageItem.title            = abstractStr;
                shareImageItem.width            = [[TBXML textForElement:widthElement] integerValue];
                shareImageItem.height            = [[TBXML textForElement:heightElement] integerValue];
                [shareImagesAry addObject:shareImageItem];
                
                while ((image=[TBXML nextSiblingNamed:kPhoto searchFromElement:image]) != nil) {
                    shareImageItem   = [[NewsImageItem alloc] init];
                    shareImageItem.termId           = self.termId;
                    shareImageItem.newsId           = self.newsId;
                    shareImageItem.type             = NEWSSHAREIMAGE_TYPE;
                    TBXMLElement *pic = [TBXML childElementNamed:kPic parentElement:image];
                    TBXMLElement *abstract = [TBXML childElementNamed:kAbstract parentElement:image];
                    TBXMLElement *widthElement = [TBXML childElementNamed:kWidth parentElement:image];
                    TBXMLElement *heightElement = [TBXML childElementNamed:kHeight parentElement:image];
                    shareImageItem.url              = [TBXML textForElement:pic];
                    NSString *abstractStr = [TBXML textForElement:abstract];
                    if ([abstractStr isMatchedByRegex:@"(%[0-9a-f]{2})+" options:RKLCaseless inRange:NSMakeRange(0, abstractStr.length) error:nil]) {
                        abstractStr = [abstractStr URLDecodedString];
                    }
                    shareImageItem.title            = abstractStr;
                    shareImageItem.width            = [[TBXML textForElement:widthElement] integerValue];
                    shareImageItem.height            = [[TBXML textForElement:heightElement] integerValue];
                    [shareImagesAry addObject:shareImageItem];
                }

            }
        }
        
        self.newsImageItems    = shareImagesAry;

//        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:5];
//        for (NewsImageItem *img in self.shareImages) {
//            [arr addObject:img.url];
//        }

        self.thumbnailImages = [[SNDBManager currentDataBase] getImageUrlFromNewsContent:self.content];

        //audios
        NSArray *audioList = [self parseAudioList:root];
        self.audios = audioList;
        [self replaceAudioContentIfExists];

        //videos
        self.videos = [self parseVideoList:root];
        [self replaceVideoContentIfExists];
        
        // adinfo
        self.adInfos = [self parseAdInfoList:root];
        [self replaceAdInfoContentIfExists];
        
        //解析投票
        //<votes>
        TBXMLElement *voteEles = [TBXML childElementNamed:kVotes parentElement:root];
        
        if (voteEles != nil) {
            self.votesInfo = [SNNewsVoteService votesInfoFromXMLElement:voteEles];
        } //<votes>
        
        // 解析subInfo
        TBXMLElement *subEles = [TBXML childElementNamed:@"subInfo" parentElement:root];
        if (subEles != nil) {
            self.subId = [TBXML textForElement:[TBXML childElementNamed:@"subId" parentElement:subEles]];
            if (self.subId.length > 0) {
                SCSubscribeObject *subObj = [SCSubscribeObject subscribeObjFromXMLData:subEles];
                subObj.subId = self.subId;
                [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
            }
        }
        
        // 解析shareRead
        TBXMLElement *shareRead = [TBXML childElementNamed:@"shareRead" parentElement:root];
        if (shareRead) {
            SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromXMLObj:shareRead];
            if (obj) [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypeNews contentId:nId];
        }
        
        // 4.0广告 解析定向回传参数 by jojo
        // 先清除之前缓存的广告数据
        [[SNDBManager currentDataBase] adInfoClearAdInfosByType:SNAdInfoTypeArticle dataId:nId categoryId:tId];
        
        TBXMLElement *adInfoControls = [TBXML childElementNamed:@"adControlInfos" parentElement:root];
        if (adInfoControls) {
            NSMutableArray *adInfosArray = [NSMutableArray array];
            TBXMLElement *adInfoElm = [TBXML childElementNamed:@"adControlInfo" parentElement:adInfoControls];
            if (adInfoElm) {
                SNAdControllInfo *adInfoObj = [[SNAdControllInfo alloc] initWithXMLElement:adInfoElm];
                [adInfosArray addObject:adInfoObj];
                
                while (!!(adInfoElm = [TBXML nextSiblingNamed:@"adControlInfo" searchFromElement:adInfoElm])) {
                    SNAdControllInfo *adInfoObj = [[SNAdControllInfo alloc] initWithXMLElement:adInfoElm];
                    [adInfosArray addObject:adInfoObj];
                }
            }
            
            // 缓存本地数据库
            [[SNDBManager currentDataBase] adInfoAddOrUpdateAdInfos:adInfosArray withType:SNAdInfoTypeArticle dataId:nId categoryId:tId];
        }
        
        // 解析opencms管理操作权限节点
        TBXMLElement *operationInfo = [TBXML childElementNamed:@"operationInfo" parentElement:root];
        if (operationInfo) {
            self.action = [TBXML textForElement:[TBXML childElementNamed:@"action" parentElement:operationInfo]];
            self.isPublished = [TBXML textForElement:[TBXML childElementNamed:@"isPublished" parentElement:operationInfo]];
            self.editNewsLink = [TBXML textForElement:[TBXML childElementNamed:@"editNewsLink" parentElement:operationInfo]];
            self.operators = [TBXML textForElement:[TBXML childElementNamed:@"operators" parentElement:operationInfo]];
        }
        
        TBXMLElement *cmtControl = [TBXML childElementNamed:@"comtRel" parentElement:root];
        if (cmtControl) {
            self.comtStatus = [TBXML textForElement:[TBXML childElementNamed:kCmtStatus parentElement:cmtControl]];
            self.comtHint = [TBXML textForElement:[TBXML childElementNamed:kCmtHint parentElement:cmtControl]];
            self.comtRemarkTips = [TBXML textForElement:[TBXML childElementNamed:kCmtRemarkTips parentElement:cmtControl]];
            [SNUtility setCmtRemarkTips:self.comtRemarkTips];
        }
        SNDebugLog(@"%@", self.content);       
        
		TBXMLElement *pre = [TBXML childElementNamed:kPreId parentElement:root];
		TBXMLElement *next = [TBXML childElementNamed:kNextId parentElement:root];
		if (pre) {
			self.preId = [TBXML textForElement:pre];
		}
		if (next) {
			self.nextId = [TBXML textForElement:next];
		}
        
		TBXMLElement *nextLink = [TBXML childElementNamed:kNextNewsLink parentElement:root];
		if (nextLink) {
			self.nextNewsLink = [TBXML textForElement:nextLink];
		}
        TBXMLElement *nextLink2 = [TBXML childElementNamed:kNextNewsLink2 parentElement:root];
		if (nextLink) {
			self.nextNewsLink2 = [TBXML textForElement:nextLink2];
		}
		
	}
	return self;
}

#pragma mark - For RollingNews download

//This methods added by handy for RollingNews download.
+ (id)newsForDownloadWithNewsId:(NSString *)nId channelId:(NSString *)cId paramsDic:(NSDictionary *)params {
	
	if (!nId || !cId) {
		SNDebugLog(@"invalid Rolling newsId=%@, channelId=%@", nId, cId);
		return nil;
	}
    
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    @autoreleasepool {
        id articleJson = [jsKitStorage getItem:[NSString stringWithFormat:@"article%@", nId]];
        if (articleJson) {
            return nil;
        }
    }
    
    //no cache
    NSData *data = nil;
    SNURLRequest *request = nil;
    NSString *url = nil;
    
    if ((url = [params stringValueForKey:kCDNUrl defaultValue:nil]) && url.length > 0) {
        url = [url URLDecodedString];
        request = [SNURLRequest requestWithURL:url delegate:self isParamP:NO];
    } else {
        url = [NSString stringWithFormat:kUrlRollingNewsArticle, nId, cId, kRecommendNewsCount];
        
        if (params) url = [params appendParamToUrlString:url];
        
        request = [SNURLRequest requestWithURL:url delegate:self];
    }
    
    request.cachePolicy = TTURLRequestCachePolicyDefault;
    request.response = [[SNURLJSONResponse alloc] init];
    [request sendSynchronously];
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    
    [jsKitStorage setItem:jsonData forKey:[NSString stringWithFormat:@"article%@",nId] withExpire:[NSNumber numberWithInt:172800]];
    
    return nil;
}
// MARK: - 新闻下载缓存使用此方法
+ (void)newsDownloadWithNewsId:(NSString *)nId channelId:(NSString *)cId paramsDic:(NSDictionary *)params {
    
    if (!nId || !cId) {
        SNDebugLog(@"invalid Rolling newsId=%@, channelId=%@", nId, cId);
        return;
    }
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    id articleJson = [jsKitStorage getItem:[NSString stringWithFormat:@"article%@", nId]];
    if (articleJson) {
        return;
    }
    [[[SNArticleRequest alloc] initWithNewsId:nId channelId:cId andCDNParams:params] send:^(SNBaseRequest *request, id responseObject) {
       dispatch_async(dispatch_get_global_queue(0, 0), ^{
           @try {
               if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                   [jsKitStorage setItem:responseObject
                                  forKey:[NSString stringWithFormat:@"article%@",nId]
                              withExpire:[NSNumber numberWithInt:172800]];
               }
           } @catch (NSException *exception) {
               SNDebugLog(@"SNArticleRequest exception reason--%@", exception.reason);
           } @finally {
               
           }
       });
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
    
}

// MARK: - SNS 调起 SNMySDK.m
+ (void)newsWithNewsId:(NSString *)nId
                termId:(NSString *)tId
              userData:(NSDictionary *)userData
              callBack:(void(^)(NSDictionary *acticleJson))callBack {
    if (!nId || !tId) {
        SNDebugLog(@"invalid Rolling newsId=%@, channelId=%@", nId, tId);
        return;
    }
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    @autoreleasepool {
        id articleJson = [jsKitStorage getItem:[NSString stringWithFormat:@"article%@", nId]];
        if (articleJson && [articleJson isKindOfClass:[NSDictionary class]] && callBack) {
            callBack(articleJson);
            return;
        }
    }
    
    NSString *linkStr = [userData stringValueForKey:kLink defaultValue:nil];
    NSDictionary *linkParams = [SNUtility parseLinkParams:linkStr];
    
    NSMutableDictionary *articleParams = [NSMutableDictionary dictionaryWithCapacity:2];
    if (userData) {
        NSString *recommendParams = [userData objectForKey:@"recommendParams"];
        if ([recommendParams length] > 0) {
            [articleParams setValuesForKeysWithDictionary:[NSString getURLParas:recommendParams]];
        }
    }
    // 添加打开article的link所带的所有字段
    articleParams = [SNUtility appendingParamsToUrl:articleParams fromLink:userData].mutableCopy;
    
    [[[SNArticleRequest alloc] initWithNewsId:nId termId:tId CDNParams:linkParams andArticleParams:articleParams] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]] && callBack) {
            callBack(responseObject);
            
            [jsKitStorage setItem:responseObject
                           forKey:[NSString stringWithFormat:@"article%@",nId]
                       withExpire:[NSNumber numberWithInt:172800]];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"load article fail");
    }];
    
}


+ (id)newsForDownloadWithNewsId:(NSString *)nId termId:(NSString *)tId paramsDic:(NSDictionary *)params{
    
	if (!nId || !tId) {
		SNDebugLog(@"invalid newsId=%@, termId=%@", nId, tId);
		return nil;
	}
    
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    @autoreleasepool {
        id articleJson = [jsKitStorage getItem:[NSString stringWithFormat:@"article%@", nId]];
        if (articleJson) {
            return nil;
        }
    }
    
    NSData *data = nil;
    NSString *url = nil;
    
    url = [NSString stringWithFormat:kUrlNewsArticle, nId, tId, kRecommendNewsCount];
    
    url = [params appendParamToUrlString:url];
    
    SNURLRequest *request = [SNURLRequest requestWithURL:url delegate:self];
    request.cachePolicy = TTURLRequestCachePolicyNoCache;
    request.response = [[SNURLJSONResponse alloc] init];
    [request sendSynchronously];
    SNURLJSONResponse *json = request.response;
    id jsonData = json.rootObject;
    
    [jsKitStorage setItem:jsonData forKey:[NSString stringWithFormat:@"article%@",nId] withExpire:[NSNumber numberWithInt:172800]];
    
    return nil;
}

- (void)saveAsCacheForDownload {
    
	SNDebugLog(@"saveAsCache begin,thread = %@",[NSThread currentThread]);
	
	NewsArticleItem *cache = [[NewsArticleItem alloc] init];
	
	cache.newsId		= self.newsId;
	cache.title			= self.title;
	cache.from			= self.from;
    cache.newsMark      = self.newsMark;
    cache.originFrom    = self.originFrom;
    cache.originTitle   = self.originTitle;
	cache.time			= self.time;
    cache.updateTime	= self.updateTime;
	cache.content		= self.content;
	cache.preId			= self.preId;
	cache.nextId		= self.nextId;
    cache.nextNewsLink  = self.nextNewsLink;
    cache.nextNewsLink2 = self.nextNewsLink2;
	cache.termId		= self.termId;
	cache.channelId		= self.channelId;
	cache.commentNum	= self.commentNum;
	cache.link			= self.link;
	cache.shareContent	= self.shareContent;
    cache.shareImages   = self.newsImageItems;
	cache.thumbnailImages = self.thumbnailImages;
    cache.subId         = self.subId;
    cache.action        = self.action;
    cache.isPublished   = self.isPublished;
    cache.editNewsLink  = self.editNewsLink;
    cache.operators     = self.operators;
    cache.cmtStatus     = self.comtStatus;
    cache.cmtHint       = self.comtHint;
    cache.cmtRead       = self.cmtRead;
    cache.logoUrl       = self.logoUrl;
    cache.linkUrl       = self.linkUrl;
    cache.favour        = self.favour;
    cache.newsType      = self.newsType;
    cache.h5link        = self.h5link;
    cache.openType      = self.openType;
    cache.favIcon       = self.favIcon;
    cache.mediaName     = self.mediaName;
    cache.mediaLink     = self.mediaLink;
    cache.optimizeRead  = self.optimizeRead;
    cache.tagChannels   = self.tagChannelItems;
    cache.stocks        = self.stockItems;
    
    SNDebugLog(@"INFO: SELF: channelId %@, termId %@, CACHE: channelId %@, termId %@, newsId %@",
               self.channelId, self.termId, cache.channelId, cache.termId, self.newsId);
    
    if (cache.channelId) {
        [[SNDBManager currentDataBase] addSingleNewsArticle:cache updateIfExist:YES withOption:ADDNEWSARTICLE_BY_CHANNELID];
        
        [[SNDBManager currentDataBase] markRollingNewsListItemAsNotExpiredByChannelId:cache.channelId newsId:cache.newsId];
        
        SNDebugLog(@"set rolling news read in cache=%@", cache.title);
        
    } else if (cache.termId) {
        [[SNDBManager currentDataBase] addSingleNewsArticle:cache updateIfExist:YES withOption:ADDNEWSARTICLE_BY_CHANNELID];
    } else {
        [[SNDBManager currentDataBase] addSingleNewsArticle:cache updateIfExist:YES withOption:ADDNEWSARTICLE_BY_TERMID];
    }
    
    [[SNDBManager currentDataBase] addMultiNewsAudio:self.audios];
    // save votes cache
    SNDebugLog(@"voteXML=%@ \nvotesInfo=%@", self.voteXML, self.votesInfo);
    if ([self.voteXML length] > 0 && self.votesInfo != nil) {
        VotesInfo *voteInfo = [[VotesInfo alloc] init];
        voteInfo.newsID = cache.newsId;
        if (self.votesInfo.topicId) voteInfo.topicID = self.votesInfo.topicId;
        if (self.voteXML) voteInfo.voteXML = self.voteXML;
        voteInfo.isVoted = @"0";

        [[SNDBManager currentDataBase] addOrUpdateOneVoteInfo:voteInfo];
    }

}

#pragma mark -

- (id)initWithNewsId:(NSString *)nId channelId:(NSString *)cId XMLData:(NSData *)xmlData openType:(NSInteger)openType{
	return [self initWithNewsId:nId channelId:cId XMLData:xmlData openType:(NSInteger)openType onLineMode:YES];
}

- (SNNewsVoteItem *)parseNewsVoteItemFromXMLElement:(TBXMLElement *)voteItemElem {
    SNNewsVoteItem *voteItem = [[SNNewsVoteItem alloc] init];
    
    voteItem.voteId = [TBXML textForElement:[TBXML childElementNamed:kVoteItemId parentElement:voteItemElem]];
    voteItem.content = [TBXML textForElement:[TBXML childElementNamed:kVoteItemContent parentElement:voteItemElem]];
    voteItem.voteType = [TBXML textForElement:[TBXML childElementNamed:kVoteItemVoteType parentElement:voteItemElem]];
    voteItem.postion = [TBXML textForElement:[TBXML childElementNamed:kVoteItemPosition parentElement:voteItemElem]];
    voteItem.minVoteNum = [TBXML textForElement:[TBXML childElementNamed:kVoteItemMinVoteNum parentElement:voteItemElem]];
    voteItem.maxVoteNum = [TBXML textForElement:[TBXML childElementNamed:kVoteItemMaxVoteNum parentElement:voteItemElem]];
    
    //<option>
    NSMutableArray* optionList = [NSMutableArray array];
    
    TBXMLElement *optionElem = [TBXML childElementNamed:kVoteItemOption parentElement:voteItemElem];
    
    if (optionElem) {
        SNNewsVoteItemOption *optionItem = [[SNNewsVoteItemOption alloc] init];
        
        optionItem.optionId = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionId parentElement:optionElem]];
        optionItem.name = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionName parentElement:optionElem]];
        optionItem.position = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionPos parentElement:optionElem]];
        optionItem.optionDesc = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionDesc parentElement:optionElem]];
        optionItem.type = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionType parentElement:optionElem]];
        
        [optionList addObject:optionItem];
        
        while ((optionElem = [TBXML nextSiblingNamed:kVoteItemOption searchFromElement:optionElem]) != nil) {
            
            SNNewsVoteItemOption *optionItem = [[SNNewsVoteItemOption alloc] init];
            
            optionItem.optionId = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionId parentElement:optionElem]];
            optionItem.name = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionName parentElement:optionElem]];
            optionItem.position = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionPos parentElement:optionElem]];
            optionItem.picPath = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionPic parentElement:optionElem]];
            optionItem.smallPicPath = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionSmallPic parentElement:optionElem]];
            optionItem.optionDesc = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionDesc parentElement:optionElem]];
            optionItem.type = [TBXML textForElement:[TBXML childElementNamed:kVoteItemOptionType parentElement:optionElem]];
            
            [optionList addObject:optionItem];
        }
        
    }
    //</option>
    voteItem.optionArray = optionList;

    return voteItem;
}

- (id)initWithNewsId:(NSString *)nId channelId:(NSString *)cId XMLData:(NSData *)xmlData openType:(NSInteger)openType onLineMode:(BOOL)bOnLineMode {
	
	if (!xmlData) {
		SNDebugLog(@"Rolling News xml data is nil");
		return nil;
	}
	
	//SNDebugLog(@"Rolling article data: %@", [NSString stringWithUTF8String:[xmlData bytes]]);
	
	if (self=[super init]) {
		
		self.newsId = nId;
		self.channelId = cId;
		
		TBXML *tbxml = [TBXML tbxmlWithXMLData:xmlData];
		
		TBXMLElement *root = tbxml.rootXMLElement;
		
		self.title		= [TBXML textForElement:[TBXML childElementNamed:kTitle parentElement:root]];
		self.from		= [TBXML textForElement:[TBXML childElementNamed:kFrom parentElement:root]];
        self.originFrom = [TBXML textForElement:[TBXML childElementNamed:kOriginFrom parentElement:root]];
        self.newsMark   = [TBXML textForElement:[TBXML childElementNamed:kNewsMark parentElement:root]];
        self.originTitle= [TBXML textForElement:[TBXML childElementNamed:kOriginTitle parentElement:root]];
		self.time		= [TBXML textForElement:[TBXML childElementNamed:kTime parentElement:root]];
        self.updateTime = [TBXML textForElement:[TBXML childElementNamed:kUpdateTime parentElement:root]];
		self.content	= [TBXML textForElement:[TBXML childElementNamed:kContent parentElement:root]];		
		self.commentNum	= [TBXML textForElement:[TBXML childElementNamed:kCommentNum parentElement:root]];		
		self.link		= [TBXML textForElement:[TBXML childElementNamed:kLink parentElement:root]];
		self.shareContent = [TBXML textForElement:[TBXML childElementNamed:kShareContent parentElement:root]];
        self.nextId     = [TBXML textForElement:[TBXML childElementNamed:kNextId parentElement:root]];
        self.nextNewsLink = [TBXML textForElement:[TBXML childElementNamed:kNextNewsLink parentElement:root]];
        self.nextNewsLink2 = [TBXML textForElement:[TBXML childElementNamed:kNextNewsLink2 parentElement:root]];
        self.voteXML = [SNNewsVoteService getVotesXMLFromData:xmlData];
		self.thirdPartUrl = [TBXML textForElement:[TBXML childElementNamed:kThirdPartUrl parentElement:root]];
        self.cmtRead = NO;
        self.h5link = [TBXML textForElement:[TBXML childElementNamed:kH5link parentElement:root]];
        self.favIcon = [TBXML textForElement:[TBXML childElementNamed:kFavIcon parentElement:root]];
        self.newsType = [[TBXML textForElement:[TBXML childElementNamed:kNewsType parentElement:root]] integerValue];
        self.favour = NO;
        self.openType = openType;
        TBXMLElement *httpHeader = [TBXML childElementNamed:kHttpHeader parentElement:root];
        if (httpHeader) {
            self.logoUrl = [TBXML textForElement:[TBXML childElementNamed:kLogoUrl parentElement:httpHeader]];
            self.linkUrl = [TBXML textForElement:[TBXML childElementNamed:kLinkUrl parentElement:httpHeader]];
        }
        TBXMLElement *media = [TBXML childElementNamed:kMedia parentElement:root];
        if(media)
        {
            self.mediaName = [TBXML textForElement:[TBXML childElementNamed:kMediaName parentElement:media]];
            self.mediaLink = [TBXML textForElement:[TBXML childElementNamed:kMediaLink parentElement:media]];
        }
        self.optimizeRead = [TBXML textForElement:[TBXML childElementNamed:kOptimizeRead parentElement:root]];
        
        NSMutableArray *tagChannelAry = [NSMutableArray array];
        TBXMLElement *tagChannels = [TBXML childElementNamed:kTagChannels parentElement:root];
        if (tagChannels != nil) {
            TBXMLElement *tagChannel = [TBXML childElementNamed:kTagChannel parentElement:tagChannels];
            if (tagChannel) {
                NewsTagChannelItem *tagChannelItem = [[NewsTagChannelItem alloc] init];
                TBXMLElement *tagName = [TBXML childElementNamed:kTagChannelName parentElement:tagChannel];
                TBXMLElement *tagLink = [TBXML childElementNamed:kTagChannelLink parentElement:tagChannel];
                tagChannelItem.name = [TBXML textForElement:tagName];
                tagChannelItem.link = [TBXML textForElement:tagLink];
                [tagChannelAry addObject:tagChannelItem];
                
                while ((tagChannel = [TBXML nextSiblingNamed:kTagChannel searchFromElement:tagChannel]) != nil) {
                    NewsTagChannelItem *tagChannelItem = [[NewsTagChannelItem alloc] init];
                    TBXMLElement *tagName = [TBXML childElementNamed:kTagChannelName parentElement:tagChannel];
                    TBXMLElement *tagLink = [TBXML childElementNamed:kTagChannelLink parentElement:tagChannel];
                    tagChannelItem.name = [TBXML textForElement:tagName];
                    tagChannelItem.link = [TBXML textForElement:tagLink];
                    [tagChannelAry addObject:tagChannelItem];
                }
            }
        }
        self.tagChannelItems = tagChannelAry;
        
        NSMutableArray *stockAry = [NSMutableArray array];
        TBXMLElement *stocks = [TBXML childElementNamed:kStocks parentElement:root];
        if (stocks != nil) {
            TBXMLElement *stock = [TBXML childElementNamed:kStock parentElement:stocks];
            if (stock) {
                NewsStockItem *stockItem = [[NewsStockItem alloc] init];
                TBXMLElement *stockName = [TBXML childElementNamed:kStockName parentElement:stock];
                TBXMLElement *stockLink = [TBXML childElementNamed:kStockLink parentElement:stock];
                stockItem.name = [TBXML textForElement:stockName];
                stockItem.link = [TBXML textForElement:stockLink];
                [stockAry addObject:stockItem];
                
                while ((stock = [TBXML nextSiblingNamed:kStock searchFromElement:stock]) != nil) {
                    NewsStockItem *stockItem = [[NewsStockItem alloc] init];
                    TBXMLElement *stockName = [TBXML childElementNamed:kStockName parentElement:stock];
                    TBXMLElement *stockLink = [TBXML childElementNamed:kStockLink parentElement:stock];
                    stockItem.name = [TBXML textForElement:stockName];
                    stockItem.link = [TBXML textForElement:stockLink];
                    [stockAry addObject:stockItem];
                }
            }
        }
        self.stockItems = stockAry;
        
        NSMutableArray* shareImagesAry    = [NSMutableArray array];
        self.titleForImageDic = [NSMutableDictionary dictionary];
        TBXMLElement *images = [TBXML childElementNamed:kPhotos parentElement:root];
        if (images != nil) {
            TBXMLElement *image = [TBXML childElementNamed:kPhoto parentElement:images];
            if (image) {
                NewsImageItem *shareImageItem   = [[NewsImageItem alloc] init];
                shareImageItem.termId           = self.channelId;
                shareImageItem.newsId           = self.newsId;
                shareImageItem.type             = NEWSSHAREIMAGE_TYPE;
                TBXMLElement *pic = [TBXML childElementNamed:kPic parentElement:image];
                TBXMLElement *abstract = [TBXML childElementNamed:kAbstract parentElement:image];
                TBXMLElement *widthElement = [TBXML childElementNamed:kWidth parentElement:image];
                TBXMLElement *heightElement = [TBXML childElementNamed:kHeight parentElement:image];
                
                shareImageItem.url              = [TBXML textForElement:pic];
                NSString *abstractStr = [TBXML textForElement:abstract];
                if ([abstractStr isMatchedByRegex:@"(%[0-9a-f]{2})+" options:RKLCaseless inRange:NSMakeRange(0, abstractStr.length) error:nil]) {
                    abstractStr = [abstractStr URLDecodedString];
                }
                shareImageItem.title            = abstractStr;
                shareImageItem.width            = [[TBXML textForElement:widthElement] integerValue];
                shareImageItem.height            = [[TBXML textForElement:heightElement] integerValue];
                [shareImagesAry addObject:shareImageItem];
                
                while ((image=[TBXML nextSiblingNamed:kPhoto searchFromElement:image]) != nil) {
                    shareImageItem   = [[NewsImageItem alloc] init];
                    shareImageItem.termId           = self.channelId;
                    shareImageItem.newsId           = self.newsId;
                    shareImageItem.type             = NEWSSHAREIMAGE_TYPE;
                    TBXMLElement *pic = [TBXML childElementNamed:kPic parentElement:image];
                    TBXMLElement *abstract = [TBXML childElementNamed:kAbstract parentElement:image];
                    TBXMLElement *widthElement = [TBXML childElementNamed:kWidth parentElement:image];
                    TBXMLElement *heightElement = [TBXML childElementNamed:kHeight parentElement:image];
                    
                    shareImageItem.url              = [TBXML textForElement:pic];
                    NSString *abstractStr = [TBXML textForElement:abstract];
                    if ([abstractStr isMatchedByRegex:@"(%[0-9a-f]{2})+" options:RKLCaseless inRange:NSMakeRange(0, abstractStr.length) error:nil]) {
                        abstractStr = [abstractStr URLDecodedString];
                    }
                    shareImageItem.title            = abstractStr;
                    shareImageItem.width            = [[TBXML textForElement:widthElement] integerValue];
                    shareImageItem.height            = [[TBXML textForElement:heightElement] integerValue];
                    [shareImagesAry addObject:shareImageItem];
                }
            }
        }
        self.newsImageItems    = shareImagesAry;

        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:5];
        for (NewsImageItem *img in self.newsImageItems) {
            [arr addObject:img.url];
        }
        self.thumbnailImages = [[SNDBManager currentDataBase] getImageUrlFromNewsContent:self.content];

        //audios
        NSArray *audioList = [self parseAudioList:root];
        self.audios = audioList;
        [self replaceAudioContentIfExists];
        
        //videos
        self.videos = [self parseVideoList:root];
        [self replaceVideoContentIfExists];
        
        // adinfo
        self.adInfos = [self parseAdInfoList:root];
        [self replaceAdInfoContentIfExists];
        
        //解析投票
        //<votes>
        TBXMLElement *voteEles = [TBXML childElementNamed:kVotes parentElement:root];
        
        if (voteEles != nil) {
            self.votesInfo = [SNNewsVoteService votesInfoFromXMLElement:voteEles];
        } //<votes>
        
        //SNDebugLog(@"%@", self.votesInfo.voteArray);
        // 解析subInfo
        TBXMLElement *subEles = [TBXML childElementNamed:@"subInfo" parentElement:root];
        if (subEles != nil) {
            self.subId = [TBXML textForElement:[TBXML childElementNamed:@"subId" parentElement:subEles]];
            if (self.subId.length > 0) {
                SCSubscribeObject *subObj = [SCSubscribeObject subscribeObjFromXMLData:subEles];
                subObj.subId = self.subId;
                [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
            }
        }
        
        // 解析shareRead
        TBXMLElement *shareRead = [TBXML childElementNamed:@"shareRead" parentElement:root];
        if (shareRead) {
            SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromXMLObj:shareRead];
            if (obj) [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypeNews contentId:nId];
        }
        
        // 4.0广告 解析定向回传参数 by jojo
        // 先清除之前缓存的广告数据
        [[SNDBManager currentDataBase] adInfoClearAdInfosByType:SNAdInfoTypeArticle dataId:nId categoryId:cId];
        
        TBXMLElement *adInfoControls = [TBXML childElementNamed:@"adControlInfos" parentElement:root];
        if (adInfoControls) {
            NSMutableArray *adInfosArray = [NSMutableArray array];
            TBXMLElement *adInfoElm = [TBXML childElementNamed:@"adControlInfo" parentElement:adInfoControls];
            if (adInfoElm) {
                SNAdControllInfo *adInfoObj = [[SNAdControllInfo alloc] initWithXMLElement:adInfoElm];
                [adInfosArray addObject:adInfoObj];
                
                while (!!(adInfoElm = [TBXML nextSiblingNamed:@"adControlInfo" searchFromElement:adInfoElm])) {
                    SNAdControllInfo *adInfoObj = [[SNAdControllInfo alloc] initWithXMLElement:adInfoElm];
                    [adInfosArray addObject:adInfoObj];
                }
            }
            
            // 缓存本地数据库
            [[SNDBManager currentDataBase] adInfoAddOrUpdateAdInfos:adInfosArray withType:SNAdInfoTypeArticle dataId:nId categoryId:cId];
        }
        
        // 解析opencms管理操作权限节点
        TBXMLElement *operationInfo = [TBXML childElementNamed:@"operationInfo" parentElement:root];
        if (operationInfo) {
            self.action = [TBXML textForElement:[TBXML childElementNamed:@"action" parentElement:operationInfo]];
            self.isPublished = [TBXML textForElement:[TBXML childElementNamed:@"isPublished" parentElement:operationInfo]];
            self.editNewsLink = [TBXML textForElement:[TBXML childElementNamed:@"editNewsLink" parentElement:operationInfo]];
            self.operators = [TBXML textForElement:[TBXML childElementNamed:@"operators" parentElement:operationInfo]];
        }
        
        TBXMLElement *cmtControl = [TBXML childElementNamed:@"comtRel" parentElement:root];
        if (cmtControl) {
            self.comtStatus = [TBXML textForElement:[TBXML childElementNamed:kCmtStatus parentElement:cmtControl]];
            self.comtHint = [TBXML textForElement:[TBXML childElementNamed:kCmtHint parentElement:cmtControl]];
            self.comtRemarkTips = [TBXML textForElement:[TBXML childElementNamed:kCmtRemarkTips parentElement:cmtControl]];
            [SNUtility setCmtRemarkTips:self.comtRemarkTips];
        }
        //SNDebugLog(@"%@", self.content);
		
		TBXMLElement *pre = [TBXML childElementNamed:kPreId parentElement:root];
		TBXMLElement *next = [TBXML childElementNamed:kNextId parentElement:root];
		if (pre) {
			self.preId = [TBXML textForElement:pre];
		}
		if (next) {
			self.nextId = [TBXML textForElement:next];
		}
	}
	return self;
}

- (NSString*)locateNewsContentImgToLocalPath:(NSString*)newsContent termId:(NSString*)tId  newspaperPath:(NSString *)newspaperPath
{
	if ([newsContent length] == 0 || [tId length] == 0) {
		SNDebugLog(@"SNArticle - locateNewsContentImgToLocalPath:Invalid newsContent = %@ or nId = %@",newsContent,tId);
		return newsContent;
	}
	
	NSArray *newsImgList	= [[SNDBManager currentDataBase] getImageUrlFromNewsContent:newsContent];
	
	do {
		//没有本地图片，则直接返回原内容
		if ([newsImgList count] == 0) {
			break;
		}
		
		NSString *newsFolder	= [[SNDBManager currentDataBase] getNewsPaperFolderByTermId:tId];
		if ([newsFolder length] == 0) {
            if (newspaperPath.length > 0) {
                newsFolder = newspaperPath;
            } else {
                break;
            }
		}
		
		NSString *newsContentWithLocalImg	= nil;
		NSFileManager *fm	= [NSFileManager defaultManager];
		for (NSString *imgName in newsImgList) {
			NSString *localImgPath	= [newsFolder stringByAppendingPathComponent:imgName];
			if ([fm fileExistsAtPath:localImgPath]) {
				newsContentWithLocalImg = [newsContent stringByReplacingOccurrencesOfString:imgName
																				 withString:localImgPath];
				newsContent	= newsContentWithLocalImg;
			}
		}
		
		if ([newsContentWithLocalImg length] == 0) {
			break;
		}
		
		SNDebugLog(@"SNArticle - locateNewsContentImgToLocalPath : Succeeded");
		return newsContentWithLocalImg;
		
	} while (NO);
	
	return newsContent;
}

- (void)updateArticleCmtRead
{
    [[SNDBManager currentDataBase] updateNewsCmtReadByChannelId:self.channelId newsId:self.newsId hasRead:self.cmtRead];
}

- (void)updateArticleFavour
{
    self.favour = YES;
    if(self.channelId)
    {
        [[SNDBManager currentDataBase] updateNewsArticleFavourByChannelId:self.channelId newsId:self.newsId];
    }
    if(self.termId)
    {
        [[SNDBManager currentDataBase] updateNewsArticleFavourByTermId:self.termId newsId:self.newsId];
    }
}

- (void)dealloc {
    self.newsId = nil;
    self.channelId = nil;
    self.title = nil;
    self.from = nil;
    self.originFrom = nil;
    self.newsMark = nil;
    self.originTitle = nil;
    self.time = nil;
    self.updateTime = nil;
    self.content = nil;
    self.preId = nil;
    self.nextId = nil;
    self.nextNewsLink = nil;
    self.nextNewsLink2 = nil;
    self.termId = nil;
    self.commentNum = nil;
    self.link = nil;
    self.shareContent = nil;
    self.shareImages = nil;
    self.thumbnailImages = nil;
    self.titleForImageDic = nil;
    self.videos = nil;
    self.audios = nil;
    self.adInfos = nil;
    self.votesInfo = nil;
    self.voteXML = nil;
    self.action = nil;
    self.isPublished = nil;
    self.editNewsLink = nil;
    self.operators = nil;
    self.comtHint = nil;
    self.comtStatus = nil;
    self.comtRemarkTips = nil;
    self.newsImageItems = nil;
    self.logoUrl = nil;
    self.linkUrl = nil;
    self.thirdPartUrl = nil;
    self.h5link = nil;
    self.favIcon = nil;
    self.mediaName = nil;
    self.mediaLink = nil;
    self.optimizeRead = nil;
    self.tagChannelItems = nil;
    self.stockItems = nil;
    self.tvAdInfos = nil;
    self.tvInfos = nil;
    
}

- (BOOL)isValid {
    return ([self.title isKindOfClass:[NSString class]] && self.title.length > 0);
}

- (BOOL)isCMSOperator
{
    NSString *pid = [SNUserManager getPid];
    
    if ([pid isEqualToString:@"-1"]) {
        return NO;
    }
    
    //类似这样的数组：[5782679059297210390]，里面是long值
    NSArray *operators = [NSJSONSerialization JSONObjectWithString:_operators
                                                           options:NSJSONReadingMutableContainers
                                                             error:NULL];
    
    if (operators && operators.count > 0) {
        for (id op in operators) {
            NSString *o = [NSString stringWithFormat:@"%@", op];
            if ([pid isEqualToString:o]) {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (NSString *)newsContentForJsKitStorageWithNewsId:(NSString *)nId {
    NSString *methodStr = [NSString stringWithFormat:@"article%@", nId];
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    id jsonData = [jsKitStorage getItem:methodStr];
    if (jsonData &&
        [jsonData isKindOfClass:[NSDictionary class]]) {
        NSString *content = [jsonData objectForKey:@"content"];
        return content;
    }
    return nil;
}


@end
