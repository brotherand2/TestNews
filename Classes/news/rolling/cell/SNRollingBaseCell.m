//
//  SNRollingBaseCell.m
//  sohunews
//
//  Created by lhp on 5/9/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingBaseCell.h"
#import "SNGuideRegisterManager.h"
#import "SNActionMenuContentFactory.h"
#import "SNCellMoreView.h"
#import "SNNewsContentFavourite.h"
#import "SNMyFavouriteManager.h"
#import "SNNewsAd+analytics.h"
#import "SNNewsUninterestedService.h"
#import "SNCommonNewsDatasource.h"
#import "SNNewsSpeaker.h"
#import "SNNewsSpeakerManager.h"
#import "SNToast.h"
#import "SNCenterToast.h"
#import "SNVideoDetailModel.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNUserManager.h"
#import "SNRollingNewsTitleCell.h"
#import "SNBookShelf.h"
#import "SNReasonsForUninterestedFormater.h"
#import "SNNewAlertView.h"
#import "SNNewsReport.h"
#import "SNUninterestedView.h"
#import "StoryBookList.h"
#import "SNCellPopover.h"

#import "SNNewsLoginManager.h"

#define kMoreImageWidth ([[SNDevice sharedInstance] isPlus] ? (43.5 / 3) : (29.0 / 2))
#define kMoreImageHeight ([[SNDevice sharedInstance] isPlus] ? (43.5 / 3) :(29.0/2))
#define kCellLineHeight    0.5

@interface SNRollingBaseCell ()
@property (nonatomic, assign) BOOL isAddShelf;//是否加入书架
@property (nonatomic, strong) SNCellPopover *popover;
@end

@implementation SNCellMoreButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat x = frame.size.width - kMoreImageWidth - CONTENT_LEFT;
        CGFloat y = frame.size.height - kMoreImageHeight - CONTENT_BOTTOM;
        CGRect imageRect = CGRectMake(x,y, kMoreImageWidth, kMoreImageHeight);
        _moreImageView = [[UIImageView alloc] initWithFrame:imageRect];
        _moreImageView.image = [UIImage themeImageNamed:@"icohome_moresmall_v5.png"];
        _moreImageView.highlightedImage = [UIImage themeImageNamed:@"icohome_moresmallpress_v5.png"];
        [self addSubview:_moreImageView];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    _moreImageView.highlighted = highlighted;
}

- (void)updateTheme {
    _moreImageView.image = [UIImage themeImageNamed:@"icohome_moresmall_v5.png"];
    _moreImageView.highlightedImage = [UIImage themeImageNamed:@"icohome_moresmallpress_v5.png"];
}

@end


@interface SNRollingBaseCell () {
    BOOL isFristNews;
}
@end

@implementation SNRollingBaseCell
@synthesize item;
@synthesize exposure;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.exposure = YES;
        isFristNews = NO;
        [self initMoreButton];
        
        //by 5.9.4 wangchuanwen add
        //cell分割线
        lineView = [[UIView alloc]initWithFrame:CGRectMake(CONTENT_LEFT, 0, kAppScreenWidth - 2 * CONTENT_LEFT, kCellLineHeight)];
        lineView.backgroundColor = SNUICOLOR(kThemeBg6Color);
        [self addSubview:lineView];
        //add end
    }
    return self;
}

- (void)initMoreButton {
    CGFloat offsetLeft = kAppScreenWidth - kMoreButtonWidth;
    moreButton = [[SNCellMoreButton alloc] initWithFrame:CGRectMake(offsetLeft,0, kMoreButtonWidth, kMoreButtonHeight)];
    [moreButton addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
    moreButton.isAccessibilityElement = NO;
    [self addSubview:moreButton];
}

- (SNTimelineOriginContentObject *)returnOriginContentObject {
    SNTimelineOriginContentObject *obj = [[SNTimelineOriginContentObject alloc] init];
    obj.contentId = [self.item getShareContentId];
    obj.sourceType = [self.item getShareSourceType];
    obj.title = self.item.news.title;
    obj.abstract = self.item.news.abstract;
    obj.description = self.item.news.abstract;
    obj.picUrl = self.item.news.picUrl;
    obj.subId = self.item.news.subId;
    obj.hasTv = [self.item hasVideo];
    obj.fromString = self.item.news.from;
    obj.link = self.item.news.link;
    obj.picsArray = self.item.news.picUrls?[NSMutableArray arrayWithArray:self.item.news.picUrls]:nil;
    
    // 微热议 没有title的情况 title字段用摘要
    if (obj.sourceType == 13 && obj.title.length == 0) {
        if (obj.abstract.length > 10) {
            NSString *title = [NSString stringWithFormat:@"%@...", [obj.abstract substringToIndex:10]];
            obj.title = title;
        } else {
            obj.title = obj.abstract;
        }
    }
    
    // v5.2.0 会报警告是因为 init开头的原因 ?
    return obj;
}

- (NSMutableDictionary *)getShareContentDic {
    NSMutableDictionary *shareDic = [NSMutableDictionary dictionary];
    if (self.item.news.newsId) {
        [shareDic setObject:self.item.news.newsId forKey:kNewsId];
    }
    if (self.item.news.subId) {
        [shareDic setObject:self.item.news.subId forKey:kSubId];
        [shareDic setObject:self.item.news.subId forKey:@"logSubId"];
    }
    if (self.item.news.title) {
        [shareDic setObject:self.item.news.title forKey:kTitle];
    }
    if (self.item.news.picUrl) {
        [shareDic setObject:self.item.news.picUrl forKey:@"imageUrl"];
    }
    
    SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:[self.item getShareContentType] contentId:[self.item getShareContentId]];
    if (!obj) {
        obj = [self returnOriginContentObject];
    }
    
    [shareDic setObject:obj forKey:kShareInfoKeyInfoDic];
    return shareDic;
}

