//
//  SNRollingNews.m
//  sohunews
//
//  Created by Dan on 2/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNRollingNews.h"

#import "NSObject+YAJL.h"
#import "NSDictionaryExtend.h"
#import "SNNewsAd+analytics.h"
#import "SNStatisticsManager.h"
#import "SNAdStatisticsManager.h"
#import "SNRollingNewsModel.h"
#import "SNRedPacketManager.h"
#import "SNHotWordModel.h"
#import "SNRollingNewsPublicManager.h"
#import "TMCache.h"

#define kFinance                            (@"finance")
#define kFinanceCursor                      (@"curCursor")
#define kFinanceUnreadMsg                   (@"unreadMsg")
#define kLottery                            (@"lottery")
#define kCommon                             (@"common")
#define kVideo                              (@"video")
#define kAdvertiser                         (@"advertiser")

#define kColumnId                           (@"columnId")
#define kColumnName                         (@"columnName")
#define kDuration                           (@"duration")
#define kLink2                              (@"link2")
#define kSiteName                           (@"siteName")
#define kSiteId                             (@"siteId")

#define kAppId                              (@"appId")
#define kUrlScheme                          (@"urlScheme")
#define kAppName                            (@"appName")
#define kAppDesc                            (@"appDesc")
#define kAppPics                            (@"pics")
#define kDownloadLink                       (@"downloadLink")

#define kSubnum                             (@"subnum")

#define kAdId                               (@"adid")
#define kSpecial                            (@"special")
#define kDict                               (@"dict")
#define kPicture                            (@"picture")
#define kFile                               (@"file")
#define kText                               (@"text")
#define kClick                              (@"click")
#define kSummary                            (@"summary")
#define kAppLink                            (@"ios_link")
#define kAdResourceMizozhen                 (@"miaozhen_imp")
#define kAdResourceMizozhenClick            (@"miaozhen_click_imp")
#define kAdResourceAdmaster                 (@"admaster_imp")
#define kAdResourceAdmasterClick            (@"admaster_click_imp")
#define kAdResourceNormalImp                (@"imp")
#define kAdResourceTrackingImp              (@"tracking_imp")
#define kAdResourceTrackingImpEnd           (@"tracking_imp_end")
#define kAdResourceTrackingImpBreakpoint    (@"tracking_imp_breakpoint")
#define kAdResourceClickImp                 (@"click_imp")
#define kAdViewMonitor                      (@"viewmonitor")
#define kAdClickMonitor                     (@"clickmonitor")
#define kSource                             (@"source")
#define kAdStyle                            (@"adstyle")
#define kAdPredownload                      (@"predownload")

#define kLeftPicture                        (@"leftpicture")
#define kMiddlePicture                      (@"middlepicture")
#define kRightPicture                       (@"rightpicture")

#define kPhone                              (@"phone")
#define kAdTelImp                           (@"tel_imp")

#define kIndex                              (@"index")
#define kColour                             (@"colour")
#define kDiff                               (@"diff")
#define kPrice                              (@"price")
#define kRate                               (@"rate")
#define kShortTitle                         (@"shortTitle")

#define kJokentime                          (@"ntime")
#define kJokecity                           (@"city")
#define kJokeauthorimg                      (@"authorimg")
#define kJokegen                            (@"gen")
#define kJokectime                          (@"ctime")
#define kJokepassport                       (@"passport")
#define kJokeauthor                         (@"author")
#define kJokecommentId                      (@"commentId")
#define kJokecontent                        (@"content")
#define kJokepid                            (@"pid")
#define kJokehotComment                     (@"hotComment")
#define kJokehotCount                       (@"hotCount")

#define kHostIcon                           (@"hostIcon")
#define kHostTeam                           (@"hostTeam")
#define kHostTotal                          (@"hostTotal")
#define kVisitorIcon                        (@"visitorIcon")
#define kVisitorTeam                        (@"visitorTeam")
#define kVisitorTotal                       (@"visitorTotal")
#define kBgPic                              (@"bgPic")

#define kNamingData                         (@"namingdata")
#define kDefaultOpenNum                     (@"defaultOpenNum")
#define kOpenNum                            (@"openNum")

#define kMorePage                           (@"morePage")

#define kAutoPlay                           (@"autoPlay")

#define kData                               (@"data")
#define kAdcode                             (@"adcode")
#define kError                              (@"error")

#define kLiveCnt                            (@"liveCnt")
#define kNickName                           (@"nickName")
#define kShowTime                           (@"showTime")
#define kLiveStatus                         (@"liveStatus")

#define kFeedContent                            (@"content")
#define kFeedId                                 (@"feedId")
#define kFeedCreateTime                         (@"createTime")
#define kFeedCoverPic                           (@"coverPic")
#define kFeedRepostsCount                       (@"repostsCount")
#define kFeedType                               (@"feedType")
#define kFeedCoverPic                           (@"coverPic")
#define kFeedUserId                             (@"userId")
#define kFeedUserName                           (@"userName")
#define kFeedAvatarUrl                          (@"avatar")
#define kFeedCommentCount                       (@"commentCount")
#define kFeedOpenFlag                           (@"openFlag")

@implementation SNNewsIndividuationInfo

@synthesize idString;
@synthesize pic;
@synthesize link;

- (id)initWithDic:(NSDictionary *) dicInfo
{
    self = [super init];
    if (self) {
        self.idString = [dicInfo stringValueForKey:kId defaultValue:@""];
        self.pic = [dicInfo objectForKey:kPic];
        self.link = [dicInfo objectForKey:kLink];
    }
    return self;
}

- (void)dealloc
{
     //(idString);
     //(pic);
     //(link);
}

@end

@implementation SNNewsIndividuationNameInfo

- (id)initWithDic:(NSDictionary *) dicInfo
{
    self = [super init];
    if (self) {
        if (dicInfo) {
            self.idString = [dicInfo stringValueForKey:kId defaultValue:@""];
            self.pic = [dicInfo objectForKey:kPic];
            self.link = [dicInfo objectForKey:kLink];
            self.desc = [dicInfo objectForKey:kTitle];
        }
    }
    return self;
}

- (void)dealloc
{
}

@end


@implementation SNNewsIndividuation

- (id)initWithIndividuationDic:(NSDictionary *) dic
{
    self = [super init];
    if (self) {
        self.individuationArray = [[NSMutableArray alloc] init];
        NSArray *individuationInfo = [dic objectForKey:kData];
        NSDictionary *nameDic = [dic objectForKey:kNamingData];
        if ([individuationInfo isKindOfClass:[NSArray class]]) {
            for (NSDictionary *individuationDic in individuationInfo) {
                SNNewsIndividuationInfo *newsIndividuation = [[SNNewsIndividuationInfo alloc] initWithDic:individuationDic];
                [_individuationArray addObject:newsIndividuation];
            }
        }
        _nameInfo = [[SNNewsIndividuationNameInfo alloc] initWithDic:nameDic];
    }
    return self;
}

@end


//应用
@implementation SNNewsApp

@synthesize appId;
@synthesize urlScheme;
@synthesize appName;
@synthesize appDesc;
@synthesize appIcon;
@synthesize downloadLink;

- (id)initAppWithDic:(NSDictionary *) dicInfo
{
    self = [super init];
    if (self) {
        self.appId = [dicInfo stringValueForKey:kAppId defaultValue:@""];
        self.urlScheme = [dicInfo stringValueForKey:kUrlScheme defaultValue:nil];
        self.appName = [dicInfo stringValueForKey:kAppName defaultValue:nil];
        self.appDesc = [dicInfo stringValueForKey:kAppDesc defaultValue:nil];
        self.downloadLink = [dicInfo stringValueForKey:kDownloadLink defaultValue:nil];
        NSArray *pics = [dicInfo arrayValueForKey:kAppPics defaultValue:nil];
        if (pics.count > 0) {
            self.appIcon = pics[0];
        }
        self.adID = [dicInfo stringValueForKey:@"id" defaultValue:@""];
    }
    return self;
}

- (void)dealloc
{
     //(_adID);
     //(appId);
     //(urlScheme);
     //(appName);
     //(appDesc);
     //(appIcon);
     //(downloadLink);
}

@end

//视频
@implementation SNNewsVideoInfo

@synthesize idString;
@synthesize columnId;
@synthesize columnName;
@synthesize duration;
@synthesize link;
@synthesize pic;
@synthesize siteName;
@synthesize title;
@synthesize vId;
@synthesize siteId;

- (id)initVideoWithDic:(NSDictionary *) dicInfo
{
    self = [super init];
    if (self) {
        self.idString = [dicInfo stringValueForKey:kId defaultValue:@""];
        self.columnId = [dicInfo stringValueForKey:kColumnId defaultValue:@""];
        self.columnName = [dicInfo objectForKey:kColumnName];
        self.duration = [dicInfo stringValueForKey:kDuration defaultValue:@""];
        //self.link = [dicInfo objectForKey:kLink2];
        //self.pic = [dicInfo objectForKey:kPic];
        self.siteName = [dicInfo stringValueForKey:kSiteName defaultValue:@""];
        //self.title = [dicInfo objectForKey:kTitle];
        self.vId = [dicInfo stringValueForKey:kVid defaultValue:@""];
        self.siteId = [dicInfo stringValueForKey:kSiteId defaultValue:@""];
        //lijian 2015.1.1 增加视频广告
        NSDictionary *specialDic = [[dicInfo objectForKey:kSpecial] objectForKey:kDict];
        if(nil == specialDic){
            return self;
        }
        
        NSString *resTemp = nil;
        
        //picture = resource;
        resTemp = [specialDic stringValueForKey:kPicture defaultValue:@""];
        if(nil != resTemp && ![resTemp isEqualToString:@""]){
            //adcode
            NSDictionary *resDic = [dicInfo objectForKey:resTemp];
            self.pic = [resDic stringValueForKey:kAdcode defaultValue:@""];
        }
        
        //title = resource1;
        resTemp = [specialDic stringValueForKey:kTitle defaultValue:@""];
        if(nil != resTemp && ![resTemp isEqualToString:@""]){
            //adcode
            NSDictionary *resDic = [dicInfo objectForKey:resTemp];
            self.title = [resDic stringValueForKey:kText defaultValue:@""];
        }
        
        //video = resource2;
        resTemp = [specialDic stringValueForKey:kVideo defaultValue:@""];
        if(nil != resTemp && ![resTemp isEqualToString:@""]){
            //adcode
            NSDictionary *resDic = [dicInfo objectForKey:resTemp];
            self.link = [resDic stringValueForKey:kFile defaultValue:@""];
        }
    }
    return self;
}

