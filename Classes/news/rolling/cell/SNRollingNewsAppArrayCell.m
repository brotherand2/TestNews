//
//  SNRollingNewsAppArrayCell.m
//  sohunews
//
//  Created by chenhong on 14-6-17.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsAppArrayCell.h"
#import "SNImageView.h"
#import "SNStatisticsManager.h"
#import "SNNewsAd+analytics.h"

#define kPublicImageViewWidth       30
#define kImageViewTop               17
#define kImageToTitle               7
#define kTitleFont                  11.0f
#define kAbstractFont               10.0f

@interface SNAppContentView : UIView
@property (nonatomic, weak) SNRollingNewsAppArrayCell *cell;
@property (nonatomic, strong) SNImageView *publicImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *abstractLabel;
@property (nonatomic, strong) SNNewsApp *app;
@end


@implementation SNAppContentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initSubViews];
        
        UIButton *openLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [openLinkButton setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [openLinkButton addTarget:self action:@selector(loadApp) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:openLinkButton];
    }
    return self;
}

- (void)initSubViews {
    _publicImageView = [[SNImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, kImageViewTop, kPublicImageViewWidth, kPublicImageViewWidth)];
    _publicImageView.backgroundColor = [UIColor clearColor];
    _publicImageView.alpha = themeImageAlphaValue();
    [self addSubview:_publicImageView];
    
    int titleWidth = kAppScreenWidth - 3 * CONTENT_LEFT - 2 * kPublicImageViewWidth - 2 * kImageToTitle - 18;
    int titleLeft = CONTENT_LEFT + kPublicImageViewWidth + kImageToTitle;
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft, kImageViewTop, titleWidth, kThemeFontSizeB+2)];
    _titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    [self addSubview:_titleLabel];
    
    _abstractLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft, 21, titleWidth, kTitleFont+2)];
    _abstractLabel.font = [UIFont systemFontOfSize:kTitleFont];
    _abstractLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    _abstractLabel.numberOfLines = 2;
    _abstractLabel.backgroundColor = [UIColor clearColor];
    _abstractLabel.bottom = kImageViewTop + kPublicImageViewWidth;
    [self addSubview:_abstractLabel];
}

- (void)updateWithApp:(SNNewsApp *)app {
    self.app = app;
    _titleLabel.text = app.appName;
    _abstractLabel.text = app.appDesc;
    [_publicImageView loadImageWithUrl:app.appIcon
                          defaultImage:[UIImage imageNamed:kThemeImgPlaceholder1]];
}

- (void)loadApp {
    [self statPopularizeClick];
    
    if (self.app.downloadLink.length > 0) {
        [SNUtility openProtocolUrl:self.app.downloadLink];
    }
}

//统计搜狐新闻投放广告(多app下载换量)的点击
- (void)statPopularizeClick {
    if ([_cell respondsToSelector:@selector(reportPopularizeStatClickInfo:)]) {
        [_cell reportPopularizeStatClickInfo:self.app];
    }
}

- (void)updateTheme {
    _publicImageView.alpha = themeImageAlphaValue();
    [_publicImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder1]];
    _titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    _abstractLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
}

@end

#pragma mark - SNAppContainerView

@interface SNAppContainerView : UIView
@property (nonatomic, weak) SNRollingNewsAppArrayCell *cell;

- (void)initSubViews;
- (void)updateWithApps:(NSArray *)apps;

@end

@implementation SNAppContainerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg2Color];
    }
    return self;
}

- (void)initSubViews {
}

- (void)updateWithApps:(NSArray *)apps {
}

- (void)updateTheme {
    self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg2Color];
}

@end

#pragma mark - SNAppContentViewForOne

@interface SNAppContentViewForOne : SNAppContainerView {
    UIButton *downloadBtn;
}

@property (nonatomic, strong) SNAppContentView *contentView;

@end

@implementation SNAppContentViewForOne
@synthesize contentView;

