//
//  SNRollingNewsTableItem.m
//  sohunews
//
//  Created by Dan on 2/10/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNRollingNewsTableItem.h"
#import "SNRollingNews.h"
#import "SNShareConfigs.h"
#import "SNAppConfigManager.h"

#import "SNNovelUtilities.h"//5.9.4 wangchuanwen add

@implementation SNRollingNewsTableItem

@synthesize newsModel = _newsModel ,news, type,controller;
@synthesize newsList,photoList,specailList,liveList;
@synthesize allList;
@synthesize dataSource;
@synthesize isFocus = _isFocus;
@synthesize isRecommend = _isRecommend;
@synthesize isLoading = _isLoading;
@synthesize isSubscribeAd = _isSubscribeAd;
@synthesize isExpand = _isExpand;
@synthesize photoListNewsRecommend = _photoListNewsRecommend;
@synthesize titleString;
@synthesize abstractString;
@synthesize titleHeight;
@synthesize abstractHeight;
@synthesize cellHeight;
@synthesize lastCellHeight;
@synthesize isSearchNews = _isSearchNews;
@synthesize subscribeCount;
@synthesize keyWord;
@synthesize expressFrom;
@synthesize cellType;
@synthesize subscribeAdObject;
@synthesize focusList;
@synthesize titlelineCnt;

- (void)fillDataToTableItem {
	self.subtitle = news.abstract;
	self.text = news.title;
    if (![news.picUrl isKindOfClass:[NSNull class]] && news.picUrl.length > 0) {
        self.imageURL = news.picUrl;
    }
    
}

- (void)setNews:(SNRollingNews *)newItem
{
	if (news != newItem) {
		 //(news);
		news = newItem;
		[self fillDataToTableItem];
	}
}

- (BOOL)hasGroupImages
{
    BOOL hasGroupImages = NO;
    if (![news.picUrl isKindOfClass:[NSNull class]] && self.news.picUrls.count >0) {
        hasGroupImages = YES;
    }
    return hasGroupImages;
}

- (NSInteger)getGroupImagesCount
{
    NSInteger imageCount = 0;
    if (![news.picUrl isKindOfClass:[NSNull class]] && self.news.picUrls.count >0) {
        imageCount = self.news.picUrls.count;
    } else if (self.news.newsAd.picUrls.count > 0) {
        imageCount = self.news.newsAd.picUrls.count;
    }
    return imageCount;
}

- (BOOL)hasImage
{
    BOOL hasImage = NO;
    if ( ![news.picUrl isKindOfClass:[NSNull class]] && self.news.picUrl.length > 0) {
        hasImage = YES;
    }
    return hasImage;
}

- (BOOL)hasNewsTypeIcon
{
    if (self.type==NEWS_ITEM_TYPE_SPECIAL_NEWS  || self.type== NEWS_ITEM_TYPE_LIVE
                                                || self.type==NEWS_ITEM_TYPE_WEIBO
                                                || self.type == NEWS_ITEM_TYPE_NEWSPAPER) {
        return YES;
    }
    else {
        if (self.type == NEWS_ITEM_TYPE_NORMAL && [self.news.hasVote isEqualToString:@"1"]) {
            return YES;
        }
        return NO;
    }
}

- (BOOL)hasVideo
{
    BOOL hasVideo = [self.news.hasVideo isEqualToString:@"1"];
    return hasVideo;
}

- (BOOL)hasVote
{
    BOOL hasVote = [self.news.hasVote isEqualToString:@"1"];
    return hasVote;
}

- (BOOL)isFlashNews
{
    BOOL isFlashNews = NO;
    if (self.news.isFlash && [self.news.isFlash isEqualToString:@"1"]) {
        isFlashNews = YES;
    }
    return isFlashNews;
}

- (BOOL)isH5Link
{
    BOOL isH5 = NO;
    if (self.news.link.length > 0) {
        isH5 = [SNAPI isWebURL:self.news.link];
    }
    return isH5;
}

- (BOOL)isChannelLink
{
    BOOL isChannel = NO;
    if (self.news.link.length > 0) {
        isChannel = [self.news.link hasPrefix:@"channel://"];
    }
    return isChannel;
}

