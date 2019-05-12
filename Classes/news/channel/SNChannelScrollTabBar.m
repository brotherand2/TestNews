//
//  SNChannelScrollTabBar.m
//  sohunews
//
//  Created by Cong Dan on 4/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNChannelScrollTabBar.h"
#import "SNScrollTabBarDataSourceWrapper.h"
#import "Toast+UIView.h"
#import "SNChannelManageContants.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNVideoAdContext.h"
#import "NSCellLayout.h"
#import "SNNewsNotificationManager.h"
#import "SNRollingNewsPublicManager.h"
#import "SNBubbleBadgeService.h"
#import "NSAttributedString+Attributes.h"
#import "SNCheckManager.h"
#import "SNRollingNewsViewController.h"
#import "SNDynamicPreferences.h"
#import "SNSearchWebViewController.h"
#import "SNUserLocationManager.h"
#import "SNUserManager.h"
#import "SNSpecialActivity.h"
#import "SNNewsFullscreenManager.h"

#define kTabMargin                  (10.0f)
#define kPadding                    (34 / 2)
#define kChannelSeparatorHeight     (26 / 2)
#define kBottomMarkTag              (666)

#define kEditButtonWidth            (88 / 2)
#define kEditButtonSideMargin       (13 / 2)
#define kEditButtonSpacing          (10 / 2)

#define kSearchButtonWidth          (64 / 2 + 10)
#define kSearchButtonHeight         (64 / 2 + 15)

#define kSearchButtonBubbleTag      (100)

#define kUnReadImageViewWidth       ((kAppScreenWidth > 375) ? 18/3 : 10/2)
#define kUnReadImageViewTop         ((kAppScreenWidth > 375) ? 38/3 : 23/2)

#define kPopOverViewWidth ((kAppScreenWidth > 375) ? 900.0/3 : ((kAppScreenWidth == 320) ? 570.0/2 : 580.0/2))
#define kPopOverViewHeight ((kAppScreenWidth > 375) ? 182.0/3 : ((kAppScreenWidth == 320) ? 100.0/2 : 105.0/2))
#define kPopOverViewOriginX ((kAppScreenWidth > 375) ? (kAppScreenWidth - 20.0) : ((kAppScreenWidth == 320) ? (kAppScreenWidth - 28.0) : (kAppScreenWidth - 28.0)))

@interface SNChannelTitleLabel : UILabel {
    UIImageView *markImageView;
    UIImageView *searchBgImageView;
    UIImageView *searchItemImageView;
    UILabel *searchItemLabel;
    SNSearchWebViewController *_searchWebViewController;
}

@property (nonatomic, strong) SNSearchWebViewController *searchWebViewController;

@end

@implementation SNChannelTitleLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont systemFontOfSize:kThemeFontSizeE];
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        self.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color];
        
        markImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, 42, 114, 2)];
        UIImage *markImage = [UIImage themeImageNamed:@"icotitlebar_redstripe_v5.png"];
        markImage = [markImage stretchableImageWithLeftCapWidth:markImage.size.width/2 topCapHeight:markImage.size.height/2];
        markImageView.image = markImage;
        markImageView.centerX = frame.size.width/2;
        [self addSubview:markImageView];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)setTitleString:(NSString *)title {
    if (title.length > 0) {
        self.text = title;
        CGSize titleSize = [title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        self.width = titleSize.width;
        self.left = CONTENT_LEFT;
        [self setMarkImageWidth:titleSize.width + 6];
        markImageView.alpha = 1.0;
    } else {
        //creat search frame
        [self creatSearchFrame];
        self.text = nil;
        markImageView.alpha = 0;
    }
}

- (void)creatSearchFrame {
    CGRect rect = CGRectMake(0, 0, kAppScreenWidth - kIcoNormalSettingCloseButtonWidth, self.height);
    if (!searchBgImageView) {
        searchBgImageView = [[UIImageView alloc] initWithFrame:rect];
        searchBgImageView.backgroundColor = SNUICOLOR(kThemeBg5Color);
        self.userInteractionEnabled = YES;
        searchBgImageView.userInteractionEnabled = YES;
        [self addSubview:searchBgImageView];
        
        UITapGestureRecognizer *tapSearchBgImageView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSearchBgImageViewAction:)];
        [searchBgImageView addGestureRecognizer:tapSearchBgImageView];
        
        searchBgImageView.alpha = 0;
        [UIView animateWithDuration:0.6 animations:^(void) {
            searchBgImageView.alpha = 0.95;
        } completion:^(BOOL finished) {
        }];
    } else {
        searchBgImageView.alpha = 0.95;
    }
    
    if (!searchItemImageView) {
        UIImage *searchImage = [UIImage imageNamed:@"icopersonal_search_v5.png"];
        CGSize searchSize = CGSizeMake(21.0, 21.0); //searchImage.size; v5.2.0
        searchItemImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, searchSize.width, searchSize.height)];
        searchItemImageView.image = searchImage;
        searchItemImageView.top = (rect.size.height-searchSize.height)/2;
        searchItemImageView.left = kIcoNormalSettingLeft;
        [searchBgImageView addSubview:searchItemImageView];
    }
    
    if (!searchItemLabel) {
        searchItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, rect.size.width - searchItemImageView.right - kIcoNormalSettingSearchIconRightDistance, rect.size.height)];
        searchItemLabel.left = searchItemImageView.right + kIcoNormalSettingSearchIconRightDistance;
        searchItemLabel.backgroundColor = [UIColor clearColor];
        searchItemLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        searchItemLabel.text = kChannelBottomSearchText;
        searchItemLabel.textColor = SNUICOLOR(kThemeText3Color);
        [searchBgImageView addSubview:searchItemLabel];
    }
}
//进入搜索页面
- (void)tapSearchBgImageViewAction:(UITapGestureRecognizer *)gesture {
    // search模块的初始化放在这里 & self.superview.superview 太奇怪
    self.searchWebViewController = [[SNSearchWebViewController alloc] initWithNibName:nil bundle:nil];
    
    _searchWebViewController.refertype = SNSearchReferChannel;
    
    [self.superview.superview addSubview:_searchWebViewController.view];
    
    [_searchWebViewController beginSearchAndreloadHotWords];
    
    _searchWebViewController.view.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
    [_searchWebViewController.view layoutIfNeeded];
}

- (void)setMarkImageWidth:(int) markWidth {
    [UIView animateWithDuration:0.3
                     animations:^(void) {
        markImageView.width = markWidth;
        markImageView.centerX = self.width / 2;
    }];
}

- (void)updateTheme {
    searchBgImageView.backgroundColor = SNUICOLOR(kThemeBg5Color);
    searchItemImageView.image = [UIImage imageNamed:@"icopersonal_search_v5.png"];
    searchItemLabel.textColor = SNUICOLOR(kThemeText3Color);
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end


@interface SNChannelScrollLogoButton:UIButton {
    UIImageView *_logoImageView;
    UIImageView *_coverImageView;
    UIView * _themeMaskView;
}

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIImageView *coverImageView;

- (void)loadImageWithUrl:(NSString *)url;
- (void)updateTheme;
- (void)resetNormalColor:(BOOL)isNormal;
@end

@implementation SNChannelScrollLogoButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        UIImage *coverImage = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"bgtitlebar_maskleft_v5.png" ImageSize:CGSizeMake(96 / 2, 92 / 2)];
        _coverImageView = [[UIImageView alloc] initWithImage:coverImage];
        _coverImageView.frame = CGRectMake(0, -2, 96 / 2, 92 / 2);
        [self addSubview:_coverImageView];
        
        UIDevicePlatform device = [[UIDevice currentDevice] platformTypeForScreen];
        
        //logo
        CGFloat logoHeight =( UIDevice6PlusiPhone == device)? (63 / 3) : 21;
        CGFloat logoWidth =( UIDevice6PlusiPhone == device)? (63 / 3) : 21;
        CGFloat logoLeft = (UIDevice6PlusiPhone == device) ? (42 / 3) : CONTENT_LEFT;
        CGFloat logoTop = (frame.size.height - logoHeight) / 2;
        
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(logoLeft,
                                                                       logoTop,
                                                                       logoWidth,
                                                                       logoHeight)];
        _logoImageView.backgroundColor = [UIColor clearColor];
        _logoImageView.image = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"icotitlebar_sohu_v5.png" ImageSize:CGSizeMake(logoWidth, logoHeight)];
