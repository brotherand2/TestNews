//
//  SNSplashViewController.m
//  sohunews
//
//  Created by Dan on 8/13/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNSplashViewController.h"
#import "SNAdvertiseManager.h"
#import "SNBrandView.h"
#import "SNAppConfigFestivalIcon.h"
#import "SNRollingNewsPublicManager.h"
#import "SNNewsShareManager.h"
#import "SNCommentEditorViewController.h"
#import "SNStatisticsManager.h"
#import "SNAlertStackManager.h"
#import "SNSpecialActivity.h"
#import "SNClientRegister.h"
#import "SNRollingNewsViewController.h"

@interface SNSplashViewController () <CAAnimationDelegate> {
    BOOL _isBecomeActive;//从后台切回来
    UIView *_adView;
    BOOL _isFirstLoading;
    BOOL _isUserCenter;
    BOOL _adViewDidShow;
    NSInteger _isFristPullAd;//纪录第一次拉出loading页,1为第一次拉出loading页
    BOOL _isFirstPerdonw;  //每次启动完预加载一次
    NSTimer  * _timer;
}
@property (nonatomic, retain) SNBrandView * brandView;//品牌区域
@property (nonatomic, retain) UIPanGestureRecognizer *panSwipeRecognizer;
@property (nonatomic, retain) SNNewsShareManager *shareManager;

@end

@implementation SNSplashViewController

@synthesize isSplashDecelorating;

#pragma mark - Lifecycle
- (id)initWithRefer:(SNSplashViewRefer)splashViewRefer delegate:(id<SNSplashViewDelegate>)delegate{
	self = [super init];
    if (self) {
        _splashViewRefer = splashViewRefer;
        if (_splashViewRefer == (SNSplashViewReferRollingNewsHorizontalSliding | SNSplashViewReferUserCenter)) {
            _isUserCenter = YES;
        }
        _delegate = delegate;
        _isFristPullAd = 0;
        [self initUI];
        if (_splashViewRefer == SNSplashViewReferAppLaunching) {
//            // APP启动刷新setting.go
//            [[SNAppConfigManager sharedInstance] requestConfigAsync];
            
            // 设置用户track起点
            [[SNUserTrackRecorder sharedRecorder] setLoadingPage:[SNUserTrack trackWithPage:splash link2:nil]];
            
//            ////这一坨是为了解决之前装过APP卸载后，再次安装，准确识别新激活用户的问题
//            ////就为了新激活的用户，不去展示loading广告
//            BOOL isRegisted = [SNClientRegister sharedInstance].isRegisted && [SNClientRegister sharedInstance].isDeviceModelAdapted;
//            BOOL isRegistedUserInKeychain = [SNClientRegister sharedInstance].isRegistedInKeychain;
//            
//            if (!isRegisted && !isRegistedUserInKeychain) {
//                
//                [[SNClientRegister sharedInstance] registerClientAnywaySuccess:^(SNBaseRequest *request) {
//                    BOOL isNewUser = NO;
//                    NSDictionary * registInfo = [[SNClientRegister sharedInstance] keychainClientInfo];
//                    if (registInfo) {
//                        ///isNewActivation=1 是新激活的用户  为0是已注册的用户
//                        isNewUser = [registInfo intValueForKey:@"isNewActivation" defaultValue:0];
//                    }
//                    if (isNewUser) {
//                        [self enterApp];
//                        [_delegate splashViewDidShow];
//                        [[SNStatisticsManager shareInstance] recordAppStartStage:@"t6"];
//                    }else{
//                        // 记录APP启动发起广告请求的时间戳
//                        [[SNStatisticsManager shareInstance] recordAppStartStage:@"t1"];
//                        [self requestSplashAdWithTimeout];
//                    }
//                } fail:^(SNBaseRequest *request, NSError *error) {
//                    // 记录APP启动发起广告请求的时间戳
//                    [[SNStatisticsManager shareInstance] recordAppStartStage:@"t1"];
//                    [self requestSplashAdWithTimeout];
//                }];
//            }else{
                // 记录APP启动发起广告请求的时间戳
                [[SNStatisticsManager shareInstance] recordAppStartStage:@"t1"];
                [self requestSplashAdWithTimeout];
//            }
        }else if (_splashViewRefer == SNSplashViewReferWillEnterForeground) {
            _isBecomeActive = YES;
            [self requestSplashAdWithTimeout];
        }
    }
    return self;
}