- (BOOL)hasComments
{
    if (self.cellType == SNRollingNewsCellTypeApp ||
        self.cellType == SNRollingNewsCellTypeAppArray) {
        return NO;
    }
    
    switch (self.type) {
        case NEWS_TIEM_TYPE_OTHER_NEWS:
        case NEWS_ITEM_TYPE_SUBSCRIBE_NEWS:
        case NEWS_ITEM_TYPE_FINANCE:
        case NEWS_ITEM_TYPE_AD:
            return NO;
        default:
            break;
    }
    
    //和李家明确认，有sponsorshipsObject字段，需要显示评论 wangyy
//    if (self.news.sponsorshipsObject) {
//        return NO;
//    }
    if ([self.news isRedPacketNews]) {
        return NO;
    }
    
    if ([self.news isCouponsNews]) {
        return NO;
    }
    
    if (self.news.isFlash && [self.news.isFlash isEqualToString:@"1"]) {
        return NO;
    }    
    //14为视频类型，不显示评论数
    BOOL hasCommments = ![self.news.newsType isEqualToString:@"14"];
    return hasCommments;
}

- (BOOL)hasHotcomment{ //段子是否有热门评论
    if (self.news.funnyText.hotcomment_author.length > 0) {
        _hasHotcomment = YES;
    }else{
        _hasHotcomment = NO;
    }
    return _hasHotcomment;
}

- (BOOL)jokeHasImage {
    if ([self.news.newsType isEqualToString:@"62"] && self.news.picUrl.length > 0) {
        _jokeHasImage = YES;
    }else{
        _jokeHasImage = NO;
    }
    return _jokeHasImage;
}

- (BOOL)hasFavorites
{
    BOOL favorites = NO;
    switch (self.type) {
        case NEWS_ITEM_TYPE_NORMAL:
        case NEWS_ITEM_TYPE_GROUP_PHOTOS:
        case NEWS_ITEM_TYPE_WEIBO:
            favorites = YES;
            break;
        case NEWS_ITEM_TYPE_VIDEO: // v5.2.0 视频类型的没有
            favorites = NO;
            break;
        default:
            break;
    }
    
    switch (self.cellType) {
        case SNRollingNewsCellTypeIndividuation:
        case SNRollingNewsCellTypeWeather:
        case SNRollingNewsCellTypeVideo:
        case SNRollingNewsCellTypeSohuFeedBigPic:
        case SNRollingNewsCellTypeSohuFeedPhotos:
            favorites = NO;
            break;
            
        default:
            break;
    }
    
    return favorites;
}

- (BOOL)hasReport
{
    BOOL hasReport = NO;
    if (self.news.newsId && ![self.news.newsId isEqualToString:@""]) {
        hasReport = YES;
    }
    return hasReport;
}

- (NSString *)getExposureFrom
{
    NSString *fromString = nil;
    switch (self.expressFrom) {
        case NewsFromChannel:
            fromString = @"0";
            break;
        case NewsFromRecommend:
            fromString = @"1";
            break;
        case NewsFromArticleRecommend:
            fromString = @"2";
            break;
        case NewsFromSearch:
            fromString = @"3";
            break;
        case NewsFromChannelSubscribe:
            fromString = @"4";
            break;
        default:
            fromString = @"0";
            break;
    }
    return fromString;
}