- (SNActionMenuContent *)getShareContentInfo {
    SNOAuthsActionMenuContent *shareContent = (SNOAuthsActionMenuContent *)[SNActionMenuContentFactory getContentOfType:SNActionMenuOptionOAuths];
    shareContent.shareSubType = ShareSubTypeQuoteCard;
    shareContent.timelineContentType = [self.item getShareContentType];
    shareContent.timelineContentId = [self.item getShareContentId];
    shareContent.shareLogSudId = self.item.news.subId;
    shareContent.shareLogType = [self.item getShareLogoType];
    shareContent.shareTitle = self.item.news.title;
    shareContent.dic = [self getShareContentDic];
    
    SNTimelineOriginContentObject *obj = [[SNDBManager currentDataBase] getTimelineOriginObjByType:[self.item getShareContentType]
                                                                                         contentId:[self.item getShareContentId]];
    if (obj) {
        shareContent.sourceType = obj.sourceType;
    } else {
        shareContent.sourceType = [self.item getShareSourceType];
    }
    
    return shareContent;
}

- (BOOL)hasUninterested {
    //焦点图不感兴趣无效
    if (self.item.news.templateType &&
        [self.item.news.templateType isEqualToString:@"3"]) {
        return NO;
    }
    
    if (self.item.news.newsId.length == 0) {
        return NO;
    }
    
    //小说显示“不感兴趣”区分 1.小说频道不显示  2.推荐频道小说显示
    if (self.item.type == NEWS_ITEM_TYPE_NEWS_BOOK) {
        if ([self.item.news.channelId isEqualToString:@"960415"] ||
            [self.item.news.channelId isEqualToString:@"13555"]) {
            return NO;
        } else {
            return YES;
        }
    }
    
    isAdRecom = NO;//是否为推荐流广告
    if (self.item.type == NEWS_ITEM_TYPE_AD) {
        NSDictionary *dict = [self dictionaryWithJsonString:self.item.news.dataString];
        if (dict) {
            _monitorkey = [[dict objectForKey:@"data"] objectForKey:@"monitorkey"];
            NSString *itemspaceid = [[dict objectForKey:@"data"] objectForKey:@"itemspaceid"];
            if (itemspaceid && ([itemspaceid isEqualToString:@"13016"] ||
                                [itemspaceid isEqualToString:@"12451"])) {
                isAdRecom = YES;
            }
        }
    }
    
    //要闻&推荐频道置顶新闻三点内不展示“不感兴趣”
    if ([self.item.news isRollingTopNews] && (![self.item.news.channelId isEqualToString:@"1"] && ![self.item.news.channelId  isEqualToString:@"13557"])) {
        return YES;
    }
    
    //非推荐流新闻和广告，不显示“不感兴趣”功能
    if (![self.item.news.isRecom isEqualToString:@"1"] && !isAdRecom) {
        if ([self.item.news isSohuFeed]) {
            return YES;
        }
        return NO;
    }
    
    return YES;
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return nil;
    }
    return dic;
}