- (void)initUI {
    if (!_fullscreenWindow) {
        _fullscreenWindow = [[UIWindow alloc] initWithFrame:TTScreenBounds()];
        _fullscreenWindow.windowLevel = UIWindowLevelAlert + 2.0f;//2是为了挡住alertView
        _fullscreenWindow.hidden = NO;
        [_fullscreenWindow setRootViewController:[[UIViewController alloc] init]];
    }
    if (!_screenshotArea) {
        _screenshotArea = [[UIView alloc] initWithFrame:_fullscreenWindow.bounds];
        [_fullscreenWindow addSubview:_screenshotArea];
    }
    if (!_contentCanvas) {
        _contentCanvas = [[UIView alloc] initWithFrame:_fullscreenWindow.bounds];
        [_screenshotArea addSubview:_contentCanvas];
    }
    if (!_photoView) {
        _photoView = [[SNWebImageView alloc] initWithFrame:_fullscreenWindow.bounds];
        _photoView.backgroundColor = [UIColor clearColor];
        _photoView.ignorePicMode = YES;
        _photoView.showFade = YES;
        [_contentCanvas addSubview:_photoView];
        _photoView.contentMode = UIViewContentModeScaleToFill;
        [_photoView setDefaultImage:[self getDefaultSplashImg]];
        [self showDefaultSplashImg];
    }
    if (!_brandView) {
        _brandView = [[SNBrandView alloc] initWithFrame:CGRectMake(0, _fullscreenWindow.bounds.size.height - 115, _fullscreenWindow.bounds.size.width, 115)];
        if (kAppScreenWidth == kIPHONE_6P_WIDTH) {
            _brandView.frame = CGRectMake(0, _fullscreenWindow.bounds.size.height - 380.0f/3.0f, _fullscreenWindow.bounds.size.width, 385.0f/3.0f) ;
        }else if(kAppScreenWidth == kIPHONE_4_WIDTH){
            _brandView.frame = CGRectMake(0, _fullscreenWindow.bounds.size.height - 196.0f/2.0f, _fullscreenWindow.bounds.size.width, 195.0f/2.0f) ;
        }
        
        if([UIScreen mainScreen].bounds.size.height == kIPHONE_X_HEIGHT){
            _brandView.frame = CGRectMake(0, _fullscreenWindow.bounds.size.height - 447/3.0f, _fullscreenWindow.bounds.size.width, 447/3.0f) ;
        }
        //默认隐藏
        _brandView.alpha = 0.0f;
        [_contentCanvas insertSubview:_brandView aboveSubview:_photoView];
    }
    if (!_shadowMask) {
        _shadowMask = [[UIImageView alloc] initWithFrame:CGRectMake(_contentCanvas.width, 0, 20, _contentCanvas.height)];
        _shadowMask.backgroundColor = [UIColor clearColor];
        _shadowMask.image = [UIImage imageNamed:@"popshadow.png"];
        _shadowMask.transform = CGAffineTransformMakeScale(-1, 1);//水平翻转
        _shadowMask.hidden = YES;
        [_contentCanvas addSubview:_shadowMask];
    }
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (kAppScreenWidth == kIPHONE_4_WIDTH) {
            _shareBtn.frame = CGRectMake(kAppScreenWidth - 44,kAppScreenHeight - 46,44, 44);
        }else if (kAppScreenWidth == kIPHONE_6_WIDTH){
            _shareBtn.frame = CGRectMake(kAppScreenWidth - 44,kAppScreenHeight - 46,44, 44);
        }else {
            _shareBtn.frame = CGRectMake(kAppScreenWidth - 44,kAppScreenHeight - 46,44, 44);
        }
        
        if([UIScreen mainScreen].bounds.size.height == kIPHONE_X_HEIGHT) {
            _shareBtn.frame = CGRectMake(kAppScreenWidth - 44,kAppScreenHeight - 46 - 36,44, 44);
        }
        [_shareBtn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        _shareBtn.backgroundColor = [UIColor clearColor];
        _shareBtn.exclusiveTouch = YES;
        [_shareBtn setImage:[UIImage imageWithBundleName:@"icotext_share_v5.png"] forState:UIControlStateNormal];
        [_shareBtn setImage:[UIImage imageWithBundleName:@"icotext_sharepress_v5.png"] forState:UIControlStateSelected];
        _shareBtn.accessibilityLabel = @"分享封面图";
        _shareBtn.alpha = 0;
        [_contentCanvas insertSubview:_shareBtn aboveSubview:_brandView];
    }
    
    if (_adView) {
        _adView.frame = _fullscreenWindow.bounds;
        [_contentCanvas insertSubview:_adView belowSubview:_brandView];
        [self addPanGestureRecognizerView:_contentCanvas removeView:_adView];
        
        _brandView.alpha = 1.0f;
        _shareBtn.alpha = 1.0f;
    } else {
        [self addPanGestureRecognizerView:_contentCanvas removeView:nil];
    }
    if (_splashViewRefer != SNSplashViewReferAppLaunching) {
        _fullscreenWindow.left = -_fullscreenWindow.width;
    }
}