- (BOOL)hiddenMoreButton
{
    if ([SNNewsFullscreenManager newsChannelChanged] && [self.news showNewTopArea]){
        return YES;
    }
    
    //外链的新闻没有更多按钮 wangyy
    if ([self.news.newsType isEqualToString:kSNOuterLinkNewsType]
        || self.cellType == SNRollingNewsCellTypeBookShelf) {
        return YES;
    }
 
    if (self.cellType == SNRollingNewsCellAdIndividuation) {
        return YES;
    }
    if (self.type == NEWS_ITEM_TYPE_NEWS_VIDEO
        || self.type == NEWS_ITEM_TYPE_NEWS_FUNNYTEXT
        || [self.news isSohuFeed]//搜狐feed 无听新闻、不感兴趣功能 需要显示更多按钮
        ) {
        return NO;
    }
    
    if (self.type == NEWS_ITEM_TYPE_NEWS_BOOK) {//首页流小说
        if ([self.news.title isEqualToString:[SNNovelUtilities shelfDataTitle]]) {//书架入口，隐藏更多按钮
            return YES;
        } else {
            return NO;
        }
    }
    
    BOOL isBookNews = self.cellType == SNRollingNewsCellTypeBookLabel || self.cellType == SNRollingNewsCellTypeBookBanner;
    //不显示更多按钮wyy
    if ([self.news isRedPacketNews]
        || [self.news isCouponsNews]
        || [self.news isSohuLive]
        || [self.news isRecomendHotWrods]
        || [self.news isFullScreenFocusNewsItem]//全屏焦点图
        || [self.news isTrainCardNewsItem]//火车卡片
        || isBookNews //书籍标签、bannner没有更多按钮
        ) {
        return YES;
    }
 
    //无听新闻、不感兴趣功能，只需判断是否能收藏决定是否显示更多按钮
    BOOL hasFavorites = [self hasFavorites];
    if (!hasFavorites) {
        
        //lijian 2015.05.05 特殊处理，适配广告要留更多按钮，并且要去掉收藏，真是复杂！
        if (self.cellType == SNRollingNewsCellTypeVideo || self.cellType == SNRollingNewsCellTypeAdDefault || self.cellType == SNRollingNewsCellTypeAdPicture || self.cellType == SNRollingNewsCellTypeAdBanner || self.cellType == SNRollingNewsCellTypeAppAd || self.cellType == SNRollingNewsCellTypeAdPhotos || self.cellType == SNRollingNewsCellTypeAdMixpicDownload || self.cellType == SNRollingNewsCellTypeAdSmallpicDownload || self.cellType == SNRollingNewsCellTypeAdBigpicDownload || self.cellType == SNRollingNewsCellTypeAdMixpicPhone || self.cellType == SNRollingNewsCellTypeAdBigpicPhone || self.cellType == SNRollingNewsCellTypeAdVideoDownload) {
            return NO;
        }
        return YES;
    }
    
    BOOL hiddenMore = NO;
    switch (self.expressFrom) {
        case NewsFromChannel:
            if (self.news.fromSub) {
                hiddenMore = YES;
            }else {
                hiddenMore = NO;
            }
            break;
        case NewsFromRecommend:
            hiddenMore = NO;
            break;
        case NewsFromArticleRecommend:
            hiddenMore = YES;
            break;
        case NewsFromSearch:
            hiddenMore = YES;
            break;
        default:
            break;
    }
        
    switch (self.cellType) {
        case SNRollingNewsCellTypeFocus:
        case SNRollingNewsCellTypeFocusWeather:
        case SNRollingNewsCellTypeFocusAd:
        case SNRollingNewsCellTypeMoreFoucs:
            hiddenMore = YES;
            break;
        case SNRollingNewsCellTypeApp:
        case SNRollingNewsCellTypeAppArray: {
            hiddenMore = ![[SNAppConfigManager sharedInstance] isAppInterestOpen];
            break;
        }
        default:
            break;
    }
    
    if (self.type == NEWS_ITEM_TYPE_SUBSCRIBE_NEWS) {
        hiddenMore = YES;
    }
    
    return hiddenMore;
}

#pragma mark 隐藏cell分割线 5.9.4 wangchuanwen add
- (BOOL)hiddenCellLine
{
    return self.news.hiddenLine;
}

- (BOOL)checkInstallApp
{
    BOOL install = NO;
    if (self.news.app.urlScheme.length >0) {
         install = [SNUtility isWhiteListURL:[NSURL URLWithString:self.news.app.urlScheme]];
    }
    return install;
}


- (SNCCPVPage)getCurrentPage
{
    SNCCPVPage page;
    switch (self.expressFrom) {
        case NewsFromChannel:
            if (self.news.fromSub) {
                page = paper_main;
            }else {
                page = tab_news;
            }
            break;
        case NewsFromRecommend:
            page = tab_news;
            break;
        case NewsFromArticleRecommend:
            if (self.photoListNewsRecommend) {
                page = article_detail_pic;
            }else {
                page = article_detail_txt;
            }
            break;
        case NewsFromSearch:
            page = search;
            break;
        default:
            page = tab_news;
            break;
    }
    return page;
}

- (SNTimelineContentType)getShareContentType
{
    SNTimelineContentType contentType;
    switch (self.type) {
        case NEWS_ITEM_TYPE_NORMAL:
            contentType = SNTimelineContentTypeNews;
            break;
        case NEWS_ITEM_TYPE_GROUP_PHOTOS:
            contentType = SNTimelineContentTypePhoto;
            break;
        case NEWS_ITEM_TYPE_SPECIAL_NEWS:
            contentType = SNTimelineContentTypeSpecial;
            break;
        case NEWS_ITEM_TYPE_LIVE:
            contentType = SNTimelineContentTypeLive;
            break;
        case NEWS_ITEM_TYPE_WEIBO:
            contentType = SNTimelineContentTypeWeibo;
            break;
        case NEWS_ITEM_TYPE_NEWSPAPER:
        case NEWS_ITEM_TYPE_SUBSCRIBE:
            contentType = SNTimelineContentTypePaper;
            break;
        default:
            contentType = SNTimelineContentTypeNews;
            break;
    }
    return contentType;
}

