//
//  SNJDActivityAlert.m
//  sohunews
//
//  Created by TengLi on 2017/6/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSpecialActivityAlert.h"
#import "SNSpecialActivityReportRequest.h"
#import "SNSpecialAD.h"
#import "SHH5NewsWebViewController.h"
#import "SNCommonNewsController.h"
#import "SNRollingNewsViewController.h"
#import "SNUtility.h"
#import "SNWindow.h"
#import "NSCellLayout.h"
#import "NSTimer+SNBlocksSupport.h"

#define KAnimationMaxTime 5.0
#define kChannelCloseButtonWidth            (22.f)
@interface SNSpecialActivityAlert ()

@property (nonatomic, strong) NSDictionary *activityInfo;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, weak) SNSpecialAD *adData;
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UIImageView *animationImageView;
@property (nonatomic, strong) NSTimer *animationTimer;//动画timer
@property (nonatomic, assign) NSInteger imageShowCount;//显示动画帧数
@property (nonatomic, strong) NSMutableArray *animationImageDataArray;//帧比特流
@property (nonatomic, assign) NSInteger animationTimes;//动画播放次数，避免低性能手机动画5s内不能播完
@property (nonatomic, strong) NSTimer *durationTimer;//持续时长timer
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, assign) BOOL isBecomingDismiss;
@property (nonatomic, assign) BOOL isBecomingShow;

@end

@implementation SNSpecialActivityAlert

- (instancetype)initWithAlertViewData:(id)content
{
    self = [super init];
    if (self) {
        [self setAlertViewData:content];
        self.alertViewType = SNAlertViewSpecialActivityType;
        self.backImageView = [UIImageView new];
    }
    return self;
}

- (BOOL)adResourceAvailable {
    return  self.animationImageDataArray.count > 0;
}

- (void)setAdType:(SNFloatingADType)adType {
    _adType = adType;
    switch (adType) {
        case SNFloatingADTypeHomePage:
        {
            [self buildUITypeHomePage];
            break;
        }
            
        case SNFloatingADTypeChannels:
        {
            [self buildUITypeChannels];
            break;
        }
            
        case SNFloatingADTypeNewsDetail:
        {
            [self buildUITypeNewsDetail];
            break;
        }
        default:
            break;
    }
    self.backImageView.userInteractionEnabled = YES;
    [self addSubview:self.backImageView];
    [self.backImageView addGestureRecognizer:self.tapGesture];
}

- (void)buildUITypeHomePage {
    self.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight);
    self.backImageView.frame = self.bounds;
    UIImage *backImage = [UIImage imageNamed:@"special_activity_background.png"];
    backImage = [backImage stretchableImageWithLeftCapWidth:2.0 topCapHeight:2.0];
    self.backImageView.image = backImage;
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.backImageView addSubview:self.animationImageView];
    [self addCloseButton];
}

- (void)didTap:(UIGestureRecognizer *)gesture {
    [self dismissAlertViewCompleted:^{
        
    }];
}

- (void)buildUITypeChannels {
    self.frame = CGRectMake(0, 0, CELL_IMAGE_HEIGHT + 22, CELL_IMAGE_HEIGHT + 22);
    CGFloat tabbarHeight = [[SNUtility getApplicationDelegate] appTabbarController].tabbarView.height;
    self.left = kAppScreenWidth;
    self.bottom = kAppScreenHeight - tabbarHeight - 16;
    self.backImageView.frame = CGRectMake(0, 22, CELL_IMAGE_HEIGHT, CELL_IMAGE_HEIGHT);
    self.animationImageView.frame = self.backImageView.bounds;
    self.backImageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterActivityPage)];
    [self.backImageView addSubview:self.animationImageView];
    [self addCloseButton];
}

- (void)buildUITypeNewsDetail {
    CGFloat ratio = 0.5;
    self.frame = CGRectMake(0, 0, kAppScreenWidth, kAppScreenWidth * ratio);
    self.backImageView.frame = self.bounds;
    self.backImageView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    self.animationImageView.backgroundColor = [UIColor clearColor];
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterActivityPage)];
    [self.backImageView addSubview:self.animationImageView];
    [self addCloseButton];
}

- (void)setAlertViewData:(id)content {
    if (content && [content isKindOfClass:[NSDictionary class]]) {
        self.activityInfo = content;
    }else if (content && [content isKindOfClass:[SNSpecialAD class]]) {
        self.adData = content;
    }
    
}

