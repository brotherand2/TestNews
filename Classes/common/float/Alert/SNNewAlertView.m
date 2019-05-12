//
//  SNNewAlertView.h
//  sohunews
//
//  Created by 李腾 on 2016/12/1.
//  Copyright © 2016年 sohu. All rights reserved.
//

#import "SNNewAlertView.h"
#import "UIViewAdditions.h"

#define kDefaultAlertWidth  (kAppScreenWidth > 375.0 ? kAppScreenWidth * 2/3 : 250.0)
#define kDefaultAlertHeight (kAppScreenHeight * 250.0 * 0.618/667.0)
#define kMaxAlertHeight (kAppScreenWidth > 375.0 ? 500/1336.0*kAppScreenHeight : 250.0) - kDefaultButtonHeight
#define kDefaultButtonHeight 45.0
#define kMessageLeftRightPadding 20.0
#define kLabelLineSpace 4.0
#define kTitleTopPadding (self.title?20.0:0)
#define kTitleBottomPadding (self.title?8.0:20.0)

#define kTitleHeight (self.title?20.0:0)
#define kMessageBottomPadding 20.0
#define kActionSheetButtonHeight 48.0
#define kActionSheetButtonOffset ([SNDevice sharedInstance].isPhoneX ? 18.0 : 0.0)
#define kActionSheetHorizontalSeparatorHeight 0.5f
#define kAlertCornerRadius 4.0

#define kMessageFont [UIFont systemFontOfSize:kThemeFontSizeD]

#define kHorizontalSeparatorColor ([SNThemeManager sharedThemeManager].isNightTheme ? SNUICOLOR(kThemeBg1Color):SNUICOLOR(kThemeBg1Color))

typedef NS_ENUM(NSUInteger, SNNewAlertViewAnimationType) {
    
    SNNewAlertViewAnimationTypeFlyBottom   = 0,
    SNNewAlertViewAnimationTypeZoomIn      = 1,
    SNNewAlertViewAnimationTypeZoomOut     = 2
//    SNNewAlertViewAnimationTypeFlyTop    = 3   // 后续可在此添加展示与消失的动画
};

typedef void (^SNNewAlertViewBlock)(void);

@interface SNNewAlertView ()
{
    CGRect titleLabelFrame;
    CGRect messageLabelFrame;
    CGRect cancelButtonFrame;
    CGRect otherButtonFrame;
    
    CGRect verticalSeperatorFrame;
    CGRect horizontalSeperatorFrame;
    
    BOOL hasModifiedFrame;
    BOOL hasContentView;
}
@property (nonatomic, weak) UIView *alertContentView;
@property (nonatomic, assign) CGRect customFrame;
@property (nonatomic, strong) UIView *horizontalSeparator;
@property (nonatomic, strong) UIView *verticalSeparator;

@property (nonatomic, strong) UIView *blackOpaqueView;
@property (nonatomic, strong) UIImage *backgroundImage;                // Default is nil
@property (nonatomic, strong) UIColor *defaultBgColor;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *cancelButtonTitle;
@property (nonatomic, strong) NSString *otherButtonTitle;

@property (nonatomic, strong) UIView *whiteView;

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, strong) UIColor *originCancelButtonColor;
@property (nonatomic, strong) UIColor *originOtherButtonColor;

@property (nonatomic, assign) SNNewAlertViewStyle alertViewStyle;       // Default is alert

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) BOOL hasModifiedBackgroundColor;

@property (nonatomic, assign) SNNewAlertViewAnimationType appearAnimationType;
@property (nonatomic, assign) SNNewAlertViewAnimationType disappearAnimationType;

@property (readwrite, copy) SNNewAlertViewBlock cancelButtonAction;
@property (readwrite, copy) SNNewAlertViewBlock otherButtonAction;
@property (nonatomic, copy) SNNewAlertViewBlock dismissHandler;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *otherButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, assign) CGFloat titleHeight;

@property (nonatomic, assign) CGFloat titleTopPadding;
@property (nonatomic, assign) CGFloat titleBottomPadding;
@property (nonatomic, assign) CGFloat messageBottomPadding;
@property (nonatomic, assign) CGFloat messageLeftRightPadding;

@property (nonatomic, assign) CGFloat horizontalSeparatorHeight;

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign) BOOL hideSeperator;                       // Default is NO