- (void)dealloc
{
     //(idString);
     //(columnId);
     //(columnName);
     //(duration);
     //(link);
     //(pic);
     //(siteName);
     //(title);
     //(vId);
     //(siteId);
}

@end


@implementation SNNewsAd

@synthesize adId;
@synthesize title;
@synthesize picUrl;
@synthesize viewMonitor;
@synthesize clickMonitor;
@synthesize appLink;
@synthesize h5Link;
@synthesize advertiser;

- (void)dealloc
{
     //(advertiser);
     //(adId);
     //(title);
     //(picUrl);
     //(_picUrls);
     //(_newsDataDic);
     //(_channelId);
     //(_adpType);
     //(viewMonitor);
     //(clickMonitor);
     //(appLink);
     //(h5Link);
     //(_admaster_click_imp);
     //(_admaster_imp);
     //(_imp);
     //(_miaozhen_click_imp);
     //(_miaozhen_imp);
     //(_tracking_imp);
     //(_tracking_imp_end);
     //(_tracking_imp_Breakpoint);
    
}

@end

@implementation SNNewsLottery
@synthesize title;
@synthesize description;
@synthesize pic;
@synthesize link;
@synthesize idString;

- (id)initLotteryWithDic:(NSDictionary *) dicInfo
{
    self = [super init];
    if (self) {
        self.title = [dicInfo objectForKey:kTitle];
        self.description = [dicInfo objectForKey:kDesc];
        self.pic = [dicInfo objectForKey:kPic];
        self.link = [dicInfo objectForKey:kLink];
        self.idString = [dicInfo stringValueForKey:kId defaultValue:@""];
    }
    return self;
}

- (void)dealloc
{
     //(title);
     //(description);
     //(pic);
     //(link);
     //(idString);
}

@end



@implementation SNNewsFinance
@synthesize colour;
@synthesize name;
@synthesize rate;
@synthesize diff;
@synthesize price;
@synthesize link;
@synthesize idString;
@synthesize shortTitle;

- (id)initFinaceWithDic:(NSDictionary *) dicInfo
{
    self = [super init];
    if (self) {
        self.colour = [dicInfo objectForKey:kColour];
        self.diff = [dicInfo objectForKey:kDiff];
        self.name = [dicInfo objectForKey:kName];
        self.price = [dicInfo objectForKey:kPrice];
        self.rate = [dicInfo objectForKey:kRate];
        self.link = [dicInfo objectForKey:kUrl];
        self.idString = [dicInfo stringValueForKey:kId defaultValue:@""];
        self.shortTitle = [dicInfo stringValueForKey:kShortTitle defaultValue:@""];
    }
    return self;
}

- (void)dealloc
{
     //(colour);
     //(name);
     //(rate);
     //(diff);
     //(price);
     //(link);
     //(idString);
}

@end

@implementation SNNewsFunnyText
@synthesize content;
@synthesize imgUrl;
@synthesize hotcomment_ntime;
@synthesize hotcomment_city;
@synthesize hotcomment_authorImg;
@synthesize hotcomment_gen;
@synthesize hotcomment_ctime;
@synthesize hotcomment_passport;
@synthesize hotcomment_commentId;
@synthesize hotcomment_author;
@synthesize hotcomment_content;
@synthesize hotcomment_pid;
@synthesize hotCount;

- (id)initFunnyTextWithDic:(NSDictionary *) dicInfo
{
    self = [super init];
    if (self) {
        self.content = [dicInfo objectForKey:kJokecontent];
        NSNumber* hotCountNum = [dicInfo objectForKey:kJokehotCount];
        if ([hotCountNum integerValue] >= 10000) {
            self.hotCount = [NSString stringWithFormat:@"%.1f万",[hotCountNum integerValue]/10000.f];
        }else{
            self.hotCount = [hotCountNum stringValue];
        }
//        self.imgUrl = [dicInfo objectForKey:kDiff];
        NSArray * hotCommentDicArr = [dicInfo objectForKey:kJokehotComment];
        if (hotCommentDicArr.count > 0) {
            id hotCommentDic = [hotCommentDicArr firstObject];
            if ([hotCommentDic isKindOfClass:[NSDictionary class]]) {
                self.hotcomment_ntime       = [hotCommentDic stringValueForKey:kJokentime       defaultValue:@""];
                self.hotcomment_city        = [hotCommentDic stringValueForKey:kJokecity        defaultValue:@""];
                self.hotcomment_authorImg   = [hotCommentDic stringValueForKey:kJokeauthorimg   defaultValue:@""];
                self.hotcomment_gen         = [hotCommentDic stringValueForKey:kJokegen         defaultValue:@""];
                self.hotcomment_ctime       = [hotCommentDic stringValueForKey:kJokectime       defaultValue:@""];
                self.hotcomment_passport    = [hotCommentDic stringValueForKey:kJokepassport    defaultValue:@""];
                self.hotcomment_author      = [hotCommentDic stringValueForKey:kJokeauthor      defaultValue:@""];
                self.hotcomment_commentId   = [hotCommentDic stringValueForKey:kJokecommentId   defaultValue:@""];
                self.hotcomment_content     = [hotCommentDic stringValueForKey:kJokecontent     defaultValue:@""];
                self.hotcomment_pid         = [hotCommentDic stringValueForKey:kJokepid         defaultValue:@""];
            }
            
        }
        
    }
    return self;
}

+ (SNNewsFunnyText *)initWithFavorateInfoString:(NSString *)infoString {
    SNNewsFunnyText * funnyText = [[SNNewsFunnyText alloc] init];
    NSArray * tempStringArray = [infoString componentsSeparatedByString:@"\",\""];
    if (tempStringArray.count > 0) {
        for (NSString * tmpString in tempStringArray) {
            @autoreleasepool {
                if ([tmpString containsString:@"content\":\""]) {
                    funnyText.hotcomment_content = [[tmpString componentsSeparatedByString:@"\":\""] lastObject];
                }
                else if ([tmpString containsString:@"author\":\""]) {
                    funnyText.hotcomment_author = [[tmpString componentsSeparatedByString:@"\":\""] lastObject];
                }
                else if ([tmpString containsString:@"commentId\":\""]) {
                    funnyText.hotcomment_commentId = [[tmpString componentsSeparatedByString:@"\":\""] lastObject];
                }
            }
        }
    }
    
    return  funnyText;
}

- (void)dealloc
{
     //(content);
     //(imgUrl);
     //(hotcomment_ntime);
     //(hotcomment_city);
     //(hotcomment_gen);
     //(hotcomment_pid);
     //(hotcomment_commentId);
     //(hotcomment_ctime);
     //(hotcomment_author);
     //(hotcomment_content);
     //(hotcomment_passport);
     //(hotcomment_authorImg);
}

@end

@implementation SNBook


@end

@implementation SNBookLabel


@end

@implementation SNNewsMatch
@synthesize hostIcon;
@synthesize hostTeam;
@synthesize hostTotal;
@synthesize visitorIcon;
@synthesize visitorTeam;
@synthesize visitorTotal;

- (id)initMatchWithDic:(NSDictionary *) dicInfo
{
    self = [super init];
    if (self) {
        self.hostIcon = [dicInfo objectForKey:kHostIcon];
        self.hostTeam = [dicInfo objectForKey:kHostTeam];
        self.hostTotal = [dicInfo stringValueForKey:kHostTotal defaultValue:@"0"];
        self.visitorIcon = [dicInfo objectForKey:kVisitorIcon];
        self.visitorTeam = [dicInfo objectForKey:kVisitorTeam];
        self.visitorTotal = [dicInfo stringValueForKey:kVisitorTotal defaultValue:@"0"];
    }
    return self;
}

- (void)dealloc
{
     //(hostIcon);
     //(hostTeam);
     //(hostTotal);
     //(visitorIcon);
     //(visitorTeam);
     //(visitorTotal);
}

@end


@implementation SNNewsSponsorships

@synthesize title;
@synthesize adId;
@synthesize adType;
@synthesize gbcode;
@synthesize position;

- (id)initSponsorshipsWithDic:(NSDictionary *) dicInfo
{
    self = [super init];
    if (self) {
        self.adType = [dicInfo stringValueForKey:kAdType defaultValue:@""];
        self.gbcode = [dicInfo objectForKey:kGbcode];
        self.position = [dicInfo stringValueForKey:kPosition defaultValue:@""];
        self.abposition = [dicInfo stringValueForKey:kAdAbPosition defaultValue:@""];
        self.lc = [dicInfo stringValueForKey:kAdLoadMoreCount defaultValue:@""];
        self.rc = [dicInfo stringValueForKey:kAdRefreshCount defaultValue:@""];
        self.scope = [dicInfo stringValueForKey:kAdScope defaultValue:@""];
        self.newschn = [dicInfo stringValueForKey:kAdNewsChannel defaultValue:@""];
        self.adpType = [dicInfo stringValueForKey:kAdNewsAdpType defaultValue:nil];
        self.appchn = [dicInfo stringValueForKey:kAdAppChannel defaultValue:@""];
        self.reportDisplay = NO;
        [self initAdDataWithDic:dicInfo];
    }
    return self;
}

- (void)initAdDataWithDic:(NSDictionary *) dic
{
    NSDictionary *adDic = [dic objectForKey:kData];
    if (adDic) {
        self.adId = [adDic stringValueForKey:kAdId defaultValue:@""];
        self.itemspaceid = [adDic stringValueForKey:kAdItemSpaceId defaultValue:@""];
        self.impId = [adDic stringValueForKey:kAdImpressionId defaultValue:@""];
        self.monitorkey = [adDic stringValueForKey:kAdMonitorKey defaultValue:@""];
        self.clickMonitor = [adDic stringValueForKey:kAdClickMonitor defaultValue:@""];
        self.viewMonitor = [adDic stringValueForKey:kAdViewMonitor defaultValue:@""];
        
        NSDictionary *specialDic = [adDic objectForKey:kSpecial];
        if (specialDic) {
            NSDictionary *dic = [specialDic objectForKey:kDict];
            if (dic) {
                NSString *titleKey = [dic objectForKey:kTitle];
                if (titleKey.length >0) {
                    NSDictionary *titleDic = [adDic objectForKey:titleKey];
                    if (titleDic) {
                        self.title = [titleDic objectForKey:kText];
                        self.miaozhen_imp = [titleDic arrayValueForKey:kAdResourceMizozhen defaultValue:nil];
                        self.admaster_imp = [titleDic arrayValueForKey:kAdResourceAdmaster defaultValue:nil];
                        self.click_imp = [titleDic arrayValueForKey:kAdResourceClickImp defaultValue:nil];
                        self.normal_imp = [titleDic arrayValueForKey:kAdResourceNormalImp defaultValue:nil];
                    }
                }
            }
        }
    }
}