- (BOOL)hasVideoAd {
    if (self.item.news.templateType &&
        ([self.item.news.templateType isEqualToString:@"22"] || [self.item.news.templateType isEqualToString:@"77"])) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isNewsVideo {
    if (self.item.news.templateType &&
        [self.item.news.templateType isEqualToString:@"37"]) {
        return YES;
    }
    if (self.item.news.templateType &&
        [self.item.news.templateType isEqualToString:@"38"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isBook {
    if (self.item.news.templateType &&
        [self.item.news.templateType isEqualToString:@"138"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isFunnyTextNews {
    if (self.item.news.templateType &&
        [self.item.news.templateType isEqualToString:@"35"]) {
        return YES;
    }
    return NO;
} 

- (BOOL)hideMoreButton {
    return [self.item hiddenMoreButton];
}

//by 5.9.4 wangchuanwen add
- (BOOL)hideCellLine {
    return [self.item hiddenCellLine];
}
//add end

- (BOOL)showListenNewsTips {
    BOOL showListenTips = NO;
    if ([self hasListenNews] &&
        ![self hideMoreButton]) {
        showListenTips = YES;
    }
    return showListenTips;
}

- (SNNewsContentFavourite *)getFavourite {
    NSString *mid = nil;
    NSString *subId = nil;
    NSString *termId = nil;
    NSString *pubId = nil;
    NSString *newsPaperId = nil;
    if (self.item.news.link.length > 0) {
        NSRange range = [self.item.news.link rangeOfString:@"://"];
        if (range.length > 0) {
            NSString *schema = [self.item.news.link substringToIndex:range.location + range.length];
            NSDictionary *queryDic = [SNUtility parseProtocolUrl:self.item.news.link schema:schema];
            
            mid = [queryDic stringValueForKey:kMidInMediaLink defaultValue:@""];
            subId = [queryDic stringValueForKey:kSubId defaultValue:@""];
            termId = [queryDic stringValueForKey:kTermId defaultValue:@""];
            pubId = [queryDic stringValueForKey:kPUB_ID defaultValue:@""];
            
            if (termId.length > 0) {
                newsPaperId = termId;
            }
            if (newsPaperId && subId.length > 0) {
                newsPaperId = [newsPaperId stringByAppendingFormat:@"#%@",subId];
            }
        }
    }
    
    SNNewsContentFavourite *newsContentFavourite = [[SNNewsContentFavourite alloc] init];
    newsContentFavourite.title = self.item.news.title;
    newsContentFavourite.publicationDate = [NSString stringWithFormat:@"%lf", [[NSDate date] timeIntervalSince1970] * 1000];
    switch (self.item.type) {
        case NEWS_ITEM_TYPE_NEWSPAPER:
            newsContentFavourite.type = MYFAVOURITE_REFER_PUB_HOME;
            newsContentFavourite.contentLevelFirstID = pubId;
            newsContentFavourite.contentLevelSecondID = newsPaperId;
            break;
        case NEWS_ITEM_TYPE_VIDEO:
            newsContentFavourite.type = MYFAVOURITE_REFER_VIDEO;
            newsContentFavourite.contentLevelFirstID = self.item.news.channelId;
            newsContentFavourite.contentLevelSecondID = mid;
            break;
        case NEWS_ITEM_TYPE_WEIBO:
            newsContentFavourite.type = MYFAVOURITE_REFER_WEIBO_HOT;
            newsContentFavourite.contentLevelFirstID = self.item.news.channelId;
            newsContentFavourite.contentLevelSecondID = self.item.news.newsId;
            break;
        case NEWS_ITEM_TYPE_GROUP_PHOTOS:
            newsContentFavourite.type = MYFAVOURITE_REFER_GROUPPHOTOLIST_IN_ROLLINGNEWS;
            newsContentFavourite.contentLevelFirstID = self.item.news.channelId;
            newsContentFavourite.contentLevelSecondID = self.item.news.newsId;
            break;
        case NEWS_ITEM_TYPE_NEWS_FUNNYTEXT:
            newsContentFavourite.type = MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWSJOKE;
            newsContentFavourite.contentLevelFirstID = self.item.news.channelId;
            newsContentFavourite.contentLevelSecondID = self.item.news.newsId;
            break;
        case NEWS_ITEM_TYPE_NEWS_VIDEO:
            newsContentFavourite.type = MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWSNEWVIDEO;
            newsContentFavourite.contentLevelFirstID = self.item.news.channelId;
            newsContentFavourite.contentLevelSecondID = self.item.news.link;
            newsContentFavourite.templateType = self.item.news.templateType;
            break;
        default:
            newsContentFavourite.type = MYFAVOURITE_REFER_NEWS_IN_ROLLINGNEWS;
            newsContentFavourite.contentLevelFirstID = self.item.news.channelId;
            newsContentFavourite.contentLevelSecondID = self.item.news.newsId;
            break;
    }
    
    return newsContentFavourite;
}

- (BOOL)checkIfHadBeenMyFavourite {
    @autoreleasepool {
        SNNewsContentFavourite *newsContentFavourite = [self getFavourite];
        return [[SNMyFavouriteManager shareInstance] checkIfInMyFavouriteList:newsContentFavourite];
    }
}

- (void)moreAction {
    //CC统计
    SNCCPVPage page = [self.item getCurrentPage];
    SNUserTrack *userTrack = [SNUserTrack trackWithPage:page link2:nil];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], f_intimenews_more];
    [SNNewsReport reportADotGifWithTrack:paramString];
    
    //关闭cell弹出的更多View
    [[SNRollingNewsPublicManager sharedInstance] closeCellMoreViewAnimation:NO];
    [[SNRollingNewsPublicManager sharedInstance] closeListenNewsGuideViewAnimation:NO];
    
    BOOL newsFavorited = [self checkIfHadBeenMyFavourite];
    BOOL uninterest = [self hasUninterested];
    BOOL hasFavorites = [self.item hasFavorites];
    BOOL hasListenNews = [self hasListenNews];
    BOOL hasVideoAd = [self hasVideoAd];
    BOOL isNewsVideo = [self isNewsVideo];
    BOOL isFunnyText = [self isFunnyTextNews];
    BOOL isBook = [self isBook];
    
    SNCellMoreViewButtonOptions buttonOptions = SNCellMoreButtonOptionsNone;
    if (uninterest) {
        buttonOptions = buttonOptions | SNCellMoreButtonOptionsUninterested;
        
        NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
        [dictData setValue:self.item.news.newsId forKey:@"oid"];

        //这里type和服务端商定好的 新闻传1，广告传2
        if ([self.item.news.isRecom isEqualToString:@"1"]) {
            [dictData setValue:@"1" forKey:@"type"];
        } else if (isAdRecom) {
            [dictData setValue:@"2" forKey:@"type"];
        }
        
        [SNReasonsForUninterestedFormater requestUninterestedDataWithDic:dictData Completion:^(NSError *error, id data) {
            if (data) {
                self.uninterestedItem = data;
            } else {
                self.uninterestedItem = nil;
            }
        }];
    }
    
    if (isBook) {
        if (uninterest) {
            buttonOptions = buttonOptions | SNCellMoreButtonOptionAddBookShelf;
        } else {
            buttonOptions = SNCellMoreButtonOptionAddBookShelf;
        }
    } else {
        buttonOptions = buttonOptions | SNCellMoreButtonOptionReport;
        if (hasFavorites) {
            buttonOptions = buttonOptions | SNCellMoreButtonOptionsFavorites;
        }
        if (hasVideoAd){
            buttonOptions = buttonOptions | SNCellMoreButtonOptionVideoAd;
        }
        if (hasListenNews) {
            buttonOptions = buttonOptions | SNCellMoreButtonOptionListenNews;
        }
        if (isFunnyText) {
            buttonOptions = buttonOptions | SNCellMoreButtonOptionsFavorites | SNCellMoreButtonOptionsUninterested | SNCellMoreButtonOptionShare| SNCellMoreButtonOptionListenNews;
        }
        if (isNewsVideo) {
            buttonOptions = SNCellMoreButtonOptionReport | SNCellMoreButtonOptionsFavorites | SNCellMoreButtonOptionShare;
            if (uninterest) {
                buttonOptions = buttonOptions | SNCellMoreButtonOptionsUninterested;
            }
        }
    }

    int moreViewHeight = self.item.isExpand ? (self.item.lastCellHeight > 0 ? self.item.lastCellHeight : self.height) : self.height ;
    CGFloat moreViewY = self.item.isExpand ? (self.height - moreViewHeight) : 0;
    
    CGRect rect = CGRectMake(0, moreViewY, kAppScreenWidth, moreViewHeight);
    self.isAddShelf = NO;
    
    if (self.item.news.novelBookId &&
        self.item.news.novelBookId.length > 0) {//小说更多浮层
        [self queryBookShelfWithRect:rect newsFavorited:newsFavorited buttonOptions:buttonOptions];
    } else {
        [self createCellMoreViewWithFrame:rect newsFavorited:newsFavorited buttonOptions:buttonOptions];
    }
}

#pragma mark -书架书记确认
- (void)queryBookShelfWithRect:(CGRect)rect
                 newsFavorited:(BOOL)newsFavorited
                 buttonOptions:(SNCellMoreViewButtonOptions)buttonOptions {
    //换成从数据库中取值
    BOOL isOnBookshelf = [SNBookShelf isOnBookshelf:self.item.news.novelBookId];
    self.isAddShelf = isOnBookshelf;
    [self createCellMoreViewWithFrame:rect newsFavorited:newsFavorited buttonOptions:buttonOptions];
}

- (void)createCellMoreViewWithFrame:(CGRect)frame
                      newsFavorited:(BOOL)newsFavorited
                      buttonOptions:(SNCellMoreViewButtonOptions)buttonOptions {
    // 清理掉之前的moreview，以免出现两个浮层
    if (self.moreView) {
        [self.moreView removeFromSuperview];
        self.moreView = nil;
    }
    __weak SNRollingBaseCell *blockSelf = self;
    self.moreView = [[SNCellMoreView alloc] initWithFrame:frame
                                            buttonOptions:buttonOptions
                                            newsFavorited:newsFavorited isAddBookShelf:self.isAddShelf];
    
    self.moreView.right = 2*kAppScreenWidth + CONTENT_LEFT;
    [self.moreView setUninterestBlock:^{
        [blockSelf showReasonsForUninterestedView];
    } favoritesBlock:^(NSDictionary *dict){
        [blockSelf favoriteNews:dict];
    } listenBlock:^{
        [blockSelf listenNews];
    } reportBlock:^{
        [blockSelf report];
    } addBookShelfBlock:^{
        [blockSelf addBookShelf];
    }];
    
    [SNRollingNewsPublicManager sharedInstance].moreView = self.moreView;
    [self addSubview:self.moreView];
    [[SNRollingNewsPublicManager sharedInstance] showAnimationWithRight:kAppScreenWidth];
}

- (void)createPopMoreViewWithFrame:(CGRect)frame
                     newsFavorited:(BOOL)newsFavorited
                     buttonOptions:(SNCellMoreViewButtonOptions)buttonOptions {
    __weak SNRollingBaseCell *blockSelf = self;
    frame.size.height = 82;
    self.moreView = [[SNCellMoreView alloc] initWithFrame:frame
                                            buttonOptions:buttonOptions
                                            newsFavorited:newsFavorited isAddBookShelf:self.isAddShelf];
    
    [_moreView hideBlurEffort];
    [_moreView removeCloseButton];
    
    _moreView.frame = CGRectMake(8, frame.origin.y,
                                 [UIScreen mainScreen].bounds.size.width - 16,
                                 frame.size.height);
    
    _moreView.assignBaseCellDelegate = self;
    
    self.popover = [SNCellPopover popover];
    
    [_moreView setUninterestBlock:^{
        [blockSelf dismissPopover];
        [blockSelf showReasonsForUninterestedView];
    } favoritesBlock:^(NSDictionary *dict){
        [blockSelf dismissPopover];
        [blockSelf favoriteNews:dict];
    } listenBlock:^{
        [blockSelf dismissPopover];
        [blockSelf listenNews];
    } reportBlock:^{
        [blockSelf dismissPopover];
        [blockSelf report];
    } addBookShelfBlock:^{
        [blockSelf dismissPopover];
        [blockSelf addBookShelf];
    }];

    [self.popover showAtView:moreButton withContentView:_moreView];
}

- (void)dismissPopover {
    if (self.popover) {
        [self.popover dismiss];
    }
}

- (void)addBookShelf {
    //hzbook
    if (self.item.news.novelBookId) {
        if (self.isAddShelf) {//书籍在书架，再次点击，从书架中移除
            [SNBookShelf removeBookShelf:self.item.news.novelBookId completed:^(BOOL success) {
                if (success) {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已删除" toUrl:nil mode:SNCenterToastModeSuccess];
                } else {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"删除失败" toUrl:nil mode:SNCenterToastModeError];
                }
            }];
        } else {//书籍没在书架，添加书籍
            [SNBookShelf addBookShelf:item.news.novelBookId hasRead:NO completed:^(BOOL success) {
                if (success) {
                    NSArray *channelList = [[SNDBManager currentDataBase] getNewsChannelList];
                    NewsChannelItem *channelItem = nil;
                    BOOL hasNovelChannel = NO;
                    for (NewsChannelItem *newsItem in channelList) {
                        if ([newsItem.channelId isEqualToString:self.item.news.channelId]) {
                            channelItem = newsItem;
                            hasNovelChannel = YES;
                            break;
                        }
                    }
                    
                    NSString *urlString = [NSString stringWithFormat:@"%@&channelSource=%@&channelStatusDelete=%@", self.item.news.novelChannelLink, [NSNumber numberWithBool:YES], kChannelDeleteFromChannelPreview];
                    NSString *toUrl = nil;
                    if (!hasNovelChannel) {
                        [[SNDBManager currentDataBase] addOrDeleteNewsChannnelToDataBase:channelItem editMode:YES];
                        [SNUtility openProtocolUrl:urlString];
                        //只在搜索的标签中，添加频道时更新频道管理界面；不影响正文页标签频道的添加(任务单 #41047 (new bug) [搜狐新闻_iOS]_5.2_频道管理：从搜索结果中添加频道，无法添加到频道栏)
                        [SNNotificationManager postNotificationName:kProcessChannelFromSearchNotification object:nil];
                        toUrl = self.item.news.novelChannelLink;
                    }
                    
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已添加" toUrl:toUrl userInfo:nil mode:SNCenterToastModeSuccess];
                } else {
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"添加失败" toUrl:nil mode:SNCenterToastModeError];
                }
            }];
        }
    }
}

- (void)report {
    [SNUtility shouldUseSpreadAnimation:NO];
    if (self.item.news.newsId) {
        if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
            return ;
        }
        if (![SNUserManager isLogin]) {
//            NSMutableDictionary *infoDic = [NSMutableDictionary dictionary];
//            [infoDic setObject:@"举报" forKey:kRegisterInfoKeyTitle];
//            NSString *tipText = NSLocalizedString(@"user_info_guide_register_tip", nil);
//            [infoDic setObject:tipText forKey:kRegisterInfoKeyText];
//            infoDic[kRegisterInfoKeyName] = @"举报";
//            [infoDic setObject:[NSNumber numberWithInteger:SNGuideRegisterTypeReport] forKey:kRegisterInfoKeyGuideType];
//            [infoDic setObject:self.item.news.newsId forKey:kRegisterInfoKeyNewsId];
//            [infoDic setObject:self.item.news.channelId forKey:kRegisterInfoKeyChannelId];
//            if ([self.item.news.newsType isEqualToString:@"64"] && self.item.news.playVid) {
//                [infoDic setObject:@"2" forKey:@"type"];
//                [infoDic setObject:self.item.news.playVid forKey:@"vid"];
//            }
//            if (self.item.cellType == SNRollingNewsCellTypeVideo ||
//                self.item.cellType == SNRollingNewsCellTypeAdDefault ||
//                self.item.cellType == SNRollingNewsCellTypeAdPicture ||
//                self.item.cellType == SNRollingNewsCellTypeAdBanner ||
//                self.item.cellType == SNRollingNewsCellTypeAppAd ||
//                self.item.cellType == SNRollingNewsCellTypeAdPhotos ||
//                self.item.cellType == SNRollingNewsCellTypeAdMixpicDownload ||
//                self.item.cellType == SNRollingNewsCellTypeAdBigpicDownload ||
//                self.item.cellType == SNRollingNewsCellTypeAdSmallpicDownload ||
//                self.item.cellType == SNRollingNewsCellTypeAdMixpicPhone ||
//                self.item.cellType == SNRollingNewsCellTypeAdBigpicPhone ||
//                self.item.cellType == SNRollingNewsCellTypeAdVideoDownload) {
//                [infoDic setObject:@"3" forKey:@"type"];
//            }
//            if (self.item.type == NEWS_ITEM_TYPE_AD) {
//                [infoDic setObject:self.item.news.link forKey:@"url"];
//            }
//            NSValue *method = [NSValue valueWithPointer:NSSelectorFromString(@"loginSuccess")];
//            [infoDic setObject:method forKey:@"method"];
//            [infoDic setObject:kLoginFromReport forKey:kLoginFromKey];
//            [SNUtility openLoginViewWithDict:infoDic];
//
//            [[SNActionSheetLoginManager sharedInstance] setNewGuideDic:infoDic];
            
            //wangshun login open
            [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//111流内举报
                [self performSelector:@selector(openReportPage) withObject:nil afterDelay:0.5];
            } Failed:nil];
            
            return;
        }
        
        [self openReportPage];
    }
}

//跳举报页面 修改 wangshun
- (void)openReportPage{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.item.news.newsId, @"newsId", nil];
    NSString *type = @"1";//普通文章页
    if ([self.item.news.newsType isEqualToString:@"64"] &&
        self.item.news.playVid) {
        type = @"2";//视频
    }
    if (self.item.cellType == SNRollingNewsCellTypeVideo ||
        self.item.cellType == SNRollingNewsCellTypeAdDefault ||
        self.item.cellType == SNRollingNewsCellTypeAdPicture ||
        self.item.cellType == SNRollingNewsCellTypeAdBanner ||
        self.item.cellType == SNRollingNewsCellTypeAppAd ||
        self.item.cellType == SNRollingNewsCellTypeAdPhotos ||
        self.item.cellType == SNRollingNewsCellTypeAdMixpicDownload ||
        self.item.cellType == SNRollingNewsCellTypeAdBigpicDownload ||
        self.item.cellType == SNRollingNewsCellTypeAdSmallpicDownload ||
        self.item.cellType == SNRollingNewsCellTypeAdMixpicPhone ||
        self.item.cellType == SNRollingNewsCellTypeAdBigpicPhone ||
        self.item.cellType == SNRollingNewsCellTypeAdVideoDownload) {
        type = @"3";//广告
    }
    if (self.item.type == NEWS_ITEM_TYPE_AD) {
        type = @"3";
    }
    if ([self.item.news isSohuFeed]) {
        type = @"5";//搜狐feed   小说4
    }
    NSString *urlString = [NSString stringWithFormat:kUrlReport,type];
    urlString = [SNUtility addParamP1ToURL:urlString];
    urlString = [NSString stringWithFormat:@"%@&newsId=%@", urlString, self.item.news.newsId];
    urlString = [NSString stringWithFormat:@"%@&channelId=%@", urlString, self.item.news.channelId];
    if ([self.item.news.newsType isEqualToString:@"64"] && self.item.news.playVid) {
        urlString = [NSString stringWithFormat:@"%@&vid=%@", urlString, self.item.news.playVid];
    }
    //如果是广告举报 需要传广告url
    if (self.item.type == NEWS_ITEM_TYPE_AD) {
        urlString = [NSString stringWithFormat:@"%@&url=%@", urlString, [self.item.news.link urlEncoded]];
    }
    [dic setObject:urlString forKey:kLink];
    [dic setObject:[NSNumber numberWithInt:ReportWebViewType]
            forKey:kUniversalWebViewType];
    [SNUtility openUniversalWebView:dic];
}

