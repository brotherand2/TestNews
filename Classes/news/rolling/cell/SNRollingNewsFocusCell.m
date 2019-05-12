//
//  SNRollingNewsFocusCell.m
//  sohunews
//
//  Created by lhp on 11/22/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNRollingNewsFocusCell.h"
#import "SNCommonNewsController.h"
#import "SNCommonNewsDatasource.h"
#import "NSCellLayout.h"

#import "SNThemeManager.h"
#import "UITableViewCell+ConfigureCell.h"
#import "SNStatisticsInfoAdaptor.h"
#import "SNRollingNewsConst.h"
#import "SNNewsAd+analytics.h"
#import "UIFont+Theme.h"

@interface SNRollingNewsFocusCell ()

@end

#define kImageViewTop                   (35 / 2)
#define kContentLeft                    (20 / 2)
#define kContentTop                     (20 / 2)

static CGFloat rowCellHeight = 0.0f;
static CGFloat rowCellHeight1 = 0.0f;

@implementation SNRollingNewsFocusCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    if (newsItem.subscribeAdObject) {
        if (rowCellHeight1 == 0.0) {
            rowCellHeight1 = roundf(kAppScreenWidth * kFocusImageRate);
        }
        return rowCellHeight1;
    }
    
    if (rowCellHeight == 0.0f) {
        rowCellHeight = roundf(kAppScreenWidth * kFocusImageRate + 7);
    }
    
    return rowCellHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        if (self.layer) {
//            NSLog(@"%@",self.subviews);
//            [self.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
//        }
        [self initFocusContentView];
    }
    return self;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if ([change[@"new"] isKindOfClass:[NSArray class]]) {
//        NSArray *sublayers = change[@"new"];
//        for (CALayer *layer in sublayers) {
//            if (layer.frame.size.height < 1) {
//                NSLog(@"%@",layer);
//            }
//        }
//    }
//}

- (void)initFocusContentView {
    int focusImageHeight = kAppScreenWidth * kFocusImageRate;
    focusImageView = [[SNCellImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, focusImageHeight)];
    [focusImageView setDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder5]];
    [self addSubview:focusImageView];
    
    topMarkView = [[UIImageView alloc] initWithImage:[UIImage themeImageNamed:@"news_topline_titlemark.png"]];
    topMarkView.frame = CGRectMake(0, 0, kAppScreenWidth, 42);
    [focusImageView addSubview:topMarkView];
    topMarkView.hidden = YES;
    
    titleMarkView = [[UIImageView alloc] initWithImage:[UIImage themeImageNamed:@"news_headline_titlemark.png"]];
    titleMarkView.frame = CGRectMake(0, 0, kAppScreenWidth, 42);
    titleMarkView.bottom = focusImageHeight;
    [focusImageView addSubview:titleMarkView];
    
    UIFontSizeType fontType = UIFontSizeTypeD;
    if ([[SNDevice sharedInstance] isPlus]) {
        fontType = UIFontSizeTypeE;
    }
    CGFloat fontSize = [UIFont fontSizeWithType:fontType] ;
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_LEFT,0,kAppScreenWidth - 2*CONTENT_LEFT,fontSize + 1)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [SNUtility getNewsTitleFont];
    titleLabel.bottom = focusImageHeight -12;
    [focusImageView addSubview:titleLabel];
    
    UIImage *videoImage = [UIImage imageNamed:@"icohome_focus_videosmall_v5.png"];
    int videoBottom = focusImageView.bottom - VIDEO_ICON_WIDTH - 11;
    videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT,videoBottom,VIDEO_ICON_WIDTH, VIDEO_ICON_WIDTH)];
    videoIcon.image = videoImage;
    videoIcon.alpha = themeImageAlphaValue();
    videoIcon.hidden = YES;
    [self addSubview:videoIcon];
    
    adIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, videoBottom + 4, 29, 14)];
    adIcon.image = [UIImage themeImageNamed:@"icohome_ad_Label_v5.png"];
    adIcon.hidden = YES;
    [self addSubview:adIcon];
    
    adTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 14)];
    adTitleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeA];
    adTitleLabel.backgroundColor = [UIColor clearColor];
    adTitleLabel.textColor = [UIColor whiteColor];
    adTitleLabel.textAlignment = NSTextAlignmentCenter;
    [adIcon addSubview:adTitleLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openNews)];
    [focusImageView addGestureRecognizer:tap];
    
    moreButton.hidden = YES;
}

