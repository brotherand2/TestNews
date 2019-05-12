//
//  SNCenterToastView.m
//  sohunews
//
//  Created by Scarlett on 16/8/31.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNCenterToastView.h"
#import "SNCheckAnimationView.h"
#import "SNUserManager.h"
#import "SNTripletsLoadingView.h"

#define kLoadingViewWidth    59.f
#define kLoadingViewHeight   57.f

#define kOnlySingleWordBackViewHeight 120.0/2
#define kOnlyDoubleWordBackViewHeight 126.0/2
#define kSingleWordBackViewHeight 180.0/2
#define kSingleWordBackViewWidth 196.0/2
#define kDoubleWordBackViewHeight 216.0/2
#define kDoubleWordBackViewWidth 236.0/2

#define kCenterToastTitleLeftDistance 28.0/2
#define kCenterToastImageWidth 52.0/2
#define kCenterToastImageHeight 52.0/2
#define kCenterToastImageTopDistance 36.0/2
#define kCenterToastImageBottomDistance 20.0/2

#define kBackViewCornerRadius 8.0/2
#define kBackViewAlpha 0.9
#define kOnlyWordMaxCount 10
#define kWordMaxCount 6

#define kCenterBackViewTag 100000000


@interface SNCenterToastView ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) SNCheckAnimationView *animationView;
@property (nonatomic, strong) SNTripletsLoadingView *tripleLoadingView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, assign) CGFloat animationDuration;

@end

@implementation SNCenterToastView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, kSingleWordBackViewWidth, kSingleWordBackViewHeight);
    }
    
    return self;
}


- (void)showToastWithMode:(SNCenterToastMode)mode{
    if ([self.toastText isEqual:[NSNull null]]) {
        return;
    }
    
    if ([[self rootView] viewWithTag:kCenterBackViewTag]) {
        UIView *view = [[self rootView] viewWithTag:kCenterBackViewTag];
        UILabel *label = [view viewWithTag:kCenterBackViewTag+1];
        if ([label.text isEqualToString:NSLocalizedString(@"Please wait",@"")]) {
            [label removeFromSuperview];
            [view removeFromSuperview];
        }
        else {
            return;
        }
    }
    
    //self.backView 是在backView方法中创建的
    [[self rootView] addSubview:self.backView];
   
    self.toastMode = mode;
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    [self resetBackViewSize];
    
    self.backView.transform = CGAffineTransformMakeScale(0.6, 0.6);
    self.backView.alpha = 0.2;
    
    [UIView animateWithDuration:0.11 animations:^{
        self.backView.alpha = kBackViewAlpha;
        self.backView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        [self.backView addSubview:self.textLabel];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.04 animations:^{
            self.backView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished){
            
        }];
    }];
}

-(void)hideToast{
    [self.textLabel removeFromSuperview];
    [self.backView removeFromSuperview];
    self.targetView = nil;
//    [UIView animateWithDuration:0.1 animations:^{
//        self.backView.transform = CGAffineTransformMakeScale(0.6, 0.6);
//        self.backView.alpha = 0.2;
//    } completion:^(BOOL finished) {
//        [self.backView removeFromSuperview];
//        self.targetView = nil;
//    }];
}

- (void)showCenterToastWithMode:(SNCenterToastMode)mode {
    if ([self.toastText isEqual:[NSNull null]]) {
        return;
    }
    
    if ([[self rootView] viewWithTag:kCenterBackViewTag]) {
        UIView *view = [[self rootView] viewWithTag:kCenterBackViewTag];
        UILabel *label = [view viewWithTag:kCenterBackViewTag+1];
        if ([label.text isEqualToString:NSLocalizedString(@"Please wait",@"")]) {
            [label removeFromSuperview];
            [view removeFromSuperview];
        }
        else {
            return;
        }
    }
    if (mode == SNCenterToastModeLoading) {
        [self.backgroundView addSubview:self.backView];
        [[self rootView] addSubview:self.backgroundView];
    }else if (mode == SNCenterToastModeSuccess || mode == SNCenterToastModeError){
        [self.backgroundView addSubview:self.backView];
        [[self rootView] addSubview:self.backgroundView];
    }else{
        [[self rootView] addSubview:self.backView];
    }
    
    self.toastMode = mode;
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    [self resetBackViewSize];
    self.backView.transform = CGAffineTransformMakeScale(0.6, 0.6);
    self.backView.alpha = 0.2;
    [UIView animateWithDuration:0.11 animations:^{
        self.backView.alpha = kBackViewAlpha;
        self.backView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        [self.backView addSubview:self.textLabel];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.04 animations:^{
            self.backView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished){
            if (mode == SNCenterToastModeSuccess) {
                if (self.toastUrl.length > 0 || _toProfile) {
                    [self addDetailButton];
                }
                self.animationDuration = 1.5;
                [self showCheckCenterToast];
            }
            else if (mode == SNCenterToastModeLoading) {
                [self showLoadingToast];
                if (self.cancelButtonClickedBlock) {
                    [self addCancelButton];
                }
            }
            else {
                self.animationDuration = 1.0;
                [self showNormalCenterToast];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)self.animationDuration*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                if (mode != SNCenterToastModeLoading) {
                    [self hideCenterToast];
                }
            });
        }];
        
    }];
    
}