- (void)reportSponsorShipOneDisplay:(SNRollingNews *)news {
    //空广告返回
    if ([self.adType isEqualToString:@"2"]) {
        return;
    }
    //不是当前频道返回
    if (![news.channelId isEqualToString:[[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif]]) {
        return;
    }
    //曝光统计虑重
    if (self.reportDisplay) {
        return;
    }
    
    SNStatExposureInfo *info = [[SNStatExposureInfo alloc] init];
    info.objLabel = news.isRecomNews ? SNStatInfoUseTypeRecommed : SNStatInfoUseTypeTimelineAd;
    [self updateInfoWithData:info data:news];
    info.isReported = [news isReportAd:AdReportStateDisplay];
    
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
    
    self.reportDisplay = YES;
    
    news.adReportState = AdReportStateDisplay;
}

- (void)reportSponsorShipLoad:(SNRollingNews *)news {
    SNStatLoadInfo *info = [[SNStatLoadInfo alloc] init];
    info.objLabel = news.isRecomNews ? SNStatInfoUseTypeRecommed : SNStatInfoUseTypeTimelineAd;
    [self updateInfoWithData:info data:news];
    info.isReported = [news isReportAd:AdReportStateLoad];
    
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
    
    SNDebugLog(@"SNRollingNews reportSponsorShipLoad adInfo %@" , info.loadMoreCount);
    
    // 第三方展示曝光
    [self.admaster_imp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [[SNADManager sharedSTADManager] stadAdTrack:obj andTrackType:kSTADAdTrackTypeAdmaster];
        }
    }];
    
    [self.miaozhen_imp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [[SNADManager sharedSTADManager] stadAdTrack:obj andTrackType:kSTADAdTrackTypeMiaozhen];
        }
    }];
    
    [self.normal_imp enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [[SNADManager sharedSTADManager] stadAdTrack:obj andTrackType:kSTADAdTrackTypeNormal];
        }
    }];
    
    news.adReportState = AdReportStateLoad;
}

- (void)reportSponsorShipEmpty:(SNRollingNews *)news {
    SNStatEmptyInfo *info = [[SNStatEmptyInfo alloc] init];
    info.objLabel = news.isRecomNews ? SNStatInfoUseTypeEmptyRecommed : SNStatInfoUseTypeEmptyTimelineAd;
    [self updateInfoWithData:info data:news];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
}

- (void)updateInfoWithData:(SNStatInfo *)info data:(SNRollingNews *)news
{
    NSString *newsID = self.adId;
    if (newsID.length > 0) {
        info.adIDArray = @[newsID];
    }
    
    info.token = news.token;
    info.objType = self.itemspaceid;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
//    info.newsId = news.newsId;//为什么没有newsId呢 加上 //不知道到底要不要newsid
    
    // 为什么是news.newsAd.channelId，而不是news.channelId呢？ 不知道，可能有深意，在此打个补丁
    if ([@"12790" isEqualToString:news.newsAd.itemSpaceId] || [@"12433" isEqualToString:news.newsAd.itemSpaceId] || [@"12837" isEqualToString:news.newsAd.itemSpaceId])
    {
        info.objFromId = news.channelId;
    }
    else
    {
        info.objFromId = news.newsAd.channelId;
    }
    
    info.scope = self.scope;
//    info.refreshCount = [SNAnalytics sharedInstance].rc ? : @"1";
    info.refreshCount = self.rc;
    info.loadMoreCount = self.lc;
    info.position = self.position;
    info.reposition = self.position;
    info.abposition = self.abposition;
    info.appChannelId = news.appChannel;
    info.newsChannelId = self.newschn;
    info.itemspaceid = self.itemspaceid;
    info.monitorkey = self.monitorkey;
    info.impId = self.impId;
    info.gbcode = news.newsAd.gbcode;
    info.adpType = self.adpType;
    info.clickMonitor = self.clickMonitor;
    info.viewMonitor = self.viewMonitor;
    info.newsId = news.newsId;
    if ([news.newsType isEqualToString:kNewsTypeLive]) {
        info.roomId = news.newsId;
    }
}


- (void)dealloc
{
     //(title);
     //(adId);
     //(adType);
     //(gbcode);
     //(position);
     //(_abposition);
     //(_lc);
     //(_rc);
     //(_scope);
     //(_newschn);
     //(_monitorkey);
     //(_itemspaceid);
     //(_impId);
     //(_adpType);
     //(_miaozhen_imp);
     //(_admaster_imp);
     //(_click_imp);
     //(_normal_imp);
     //(_appchn);
     //(_clickMonitor);
     //(_viewMonitor);
    
}

@end


@implementation SNNewsSohuLive

@synthesize liveCount, nickName, showTime, liveStatus;

- (void)dealloc{
     //(nickName);
     //(showTime);
    
}

- (id)initSohuLiveWithDic:(NSDictionary *)dicInfo{
    self = [super init];
    if (self) {
        self.liveCount = [[dicInfo objectForKey:kLiveCnt defalutObj:@"0"] intValue];
        self.nickName = [dicInfo objectForKey:kNickName defalutObj:@""];
        self.showTime = [dicInfo objectForKey:kShowTime defalutObj:@""];
        self.liveStatus = [[dicInfo objectForKey:kLiveStatus defalutObj:nil] intValue];
    }
    
    return self;
}

@end

@implementation SNNewsSohuFeed

@synthesize feedId, repostsCount, feedType, userId, userName, avatarUrl, commentCnt;
@synthesize openFlag;

- (void)dealloc{
}

- (id)initSohuLiveWithDic:(NSDictionary *)dicInfo{
    self = [super init];
    if (self) {
        self.feedId = [dicInfo stringValueForKey:kFeedId defaultValue:@"0"];
        self.repostsCount = [[dicInfo objectForKey:kFeedRepostsCount defalutObj:@"0"] intValue];
        self.feedType = [[dicInfo objectForKey:kFeedType defalutObj:@"0"] intValue];
        self.userId = [dicInfo objectForKey:kFeedUserId defalutObj:@""];
        self.userName = [dicInfo objectForKey:kFeedUserName defalutObj:@""];
        self.avatarUrl = [dicInfo objectForKey:kFeedAvatarUrl defalutObj:@""];
        self.commentCnt = [[dicInfo objectForKey:kFeedCommentCount defalutObj:@"0"] intValue];
        self.openFlag = [dicInfo stringValueForKey:kFeedOpenFlag defaultValue:@""];
    }
    
    return self;
}

@end

@implementation SNRollingNews

@synthesize channelId, newsId, newsType, time, title, digNum, commentNum, abstract, link, from, isRead, listPicsNumber, timelineIndex, hasVideo, hasVote, updateTime, hasAudio, newsTypeText;
@synthesize recomDay,recomNight;
@synthesize starGrade,subId,needLogin,isSubscribe;
@synthesize isWeather,city,tempHigh,tempLow,weatherIoc,weather,pm25,quality,weak, liveTemperature;
@synthesize isRecom,recomType,liveStatus,local,wind,thirdPartUrl;
@synthesize media,gbcode,localWeather;
@synthesize date,localIoc,fromSub;
@synthesize templateId,templateType;
@synthesize dataString,playTime,liveType;
@synthesize token;
@synthesize leftFinance,rightFinance,entryFinance;
@synthesize match;
@synthesize funnyText;
@synthesize leftLottery,rightLottery;
@synthesize newsAd,video,app,appArray,individuation;
@synthesize isFlash;
@synthesize position;
@synthesize adType;
@synthesize newsInfoArray;
@synthesize morePageNum;
@synthesize showUpdateTips;
@synthesize isHasSponsorships;
@synthesize iconText;
@synthesize sponsorships;
@synthesize cursor;
@synthesize sponsorshipsObject;
@synthesize reportState;
@synthesize picUrl = _picUrl;
@synthesize isTopNews;
@synthesize isLatestNews;
@synthesize newsFocusArray;
@synthesize bgPic, sponsoredIcon, redPacketTitle, redPacketId, couponId;
@synthesize tvPlayTime,tvPlayNum,playVid,tvUrl,sourceName, siteValue, autoPlay;
@synthesize sohuLive, sohuFeed;
@synthesize newsHotWordsArray;
@synthesize recomReasons, recomTime,recomInfo;
@synthesize blueTitle;
@synthesize newsItemArray;
@synthesize trainCardId, trainPos;

- (id)init
{
    self = [super init];
    if (self) {
        _hasStatistics = NO;
        _trainCellContentOffsetX = 0.f;
        _trainCellIndex = 0;
        _isCardsFromFocus = NO;
    }
    return self;
}

- (void)setPicUrl:(NSString *)url
{
    if (url != _picUrl)
    {
        _picUrl = url;
    }
}

- (NSArray *)picUrls
{
    return _picUrls;
}

- (NSString *)picUrl
{
    return _picUrl;
}

- (BOOL)isReportAd:(AdReportState)reportType
{
    return self.reportState >= reportType;
}

- (AdReportState)adReportState
{
    return reportState;
}

- (void)setAdReportState:(AdReportState)adReportState
{
    if (adReportState > reportState) {
        reportState = adReportState;
    }
}

- (BOOL)isRecomNews
{
    BOOL isRecomNews = NO;
    if (self.isRecom.length > 0) {
        isRecomNews = [self.isRecom isEqualToString:@"1"] ? YES : NO;
    }
    
    return isRecomNews;
}

- (BOOL)isAdNews
{
    BOOL isAd = NO;
    int templateValue = [self.templateType intValue];
    switch (templateValue) {
        case 12:
        case 13:
        case 14:
        case 21:
        case 22:
        case 23:
        case 41:
        case 51:
        case 52:
        case 53:
        case 54:
        case 55:
        case 76:
        case 77:
            isAd = YES;
            break;
        default:
            break;
    }
    
    return isAd;
}