- (void)initSubViews {
    CGRect contentRect = CGRectMake(0, 0, self.width, self.height);
    contentView = [[SNAppContentView alloc] initWithFrame:contentRect];
    contentView.cell = self.cell;
    contentView.abstractLabel.numberOfLines = 1;
    [self addSubview:contentView];
    
    // 下载图标
    downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadBtn.bounds = CGRectMake(0, 0, kPublicImageViewWidth, kPublicImageViewWidth);
    [downloadBtn setImage:[UIImage imageNamed:@"icohome_download_v5.png"] forState:UIControlStateNormal];
    [downloadBtn setImage:[UIImage imageNamed:@"icohome_downloadpress_v5.png"] forState:UIControlStateHighlighted];
    downloadBtn.right = self.width - 18;
    downloadBtn.top = kImageViewTop;
    [downloadBtn addTarget:self action:@selector(openLink) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:downloadBtn];
}

- (void)updateWithApps:(NSArray *)apps {
    if (apps.count >= 1) {
        SNNewsApp *app = (SNNewsApp *)apps[0];
        [contentView updateWithApp:app];
    }
}

- (void)openLink {
    [contentView loadApp];
}

- (void)updateTheme {
    [super updateTheme];
    [contentView updateTheme];
    [downloadBtn setImage:[UIImage imageNamed:@"icohome_download_v5.png"] forState:UIControlStateNormal];
    [downloadBtn setImage:[UIImage imageNamed:@"icohome_downloadpress_v5.png"] forState:UIControlStateHighlighted];
}

@end


#pragma mark - SNAppContentViewForTwo

@interface SNAppContentViewForTwo : SNAppContainerView
@property (nonatomic, strong) SNAppContentView *leftContentView;
@property (nonatomic, strong) SNAppContentView *rightContentView;
@end

@implementation SNAppContentViewForTwo
@synthesize leftContentView;
@synthesize rightContentView;

- (void)initSubViews {
    CGRect leftContentRect = CGRectMake(0, 0, self.width / 2, self.height);
    CGRect rightContentRect = CGRectMake(self.width / 2 + 1, 0, self.width / 2, self.height);
    int titleWidth = self.width / 2 - CONTENT_LEFT - kPublicImageViewWidth - 2 * kImageToTitle;
    int titleLeft = CONTENT_LEFT + kPublicImageViewWidth + kImageToTitle;
    
    leftContentView = [[SNAppContentView alloc] initWithFrame:leftContentRect];
    leftContentView.cell = self.cell;
    leftContentView.titleLabel.hidden = YES;
    leftContentView.abstractLabel.frame = CGRectMake(titleLeft, kImageViewTop, titleWidth, kPublicImageViewWidth);
    [self addSubview:leftContentView];
    
    rightContentView = [[SNAppContentView alloc] initWithFrame:rightContentRect];
    rightContentView.cell = self.cell;
    rightContentView.titleLabel.hidden = YES;
    rightContentView.abstractLabel.frame = CGRectMake(titleLeft, kImageViewTop, titleWidth, kPublicImageViewWidth);
    [self addSubview:rightContentView];
}

- (void)updateWithApps:(NSArray *)apps {
    if (apps.count >= 2) {
        [leftContentView updateWithApp:apps[0]];
        [rightContentView updateWithApp:apps[1]];
    }
}

- (void)updateTheme {
    [super updateTheme];
    [leftContentView updateTheme];
    [rightContentView updateTheme];
}

@end

#pragma mark - SNAppContentViewForThree

@interface SNAppContentViewForThree : SNAppContainerView
@property (nonatomic, strong) SNAppContentView *leftContentView;
@property (nonatomic, strong) SNAppContentView *middleContentView;
@property (nonatomic, strong) SNAppContentView *rightContentView;
@end


@implementation SNAppContentViewForThree
@synthesize leftContentView;
@synthesize middleContentView;
@synthesize rightContentView;