- (void)showAlertView {
    if (_isBecomingShow) {
        return;
    }
    _isBecomingShow = YES;
    [super showAlertView];
    [SNUtility sharedUtility].isShowSpecialActivity = YES;
    [self specialActivityShowReport];
    _isShowing = YES;
    switch (self.adType) {
        case SNFloatingADTypeHomePage:
        {
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            [self setImageViewAnimation];
            _isBecomingShow = NO;
            break;
        }
            
        case SNFloatingADTypeChannels:
        {
            UIViewController * vc = [TTNavigator navigator].topViewController;
            if ([vc isKindOfClass:[SNRollingNewsViewController class]]) {
                [vc.view addSubview:self];
                [UIView animateWithDuration:0.5 animations:^{
                    self.right = kAppScreenWidth - 14;
                } completion:^(BOOL finished) {
                    _isBecomingShow = NO;
                }];
                [self setImageViewAnimation];
                [[SNSpecialActivity shareInstance] setCurrentShowingChannelAlert:self];
            }
            break;
        }
            
        case SNFloatingADTypeNewsDetail:
        {
            SNWindow *window = (SNWindow *)[SNUtility getApplicationDelegate].window;
            window.listenScreenTouch = YES;
            [SNNotificationManager addObserver:self selector:@selector(onScreenTouch:) name:@"nScreenTouch" object:nil];

            UIViewController * vc = [TTNavigator navigator].topViewController;
            if ([vc isKindOfClass:[SHH5NewsWebViewController class]] || [vc isKindOfClass:[SNCommonNewsController class]]) {
                UIView * postFollow = nil;
                if ([vc isKindOfClass:[SHH5NewsWebViewController class]]) {
                    postFollow = ((SHH5NewsWebViewController *)vc).postFollow.textFieldBgView;
                }else if ([((SNCommonNewsController *)vc).currentController isKindOfClass:[SHH5NewsWebViewController class]]){
                    postFollow = ((SHH5NewsWebViewController *)((SNCommonNewsController *)vc).currentController).postFollow.textFieldBgView;
                }
                if (postFollow) {
                    if (!self.durationTimer) {
                        self.durationTimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(durationTimerDidBurnOut) userInfo:nil repeats:NO];
                        [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSRunLoopCommonModes];
                    }
                    
                    self.top = vc.view.height;
                    [vc.view insertSubview:self belowSubview:postFollow];
                    [vc.view addSubview:postFollow];//insert没有起作用，所以add了一下
                    [UIView animateWithDuration:0.5 animations:^{
                        self.bottom = vc.view.height - postFollow.height;
                    } completion:^(BOOL finished) {
                        _isBecomingShow = NO;
                    }];
                    [self setImageViewAnimation];
                }

            }
            break;
        }
        default:
            _isBecomingShow = NO;
            _isShowing = YES;
            break;
    }
    [self.adData didShow];
}

- (void)durationTimerDidBurnOut {
    [self dismissAlertViewCompleted:^{
        
    }];
}

- (void)onScreenTouch:(NSNotification *)notification {
    UIEvent *event=[notification.userInfo objectForKey:@"data"];
    NSSet *allTouches = event.allTouches;
    for (UITouch *touch in allTouches){
        BOOL touchSelf = NO;
        for (UIView * subView in self.subviews) {
            if (touch.view == subView || touch.view == self) {
                touchSelf = YES;
            }
        }
        if (!touchSelf) {
            [self dismissAlertViewCompleted:^{
                
            }];
            return;
        }
    }
}


- (void)setImageViewAnimation {
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak SNSpecialActivityAlert * weakSelf = self;
        self.animationTimer = [NSTimer sn_timerWithTimeInterval:[self getPerFrameAnimationTime] repeats:YES block:^() {
            SNSpecialActivityAlert * strongSelf = weakSelf;
            [strongSelf loopImageView];
        }];
        if (self.adType == SNFloatingADTypeChannels || self.adType == SNFloatingADTypeNewsDetail) {
            //用timer做帧动画没必要用CommonModes，会影响scrollView的滚动的
            [[NSRunLoop mainRunLoop] addTimer:self.animationTimer forMode:NSDefaultRunLoopMode];
        }else {
            [[NSRunLoop mainRunLoop] addTimer:self.animationTimer forMode:NSRunLoopCommonModes];
        }
    });
}