- (void)clikItemOnHalfFloatView:(NSDictionary *)dict {
    [self executeFavouriteNews:dict];
}

- (void)executeFavouriteNews:(NSDictionary *)dict {
    [self favoriteNews:dict];
}

- (BOOL)hasListenNews {
    switch (self.item.cellType) {
        case SNRollingNewsCellTypeIndividuation:
        case SNRollingNewsCellTypeWeather:
        case SNRollingNewsCellTypeSohuFeedBigPic:
        case SNRollingNewsCellTypeSohuFeedPhotos:
            return NO;
        default:
            break;
    }
    //H5的不支持听新闻功能 wangyy
    if ([self.item isH5Link]) {
        return NO;
    }
    
    //听新闻只能播放article新闻，组图新闻不再支持听新闻功能
    if (self.item.type == NEWS_ITEM_TYPE_NORMAL) {
        return YES;
    }
    
    return NO;
}

- (void)showReasonsForUninterestedView {
    if (!self.uninterestedItem) {
        if (![SNUtility getApplicationDelegate].isNetworkReachable) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        }
        return;
    }

    SNUninterestedView *uninterestedView = [[SNUninterestedView alloc] initWithUninterestedItem:self.uninterestedItem];
    CGFloat uninterestedViewH = [uninterestedView getHeight];
    uninterestedView.frame = CGRectMake(0, kAppScreenHeight - uninterestedViewH, kAppScreenWidth, uninterestedViewH);
    
    SNNewAlertView *uninterestedAlert = [[SNNewAlertView alloc] initWithContentView:uninterestedView cancelButtonTitle:nil otherButtonTitle:nil alertStyle:SNNewAlertViewStyleActionSheet];
    [uninterestedAlert show];
    
    uninterestedView.confirmBtnClickBlock = ^(NSArray *selectedReasons) {
        [uninterestedAlert dismiss];
        [self uninterestedReport:selectedReasons];
    };
}