- (void)initSubViews {
    int contentWidth = self.width / 3;
    CGRect leftContentRect = CGRectMake(0, 0, contentWidth, self.height);
    CGRect middleContentRect = CGRectMake(contentWidth, 0, contentWidth, self.height);
    CGRect rightContentRect = CGRectMake(2*contentWidth, 0, contentWidth, self.height);
    
    leftContentView = [[SNAppContentView alloc] initWithFrame:leftContentRect];
    leftContentView.cell = self.cell;
    leftContentView.publicImageView.top = 13;
    leftContentView.publicImageView.centerX = contentWidth / 2;
    leftContentView.titleLabel.hidden = YES;
    leftContentView.abstractLabel.frame = CGRectMake(2, leftContentView.publicImageView.bottom + 6, 14 * 2 + kPublicImageViewWidth, kThemeFontSizeB + 2);
    leftContentView.abstractLabel.textAlignment = NSTextAlignmentCenter;
    leftContentView.abstractLabel.centerX = leftContentView.publicImageView.centerX;
    [self addSubview:leftContentView];
    
    middleContentView = [[SNAppContentView alloc] initWithFrame:middleContentRect];
    middleContentView.cell = self.cell;
    middleContentView.publicImageView.top = 13;
    middleContentView.publicImageView.centerX = contentWidth / 2;
    middleContentView.titleLabel.hidden = YES;
    middleContentView.abstractLabel.frame = CGRectMake(2, middleContentView.publicImageView.bottom+6, middleContentView.width-2*2, kThemeFontSizeB+2);
    middleContentView.abstractLabel.textAlignment = NSTextAlignmentCenter;
    middleContentView.abstractLabel.centerX = middleContentView.publicImageView.centerX;
    [self addSubview:middleContentView];
    
    rightContentView = [[SNAppContentView alloc] initWithFrame:rightContentRect];
    rightContentView.cell = self.cell;
    rightContentView.publicImageView.top = 13;
    rightContentView.publicImageView.centerX = contentWidth / 2;
    rightContentView.titleLabel.hidden = YES;
    rightContentView.abstractLabel.frame = CGRectMake(2, rightContentView.publicImageView.bottom + 6, 14 * 2 + kPublicImageViewWidth, kThemeFontSizeB + 2);
    rightContentView.abstractLabel.textAlignment = NSTextAlignmentCenter;
    rightContentView.abstractLabel.centerX = rightContentView.publicImageView.centerX;
    [self addSubview:rightContentView];
}

- (void)updateWithApps:(NSArray *)apps {
    if (apps.count >= 3) {
        SNNewsApp *leftApp = (SNNewsApp *)apps[0];
        [leftContentView updateWithApp:leftApp];
        leftContentView.abstractLabel.text = leftApp.appName;
        
        SNNewsApp *middleApp = (SNNewsApp *)apps[1];
        [middleContentView updateWithApp:middleApp];
        middleContentView.abstractLabel.text = middleApp.appName;
        
        SNNewsApp *rightApp = (SNNewsApp *)apps[2];
        [rightContentView updateWithApp:rightApp];
        rightContentView.abstractLabel.text = rightApp.appName;
    }
}

- (void)updateTheme {
    [super updateTheme];
    [leftContentView updateTheme];
    [middleContentView updateTheme];
    [rightContentView updateTheme];
}

@end

#pragma mark - SNAppContentViewForFour
@interface SNAppContentViewForFour : SNAppContainerView {
    SNAppContentView *appView[4];
}

@end

@implementation SNAppContentViewForFour

- (void)initSubViews {
    CGFloat left = 0;
    int contentWidth = self.width / 4;
    CGRect titleFrame = CGRectMake(2, 0, contentWidth, kThemeFontSizeB + 2);
    CGRect frame = CGRectMake(left, 0, contentWidth, self.height);
    
    for (int i = 0; i < 4; ++i) {
        frame.origin = CGPointMake(left, 0);
        appView[i] = [[SNAppContentView alloc] initWithFrame:frame];
        left += contentWidth;
        
        appView[i].cell = self.cell;
        appView[i].publicImageView.top = 13;
        appView[i].publicImageView.centerX = contentWidth / 2;
        appView[i].titleLabel.hidden = YES;
        appView[i].abstractLabel.frame = titleFrame;
        appView[i].abstractLabel.textAlignment = NSTextAlignmentCenter;
        appView[i].abstractLabel.top = appView[i].publicImageView.bottom + 6;
        appView[i].abstractLabel.centerX = appView[i].publicImageView.centerX;
        [self addSubview:appView[i]];
    }
}

- (void)updateWithApps:(NSArray *)apps {
    for (int i = 0; i < 4 && i < apps.count; ++i) {
        SNNewsApp *app = (SNNewsApp *)apps[i];
        [appView[i] updateWithApp:app];
        appView[i].abstractLabel.text = app.appName;
    }
}

- (void)updateTheme {
    [super updateTheme];
    for (int i = 0; i < 4; i++) {
        [appView[i] updateTheme];
    }
}

@end


#pragma mark - SNRollingNewsAppArrayCell
@interface SNRollingNewsAppArrayCell() {
    SNAppContainerView *contentView;
    BOOL isFristNews;
}
@end

