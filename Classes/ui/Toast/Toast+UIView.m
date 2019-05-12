//
//  Toast+UIView.m
//  Toast
//  Version 2.0
//
//  Copyright 2013 Charles Scalesse.
//

#import "Toast+UIView.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import "SNToastWrapperView.h"
#import "SNWaitingActivityView.h"

#import "SNTripletsLoadingView.h"

/*
 *  CONFIGURE THESE VALUES TO ADJUST LOOK & FEEL,
 *  DISPLAY DURATION, ETC.
 */

// general appearance
//static const CGFloat CSToastMaxWidth            = 0.8;      // 80% of parent view width
//static const CGFloat CSToastMaxHeight           = 0.8;      // 80% of parent view height
static const CGFloat CSToastHorizontalPadding   = 15.0;
static const CGFloat CSToastVerticalPadding     = 0.0;
static const CGFloat CSToastCornerRadius        = 10.0;
static const CGFloat CSToastOpacity             = 0.8;
static const CGFloat CSToastFontSize            = 16.0;
//static const CGFloat CSToastMaxTitleLines       = 0;
static const CGFloat CSToastMaxMessageLines     = 1;
static const CGFloat CSToastFadeDuration        = 0.2;
static const CGFloat CSToastMaxMsgLabelWidth    = 280;

// shadow appearance
static const CGFloat CSToastShadowOpacity       = 0.8;
static const CGFloat CSToastShadowRadius        = 6.0;
static const CGSize  CSToastShadowOffset        = { 4.0, 4.0 };
static const BOOL    CSToastDisplayShadow       = YES;

// display duration and position
//static const CGFloat CSToastDefaultDuration     = 3.0;
static const NSString * CSToastDefaultPosition  = @"bottom";

// image view size
//static const CGFloat CSToastImageViewWidth      = 80.0;
//static const CGFloat CSToastImageViewHeight     = 80.0;

// activity
static const CGFloat CSToastActivityWidth       = 100.0;
static const CGFloat CSToastActivityHeight      = 100.0;
//static const NSString * CSToastActivityDefaultPosition = @"center";
static const NSString * CSToastActivityViewKey  = @"CSToastActivityViewKey";
static const NSString * CSToastViewKey  = @"CSToastViewKey";

@interface UIView (ToastPrivate)

- (CGPoint)centerPointForPosition:(id)position withToast:(UIView *)toast;

@end


@implementation UIView (Toast)

#pragma mark - Toast Methods

- (void)makeToast:(NSString *)message action:(NSString *)actionURL userInfo:(NSDictionary *)userInfo
       forFullScreen:(BOOL)fullScreen duration:(CGFloat)interval position:(id)position {
    
    UIView *toast = [self viewForMessage:message action:actionURL forFullScreen:fullScreen userInfo:userInfo];
    [self showToast:toast duration:interval position:position rightIcon:@"toast_close.png"];
}

- (void)makeToast:(NSString *)message image:(UIImage *)image duration:(CGFloat)interval position:(id)position {
    UIView *toast = [UIView viewForMessage:message image:image activity:NO];
    [self showToast:toast duration:interval position:position rightIcon:@"toast_close.png"];
}

- (void)makeToast:(NSString *)message image:(UIImage *)image duration:(CGFloat)interval position:(id)position arrowXPosition:(CGFloat)xPos {
    UIView *toast = [UIView viewForMessage:message image:image activity:NO];
    if (toast) {
        UIImage *arrowImage = [UIImage imageNamed:@"toast_up_arrow.png"];
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:arrowImage];
        arrowView.bottom = 5;
        arrowView.centerX = xPos;
        [toast addSubview:arrowView];
         //(arrowView);
    }
    
    [self showToast:toast duration:interval position:position rightIcon:@"toast_close.png"];
}

- (void)makeActivityToast:(NSString *)message position:(id)position {
    UIView *toast = [UIView viewForMessage:message image:nil activity:YES];
    [self showActivityToast:toast position:position];
}