- (void)uninterestedReport:(NSArray *)selectedReasons {
    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
        SNCCPVPage page = [self.item getCurrentPage];
        SNUserTrack *userTrack= [SNUserTrack trackWithPage:page link2:self.item.news.link];
        BOOL isJoke = NO;
        if ([self.item.news.newsType isEqualToString:@"62"]) {
            isJoke = YES;
        }
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], isJoke ? f_uninterested : f_intimenews_uninterest];
        [SNNewsReport reportADotGifWithTrack:paramString];
        
        [SNNotificationManager postNotificationName:SNToastNotificaionRollingCellUninterested object:nil];
        
        NSIndexPath *cellIndexPath = [self.item.controller.tableView indexPathForCell:self];
        NSInteger cellIndex = cellIndexPath.row;
        [SNNotificationManager postNotificationName:kDeleteNewsCellNotification object:[NSNumber numberWithInteger:cellIndex]];
        
        // 如果是广告cell 还需要通过广告sdk触发统计
        [self reportAdSDKUninterestIfNeeded];
        
        //不感兴趣request
        NSMutableArray *reasonArray = [NSMutableArray array];;
        for (SNReasonItem *reasonItem in selectedReasons) {
            NSString *reason = [NSString stringWithFormat:@"%@_%@", reasonItem.rid, reasonItem.pos];
            [reasonArray addObject:reason];
        }
        NSString *reasonStr = [reasonArray componentsJoinedByString:@","];
        NSMutableDictionary *dictData = [NSMutableDictionary dictionary];
        [dictData setObject:reasonStr forKey:@"rids"];
        
        [dictData setObject:self.item.news.newsType forKey:@"type"];
        if ([self.item.news.isRecom isEqualToString:@"1"]) {
            [dictData setObject:self.item.news.newsId forKey:@"oid"];
        } else if (isAdRecom) {
            [dictData setObject:_monitorkey forKey:@"oid"];
        } else if (self.item.type == NEWS_ITEM_TYPE_NEWS_BOOK) {
            [dictData setObject:self.item.news.newsId forKey:@"oid"];
        }
        
        //服务端：缺少参数act anroid确认取1
        [dictData setObject:[NSNumber numberWithInt:1] forKey:@"act"];
        
        //feed添加uid 参数
        if ([self.item.news isSohuFeed]) {
            [dictData setObject:self.item.news.sohuFeed.userId forKey:@"feed_user_id"];
        }
        
        [SNReasonsForUninterestedFormater requestUninterestedReportWithDic:dictData Completion:^(NSError *error, id data) {
        }];
    } else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
}