/*Make the cancel button on the right*/
@property (nonatomic, assign) BOOL cancelButtonPositionRight;           // Default is NO
@property (nonatomic, assign) BOOL buttonClickedHighlight;              // Default is YES
@property (nonatomic, assign) BOOL shouldDismissOnOutsideTapped;        // Default is YES

@property (nonatomic, assign) BOOL shouldDimBackgroundWhenShowInWindow; // Default is YES
@property (nonatomic, assign) BOOL shouldDimBackgroundWhenShowInView;   // Default is YES
@property (nonatomic, assign) CGFloat dimAlpha;

@property (nonatomic, assign) UIInterfaceOrientation orientation;       // Current Device Direction

@end

@implementation SNNewAlertView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (self.alertViewStyle == SNNewAlertViewStyleAlert) {
        // Alert add sohu logo.
        self.clipsToBounds = YES;
        UIImage *drawImg = [UIImage imageNamed:@"icotooltip_rightfox_v5.png"];
        [drawImg drawInRect:CGRectMake(self.width - drawImg.size.width,
                                       0,
                                       drawImg.size.width,
                                       drawImg.size.height)];
    }
}

#pragma mark -  Init method

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     delegate:(id<SNNewAlertViewDelegate>)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
             otherButtonTitle:(NSString *)otherButtonTitle {

    if (self = [self initWithTitle:title
                           message:message
                 cancelButtonTitle:cancelButtonTitle
                  otherButtonTitle:otherButtonTitle]) {
        self.delegate = delegate;
        return self;
    }
    
    return nil;
}

- (instancetype)initWithContentView:(UIView *)contentView
                  cancelButtonTitle:(NSString *)cancelButtonTitle
                   otherButtonTitle:(NSString *)otherButtonTitle
                         alertStyle:(SNNewAlertViewStyle)alertStyle {
    if (self = [self initWithTitle:nil
                           message:nil
                 cancelButtonTitle:cancelButtonTitle
                  otherButtonTitle:otherButtonTitle]) {
        self.alertViewStyle = alertStyle;
        self.contentView = contentView;
        return self;
    }
    return nil;
}

- (instancetype)initWithContentView:(UIView *)contentView
                    backgroundColor:(UIColor *)backgroundColor
                         alertStyle:(SNNewAlertViewStyle)alertStyle {
    if (self = [self initWithTitle:nil
                           message:nil
                 cancelButtonTitle:nil
                  otherButtonTitle:nil]) {
        self.alertViewStyle = alertStyle;
        self.contentView = contentView;
        self.hasModifiedBackgroundColor = YES;
        self.defaultBgColor = backgroundColor;
        return self;
    }
    return nil;
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
             otherButtonTitle:(NSString *)otherButtonTitle {
    self.width = kDefaultAlertWidth;
    self.height = kDefaultAlertHeight;
    
    self = [super initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    if (self) {
        // Initialization code

        self.alertViewType = SNAlertViewNormalType;
        self.hasModifiedBackgroundColor = NO;
        self.title = title;
        self.message = message;
        self.cancelButtonTitle = cancelButtonTitle;
        self.otherButtonTitle = otherButtonTitle;
        self.appearAnimationType = SNNewAlertViewAnimationTypeZoomIn;
        self.disappearAnimationType = SNNewAlertViewAnimationTypeZoomOut;
        self.cornerRadius = kAlertCornerRadius;
        self.buttonClickedHighlight = YES;
        self.horizontalSeparatorHeight = 0.5;
        self.buttonHeight = kDefaultButtonHeight;
        self.titleTopPadding = kTitleTopPadding;
        self.titleHeight = kTitleHeight;
        self.titleBottomPadding = kTitleBottomPadding;
        self.messageBottomPadding = kMessageBottomPadding;
        self.messageLeftRightPadding = kMessageLeftRightPadding;
        self.shouldDimBackgroundWhenShowInWindow = YES;
        self.shouldDimBackgroundWhenShowInView = YES;
        self.dimAlpha = 0.4;
        
        [self setupItems];
        
        [SNNotificationManager addObserver:self
                                  selector:@selector(hideAndDismissAlertView)
                                      name:kOpenNewsFromWidgetNotification
                                    object:nil];
        [SNNotificationManager addObserver:self
                                  selector:@selector(hideAndDismissAlertView)
                                      name:kOpenClientFrom3DTouchNotification
                                    object:nil];
        [SNNotificationManager addObserver:self
                                  selector:@selector(hideAndDismissAlertView)
                                      name:kAppBecomeActivityNotification
                                    object:nil];

        [SNNotificationManager addObserver:self
                                  selector:@selector(orientationDidChange)
                                      name:UIDeviceOrientationDidChangeNotification
                                    object:nil];
        [SNNotificationManager addObserver:self
                                  selector:@selector(updateTheme)
                                      name:kThemeDidChangeNotification
                                    object:nil];

        
    }
    return self;
}

#pragma mark - Show the alert view
/**
 * Show in specified view
 *
 * @param Specified View
 */
- (void)showInView:(UIView *)view {
    if ([SNNewAlertView isAlertViewShow]) return;
    [self showAlertView];
    [self calculateFrame];
    [self setupViews];
    self.orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (!hasModifiedFrame) {
        self.frame = CGRectMake((view.frame.size.width - self.frame.size.width )/2,
                                (view.frame.size.height - self.frame.size.height) /2,
                                self.frame.size.width,
                                self.frame.size.height);
    }
    UIView *window = [[[UIApplication sharedApplication] delegate] window];
    
    if (self.shouldDimBackgroundWhenShowInView && view != window) {
        UIView *window = [[[UIApplication sharedApplication] delegate] window];
        self.blackOpaqueView = [[UIView alloc] initWithFrame:window.bounds];
        self.blackOpaqueView.backgroundColor = [UIColor colorWithWhite:0 alpha:self.dimAlpha];
        
        UITapGestureRecognizer *outsideTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outsideTap:)];
        [self.blackOpaqueView addGestureRecognizer:outsideTapGesture];
        [view addSubview:self.blackOpaqueView];
    }
    
    [self willAppearAlertView];
    [self addThisViewToView:view];
}

