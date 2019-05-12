//
//  SNTabbarView.m
//  sohunews
//
//  Created by wang yanchen on 13-1-17.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNTabbarView.h"
#import "SNNavigationController.h"
#import "SNDynamicPreferences.h"
#import "UIDevice-Hardware.h"
#import "SNDevice.h"
#import "UIFont+Theme.h"
#import "SNUserManager.h"
#import "SNNewsReport.h"
#import "SNRollingNewsPublicManager.h"
#import "SNCheckManager.h"

#define kIdentifyRightDistance ((kAppScreenWidth == 320.0) ? 16.0/2 : ((kAppScreenWidth == 375.0) ? 26.0/2 : 57.0/3))
#define kIdentifyBetweenDistance 10.0/2

@implementation SNTabBarButton
@synthesize imgSelect = _imgSelect, imgNormal = _imgNormal;

- (SNTabBarButton *)initWithFrame:(CGRect)frame normalImage:(NSString *)imgNormal selectImage:(NSString *)imgSelect text:(NSString *)text {
    self = [super initWithFrame:frame];
    if (self) {
        CGSize size = CGSizeMake(60/2, 60/2);
        if ([[SNDevice sharedInstance] isPlus]) {
            size = CGSizeMake(90/3.0, 90/3.0);
        }
        _imgNormal = [imgNormal copy];
        _imgSelect = [imgSelect copy];
        UIImage *image = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:imgNormal ImageSize:size];
        self.text = [text copy];
        
        self.tabBarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        self.tabBarImageView.image = image;
        self.tabBarImageView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.tabBarImageView.top = 0;
        [self addSubview:self.tabBarImageView];
        
        [self addSubview:self.tabBarLabel];

        
        _maskButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _maskButton.backgroundColor = [UIColor clearColor];
        [self addSubview:_maskButton];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [_maskButton addTarget:target action:action forControlEvents:controlEvents];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _maskButton.size = frame.size;
}

- (void)setTag:(NSInteger)tag {
    [super setTag:tag];
    _maskButton.tag = tag;
}

- (UILabel *)tabBarLabel {
    if (!_tabBarLabel) {
        _tabBarLabel = [[UILabel alloc] init];
        _tabBarLabel.backgroundColor = [UIColor clearColor];
        _tabBarLabel.text = self.text;
        if ([[SNDevice sharedInstance] isPlus]) {
            _tabBarLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        }
        else{
            _tabBarLabel.font = [UIFont systemFontOfSize:kThemeFontSizeA];
        }
        [_tabBarLabel sizeToFit];
        _tabBarLabel.center = self.tabBarImageView.center;
        _tabBarLabel.top = self.tabBarImageView.bottom;
    }
    
    return _tabBarLabel;
}

- (void)dealloc {
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        if (self.tag == 0) {
            [SNUtility shouldUseSpreadAnimation:YES];
        }
        else if (self.tag == 2 || self.tag == 3) {
            [SNUtility shouldUseSpreadAnimation:NO];
        }
    }
    //modify by wangyy
    CGSize size = CGSizeMake(60/2.0, 60/2.0);
    if ([[SNDevice sharedInstance] isPlus]) {
        size = CGSizeMake(90/3.0, 90/3.0);
    }
    
    UIImage *image1 = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:_imgNormal ImageSize:size];
    
    UIImage *image2 = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:_imgSelect ImageSize:size];
    self.tabBarImageView.size = image1.size;
    self.tabBarLabel.center = self.tabBarImageView.center;
    self.tabBarLabel.top = self.tabBarImageView.bottom;
    [self.tabBarImageView setImage:selected ? image2 : image1];
    
    NSString *titleNormalColorStr = [[SNDynamicPreferences sharedInstance] getDynmicColor:kThemeText6Color type:SNBottomFontColorDefaultType];
    NSString *highlightNormalColorStr = [[SNDynamicPreferences sharedInstance] getDynmicColor:kThemeRed1Color type:SNBottomFontColorSelectedType];
    UIColor *titleNormalColor = [UIColor colorFromString:titleNormalColorStr];
    UIColor *highlightNormalColor = [UIColor colorFromString:highlightNormalColorStr];
    //end

    if (selected) {
        self.tabBarLabel.textColor = highlightNormalColor;
    }
    else {
        self.tabBarLabel.textColor = titleNormalColor;
    }
    
    _isSelected = selected;
}