- (void)uninterested {
    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
        SNCCPVPage page = [self.item getCurrentPage];
        SNUserTrack *userTrack= [SNUserTrack trackWithPage:page link2:self.item.news.link];
        BOOL isJoke = NO;
        if ([self.item.news.newsType isEqualToString:@"62"]) {
            isJoke = YES;
        }
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], isJoke ? f_uninterested : f_intimenews_uninterest];
        [SNNewsReport reportADotGifWithTrack:paramString];

        [SNNotificationManager postNotificationName:SNToastNotificaionRollingCellUninterested object:nil];
        
        NSIndexPath *cellIndexPath = [self.item.controller.tableView indexPathForCell:self];
        NSInteger cellIndex = cellIndexPath.row;
        [SNNotificationManager postNotificationName:kDeleteNewsCellNotification object:[NSNumber numberWithInteger:cellIndex]];
        
        // 如果是广告cell 还需要通过广告sdk触发统计
        [self reportAdSDKUninterestIfNeeded];
        
        // 不感兴趣request
        [[SNNewsUninterestedService sharedInstance] uninterestedNewsWithType:self.item.news.newsType newsId:self.item.news.newsId];
    } else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
    }
}

- (void)listenNews {
    [SNNewsReport reportADotGif:@"_act=listen&_tp=news"];
    
    //lijian 2015.05.08 播放听新闻时，有视频播放就暂停
    SNTimelineSharedVideoPlayerView *timelineVideoPlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
    if([timelineVideoPlayer isPlaying]){
        [timelineVideoPlayer pause];
    }
    
    NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if ([self.item.news.newsType isEqualToString:@"62"]) {
        SNCCPVPage page = [self.item getCurrentPage];
        SNUserTrack *userTrack= [SNUserTrack trackWithPage:page
                                                     link2:self.item.news.link];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], f_joke_listen];
        [SNNewsReport reportADotGifWithTrack:paramString];
    }
    
    NSInteger curIndex = -1;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:5];
    for (NSInteger i = 0; i < self.item.dataSource.allList.count; ++i) {
        SNRollingNewsTableItem *newsItem = [self.item.dataSource.allList objectAtIndex:i];
        if (newsItem == self.item) {
            curIndex = i;
        }
        if (curIndex < 0)
            continue;
        
        if ([newsItem.news isLoadMore]) {
            continue;
        }
        
        if ([newsItem isKindOfClass:[SNRollingNewsTableItem class]] &&
            newsItem.type == NEWS_ITEM_TYPE_NORMAL) {
            //lijian 2017.08.21 在这里如果不符合听新闻的内容直接在数组制作时就进行过滤了，不在听新闻的功能接口内判断业务逻辑，这样才合理
            if (nil == newsItem.news.title
                || [newsItem.news.title isEqualToString:@""]
                || [newsItem.news.title isEqualToString:@"上次看到这里，点击刷新"]
                || [newsItem.news.title isEqualToString:@"展开，继续看今日要闻"]) {
                continue;
            }
            
            SNListenNewsItem *listenNews = [[SNListenNewsItem alloc] init];
            listenNews.newsId = newsItem.news.newsId;
            listenNews.channelId = newsItem.news.channelId;
            listenNews.title = newsItem.news.title;
            listenNews.link = newsItem.news.link;
            listenNews.type = SNListenNewsItemNews;
            [array addObject:listenNews];
        }
        else if (newsItem.type == NEWS_ITEM_TYPE_NEWS_FUNNYTEXT) {
            SNListenNewsItem *listenNews = [[SNListenNewsItem alloc] init];
            listenNews.newsId = newsItem.news.newsId;
            listenNews.channelId = newsItem.news.channelId;
            listenNews.title = newsItem.news.funnyText.content;
            listenNews.link = newsItem.news.link;
            listenNews.type = SNListenNewsItemJoke;
            [array addObject:listenNews];
        }
    }
    
    [[SNNewsSpeakerManager shareManager] showNewsSpeakerViewWithList:array];
}

