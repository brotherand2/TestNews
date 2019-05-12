//
//  SNToastView.m
//  sohunews
//
//  Created by jialei on 14-10-20.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNToastView.h"
#import "SNUserUtility.h"
#import "SNNewsReport.h"
#import "SNUserManager.h"
#define kSNToastLeftRightGap    (14 / 2)
#define kSNToastIconWidth       (50 / 2)
#define kSNToastButtonWidth     (70 / 2)
#define kSNToastIconTextGap     (22 / 2)
#define kSNToastSwipIconHeight  (28 / 2)
#define kSNtoastViewTopGap      (10)

@interface SNToastView() {
    CGAffineTransform rotationTransform;
    float _startPostionY;
    BOOL _isEnterUrl;
}

@property (atomic, strong) NSTimer *showTimer;
@property (atomic, strong) NSTimer *hideTimer;

@property (nonatomic, strong)UILabel *tipLabel;
@property (nonatomic, strong)UIImageView *toastIcon;
@property (nonatomic, strong)UIButton *urlButton;


@end

@implementation SNToastView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark - init
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = .0;
//        self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95];
//        self.bottom = kSystemBarHeight;
        _toastUrl = nil;
        _toastText = nil;
        _startPostionY = frame.origin.y;
        _isEnterUrl = NO;
        
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = SNUICOLOR(kThemeBg4Color);
        backView.alpha = .95;
        backView.frame = self.bounds;
        [self addSubview:backView];
        
        [self setUpToastIcon];
        [self setUpToastLabel];
//        [self setUpToastActionButton];
        [self setUpToastSwipIcon];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpToHide:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
        [self addGestureRecognizer:recognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transferByUrl:)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    id me = [self initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kSNToastHeight)];
    if ([view isKindOfClass:[UIWindow class]]) {
    }
    return me;
}

#pragma mark - UI
- (void)setUpToastIcon {
    UIImage *icon = [UIImage themeImageNamed:self.iconImageName];
    self.toastIcon = [[UIImageView alloc] initWithImage:icon];
    self.toastIcon.size = CGSizeMake(kSNToastIconWidth, kSNToastIconWidth);
    self.toastIcon.left = kSNToastLeftRightGap;
    self.toastIcon.centerY = (self.height - kSNtoastViewTopGap) / 2;
    
    [self addSubview:self.toastIcon];
}

- (void)setUpToastLabel {
    float tipLabelWidth = self.width - kSNToastLeftRightGap * 2 - kSNToastIconTextGap - kSNToastButtonWidth - kSNToastIconWidth - 20;
    self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tipLabelWidth , kThemeFontSizeC)];
    self.tipLabel.left = self.toastIcon.right + kSNToastIconTextGap;
    self.tipLabel.centerY = (self.height - kSNtoastViewTopGap) / 2;
    self.tipLabel.text = self.toastText;
    self.tipLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    self.tipLabel.textColor = SNUICOLOR(kThemeText2Color);
    self.tipLabel.textAlignment = NSTextAlignmentLeft;
    self.tipLabel.backgroundColor = [UIColor clearColor];
    //toast 显示统一的字号 过长显示。。。缩略
//    self.tipLabel.adjustsFontSizeToFitWidth = YES;
//    self.tipLabel.minimumScaleFactor = kThemeFontSizeA/kThemeFontSizeC;
    
    [self addSubview:self.tipLabel];
}

- (void)setUpToastActionButtonWithTitle:(NSString *)title {
//    UIImage *linkImage = [UIImage themeImageNamed:@"icotoast_link_v5.png"];
    self.urlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.urlButton setBackgroundColor:[UIColor clearColor]];