- (void)updateTheme {
    [self setSelected:_isSelected];
}

- (void)setIdentifyOnButton {
    if (![SNUserDefaults boolForKey:kIdentifyImageOnMeTabKey]) {
        if (!_identifyImageView) {
            self.identifyImageView.size = CGSizeMake(self.identifyLabel.width + kIdentifyBetweenDistance, self.identifyLabel.height + kIdentifyBetweenDistance);
            self.identifyImageView.center = CGPointMake(kAppScreenWidth, 0);
            self.identifyImageView.right = kAppScreenWidth - kIdentifyRightDistance;
            self.identifyLabel.center = CGPointMake(self.identifyImageView.center.x, self.identifyImageView.center.y - 1.0);
        }
        self.identifyImageView.image = [[UIImage imageNamed:@"icozw_background_v5.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 6) resizingMode:UIImageResizingModeStretch];
        self.identifyLabel.textColor = SNUICOLOR(kThemeText5Color);
    }
}

- (UIImageView *)identifyImageView {
    if (!_identifyImageView) {
        _identifyImageView = [[UIImageView alloc] init];
        [self.superview addSubview:_identifyImageView];
    }
    return _identifyImageView;
}

- (UILabel *)identifyLabel {
    if (!_identifyLabel) {
        _identifyLabel = [[UILabel alloc] init];
        _identifyLabel.text = KIdentifyOnMeText;
        _identifyLabel.font = [UIFont systemFontOfSize:kThemeFontSizeA];
        [_identifyLabel sizeToFit];
        [self.superview addSubview:_identifyLabel];
    }
    return _identifyLabel;
}

- (void)removeIdendifyOnButton {
    if (self.identifyImageView) {
        [self.identifyImageView removeFromSuperview];
        self.identifyImageView = nil;
    }
    if (self.identifyLabel) {
        [self.identifyLabel removeFromSuperview];
        self.identifyLabel = nil;
    }
}

@end

// ------------------------------------------

@implementation SNTabbarView
@synthesize viewControllers = _viewControllers;
@synthesize currentSelectedIndex = _currentSelectedIndex;
@synthesize delegate = _delegate;
@synthesize tabButtons;
@synthesize isForceClick = _isForceClick;
@synthesize coverLayer = _coverLayer;

+ (SNTabbarView *)tabbarViewWithViewControllers:(NSArray *)viewControllers {
    SNTabbarView *aView = [[SNTabbarView alloc] init];
    aView.viewControllers = viewControllers;
    return aView;
}

- (void)updateTheme {
    self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg4Color];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(2, 1, 2, 1);
    _bgnView.image = [[UIImage imageNamed:@"icotabbar_shadow_v5.png"] resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    
    [self refreshTabButton];
}

- (void)refreshTabButton {
    for (SNTabBarButton *btn in _tabButtons) {
        [btn updateTheme];
        if (btn.tag == 3) {
            [btn setIdentifyOnButton];
        }
    }
    
    [self setTabBackgroundImage];
}

- (UIImage *)tabSnapShot {
    UIWindow *window = [SNUtility getApplicationDelegate].window;
    return [UIImage imageFromView:window clipRect:CGRectMake(0, window.height - self.height, window.width, self.height)];
}

- (id)init {
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(2, 1, 2, 1);
    UIImage *tabBGImage = [[UIImage imageNamed:@"icotabbar_shadow_v5.png"] resizableImageWithCapInsets:edgeInsets];
    
    CGFloat height = (UIDevice6PlusiPhone == [[UIDevice currentDevice] platformTypeForSohuNews] || UIDevice7PlusiPhone == [[UIDevice currentDevice] platformTypeForSohuNews] || [[UIDevice currentDevice] platformTypeForSohuNews] == UIDevice8PlusiPhone) ? 146.0 / 3.0 : 44;
    
    if([[UIDevice currentDevice] platformTypeForSohuNews] == UIDeviceiPhoneX){
        height = [SNTabbarView tabBarHeightForiPhoneX];
    }
    self = [super initWithFrame:CGRectMake(0, 0, TTScreenBounds().size.width, height)];
    if (self) {
        self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg4Color];
        self.alpha = 0.95;
        _bgnView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -tabBGImage.size.height, self.width, tabBGImage.size.height)];
        _bgnView.image = tabBGImage;
        [self addSubview:_bgnView];
        
        self.coverLayer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, height)];
        self.coverLayer.backgroundColor = [UIColor blackColor];
        self.coverLayer.alpha = 0.5;
        self.coverLayer.hidden = YES;
        [self addSubview:self.coverLayer];
        
        [self setTabBackgroundImage];
    }
    //@qz 调试用
    //[self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:NULL];
    return self;
}