- (void)showCheckCenterToast {
    self.animationView = [[SNCheckAnimationView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.backView.width, kCenterToastImageTopDistance*3)];
    [self.backView addSubview:self.animationView];
    [self.animationView startSuccessAnimation];
    if (self.isFullScreen) {
        self.animationView.transform = CGAffineTransformMakeRotation(90.0*M_PI/180.0);
        self.animationView.origin = CGPointMake(self.animationView.origin.x + 30.0, self.animationView.origin.y + 35.0);
    }
}

- (void)showLoadingToast {
    self.tripleLoadingView = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.backView.width, kCenterToastImageTopDistance*3)];
    [self.tripleLoadingView setColorVideoMode:YES];
    [self.backView insertSubview:self.tripleLoadingView belowSubview:self.textLabel];
    [self.tripleLoadingView setStatus:SNTripletsLoadingStatusLoading];
    
}

- (void)hideLoadingToast {
    [self.tripleLoadingView setStatus:SNTripletsLoadingStatusStopped];
    [self.tripleLoadingView removeFromSuperview];
    self.tripleLoadingView = nil;
    [_backgroundView removeFromSuperview];
    _backgroundView = nil;
    [self hideCenterToast];
}

- (void)showNormalCenterToast {
    if (self.toastMode == SNCenterToastModeError) {
        self.iconImageView.image = [UIImage imageNamed:@"ico_x_v5.png"];
    }
    else if (self.toastMode == SNCenterToastModeWarning) {
        self.iconImageView.image = [UIImage imageNamed:@"ico_plaint_v5.png"];
    }
}

- (void)addDetailButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:kCorpusContentShow forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    [button sizeToFit];
    button.size = CGSizeMake(self.backView.width, button.size.height);
    button.top = self.textLabel.bottom + kCenterToastImageBottomDistance - 5.0;
    [button setTitleColor:SNUICOLOR(kThemeText7Color) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(detailAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:button];
    
    if (self.isFullScreen) {
        button.transform = CGAffineTransformMakeRotation(90.0*M_PI/180.0);
        button.origin = CGPointMake(button.origin.x - 35.0, button.origin.y - 62.0);
    }
    
}

- (void)addCancelButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:kCorpusContentCancel forState:UIControlStateNormal];
    [button.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    [button sizeToFit];
    button.size = CGSizeMake(self.backView.width, button.size.height);
    button.top = self.textLabel.bottom + kCenterToastImageBottomDistance - 5.0;
    [button setTitleColor:SNUICOLOR(kThemeText7Color) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:button];
    
    if (self.isFullScreen) {
        button.transform = CGAffineTransformMakeRotation(90.0*M_PI/180.0);
        button.origin = CGPointMake(button.origin.x - 35.0, button.origin.y - 62.0);
    }
    
}

- (void)cancelAction:(id)sender {
    if (self.cancelButtonClickedBlock) {
        self.cancelButtonClickedBlock();
    }
    [self hideLoadingToast];
    [self hideCenterToast];
}

- (void)detailAction:(id)sender {
    [SNUtility shouldUseSpreadAnimation:NO];
    
    [self hideCenterToast];
    if (_toProfile) {
        if (_urlButtonClickedBlock) {
            [self hideCenterToast];
            _urlButtonClickedBlock();
            return;
        }
    }
    
    if ([self.toastUrl containsString:@"showType="]) {
        [SNNewsReport reportADotGif:@"_act=push&_tp=inread"];
    }
    [SNUtility openProtocolUrl:self.toastUrl context:self.userInfo];
}