- (void)showAlertView {
    [super showAlertView];
}

/**
 *  Show in window
 */
- (void)show {
    UIView *superView;
    UIView *window = [[[UIApplication sharedApplication] delegate] window];
    superView = window;
    
    if (self.shouldDimBackgroundWhenShowInWindow) {
        self.blackOpaqueView = [[UIView alloc] initWithFrame:window.bounds];
        self.blackOpaqueView.backgroundColor = [UIColor colorWithWhite:0 alpha:self.dimAlpha];
        
        UITapGestureRecognizer *outsideTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outsideTap:)];
        [self.blackOpaqueView addGestureRecognizer:outsideTapGesture];
        [superView addSubview:self.blackOpaqueView];
    }
    
    [self showInView:superView];
}


+ (BOOL)isAlertViewShow {
    NSArray* subViews = [[TTNavigator navigator].window subviews];
    for(UIView* view in subViews) {
        if([view isKindOfClass:[self class]])
            return YES;
    }
    return NO;
}

- (void)outsideTap:(UITapGestureRecognizer *)recognizer {
    if (self.shouldDismissOnOutsideTapped) {
        [self dismissWithIndex:1];
    }
}

- (void)addThisViewToView: (UIView *)view {
    NSTimeInterval timeAppear = .2;
    NSTimeInterval timeDelay = 0;
    
    [view addSubview:self];
    
    if (self.appearAnimationType == SNNewAlertViewAnimationTypeZoomIn) {
        if (self.hasModifiedBackgroundColor) {
            self.backgroundColor = self.defaultBgColor;
        } else {
            self.backgroundColor = SNUICOLOR(kThemeBg4Color);
        }
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
        [UIView animateWithDuration:timeAppear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
             self.transform = CGAffineTransformMakeScale(1.10, 1.10);
            
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.2 animations:^{
                self.transform = CGAffineTransformIdentity;
                
            } completion:^(BOOL finished) {
                [self didAppearAlertView];
                
            }];
        }];
    } else if (self.appearAnimationType == SNNewAlertViewAnimationTypeFlyBottom) {
        CGRect tmpFrame = self.frame;
        self.frame = CGRectMake(self.frame.origin.x,
                                view.frame.size.height + 10,
                                self.frame.size.width,
                                self.frame.size.height);
        if (self.hasModifiedBackgroundColor) {
            self.backgroundColor = self.defaultBgColor;
        } else {
            self.backgroundColor = [UIColor clearColor];
            if ([SNThemeManager sharedThemeManager].isNightTheme) {
                self.backgroundColor = SNUICOLOR(kThemeBg4Color);
            }
            /* 添加背景毛玻璃效果 */
            UIView *blurView = [[SNNavigationBar alloc] initWithFrame:self.bounds];
            [blurView addSubview:self.whiteView];
            if ([SNThemeManager sharedThemeManager].isNightTheme) { // 设计要求还得再加一层白..效果更难看
                self.whiteView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
            }
            [self insertSubview:blurView atIndex:0];
        }
        
        [UIView animateWithDuration:timeAppear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = tmpFrame;
            self.alpha = 1;
        } completion:^(BOOL finished){
            [self didAppearAlertView];
        }];
    }
}