//        _logoImageView.alpha = themeImageAlphaValue();
        [self updateTheme];
        _logoImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLogoImageView)];
        [_logoImageView addGestureRecognizer:tapGes];
        [self addSubview:_logoImageView];
        
        if ([SNNewsFullscreenManager manager].isFullscreenMode && [[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"]) {
            //当前为全屏模式并且为首页频道，使用白色状态条
            [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:YES];
        }else {
            [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:NO];
        }
    }
    return self;
}

- (void)clickLogoImageView {
    [SNRollingNewsPublicManager sharedInstance].isRollingEditNewsShow = YES;
    [SNRollingNewsPublicManager sharedInstance].isRecommendAfterEditNews = NO;
    //不管在那个tab，点击都回到新闻tab头条流，并刷新
    UIViewController *topController = [TTNavigator navigator].topViewController;
    [SNUtility popToTabViewController:topController];

    //tab切换到新闻
    [SNRollingNewsPublicManager sharedInstance].userAction = SNRollingNewsUserSohuIconRefresh;
    [[[SNUtility getApplicationDelegate] appTabbarController].tabbarView forceClickAtIndex:TABBAR_INDEX_NEWS];
    //栏目切换到焦点
    [SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil];
    
    [SNNewsReport reportADotGif:@"act=cc&page=1&topage=1&fun=36"];
    
    [SNRollingNewsPublicManager sharedInstance].isHomePage = YES;
}

- (void)loadImageWithUrl:(NSString *)url {
    if (url && ![url isEqualToString:@""]) {
        [_logoImageView sd_setImageWithURL:[NSURL URLWithString:url]
                       placeholderImage:[UIImage themeImageNamed:@"icotitlebar_sohu_v5.png"]];
    }
}

- (void)updateTheme {
    _coverImageView.image = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"bgtitlebar_maskleft_v5.png" ImageSize:_coverImageView.frame.size];
    
    _logoImageView.image = [UIImage themeImageNamed:@"icotitlebar_sohu_v5.png"];
    if ([SNThemeManager sharedThemeManager].isNightTheme) {
        if (!_themeMaskView) {
            _themeMaskView = [[UIView alloc] initWithFrame: _logoImageView.bounds];
            _themeMaskView.layer.cornerRadius = 3;
            _themeMaskView.clipsToBounds = YES;
            _themeMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
            [_logoImageView addSubview:_themeMaskView];
        }
    }else{
        [_themeMaskView removeFromSuperview];
        _themeMaskView = nil;
    }
//    _logoImageView.alpha = themeImageAlphaValue();
}

- (void)resetNormalColor:(BOOL)isNormal {
    UIImage *image = nil;
    if (isNormal) {
        image = [UIImage imageNamed:@"bgtitlebar_maskleft_v5.png"];
    }
    else {
        image = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"bgtitlebar_maskleft_v5.png" ImageSize:_coverImageView.frame.size];
    }
    _coverImageView.image = image;
}

@end

@implementation SNChannelScrollTabBar

@synthesize tabItems = _tabItems;
@synthesize tabViews = _tabViews;
@synthesize selectedTabIndex = _selectedTabIndex;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize moreButton = _moreButton;
@synthesize isReleased;
@synthesize observeScrollEnable = _observeScrollEnable;
@synthesize editModeTitleString = _editModeTitleString;
@synthesize needChannelEditModeButton = _needChannelEditModeButton;
@synthesize logoLink = _logoLink;

- (id)initWithChannelId:(NSString *)channelId showLogo:(BOOL)isShow {
    showLogo = isShow;
    
    self = [self initWithChannelId:channelId];
    
    return self;
}

+ (CGFloat)channelBarHeight {
    if (UIDevice6PlusiPhone == [[UIDevice currentDevice] platformTypeForScreen]) {
        return 132 / 3 + kSystemBarHeight;
    } else {
        return (88 / 2 + kSystemBarHeight);
    }
}

- (id)initWithChannelId:(NSString *)channelId {
	self = [super initWithFrame:CGRectMake(0, 0, kAppScreenWidth, [SNChannelScrollTabBar channelBarHeight])];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _selectedTabIndex = NSIntegerMax;
        _channelId = [channelId copy];
        [[SNVideoAdContext sharedInstance] setCurrentChannelID:_channelId];
        _tabViews = [[NSMutableArray alloc] init];
        [self initAllSubviews];
        [SNNotificationManager addObserver:self
                                  selector:@selector(handleThemeChangeNotify:)
                                      name:kThemeDidChangeNotification
                                    object:nil];
        [SNNotificationManager addObserver:self
                                  selector:@selector(actionChannelManageDidBeginEditMode:)
                                      name:kChannelManageDidBeginEditModeNotification
                                    object:nil];
        [SNNotificationManager addObserver:self
                                  selector:@selector(onActionReceived:)
                                      name:kSNJoinActionNotification
                                    object:nil];
        [SNNotificationManager addObserver:self
                                  selector:@selector(updateLocalChannelBadge:)
                                      name:kResetMyCouponBadgeNotification
                                    object:nil];
        [SNNotificationManager addObserver:self
                                  selector:@selector(onlyShowPopOverView)
                                      name:kFontSetterGuideDismissNotification
                                    object:nil];
    }
    
    return self;
}

- (void)updateLocalChannelBadge:(NSNotification *)notification {
    id obj = notification.object;
    if (obj && [obj isKindOfClass:[NSNumber class]]) {
        BOOL clearBadge = [(NSNumber *)obj integerValue];
        if (clearBadge) {
            _localChnBadgeView.hidden = YES;
        }else {
            _localChnBadgeView.hidden = NO;
        }
    }
}

- (void)fullscreenMaskViewAddColor {
    UIColor *color1 = [UIColor colorWithWhite:0 alpha:0.8];
    UIColor *color2 = [UIColor colorWithWhite:0 alpha:0.5];
    UIColor *color3 = [UIColor colorWithWhite:0 alpha:0.2];
    UIColor *color4 = [UIColor colorWithWhite:0 alpha:0.0];
    NSArray *colors = [NSArray arrayWithObjects:(id)color1.CGColor, color2.CGColor,color3.CGColor,color4.CGColor, nil];
    NSArray *locations = [NSArray arrayWithObjects:@(0.0), @(0.3),@(0.7),@(1.0), nil];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.locations = locations;
    gradientLayer.frame = self.fullscreenMaskImageView.bounds;
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint   = CGPointMake(0, 1);
    self.fullscreenMaskImageView.layer.mask = gradientLayer;
}

- (void)initAllSubviews {
    _homeTableViewOffsetY = 0;
    //全屏模式的黑色蒙层衬底
    CGRect middleCoverRect = CGRectMake(0, 0.f, self.width, 44 + kSystemBarHeight);
    self.fullscreenMaskImageView = [[UIImageView alloc] initWithFrame:middleCoverRect];
    self.fullscreenMaskImageView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.fullscreenMaskImageView];
    [self fullscreenMaskViewAddColor];
    self.fullscreenMaskImageView.alpha = 0;
    
    //非全屏模式下的白色不透明衬底  可配置皮肤
    self.middleCoverImageView = [[UIImageView alloc] initWithFrame:middleCoverRect];
    [self addSubview:self.middleCoverImageView];
    self.backgroundColor = [UIColor clearColor];
    //白色衬底下的阴影
    UIImage *image = [UIImage themeImageNamed:@"icotitlebar_shadow_v5.png"];
    image = [image stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    self.shadowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44 + kSystemBarHeight, kAppScreenWidth, 2)];
    self.shadowImageView.image = image;
    [self.middleCoverImageView addSubview:self.shadowImageView];
    //by 5.9.4 wangchuanwen add
    //底部加一根投影线
    lineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height, kAppScreenWidth, 0.5)];
    lineView.backgroundColor = SNUICOLOR(kThemeTextUpdateColor);
    lineView.alpha = 0.1;
    [self.middleCoverImageView addSubview:lineView];
    //add end
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.scrollEnabled = YES;
    _scrollView.scrollsToTop = NO;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:_scrollView];
    
    _channelSelectedImageView = [[SNChannelSelectedLineView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, 42, 16, 2)];
    _channelSelectedImageView.left = showLogo ? CONTENT_LEFT + 32: CONTENT_LEFT;
    [_scrollView addSubview:_channelSelectedImageView];
    
    channelLogoButton = [[SNChannelScrollLogoButton alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, 40, 44)];
    channelLogoButton.backgroundColor = [UIColor clearColor];
    [channelLogoButton addTarget:self action:@selector(openLogoLink) forControlEvents:UIControlEventTouchUpInside];
    channelLogoButton.hidden = showLogo ? NO : YES;
    [self addSubview:channelLogoButton];
    
    self.rightCoverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kAppScreenWidth - 64 , kSystemBarHeight, 64, 44)];
    [self addSubview:self.rightCoverImageView];
    
    [self creatCenterAnimatinView];
    [self showPopOverView];
    
    self.isManagerChannelViewHide = YES;
    
    //edit