- (void)addTimeLimit {
    _adViewDidShow = NO;
    if (![_timer isValid]) {
        _timer = [NSTimer timerWithTimeInterval:1.5 target:self selector:@selector(needForceEnterApp) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)removeTimer {
    if ([_timer isValid]) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
}

- (void)requestSplashViewFromAdSDK:(BOOL)isFirstLoad
{
    _isFirstLoading = isFirstLoad;
    [[SNAdvertiseManager sharedManager] getNewsOpenisFirstLoad:isFirstLoad loadDidFinished:^(BOOL success, UIViewController *controller, NSTimeInterval oadInterval) {
        _adViewDidShow = YES;
        if (success) {
            //广告展示出来的时间
            [[SNStatisticsManager shareInstance] recordAppStartStage:@"t2"];
            if (_adView) {
                if (_adView != controller.view) {
                    [self addAdViewController:controller.view isShareBtn:1.0];
                    if (_isBecomeActive) {
                        [self showSplashView];
                    }
                } else {
                    _shareBtn.alpha = 1.0;
                }
            } else {
                [self addAdViewController:controller.view isShareBtn:1.0];
                if (_isBecomeActive) {
                    [self showSplashView];
                }
            }
        } else {//SDK说现在没有回调这个地方
            if (_isFirstLoading) {
                if ([NSThread currentThread].isMainThread) {
                    [self enterApp];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self enterApp];
                    });
                }
            }
        }
        if (_splashViewRefer == SNSplashViewReferAppLaunching)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_delegate splashViewDidShow];
            });
        }

    } playDidFinished:^(BOOL success, UIViewController *controller) {
        if (success) {
            if (_isFirstLoading) {
                if ([NSThread currentThread].isMainThread) {
                    [self enterApp];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self enterApp];
                    });
                }
            }
        } else {
            /// 空广告
            _adViewDidShow = YES;
            if (!_adView) {
                if (_splashViewRefer == SNSplashViewReferAppLaunching)
                {
                    //广告展示出来的时间
                    [[SNStatisticsManager shareInstance] recordAppStartStage:@"t2"];
                    [_delegate splashViewDidShow];
                }
                if (_isFirstLoading) {
                    if ([NSThread currentThread].isMainThread) {
                        [self enterApp];
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self enterApp];
                        });
                    }
                }
                [self addAdViewController:controller.view isShareBtn:0];
            } else {
                if (_isFirstLoading) {
                    if ([NSThread currentThread].isMainThread) {
                        [self enterApp];
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self enterApp];
                        });
                    }
                }
                if (_adView != controller.view) {
                    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
                        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
                        return;//无网络提示，不需要添加空白页面，还是展示上次的页面
                    }

                    [self addAdViewController:controller.view isShareBtn:0];
                } else {
                    _shareBtn.alpha = 0;
                }
                [self pushToIntroChannel];
            }
        }
    } didClicked:^(NSString *loadingString) {
        if (loadingString && loadingString.length > 0) {
            if ([NSThread currentThread].isMainThread) {
                [self enterApp];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self enterApp];
                });
            }
            [self adClick:loadingString];
        }
    }];
}