#pragma mark -  Hide and dismiss the alert

- (void)dismiss {
    [self dismissWithIndex:0];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    self.dismissHandler = completion;
    [self dismiss];
}

- (void)dismissWithIndex:(NSInteger )index {
    
    [self willDisAppearAlertViewWithIndex:index];
    
    NSTimeInterval timeDisappear = .25;
    NSTimeInterval timeDelay = .02;

    if (self.disappearAnimationType == SNNewAlertViewAnimationTypeZoomOut) {
        self.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:timeDisappear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.transform = CGAffineTransformMakeScale(0.01, 0.01);
            self.alpha = 0.0;
        } completion:^(BOOL finished){
            [self removeFromSuperview];
            [self didDisAppearAlertViewWithIndex:index];
        }];
    } else if (self.disappearAnimationType == SNNewAlertViewAnimationTypeFlyBottom) {
        [UIView animateWithDuration:timeDisappear delay:timeDelay options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.frame = CGRectMake( self.frame.origin.x, self.superview.frame.size.height + 100, self.frame.size.width, self.frame.size.height);
        } completion:^(BOOL finished){
            [self removeFromSuperview];
            [self didDisAppearAlertViewWithIndex:index];
        }];
    }
    
    if (self.blackOpaqueView) {
        [UIView animateWithDuration:timeDisappear animations:^{
            self.blackOpaqueView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.blackOpaqueView removeFromSuperview];
        }];
    }
}

- (void)dismissAlertView {
    [super dismissAlertView];
}

- (void)hideAndDismissAlertView {
    if ([SNNewAlertView isAlertViewShow]) {
        NSArray* subViews = [[TTNavigator navigator].window subviews];
        for(UIView* view in subViews) {
            if([view isKindOfClass:[self class]]) {
                SNNewAlertView *alert = (SNNewAlertView *)view;
                [alert dismiss];
            }
        }
    }
}

+ (void)forceDismissAlertView {
    NSArray* subViews = [[TTNavigator navigator].window subviews];
    for(UIView* view in subViews) {
        if([view isKindOfClass:[self class]]) {
            SNNewAlertView *alert = (SNNewAlertView *)view;
            [alert dismiss];
        }
    }
}

- (void)orientationDidChange {
    
    if ([UIApplication sharedApplication].statusBarOrientation != self.orientation && self.orientation != UIInterfaceOrientationUnknown) {
        self.orientation = [UIApplication sharedApplication].statusBarOrientation;
        [self hideAndDismissAlertView];
    }
}

// 增加更新皮肤的通知，用于在alert已经存在的情况下切换日夜间模式
- (void)updateTheme {
    if (self.alertViewStyle != SNNewAlertViewStyleActionSheet) {
        self.cancelButton.backgroundColor = SNUICOLOR(kThemeBg4Color);
        self.otherButton.backgroundColor = SNUICOLOR(kThemeBg4Color);
    }
    [self.cancelButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    [self.otherButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];

    if ([SNThemeManager sharedThemeManager].isNightTheme) {
        self.backgroundColor = SNUICOLOR(kThemeBg4Color);
        if (self.whiteView) {
            self.whiteView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        }
    } else {
        if (self.alertViewStyle == SNNewAlertViewStyleAlert) {
            self.backgroundColor = SNUICOLOR(kThemeBg4Color);
        } else {
            self.backgroundColor = [UIColor clearColor];
        }
        if (self.whiteView) {
            self.whiteView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
        }
    }
    self.horizontalSeparator.backgroundColor = kHorizontalSeparatorColor;
    self.verticalSeparator.backgroundColor = kHorizontalSeparatorColor;
}

#pragma mark - Setup the alert view

- (void)setAlertViewStyle:(SNNewAlertViewStyle)alertViewStyle {
    _alertViewStyle = alertViewStyle;
    if (alertViewStyle == SNNewAlertViewStyleActionSheet) {
        self.appearAnimationType = SNNewAlertViewAnimationTypeFlyBottom;
        self.disappearAnimationType = SNNewAlertViewAnimationTypeFlyBottom;
        self.cornerRadius = 0;
        self.shouldDismissOnOutsideTapped = YES;
        self.buttonHeight = kActionSheetButtonHeight + kActionSheetButtonOffset;
        self.horizontalSeparatorHeight = kActionSheetHorizontalSeparatorHeight;
        self.otherButton.backgroundColor = [UIColor clearColor];
        self.cancelButton.backgroundColor = [UIColor clearColor];
        self.otherButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, kActionSheetButtonOffset, 0);
        self.cancelButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, kActionSheetButtonOffset, 0);
    }
}