- (void)showToast:(UIView *)toast duration:(CGFloat)interval position:(id)point rightIcon:(NSString *)iconname {
    BOOL bRemoveLast = NO;
    UIView *existingToastView = (UIView *)objc_getAssociatedObject(self, &CSToastViewKey);
    if (existingToastView != nil) {
        bRemoveLast = YES;
        [existingToastView removeFromSuperview];
    }

    UIView *existingActivityToastView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityToastView != nil) {
        bRemoveLast = YES;
        [existingActivityToastView removeFromSuperview];
    }
    
    UIButton *closeBtn = (UIButton *)[self viewWithTag:TOAST_CLOSE_BUTTON];
    if (closeBtn != nil) {
        [closeBtn removeFromSuperview];
    }
    
    // associate ourselves with the activity view
    objc_setAssociatedObject (self, &CSToastViewKey, toast, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    CGPoint pt = [self centerPointForPosition:point withToast:toast];
    //iphone6 和iphone plus适配 wangyy
    CGRect frame = toast.frame;
    frame.size.width = pt.x * 2;
    toast.frame = frame;
    
    toast.center = pt;
    toast.alpha = (bRemoveLast ? 1.0 : 0.0);
    [self addSubview:toast];
    
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.tag = TOAST_CLOSE_BUTTON;
    [closeBtn setImage:[UIImage imageNamed:iconname] forState:UIControlStateNormal];
    closeBtn.frame = CGRectMake(toast.width - 45, (toast.height-45)/2, 45, 45);
    if ([iconname isEqualToString:@"toast_close.png"]) {
        [closeBtn addTarget:self action:@selector(closeToast) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [closeBtn setImage:[UIImage imageNamed:iconname] forState:UIControlStateDisabled];
        closeBtn.enabled = NO;
    }

    [toast addSubview:closeBtn];
    
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         toast.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         [self performSelector:@selector(hideToastAnimation) withObject:nil afterDelay:interval];
                     }];
}

- (void)hideToastAnimation {
    UIView *toast = (UIView *)objc_getAssociatedObject(self, &CSToastViewKey);
    UIButton *closeBtn = (UIButton *)[self viewWithTag:TOAST_CLOSE_BUTTON];
    
    if (toast) {
        [UIView animateWithDuration:CSToastFadeDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             toast.alpha = 0.0;
                             //closeBtn.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [toast removeFromSuperview];
                             [closeBtn removeFromSuperview];
                             UIView *existingToastView = (UIView *)objc_getAssociatedObject(self, &CSToastViewKey);
                             if (existingToastView == toast) {
                                 objc_setAssociatedObject (self, &CSToastViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             }
                         }];
    }
}

- (void)showActivityToast:(UIView *)toast position:(id)point {
    UIView *existingToastView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingToastView != nil) return;
    
    // associate ourselves with the activity view
    objc_setAssociatedObject (self, &CSToastActivityViewKey, toast, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    toast.center = [self centerPointForPosition:point withToast:toast];
    toast.alpha = 0.0;
    [self addSubview:toast];
    
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         toast.alpha = 1.0;
                     } completion:nil];
}

- (void)makeToastActivity:(id)position {
    // sanity
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) return;
    
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CSToastActivityWidth, CSToastActivityHeight)];
    activityView.center = [self centerPointForPosition:position withToast:activityView];
    activityView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:CSToastOpacity];
    activityView.alpha = 0.0;
    activityView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    activityView.layer.cornerRadius = CSToastCornerRadius;
    
    if (CSToastDisplayShadow) {
        activityView.layer.shadowColor = [UIColor blackColor].CGColor;
        activityView.layer.shadowOpacity = CSToastShadowOpacity;
        activityView.layer.shadowRadius = CSToastShadowRadius;
        activityView.layer.shadowOffset = CSToastShadowOffset;
    }
    
    
    // Cae 37是大菊花的系统固定尺寸
    SNTripletsLoadingView *activityIndicatorView = [[SNTripletsLoadingView alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];

    //UIActivityIndicatorView *activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2);
    [activityView addSubview:activityIndicatorView];
    //[activityIndicatorView startAnimating];
    activityIndicatorView.status = SNTripletsLoadingStatusLoading;
    
    // associate ourselves with the activity view
    objc_setAssociatedObject (self, &CSToastActivityViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addSubview:activityView];
    
    [UIView animateWithDuration:CSToastFadeDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         activityView.alpha = 1.0;
                     } completion:nil];
}

- (void)hideActivityToast {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:CSToastFadeDuration
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &CSToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                             
                              if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
                              {
                                  UIButton* closeButton = (UIButton*)[self viewWithTag:TOAST_CLOSE_BUTTON];
                                  closeButton.alpha = 0.0f;
                              }
                         }];
    }
}

#pragma mark - Private Methods

- (CGPoint)centerPointForPosition:(id)point withToast:(UIView *)toast {
    if([point isKindOfClass:[NSString class]]) {
        // convert string literals @"top", @"bottom", @"center", or any point wrapped in an NSValue object into a CGPoint
        if([point caseInsensitiveCompare:@"top"] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width/2, (toast.frame.size.height / 2) + CSToastVerticalPadding);
        } else if([point caseInsensitiveCompare:@"bottom"] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)) - CSToastVerticalPadding);
        } else if([point caseInsensitiveCompare:@"center"] == NSOrderedSame) {
            return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
    } else if ([point isKindOfClass:[NSValue class]]) {
        return [point CGPointValue];
    }
    
    return [self centerPointForPosition:CSToastDefaultPosition withToast:toast];
}