- (void)loopImageView {
    SNDebugLog(@"SNSpecialActivityAlert Repeats Timer is Running !!!%d",self.imageShowCount);
    
    if (!self.animationImageDataArray) {
        self.animationImageDataArray = [self getAnimationImageDataArray];
    }
    if (self.animationImageDataArray.count == 0) {
        self.animationTimes = 0;
        [self dismissAlertViewCompleted:^{
            
        }];
        return;
    }
    if (self.closeButton.hidden) {
        self.closeButton.hidden = NO;
    }
    if (self.imageShowCount < [self.animationImageDataArray count]) {
        self.animationImageView.image = [UIImage imageWithData:[self.animationImageDataArray objectAtIndex:self.imageShowCount]];
        self.imageShowCount++;
    }
    else {
        self.animationTimes++;
        if (self.animationTimes >= [self getImageAnimationTimes] || [self getImageAnimationTimes] == 0) {
            if (self.adType == SNFloatingADTypeChannels || self.adType == SNFloatingADTypeNewsDetail) {
                
            }else{
                self.animationTimes = 0;
                [self dismissAlertViewCompleted:^{
                    
                }];
                return;
            }
        }
        //轮询播放
        [self.animationTimer invalidate];
        self.animationTimer = nil;
        self.imageShowCount = 0;
        [self setImageViewAnimation];
    }
}

- (UIImageView *)animationImageView {
    if (!_animationImageView) {
        _animationImageView = [UIImageView new];
        _animationImageView.frame = [self getImageRect];
        UITapGestureRecognizer *tapActivity = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enterActivityPage)];
        _animationImageView.userInteractionEnabled = YES;
        _animationImageView.contentMode = UIViewContentModeScaleAspectFill;
        [_animationImageView addGestureRecognizer:tapActivity];
    }
    
    return _animationImageView;
}

- (void)addCloseButton {
    
    UIImage * btnImg = nil;
    
    if (self.adType == SNFloatingADTypeChannels || self.adType == SNFloatingADTypeNewsDetail) {
        btnImg = [[UIImage alloc] initWithContentsOfFile:[SNSpecialADTools imagePathWithMajorkey:self.adData.spaceId imageName:@"activity_close.png"]];
        if (!btnImg) {
            btnImg = [UIImage imageNamed:@"activity_close.png"];
        }
    }else{
        btnImg = [[UIImage alloc] initWithContentsOfFile:[SNUtility getImagePathWithName:@"activity_close.png"]];
    }
    
    if (!btnImg) {
        return;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:btnImg forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(didClickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton = button;
    self.closeButton.hidden = YES;
    if (self.adType == SNFloatingADTypeChannels) {
        self.closeButton.frame = CGRectMake(0, 0, 22, 22);
        self.closeButton.left = self.animationImageView.right;
        [self addSubview:self.closeButton];
    }
    else if (self.adType == SNFloatingADTypeNewsDetail) {
        self.closeButton.frame = CGRectMake(0, 0, 32, 32);
        self.closeButton.top = self.animationImageView.top;
        self.closeButton.right = self.animationImageView.right - 8;
        [self.backImageView addSubview:self.closeButton];
    }else{
        self.closeButton.frame = CGRectMake(0, 0, btnImg.size.width, btnImg.size.height);
        self.closeButton.top = self.animationImageView.top;
        self.closeButton.right = self.animationImageView.right;
        [self.backImageView addSubview:self.closeButton];
    }
}

- (void)didClickCloseButton:(UIButton *)sender {
    [self.adData cantSeeInDay];
    [self dismissAlertViewCompleted:^{
        
    }];
}

- (void)enterActivityPage {
    NSString *urlString = nil;
    if (self.adType == SNFloatingADTypeChannels || self.adType == SNFloatingADTypeNewsDetail) {
        urlString = self.adData.actUrl;
    }else{
       urlString = [[SNSpecialActivity shareInstance].activityInfo stringValueForKey:kSpecialActivityActUrl defaultValue:@""];
    }
    if (urlString.length > 0) {
        [self specialActivityClickReport];
        [SNUtility openUniversalWebView:@{kLink : urlString}];
    }
    
    [self dismissAlertViewCompleted:^{
        
    }];
}

- (void)dismissAlertViewCompleted:(SNSpecialAlertDismissCompletedBlock)dismissCompleted {
    if (_isBecomingDismiss) {
        return;
    }
    _isBecomingDismiss = YES;
    switch (self.adType) {
        case SNFloatingADTypeHomePage:
        {
            _isShowing = NO;
            [self clearView];
            [SNUtility sharedUtility].isShowSpecialActivity = NO;
            [super dismissAlertView];
            _isBecomingDismiss = NO;
            dismissCompleted();
            break;
        }
            
        case SNFloatingADTypeChannels:
        {
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                _isShowing = NO;
                [self clearView];
                [SNUtility sharedUtility].isShowSpecialActivity = NO;
                [super dismissAlertView];
                _isBecomingDismiss = NO;
                dismissCompleted();
            }];
            break;
        }
            
        case SNFloatingADTypeNewsDetail:
        {
            SNWindow *window = (SNWindow *)[SNUtility getApplicationDelegate].window;
            window.listenScreenTouch = NO;
            
            UIViewController * vc = [TTNavigator navigator].topViewController;
            if ([vc isKindOfClass:[SHH5NewsWebViewController class]] || [vc isKindOfClass:[SNCommonNewsController class]]) {
                [UIView animateWithDuration:0.5 animations:^{
                    self.top = vc.view.height;
                } completion:^(BOOL finished) {
                    _isShowing = NO;
                    [self clearView];
                    [SNUtility sharedUtility].isShowSpecialActivity = NO;
                    [super dismissAlertView];
                    _isBecomingDismiss = NO;
                    dismissCompleted();
                }];
            }
            break;
        }
        default:
        {
            _isShowing = NO;
            [self clearView];
            [SNUtility sharedUtility].isShowSpecialActivity = NO;
            [super dismissAlertView];
            _isBecomingDismiss = NO;
            dismissCompleted();
        }
            break;
    }
}