//    _editButton = [[UIButton alloc] init];
//    _editButton.backgroundColor = [UIColor clearColor];
//    _editButton.imageEdgeInsets = UIEdgeInsetsMake(0, 23, 0, 0);
//    [_editButton addTarget:self action:@selector(beginEdit) forControlEvents:UIControlEventTouchUpInside];
//    _editButton.adjustsImageWhenDisabled = NO;
//    _editButton.adjustsImageWhenHighlighted = NO;
//    _editButton.accessibilityLabel = @"编辑频道";
    
    //search
//    _searchButton = [[UIButton alloc] init];
//    [_searchButton addTarget:self action:@selector(enterSelfCenterAction) forControlEvents:UIControlEventTouchUpInside];
//    _searchButton.accessibilityLabel = @"进入个人中心";
//
//    SNBubbleTipView *bubbleView = [[SNBubbleTipView alloc] initWithType:SNBubbleAlignRight];
//    bubbleView.frame = CGRectMake(0, 0, 6, bubbleView.defaultHeight-2);
//    bubbleView.tag = kSearchButtonBubbleTag;
//    [_searchButton addSubview:bubbleView];
    
//    UIImage *imageDot = [UIImage imageNamed:@"icohome_dot_v5.png"];
//    CGFloat pointY = 0;
//    if (imageDot.size.width>4) {
//        pointY = 13;
//    } else {
//        pointY = 15;
//    }
//    NSInteger countSave = [[SNUserDefaults objectForKey:kEnterSelfCenterBubbleCount] integerValue];
//    if (countSave > 0) {
//        [bubbleView setBubbleImageFrame:CGRectMake(30, pointY,
//                                                   imageDot.size.width,
//                                                   imageDot.size.height)
//                              withImage:imageDot];
//    }
    //done
//    _editDoneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, kIcoNormalSettingCloseButtonWidth, kIcoNormalSettingCloseButtonHeight)];
//    [_editDoneButton addTarget:self action:@selector(beginEdit) forControlEvents:UIControlEventTouchUpInside];
//    _editDoneButton.alpha = 0;
//    _editDoneButton.accessibilityLabel = @"频道完成";
    
}

/*5.2 add 动画序列*/
#pragma mark animation
- (void)creatCenterAnimatinView {
    if (!_animationView) {
        _animationView = [[SNCenterLinesAnimView alloc] init];
        _animationView.right = kAppScreenWidth - kIcoNormalSettingCloseButtonRightDistance;
        _animationView.top = kIcoNormalSettingCloseButtonTopDistance + kSystemBarHeight;
        _animationView.duration = kAnimationImageViewDuration;
        [self addSubview:_animationView];
    }
    
    _animationLaunchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _animationLaunchButton.backgroundColor = [UIColor clearColor];
    _animationLaunchButton.frame = CGRectMake(0, 0, kIcoNormalSettingCloseButtonWidth, kIcoNormalSettingCloseButtonHeight);
    _animationLaunchButton.center = _animationView.center;
    [_animationLaunchButton addTarget:self action:@selector(beginEdit) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_animationLaunchButton];
}

/*end*/

- (void)onlyShowPopOverView {
    if (!showLogo) {
        //收藏页面和流内使用的tabbar相同
        return;
    }
//    if (![SNUserDefaults boolForKey:kFirstShowChannelScrollKey]) {
//        [SNUserDefaults setBool:YES forKey:kFirstShowChannelScrollKey];
//        CGPoint point = CGPointMake(kPopOverViewOriginX, _channelSelectedImageView.bottom + 20);
//        if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
//            point = CGPointMake(kPopOverViewOriginX, _channelSelectedImageView.bottom + 20 + 24);
//        }
//        CGSize size = CGSizeMake(kPopOverViewWidth, kPopOverViewHeight);
//        self.popOverView = [[SNPopoverView alloc] initWithTitle:kFirstShowChannelGuideText Point:point size:size leftImageName:@"ico_homehand_v5.png"];
//        [self.popOverView show];
//    }
}

- (void)showPopOverView {

    [self onlyShowPopOverView];
}

- (void)updateShowLogo:(BOOL)isShow
               logoUrl:(NSString *)url
                  link:(NSString *)link {
    isShow = YES;
    
    if (showLogo != isShow) {
        showLogo = isShow;
        channelLogoButton.hidden = showLogo ? NO : YES;
        self.logoLink = link;
        [channelLogoButton loadImageWithUrl:url];
        _contentSizeCached = NO;
        [self layoutTabs];
        
        if (isEditMode) {
            channelLogoButton.hidden = YES;
        }
    }
}

- (void)openLogoLink {
    [SNRollingNewsPublicManager sharedInstance].isNeedToPushToRecom = NO;
    [SNNotificationManager postNotificationName:kRecommendReadMoreDidClickNotification object:nil];
}

- (void)setNeedChannelEditModeButton:(BOOL)needChannelEditModeButton {
    _needChannelEditModeButton = needChannelEditModeButton;
    _channelManageEditButton.hidden = !_needChannelEditModeButton;
}

- (void)handleThemeChangeNotify:(NSNotification *)notification {
    [self updateTheme];
    [self needsUpdateTheme];
}

- (void)updateTheme {
    if (self.isUseDynamicSkin) {
        self.middleCoverImageView.image = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"channel_middle_bg.png" ImageSize:self.middleCoverImageView.size];
        
        self.rightCoverImageView.image = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"bgtitlebar_maskright_v5.png" ImageSize:self.rightCoverImageView.size];
        [channelLogoButton updateTheme];
    }
    else {
        self.middleCoverImageView.image = [UIImage imageNamed:@"channel_middle_bg.png"];
        self.rightCoverImageView.image = [UIImage imageNamed:@"bgtitlebar_maskright_v5.png"];
        [channelLogoButton resetNormalColor:YES];
    }
    
    UIImage *markImage = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"icotitlebar_redstripe_v5.png" ImageSize:_channelSelectedImageView.size];
    markImage = [markImage stretchableImageWithLeftCapWidth:markImage.size.width/2 topCapHeight:markImage.size.height/2];
    _channelSelectedImageView.image = markImage;
    [_channelSelectedImageView updateTheme];
//    [_editButton setImage:[UIImage themeImageNamed:@"icotitlebar_personal_v5.png"] forState:UIControlStateNormal];
//    [_editButton setImage:[UIImage themeImageNamed:@"icotitlebar_personalpress_v5.png"] forState:UIControlStateHighlighted];

    UIImage *editDoneNormalImage = [UIImage themeImageNamed:@"iconormalsetting_close_v5.png"];
    UIImage *editDoneHighlightImage = [UIImage themeImageNamed:@"iconormalsetting_closepress_v5.png"];
    [_editDoneButton setImage:editDoneNormalImage forState:UIControlStateNormal];
    [_editDoneButton setImage:editDoneHighlightImage forState:UIControlStateHighlighted];
    
    if (_localChnBadgeView) {
        _localChnBadgeView.image = [UIImage imageNamed:@"ico_hong_v5.png"];
    }
    //by 5.9.4 wangchuanwen add
    lineView.backgroundColor = SNUICOLOR(kThemeTextUpdateColor);
    //add end
//    [_searchButton setImage:[UIImage themeImageNamed:@"icotitlebar_personal_v5.png"] forState:UIControlStateNormal];
//    [_searchButton setImage:[UIImage themeImageNamed:@"icotitlebar_personalpress_v5.png"] forState:UIControlStateHighlighted];
    
    [self.popOverView updateTheme];
}

- (void)reloadChannels {
    NSInteger itemNum = 0;
    int index = 0;
    NSMutableArray *tabItemsArray = [NSMutableArray array];
    
    if (_dataSource) {
        itemNum = [_dataSource numberOfItemsForTabBar:self];
        while (index < itemNum) {
            SNChannelScrollTabItem *tabItem = [_dataSource tabBar:self tabBarItemForIndex:index];
            [tabItemsArray addObject:tabItem];
            index++;
        }
    }
    
    self.tabItems = tabItemsArray;
    
    if (_delegate &&
        [_delegate respondsToSelector:@selector(tabBarChannelReloaded)]) {
        [_delegate tabBarChannelReloaded];
    }
}