- (void)updateContentView {
    [super updateContentView];
    UIImage *defaultImage = [UIImage themeImageNamed:kThemeImgPlaceholder5];
    [focusImageView updateImageWithUrl:self.item.news.picUrl defaultImage:defaultImage showVideo:NO];
    videoIcon.hidden = ![self.item hasVideo];
    titleLabel.text = self.item.news.title;
    titleLabel.width = [self.item hasVideo] ? kAppScreenWidth - 2 * CONTENT_LEFT - 25 : kAppScreenWidth - 2 * CONTENT_LEFT;
    titleLabel.font = [SNUtility getNewsTitleFont];
    titleLabel.left = [self.item hasVideo] ? CONTENT_LEFT + VIDEO_ICON_WIDTH + 7: CONTENT_LEFT;
    adTitleLabel.text = self.item.news.iconText;
    if (self.item.type == NEWS_ITEM_TYPE_AD && !self.item.isSubscribeAd) {
        adIcon.hidden = NO;
        adIcon.right = kAppScreenWidth - CONTENT_LEFT;
        titleLabel.width =  kAppScreenWidth - 2*CONTENT_LEFT - 25;
        adIcon.alpha = themeImageAlphaValue();
    } else {
        adIcon.hidden = YES;
    }
}

- (void)updateTheme {
    [super updateTheme];
    [focusImageView updateTheme];
    [focusImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder5]];
    videoIcon.alpha = themeImageAlphaValue();
    videoIcon.hidden = ![self.item hasVideo];
    adIcon.image = [UIImage themeImageNamed:@"icohome_ad_Label_v5.png"];
    adIcon.alpha = themeImageAlphaValue();
    titleLabel.width = [self.item hasVideo] ? kAppScreenWidth - 2 * CONTENT_LEFT - 25 : kAppScreenWidth - 2 * CONTENT_LEFT;
}

- (void)updateImage {
    UIImage *defaultImage = [UIImage themeImageNamed:kThemeImgPlaceholder5];
    [focusImageView updateImageWithUrl:self.item.news.picUrl defaultImage:defaultImage showVideo:NO];
}

- (void)reportPopularizeClick {
    SNStatClickInfo *info = [[SNStatClickInfo alloc] init];
    [self updateInfoWithData:info];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}

- (void)updateInfoWithData:(SNStatInfo *)info {
    if (self.item.subscribeAdObject.adId.length > 0) {
        info.adIDArray = @[self.item.subscribeAdObject.adId];
    }
    info.objLabel = SNStatInfoUseTypeOutTimelinePopularize;
    info.objType = kObjTypeOfRecommendPosionInMySubBanner;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
}

- (void)openNews {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kSpreadAnimationStartKey]) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setDouble:100.0 forKey:kRememberCellOriginYInScreen];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SNUtility shouldUseSpreadAnimation:YES];
    //订阅流广告点击统计
    if (self.item.subscribeAdObject &&
        self.item.type == NEWS_ITEM_TYPE_AD) {
        [self reportPopularizeClick];
    }
    
    // 广告点击曝光
    if (self.item.type == NEWS_ITEM_TYPE_AD) {
        [self.item.news.newsAd reportAdClick:self.item.news];
    }
    
    [item.controller cacheCellIndexPath:self];
    if (item.news.newsType != nil && [SNCommonNewsController supportContinuation:item.news.newsType]) {
        NSMutableDictionary *dic = nil;
        if (item.dataSource) {
            dic = [item.dataSource getContentDictionary:item.news];
        }
        [dic setObject:kChannelEditionNews forKey:kNewsFrom];
        
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:urlAction];
    } else if(item.news.link.length > 0) {
        if ([item.news.link startWith:kProtocolVideo]) {//二代协议视频: video://
            NSMutableDictionary *query = [NSMutableDictionary dictionary];
            //判断此视频是否已离线，已离线则把视频对象进行离线播放
            SNVideoData *offlinePlayVideo = [self getDownloadVideoIfNeededWithLink2:item.news.link];
            if (!!offlinePlayVideo) {
                query[kDataKey_TimelineVideo] = offlinePlayVideo;
            }
            query[kRollingNewsVideoPosition] = @(SNRollingNewsVideoPosition_NormalVideoLink2);
            [SNUtility openProtocolUrl:item.news.link context:query];
        } else {
            [SNUtility openProtocolUrl:item.news.link];
        }
    }
    
    //设置数据库已读
    NSString *newsId = self.item.news.newsId;
    NSString *channel = self.item.news.channelId;
    if (channel != nil && newsId != nil)
        [SNRollingNewsPublicManager saveReadNewsWithNewsId:newsId ChannelId:channel];
    //内存已读
    self.item.news.isRead = YES;
}

- (SNVideoData *)getDownloadVideoIfNeededWithLink2:(NSString *)link2 {
    NSString *vid = [[SNUtility parseLinkParams:link2] stringValueForKey:@"vid" defaultValue:nil];
    SNVideoDataDownload *downloadVideo = [[SNDBManager currentDataBase] queryDownloadVideoByVID:vid];
    SNVideoData *offlinePlayVideo = [[SNDBManager currentDataBase] getOfflinePlayVideoByVid:vid];
    NSString *localVideoRelativePath = downloadVideo.localRelativePath;
    if (localVideoRelativePath.length > 0) {
        NSString *localVideoAbsolutePath = [[SNVideoDownloadConfig rootDir] stringByAppendingPathComponent:localVideoRelativePath];
        offlinePlayVideo.sources = [NSMutableArray arrayWithObject:localVideoAbsolutePath];
    }
    return offlinePlayVideo;
}

@end