- (void)setTabBackgroundImage {
    if (![SNCheckManager checkDynamicPreferences]) {
        if (self.tabBackImageView) {
            self.tabBackImageView.hidden = YES;
        }
        return;
    }
    
    if (!self.tabBackImageView) {
        self.tabBackImageView = [[UIImageView alloc] initWithFrame:self.coverLayer.frame];
        [self addSubview:self.tabBackImageView];
        [self sendSubviewToBack:self.tabBackImageView];
    }
    UIImage *image = [[SNDynamicPreferences sharedInstance] getDynamicSkinImage:@"bottom_tabbar_background.png" ImageSize:self.tabBackImageView.size];
    if (image) {
        self.tabBackImageView.hidden = NO;
        self.tabBackImageView.image = image;
    }
    else {
        self.tabBackImageView.hidden = YES;
    }
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if ([change[@"new"] isKindOfClass: NSClassFromString(@"NSConcreteValue")]) {
//        NSValue *value = change[@"new"];
//    }
//}

- (NSArray *)tabButtons {
    return _tabButtons;
}

- (void)dealloc {
    _delegate = nil;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    if (_viewControllers != viewControllers) {
        _viewControllers = viewControllers;
        [self resetTabButtons];
    }
}

- (void)setCurrentSelectedIndex:(NSInteger)currentSelectedIndex {
    _currentSelectedIndex = currentSelectedIndex;
    int tmpIndex = 0;
    while (tmpIndex < _tabButtons.count) {
        SNTabBarButton *btn = [_tabButtons objectAtIndex:tmpIndex];
        
        // hack for voice over
        NSString *key = [NSString stringWithFormat:@"tab_bar_%ld", (long)btn.tag];
        NSString *value = NSLocalizedString(key, @"");
        if (tmpIndex == _currentSelectedIndex) {
            btn.selected = YES;
            btn.accessibilityLabel = [NSString stringWithFormat:@"已选定, %@", value];
        }
        else {
            btn.selected = NO;
            btn.accessibilityLabel = value;
        }
        tmpIndex++;
    }
}

- (void)resetTabButtons {
    if (_viewControllers.count == 0) {
        return;
    }
    
    if (!_tabButtons) {
        _tabButtons = [[NSMutableArray alloc] init];
    }
    else {
        for (UIView *oldBtn in _tabButtons) {
            [oldBtn removeFromSuperview];
        }
        [_tabButtons removeAllObjects];
    }
    
    CGFloat btnSpace = self.width / _viewControllers.count;
    CGFloat btnStartX = 0;
    CGFloat btnStartY = 0;
    
    for (int i = 0; i < _viewControllers.count; ++i) {
        UIViewController *vc = [_viewControllers objectAtIndex:i];
        if ([vc isKindOfClass:[SNNavigationController class]]) {
            if ([(SNNavigationController *)vc viewControllers].count > 0) {
                vc = [[(SNNavigationController *)vc viewControllers] objectAtIndex:0];
            }
        }
        NSArray *iconNames = [vc iconNames];
        NSString *tabItemText = [vc tabItemText];
        if ([iconNames count] > 1) {
            NSString *imgNormal = [iconNames objectAtIndex:0];
            NSString *imgSeleced = [iconNames objectAtIndex:1];
            
            btnStartX = i * btnSpace;
            CGRect tabbarBtnFrame = CGRectMake(btnStartX, btnStartY, btnSpace, self.height);
            SNTabBarButton *aBtn = [[SNTabBarButton alloc] initWithFrame:tabbarBtnFrame normalImage:imgNormal selectImage:imgSeleced text:tabItemText];
            aBtn.tag = i;
            
            [aBtn addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [self insertSubview:aBtn belowSubview:_coverLayer];
            [_tabButtons addObject:aBtn];
        }
    }
}

//更新tab bar name
- (void)updateTabButtonTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[SNTabBarButton class]]) {
                SNTabBarButton *tabBarButton = (SNTabBarButton *)view;
                NSString *tabName = [SNUtility getTabBarName:tabBarButton.tag];
                if (tabName.length > 0 &&
                    [tabName isKindOfClass:[NSString class]]) {
                    tabBarButton.tabBarLabel.text = tabName;
                }
            }
        }
    });
}

