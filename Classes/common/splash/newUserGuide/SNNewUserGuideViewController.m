//
//  SNNewUserGuideViewController.m
//  sohunews
//
//  Created by XiaoShan on 11/5/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNNewUserGuideViewController.h"
#import "SNPageControl.h"

#import "UIDevice-Hardware.h"
#import "SNRollingNewsPublicManager.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNStatisticsManager.h"
#import "SNNewsReportRequest.h"
#import "SNUserManager.h"

#define kPageCount                  (2)
#define kPageControlBottom960       (156/2.0f)
#define kPageControlBottom1136      (202/2.0f)
#define kPageControlHeight          (12/2.0f)

#define kNextPageBtnBottom960       (44/2.0f)
#define kNextPageBtnBottom1136      (62/2.0f)

#define kiPhone4SScreenHeight       (960/2.0f)
#define kiPhone5SScreenHeight       (1136/2.0f)

#define kClickNovelAreaHeight ((kAppScreenWidth > 375.0) ? 315.0/3 : ((kAppScreenWidth == 375.0) ? 190.0/2 : 162.0/2))
#define kCLickNovelAreaBottom ((kAppScreenWidth > 375.0) ? 364.0/3 : ((kAppScreenWidth == 375.0) ? 219.0/2 : ((kAppScreenHeight == 480.0) ? 133.0/2 : 185.0/2)))


@interface SNNewUserGuideViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    NSDictionary *_frameData;
    UIWindow *_fullscreenWindow;
    UIImageView *_defaultView;
    UIView *_contentView;
    UIScrollView *_scrollView;
    SNPageControl *_pageControl;
    UIButton *_nextPageBtn;
    UIButton *_skipButton;
    NSInteger _curPage;
    UISwipeGestureRecognizer *_swipeGestureRecognizer;
}
@end

@implementation SNNewUserGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = CGRectZero;
    _curPage = 0;
    [self createFullscreenWindow];
    [self createDefaultView];
    [self createContentView];
    [self createScrollView];
//    [self createPageControl];
//    [self createNextPageBtn];
    [self addSwipeGestureRecognizer];
    [self createSkipButton];
    [self reportWithAct:@"guide_page" from:_curPage];
    [[SNStatisticsManager shareInstance] recordAppStartStage:@"t4"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_delegate splashViewDidShow];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    _defaultView.hidden = YES;
    _contentView.hidden = NO;
}

#pragma mark - Private
- (CGFloat)pageControlTop {
    CGFloat bottom = kPageControlBottom1136;//默认按iPhone5s的屏幕计算
    CGFloat top = kiPhone5SScreenHeight-_pageControl.height-bottom;;
    if ([self shouldiPhone4sScreen]) {
        bottom = kPageControlBottom960;
        top = kiPhone4SScreenHeight-_pageControl.height-bottom;
    }
    return top;
}

- (BOOL)shouldiPhone4sScreen {
    UIDevicePlatform p = [[UIDevice currentDevice] platformTypeForSohuNews];
    return (p == UIDevice1GiPhone || p == UIDevice3GiPhone || p == UIDevice3GSiPhone ||
            p == UIDevice4iPhone || p == UIDevice4SiPhone || p == UIDevice1GiPod ||
            p == UIDevice2GiPod || p == UIDevice3GiPod || p == UIDevice4GiPod ||
            p == UIDevice1GiPad || p == UIDevice2GiPad || p == UIDevice3GiPad ||
            p == UIDevice4GiPad || p == UIDevice5GiPad || p == UIDevice1GiPadMini ||
            p == UIDevice2GiPadMini
            );
}

- (void)createSkipButton {
    if (kPageCount > 1) {
        _skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipButton.frame = CGRectMake(0, 60/2.f, 118/2.f, 52/2.f);
        _skipButton.right = kAppScreenWidth - 30/2.f;
        _skipButton.top = kStatusbarAddWhenCalling + 15;
        _skipButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        _skipButton.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25f];
        _skipButton.clipsToBounds = YES;
        _skipButton.layer.cornerRadius = 52/2/2.f;
        [_skipButton setTitle:@"跳过" forState:UIControlStateNormal];
        [_skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_skipButton addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_skipButton];
    }
}

- (void)skip:(UIButton *)button {
    [self reportWithAct:@"guide_skip" from:_curPage];
    [self launchApp];
}

- (void)createFullscreenWindow {
    if (!_fullscreenWindow) {
        _fullscreenWindow = [[UIWindow alloc] initWithFrame:TTScreenBounds()];
        _fullscreenWindow.backgroundColor = [UIColor clearColor];
        _fullscreenWindow.windowLevel = UIWindowLevelStatusBar + 2.0f;//提高层级
        _fullscreenWindow.hidden = NO;
        [_fullscreenWindow setRootViewController:[[UIViewController alloc] init]];
    }
}