+ (UIView *)viewForMessage:(NSString *)message image:(UIImage *)image activity:(BOOL)showActivity {

    if (message == nil && image == nil) return nil;

    UILabel *messageLabel = nil;
    UIImageView *imageView = nil;
    
    UIImageView *wrapperView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"toast_bg.png"]];
    
    wrapperView.userInteractionEnabled = YES;
    
    CGFloat left = CSToastHorizontalPadding;
    
    if (showActivity) {
        SNWaitingActivityView *activityIndicatorView = [[SNWaitingActivityView alloc] init];
        activityIndicatorView.center = CGPointMake(left + activityIndicatorView.width/2, wrapperView.height/2);
        [activityIndicatorView startAnimating];
        
        [wrapperView addSubview:activityIndicatorView];
        
        left += activityIndicatorView.width + CSToastHorizontalPadding;
    }
    
    if (image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(left, (wrapperView.height-imageView.height)/2 + 2, imageView.width, imageView.height);
        [wrapperView addSubview:imageView];
        
        left += imageView.width + CSToastHorizontalPadding;
    }
    
    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = CSToastMaxMessageLines;
        messageLabel.font = [UIFont systemFontOfSize:CSToastFontSize];
        messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        messageLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        
        [messageLabel sizeToFit];
        
        messageLabel.frame = CGRectMake(left, (wrapperView.height-messageLabel.height)/2 + 2, MIN(messageLabel.width,CSToastMaxMsgLabelWidth), messageLabel.height);
        [wrapperView addSubview:messageLabel];
    }
    
    return wrapperView;
}

- (void)closeToast {
//    UIView *existingToastView = (UIView *)objc_getAssociatedObject(self, &CSToastViewKey);
//    if (existingToastView != nil) {
//        [existingToastView.layer removeAllAnimations];
//    }
//    
//    UIButton* closeButton = (UIButton*)[self viewWithTag:TOAST_CLOSE_BUTTON];
//    [closeButton removeFromSuperview];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideToastAnimation) object:nil];
    [self hideToastAnimation];
}

#pragma mark - Toast with action
- (UIView *)viewForMessage:(NSString *)message action:(NSString *)actionURL forFullScreen:(BOOL)fullScreen userInfo:(NSDictionary *)userInfo {
    if (message == nil) {
        return nil;
    }
    
    NSMutableDictionary *tempUserInfo = [NSMutableDictionary dictionary];
    if (userInfo.count > 0) {
        [tempUserInfo setValuesForKeysWithDictionary:userInfo];
    }
    if (actionURL.length > 0) {
        [tempUserInfo setValue:actionURL forKey:kToast_ActionURL];
    }
    
    SNToastWrapperView *wrapperView = [[SNToastWrapperView alloc] initWithImage:[UIImage imageNamed:@"toast_bg.png"]];
    wrapperView.userInfo = tempUserInfo;
    wrapperView.forFullScreen = fullScreen;
    wrapperView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openWithActionURL:)];
    [wrapperView addGestureRecognizer:tapGR];
    tapGR.delegate = nil;
    tapGR = nil;

    if (message != nil) {
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = CSToastMaxMessageLines;
        messageLabel.font = [UIFont systemFontOfSize:CSToastFontSize];
        messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        messageLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        
        [messageLabel sizeToFit];
        
        messageLabel.frame = CGRectMake(CSToastHorizontalPadding, (wrapperView.height-messageLabel.height)/2 + 2,
                                        MIN(messageLabel.width,CSToastMaxMsgLabelWidth), messageLabel.height);
        [wrapperView addSubview:messageLabel];
    }
    
    return wrapperView;
}

- (void)openWithActionURL:(UITapGestureRecognizer *)gesture {
    SNToastWrapperView *wrapperView = (SNToastWrapperView *)(gesture.view);
    
    if (wrapperView.forFullScreen) {
        [SNNotificationManager postNotificationName:kNotifyDidHandled object:nil];
    }
    //这里不能采用暂停方式只能采用Stop方式，因为暂停后，等下载完后，播刚下完的视频时会播暂停的那个视频
    [SNNotificationManager postNotificationName:kSNPlayerViewStopVideoNotification object:nil];
    
    NSDictionary *userInfo = wrapperView.userInfo;
    NSString *actionURL = [userInfo stringValueForKey:kToast_ActionURL defaultValue:nil];
    if (actionURL.length > 0) {
        TTURLAction *_urlAction = [[[TTURLAction actionWithURLPath:actionURL] applyQuery:userInfo] applyAnimated:YES];
        [[TTNavigator navigator] openURLAction:_urlAction];
        
        [self closeToast];
    }
}

@end