- (void)reportAdSDKUninterestIfNeeded {
    if (self.item.type == NEWS_ITEM_TYPE_AD) {
        [self.item.news.newsAd reportAdNotInterest:self.item.news];
    }
    if (self.item.type == NEWS_ITEM_TYPE_APP_ARRAY || self.item.type == NEWS_TIEM_TYPE_INDIVIDUATION) {
        if ([self respondsToSelector:@selector(reportPopularizeStatUninterestInfo)]) {
            [self performSelector:@selector(reportPopularizeStatUninterestInfo)];
        }
    }
}

- (void)favoriteNews:(NSDictionary *)dict {
    NSMutableDictionary *muDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    if (self.item.expressFrom == NewsFromChannel) {
        [muDict setObject:kChannelEditionCollection forKey:kCollectionFrom];
    } else if (self.item.expressFrom == NewsFromRecommend) {
        [muDict setObject:kChannelRecomCollection forKey:kCollectionFrom];
    } else {
        [muDict setObject:kOtherCollection forKey:kCollectionFrom];
    }
    //CC统计
    SNCCPVPage page = [self.item getCurrentPage];
    SNUserTrack *userTrack= [SNUserTrack trackWithPage:page link2:nil];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], f_intimenews_fav];
    paramString = [paramString stringByAppendingFormat:@"&newsId=%@", self.item.news.newsId];
    [SNNewsReport reportADotGifWithTrack:paramString];
    
    @autoreleasepool {
        SNNewsContentFavourite *newsContentFavourite = [self getFavourite];
        [[SNMyFavouriteManager shareInstance] addOrDeleteFavourite:newsContentFavourite corpusDict:muDict];
    }
}