- (void)createDefaultView {
    if (!_defaultView) {
        UIImage *defaultImg = nil;
        double screenHeight = [UIScreen mainScreen].bounds.size.height;
        if (screenHeight == 568) {
            defaultImg = [UIImage imageWithBundleName:@"Default-568h.png"];
        }else if(screenHeight == 667) {
            defaultImg = [UIImage imageWithBundleName:@"Default-667h.png"];
        }else if (screenHeight == 736) {
            defaultImg = [UIImage imageWithBundleName:@"Default-736h.png"];
        }else if (screenHeight == 812) {
            defaultImg = [UIImage imageWithBundleName:@"Default-812h.png"];
        }else {
            defaultImg = [UIImage imageWithBundleName:@"Default.png"];
        }

        _defaultView = [[UIImageView alloc] initWithFrame:_fullscreenWindow.bounds];
        _defaultView.image = defaultImg;
        [_fullscreenWindow addSubview:_defaultView];
    }
}

- (void)createContentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:_fullscreenWindow.bounds];
        _contentView.backgroundColor = [UIColor clearColor];
        [_fullscreenWindow addSubview:_contentView];
//        _contentView.hidden = YES;
    }
}

- (void)createScrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:_contentView.bounds];
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake(kPageCount*_contentView.width, _contentView.height);
        _scrollView.delegate = self;
        [_contentView addSubview:_scrollView];
    }
    
    NSString *ps = [[UIDevice currentDevice] platformStringForSohuNews];
    for (int i=0; i<kPageCount; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:_scrollView.bounds];
        NSString *imgName = nil;
        if ([ps containsString:@"iPad"]) {
            imgName = [NSString stringWithFormat:@"640x960_%d.png", i];
        } else {
            imgName = [NSString stringWithFormat:@"%@_%d.png", [[UIDevice currentDevice] screenSizeStringForSohuNews], i];
        }
        if (i == kPageCount - 1) {
            UIButton * enterAppBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            enterAppBtn.frame = CGRectMake(0, 0, imgView.frame.size.width, imgView.frame.size.height);
            enterAppBtn.backgroundColor = [UIColor clearColor];
            [enterAppBtn addTarget:self action:@selector(enterAppAction:event:) forControlEvents:UIControlEventTouchUpInside];
            imgView.userInteractionEnabled = YES;
            [imgView addSubview:enterAppBtn];
        }
        imgView.image = [UIImage imageNamed:imgName];
        [_scrollView addSubview:imgView];
        imgView.left = i*_contentView.width;
    }
}

- (void)createPageControl {
    if (!_pageControl) {
        CGRect pageControlFrame = CGRectMake(0, 0, _contentView.width, kPageControlHeight);
        _pageControl = [[SNPageControl alloc] initWithFrame:pageControlFrame];
        _pageControl.dotColorCurrentPage = [UIColor colorFromString:@"#ee2f10"];
        _pageControl.dotColorOtherPage = [UIColor colorFromString:@"#b1b1b1"];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.dotsAlignment = NSTextAlignmentCenter;
        _pageControl.numberOfPages = kPageCount;
        _pageControl.top = [self pageControlTop];
        _pageControl.hidden = YES;
        [_contentView addSubview:_pageControl];
    }
}

- (CGFloat)nextPageBtnBottom {
    //    CGFloat bottom = kNextPageBtnBottom1136;//默认按iPhone5s的屏幕计算
    //    CGFloat top = kiPhone5SScreenHeight-_nextPageBtn.height-bottom;
    //
    //    if ([self shouldiPhone4sScreen]) {
    //        bottom = kNextPageBtnBottom960;
    //        top = kiPhone4SScreenHeight-_nextPageBtn.height-bottom;
    //    }
    //    return top;
    
    CGSize size = _scrollView.bounds.size;
    
    switch ((int)size.height) {
        case 480:
            return 480 - 38;
        case 667:
            return 600;
        case 910:
            return 700;
        default:   // 默认 568:
            return size.height - 65;
    }
}

- (UIImage *)nextBtnImage
{
//    NSString *imgName = [NSString stringWithFormat:@"%@_立即体验.png", [[UIDevice currentDevice] screenSizeStringForSohuNews]];
//    UIImage *img = [UIImage imageNamed:imgName];
    
    return nil;
}

- (void)createNextPageBtn {
    if (!_nextPageBtn) {
        _nextPageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        float scale = [UIScreen mainScreen].scale == 0 ? 2 : [UIScreen mainScreen].scale;
        
        if ([[UIDevice currentDevice] platformTypeForSohuNews] == UIDevice6PlusiPhone || [[UIDevice currentDevice] platformTypeForSohuNews] == UIDevice7PlusiPhone || [[UIDevice currentDevice] platformTypeForSohuNews] == UIDevice8PlusiPhone) {
            scale = 3;
        }
        
        UIImage *btnBg = [self nextBtnImage];
        CGSize btnSize = CGSizeMake(btnBg.size.width / scale, btnBg.size.height / scale);
        float x = (_contentView.bounds.size.width - btnSize.width) / 2;
        float bottom = [self nextPageBtnBottom];
        float top = bottom - btnBg.size.height / scale;
        CGRect nextPageBtnFrame = CGRectMake(_scrollView.bounds.size.width * 2 + x, top, btnSize.width, btnSize.height);
        
        _nextPageBtn.frame = nextPageBtnFrame;
        
        [_nextPageBtn setBackgroundColor:[UIColor clearColor]];
        [_nextPageBtn setBackgroundImage:btnBg forState:UIControlStateNormal];
        [_nextPageBtn addTarget:self action:@selector(launchApp) forControlEvents:UIControlEventTouchUpInside];
        
        [_scrollView addSubview:_nextPageBtn];
    }
}