- (void)clearView {
    if (self.animationTimer) {
        [self.animationTimer invalidate];
        self.animationTimer = nil;
    }
    [self.durationTimer invalidate];
    self.durationTimer = nil;
    self.animationImageDataArray = nil;
    self.animationImageView.image = nil;
    self.animationImageView = nil;
    self.imageShowCount = 0;
    [self.backImageView removeFromSuperview];
    self.backImageView = nil;
    [SNNotificationManager removeObserver:self];
    [self removeFromSuperview];
}

- (NSMutableArray *)getAnimationImageDataArray {
    NSMutableArray *muArray = [NSMutableArray arrayWithCapacity:0];
    NSInteger imageCount = [self getImageCount];
    UIImage *closeImage = nil;
    if (self.adType == SNFloatingADTypeChannels || self.adType == SNFloatingADTypeNewsDetail) {
        closeImage = [[UIImage alloc] initWithContentsOfFile:[SNSpecialADTools imagePathWithMajorkey:self.adData.spaceId imageName:@"activity_close.png"]];
    }else{
        closeImage = [[UIImage alloc] initWithContentsOfFile:[SNUtility getImagePathWithName:@"activity_close.png"]];
    }
    if (!closeImage) {
        imageCount = imageCount + 1;
    }

    for (NSInteger i = 1; i < imageCount; i ++) {
        NSString *imageName = nil;
        if ([[SNDevice sharedInstance] isPlus]) {
            imageName = [NSString stringWithFormat:@"activity_%d@3x.png", i];
        }
        else {
            imageName = [NSString stringWithFormat:@"activity_%d@2x.png", i];
        }
        NSString *imagePath = nil;
        NSData *imageData = nil;
        if (self.adType == SNFloatingADTypeChannels || self.adType == SNFloatingADTypeNewsDetail) {
            imageData = [NSData dataWithContentsOfFile:[SNSpecialADTools imagePathWithMajorkey:self.adData.spaceId imageName:imageName]];
            if (!imageData) {
                imageName = [NSString stringWithFormat:@"activity_%d.png", i];
                imageData = [NSData dataWithContentsOfFile:[SNSpecialADTools imagePathWithMajorkey:self.adData.spaceId imageName:imageName]];
            }
        }else{
            imagePath = [SNUtility getImagePathWithName:imageName];
            imageData = [NSData dataWithContentsOfFile:imagePath];//使用data可以降低图片较多时消耗的内存
        }
        if (imageData) {
            [muArray addObject:imageData];
        }
    }
    
    return muArray;
}

- (NSInteger)getImageCount {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray * imageArray = nil;
    if (self.adType == SNFloatingADTypeChannels || self.adType == SNFloatingADTypeNewsDetail) {
        imageArray = [fileManager contentsOfDirectoryAtPath:[SNSpecialADTools rootPathWithMajorkey:self.adData.spaceId] error:nil];
    }else{
        imageArray = [fileManager contentsOfDirectoryAtPath:[SNUtility getImagePathWithName:nil] error:nil];
    }
    return [imageArray count];
}