- (void)requestSplashAdWithTimeout {
    // APP启动广告返回时长控制
    [self addTimeLimit];
    // 后台调起需要展现广告时 从广告SDK请求广告
    [self requestSplashViewFromAdSDK:YES];
}

- (void)needForceEnterApp{
    /// 如果广告还是没有展示出来，强制进入 APP
    if (!_adViewDidShow) {
        [self enterApp];
    }
}

- (void)addAdViewController:(UIView *)adView isShareBtn:(CGFloat)isShareBtn
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_contentCanvas) {
            [self addPanGestureRecognizerView:adView removeView:_contentCanvas];
            adView.alpha = 0;
            adView.frame = _fullscreenWindow.bounds;
            [_contentCanvas insertSubview:adView belowSubview:_brandView];
            _brandView.alpha = 1.0f;
            _shareBtn.alpha = isShareBtn;
            [UIView animateWithDuration:0.2 animations:^{
                if (_adView && _adView != adView) {
                    _adView.alpha = 0;
                }
                adView.alpha = 1;
            }completion:^(BOOL finished) {
                if (_adView && _adView != adView) {
                    [_adView removeFromSuperview];
                }
                _adView = adView;
            }];
        } else {
            _adView = adView;
        }
    });
 }

- (UIPanGestureRecognizer *)panSwipeRecognizer
{
    if (_panSwipeRecognizer == nil) {
        _panSwipeRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanSwipe:)];
        _panSwipeRecognizer.minimumNumberOfTouches = 1;
        _panSwipeRecognizer.delegate = self;
    }
    return _panSwipeRecognizer;
}

- (void)addPanGestureRecognizerView:(UIView *)addView removeView:(UIView *)removeView
{
    if (removeView) {
        [removeView removeGestureRecognizer:self.panSwipeRecognizer];
    }
    [addView addGestureRecognizer:self.panSwipeRecognizer];
}

- (void)adClick:(NSString *)url
{
    [SNUtility shouldUseSpreadAnimation:NO];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        [query setObject:[NSNumber numberWithInt:REFER_LOADING] forKey:kRefer];
        [SNUtility openProtocolUrl:url context:query];
    });
}

- (void)loadView {
    [super loadView];

    [SNNotificationManager addObserver:self
                              selector:@selector(userShouldGoLogin)
                                  name:kUserLoginSplashShouldDismissNotification
                                object:nil];
    
    [SNNotificationManager addObserver:self
                              selector:@selector(updateTheme)
                                  name:kThemeDidChangeNotification
                                object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.frame = CGRectZero;
}

- (void)updateTheme {
    [_shareBtn setImage:[UIImage imageWithBundleName:@"icotext_share_v5.png"] forState:UIControlStateNormal];
    [_shareBtn setImage:[UIImage imageWithBundleName:@"icotext_sharepress_v5.png"] forState:UIControlStateSelected];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _photoView.backgroundColor = [UIColor colorWithRed:0.98f green:0.98f blue:0.98f alpha:1.00f];
}

#pragma mark - Public
- (BOOL)isSplashViewVisible {
    return 0 == _fullscreenWindow.left;
}

- (void)setIsSplashViewVisible:(BOOL)isVisible {
    _fullscreenWindow.left = isVisible ? 0 : -_fullscreenWindow.width;
}

- (void)enterAppByTimeUp {
    [self enterApp];
}

#pragma mark - ===Begin: Private===
#pragma mark - Private - Splash图片加载
- (void)showDefaultSplashImg {
    [_photoView setImage:[self getDefaultSplashImg] animated:YES];
}

- (UIImage *)getDefaultSplashImg {
    double screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight == 568) {
        return [UIImage imageWithBundleName:@"Default-568h.png"];
    }else if(screenHeight == 667) {
        return [UIImage imageWithBundleName:@"Default-667h.png"];
    }else if (screenHeight == 736) {
        return [UIImage imageWithBundleName:@"Default-736h.png"];
    }else if (screenHeight == 812) {
        return [UIImage imageWithBundleName:@"Default-812h.png"];
    }else {
        return [UIImage imageWithBundleName:@"Default.png"];
    }
    
}