- (void)drawRect:(CGRect)rect {
    if (![self hideMoreButton]) {
        moreButton.hidden = NO;
        BOOL isMoreThan320 = [SNDevice sharedInstance].isMoreThan320;
        BOOL isBigerFont = [SNUtility shownBigerFont];
        if (self.item.type == NEWS_ITEM_TYPE_APP) {
            moreButton.bottom = rect.size.height - 5;
        } else {
            CGFloat bottom = 2;
            switch (self.item.cellType) {
                case SNRollingNewsCellTypeTitle:
                case SNRollingNewsCellTypeAbstrac:
                    bottom = isBigerFont? 2 : 0;
                    break;
                    
                case SNRollingNewsCellTypeRedPacket:
                case SNRollingNewsCellTypeCoupons:
                    bottom = -1;
                    break;
                //by 5.9.4 wangchuanwen modify
                //item间距调整 moreButton
                case SNRollingNewsCellTypeDefault: {
                    //图文调整，行数及屏幕改变，bottom不同
                    int gap = 0;
                    if (isBigerFont) {
                        if (isMoreThan320) {
                            gap = 2;
                        } else {
                            if (self.item.titlelineCnt > 2) {
                                gap = 2;
                            } else {
                                gap = 3;
                            }
                        }
                    } else {
                        if (isMoreThan320) {
                            if (self.item.titlelineCnt > 2) {
                                gap = 3;
                            } else {
                                gap = 2;
                            }
                        } else {
                            if (self.item.titlelineCnt > 2) {
                                gap = 1;
                            } else {
                                gap = 1;
                            }
                        }
                        
                    }
                    bottom = gap;
                }
                    break;
                case SNRollingNewsCellTypePhotos:
                case SNRollingNewsCellTypeAdPhotos:
                    bottom = 2;
                    break;
                case SNRollingNewsCellTypeAdMixpicDownload:
                case SNRollingNewsCellTypeAdMixpicPhone:
                    bottom = 1;
                    break;
                case SNRollingNewsCellTypeNewsVideo:
                    bottom = (self.item.titlelineCnt > 1) ? 5 : 4;
                    break;
                case SNRollingNewsCellTypeAdPicture:
                case SNRollingNewsCellTypeAdBigpicPhone:
                case SNRollingNewsCellTypeAdBigpicDownload:
                    bottom = (isMoreThan320?3:2);
                    break;
                case SNRollingNewsCellTypeSohuFeedBigPic:
                case SNRollingNewsCellTypeSohuFeedPhotos:
                    bottom = 4;
                    break;
                case SNRollingNewsCellTypeMatch:
                    bottom = 10;
                    break;
                case SNRollingNewsCellTypeAdBanner:
                    bottom = 3;
                    break;
                case SNRollingNewsCellTypeAdVideoDownload:
                case SNRollingNewsCellTypeVideo:
                    bottom = 4;
                    break;
                //modify end
                case SNRollingNewsCellTypeAdSmallpicDownload:
                    bottom = 51;
                    break;
                case SNRollingNewsCellTypeTrainCard:
                    bottom = rect.size.height - moreButton.height;
                    break;
                default:
                    break;
            }
            
            moreButton.bottom = rect.size.height - bottom;
        }
    } else {
        moreButton.hidden = YES;
    }
    
    //By 5.9.4 wangchuanwen add
    if (![self hideCellLine]) {
        lineView.top = rect.size.height - kCellLineHeight;
        lineView.hidden = NO;
    } else {
        lineView.hidden = YES;
    }
    //add end
}

- (void)updateTitleColor {
    //刷新已读标题颜色
}

- (void)updateImage {
    //刷新图片
}

- (void)setObject:(id)object {
    if (!object) {
        return;
    }
    //slide页切换组图后，回到频道列表后已浏览的组图新闻未显示已读标识
    self.item.news.isRead = [SNRollingNewsPublicManager isReadNewsWithNewsId:self.item.news.newsId ChannelId:self.item.news.channelId];
    
    if (self.item != object) {
        self.item = object;
        [self updateContentView];
    } else {
        if ([SNUtility customSettingChange]) {
            [self updateContentView];
        } else {
            [self updateTitleColor];
            [self updateImage];
        }
    }
    
    moreButton.left = kAppScreenWidth - kMoreButtonWidth;
}

- (void)updateContentView {
    BOOL hiddenMore = [self.item hiddenMoreButton];
    [self bringSubviewToFront:moreButton];
    //by 5.9.4 wangchuanwen add
    [self bringSubviewToFront:lineView];
    //add end
    moreButton.hidden = hiddenMore;
    [self setNeedsDisplay];
}

- (void)updateTheme {
    [super updateTheme];
    [self setNeedsDisplay];
    [moreButton updateTheme];
    //by 5.9.4 wangchuanwen add
    lineView.backgroundColor = SNUICOLOR(kThemeBg6Color);
    //add end
}

+ (void)calculateCellHeight:(SNRollingNewsTableItem *)item {
    //子类实现
}

@end