- (void)setContentView:(UIView *)contentView {

    self.alertContentView = contentView;
    
    hasContentView = YES;
    self.width = contentView.frame.size.width;
    BOOL hasButton = (self.cancelButtonTitle || self.otherButtonTitle);
    if (!hasButton) {
        self.buttonHeight = 0;
    }
    self.height = contentView.frame.size.height + self.buttonHeight;
       
    contentView.frame = contentView.bounds;
    if (self.alertViewStyle == SNNewAlertViewStyleActionSheet) {
        self.frame = CGRectMake(self.frame.origin.x,
                                [UIScreen mainScreen].bounds.size.height - self.height,
                                self.width,
                                self.height);
        hasModifiedFrame = YES;
    } else {
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.width,
                                self.height);
    }
    [self addSubview:contentView];
}

- (UIView *)contentView {
    return self.alertContentView;
}

- (void)setCenter:(CGPoint)center {
    [super setCenter:center];
    
    hasModifiedFrame = YES;
}

- (void)setCustomFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.width = frame.size.width;
    self.height = frame.size.height;
    hasModifiedFrame = YES;
    
    [self calculateFrame];
}

- (void)calculateFrame {
    BOOL hasButton = (self.cancelButtonTitle || self.otherButtonTitle);
    
    if (!hasContentView) {
        if (!hasModifiedFrame) {

            CGFloat messageHeight = [self calculateTextRectWithText:self.message].size.height+4;
            if (messageHeight > kMaxAlertHeight) messageHeight = kMaxAlertHeight;
            CGFloat newHeight = messageHeight + self.titleHeight + self.buttonHeight + self.titleTopPadding + self.titleBottomPadding + self.messageBottomPadding;

            self.height = newHeight;
            
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.height);
            
        }
        
        if (!self.title) {
            titleLabelFrame = CGRectZero;
            self.titleTopPadding = 0;
            
        } else {
            titleLabelFrame = CGRectMake(self.messageLeftRightPadding,
                                         self.titleTopPadding,
                                         self.width - self.messageLeftRightPadding * 2,
                                         self.titleHeight);
        }
        if (!self.message) {
            messageLabelFrame = CGRectZero;
        } else if (hasButton) {
            messageLabelFrame = CGRectMake(self.messageLeftRightPadding,
                                           titleLabelFrame.origin.y + titleLabelFrame.size.height + self.titleBottomPadding,
                                           self.width - self.messageLeftRightPadding * 2,
                                           self.height - self.buttonHeight - titleLabelFrame.size.height - self.titleTopPadding - self.titleBottomPadding);
        } else {
            messageLabelFrame = CGRectMake(self.messageLeftRightPadding,
                                           titleLabelFrame.origin.y +  titleLabelFrame.size.height + self.titleBottomPadding,
                                           self.width - self.messageLeftRightPadding * 2,
                                           self.height - titleLabelFrame.size.height - self.titleTopPadding - self.titleBottomPadding);
        }
        
        if ( ! self.title || self.title.length == 0 ) {
            messageLabelFrame = CGRectMake(self.messageLeftRightPadding,
                                           self.titleBottomPadding,
                                           self.width - self.messageLeftRightPadding * 2,
                                           self.height - self.buttonHeight - self.messageBottomPadding - self.titleBottomPadding);
        }
        
    }
    
    if (self.hideSeperator || !hasButton ) {
        verticalSeperatorFrame = CGRectZero;
        horizontalSeperatorFrame = CGRectZero;
    } else {
        verticalSeperatorFrame = CGRectMake(self.width / 2,
                                            self.height - self.buttonHeight,
                                            0.5,
                                            self.buttonHeight);
        
        horizontalSeperatorFrame = CGRectMake(0,
                                              self.height - self.buttonHeight,
                                              self.width,
                                              self.horizontalSeparatorHeight);
    }
    
    if (!self.cancelButtonTitle) {
        cancelButtonFrame = CGRectZero;
    } else if (!self.otherButtonTitle) {
        verticalSeperatorFrame = CGRectZero;
        cancelButtonFrame = CGRectMake(0,
                                       self.height - self.buttonHeight + self.horizontalSeparatorHeight,
                                       self.width,
                                       self.buttonHeight);
    } else if (!self.cancelButtonPositionRight) {
        cancelButtonFrame = CGRectMake(0,
                                       self.height - self.buttonHeight,
                                       self.width / 2,
                                       self.buttonHeight);
    } else {
        cancelButtonFrame = CGRectMake(self.width / 2,
                                       self.height - self.buttonHeight,
                                       self.width / 2,
                                       self.buttonHeight);
    }
    
    if (!self.otherButtonTitle) {
        otherButtonFrame = CGRectZero;
    } else if (!self.cancelButtonTitle) {
        verticalSeperatorFrame = CGRectZero;
        otherButtonFrame = CGRectMake(0,
                                      self.height - self.buttonHeight,
                                      self.width,
                                      self.buttonHeight);
    } else if (!self.cancelButtonPositionRight) {
        otherButtonFrame = CGRectMake(self.width / 2,
                                      self.height - self.buttonHeight,
                                      self.width / 2,
                                      self.buttonHeight);
    } else {
        otherButtonFrame = CGRectMake(0,
                                      self.height - self.buttonHeight,
                                      self.width / 2,
                                      self.buttonHeight);
    }
    
    if (!self.otherButtonTitle && !self.cancelButtonTitle) {
        cancelButtonFrame = CGRectZero;
        otherButtonFrame = CGRectZero;
        
        self.height = self.height - self.buttonHeight;
        self.buttonHeight = 0;
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                self.frame.size.width,
                                self.height);
    }
    
}