//焦点图新闻
- (BOOL)isFocusNews
{
    BOOL isFocusNews = NO;
    if ([self.templateType isEqualToString:@"3"]) {
        isFocusNews = YES;
    }
    return isFocusNews;
}

- (BOOL)isLoadMore
{
    BOOL isLoadMore = NO;
    if ([self.templateType isEqualToString:@"20"]) {
        isLoadMore = YES;
    }
    return isLoadMore;
}

- (BOOL)isMoreFocusNews
{
    BOOL isMoreFocusNews = NO;
    if ([self.templateType isEqualToString:@"28"] || [self.templateType isEqualToString:@"202"]) {
        isMoreFocusNews = YES;
    }
    return isMoreFocusNews;
}

- (BOOL)isGroupPhotoNews{
    BOOL isGroupPhotoNews = NO;
    if ([self.templateType isEqualToString:@"2"]) {
        isGroupPhotoNews = YES;
    }
    return isGroupPhotoNews;
}

- (BOOL)isCouponsNews {
    if ([self.templateType isEqualToString:@"33"] && [self.newsType isEqualToString:@"58"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isRedPacketNews{
    if ([self.templateType isEqualToString:@"31"] && [self.newsType isEqualToString:@"56"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isRedPacketTips{
    if ([self.templateType isEqualToString:@"32"] ) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isSohuLive{
    if ([self.templateType isEqualToString:@"39"] && [self.newsType isEqualToString:@"65"]) {
        return YES;
    }
    
    return NO;
}



- (BOOL)isRecomendHotWrods{
    if ([self.templateType isEqualToString:@"40"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isFullScreenFocusNews{
    return [self.from isEqualToString:kRollingNewsFormFocus];
}

- (BOOL)isFullScreenFocusNewsItem{
    return [self.templateType isEqualToString:kTemplateTypeFullScreenFocus];
}

- (BOOL)isTowTopNews{
    return [self.from isEqualToString:kRollingNewsFormTowTop];
}

- (BOOL)isTrainCardNews{
    return [self.from isEqualToString:kRollingNewsFormTrainCard];
}

- (BOOL)isTrainCardNewsItem{
    return [self.templateType isEqualToString:kTemplateTypeTrainCard];
}

- (BOOL)isRollingTopNews{
    return [self.from isEqualToString:kRollingNewsFormTop] || [self isTopNews];
}

- (BOOL)showNewTopArea{
    return ([self.channelId isEqualToString:@"1"] || [self.channelId isEqualToString:@"13557"]) && [self isRollingTopNews];
}

- (NSString *)commentNum
{
    if ([commentNum intValue] > 0) {
        return commentNum;
    }
    //评论数为-1的表示不可评论，但要显示为0
    else if ([commentNum intValue] == -1) {
        return @"0";
    }
    return nil;
}

// 切换城市 扫一扫 优惠券
- (void)setkFunctionArticlesDataWithDic:(NSDictionary *)newsDic {
    if (newsDic) {
        NSArray * data = [newsDic objectForKey:kData];
        if ([data isKindOfClass:[NSArray class]]) {
            if (!self.newsInfoArray) {
                self.newsInfoArray = [NSMutableArray array];
            }
            [self.newsInfoArray removeAllObjects];
            for (NSDictionary *funArticle in data) {
                [self.newsInfoArray addObject:funArticle];
            }
        }
        
        self.dataString = [newsDic yajl_JSONString];
    }
}

//财经
- (void)setFinanceDataWithDic:(NSDictionary *)newsDic
{
    if (newsDic) {
        NSString *curCursor = [newsDic stringValueForKey:kFinanceCursor defaultValue:@""];
        [[NSUserDefaults standardUserDefaults] setObject:curCursor forKey:kFinanceCursorKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.financeUnreadMsg = [newsDic stringValueForKey:kFinanceUnreadMsg defaultValue:@""];
        NSArray *financeArray = [newsDic objectForKey:kIndex];
        if ([financeArray isKindOfClass:[NSArray class]]) {
            for (int i = 0; i < [financeArray count]; i++) {
                NSDictionary *infoDic = [financeArray objectAtIndex:i];
                if (i == 0) {
                    SNNewsFinance *newFinance = [[SNNewsFinance alloc] initFinaceWithDic:infoDic];
                    self.leftFinance = newFinance;
                }else if (i == 1) {
                    SNNewsFinance *newFinance = [[SNNewsFinance alloc] initFinaceWithDic:infoDic];
                    self.rightFinance = newFinance;
                }else if (i == 2) {
                    SNNewsFinance * entry = [[SNNewsFinance alloc] initFinaceWithDic:infoDic];
                    self.entryFinance = entry;
                }
            }
        }
        self.dataString = [newsDic yajl_JSONString];
        self.time = [newsDic objectForKey:kTime];
        
        //生成唯一newsId
        if ([self.newsId isEqualToString:@"0"]) {
            self.newsId = [SNUtility CreateUUID];
        }
    }
}

//比赛
- (void)setMatchDataWithDic:(NSDictionary *)newsDic
{
    if (newsDic) {
        SNNewsMatch *newsMatch = [[SNNewsMatch alloc] initMatchWithDic:newsDic];
        self.match = newsMatch;
        NSString *bgString = [newsDic objectForKey:kBgPic];
        if (bgString.length > 0) {
            self.picUrl = bgString;
        } else {
            self.picUrl = nil;
        }
        self.dataString = [newsDic yajl_JSONString];
    }
}

//彩票、世界杯通用类型
- (void)setCommonDataWithDic:(NSDictionary *)newsDic
{
    if (newsDic) {
        NSArray *financeArray = [newsDic objectForKey:kCommon];
        if ([financeArray isKindOfClass:[NSArray class]]) {
            for (int i = 0; i < [financeArray count]; i++) {
                NSDictionary *infoDic = [financeArray objectAtIndex:i];
                if (i == 0) {
                    SNNewsLottery *newLottery = [[SNNewsLottery alloc] initLotteryWithDic:infoDic];
                    self.leftLottery = newLottery;
                }else if (i == 1) {
                    SNNewsLottery *newLottery = [[SNNewsLottery alloc] initLotteryWithDic:infoDic];
                    self.rightLottery = newLottery;
                }
            }
        }
        //生成唯一newsId
        if ([self.newsId isEqualToString:@"0"]) {
            self.newsId = [SNUtility CreateUUID];
        }
        self.dataString = [newsDic yajl_JSONString];
    }
}

- (void)setJokeNewsDataDic:(NSDictionary *)newsDic {
    if (newsDic) {
        
        SNNewsFunnyText * jokeNews = [[SNNewsFunnyText alloc] initFunnyTextWithDic:newsDic];
        self.funnyText = jokeNews;
        
        //生成唯一newsId
        if ([self.newsId isEqualToString:@"0"]) {
            self.newsId = [SNUtility CreateUUID];
        }
        self.dataString = [newsDic yajl_JSONString];
    }
}

- (void)setNewsVideoDataDic:(NSDictionary *)newsDic{
    if (newsDic) {
        SNNewsVideoInfo *newsVideo = [[SNNewsVideoInfo alloc] initVideoWithDic:newsDic];
        self.video = newsVideo;
        self.video.link = [newsDic objectForKey:@"tvUrl"];
        
        /**
         * 如果视频信息里poster(pic)有值则让cell的图片显示poster图;
         * 如果视频信息里poster(pic)空则cell里还是显示news基本信息里picUrl对应的图
         */
        if (newsVideo.pic.length > 0) {
            self.picUrl = newsVideo.pic;
            self.title = newsVideo.title;
        }
    }

}

//视频
- (void)setVideoDataDic:(NSDictionary *)newsDic
{
    if (newsDic) {
        SNNewsVideoInfo *newsVideo = [[SNNewsVideoInfo alloc] initVideoWithDic:newsDic];
        self.video = newsVideo;
        
        /**
         * 如果视频信息里poster(pic)有值则让cell的图片显示poster图;
         * 如果视频信息里poster(pic)空则cell里还是显示news基本信息里picUrl对应的图
         */
        if (newsVideo.pic.length > 0) {
            self.picUrl = newsVideo.pic;
            self.title = newsVideo.title;
        }
    }
}

//应用
- (void)setAppDataWithDic:(NSDictionary *)newsDic
{
    if (newsDic) {
        SNNewsApp *newsApp = [[SNNewsApp alloc] initAppWithDic:newsDic];
        self.app = newsApp;
        
        self.dataString = [newsDic yajl_JSONString];
    }
}

//批量应用
- (void)setAppArrayDataWithDic:(NSDictionary *)newsDic {
    if (newsDic) {
        self.appArray = [NSMutableArray array];
        NSArray *array = [newsDic arrayValueForKey:kData defaultValue:nil];
        for (NSDictionary *dic in array) {
            if ([dic isKindOfClass:[NSDictionary class]]) {
                SNNewsApp *newsApp = [[SNNewsApp alloc] initAppWithDic:dic];
                if (newsApp.urlScheme.length > 0) {
                    // 只显示未安装的
                    BOOL canOpen = [SNUtility isWhiteListURL:[NSURL URLWithString:newsApp.urlScheme]];
                    if (!canOpen) {
                        [self.appArray addObject:newsApp];
                    }
                } else {
                    [self.appArray addObject:newsApp];
                }
                
                // 最多4个
                if (self.appArray.count >= 4) {
                    break;
                }
            }
        }
        //
        //        if (self.appArray.count == 0) {
        //            self.appArray = nil;
        //        }
        
        self.dataString = [newsDic yajl_JSONString];
    }
}

//个性化模版
- (void)setIndividuationDataWithDic:(NSDictionary *)newsDic
{
    if (newsDic) {
        individuation = [[SNNewsIndividuation alloc] initWithIndividuationDic:newsDic];
        NSArray *newsList = [newsDic objectForKey:kData];
        if (newsList) {
            NSMutableArray *newsGroup = [NSMutableArray array];
            [newsGroup addObjectsFromArray:newsList];
            self.newsInfoArray = newsGroup;
        }
        self.dataString = [newsDic yajl_JSONString];
    }
}

//编辑频道加载更多
- (void)setLoadMoreDateWithDic:(NSDictionary *)newsDic
{
    if (newsDic) {
        self.morePageNum = [newsDic intValueForKey:kMorePage defaultValue:0];
        self.title = [newsDic objectForKey:kTitle];
        self.newsId = [SNUtility CreateUUID];
        self.dataString = [newsDic yajl_JSONString];
    }
}

//广告   查看广告数据结构http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=7471346

/****************************************吐槽时间***********************************************
 (55555555  广告的数据结构谁设计的简直是神啊，就这堆屎一样的数据还要支持模版内容显示，适配我们支持的数据结构会死啊！！！！)
 *********************************************************************************************/

- (void)setAdDataWithDic:(NSDictionary *)newsDataDic {
    @autoreleasepool {
        NSDictionary *newsDic = [newsDataDic objectForKey:kData];
        
        if (newsDic) {
            SNNewsAd *adObject = [[SNNewsAd alloc] init];
            adObject.adId = [newsDic stringValueForKey:kAdId defaultValue:@""];
            adObject.newsDataDic = [NSMutableDictionary dictionaryWithDictionary:newsDataDic];
            adObject.channelId = self.channelId;
            adObject.adpType = [newsDataDic stringValueForKey:kAdNewsAdpType defaultValue:nil];
            
            // add by Cae. 解析5.1的viewmonitor和clickmonitor的上报需求
            adObject.viewMonitor = [newsDic stringValueForKey:kAdViewMonitor defaultValue:@""];
            adObject.clickMonitor = [newsDic stringValueForKey:kAdClickMonitor defaultValue:@""];
            adObject.source = [newsDic stringValueForKey:kSource defaultValue:@""];
            adObject.adStyle = [newsDic stringValueForKey:kAdStyle defaultValue:@""];
            
            NSDictionary *specialDic = [newsDic objectForKey:kSpecial];
            if (specialDic) {
                NSDictionary *dic = [specialDic objectForKey:kDict];
                if (dic) {
                    NSString *pictureKey = [dic objectForKey:kPicture];
                    NSString *titleKey = [dic objectForKey:kTitle];
                    NSString *summaryKey = [dic objectForKey:kSummary];
                    NSString *appLinkKey = [dic objectForKey:kAppLink];
                    NSString *videoKey = [dic objectForKey:kVideo] ? : @"";
                    NSString *advertiserKey = [dic objectForKey:kAdvertiser] ? : @"";
                    NSString *leftPictureKey = [dic objectForKey:kLeftPicture];
                    NSString *middlePictureKey = [dic objectForKey:kMiddlePicture];
                    NSString *rightPictureKey = [dic objectForKey:kRightPicture];
                    NSString *phoneKey = [dic objectForKey:kPhone];
                    NSString *predownloadKey = [dic objectForKey:kAdPredownload];
                    
                    if (phoneKey.length > 0) {
                        NSDictionary *phoneDic = [newsDic objectForKey:phoneKey];
                        if (phoneDic) {
                            adObject.phone = [phoneDic objectForKey:kText];
                            adObject.tel_imp = [phoneDic objectForKey:kAdTelImp];
                            if (adObject.tel_imp && adObject.tel_imp.count > 0) {
                                self.tel_imp = adObject.tel_imp;
                            }
                        }
                    }
                    
                    NSMutableArray *picUrlArr = [[NSMutableArray alloc] init];
                    if (leftPictureKey.length > 0) {
                        NSDictionary *leftPictureDic = [newsDic objectForKey:leftPictureKey];
                        if (leftPictureDic) {
                            NSString *leftPicUrl = [leftPictureDic objectForKey:kFile];
                            self.link = [leftPictureDic objectForKey:kClick];
                            adObject.h5Link = [leftPictureDic objectForKey:kClick];
                            [picUrlArr addObject:leftPicUrl];
                        }
                    }
                    if (middlePictureKey.length > 0) {
                        NSDictionary *middlePictureDic = [newsDic objectForKey:middlePictureKey];
                        if (middlePictureDic) {
                            NSString *middlePicUrl = [middlePictureDic objectForKey:kFile];
                            [picUrlArr addObject:middlePicUrl];
                        }
                    }
                    if (rightPictureKey.length > 0) {
                        NSDictionary *rightPictureDic = [newsDic objectForKey:rightPictureKey];
                        if (rightPictureDic) {
                            NSString *rightPicUrl = [rightPictureDic objectForKey:kFile];
                            [picUrlArr addObject:rightPicUrl];
                        }
                    }
                    if (picUrlArr.count > 0) {
                        adObject.picUrls = (NSArray *)picUrlArr;
                    }
                    
                    if (advertiserKey.length > 0) {
                        NSDictionary *advertiserDic = [newsDic objectForKey:advertiserKey];
                        if (advertiserDic) {
                            adObject.advertiser = [advertiserDic objectForKey:kText];
                        }
                    }
                    
                    if (pictureKey.length >0) {
                        NSDictionary *pictureDic = [newsDic objectForKey:pictureKey];
                        if (pictureDic) {
                            adObject.picUrl = [pictureDic objectForKey:kFile];
                            self.link = [pictureDic objectForKey:kClick];
                            adObject.h5Link = [pictureDic objectForKey:kClick];
                        }
                    }
                    if (titleKey.length >0) {
                        NSDictionary *titleDic = [newsDic objectForKey:titleKey];
                        if (titleDic) {
                            adObject.title = [titleDic objectForKey:kText];
                            self.link = [titleDic objectForKey:kClick];
                        }
                    }
                    if (summaryKey.length >0) {
                        NSDictionary *summaryDic = [newsDic objectForKey:summaryKey];
                        if (summaryDic) {
                            self.abstract = [summaryDic objectForKey:kText];
                        }
                    }
                    if (appLinkKey.length >0) {
                        NSDictionary *appDic = [newsDic objectForKey:appLinkKey];
                        adObject.appLink = [appDic objectForKey:kText];
                    }
                    if (predownloadKey.length > 0) {
                        NSDictionary *predownloadDic = [newsDic objectForKey:predownloadKey];
                        if (predownloadDic) {
                            adObject.predownload = [predownloadDic objectForKey:kFile];
                        }
                    }
                    if (videoKey.length > 0) {//视频新加的第三方检测 v5.2.3
                        NSDictionary *videoDic = [newsDic objectForKey:videoKey];
                        adObject.admaster_click_imp = [videoDic arrayValueForKey:kAdResourceAdmasterClick defaultValue:nil];
                        adObject.admaster_imp = [videoDic arrayValueForKey:kAdResourceAdmaster defaultValue:nil];
                        adObject.miaozhen_click_imp = [videoDic arrayValueForKey:kAdResourceMizozhenClick defaultValue:nil];
                        adObject.miaozhen_imp = [videoDic arrayValueForKey:kAdResourceMizozhen defaultValue:nil];
                        adObject.imp = [videoDic arrayValueForKey:kAdResourceNormalImp defaultValue:nil];
                        adObject.tracking_imp = [videoDic arrayValueForKey:kAdResourceTrackingImp defaultValue:nil];
                        adObject.tracking_imp_end = [videoDic arrayValueForKey:kAdResourceTrackingImpEnd defaultValue:nil];
                        adObject.tracking_imp_Breakpoint = [videoDic arrayValueForKey:kAdResourceTrackingImpBreakpoint defaultValue:nil];
                    }
                }
            }
            
            if (adObject.title.length > 0) {
                self.title = adObject.title;
            }
            if (adObject.picUrl.length > 0) {
                self.picUrl = adObject.picUrl;
            }
            self.newsAd = adObject;
            
            //创建唯一NewsID,防止存数据库覆盖其它数据
            if ([self.newsId isEqualToString:@"0"]) {
                self.newsId = [SNUtility CreateUUID];
            }
            if ([adObject.newsDataDic isKindOfClass:[NSDictionary class]]) {
                self.dataString = [adObject.newsDataDic translateDictionaryToJsonString];
            } else {
                self.dataString = @"";
            }
        }
    }
}

- (void)setTrainInfoDataDic:(NSDictionary *)newsDic{
    if (newsDic) {
        self.trainPos = [newsDic stringValueForKey:kTrainPos defaultValue:@""];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObject:self.trainPos forKey:kTrainPos];
        
        self.dataString = [dic translateDictionaryToJsonString];
    }
}

- (void)setSohuLiveDataDic:(NSDictionary *)newsDic {
    if (newsDic) {
        
        SNNewsSohuLive * tmpLive = [[SNNewsSohuLive alloc] initSohuLiveWithDic:newsDic];
        self.sohuLive = tmpLive;
        
        self.dataString = [newsDic translateDictionaryToJsonString];
    }
}

- (void)setSohuFeedDataDic:(NSDictionary *)newsDic{
    if (newsDic) {
        self.title = [newsDic stringValueForKey:kFeedContent defaultValue:@""];
        
        if ([[newsDic objectForKey:kFeedCoverPic] isKindOfClass:[NSArray class]]) {
            self.picUrls = [newsDic objectForKey:kFeedCoverPic];
            if ([self.picUrls count]) {
                self.picUrl = [self.picUrls objectAtIndex:0];
            }
        }
        
        SNNewsSohuFeed * tmpFeed = [[SNNewsSohuFeed alloc] initSohuLiveWithDic:newsDic];
        self.sohuFeed = tmpFeed;
        
        self.dataString = [newsDic translateDictionaryToJsonString];
    }
}

- (void)setPGCVoidDataDic:(NSDictionary *)pgcDic{
    if (pgcDic) {
        self.autoPlay = [pgcDic intValueForKey:kAutoPlay defaultValue:0];
        
        self.dataString = [pgcDic translateDictionaryToJsonString];
    }
}

- (BOOL)isSohuFeed{
    return ([self.templateType isEqualToString:@"74"] || [self.templateType isEqualToString:@"75"]) && [self.newsType isEqualToString:@"74"];
}

- (BOOL)isSohuFeedPhotos{
    return (self.sohuFeed && self.sohuFeed.feedType == 14);
}

- (BOOL)isSohuFeedVideo{
    return (self.sohuFeed && self.sohuFeed.feedType == 17);
}

- (BOOL)isSohuFeedLive{
    return (self.sohuFeed && self.sohuFeed.feedType == 18);
}

- (void)setRecomendHotWords:(NSDictionary *)newsDic {
    if (newsDic) {
//        NSArray * data = [newsDic objectForKey:kData];
//        if ([data isKindOfClass:[NSArray class]]) {
//            if (!self.newsInfoArray) {
//                self.newsInfoArray = [NSMutableArray array];
//            }
//            [self.newsInfoArray removeAllObjects];
//            for (NSDictionary *funArticle in data) {
//                [self.newsInfoArray addObject:funArticle];
//            }
//        }
//        
//        self.dataString = [newsDic yajl_JSONString];
        
        if (!self.newsHotWordsArray) {
            self.newsHotWordsArray = [NSMutableArray array];
        }
        [self.newsInfoArray removeAllObjects];
        
        SNHotWordModel *modle1 = [[SNHotWordModel alloc] init];
        modle1.name = @"modle1";
        
        SNHotWordModel *modle2 = [[SNHotWordModel alloc] init];
        modle2.name = @"modle2";
        
        SNHotWordModel *modle3 = [[SNHotWordModel alloc] init];
        modle3.name = @"modle3";
        
        [self.newsHotWordsArray addObject:modle1];
        [self.newsHotWordsArray addObject:modle2];
        [self.newsHotWordsArray addObject:modle3];
        
        [self.newsHotWordsArray addObject:modle3];
        [self.newsHotWordsArray addObject:modle2];
        [self.newsHotWordsArray addObject:modle1];
        
         //(modle1);
         //(modle2);
         //(modle3);
    }
}

//由于4.3版本时间原因，接口的比赛数据未整理到一个统一的比赛节点,以后会跟财经数据类似放到一个节点
- (NSDictionary *)getMatchDataWithDic:(NSDictionary *) newsDic
{
    NSMutableDictionary *matchDic = [NSMutableDictionary dictionary];
    NSString *hostIcon = [newsDic stringValueForKey:kHostIcon defaultValue:@""];
    NSString *hostTeam = [newsDic stringValueForKey:kHostTeam defaultValue:@""];
    NSString *hostTotal = [newsDic stringValueForKey:kHostTotal defaultValue:@""];
    NSString *visitorIcon = [newsDic stringValueForKey:kVisitorIcon defaultValue:@""];
    NSString *visitorTeam = [newsDic stringValueForKey:kVisitorTeam defaultValue:@""];
    NSString *visitorTotal = [newsDic stringValueForKey:kVisitorTotal defaultValue:@""];
    NSString *strBgPic = [newsDic stringValueForKey:kBgPic defaultValue:@""];
    
    [matchDic setObject:hostIcon forKey:kHostIcon];
    [matchDic setObject:hostTeam forKey:kHostTeam];
    [matchDic setObject:hostTotal forKey:kHostTotal];
    [matchDic setObject:visitorIcon forKey:kVisitorIcon];
    [matchDic setObject:visitorTeam forKey:kVisitorTeam];
    [matchDic setObject:visitorTotal forKey:kVisitorTotal];
    [matchDic setObject:strBgPic forKey:kBgPic];
    return matchDic;
}

//把接口返回数据转换成各个模版需要数据
- (void)setDataStringWithDic:(NSDictionary *)newsDic
{
    @autoreleasepool {
        self.dataString = @"";
        if (self.templateType.length >0) {
            int templateValue = [self.templateType intValue];
            switch (templateValue) {
                    
                case 22:
                case 77://视频广告下载
                {
                    [self setAdDataWithDic:newsDic];
                    NSDictionary *videoDic = [newsDic objectForKey:kData];
                    [self setVideoDataDic:videoDic];
                    break;
                }
                case 34: {
                    [self setNewsVideoDataDic:newsDic];
                    break;
                }
                case 35: {
                    [self setJokeNewsDataDic:newsDic];
                    break;
                }
                case 3: {
                    [self setAdDataWithDic:newsDic]; //焦点图空广告
                    break;
                }
                case 25: {
                    [self setAdDataWithDic:newsDic]; //房产频道焦点图空广告
                    break;
                }
                case 7: {
                    NSDictionary *matchDic = [self getMatchDataWithDic:newsDic];
                    [self setMatchDataWithDic:matchDic];
                    break;
                }
                case 8: {
                    NSArray *commonArray = [newsDic objectForKey:kLottery];
                    NSMutableDictionary *commonDic = [NSMutableDictionary dictionary];
                    if (commonArray && [commonArray isKindOfClass:[NSArray class]]) {
                        [commonDic setObject:commonArray forKey:kCommon];
                        [self setCommonDataWithDic:commonDic];
                    }
                    break;
                }
                case 10:
                case 29:
                {
                    NSDictionary *financeDic = [newsDic objectForKey:kFinance];
                    [self setFinanceDataWithDic:financeDic];
                    break;
                }
                case 30://本地频道 切换城市 扫一扫 优惠券
                {
                    [self setkFunctionArticlesDataWithDic:newsDic];
                    break;
                }
                case 11: {
                    NSMutableDictionary *appDic = [NSMutableDictionary dictionary];
                    NSString *appId = [newsDic objectForKey:kAppId];
                    NSString *urlScheme = [newsDic objectForKey:kUrlScheme];
                    NSString *appName = [newsDic objectForKey:kAppName];
                    if (appId) {
                        [appDic setObject:appId forKey:kAppId];
                    }
                    if (urlScheme) {
                        [appDic setObject:urlScheme forKey:kUrlScheme];
                    }
                    if (appName) {
                        [appDic setObject:appName forKey:kAppName];
                    }
                    [self setAppDataWithDic:appDic];
                    break;
                }
                case 12://图文广告
                case 13:
                case 14://大图广告
                case 23:
                case 21:
                case 41://组图广告
                case 51://图文广告下载
                case 52://大图广告下载
                case 53://组图广告下载
                case 54://组图打电话
                case 55://大图打电话
                case 76://本地频道置顶广告
                {
                    [self setAdDataWithDic:newsDic];
                    break;
                }
                case 16: {
                    self.commentNum = [newsDic stringValueForKey:kSubnum defaultValue:@""];
                    break;
                }
                case 17: {
                    NSArray *array = [newsDic objectForKey:kData];
                    NSMutableDictionary *commonDic = [NSMutableDictionary dictionary];
                    if (array && [array isKindOfClass:[NSArray class]]) {
                        [commonDic setObject:array forKey:kData];
                        [self setAppArrayDataWithDic:commonDic];
                    }
                    break;
                }
                case 18: {
                    //专题展开模版已删除
                    break;
                }
                case 19: {
                    NSMutableDictionary *individuationDic = [NSMutableDictionary dictionary];
                    NSArray *individuationArray = [newsDic objectForKey:kData];
                    NSDictionary *namingInfoDic = [newsDic objectForKey:kNamingData];
                    if (individuationArray) {
                        [individuationDic setObject:individuationArray forKey:kData];
                    }
                    if (namingInfoDic) {
                        [individuationDic setObject:namingInfoDic forKey:kNamingData];
                    }
                    [self setIndividuationDataWithDic:individuationDic];
                    break;
                }
                case 20: {
                    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
                    NSString *morePage = [newsDic stringValueForKey:kMorePage defaultValue:nil];
                    NSString *titleString = [newsDic objectForKey:kTitle];
                    if (morePage) {
                        [dataDic setObject:morePage forKey:kMorePage];
                    }
                    if (titleString) {
                        [dataDic setObject:titleString forKey:kTitle];
                    }
                    [self setLoadMoreDateWithDic:dataDic];
                    break;
                }
                    
                case 37://PGC视频特殊字段
                case 38:
                {
                    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
                    NSNumber *autoPlayObj = [newsDic objectForKey:kAutoPlay defalutObj:nil];
                    if (autoPlayObj) {
                        [dataDic setObject:autoPlayObj forKey:kAutoPlay];
                    }
                    else{
                        //默认自动播放
                        [dataDic setObject:[NSNumber numberWithBool:YES] forKey:kAutoPlay];
                    }
        
                    [self setPGCVoidDataDic:dataDic];
                }
                    break;
                    
                case 39://千帆直播
                {
                    [self setSohuLiveDataDic:newsDic];
                }
                    break;
                    
                case 74://sohufeed
                case 75:
                {
                    NSDictionary * dataDic = [newsDic dictionaryValueForKey:kData defalutValue:nil];
                    [self setSohuFeedDataDic:dataDic];
                }
                    break;
                    
                case 40:{//推荐流标签类模版
                    [self setRecomendHotWords:newsDic];
                }
                    break;
                case 138://推荐书籍
                {
                    [self setRecommendBooks:newsDic];
                    break;
                }
                /* 5.9.0之前，书架在小说频道展示，5.9.0之后，就只有一个入口了，所以书架数据不用了 by wangchuanwen update
                 case 139://书架
                {
                    [self setBookShelfData:newsDic fromCache:NO];
                    break;
                }*/
                case 145://书籍运营标签
                {
                    [self setBookLabelData:newsDic];
                    break;
                }
                case 146://书籍运营banner
                {
                    [self setBookBannerData:newsDic];
                    break;
                }
                case 79://火车卡片信息
                case 202:
                {
                    [self setTrainInfoDataDic:newsDic];
                }
                    break;
                default:
                    break;
            }
        }
    }
}

// 冠名信息
- (void)setSponsorshipsWithDic:(NSDictionary *) sponsorshipsDic
{
    //推广不显示冠名
    if ([self isAdNews]) {
        return;
    }
    if (sponsorshipsDic && [sponsorshipsDic isKindOfClass:[NSDictionary class]]) {
        sponsorshipsObject = [[SNNewsSponsorships alloc] initSponsorshipsWithDic:sponsorshipsDic];
        self.sponsorships = [sponsorshipsDic yajl_JSONString];
        self.appChannel = sponsorshipsObject.appchn;
    }
}

//把数据库中保存的json转换成冠名信息
- (void)setSponsorshipsWithJson:(NSString *) jsonString
{
    if (jsonString.length > 0) {
        NSDictionary *sponsorshipsDic = [jsonString yajl_JSON];
        if (sponsorshipsDic && [sponsorshipsDic isKindOfClass:[NSDictionary class]]) {
            [self setSponsorshipsWithDic:sponsorshipsDic];
        }
    }
}

//把数据库中保存的json转换成各个模版需要数据
- (void)setDateStringWithJson:(NSString *) jsonString
{
    @autoreleasepool {
        self.dataString = @"";
        NSDictionary *dataDic = [jsonString yajl_JSON];
        if (dataDic && [dataDic isKindOfClass:[NSDictionary class]]) {
            if (self.templateType.length >0) {
                int templateValue = [self.templateType intValue];
                switch (templateValue) {
                    case 22://视频广告
                    case 77://视频广告下载
                    {
                        [self setAdDataWithDic:dataDic];
                        NSDictionary *videoDic = [dataDic objectForKey:kData];
                        [self setVideoDataDic:videoDic];
                    }
                        break;
                    case 7:
                        [self setMatchDataWithDic:dataDic];
                        break;
                    case 8:
                        [self setCommonDataWithDic:dataDic];
                        break;
                    case 10:
                    case 29:
                        [self setFinanceDataWithDic:dataDic];
                        break;
                    case 11:
                        [self setAppDataWithDic:dataDic];
                        break;
                    case 12://图文广告
                    case 13:
                    case 14://大图广告
                    case 23:
                    case 21:
                    case 41://组图广告
                    case 51://图文广告下载
                    case 52://大图广告下载
                    case 53://组图广告下载
                    case 54://组图打电话
                    case 55://大图打电话
                    case 76://本地频道置顶广告
                        [self setAdDataWithDic:dataDic];
                        break;
                    case 17:
                        [self setAppArrayDataWithDic:dataDic];
                        break;
                    case 19:
                        [self setIndividuationDataWithDic:dataDic];
                        break;
                    case 20:
                        [self setLoadMoreDateWithDic:dataDic];
                        break;
                    case 30:
                        [self setkFunctionArticlesDataWithDic:dataDic];
                        break;
                    case 35:
                        [self setJokeNewsDataDic:dataDic];
                        break;
                    case 37://PGC视频特殊字段
                    case 38:
                        [self setPGCVoidDataDic:dataDic];
                        break;
                    case 39:
                        [self setSohuLiveDataDic:dataDic];
                        break;
                    case 74:
                    case 75:
                        [self setSohuFeedDataDic:dataDic];
                        break;
                    case 138://推荐书籍
                        [self setRecommendBooks:dataDic];
                        break;
                    case 139://书架
                        [self setBookShelfData:dataDic fromCache:YES];
                        break;
                    case 145://书籍运营标签
                        [self setBookLabelData:dataDic];
                        break;
                    case 146://书籍运营banner
                        [self setBookBannerData:dataDic];
                        break;
                    case 79:
                    case 202:
                        [self setTrainInfoDataDic:dataDic];
                        break;
                    default:
                        break;
                }
            }
        }
    }
}

-(void)setRecommendBooks:(NSDictionary *)newsDic {
    if (newsDic) {
        self.dataString = [newsDic yajl_JSONString];
        NSDictionary * bookDic = [newsDic dictionaryValueForKey:@"data" defalutValue:nil];
        
        //这一部分这么写的原因是，推荐流的书籍放在了data结构中，造成数据返回时，必要的数据解析不了，需要从data中取数据
//        self.title = [bookDic stringValueForKey:kTitle defaultValue:@""];//书名
        self.title = [bookDic stringValueForKey:@"recomWords" defaultValue:@""];//推荐语
        if (self.title.length == 0) {
            self.title = [bookDic stringValueForKey:kTitle defaultValue:@""];
        }
        self.commentNum = [bookDic stringValueForKey:kCommentNum defaultValue:@""];
        self.link = [bookDic stringValueForKey:kNewsLink2 defaultValue:@""];
        self.picUrl = [bookDic objectForKey:kListPic];
        self.novelAuthor = [bookDic stringValueForKey:@"author" defaultValue:@""];
        self.novelBookId = [bookDic stringValueForKey:@"bookId" defaultValue:@""];
        self.novelCategory = [bookDic stringValueForKey:@"category" defaultValue:@""];
        self.novelChannelLink = [bookDic objectForKey:@"link"];
        if ([[bookDic objectForKey:kListPics] isKindOfClass:[NSArray class]]) {
            self.picUrls = [bookDic objectForKey:kListPics];
            if ([self.picUrls count]) {
                self.picUrl = [self.picUrls objectAtIndex:0];
            }
        }
    }
}

- (void)setBookShelfData:(NSDictionary *)newsDic fromCache:(BOOL)cache{
    if (cache) {
        NSArray * books = [[TMCache sharedCache] objectForKey:@"com.sohunews.bookshelf"];
        if (books && books.count > 0) {
            if (!self.bookShelf) {
                self.bookShelf = [NSMutableArray arrayWithCapacity:books.count];
            }else{
                [self.bookShelf removeAllObjects];
            }
            for (NSDictionary * bookDic in books) {
                @autoreleasepool {
                    SNBook * book = [SNRollingNews createBookWithDictionary:bookDic];
                    [self.bookShelf addObject:book];
                }
            }
        }
    }else{
        if (newsDic) {
            self.dataString = [newsDic yajl_JSONString];
            NSArray * books = [newsDic arrayValueForKey:@"books" defaultValue:nil];
            if (!self.bookShelf) {
                self.bookShelf = [NSMutableArray arrayWithCapacity:books.count];
            }else{
                [self.bookShelf removeAllObjects];
            }
            for (NSDictionary * bookDic in books) {
                @autoreleasepool {
                    SNBook * book = [SNRollingNews createBookWithDictionary:bookDic];
                    [self.bookShelf addObject:book];
                }
            }
            if (books.count > 0) {
                [[TMCache sharedCache] setObject:books forKey:@"com.sohunews.bookshelf"];
            }
        }
    }
}

+ (SNBook *)createBookWithDictionary:(NSDictionary *)bookDic {
    SNBook * book = [[SNBook alloc] init];
    book.author = [bookDic stringValueForKey:@"author" defaultValue:@""];
    book.bookId = [bookDic stringValueForKey:@"bookId" defaultValue:@""];
    book.category = [bookDic stringValueForKey:@"category" defaultValue:@""];
    book.detailUrl = [bookDic stringValueForKey:@"detailUrl" defaultValue:@""];
    book.readUrl = [bookDic stringValueForKey:@"readUrl" defaultValue:@""];
    book.imageUrl = [bookDic stringValueForKey:@"imageUrl" defaultValue:@""];
    book.title = [bookDic stringValueForKey:@"title" defaultValue:@""];
    book.lastUpdateBook = [bookDic stringValueForKey:@"lastUpdateBook" defaultValue:@""];
    book.showDot = [bookDic intValueForKey:@"showDot" defaultValue:0];
    book.remind = [bookDic intValueForKey:@"remind" defaultValue:0];
    return book;
}

#pragma mark 书籍标签数据处理 wangchuanwen 5.8.9
- (void)setBookLabelData:(NSDictionary *)newsDic
{
    if (newsDic) {
        self.dataString = [newsDic yajl_JSONString];
        NSDictionary *bookLabelDic = [newsDic dictionaryValueForKey:@"data" defalutValue:nil];
        NSArray * bookLabels = [bookLabelDic arrayValueForKey:@"tags" defaultValue:nil];
        if (!self.bookLabelArray) {
            self.bookLabelArray = [NSMutableArray arrayWithCapacity:bookLabels.count];
        }else{
            [self.bookLabelArray removeAllObjects];
        }
        for (NSDictionary * labelDic in bookLabels) {
            @autoreleasepool {
                SNBookLabel * bookLabel = [SNRollingNews createBookLabelWithDictionary:labelDic];
                [self.bookLabelArray addObject:bookLabel];
            }
        }
    }
}

#pragma mark 书籍标签model wangchuanwen 5.8.9
+ (SNBookLabel *)createBookLabelWithDictionary:(NSDictionary *)bookDic {
    SNBookLabel *bookLabel = [[SNBookLabel alloc] init];
    bookLabel.labelId = [bookDic stringValueForKey:@"id" defaultValue:@""];
    bookLabel.name = [bookDic stringValueForKey:@"name" defaultValue:@""];
    bookLabel.type = [bookDic stringValueForKey:@"type" defaultValue:@""];
    bookLabel.readUrl = [bookDic stringValueForKey:@"readUrl" defaultValue:@""];
    return bookLabel;
}

#pragma mark 书籍banner数据处理 wangchuanwen 5.8.9
- (void)setBookBannerData:(NSDictionary *)newsDic
{
    if (newsDic) {
        self.dataString = [newsDic yajl_JSONString];
        NSDictionary *bookBanner = [newsDic dictionaryValueForKey:@"data" defalutValue:nil];
        self.title = [bookBanner stringValueForKey:@"title" defaultValue:@""];
        self.link = [bookBanner stringValueForKey:@"link" defaultValue:@""];
        self.startTime = [bookBanner stringValueForKey:@"startTime" defaultValue:@""];
        self.picUrl = [bookBanner stringValueForKey:@"pic" defaultValue:@""];
        self.endTime = [bookBanner stringValueForKey:@"endTime" defaultValue:@""];
    }
}

- (void)setWeatherInfoWithDic:(NSDictionary *) newsDic
{
    //设置天气信息
    if ([[newsDic objectForKey:kWeatherVO] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *weatherVoDic = [newsDic objectForKey:kWeatherVO];
        //焦点图模式，newsID不需要生成
        if (![self.templateType isEqualToString:@"24"]) {
            self.newsId = [NSString stringWithUUID];
        }
        self.city = [weatherVoDic stringValueForKey:kCity defaultValue:@""];
        self.gbcode = [weatherVoDic stringValueForKey:kGbcode defaultValue:@""];
        if ([[weatherVoDic objectForKey:kWeather] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *weatherDic = [weatherVoDic objectForKey:kWeather];
            self.tempHigh = [weatherDic stringValueForKey:kTempHigh defaultValue:@""];
            self.tempLow = [weatherDic stringValueForKey:kTempLow defaultValue:@""];
            self.weather = [weatherDic stringValueForKey:kWeather defaultValue:@""];
            self.pm25 = [weatherDic stringValueForKey:@"pm25" defaultValue:@""];
            self.quality = [weatherDic stringValueForKey:@"quality" defaultValue:@""];
            self.weatherIoc = [weatherDic stringValueForKey:kWeatherIoc defaultValue:@""];
            self.wind = [weatherDic stringValueForKey:kWind defaultValue:@""];
            self.date = [weatherDic stringValueForKey:kDate defaultValue:@""];
            self.localIoc = [weatherDic stringValueForKey:kLocalIoc defaultValue:@""];
            self.weak = [weatherDic stringValueForKey:kWeak defaultValue:@""];
            self.liveTemperature = [weatherDic stringValueForKey:kLiveTemperature defaultValue:@""];
            
            //焦点图模式，不需要用天气模版的图片 wyy
            if (![self.templateType isEqualToString:@"24"]) {
                self.picUrl = [weatherDic objectForKey:kBackground];
            }
        }
    }else {
        self.city = @"";
        self.tempHigh = @"";
        self.tempLow = @"";
        self.weather = @"";
        self.pm25 = @"";
        self.quality = @"";
        self.weatherIoc = @"";
        self.wind = @"";
        self.gbcode = @"";
        self.date = @"";
        self.localIoc = @"";
    }
}

- (SNRollingNews *)createNews:(NSDictionary *)data from:(NSString *)fromStr
{
    SNRollingNews *news = [[SNRollingNews alloc] init];
    news.channelId = self.channelId;
    news.newsId = [data stringValueForKey:kNewsId defaultValue:@""];
    news.newsType = [data stringValueForKey:kNewsType defaultValue:@""];
    news.time = [data stringValueForKey:kTime defaultValue:@""];
    news.title = [data stringValueForKey:kTitle defaultValue:@""];
    news.digNum = [data stringValueForKey:kDigNum defaultValue:@""];
    news.commentNum = [data stringValueForKey:kCommentNum defaultValue:@""];
    news.abstract = [data stringValueForKey:kDesc defaultValue:@""];
    news.link = [data stringValueForKey:kNewsLink2 defaultValue:@""];
    news.picUrl = [data objectForKey:kListPic];
    news.listPicsNumber = [data stringValueForKey:kListPicsNumber defaultValue:@""];
    news.hasVideo = [data stringValueForKey:kIsHasTV defaultValue:@""];
    news.hasAudio = [data stringValueForKey:kIsHasAudio defaultValue:@""];
    news.hasVote = [data stringValueForKey:kIsHasVote defaultValue:@""];
    news.updateTime = [data stringValueForKey:kUpdateTime defaultValue:@""];
    news.recomDay = [data stringValueForKey:kRecomDay defaultValue:@""];
    news.recomNight = [data stringValueForKey:kRecomNight defaultValue:@""];
    news.media = [data stringValueForKey:kNewsMedia defaultValue:@""];
    news.isWeather = [data stringValueForKey:kIsWeather defaultValue:@""];
    news.isRecom = [data stringValueForKey:kIsRecom defaultValue:@""];
    news.recomType = [data stringValueForKey:kRecomType defaultValue:@""];
    news.liveStatus = [data stringValueForKey:kLiveStatus defaultValue:@""];
    news.local = [data stringValueForKey:kLocal defaultValue:@""];
    news.thirdPartUrl = [data stringValueForKey:kThirdPartUrl defaultValue:@""];
    news.templateId = [data stringValueForKey:kTemplateId defaultValue:@""];
    news.templateType = [data stringValueForKey:kTemplateType defaultValue:@"1"];
    news.playTime = [data stringValueForKey:kPlayTime defaultValue:@""];
    news.liveType = [data stringValueForKey:kLiveType defaultValue:@""];
    news.isFlash = [data stringValueForKey:kIsFlash defaultValue:@"0"];
    news.position = [data stringValueForKey:kPos defaultValue:@""];
    news.from = fromStr;
    news.fromSub = NO;
    news.statsType = [data intValueForKey:kRollingNewsStatsType defaultValue:0];
    news.adType = [data stringValueForKey:kAdType defaultValue:@""];
    news.adAbPosition = [data intValueForKey:kAdAbPosition defaultValue:0];
    news.adPosition = [data intValueForKey:kAdPosition defaultValue:0];
    news.refreshCount = [data intValueForKey:kAdRefreshCount defaultValue:0];
    news.loadMoreCount = [data intValueForKey:kAdLoadMoreCount defaultValue:0];
    news.scope = [data stringValueForKey:kAdScope defaultValue:nil];
    news.appChannel = [data stringValueForKey:kAdAppChannel defaultValue:0];
    news.newsChannel = [data stringValueForKey:kAdNewsChannel defaultValue:0];
    news.isHasSponsorships = [data stringValueForKey:kIsHasSponsorships defaultValue:@""];
    news.iconText = [data objectForKey:kIconText];
    news.newsTypeText = [data objectForKey:kNewsTypeText];
    news.cursor = [data stringValueForKey:kCursor defaultValue:@""];
    news.isPush = NO;
    
    NSString *subIdStr = [data stringValueForKey:kSubId defaultValue:@""];
    if ([subIdStr length] > 0) {
        news.subId = subIdStr;
    }else{
        news.subId = [[news.link componentsSeparatedByString:@"subId="] lastObject];
        news.subId = [[news.link componentsSeparatedByString:@"&"] firstObject];
    }
    
    if ([[data objectForKey:kListPics] isKindOfClass:[NSArray class]]) {
        news.picUrls = [data objectForKey:kListPics];
        if ([news.picUrls count]) {
            news.picUrl = [news.picUrls objectAtIndex:0];
        }
    }
    
    //设置特殊模信息
    [news setDataStringWithDic:data];
    
    //设置冠名信息
    [news setSponsorshipsWithDic:[data objectForKey:kSponsorships]];
    
    //设置天气信息
    [news setWeatherInfoWithDic:data];
    
    //房产焦点图，获取城市信息
    NSDictionary *cityVO = [data objectForKey:kCityVO];
    if (cityVO != nil) {
        news.city = [cityVO stringValueForKey:@"city" defaultValue:@""];
    }
    
    news.recomReasons = [data stringValueForKey:kRecomReasons defaultValue:@""];
    news.recomTime = [data stringValueForKey:kRecomTime defaultValue:@""];
    news.blueTitle = [data stringValueForKey:kBlueTitle defaultValue:@""];
    news.recomInfo = [data stringValueForKey:kRecomInfo defaultValue:@""];
    
    return news;

}

- (void)setNewsFocusItems:(NSArray *) newsItems{
    if (newsItems.count > 0) {
        self.newsFocusArray = [NSMutableArray arrayWithCapacity:newsItems.count];
        for (int i = 0; i < newsItems.count; i++) {
            @autoreleasepool {
                NSDictionary *dataDic = [newsItems objectAtIndex:i];
                SNRollingNews *news = [self createNews:dataDic from:kRollingNewsFormFocus];
                [self.newsFocusArray addObject:news];
            }
        }
    }
}

- (void)setRedPacketNewsItem:(NSDictionary *)newDic{
    self.bgPic = [newDic objectForKey:kBgPic defalutObj:nil];
    self.sponsoredIcon = [newDic objectForKey:kSponsoredIcon defalutObj:@""];
    self.redPacketTitle = [newDic objectForKey:kDescription defalutObj:@""];
    self.redPacketId = [newDic objectForKey:kRedPacketId defalutObj:@""];
    self.abstract = [newDic objectForKey:kRedPacketMsg defalutObj:@""];
    
    [SNRedPacketManager sharedInstance].redPacketItem.redPacketType = [[newDic objectForKey:kRedPacketType defalutObj:[NSNumber numberWithInt:1]] intValue];
    [SNRedPacketManager sharedInstance].redPacketItem.sponsoredIcon = self.sponsoredIcon;
    [SNRedPacketManager sharedInstance].redPacketItem.sponsoredTitle = [newDic objectForKey:kSponsoredName defalutObj:nil];
    [SNRedPacketManager sharedInstance].redPacketItem.moneyValue = [NSString stringWithFormat:@"%@", [newDic objectForKey:kRedPacketMoney defalutObj:@"0"]];
    [SNRedPacketManager sharedInstance].redPacketItem.moneyTitle = self.abstract;
    [SNRedPacketManager sharedInstance].redPacketItem.redPacketInValid = 1;
    [SNRedPacketManager sharedInstance].redPacketItem.redPacketId = self.redPacketId;
    [SNRedPacketManager sharedInstance].redPacketItem.showAnimated = [newDic intValueForKey:kIsSupportPopWindow defaultValue:1];
    [SNRedPacketManager sharedInstance].redPacketItem.delayTime = [newDic doubleValueForKey:kPopTime defaultValue:0]/1000;
    [SNRedPacketManager sharedInstance].redPacketItem.isSlideUnlockRedpacket = [newDic intValueForKey:kIsSlideUnlockRedpacket defaultValue:1];
    [SNRedPacketManager sharedInstance].redPacketItem.slideUnlockRedPacketText = [newDic stringValueForKey:kSlideUnlockRedPacketText defaultValue:@"将小图拖到指定位置解锁"];
    [SNRedPacketManager sharedInstance].redPacketItem.jumpUrl = [newDic objectForKey:@"jumpUrl" defalutObj:@""];
}

- (void)setCouponsNesItem:(NSDictionary *)newsDic {
    if (newsDic) {
        self.bgPic = [newsDic objectForKey:kBgPic defalutObj:nil];
        self.sponsoredIcon = [newsDic objectForKey:kSponsoredIcon defalutObj:@""];
        self.redPacketTitle = [newsDic objectForKey:kRedPacketMsg defalutObj:@""];
        self.couponId = [newsDic objectForKey:kCouponId defalutObj:@""];
        self.abstract = [newsDic objectForKey:kSponsoredName defalutObj:@""];
        self.redPacketId = [newsDic objectForKey:kCouponId defalutObj:@""];
    }
}

#if DEBUG_MODE
- (void)print {
}
#endif

- (BOOL)shouldBeHiddenWith:(BOOL)preload {
    // 批量应用类型新闻，如果推荐的应用全都已经安装了，则不显示本条新闻
    if (self.appArray && self.appArray.count == 0) {
        return YES;
    }
    
    if (!preload) {
        //如果是预加载，则暂时不报，延迟到select该news所在channel时上报 SNRollingNewsTableController.m line 1128
        if ([self.newsType isEqualToString:@"21"] && [self.adType isEqualToString:@"2"]) {
            //空广告上报
            [self.newsAd reportEmptyLoad:self];
            return YES;
        }
    }else if ([self isEmptyAdNews]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isEmptyAdNews{
    if ([self.newsType isEqualToString:@"21"] && [self.adType isEqualToString:@"2"]) {
        return YES;
    }
    return NO;
}

@end
