//
//  StoryToastView.m
//  sohunews
//
//  Created by chuanwenwang on 2016/11/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryToastView.h"
#import "SNStoryContanst.h"
#import "UIViewAdditions+Story.h"
#import "UIImage+Story.h"

#define kStoryToastLeftRightGap    (14 / 2)
#define kStoryToastIconWidth       (50 / 2)
#define kStoryToastButtonWidth     (70 / 2)
#define kStoryToastIconTextGap     (22 / 2)
#define kStoryToastSwipIconHeight  (28 / 2)
#define kStorytoastViewTopGap      (10)

@interface SNStoryToastView() {
    CGAffineTransform rotationTransform;
    float _startPostionY;
    BOOL _isEnterUrl;
}

@property (atomic, strong) NSTimer *showTimer;
@property (atomic, strong) NSTimer *hideTimer;

@property (nonatomic, strong)UILabel *tipLabel;
@property (nonatomic, strong)UIButton *urlButton;


@end

@implementation SNStoryToastView

#pragma mark - init
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = .0;
        
        _toastUrl = nil;
        _toastText = nil;
        _startPostionY = frame.origin.y;
        _isEnterUrl = NO;
        
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor colorFromKey:@"kThemeCenterToastBgColor"];
        backView.alpha = .95;
        backView.frame = self.bounds;
        [self addSubview:backView];
        
        [self setUpToastLabel];
        
        UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUpToHide:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp)];
        [self addGestureRecognizer:recognizer];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(transferByUrl:)];
        [self addGestureRecognizer:tapRecognizer];
    }
    return self;
}

- (id)initWithView:(UIView *)view {
    id me = [self initWithFrame:CGRectMake(0, 0, View_Width, kStoryToastHeight)];
    if ([view isKindOfClass:[UIWindow class]]) {
    }
    return me;
}

- (void)setUpToastLabel {
    
    float tipLabelWidth = self.width - 20;
    self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, (self.height - 26/2.0f)/2, tipLabelWidth, 26/2.0f)];
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.text = self.toastText;
    self.tipLabel.font = [UIFont systemFontOfSize:26/2.0f];
    self.tipLabel.textColor = [UIColor colorFromKey:@"kThemeText5Color"];
    self.tipLabel.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.tipLabel];
}

- (void)setToastText:(NSString *)toastText {
    _toastText = toastText;
    self.tipLabel.text = toastText;
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
        self.bottom = _startPostionY + kStoryToastHeight;
        
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
        self.bottom = StoryBarHeight;
        
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
   
    /*if (_toProfile) {
        if (_urlButtonClickedblock) {
            _urlButtonClickedblock();
            [self hide:NO];
            return;
        }
    }
    if (self.toastText.length > 0 && !_isEnterUrl) {
        if ([self.toastUrl containsString:@"showType="]) {
            [SNReportUtils reportADotGif:[NSString stringWithFormat:@"_act=push&_tp=inread&p1=%@&pid=%@", [SNUserManager getP1], [SNUserManager getPid]]];
        }
        [SNUtility openProtocolUrl:self.toastUrl context:self.userInfo];
        _isEnterUrl = YES;
    }*/
   
   
}

- (void)handleSwipeUpToHide:(UISwipeGestureRecognizer *)recognize {
    [self hideUsingAnimation:YES];
}

@end