- (void)reloadChannels:(NSInteger)index
             channelId:(NSString *)channelId {
    // 我的收藏的频道tab也复用的此类,麻烦张大师改动的时候留意一下
    if (_channelId != channelId) {
        self.channelId = channelId;
    }
    [self reloadChannels];
    
    //频道管理页面进入频道流，如果选中的频道没有变化，无需刷新频道
    _selectedTabIndex = NSIntegerMax; //强制刷新
    [self setSelectedTabIndex:index];
    
    [self toScrollingAnimation:index haveAnimation:YES];
}

- (void)toScrollingAnimation:(NSInteger)index
               haveAnimation:(BOOL)haveAnimation {
    NSMutableArray *arrayM = [NSMutableArray array];
    for (SNChannelScrollTab *label in self.scrollView.subviews) {
        if ([label isKindOfClass:[SNChannelScrollTab class]]) {
            [arrayM addObject:label];
        }
    }
    if (arrayM.count <= index) {
        return;
    }
    SNChannelScrollTab *scrollTab = arrayM[index];
    CGFloat offsetx   =  scrollTab.center.x - self.scrollView.width * 0.5;
    CGFloat offsetMax = self.scrollView.contentSize.width - self.scrollView.width;

    // 在最左和最右时，标签没必要滚动到中间位置。
    if (offsetx > offsetMax) {
        offsetx = offsetMax;
    }
    if (offsetx < 0) {
        offsetx = 0;
    }
    if (haveAnimation) {
        [self.scrollView setContentOffset:CGPointMake(offsetx, 0) animated:YES];
        // 下划线滚动
        [UIView animateWithDuration:0.5 animations:^{
            self.channelSelectedImageView.centerX = scrollTab.centerX;
        } completion:^(BOOL finished){
            self.tempChannelPositionX = self.channelSelectedImageView.centerX - offsetx;
        }];
    }
    else {
        [self.scrollView setContentOffset:CGPointMake(offsetx, 0) animated:NO];
        self.channelSelectedImageView.centerX = scrollTab.centerX;
        self.tempChannelPositionX = self.channelSelectedImageView.centerX - offsetx;
    }
}

- (void)showChannelManageMode:(BOOL)show {
    [self showChannelManageMode:show animated:YES isFromRollingNews:NO];
}
- (void)channelsEditViewWillAnimate:(BOOL)show {
    if ([SNNewsFullscreenManager manager].isFullscreenMode && _selectedTabIndex == 0 && !_ignoreScroll) {
        if (show) {
            for (SNChannelScrollTab *tabView in _tabViews) {
                tabView.alpha = 0;
            }
            self.fullscreenMaskImageView.alpha = 0;
        }else{
            self.middleCoverImageView.left = 0;
        }
    }
}

- (void)showChannelManageMode:(BOOL)show
                     animated:(BOOL)animated
            isFromRollingNews:(BOOL)isFromRollingNews {
    isEditMode = show;
    _isFromRollingNews = isFromRollingNews;
    
    if (animated) {
        if (!show) {
            [UIView beginAnimations:@"manageMode" context:NULL];
            [UIView setAnimationDelegate:self];
            
            [self channelEditModeDidDismiss];
        }
        else {
            [self channelEditModeDidAppear];
        }
    }
    
    if (show) {
        for (SNChannelScrollTab *tabView in _tabViews) {
            tabView.alpha = 0;
        }
        self.isManagerChannelViewHide = NO;
//        _editButton.alpha = 0;
        _moreButton.alpha = 0;
//        _searchButton.alpha = 0;
        _channelSelectedImageView.alpha = 0;
        _editDoneButton.alpha = 1;
        CGPoint pt = _scrollView.contentOffset;
        if (pt.x > (_scrollView.width - _scrollView.contentInset.right)) {
            _scrollView.contentOffset = CGPointMake(0, pt.y);
        }
    } else {
        _editModeTitleLabel.left = -_editModeTitleLabel.width;
    }
    
    if (animated && !show) {
        [UIView commitAnimations];
    }
    if ([SNNewsFullscreenManager manager].isFullscreenMode) {
        if (show) {
            [self p_changeFullscreenMode:NO];
        }else {
            if (_ignoreScroll || _selectedTabIndex > 0) {
                [self p_changeFullscreenMode:NO];
            }else if(_selectedTabIndex == 0){//_currentSelectedTabIndex
                [self p_changeFullscreenMode:YES];
            }
        }
    }
}

- (void)channelEditModeDidDismiss {
    _scrollView.scrollEnabled = YES;
    channelLogoButton.hidden = showLogo ? NO : YES;
    [channelLogoButton updateTheme];
    [_editModeTitleLabel removeFromSuperview];
    _editModeTitleLabel = nil;
    
    self.isManagerChannelViewHide = YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        for (SNChannelScrollTab *tabView in _tabViews) {
            tabView.alpha = 1;
        }
//        _editButton.alpha = 1;
//        _editButton.enabled = YES;
        _moreButton.alpha = 1;
        _moreButton.enabled = YES;
//        _searchButton.alpha = 1;
        _channelSelectedImageView.alpha = 1;
        _editDoneButton.alpha = 0;
    } completion:^(BOOL finished) {
        if (!finished) {
            for (SNChannelScrollTab *tabView in _tabViews) {
                tabView.alpha = 1;
            }
//            _editButton.alpha = 1;
//            _editButton.enabled = YES;
            _moreButton.alpha = 1;
            _moreButton.enabled = YES;
//            _searchButton.alpha = 1;
            _channelSelectedImageView.alpha = 1;
            _editDoneButton.alpha = 0;
        }
        [_animationView reset:NO];
        [[SNSpecialActivity shareInstance] prepareShowFloatingADWithType:SNFloatingADTypeChannels majorkey:self.selectedChannelId];
    }];
    [_shieldTabBarView removeFromSuperview];
    [SNUserDefaults removeObjectForKey:kEnterChannelManageViewTag];
}

- (void)channelEditModeDidAppear {
    _scrollView.scrollEnabled = NO;
    channelLogoButton.hidden = YES;
    
    // show title
    if (!_editModeTitleLabel) {
        NSString *text = nil;
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        int labelHeight = self.height - kSystemBarHeight;
        _editModeTitleLabel = [[SNChannelTitleLabel alloc] initWithFrame:CGRectMake(-size.width, kSystemBarHeight, kAppScreenWidth - kIcoNormalSettingCloseButtonWidth, labelHeight)];
        [_editModeTitleLabel setTitleString:text];
        [self addSubview:_editModeTitleLabel];
    }
    
    [_shieldTabBarView removeFromSuperview];
    
    [SNUserDefaults setObject:[NSNumber numberWithBool:YES] forKey:kEnterChannelManageViewTag];
    
    [_animationView reset:YES];
    
    [[SNSpecialActivity shareInstance] dismissLastChannelSpecialAlert];
}

- (void)setMoreButtonSelected:(BOOL)selected {
    if (!_moreButton) {
        return;
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    _delegate = nil;
    _dataSource = nil;
}

#pragma mark -
#pragma mark Private
- (void)enterSelfCenterAction {
    NSTimeInterval editDate = [[NSDate date] timeIntervalSince1970];
    if (editDate - _editChannelTime < 0.8) {
        return;
    }
    
    [SNTimelineSharedVideoPlayerView fakeStop];
    [SNTimelineSharedVideoPlayerView forceStop];
    
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://selfCenter"] applyAnimated:YES] applyQuery:nil];
    [[TTNavigator navigator] openURLAction:urlAction];
    
    SNBubbleTipView *bubbleView = (SNBubbleTipView *)[_searchButton viewWithTag:kSearchButtonBubbleTag];
    if (bubbleView)
        [bubbleView setTipCount:0];
    
    if ([[SNUserDefaults objectForKey:kShowMessageGuideKey] boolValue]) {
        [SNUserDefaults setObject:@"0" forKey:kEnterSelfCenterBubbleCount];
    }
    
    //CC统计
    SNUserTrack *userTrack= [SNUserTrack trackWithPage:more_user link2:nil];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], f_into_user];
    [SNNewsReport reportADotGifWithTrack:paramString];
    
    [SNNotificationManager postNotificationName:kEnterSelfCenterNotification object:nil userInfo:[NSDictionary dictionaryWithObject:@"YES" forKey:@"enter_selfCenter"]];
    [[SNActionSheetLoginManager sharedInstance] resetNewGuideDic];
}