- (void)hideCenterToast {
    if (self.toastMode == SNCenterToastModeSuccess) {
        [self.animationView removeFromSuperview];
    }
    else {
        [self.iconImageView removeFromSuperview];
    }
    
    [self.textLabel removeFromSuperview];
    [UIView animateWithDuration:0.1 animations:^{
        self.backView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        self.backView.alpha = 0.2;
    } completion:^(BOOL finished) {
        [self.backView removeFromSuperview];
        [self.backgroundView removeFromSuperview];
        self.targetView = nil;
    }];
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = SNUICOLOR(kThemeText5Color);
        _textLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC + 1.0];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.tag = kCenterBackViewTag + 1;
    }
    
    return _textLabel;
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.backView.frame.size.width - kCenterToastImageWidth)/2, kCenterToastImageTopDistance, kCenterToastImageWidth, kCenterToastImageHeight)];
        [self.backView addSubview:_iconImageView];
    }
    
    return _iconImageView;
}

- (UIView *)rootView {
    if (self.targetView) {
        return self.targetView;
    }
    
    return [UIApplication sharedApplication].keyWindow;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:self.bounds];
        _backView.layer.cornerRadius = kBackViewCornerRadius;
        _backView.layer.masksToBounds = YES;
        _backView.backgroundColor = SNUICOLOR(kThemeCenterToastBgColor);
        _backView.center = self.center;
        _backView.centerY -= _verticalOffset;
        _backView.alpha = 0.5;
        _backView.tag = kCenterBackViewTag;
    }
    
    return _backView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backgroundView.backgroundColor = [UIColor clearColor];
    }
    return _backgroundView;
}