- (NSString *)getShareContentId
{
    NSString *idString;
    switch (self.type) {
        case NEWS_ITEM_TYPE_NORMAL:
            idString = self.news.newsId;
            break;
        case NEWS_ITEM_TYPE_NEWSPAPER:
            idString = self.news.newsId;
            break;
        case NEWS_ITEM_TYPE_SUBSCRIBE:
            idString = self.news.subId;
            break;
        default:
            idString = self.news.newsId;
            break;
    }
    return idString;
}

- (int)getShareSourceType
{
    int sourceType;
    switch (self.type) {
        case NEWS_ITEM_TYPE_NORMAL:
            sourceType = SNShareSourceTypeNews;
            break;
        case NEWS_ITEM_TYPE_GROUP_PHOTOS:
            sourceType = SNShareSourceTypePhoto;
            break;
        case NEWS_ITEM_TYPE_SPECIAL_NEWS:
            sourceType = SNShareSourceTypeNews;
            break;
        case NEWS_ITEM_TYPE_LIVE:
            sourceType = SNShareSourceTypeLive;
            break;
        case NEWS_ITEM_TYPE_WEIBO:
            sourceType = SNShareSourceTypeWeibo;
            break;
        case NEWS_ITEM_TYPE_NEWSPAPER:
            sourceType = SNShareSourceTypeNews;
            break;
        case NEWS_ITEM_TYPE_SUBSCRIBE:
            sourceType = SNShareSourceTypeSub;
            break;
        default:
            sourceType = SNShareSourceTypeNews;
            break;
    }
    return sourceType;
}

- (NSString *)getShareLogoType
{
    NSString *logoType;
    switch (self.type) {
        case NEWS_ITEM_TYPE_NORMAL:
            logoType = @"news";
            break;
        case NEWS_ITEM_TYPE_GROUP_PHOTOS:
            logoType = @"pics";
            break;
        case NEWS_ITEM_TYPE_SPECIAL_NEWS:
            logoType = @"special";
            break;
        case NEWS_ITEM_TYPE_LIVE:
            logoType = @"video";
            break;
        case NEWS_ITEM_TYPE_WEIBO:
            logoType = @"weiboHot";
            break;
        case NEWS_ITEM_TYPE_NEWSPAPER:
            logoType = @"news";
            break;
        case NEWS_ITEM_TYPE_SUBSCRIBE:
            logoType = @"subDetail";
            break;
        default:
            logoType = @"news";
            break;
    }
    return logoType;
}

- (NSString *)getNewsTypeString{
    return (self.news.isTopNews || [self.news.from isEqualToString:kRollingNewsFormTop]) ? @"置顶" : self.news.iconText;
}

- (NSString *)getNewsTypeTextString {
    return self.news.newsTypeText;
}

//根据templateType设置cell模版 参考链接: http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=8030444