//    [self.urlButton setImage:linkImage forState:UIControlStateNormal];
    self.urlButton.size = CGSizeMake(kSNToastButtonWidth*2, kSNToastButtonWidth);
    self.urlButton.centerY = (self.height - kSNtoastViewTopGap)  / 2;
    self.urlButton.right = self.width - kSNToastLeftRightGap;
    
    [self.urlButton addTarget:self action:@selector(transferByUrl:) forControlEvents:UIControlEventTouchUpInside];
    NSString *corpusName = [self.userInfo objectForKey:kNoCorpusFolderName];
    if (title.length > 0) {
        [self.urlButton setTitle:title forState:UIControlStateNormal];
    }
    else if ([corpusName isEqualToString:kNoCorpusCreat]) {
        [self.urlButton setTitle:kCorpusNewFavourite forState:UIControlStateNormal];
    }
    else {
        if ([[self.userInfo objectForKey:kGoSettingLocatinKey] boolValue]) {
            [self.urlButton setTitle:kGoSettingLocatin forState:UIControlStateNormal];
        }
        else {
            [self.urlButton setTitle:kCorpusContentShow forState:UIControlStateNormal];
        }
    }
    [self.urlButton setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
    [self.urlButton.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    
    [self addSubview:self.urlButton];
    if (self.toastUrl.length == 0) {
        self.urlButton.hidden = YES;
    }
}

- (void)setUpToastSwipIcon {
    UIImage *swipImage = [UIImage themeImageNamed:@"icotoast_close_v5.png"];
    UIImageView *swipImageView = [[UIImageView alloc] initWithImage:swipImage];
    swipImageView.size = swipImage.size;
    swipImageView.centerX = self.width / 2;
    swipImageView.bottom = self.height - kSNtoastViewTopGap;
    
    [self addSubview:swipImageView];
}

- (void)setToastText:(NSString *)toastText {
    _toastText = toastText;
    self.tipLabel.text = toastText;
}

- (void)setIconImageName:(NSString *)iconImageName {
    _iconImageName = iconImageName;
    UIImage *icon = [UIImage themeImageNamed:iconImageName];
    self.toastIcon.image = icon;
}

- (void)setEndInterval:(float)endInterval {
    _endInterval = endInterval;
    //重置显示时长timer
    if (self.hideTimer && [self.hideTimer isValid]) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:_endInterval
                                                          target:self
                                                        selector:@selector(handleHideTimer:)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}

- (void)setToastUrl:(NSString *)toastUrl {
    _toastUrl = toastUrl;
    if (_toastUrl.length > 0) {
        self.urlButton.hidden = NO;
    }
}
- (void)setToProfile:(BOOL)toProfile {
    _toProfile = toProfile;
    if (_toProfile) {
        self.urlButton.hidden = NO;
    }
}

#pragma mark - Show & hide
+ (SNToastView *)showToastAddedTo:(UIView *)view animated:(BOOL)animated {
    SNToastView *toastView = [[SNToastView alloc] initWithView:view];
    [view addSubview:toastView];
    [toastView show:animated];
    return toastView;
}

- (void)show:(BOOL)animated {
        _useAnimation = animated;
        // 不是立即展示，开启展示timer
        if (self.startInterval > 0.0) {
            self.showTimer = [NSTimer scheduledTimerWithTimeInterval:self.startInterval
                                                              target:self
                                                            selector:@selector(handleShowTimer:)
                                                            userInfo:nil
                                                             repeats:NO];
        }
        else {
            [self showUsingAnimation:_useAnimation];
        }
        
        //开启关闭timer
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:self.endInterval
                                                          target:self
                                                        selector:@selector(handleHideTimer:)
                                                        userInfo:nil
                                                         repeats:NO];
}

- (void)hide:(BOOL)animated {
    _useAnimation = animated;
    // If the minShow time is set, calculate how long the hud was shown,
    // and pospone the hiding operation if necessary
//    if (self.endInterval > 0.0 && _startData) {
//        NSTimeInterval interv = [[NSDate date] timeIntervalSinceDate:_startData];
//        if (interv < self.endInterval) {
//            self.endInterval = [NSTimer scheduledTimerWithTimeInterval:(self.minShowTime - interv) target:self
//                                                               selector:@selector(handleMinShowTimer:)
//                                                              userInfo:nil
//                                                               repeats:NO];
//            return;
//        } 
//    }
    [self hideUsingAnimation:_useAnimation];
}

- (void)showUsingAnimation:(BOOL)animated {
    self.startData = [NSDate date];
    self.bottom = _startPostionY;
    // Fade in
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.alpha = 1.0f;
        self.bottom = _startPostionY + kSNToastHeight;
        
        [UIView commitAnimations];
    }
    else {
        self.alpha = 1.0f;
    }
}

- (void)hideUsingAnimation:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDidStopSelector:@selector(done)];
        
        self.alpha = 0.0f;
        self.bottom = kSystemBarHeight;
        
        [UIView commitAnimations];
    }
    else {
        self.alpha = 0.0f;
        [self done];
    }
}

- (void)done {
    if (self.finishedBlock) {
        self.finishedBlock(self);
        self.finishedBlock = nil;
    }
    [self.hideTimer invalidate];
    self.hideTimer = nil;
    [self.showTimer invalidate];
    self.showTimer = nil;
    self.alpha = 0.0f;
    self.toastUrl = nil;
    self.toastText = nil;
    self.toastIcon = nil;
    [self removeAllSubviews];
    [self removeFromSuperview];
}

#pragma mark - Timer callbacks
- (void)handleShowTimer:(NSTimer *)theTimer {
    [self showUsingAnimation:_useAnimation];
}

- (void)handleHideTimer:(NSTimer *)theTimer {
    [self hideUsingAnimation:_useAnimation];
}

#pragma mark - action
- (void)transferByUrl:(UIGestureRecognizer *)recognizer {
   
    if (_toProfile) {
        if (_urlButtonClickedblock) {
            _urlButtonClickedblock();
            [self hide:NO];
            return;
        }
    }
    if (self.toastText.length > 0 && !_isEnterUrl) {
        if ([self.toastUrl containsString:@"showType="]) {
            [SNNewsReport reportADotGif:@"_act=push&_tp=inread"];
        }
        [SNUtility openProtocolUrl:self.toastUrl context:self.userInfo];
        _isEnterUrl = YES;
    }
   
   
}

- (void)handleSwipeUpToHide:(UISwipeGestureRecognizer *)recognize {
    [self hideUsingAnimation:YES];
}

@end