- (void)beginEdit {
    //增加点击时间间隔限制，防止频繁切换导致频道显示错乱
    NSTimeInterval editDate = [[NSDate date] timeIntervalSince1970];
    if (editDate - _channelActionDate < kSNChannelManageViewV2AnimationDuration/2 + 0.1 && (editDate - _channelActionDate) > 0) {
        return;
    } else {
        _channelActionDate = editDate;
    }
    
    if (!_shieldTabBarView) {
        _shieldTabBarView = [[UIView alloc] initWithFrame:CGRectMake(0, kSystemBarHeight, self.frame.size.width, self.frame.size.height)];
        _shieldTabBarView.backgroundColor = [UIColor clearColor];
        [[UIApplication sharedApplication].keyWindow addSubview:_shieldTabBarView];//避免展开频道浮层展开过程中可执行其他点击操作
    }
    if ([SNNewsFullscreenManager manager].isFullscreenMode && !_ignoreScroll) {
        _isFullScreenMode = [SNUtility isFromChannelManagerViewOpened] && _selectedTabIndex == 0;
    }
    [_animationView startAnimating];
    
    _editChannelTime = editDate;
    
    SNTimelineSharedVideoPlayerView *timelineVideoPlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
    if ([timelineVideoPlayer isPlaying]) {
        [SNTimelineSharedVideoPlayerView forceStop];
    }

    //关闭听新闻引导浮层
    [[SNRollingNewsPublicManager sharedInstance] closeListenNewsGuideViewAnimation:YES];
    //关闭频道浮层广告
    [[SNSpecialActivity shareInstance] dismissLastChannelSpecialAlert];
    
    if (_moreButton) {
        _moreButton.enabled = NO;
    }
    
//    if (_editButton) {
//        _editButton.enabled = NO;
//        double delayInSeconds = 1.0;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            _editButton.enabled = YES;
//        });
//    }
    if (_delegate && [_delegate respondsToSelector:@selector(tabBarBeginEdit:)]) {
        [_delegate tabBarBeginEdit:self];
    }
    //防止视频流，直接进入编辑状态
    if ([_delegate isKindOfClass:[SNRollingNewsViewController class]]) {
        [self actionChannelManageEdit:nil];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabBarDismissPopoverMessage:)]) {
        [self.delegate tabBarDismissPopoverMessage:self];
    }
    
    [self.popOverView dismiss];
    //频道搜索的时候 要隐藏小说的popover
    if ([_delegate isKindOfClass:[SNRollingNewsViewController class]]) {
        id tableController = [(SNRollingNewsViewController*)_delegate getCurrentTableController];
        if ([tableController isKindOfClass:[SNRollingNewsTableController class]]) {
            [(SNRollingNewsTableController*)tableController hideNovelPopover];
        }
    }
}

- (void)actionChannelManageEdit:(id)sender {
    if (self.isManagerChannelViewHide) {
        [SNNotificationManager postNotificationName:kChannelManageBeginEditNotification object:nil userInfo:nil];
    }
    
//    if (_editButton.alpha == 1) {
//        [SNNotificationManager postNotificationName:kChannelManageBeginEditNotification object:nil userInfo:nil];
//        _editButton.alpha = 0;
//        [UIView animateWithDuration:0.3 animations:^{
//            _editDoneButton.alpha = 0;
//            _searchButton.alpha = 0;
//            _channelSelectedImageView.alpha = 0;
//        }];
//    }
}

- (void)actionChannelManageDidBeginEditMode:(NSNotification *)notification {
    if ([notification isKindOfClass:[NSNotification class]]) {
        if (notification.object == self.delegate) {
            [self actionChannelManageEdit:nil];
        }
    }
}

- (void)finishChannelManageMode {
    [_editModeTitleLabel setTitleString:nil];
    [SNNotificationManager postNotificationName:kChannelManageFinishEditNotification
                                                        object:nil
                                                      userInfo:nil];
    _editDoneButton.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
//        _editButton.alpha = 1;
//        _searchButton.alpha = 1;
        _channelSelectedImageView.alpha = 1;
    }];
}

- (void)actionChannelManageEditDone:(id)sender {
    //CC统计
    SNUserTrack *userTrack = [SNUserTrack trackWithPage:channel_edit link2:nil];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [userTrack toFormatString], f_channel_edit_finish];
    [SNNewsReport reportADotGifWithTrack:paramString];
    
    [_editModeTitleLabel setTitleString:nil];
    [SNNotificationManager postNotificationName:kChannelManageFinishEditNotification
                                                        object:nil
                                                      userInfo:nil];
    [UIView animateWithDuration:0.3 animations:^{
        _editDoneButton.alpha = 1;
    }];
}

- (void)addTab:(SNChannelScrollTab*)tab {
    [_scrollView addSubview:tab];
    _contentSizeCached = NO;
}

- (void)moveTriangleGapToSelectedTab:(BOOL)needAutoscroll {
    SNChannelScrollTab *selectedTabView = [self selectedTabView];
    
    if (needAutoscroll) {
        CGPoint ptOffset = _scrollView.contentOffset;
        CGFloat xOffset = ptOffset.x;
        int paddLeft = showLogo ? CONTENT_LEFT + 21 + 14 : kPadding;
        int paddRight = kAppScreenWidth - 80;
        
        if (selectedTabView.left < xOffset + paddLeft) {
            int offset =  MAX(selectedTabView.left - paddLeft, 0);
            if (_scrollViewContentOffset.x != 0 && _currentSelectedTabIndex == _selectedTabIndex) {
                _scrollView.contentOffset = _scrollViewContentOffset;
            } else {
                _scrollView.contentOffset = CGPointMake(offset, ptOffset.y);
            }
        } else if (selectedTabView.right > xOffset + paddRight) {
            if (_scrollViewContentOffset.x != 0 && _currentSelectedTabIndex == _selectedTabIndex) {
                _scrollView.contentOffset = _scrollViewContentOffset;
            } else {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0 || kAppScreenWidth == 320.0) {
                    _scrollView.contentOffset = CGPointMake(selectedTabView.right - paddRight, ptOffset.y);
                } else {
                    _scrollView.contentOffset = CGPointMake(selectedTabView.right - paddRight - 20.0, ptOffset.y);
                }
            }
        } else {
            if (_selectedTabIndex == 0) {
                if (_scrollViewContentOffset.x != 0 || _currentSelectedTabIndex == _selectedTabIndex) {
                    _scrollView.contentOffset = _scrollViewContentOffset;
                }
                else {
                    _scrollView.contentOffset = CGPointZero;
                }
            }
            else {
                if (_scrollViewContentOffset.x != 0 && _currentSelectedTabIndex == _selectedTabIndex) {
                    _scrollView.contentOffset = _scrollViewContentOffset;
                }
            }
        }
    }
    
    if (selectedTabView.tabItem.title.length > 0) {
        _channelSelectedImageView.width = 16;
    }
    
    _channelSelectedImageView.centerX = selectedTabView.centerX;
    _currentSelectedTabIndex = _selectedTabIndex;
}

- (void)layoutTriangleGapToSelectedTab {
    if (isEditMode) {
        return;
    }
    _lastSelectedTabIndex = _selectedTabIndex;
}

- (CGSize)layoutTabsSize {
    CGFloat x = showLogo ? CONTENT_LEFT : kPadding;
    int distance = ( UIDevice6PlusiPhone == [[UIDevice currentDevice] platformTypeForScreen]) ? 13 : 15;
    for (int i = 0; i < _tabViews.count; ++i) {
        SNChannelScrollTab* tab = [_tabViews objectAtIndex:i];
        CGSize tabSize = CGSizeMake([tab titleSize].width, self.height-kSystemBarHeight);
        tab.frame = CGRectMake(x, 0, tabSize.width, tabSize.height);
        tab.titleLabel.frame = CGRectMake(0, 0, tabSize.width, tabSize.height);
        tab.maskTitleLabel.frame = tab.titleLabel.frame;
        x = tab.frame.origin.x + tab.frame.size.width + distance;
        if ([tab.tabItem.channelId isEqualToString:_channelId] && !self.isChannelTempStatus) {
            tab.selected = YES;
        }
    }
    return CGSizeMake(x, self.frame.size.height);
}