- (void)updateSettingsWithConfig:(SNAppConfig *)config {
    //节日图标
    SNAppConfigFestivalIcon *festivalConfig = config.festivalIcon;
    BOOL festivalIconEnable = festivalConfig.hasFestivalIcon;
    if (festivalIconEnable) {
        NSString * festivalIconUrl = festivalConfig.festivalIconUrl;
        UIImage * cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:festivalIconUrl];
        if (cacheImage) {
            [_brandView.festivalIdentity setImage:cacheImage animated:YES];
        }else{
            [_brandView.festivalIdentity loadUrlPath:festivalIconUrl];
            [[SDImageCache sharedImageCache] storeImage:_brandView.festivalIdentity.image forKey:festivalIconUrl toDisk:YES];
        }
    }

}

- (void)renderFestivalIcon {
    NSString * festivalIconUrl = [[SNAppConfigManager sharedInstance] festivalIconUrl];
    UIImage * cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:festivalIconUrl];
    if (cacheImage) {
        [_brandView.festivalIdentity setImage:cacheImage animated:YES];
    }else{
        [_brandView.festivalIdentity loadUrlPath:festivalIconUrl];
        [[SDImageCache sharedImageCache] storeImage:_brandView.festivalIdentity.image forKey:festivalIconUrl toDisk:YES];
    }
}

#pragma mark - Private - GestureRecognizer
- (void)handlePanSwipe:(UIPanGestureRecognizer*)recognizer {
    if (isSplashDecelorating) {
        return;
    }
    
    // Get the translation in the view
    CGPoint t = [recognizer translationInView:recognizer.view];
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    
    if (t.x != 0) {
        draggingLeft = t.x < 0;
    }
    
    if (_fullscreenWindow.left + t.x > 0) {
        _fullscreenWindow.left = 0;
        _contentCanvas.left = 0;
    } else {
        _fullscreenWindow.left += t.x;
        _contentCanvas.left += t.x/5.0;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded ||
        recognizer.state == UIGestureRecognizerStateCancelled)
    {
        isSplashDecelorating = YES;
        
        CGPoint vel = [recognizer velocityInView:recognizer.view];
        
        CGFloat interval = SPLASH_SLIDE_INTERVAL*300/vel.x;
        if (interval < 0) {
            interval = -interval;
        }
        if (interval > 1) {
            interval = 1;
        }
        
        if (!enteredApp) {
            [_delegate splashViewWillExit];
        }
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:draggingLeft ? @selector(exitWithAnimationDidStop) : @selector(enterWithAnimationDidStop)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:interval];
        
        _fullscreenWindow.left = draggingLeft ? -_fullscreenWindow.width : 0;
        _contentCanvas.left = draggingLeft ? -_fullscreenWindow.width * SPLASH_CONTENT_FASTER_FACTOR : 0;
        
        [UIView commitAnimations];
        if (draggingLeft && _splashViewRefer == SNSplashViewReferRollingNewsHorizontalSliding) {
            [[SNSpecialActivity shareInstance] prepareShowFloatingADWithType:SNFloatingADTypeChannels majorkey:[SNUtility sharedUtility].currentChannelId];
        }
    }
    _isFirstLoading = NO;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShowLoadingPageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

#pragma mark - Private - 显示、退出SplashView
- (void)showSplashView {
    if (_isFristPullAd == 0) {
        _isFristPullAd = 1;
    }
    _fullscreenWindow.hidden = NO;
    _shadowMask.hidden = NO;
    [self enterWithMoveAnimation:YES];
    [[SNSpecialActivity shareInstance] dismissLastChannelSpecialAlert];
}

- (void)showSplashViewWhenActive{
    if ([[[TTNavigator navigator] topViewController] isKindOfClass:[SNCommentEditorViewController class]]) {
        SNCommentEditorViewController *commentEditorViewController = (SNCommentEditorViewController *)[[TTNavigator navigator] topViewController];
        [commentEditorViewController popViewController];
    }
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    _isBecomeActive = YES;
    [self requestSplashViewFromAdSDK:YES];
}