#define kAppCellHeight      (220 / 2)
#define kContentHeight      (126 / 2)

@implementation SNRollingNewsAppArrayCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    return kAppCellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = NO;
    }
    return self;
}

- (void)initContentView {
    NSInteger cnt = self.item.news.appArray.count;
    cnt = MIN(cnt, 2);
    CGRect contentRect = CGRectMake(CONTENT_LEFT, 15, kAppScreenWidth - 2 * CONTENT_LEFT, kContentHeight);
    switch (cnt) {
        case 1:
            contentView = [[SNAppContentViewForOne alloc] initWithFrame:contentRect];
            break;
        case 2:
            contentView = [[SNAppContentViewForTwo alloc] initWithFrame:contentRect];
            break;
        case 3:
            contentView = [[SNAppContentViewForThree alloc] initWithFrame:contentRect];
            break;
        case 4:
            contentView = [[SNAppContentViewForFour alloc] initWithFrame:contentRect];
            break;
        default:
            contentView = [[SNAppContentViewForFour alloc] initWithFrame:contentRect];
            break;
    }

    contentView.cell = self;
    [contentView initSubViews];
    [self addSubview:contentView];
}

- (void)updateTheme {
    [super updateTheme];
    [contentView updateTheme];
}

- (void)setObject:(id)object {
    NSInteger oldCnt = self.item.news.appArray.count;
    [super setObject:object];
    NSInteger cnt = self.item.news.appArray.count;
    if (oldCnt != cnt) {
        [contentView removeFromSuperview];
        if (cnt > 0) {
            [self initContentView];
        }
    }
    [self updatePublicContent];
}

- (void)updatePublicContent {
    if (self.item.news.appArray.count > 0) {
        [contentView updateWithApps:self.item.news.appArray];
    }
}

/**
 * 上传搜狐新闻投放的多app换量广告的曝光数据
 *
 *  @return 搜狐新闻投放的多app换量广告的曝光数据
 */
- (void)reportPopularizeStatExposureInfo {
    //当前频道id和统计模版id不一致返回
    if (![self.item.news.channelId isEqualToString:[[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif]]) {
        return;
    }
    
    if (self.item.news.hasStatistics) {
        return;
    }
    
    //不需要统计搜狐投放的广告则返回空的统计数据
    if (self.item.news.statsType != SNRollingNewsStatsType_ShnAdStat) {
        return;
    }
    
    SNStatExposureInfo *info = [[SNStatExposureInfo alloc] init];
    [self updateInfoWithData:info];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    self.item.news.hasStatistics = YES;
}

/**
 * 上传搜狐新闻投放的多app换量广告的点击数据
 *
 *  @return 搜狐新闻投放的多app换量广告的点击数据
 */
- (void)reportPopularizeStatClickInfo:(SNNewsApp *)newsApp {
    SNStatClickInfo *info = [[SNStatClickInfo alloc] init];
    if (newsApp.adID.length > 0) {
        info.adIDArray = @[newsApp.adID];
    }
    info.objLabel = SNStatInfoUseTypeTimelinePopularize;
    info.token = item.news.token;
    info.objType = item.news.templateType;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
    info.objFromId = item.news.channelId;
    info.itemspaceid = item.news.newsAd.itemSpaceId;
    info.monitorkey = item.news.newsAd.monitorkey;
    info.gbcode = item.news.newsAd.gbcode;
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}

- (void)reportPopularizeStatUninterestInfo {
    SNStatUninterestedInfo *info = [[SNStatUninterestedInfo alloc] init];
    [self updateInfoWithData:info];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}

- (void)updateInfoWithData:(SNStatInfo *)info {
    NSMutableArray *appAdIDArray = [NSMutableArray array];
    for (SNNewsApp *newsApp in self.item.news.appArray) {
        NSString *adID = newsApp.adID;
        if (adID.length > 0) {
            [appAdIDArray addObject:adID];
        }
    }
    info.adIDArray = appAdIDArray;
    info.objLabel = SNStatInfoUseTypeTimelinePopularize;
    info.token = item.news.token;
    info.objType = item.news.templateType;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
    info.objFromId = item.news.channelId;
    info.itemspaceid = item.news.newsAd.itemSpaceId;
    info.monitorkey = item.news.newsAd.monitorkey;
    info.gbcode = item.news.newsAd.gbcode;
}

@end