- (CGRect)calculateTextRectWithText:(NSString *)text {
    CGSize maximumLabelSize = CGSizeMake(self.width - self.messageLeftRightPadding * 2, FLT_MAX);
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentLeft;
    paraStyle.lineSpacing = kLabelLineSpace;
    paraStyle.hyphenationFactor = 1.0;
    paraStyle.firstLineHeadIndent = 0.0;
    paraStyle.paragraphSpacingBefore = 0.0;
    paraStyle.headIndent = 0;
    paraStyle.tailIndent = 0;
    CGRect textRect = [text boundingRectWithSize:maximumLabelSize
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:kMessageFont,
                                                           NSParagraphStyleAttributeName:paraStyle}
                                                 context:nil];
    return textRect;

}

- (void)setupItems {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    // Setup Title Label
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    self.titleLabel.text = self.title;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    self.titleLabel.backgroundColor = [UIColor clearColor];
    
    // Setup Message Label
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.font = kMessageFont;
    if (self.message.length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.message];
        // Set Line Spacing
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:kLabelLineSpace];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.message length])];
        [attributedString addAttribute:NSFontAttributeName value:kMessageFont range:NSMakeRange(0, [self.message length])];
        
        self.messageLabel.attributedText = attributedString;
    }
    self.messageLabel.lineBreakMode = NSLineBreakByCharWrapping;

    if ([self calculateTextRectWithText:self.message].size.height > [self.message textSizeWithFont:kMessageFont].height + kLabelLineSpace) {
        self.messageLabel.textAlignment = NSTextAlignmentLeft;
    } else {
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
    }

    self.messageLabel.textColor = self.title ? SNUICOLOR(kThemeText2Color):SNUICOLOR(kThemeText1Color);
    self.messageLabel.backgroundColor = [UIColor clearColor];
    
    //Setup Cancel Button
    self.cancelButton.backgroundColor = SNUICOLOR(kThemeBg4Color);
    [self.cancelButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [self.cancelButton setTitle:self.cancelButtonTitle forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //Setup Other Button
    self.otherButton.backgroundColor = SNUICOLOR(kThemeBg4Color);
    [self.otherButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
    self.otherButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [self.otherButton setTitle:self.otherButtonTitle forState:UIControlStateNormal];
    [self.otherButton addTarget:self action:@selector(otherButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    //Set up Seperator
    self.horizontalSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    self.verticalSeparator = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)setupViews {
    // Setup Background
    if (self.backgroundImage) {
        [self setBackgroundColor:[UIColor colorWithPatternImage:self.backgroundImage]];
    } else {
        [self setBackgroundColor:SNUICOLOR(kThemeBg4Color)];
    }
    if (self.borderWidth) {
        self.layer.borderWidth = self.borderWidth;
    }
    if (self.borderColor) {
        self.layer.borderColor = self.borderColor.CGColor;
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
    self.layer.cornerRadius = self.cornerRadius;
    // Set Frame
    self.titleLabel.frame = titleLabelFrame;
    self.messageLabel.frame = messageLabelFrame;
    self.cancelButton.frame = cancelButtonFrame;
    self.otherButton.frame = otherButtonFrame;
    
    self.horizontalSeparator.frame = horizontalSeperatorFrame;
    self.verticalSeparator.frame = verticalSeperatorFrame;
    
    self.horizontalSeparator.backgroundColor = kHorizontalSeparatorColor;
    self.verticalSeparator.backgroundColor = kHorizontalSeparatorColor;
    
    if (self.title) {
        [self.messageLabel sizeToFit];
        CGRect myFrame = self.messageLabel.frame;
        myFrame = CGRectMake(myFrame.origin.x,
                             myFrame.origin.y,
                             self.width -  2 * self.messageLeftRightPadding,
                             myFrame.size.height);
        self.messageLabel.frame = myFrame;
    }
    
    // Add subviews
    if (!hasContentView) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.messageLabel];
    }
    
    [self addSubview:self.cancelButton];
    [self addSubview:self.otherButton];
    [self addSubview:self.horizontalSeparator];
    [self addSubview:self.verticalSeparator];
}


#pragma mark - Actions

- (void)actionWithBlocksCancelButtonHandler:(void (^)(void))cancelHandler otherButtonHandler:(void (^)(void))otherHandler {
    self.cancelButtonAction = cancelHandler;
    self.otherButtonAction = otherHandler;
}

- (void)cancelButtonClicked:(id)sender {
    
    [self dismissWithIndex:1];
    
    if (self.cancelButtonAction) {
        self.cancelButtonAction();
    }
    
    if ([self.delegate respondsToSelector:@selector(cancelButtonClickedOnAlertView:)]) {
        [self.delegate cancelButtonClickedOnAlertView:self];
    }
}

- (void)otherButtonClicked:(id)sender {

    [self dismissWithIndex:2];
    
    if (self.otherButtonAction) {
        self.otherButtonAction();
    }
    
    if ([self.delegate respondsToSelector:@selector(otherButtonClickedOnAlertView:)]) {
        [self.delegate otherButtonClickedOnAlertView:self];
    }
}

- (void)willAppearAlertView {
    if ([self.delegate respondsToSelector:@selector(willAppearAlertView:)]) {
        [self.delegate willAppearAlertView:self];
    }
}

- (void)didAppearAlertView {
    if ([self.delegate respondsToSelector:@selector(didAppearAlertView:)]) {
        [self.delegate didAppearAlertView:self];
    }
}

- (void)willDisAppearAlertViewWithIndex:(NSInteger)index {
    if ([self.delegate respondsToSelector:@selector(willDisAppearAlertView:withButtonIndex:)]) {
        [self.delegate willDisAppearAlertView:self withButtonIndex:index];
    }
}

- (void)didDisAppearAlertViewWithIndex:(NSInteger)index {
    [self dismissAlertView];

    if (self.dismissHandler) {
        self.dismissHandler();
    }
    if ([self.delegate respondsToSelector:@selector(didDisAppearAlertView:withButtonIndex:)]) {
        [self.delegate didDisAppearAlertView:self withButtonIndex:index];
    }
}

- (UIView *)whiteView {
    if (_whiteView == nil) {
        _whiteView = [[UIView alloc] initWithFrame:self.bounds];
        _whiteView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
    }
    return _whiteView;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end