- (CGSize)layoutTabs {
    if (_contentSizeCached) {
        return _contentSize;
    }
    
    CGSize size = [self layoutTabsSize];
    _scrollView.frame = CGRectMake(37.f, kSystemBarHeight, self.width - 37*2, [SNChannelScrollTabBar channelBarHeight] - kSystemBarHeight);
    _scrollView.clipsToBounds = _isFullScreenMode;
    _scrollView.contentSize = CGSizeMake(size.width, self.frame.size.height - kSystemBarHeight);
    
    if (_moreButton) {
        _editButton.frame = CGRectMake(self.width - kEditButtonSideMargin - kEditButtonWidth,
                                       (self.height - kEditButtonWidth - kSystemBarHeight) / 2 + kSystemBarHeight,
                                       kEditButtonWidth,
                                       kEditButtonWidth);
        _editButton.right = self.width - 10;
        _moreButton.frame = _editButton.frame;
        _moreButton.right = _editButton.left - kEditButtonSpacing;
    } else {
        _editButton.frame = CGRectMake(self.width - CONTENT_BOTTOM - kEditButtonWidth - kSearchButtonWidth + 10, (self.height - kEditButtonWidth - kSystemBarHeight) / 2 + kSystemBarHeight,
                                       kEditButtonWidth,
                                       kEditButtonWidth);
        _editButton.right = self.width - 10;
        int left = self.width - kSearchButtonWidth;
        int top = (self.height - kSearchButtonHeight - kSystemBarHeight) / 2 + kSystemBarHeight -1;
//        _searchButton.frame = CGRectMake(left, top, kSearchButtonWidth, kSearchButtonHeight);
    }
    _editDoneButton.right = self.width;
    
    SNChannelScrollTab *selectedTabView = [self selectedTabView];
    if (selectedTabView) {
        _channelSelectedImageView.centerX = selectedTabView.centerX;
    } else {
        _channelSelectedImageView.left = showLogo ? CONTENT_LEFT + 32: CONTENT_LEFT;
    }

    _contentSize = size;
    _contentSizeCached = YES;
    
    return size;
}

- (void)scrollToSelectedIndex {
    if (isReleased) {
        isReleased = NO;
        //滚到那个选中的tab，用于重绘时的恢复
        [_scrollView scrollRectToVisible:self.selectedTabView.frame animated:NO];
    }
}

- (BOOL)needsUpdateTheme {
    BOOL themeChanged = ![_currentTheme isEqualToString:[[SNThemeManager sharedThemeManager] currentTheme]];
    
    if (themeChanged) {
        _currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
    }
    
    return themeChanged;
}

#pragma mark -
#pragma mark UIView
- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutTabs];
    [self scrollToSelectedIndex];
    [self layoutTriangleGapToSelectedTab];
    
//    [self updateTheme];
}

- (void)resetCurrentTabTitle:(NSString *)title {
    if (self.selectedTabItem.isLocalChannel) {
        CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
        _localChnBadgeView.frame = CGRectMake(size.width, self.top + kUnReadImageViewTop, kUnReadImageViewWidth, kUnReadImageViewWidth);
    }
    if ((nil != self.selectedTabItem.title &&
         [self.selectedTabItem.title isEqualToString:title]) ||
        ![self.selectedTabItem.channelId isEqualToString:kLocalChannelUnifyID]) {
        return;
    }
    
    _contentSizeCached = NO;
    
    self.selectedTabItem.title = title;
    self.selectedTabView.titleLabel.text =title;
    [self moveTriangleGapToSelectedTab:NO];
    
    [self layoutTabs];
}

- (void)reloadScrollTabBar {
    if (self.isUseDynamicSkin) {
        //根据图片更新顶部tab背景
        self.middleCoverImageView.image = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"channel_middle_bg.png" ImageSize:self.middleCoverImageView.size];
        self.rightCoverImageView.image = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"bgtitlebar_maskright_v5.png" ImageSize:self.rightCoverImageView.size];
        
        [channelLogoButton updateTheme];
    }
    else {
        self.middleCoverImageView.image = [UIImage imageNamed:@"channel_middle_bg.png"];
        self.rightCoverImageView.image = [UIImage imageNamed:@"bgtitlebar_maskright_v5.png"];
        [channelLogoButton resetNormalColor:YES];
    }
    
    UIImage *markImage = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"icotitlebar_redstripe_v5.png" ImageSize:_channelSelectedImageView.size];
    markImage = [markImage stretchableImageWithLeftCapWidth:markImage.size.width/2 topCapHeight:markImage.size.height/2];
    _channelSelectedImageView.image = markImage;
    [_channelSelectedImageView updateTheme];
}

- (void)resetTopScrollBarBackColor:(BOOL)isNormal {
    if (![SNCheckManager checkDynamicPreferences]) {
        self.isUseDynamicSkin = YES;
        [self updateTheme];
        return;
    }
    self.isUseDynamicSkin = !isNormal;
    UIImage *middleImage = nil;
    UIImage *rightImage = nil;
    if (isNormal) {
        middleImage = [UIImage imageNamed:@"channel_middle_bg.png"];
        rightImage = [UIImage imageNamed:@"bgtitlebar_maskright_v5.png"];
    }
    else {
        middleImage = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"channel_middle_bg.png" ImageSize:self.middleCoverImageView.size];
        rightImage = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"bgtitlebar_maskright_v5.png" ImageSize:self.rightCoverImageView.size];
    }
    [channelLogoButton resetNormalColor:isNormal];
    self.middleCoverImageView.image = middleImage;
    self.rightCoverImageView.image = rightImage;
}

- (void)shouldShowSohuLogo:(BOOL)show {
    if (show && ![SNUtility isFromChannelManagerViewOpened]) {
        channelLogoButton.hidden = NO;
    }
    else {
        channelLogoButton.hidden = YES;
    }
}

#pragma mark -
#pragma mark TTTabBar
- (void)setTabItems:(NSArray *)tabItems {
    if (tabItemEditing) {
        return;
    }
    
    tabItemEditing = YES;
    
    _tabItems = tabItems;
    
    for (int i = 0; i < _tabViews.count; ++i) {
        @autoreleasepool {
            SNChannelScrollTab *tab = [_tabViews objectAtIndex:i];
            [tab removeFromSuperview];
        }
    }
    
    [_tabViews removeAllObjects];
    @synchronized (_tabItems) {
        for (int i = 0; i < _tabItems.count; ++i) {
            @autoreleasepool {
                SNChannelScrollTabItem *tabItem = [_tabItems objectAtIndex:i];
                SNChannelScrollTab *tab = [[SNChannelScrollTab alloc] initWithItem:tabItem tabBar:self];
                tab.alpha = isEditMode ? 0.0 : 1.0;
                [tab changeFullscreenMode: _isFullScreenMode];

                [tab addTarget:self
                        action:@selector(tabTouchedUp:)
              forControlEvents:UIControlEventTouchUpInside];
                
                [self addTab:tab];
                [_tabViews addObject:tab];
                
                if ([tabItem.channelId isEqualToString:_channelId] && !self.isChannelTempStatus) {
                    _selectedTabIndex = i;
                    tab.selected = YES;
                }
                
                //本地频道
                if (tabItem.isLocalChannel) {
                    if (!_localChnBadgeView) {
                        CGSize size = [tabItem.title sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
                        _localChnBadgeView = [[UIImageView alloc] initWithFrame:CGRectMake(size.width, self.top + kUnReadImageViewTop, kUnReadImageViewWidth, kUnReadImageViewWidth)];
                    }
                    _localChnBadgeView.image = [UIImage imageNamed:@"ico_hong_v5.png"];
                    
                    [tab addSubview:_localChnBadgeView];
                    NSNumber *couponViewShouldHidden = [SNUserDefaults objectForKey:kMyCouponBadgeUnRead];
                    _localChnBadgeView.hidden = ![couponViewShouldHidden integerValue];
                }
            }
        }
    }
    
    _contentSizeCached = NO;
    [self layoutSubviews];
    tabItemEditing = NO;
    if ([[TTNavigator navigator].topViewController isKindOfClass:[SNRollingNewsViewController class]]) {
        self.isUseDynamicSkin = YES;
    }
    [self updateTheme];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!bForceScroll) {
    } else {
        bForceScroll = NO;
    }
    _scrollViewContentOffset = scrollView.contentOffset;
}