- (void)enterApp {
    //广告展示结束，进入app
    [[SNStatisticsManager shareInstance] recordAppStartStage:@"t3"];
    [self removeTimer];
    if (!_isFirstPerdonw) {
        [[SNAdvertiseManager sharedManager] snadStartPerdonwloadWithParam];
        _isFirstPerdonw = YES;
    }
    _isFirstLoading = NO;
    [self exitWithFadeAnimation];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kShowLoadingPageKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)enterWithMoveAnimation:(BOOL)animated {
    if (isSplashDecelorating) {
        return;
    }
    _contentCanvas.left = -_contentCanvas.width * SPLASH_CONTENT_FASTER_FACTOR;
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(enterWithAnimationDidStop)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:SPLASH_SLIDE_INTERVAL];
    }
    isSplashDecelorating = YES;
    _fullscreenWindow.left = 0;
    _contentCanvas.left = 0;
    
    if (animated) {
        [UIView commitAnimations];
    } else {
        [self enterWithAnimationDidStop];
    }
}

- (void)enterWithAnimationDidStop {
    ///进入splash页，停止焦点图轮播
    NSNumber *stopFlagNum = [NSNumber numberWithBool:YES];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[SNUtility getCurrentChannelId], @"stopChannelId", stopFlagNum, @"stopFlag", nil];
    [SNNotificationManager postNotificationName:kStopPageTimerNotification object:nil userInfo:dic];

    isSplashDecelorating = NO;
    _fullscreenWindow.left = 0;
    _photoView.left = 0;
    _contentCanvas.left = 0;
    
    if (!_isBecomeActive) {
        //无网络提示，不去请求新页面，还是展示上次的页面
        if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
            [[SNCenterToast shareInstance] showCenterToastToTargetView:_fullscreenWindow title:NSLocalizedString(@"network error", @"") toUrl:nil userInfo:nil mode:SNCenterToastModeError];
        } else {
            if (_isUserCenter == YES) {
                _isFirstLoading = NO;
                [self requestSplashViewFromAdSDK:NO];
                _isUserCenter = NO;
            } else {
                if (_isFristPullAd == 1) {
                    [self requestSplashViewFromAdSDK:NO];
                    _isFristPullAd = 2;
                } else {
                    [[SNAdvertiseManager sharedManager] switchOpenAD];
                }
                _isFirstLoading = NO;
            }
        }
    }
    
    [_fullscreenWindow makeKeyAndVisible];
    if (_isBecomeActive) {
        _isBecomeActive = NO;
    }
}

- (void)exitWithFadeAnimation {
    
    if (isSplashDecelorating) {
        return;
    }
    
    if (!enteredApp) {
        [_delegate splashViewWillExit];
    }

    [self exitWithAnimationDidStop];
}

- (void)pushToIntroChannel {
    //要闻频道改版不跳推荐
    if ([SNNewsFullscreenManager newsChannelChanged]) {
        return;
    }
    //跳转到推荐频道
    if ([SNRollingNewsPublicManager sharedInstance].isNeedToPushToRecom) {
        [SNRollingNewsPublicManager sharedInstance].isNeedToPushToRecom = NO;
        
        //判断是不是爆光过要闻频道，如果没爆光过，留在要闻频道
        if (![SNUtility shouldShowEditMode]) {
            //Loading页广告结束之后, 调用跳转推荐流的动画
            [SNNotificationManager postNotificationName:SNROLLINGNEWS_PUSHTONEXTCHANNEL object:nil];
        }
    }
}