- (CGFloat)getImageAnimationDuration {
    NSInteger imageCount = [self getImageCount];
    UIImage *image = nil;
    if (self.adType == SNFloatingADTypeChannels || self.adType == SNFloatingADTypeNewsDetail) {
        image = [[UIImage alloc] initWithContentsOfFile:[SNSpecialADTools imagePathWithMajorkey:self.adData.spaceId imageName:@"activity_close.png"]];
    }else{
        image = [[UIImage alloc] initWithContentsOfFile:[SNUtility getImagePathWithName:@"activity_close.png"]];
    }
    if (image) {
        imageCount = imageCount - 1;
    }
    
    return [self getPerFrameAnimationTime] * imageCount;
}

- (CGFloat)getPerFrameAnimationTime {
    if (self.adType == SNFloatingADTypeChannels || self.adType == SNFloatingADTypeNewsDetail) {
        return self.adData.displayTimeLength / 1000;
    }else{
        NSString *perFrameTime = [self.activityInfo stringValueForKey:kSpecialActivityDisplayTimeLength defaultValue:@""];
        return [perFrameTime floatValue] / 1000;
    }
}

- (NSInteger)getImageAnimationTimes {
    if (self.adType == SNFloatingADTypeChannels || self.adType == SNFloatingADTypeNewsDetail) {
        return self.adData.playTimes;
    }else{
        NSString *times = [self.activityInfo stringValueForKey:kSpecialActivityPlayTimes defaultValue:@""];
        return [times integerValue];
    }
}

- (CGRect)getImageRect {
    CGFloat pointX = 0;
    CGFloat pointY = 0;
    NSInteger alignCenter = [self getImageAlignCenter];//0无效，1水平居中，2垂直居中，3屏幕居中
    NSInteger alignSide = [self getImageAlignSide];//0无效，1右对齐，2下对齐，3屏幕右下角
    if (alignCenter == 0) {
        if (alignSide == 0) {
            pointX = [self getImagePositionX];
            pointY = [self getImagePositionY];
        }
        else if (alignSide == 1) {
            pointX = kAppScreenWidth - [self getImageShowWidth];
            pointY = [self getImagePositionY];
        }
        else if (alignSide == 2) {
            pointX = [self getImagePositionX];
            pointY = kAppScreenHeight - [self getImageShowHeight];
        }
        else if (alignSide == 3) {
            pointX = kAppScreenWidth - [self getImageShowWidth];
            pointY = kAppScreenHeight - [self getImageShowHeight];
        }
    }
    else if (alignCenter == 1) {
        pointX = (kAppScreenWidth - [self getImageShowWidth]) / 2;
        if (alignSide == 2) {
            pointY = kAppScreenHeight - [self getImageShowHeight];
        }
        else {
            pointY = [self getImagePositionY];
        }
    }
    else if (alignCenter == 2) {
        if (alignSide == 1) {
            pointX = kAppScreenWidth - [self getImageShowWidth];
        }
        else {
            pointX = [self getImagePositionX];
        }
        
        pointY = (kAppScreenHeight - [self getImageShowHeight]) / 2;
    }
    else if (alignCenter == 3) {
        pointX = (kAppScreenWidth - [self getImageShowWidth]) / 2;
        pointY = (kAppScreenHeight - [self getImageShowHeight]) / 2;
    }
    CGFloat width = [self getImageShowWidth];
    CGFloat height = [self getImageShowHeight];
    if (width == 0) {
        width = self.backImageView.width;
    }
    if (height == 0) {
        height = self.backImageView.height;
    }
    return CGRectMake(pointX, pointY, width, height);
}

- (NSInteger)getImageAlignCenter {
    NSString *alignCenter = [self.activityInfo stringValueForKey:kSpecialActivityAlignCenter defaultValue:@""];
    return [alignCenter integerValue];
}

- (NSInteger)getImageAlignSide {
    NSString *alignSide = [self.activityInfo stringValueForKey:kSpecialActivityAlignSide defaultValue:@""];
    return [alignSide integerValue];
}

- (CGFloat)getImagePositionX {
    NSString *positionX = [self.activityInfo stringValueForKey:kSpecialActivityXAxisPercent defaultValue:@""];
    return [positionX floatValue] * kAppScreenWidth;
}