#pragma mark -
#pragma mark Private
- (void)tabTouchedUp:(SNChannelScrollTab *)tab {
    [SNRollingNewsPublicManager sharedInstance].touchChannel = YES;
    [SNRollingNewsPublicManager sharedInstance].isNeedToPushToRecom = NO;
    // 点击显示频道滑动切换引导
    if (![SNUserDefaults boolForKey:kSlideToChangeChannelGuideKey]) {
        [SNNotificationManager postNotificationName:kSlideToChangeChannelNotification object:nil userInfo:nil];
    }

    //手动切换频道消失听新闻引导
    [[SNRollingNewsPublicManager sharedInstance] closeListenNewsGuideViewAnimation:YES];
    _currentSelectedTabIndex = [_tabViews indexOfObject:tab];
    [SNRollingNewsPublicManager sharedInstance].userAction = SNRollingNewsUserTabAndRefresh;
    self.selectedTabView = tab;
    
    [self toScrollingAnimation:_currentSelectedTabIndex haveAnimation:YES];
    
    if ([tab.tabItem.title isEqualToString:@"首页"]) {
        [SNNewsReport reportADotGif:@"_act=channelone&_tp=pv"];
    } else if ([tab.titleLabel.text isEqualToString:@"小说"]) {
        //点击小说频道
        //小说频道埋点统计
        [SNNewsReport reportADotGif:@"act=fic_channel&tp=pv&from=1"];
    }
}

- (CGPoint)getChannelPoint {
    //减去SOHU LOGO = 34
    CGFloat channelPositionX = _channelSelectedImageView.centerX - _scrollView.contentOffset.x + 34;
    CGFloat y = _channelSelectedImageView.bottom + 20;
    return CGPointMake(channelPositionX, y);
}

- (void)p_absolutelyChangeFullscreenMode:(BOOL)fullscreen {
    _isFullScreenMode = fullscreen;
    //通知每个scrollTab更新字体颜色
    for (SNChannelScrollTab * tab in _tabViews) {
        [tab changeFullscreenMode:fullscreen];
    }
    if (fullscreen) {
        //全屏透明模式
        //状态条
        [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:YES];
        //scroll宽度
        self.scrollView.clipsToBounds = YES;
        channelLogoButton.coverImageView.alpha = 0;
        self.fullscreenMaskImageView.left = 0;
        //背景透明
        self.middleCoverImageView.left = kAppScreenWidth;
        self.fullscreenMaskImageView.alpha = 1;
        _channelSelectedImageView.maskView.alpha = 1;
        _animationView.isFullScreenMode = YES;
        self.rightCoverImageView.alpha = 0;
    }else{
        //原始模式
        [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:NO];
        //状态条
        self.middleCoverImageView.left = 0;
        //背景不透明
        self.middleCoverImageView.alpha = 1;
        self.fullscreenMaskImageView.left = -kAppScreenWidth;
        self.fullscreenMaskImageView.alpha = 1;
        _channelSelectedImageView.maskView.alpha = 0;
        _animationView.isFullScreenMode = NO;
        //scroll宽度
        _scrollView.clipsToBounds = NO;
        self.rightCoverImageView.alpha = 1;
        channelLogoButton.coverImageView.alpha = 1;
    }
}

- (void)p_changeFullscreenMode:(BOOL)fullscreen {
    if (_selectedTabIndex != 0 || _ignoreScroll) {
        return;
    }
    [self p_absolutelyChangeFullscreenMode:fullscreen];
}

#pragma mark -
#pragma mark Public
- (void)changeFullScreenMode:(BOOL)fullscreen {
    if ([SNNewsFullscreenManager manager].fullscreenMode == YES) {
        if ([SNUtility isFromChannelManagerViewOpened] || _selectedTabIndex != 0 || _ignoreScroll) {
            return;
        }
    }
    if ((self.alpha < 1 && self.homeTableViewOffsetY >= 0) || !fullscreen) {
        self.alpha = 1;
    }
    [self p_absolutelyChangeFullscreenMode:fullscreen];
}

- (void)rollingNewsScrollViewDidScroll:(CGFloat)contentOffsetX {
    if (_ignoreScroll) {
        return;
    }
    if ([SNNewsFullscreenManager manager].isFullscreenMode) {//huangzhen TODO...
        CGFloat ratio = MAX(0, contentOffsetX/kAppScreenWidth);
        ratio = MIN(1, ratio);
        CGFloat coverLeft = MAX(0, kAppScreenWidth - contentOffsetX);
        if (self.alpha <= 0) {
            
        }else{
            //黑白衬底背景
            self.middleCoverImageView.alpha = 1;
            self.middleCoverImageView.left = coverLeft;
            if (!_didMoveOut) {
                self.fullscreenMaskImageView.left = -contentOffsetX;
            }
        }
        if (_didMoveOut) {
//            channelLogoButton.left = coverLeft;
//            _scrollView.left = 37.f + coverLeft;
//            CGFloat animateLeft = _animationView.left;
//            _animationView.left = kAppScreenWidth - kIcoNormalSettingCloseButtonRightDistance - _animationView.width + coverLeft;
////            if (_homeTableViewOffsetY == 0) {
////                //已经回归原位置，重置标识变量
////                _didMoveOut = NO;
////            }
            self.alpha = ratio;
            if (ratio == 1) {
                _didMoveOut = NO;
            }
        }
        //导航滚动条
        CGFloat scrollWidth = self.width - 2*37;
        self.scrollView.width = scrollWidth + (ratio * 15);
        //频道编辑三道杠
        [_animationView setLineColorWithRatio:ratio];
        //频道名称
        for (SNChannelScrollTab * tab in _tabViews) {
            [tab changeFullscreenModeWithRatio:ratio];
        }
        _channelSelectedImageView.maskView.alpha = 1-ratio;
        //右边三道杠遮罩
        _rightCoverImageView.alpha = ratio;
        
        if (ratio == 1) {
            self.scrollView.clipsToBounds = NO;
            //左边icon遮罩
            channelLogoButton.coverImageView.alpha = 1;
            _isFullScreenMode = NO;
        }else if (ratio == 0){
            _isFullScreenMode = YES;
            channelLogoButton.coverImageView.alpha = 0;
        }else {
            _isFullScreenMode = YES;
            self.scrollView.clipsToBounds = YES;
            //左边icon遮罩
            channelLogoButton.coverImageView.alpha = 0;
            if (ratio > 0.5) {
                [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:NO];
            }else{
                if ([UIApplication sharedApplication].statusBarStyle != UIStatusBarStyleLightContent) {
                    [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"lightContent"}];
                }
            }
        }
    }
}

- (void)rollingNewsTableViewDidScroll:(CGFloat)offsetY {
    _homeTableViewOffsetY = offsetY;
    [SNNewsFullscreenManager manager].homeTableViewOffsetY = offsetY;
    if (_homeTableViewOffsetY == 0) {
        _ignoreScroll = NO;
    }
    if ((_selectedTabIndex == 0 || _didMoveOut) && [SNNewsFullscreenManager manager].isFullscreenMode && ![SNUtility isFromChannelManagerViewOpened]) {//首页要闻
        CGFloat distance = [SNNewsFullscreenManager manager].trainAnimationDistance;//huangzhen TODO...
        CGFloat ratio = MAX(-1, offsetY/distance);
        ratio = MIN(1, ratio);
        //下拉刷新隐藏导航栏
        CGFloat pullAlpha = 1 + (ratio * 0.5) + 2*ratio;
        if (pullAlpha <= 0) {
            _didMoveOut = YES;
        }else{
            _didMoveOut = NO;
        }
        self.alpha = pullAlpha;

        //上推过程
        CGFloat pushAlpha = [self ratioForDelayDistance:1/3.f originRatio:ratio];
        //黑白背景衬底
        self.middleCoverImageView.left = 0;
        self.middleCoverImageView.alpha = pushAlpha;
        self.fullscreenMaskImageView.alpha = 1 - pushAlpha;
        //频道编辑三道杠
        [_animationView setLineColorWithRatio:pushAlpha];
        //频道名称
        for (SNChannelScrollTab * tab in _tabViews) {
            [tab changeFullscreenModeWithRatio:pushAlpha];
        }
        _channelSelectedImageView.maskView.alpha = 1-pushAlpha;
        //右边三道杠遮罩
        CGFloat rightPushAlpha = [self ratioForDelayDistance:4/5.f originRatio:ratio];
        _rightCoverImageView.alpha = rightPushAlpha;
        //导航滚动条
        CGFloat scrollWidth = self.width - 2*37;
        self.scrollView.width = scrollWidth + (ratio * 15);
        
        if (ratio == 1) {
            //上推动画完成后锁定，不再恢复状态
            _ignoreScroll = YES;
            _isFullScreenMode = NO;
            self.scrollView.clipsToBounds = NO;
            //左边icon遮罩
            channelLogoButton.coverImageView.alpha = 1;
            [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:NO];
        }else if(pullAlpha < 0){
            if ([UIApplication sharedApplication].statusBarStyle != UIStatusBarStyleDefault) {
                [SNNotificationManager postNotificationName:kStatusBarStyleChangedNotification object:@{@"style": @"default"}];
            }
        }else{
            _isFullScreenMode = YES;
            _ignoreScroll = NO;
            channelLogoButton.coverImageView.alpha = 0;
            self.scrollView.clipsToBounds = YES;
            [SNNewsFullscreenManager resetStatusBarStyleIfFullscreenMode:YES];
        }
    }
}