- (void)enterMainApp {
    [UIView animateWithDuration:0.15 animations:^{
        _fullscreenWindow.alpha = 1;
        isSplashDecelorating = YES;
    } completion:^(BOOL finished) {
        [[SNStatisticsManager shareInstance] recordAppStartStage:@"t6"];
        isSplashDecelorating = NO;
        _fullscreenWindow.left = -_fullscreenWindow.width;
        _fullscreenWindow.alpha = 1;
        _photoView.left = 0;
        _contentCanvas.left = 0;
        
        if (!enteredApp) {
            [_delegate splashViewDidExit];
        } else {
            [self pushToIntroChannel];
        }
        
        enteredApp = YES;
        [[SNUtility getApplicationDelegate].window makeKeyAndVisible];
        _fullscreenWindow.hidden = YES;
        [[caltime sharedInstance] end_cal_time:@"didFinishLaunchingWithOptions"];
        if ([[SNUtility sharedUtility].currentChannelId isEqualToString:@"1"]) {
            [SNUtility trigerSpecialActivity];
        }

        /// 检查是否有符合条件的弹窗
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            BOOL result = [[SNAlertStackManager sharedAlertStackManager] checkoutInStackAlertView];
            SNDebugLog(@"%zd", result);
        });

        [self setTabBarTextLabelColor];
    }];
}

- (void)setTabBarTextLabelColor {
    if ([[[TTNavigator navigator] topViewController] isKindOfClass:[SNRollingNewsViewController class]]) {
        SNRollingNewsViewController *rollingController = (SNRollingNewsViewController *)[[TTNavigator navigator] topViewController];
        rollingController.tabBar.selectedTabView.selected = YES;
    }
}

- (void)exitWithAnimationDidStop {
    //离开splash页，恢复焦点图轮播
    NSNumber *stopFlagNum = [NSNumber numberWithBool:NO];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[SNUtility getCurrentChannelId], @"stopChannelId", stopFlagNum, @"stopFlag", nil];
    [SNNotificationManager postNotificationName:kStopPageTimerNotification object:nil userInfo:dic];
    [self enterMainApp];
}

- (void)animationDidStart:(CAAnimation *)anim {
    isSplashDecelorating = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        isSplashDecelorating = NO;
    }
}


#pragma mark - Private - 分享

- (void)callShare:(NSDictionary *)dic {
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:dic FromView:_fullscreenWindow Delegate:self];
}

- (void)share {
    
    if (isSplashDecelorating) {
        return;
    }
    _isFirstLoading = NO;
 
    //wangshun share test
    NSMutableDictionary* dic = [self getShareInfo];
    [dic setObject:@"loading" forKey:@"shareLogType"];
    //disableIcons = @"moments,weChat,sohu,sina,qqZone,qq,alipay,lifeCircle,copyLink";
    [dic setObject:@"qqZone,copyLink" forKey:@"disableIcons"];//不显示qq空间和复制链接
    [self callShare:dic];
}

- (NSMutableDictionary *)getShareInfo
{
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];
    NSDictionary *adDict = [[SNAdvertiseManager sharedManager] getShareInfo];
    if (adDict) {
        NSString *title = [adDict objectForKey:@"com.sohu.SNADOpenADShareTextKey"];
        title = (title && ![title isEqualToString:@""]) ? title : NSLocalizedString(@"News to share", @"");
        NSString *imageUrl = [adDict objectForKey:@"com.sohu.SNADOpenADShareMediaKey"];
        NSString *shareContent = (title && ![title isEqualToString:@""]) ? title : NSLocalizedString(@"SMS share to friends for splash", @"");
        
        [dicShareInfo setObject:title forKey:kShareInfoKeyTitle];
        [dicShareInfo setObject:imageUrl forKey:kShareInfoKeyImageUrl];
        [dicShareInfo setObject:imageUrl forKey:@"url"];
        [dicShareInfo setObject:shareContent forKey:kShareInfoKeyContent];
        
        //[dicShareInfo setObject:@"1" forKey:kPresentFromWindowDelegate];
        [dicShareInfo setObject:@"0" forKey:kShareInfoKeyNewsId];
        [dicShareInfo setObject:@"loading" forKey:@"contentType"];
        //    [dicShareInfo setObject:@"https://www.baidu.com" forKey:kShareInfoKeyWebUrl];
        //    [dicShareInfo setObject:@"https://www.baidu.com" forKey:kShareInfoKeyShareLink];
        //    [dicShareInfo setObject:@"https://www.baidu.com" forKey:kShareInfoKeyMediaUrl];
        return dicShareInfo;
    }
    return nil;
}

#pragma mark - Private - Utility
- (void)pushNotificationWillCome {
    [self exitWithAnimationDidStop];
}

- (void)userShouldGoLogin {
    [self enterApp];
}

@end