- (void)nextPage {
    CGRect toRect = CGRectMake((_pageControl.currentPage+1)*_scrollView.width,
                               0,
                               _scrollView.width,
                               _scrollView.height);
    [_scrollView scrollRectToVisible:toRect animated:YES];
}

- (void)enterAppAction:(id)sender event:(UIEvent *)event {
//    UIView *button = (UIView *)sender;
//    UITouch *touch = [[event touchesForView:button] anyObject];
//    CGPoint location = [touch locationInView:button];
//    
//    if ((location.y > kAppScreenHeight - kClickNovelAreaHeight - kCLickNovelAreaBottom) && (location.y < kAppScreenHeight - kCLickNovelAreaBottom)) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.6), dispatch_get_main_queue(), ^() {
//            NSString *novelUrl = [NSString stringWithFormat:@"%@channelId=%@&channelName=%@", kProtocolChannel, @"960415", @"小说"];
//            [SNUtility openProtocolUrl:novelUrl];
//            [SNNewsReport reportADotGif:@"_act=cc&fun=110"];
//        });
//    }
    [self reportWithAct:@"guide_in" from:_curPage];
    [self launchApp];
}

- (void)launchApp {
    [[SNStatisticsManager shareInstance] recordAppStartStage:@"t5"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kNewUserGuideHadEndShown];
    [self markNewUserGuideDidShow];
    
    if ([_delegate respondsToSelector:@selector(splashViewWillExit)]) {
        [((sohunewsAppDelegate *)_delegate) performSelector:@selector(splashViewWillExit)];
    }
    [UIView animateWithDuration:0.5 animations:^{
        _fullscreenWindow.alpha = 0;
    } completion:^(BOOL finished) {
        _fullscreenWindow.hidden = YES;
        if ([_delegate respondsToSelector:@selector(splashViewDidExit)]) {
            [((sohunewsAppDelegate *)_delegate) performSelector:@selector(splashViewDidExit)];
        }
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
            [DKNightVersionManager nightFalling];
        }else{
            [DKNightVersionManager dawnComing];
        }
        [[SNUtility getApplicationDelegate].window makeKeyAndVisible];
        [[SNStatisticsManager shareInstance] recordAppStartStage:@"t6"];
    }];
    
    [SNRollingNewsPublicManager sharedInstance].refreshClose = NO;
    [[SNRollingNewsPublicManager sharedInstance] resetLeaveHomeTime];
    
    //第一次启动app不显示“下拉提示” wangyy
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstlaunchApp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *specialActivityMD5 = [[NSUserDefaults standardUserDefaults] objectForKey:kSpecialActivityMD5Key];
    if (specialActivityMD5.length > 0) {
        [SNUtility trigerSpecialActivity];
    }
}

- (void)addSwipeGestureRecognizer {
    if (!_swipeGestureRecognizer) {
        _swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        _swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        _swipeGestureRecognizer.delegate = self;
        [_scrollView addGestureRecognizer:_swipeGestureRecognizer];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)swipe:(UISwipeGestureRecognizer *)swipeGestureRecognizer {
    if (_curPage == (kPageCount-1) &&
        swipeGestureRecognizer == _swipeGestureRecognizer &&
        swipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self reportWithAct:@"guide_in" from:_curPage];
        _scrollView.delegate = nil;//避免继续接收scrollView的代理事件
        [self launchApp];
    }
}

- (void)markNewUserGuideDidShow {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:kNewUserGuideHadBeenShown];
    [userDefaults synchronize];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _curPage = scrollView.contentOffset.x/scrollView.width;
//    _pageControl.currentPage = _curPage;
    if (_curPage == kPageCount - 1) {
        _skipButton.hidden = YES;
    }else{
        _skipButton.hidden = NO;
    }
//    if (scrollView.contentOffset.x >= (kPageCount-1)*scrollView.width)
//    {
//        _nextPageBtn.hidden = NO;
//    }
//    else
//    {
//        _nextPageBtn.hidden = YES;
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self reportWithAct:@"guide_page" from:_curPage];
}

//埋点
/*
 from 页码 1，2，3 = curPage+1
 _act=guide_page 引导页曝光
 _act=guide_skip 跳过按钮点击
 _act=guide_in  最后一页进入app
 */
- (void)reportWithAct:(NSString *)act from:(NSInteger)from {
    NSString * baseParamsStr = [NSString stringWithFormat:@"_act=%@&_tp=pv&from=%d&total=%d&p1=%@&pid=%@",act,from+1,kPageCount,[SNUserManager getP1],[SNUserManager getPid]];
    NSString *urlString = [SNAPI aDotGifUrlWithParameters:baseParamsStr];
    [[[SNNewsReportRequest alloc] initWithUrl:urlString] send:nil failure:nil];
}

@end