- (void)resetBackViewSize {
    CGSize backViewSize = CGSizeZero;
    self.textLabel.text = self.toastText;
    [self.textLabel sizeToFit];
    if (self.toastMode == SNCenterToastModeOnlyText) {
        //纯文本 Toast
        CGSize textSize = CGSizeZero;
        if ([self.toastText convertStringToLength] > (2 * kOnlyWordMaxCount)) {
            
            textSize = [@"搜狐新闻客户端的长度搜狐新闻客户端" getTextSizeWithFontSize:kThemeFontSizeC + 1.0];
            self.textLabel.numberOfLines = 0;
            self.textLabel.size = CGSizeMake(textSize.width, textSize.height*2 + 5.0);
            textSize = self.textLabel.size;
        }
        else {
            textSize = [self.toastText getTextSizeWithFontSize:kThemeFontSizeC + 1.0];
        }
        
        self.textLabel.origin = CGPointMake(kCenterToastTitleLeftDistance, kCenterToastTitleLeftDistance);
        
        backViewSize = CGSizeMake(textSize.width + 2*kCenterToastTitleLeftDistance, textSize.height + 2*kCenterToastTitleLeftDistance);
    }
    else {
        if ([self.toastText convertStringToLength] > 2*kWordMaxCount) {
            self.textLabel.numberOfLines = 0;
            CGSize textSize = [@"搜狐新闻客户" getTextSizeWithFontSize:kThemeFontSizeC + 1.0];
            self.textLabel.numberOfLines = 0;
            self.textLabel.size = CGSizeMake(textSize.width, textSize.height*2 + 5.0);
            self.textLabel.origin = CGPointMake(kCenterToastTitleLeftDistance, kCenterToastImageTopDistance + kCenterToastImageHeight  + kCenterToastImageBottomDistance);
            if (self.toastUrl.length > 0) {
                backViewSize = CGSizeMake(kDoubleWordBackViewWidth, kDoubleWordBackViewHeight + textSize.height);
            }
            else {
                backViewSize = CGSizeMake(kDoubleWordBackViewWidth, kDoubleWordBackViewHeight);
            }
        }
        else {
            if ([self.toastText convertStringToLength] == 2*kWordMaxCount) {
                CGSize textSize = [@"搜狐新闻客户" getTextSizeWithFontSize:kThemeFontSizeC + 1.0];
                backViewSize = CGSizeMake(textSize.width + 2 * kCenterToastTitleLeftDistance, kSingleWordBackViewHeight);
            }
            else {
                backViewSize = CGSizeMake(kSingleWordBackViewWidth, kSingleWordBackViewHeight);
            }
            
            if (self.toastUrl.length > 0 || self.toProfile) {
                backViewSize = CGSizeMake(kDoubleWordBackViewWidth, kDoubleWordBackViewHeight);
            }
            
            self.textLabel.center = CGPointMake(backViewSize.width/2, backViewSize.height/2);
            self.textLabel.top = kCenterToastImageTopDistance + kCenterToastImageHeight  + kCenterToastImageBottomDistance;
        }
    }
    
    self.size = backViewSize;
    self.backView.size = backViewSize;
    if (self.isFullScreen) {
        if ([self rootView].width < [self rootView].height) {
            self.backView.center = [self rootView].center;
            self.backView.centerY -= _verticalOffset;
            if (self.toastMode != SNCenterToastModeOnlyText) {
                self.backView.size = CGSizeMake(self.backView.size.height, self.backView.size.width);
                CGAffineTransform transForm = CGAffineTransformMakeRotation(90.0*M_PI/180.0);
                self.textLabel.transform = transForm;
                self.iconImageView.transform = transForm;
                self.textLabel.origin = CGPointMake(self.textLabel.origin.x, self.textLabel.origin.y - 13.0);
                self.iconImageView.origin = CGPointMake(self.iconImageView.origin.x + 25.0, self.iconImageView.origin.y + 30.0);
            }
            else {
                CGAffineTransform transForm = CGAffineTransformMakeRotation(90.0*M_PI/180.0);
                self.textLabel.transform = transForm;
                self.backView.size = CGSizeMake(self.backView.size.height, self.backView.size.width);
                self.backView.center = [self rootView].center;
                self.backView.centerY -= _verticalOffset;
                if ([self.toastText convertStringToLength] > 2*kOnlyWordMaxCount) {
                    self.textLabel.origin = CGPointMake(self.textLabel.origin.x - 50.0, self.textLabel.origin.y + 51.0);
                }
                else {
                    CGPoint point = CGPointZero;
                    NSInteger textLength = [self.toastText convertStringToLength];
                    if (textLength == 2*kOnlyWordMaxCount) {
                        point = CGPointMake(self.textLabel.origin.x - 63.0, self.textLabel.origin.y + 63.0);
                    }
                    else if (textLength == 18) {
                        point = CGPointMake(self.textLabel.origin.x - 55.0, self.textLabel.origin.y + 55.0);
                    }
                    else if (textLength == 16) {
                        point = CGPointMake(self.textLabel.origin.x - 48.0, self.textLabel.origin.y + 48.0);
                    }
                    else if (textLength == 14) {
                        point = CGPointMake(self.textLabel.origin.x - 48.0, self.textLabel.origin.y + 49.0);
                    }
                    else if (textLength == 12) {
                        point = CGPointMake(self.textLabel.origin.x - 33.0, self.textLabel.origin.y + 33.0);
                    }
                    
                    else {
                        point = CGPointMake(self.textLabel.origin.x - 40.0, self.textLabel.origin.y + 40.0);
                    }
                    self.textLabel.origin = point;
                }
            }
        }
        else {
            self.backView.center = CGPointMake([self rootView].center.y, [self rootView].center.x);
            self.backView.centerY -= _verticalOffset;
        }
    }
    else {
        self.backView.center = [self rootView].center;
        self.backView.centerY -= _verticalOffset;
    }
    if (_toastMode == SNCenterToastModeLoading) {
        self.size = CGSizeMake(backViewSize.width, kCenterToastImageTopDistance*3 - 8);
        self.backView.size = CGSizeMake(backViewSize.width, kCenterToastImageTopDistance*3 - 8);
        if (self.toastText.length > 0) {
            self.textLabel.top = kCenterToastImageTopDistance*2;
            self.size = CGSizeMake(backViewSize.width, kCenterToastImageTopDistance*3);
            self.backView.size = CGSizeMake(backViewSize.width, kCenterToastImageTopDistance*3);
        }
        if (self.cancelButtonClickedBlock) {
            self.size = backViewSize;
            self.backView.size = backViewSize;
        }
    }
}

@end