- (void)setItemCellTypeWithTemplate
{    
    if (self.news.templateType.length > 0) {
        int teplateValue = [self.news.templateType intValue];
        switch (teplateValue) {
            case 1:
                cellType = [self hasImage] ? SNRollingNewsCellTypeDefault:SNRollingNewsCellTypeAbstrac;
                break;
            case 2:
                cellType = SNRollingNewsCellTypePhotos;
                break;
            case 3:
                cellType = SNRollingNewsCellTypeFocus;
                break;
            case 4:
                cellType = SNRollingNewsCellTypeWeather;
                break;
            case 5:
                cellType = SNRollingNewsCellTypeFocusWeather;
                break;
            case 22:
                cellType = SNRollingNewsCellTypeVideo;
                break;
            case 7:
                cellType = SNRollingNewsCellTypeMatch;
                break;
            case 8:
                cellType = SNRollingNewsCellTypeCommon;
                break;
            case 9:
                cellType = SNRollingNewsCellTypePicture;
                break;
            case 10:
            case 29:
                cellType = SNRollingNewsCellTypeFinance;
                break;
            case 11:
                cellType = SNRollingNewsCellTypeApp;
                break;
            case 12:
                cellType = SNRollingNewsCellTypeAdDefault;
                break;
            case 13:
                cellType = SNRollingNewsCellTypeAdBanner;
                break;
            case 14:
                cellType = SNRollingNewsCellTypeAdPicture;
                break;
            case 15:
                cellType = SNRollingNewsCellTypeSubscribe;
                break;
            case 16:
                cellType = SNRollingNewsCellTypeMySubscribe;
                break;
            case 17:
                cellType = SNRollingNewsCellTypeAppArray;
                break;
            case 18:
                cellType = SNRollingNewsCellTypeGroupNews;
                break;
            case 19:
                cellType = SNRollingNewsCellTypeIndividuation;
                break;
            case 20:
                cellType = SNRollingNewsCellTypeLoadMore;
                break;
            case 21:
                cellType = SNRollingNewsCellTypeFocusAd;
                break;
            case 23:
                cellType = SNRollingNewsCellTypeAppAd;
                break;
            case 24:
                cellType = SNRollingNewsCellTypeFocusHouse;
                break;
            case 25:
                cellType = SNRollingNewsCellTypeFocusLocal;
                break;
            case 26:
                cellType = SNRollingNewsCellTypeAdStock;
                break;
            case 27:
                cellType = SNRollingNewsCellTypeChangeCity;
                break;
            case 28:
                cellType = SNRollingNewsCellTypeMoreFoucs;
                break;
            case 30:
                cellType = SNRollingNewsCellTypeCityScanAndTickets;
                break;
            case 31:
                cellType = SNRollingNewsCellTypeRedPacket;
                break;
            case 32:
                cellType = SNRollingNewsCellTypeRedPacketTip;
                break;
            case 33:
                cellType = SNRollingNewsCellTypeCoupons;
                break;
            case 34:
                cellType = SNRollingNewsCellTypeNewsVideo;
                break;
            case 35:
                cellType = SNRollingNewsCellTypeFunnyText;
                break;
            case 37:
                cellType = SNRollingNewsCellTypeNewsVideo;
                break;
            case 38:
                cellType = SNRollingNewsCellTypeAutoVideoMidImageType;
                break;
            case 39:
                cellType = SNRollingNewsCellTypeSohuLive;
                break;
            case 40:
                cellType = SNRollingNewsCellTypeRecomendItemTagType;
                break;
            case 41: 
                cellType = SNRollingNewsCellTypeAdPhotos;
                break;
            case 51:
                cellType = SNRollingNewsCellTypeAdMixpicDownload;
                break;
            case 52:
                cellType = SNRollingNewsCellTypeAdBigpicDownload;
                break;
            case 53:
                cellType = SNRollingNewsCellTypeAdSmallpicDownload;
                break;
            case 54:
                cellType = SNRollingNewsCellTypeAdMixpicPhone;
                break;
            case 55:
                cellType = SNRollingNewsCellTypeAdBigpicPhone;
                break;
            case 138:
                cellType = SNRollingNewsCellTypeBook;
                break;
            case 74:
                cellType = SNRollingNewsCellTypeSohuFeedBigPic;
                break;
            case 75:
                cellType = SNRollingNewsCellTypeSohuFeedPhotos;
                break;
            case 76:
                cellType = SNRollingNewsCellAdIndividuation;
                break;
            case 77:
                cellType = SNRollingNewsCellTypeAdVideoDownload;
                break;
            case 79:
                cellType = SNRollingNewsCellTypeTrainCard;
                break;
            case 139:
                cellType = SNRollingNewsCellTypeBookShelf;
                break;
            case 145:
                cellType = SNRollingNewsCellTypeBookLabel;
                break;
            case 146:
                cellType = SNRollingNewsCellTypeBookBanner;
                break;
            case 200:
                cellType = SNRollingNewsCellTypeTopic;
                break;
            case 201:
                cellType = SNRollingNewsCellTypeRefresh;
                break;
            case 202:
                cellType = SNRollingNewsCellTypeFullScreenFocus;
                break;
            case 203:
                cellType = SNRollingNewsCellTypeHistoryLine;
                break;
            default:
                cellType = [self hasImage]?SNRollingNewsCellTypeDefault:SNRollingNewsCellTypeAbstrac;
                break;
        }
    }
}