+ (CGFloat)tabBarHeightForiPhoneX{
    return 64.0;
}

- (void)tabButtonClicked:(UIButton *)btn {
    if (btn.tag > 0) {
        [SNUtility shouldAddAnimationOnSpread:NO];
    }
    [SNRollingNewsPublicManager sharedInstance].banScreenLandScape = NO;
    if ([SNUserDefaults boolForKey:kSpreadAnimationStartKey]) {
        return;
    }
    if (self.currentSelectedIndex != btn.tag) {
        if ([_delegate respondsToSelector:@selector(tabbarViewIndexWillChanged:)]) {
            [_delegate tabbarViewIndexWillChanged:self.currentSelectedIndex];
        }
    }

    if (self.currentSelectedIndex != btn.tag && btn.tag == 0) {
        [SNUserDefaults setBool:YES forKey:kEnterToNewsTabKey];
        [SNRollingNewsPublicManager sharedInstance].isClickBackToHomePage = YES;
    } else {
        [SNUserDefaults setBool:NO forKey:kEnterToNewsTabKey];
    }
    
    //如果从其他Tab点击首页Tab不进行刷新
    if (self.currentSelectedIndex == btn.tag && btn.tag == 0) {
        [SNRollingNewsPublicManager sharedInstance].resetOpen = YES;
        [SNRollingNewsPublicManager sharedInstance].isRecommendAfterEditNews = NO;
        [SNRollingNewsPublicManager sharedInstance].isRollingEditNewsShow = YES;
    }
    self.currentSelectedIndex = btn.tag;

    if ([_delegate respondsToSelector:@selector(tabbarViewIndexDidChanned:)]) {
        if ([SNNewsFullscreenManager newsChannelChanged]) {
            [SNRollingNewsPublicManager sharedInstance].channelRefreshClose = NO;
        }
        [_delegate tabbarViewIndexDidChanned:self.currentSelectedIndex];
    }
    
    [self addStaticForTab:btn.tag];
    
    UIViewController *rootViewController = [[TTNavigator navigator].topViewController.flipboardNavigationController rootViewController];
    if ([rootViewController respondsToSelector:@selector(showTabbarView)]) {
        [rootViewController setTabbarViewLocked:NO];
        //视频 狐友tab会overwrite这个方法 然后改变tab的top
        [rootViewController showTabbarView];
    }
}

- (void)forceClickAtIndex:(int)index {
    self.isForceClick = YES;
    if (self.currentSelectedIndex != index) {
        if ([_delegate respondsToSelector:@selector(tabbarViewIndexWillChanged:)]) {
            [_delegate tabbarViewIndexWillChanged:self.currentSelectedIndex];
        }
    }
    self.currentSelectedIndex = index;
    if ([_delegate respondsToSelector:@selector(tabbarViewIndexDidChanned:)]) {
        [_delegate tabbarViewIndexDidChanned:self.currentSelectedIndex];
    }
}

- (void)addStaticForTab:(NSInteger)tag {
    NSString *tabType = nil;
    if (tag == 0) {
        tabType = @"_act=newstab";
    }
    else if (tag == 1) {
        tabType = @"_act=vtab";
    }
    else if (tag == 2) {
        tabType = @"_act=mine";
    }else if (tag == 3) {
        tabType = @"_act=metab";
    }
    
    [SNNewsReport reportADotGif:[NSString stringWithFormat:@"%@&_tp=pv", tabType]];
}

- (void)showCoverLayer:(BOOL)show{
    if (show == YES) {
        self.coverLayer.alpha = 0.5;
        self.coverLayer.hidden = NO;
    }
    else{
        self.coverLayer.alpha = 0;
    }
}

@end