/**
 延迟变化ratio

 @param delayDis 需要delay的比例，从总路程的多少百分比开始变化，0-1
 @param originRatio 原始的ratio 0-1
 @return 0-1之间变化的ratio
 */
- (CGFloat)ratioForDelayDistance:(CGFloat)delayDis originRatio:(CGFloat)originRatio {
    //要求不立即开始变，在路程开始1/3时开始变化，总路程不变。
    CGFloat criticleValue = delayDis;//变化开始的临界值
    CGFloat d = 1 - criticleValue;//减去临界值，剩余的路程值
    CGFloat r = 1/d;//转换比率
    CGFloat t = originRatio - criticleValue;
    t = MAX(0, t);//t 0-0.7之间变化
    CGFloat pushAlpha = t*r;//乘上比率后，变为0-1之间变化
    return pushAlpha;
}

- (void)setDataSource:(id<SNScrollTabBarDataSource>)dataSource {
    _dataSource = dataSource;
}

- (SNChannelScrollTabItem *)selectedTabItem {
    if (_selectedTabIndex != NSIntegerMax) {
        return [_tabItems objectAtIndexWithRangeCheck:_selectedTabIndex];
    }
    return nil;
}

- (void)setSelectedTabItem:(SNChannelScrollTabItem *)tabItem {
    self.selectedTabIndex = [_tabItems indexOfObject:tabItem];
}

- (SNChannelScrollTab *)selectedTabView {
    if (_selectedTabIndex != NSIntegerMax && _selectedTabIndex < _tabViews.count) {
        return [_tabViews objectAtIndex:_selectedTabIndex];
    } else {
        _selectedTabIndex = 0;
        //lijian 2017.11.21 这里没有做代码保护，属于健壮性问题，增加了程序崩溃的风险。
        if([_tabViews count] == 0 || _selectedTabIndex >= [_tabViews count]){
            return nil;
        }
        return [_tabViews objectAtIndex:_selectedTabIndex];
    }
}

- (void)setSelectedTabView:(SNChannelScrollTab *)tab {
    self.selectedTabIndex = [_tabViews indexOfObject:tab];
    self.channelId = tab.tabItem.channelId;
    [SNUtility sharedUtility].currentChannelId = _channelId;
}

- (void)forceSetSelectedTabIndex:(NSInteger)selectedTabIndex {
    _selectedTabIndex = NSNotFound;
    [self setSelectedTabIndex:selectedTabIndex];
}

- (NSString *)selectedChannelId {
    return self.selectedTabItem.channelId;
}

- (void)setSelectedChannelId:(NSString *)selectedChannelId {
    if (selectedChannelId.length == 0) {
        return;
    }
    
    for (NSInteger i = 0; i < _tabViews.count; i++) {
        SNChannelScrollTab *tabItem = _tabViews[i];
        
        if ([tabItem.tabItem.channelId isEqualToString:selectedChannelId]) {
            self.selectedTabIndex = i;
            [self toScrollingAnimation:i haveAnimation:YES];
            break;
        }
    }
}

- (void)resetSelectedTabIndex:(NSInteger)selectedTabIndex {
    if (_selectedTabIndex != NSIntegerMax && selectedTabIndex != _selectedTabIndex ) {
        self.selectedTabView.selected = NO;
    }
    
    _selectedTabIndex = selectedTabIndex;
    if (_selectedTabIndex != NSIntegerMax) {
        self.selectedTabView.selected = YES;
    }
    self.channelId = self.selectedTabItem.channelId;
}

- (void)setSelectedTabIndex:(NSInteger)selectedTabIndex {
    if (selectedTabIndex == 0 && _currentSelectedTabIndex != selectedTabIndex) {
        _scrollViewContentOffset = CGPointZero;
    }

    //5.2.2 点击当前频道tab，重置刷新(新闻频道）
    SNVideoAdContextCurrentTabValue currentTab = [[SNVideoAdContext sharedInstance] getCurrentTab];
    if (selectedTabIndex == _selectedTabIndex && currentTab == SNVideoAdContextCurrentTabValue_News) {
        if ([SNRollingNewsPublicManager sharedInstance].newsSource == SNRollingNewsSourceDefault) {
            [SNRollingNewsPublicManager sharedInstance].newsSource = SNRollingNewsSourceChannel;
        }
        [_delegate tabBarAutoRefresh:self];
    }
    
    if (selectedTabIndex != _selectedTabIndex && (nil != _tabViews && [_tabViews count] > selectedTabIndex && selectedTabIndex >= 0)) {
        if (_selectedTabIndex != NSIntegerMax) {
            self.selectedTabView.selected = NO;
        }
        
        _selectedTabIndex = selectedTabIndex;
        if (_selectedTabIndex != NSIntegerMax) {
            self.selectedTabView.selected = YES;
        }
        
        bForceScroll = YES;
        [self moveTriangleGapToSelectedTab:NO];
        self.tempChannelPositionX = _channelSelectedImageView.centerX - _scrollView.contentOffset.x;

        [[SNVideoAdContext sharedInstance] setCurrentChannelID:self.selectedTabItem.channelId];
        if ([_delegate respondsToSelector:@selector(tabBar:tabSelected:)]) {
            //重新获取的索引值，避免切换频道，未刷新页面
            if (_selectedTabIndex == 0 && ![self.selectedTabItem.channelId isEqualToString:@"1"]) {
                _selectedTabIndex = [SNUtility getChannelIndexByChannelID:self.selectedTabItem.channelId];
            }
            
            [SNRollingNewsPublicManager sharedInstance].userAction = SNRollingNewsUserChangeTab;
            
            //页面上方的选项卡tab点击切换 _delegate == SNRollingNewsViewController
            [_delegate tabBar:self tabSelected:_selectedTabIndex];
        }
        
        self.channelId = self.selectedTabItem.channelId;
    } else if (_selectedTabIndex == 0 && selectedTabIndex == 0) {
        _scrollView.contentOffset = CGPointZero;
        _scrollViewContentOffset = CGPointZero;
    }
}

- (void)setMoreButton:(UIButton *)moreButton {
    if (_moreButton != moreButton) {
        _moreButton = moreButton;
        [self insertSubview:_moreButton aboveSubview:_editButton];
        
        [self layoutTabs];
    }
}

- (void)showTabAtIndex:(NSInteger)tabIndex {
    SNChannelScrollTab *tab = [_tabViews objectAtIndex:tabIndex];
    tab.hidden = NO;
}

- (void)hideTabAtIndex:(NSInteger)tabIndex {
    SNChannelScrollTab *tab = [_tabViews objectAtIndex:tabIndex];
    tab.hidden = YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
}

- (SNChannelScrollTab *)getTabAtIndex:(int)index {
    if (index < _tabViews.count) {
        SNChannelScrollTab* tab = [_tabViews objectAtIndex:index];
        return tab;
    }
    
    return nil;
}

- (void)showTabBubble:(int)count atIndex:(int)index {
    SNChannelScrollTab *tab = [self getTabAtIndex:index];
    if (!tab) return;
    
    UIImageView *badge = (UIImageView *)[tab viewWithTag:101];

    if (count > 0) {
        if (badge == nil) {
            badge = [[UIImageView alloc] initWithImage:nil];
            badge.tag = 101;
            CGRect bounds = tab.bounds;
            badge.center = CGPointMake(bounds.size.width, 6);
            [tab addSubview:badge];
        }
    } else {
        [badge removeFromSuperview];
    }
}

- (void)onActionReceived:(NSNotification *)notification {
    SNBubbleTipView *bubbleView = (SNBubbleTipView *)[_searchButton viewWithTag:kSearchButtonBubbleTag];
    UIImage *image = [UIImage imageNamed:@"icohome_dot_v5.png"];
    CGFloat pointY = 0;
    if (image.size.width > 4) {
        pointY = 13;
    } else {
        pointY = 15;
    }
    if (bubbleView) {
        [bubbleView setBubbleImageFrame:CGRectMake(30, pointY, image.size.width, image.size.height) withImage:image];
    }
}

@end