//设置newsType
- (void)setItemNewsType
{
    if ([news.newsType isEqualToString:kNewsTypePhotoAndText]) {
        self.type = NEWS_ITEM_TYPE_NORMAL;
    } else if([news.newsType isEqualToString:kNewsTypeGroupPhoto] || [news isGroupPhotoNews]) {
        self.type = NEWS_ITEM_TYPE_GROUP_PHOTOS;
    } else if ([news.newsType isEqualToString:kNewsTypeSpecialNews]) {
        self.type = NEWS_ITEM_TYPE_SPECIAL_NEWS;
    } else if ([news.newsType isEqualToString:kNewsTypeLive]) {
        self.type = NEWS_ITEM_TYPE_LIVE;
    } else if ([news.newsType isEqualToString:kNewsTypePaper]) {
        self.type = NEWS_ITEM_TYPE_NEWSPAPER;
    } else if ([news.newsType isEqualToString:kSubscriptionType]) {
        self.type = NEWS_ITEM_TYPE_SUBSCRIBE;
    } else if ([news.newsType isEqualToString:kNewsTypeWeibo]) {
        self.type = NEWS_ITEM_TYPE_WEIBO;
    } else if([news.newsType isEqualToString:kNewsTypePublic]) {
        self.type = NEWS_ITEM_TYPE_PUBLIC;
    } else if ([news.newsType isEqualToString:kNewsTypeAd]) {
        self.type = NEWS_ITEM_TYPE_AD;
    } else if ([news.newsType isEqualToString:kNewsTypeMySubscribe]) {
        self.type = NEWS_ITEM_TYPE_MYSUBSCRIBE;
    } else if ([news.newsType isEqualToString:kNewsTypeVideo]) {
        self.type = NEWS_ITEM_TYPE_VIDEO;
    } else if ([news.templateType isEqualToString:@"37"]) {
        self.type = NEWS_ITEM_TYPE_NEWS_VIDEO;
    } else if ([news.templateType isEqualToString:@"38"]) {
        self.type = NEWS_ITEM_TYPE_NEWS_VIDEO;
    }else if ([news.newsType isEqualToString:kNewsTypeFinance] || [news.newsType isEqualToString:kNewsTypeNewFinance]) {
        self.type = NEWS_ITEM_TYPE_FINANCE;
    } else if ([news.newsType isEqualToString:kNewsTypeApp]) {
        self.type = NEWS_ITEM_TYPE_APP;
    }else if ([news.newsType isEqualToString:kNewsTypeRollingFunnyText]) {
        self.type = NEWS_ITEM_TYPE_NEWS_FUNNYTEXT;
    } else if ([news.newsType isEqualToString:kNewsTypeFocusWeather]) {
        self.type = NEWS_ITEM_TYPE_FOCUS_WEATHER;
    } else if ([news.newsType isEqualToString:kSubscriptionVideoType]) {
        self.type = NEWS_ITEM_TYPE_SUBSCRIBE;
    } else if ([news.newsType isEqualToString:kSubscriptionOrgType]) {
        self.type = NEWS_ITEM_TYPE_SUBSCRIBE;
    } else if  ([news.newsType isEqualToString:kSubscriptionLinkType]) {
        self.type = NEWS_ITEM_TYPE_SUBSCRIBE;
    } else if ([news.newsType isEqualToString:kSubscriptionOtherType]) {
        self.type = NEWS_ITEM_TYPE_SUBSCRIBE;
    } else if ([news.newsType isEqualToString:kNewsTypeAppArray]) {
        self.type = NEWS_ITEM_TYPE_APP_ARRAY;
    } else if ([news.newsType isEqualToString:kNewsTypeOtherNews]) {
        self.type = NEWS_TIEM_TYPE_OTHER_NEWS;
    }else if ([news.newsType isEqualToString:kNewsTypeIndividuation]) {
        self.type = NEWS_TIEM_TYPE_INDIVIDUATION;
    }else if ([news.newsType isEqualToString:kNewsTypeRollingBook]) {
        self.type = NEWS_ITEM_TYPE_NEWS_BOOK;
    }else if ([news.newsType isEqualToString:kNewsTypeRollingBookShelf]) {
        self.type = NEWS_ITEM_TYPE_NEWS_BOOKSHELF;
    }
    else if ([news.newsType isEqualToString:kNewsTypeRecommendBook]) {
        //推荐流小说 以前是26，现在是67，不知原因
        self.type = NEWS_ITEM_TYPE_NEWS_BOOK;
    }
    else {
        self.type = NEWS_ITEM_TYPE_NORMAL;
    }
}

- (void)dealloc
{
	 //(news);
     //(newsList);
     //(photoList);
     //(specailList);
     //(liveList);
     //(allList);
     //(_newsModel);
     //(titleString);
     //(abstractString);
     //(subscribeCount);
     //(keyWord);
     //(subscribeAdObject);
     //(focusList);
}

@end