- (CGFloat)getImagePositionY {
    NSString *positionY = [self.activityInfo stringValueForKey:kSpecialActivityYAxisPercent defaultValue:@""];
    return [positionY floatValue] * kAppScreenHeight;
}

- (CGFloat)getImageShowWidth {
    NSString *ratio = [self.activityInfo stringValueForKey:kSpecialActivityMaterialRatio defaultValue:@""];
    return [ratio floatValue] * kAppScreenWidth;
}

- (CGFloat)getImageShowHeight {
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[SNUtility getImagePathWithName:@"activity_1.png"]];
    CGFloat imageScale = 0;
    if (image) {
        imageScale = (image.size.height / image.size.width);
    }
    return [self getImageShowWidth] * imageScale;
}

//曝光上报
- (void)specialActivityShowReport {
    NSString *expsAdverUrl = nil;
    NSString *expsMonitorUrl = nil;
    NSString *from = @"";
    
    if (self.adType == SNFloatingADTypeChannels) {
        expsMonitorUrl = self.adData.expsMonitorUrl;
        expsAdverUrl = self.adData.expsAdverUrl;
        from = @"4";
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=ad_expos&_tp=pv&from=%@&channelid=%@", from, self.adData.spaceId]];
    } else if (self.adType == SNFloatingADTypeNewsDetail) {
        expsMonitorUrl = self.adData.expsMonitorUrl;
        expsAdverUrl = self.adData.expsAdverUrl;
        from = @"3";
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=ad_expos&_tp=pv&from=%@", from]];
    } else {
        NSDictionary *dict = [SNSpecialActivity shareInstance].activityInfo;
        expsMonitorUrl = [dict stringValueForKey:kSpecialActivityExpsMonitorUrl defaultValue:@""];
        expsAdverUrl = [dict stringValueForKey:kSpecialActivityExpsAdverUrl defaultValue:@""];
        from = @"5";
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=ad_expos&_tp=pv&from=%@", from]];
    }
    if (expsMonitorUrl.length > 0) {
        [[[SNSpecialActivityReportRequest alloc] initWithSpecialActivityURLString:expsMonitorUrl] send:^(SNBaseRequest *request, id responseObject) {} failure:^(SNBaseRequest *request, NSError *error) {}];
    }
    if (expsAdverUrl.length > 0) {
        [[[SNSpecialActivityReportRequest alloc] initWithSpecialActivityURLString:expsAdverUrl] send:^(SNBaseRequest *request, id responseObject) {} failure:^(SNBaseRequest *request, NSError *error) {}];
    }
}

//点击上报
- (void)specialActivityClickReport {
    NSString *clickAdverUrl = nil;
    NSString *clickMonitorUrl = nil;
    NSString *from = @"";
    if (self.adType == SNFloatingADTypeChannels) {
        clickMonitorUrl = self.adData.clickMonitorUrl;
        clickAdverUrl = self.adData.clickAdverUrl;
        from = @"4";
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=ad_clk&_tp=clk&from=%@&channelid=%@", from, self.adData.spaceId]];
    } else if (self.adType == SNFloatingADTypeNewsDetail) {
        clickMonitorUrl = self.adData.clickMonitorUrl;
        clickAdverUrl = self.adData.clickAdverUrl;
        from = @"3";
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=ad_clk&_tp=clk&from=%@", from]];
    } else {
        NSDictionary *dict = [SNSpecialActivity shareInstance].activityInfo;
        clickMonitorUrl = [dict stringValueForKey:kSpecialActivityClickMonitorUrl defaultValue:@""];
        clickAdverUrl = [dict stringValueForKey:kSpecialActivityClickAdverUrl defaultValue:@""];
        from = @"5";
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=ad_clk&_tp=clk&from=%@", from]];
    }
    if (clickMonitorUrl.length > 0) {
        [[[SNSpecialActivityReportRequest alloc] initWithSpecialActivityURLString:clickMonitorUrl] send:^(SNBaseRequest *request, id responseObject) {} failure:^(SNBaseRequest *request, NSError *error) {}];
    }
    if (clickAdverUrl.length > 0) {
        [[[SNSpecialActivityReportRequest alloc] initWithSpecialActivityURLString:clickAdverUrl] send:^(SNBaseRequest *request, id responseObject) {} failure:^(SNBaseRequest *request, NSError *error) {}];
    }
}

- (void)dealloc {

}

@end
