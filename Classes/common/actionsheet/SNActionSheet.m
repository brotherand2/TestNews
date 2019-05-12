//
//  SNActionView.m
//  sohunews
//
//  Created by lhp on 9/29/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNActionSheet.h"
#import "SNLabel.h"

@interface SNActionSheetButton : UIButton {
    
    SNActionSheetButtonType actButtonType;
}
@property(nonatomic,assign) SNActionSheetButtonType actButtonType;

@end

@implementation SNActionSheetButton
@synthesize actButtonType;

@end

@interface SNActionLoginButton : UIButton

@end

@implementation SNActionLoginButton

- (id)initWithFrame:(CGRect)frame iconImage:(UIImage *) image title:(NSString *) title
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsTouchWhenHighlighted = YES;
        
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 40, 40)];
        iconImageView.image = image;
        [self addSubview:iconImageView];
        iconImageView.alpha = themeImageAlphaValue();
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height -20, 80, 20)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = title;
        titleLabel.textColor = RGBCOLOR(101,101,101);
        titleLabel.font = [UIFont systemFontOfSize:10.0];
        [self addSubview:titleLabel];
    }
    return self;
}

@end

@interface SNActionSheet ()

@end

#define  kHeadHeight                16
#define  kIconHeight                36
#define  kButtonTag                 666
#define  kLoginButtonTag            777
#define  kButtonHeight              35
#define  kBottomHeight              11
#define  kLoginViewHeight           64
#define  kContentBgToTextTop        20
#define  kContentBgToTextBottom     14
#define  kButtonDistance            9
#define  kContentBgToLoginDistance  19
#define  kContentToButtonDistance   30
#define  kLoginToButtonDistance     30
#define  kIconToContentDistance     9
#define  kIconToContentBgDistance   7
#define  kButtonWidth               TTApplicationFrame().size.width -20


@implementation SNActionSheet
@synthesize delegate;
@synthesize isShowKeyBoard;
@synthesize userInfo;

- (id)      initWithTitle:(NSString *)title
                 delegate:(id<SNActionSheetDelegate>) actionDelegate
                iconImage:(UIImage *) image
                  content:(NSString *) content
               actionType:(SNActionSheetType) type
        cancelButtonTitle:(NSString *)cancelButtonTitle
   destructiveButtonTitle:(NSString *)destructiveButtonTitle
        otherButtonTitles:(NSArray *)otherButtonTitles
{
    CGRect actionRect = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:actionRect];
    if (self) {
        _type = type;
        self.delegate = actionDelegate;
        self.isShowKeyBoard = YES;
        buttonCount = [self getButtonsCountWithCancelTitle:cancelButtonTitle
                                          destructiveTitle:destructiveButtonTitle
                                               otherTitles:otherButtonTitles];
        
        //background
        [self initBackgroundViewWithContent:content];
        
        //content
        [self initContentViewWithTitle:title
                             iconImage:image
                               content:content
                     cancelButtonTitle:cancelButtonTitle
                destructiveButtonTitle:destructiveButtonTitle
                     otherButtonTitles:otherButtonTitles];
        
        switch (type) {
            case SNActionSheetTypeLogin:
                [self createLoginView];
                break;
            case SNActionSheetTypeDefault:
                [self initButtonsWithDestructiveButtonTitle:destructiveButtonTitle
                                          otherButtonTitles:otherButtonTitles];
                break;
            default:
                [self initButtonsWithDestructiveButtonTitle:destructiveButtonTitle
                                          otherButtonTitles:otherButtonTitles];
                break;
        }
        
        //cancelButton
        [self initCancelButtonWithCancelButtonTitle:cancelButtonTitle];
        
        [SNNotificationManager addObserver:self selector:@selector(hideActionViewAnimation) name:kNotifyDidReceive object:nil];
        
    }
    return self;
}

- (void)initBackgroundViewWithContent:(NSString *) content
{
    _backgroundView = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _backgroundView.backgroundColor = [UIColor blackColor];
    _backgroundView.alpha = 0.0;
    [_backgroundView addTarget:self action:@selector(dismissActionSheetByTouchBgView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backgroundView];
    
    NSInteger actionViewHeight = [self getViewHeightWithContent:content buttonsCount: buttonCount];
    CGRect actionViewRect = CGRectMake(0, TTApplicationFrame().size.height - actionViewHeight, TTApplicationFrame().size.width, actionViewHeight);
    _actionView = [[SNNavigationBar alloc] initWithFrame:actionViewRect];
    _actionView.center = CGPointMake(TTApplicationFrame().size.width/2, TTApplicationFrame().size.height +10+ actionViewHeight/2);
    [self addSubview:_actionView];
}

- (void)initContentViewWithTitle:(NSString *)title
                       iconImage:(UIImage *) image
                         content:(NSString *) content
               cancelButtonTitle:(NSString *)cancelButtonTitle
          destructiveButtonTitle:(NSString *)destructiveButtonTitle
               otherButtonTitles:(NSArray *)otherButtonTitles
{
    //icon
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, kHeadHeight, kIconHeight, kIconHeight)];
    iconImageView.image  = image;
    [_actionView addSubview:iconImageView];
    
    //title
    NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kShareToInfoTextColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20+kIconHeight, kHeadHeight +9, 200, 18)];
    titleLabel.font = [UIFont systemFontOfSize:18.0];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor colorFromString:strColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [_actionView addSubview:titleLabel];
    
    SNLabel *contentLabel = [[SNLabel alloc] initWithFrame:CGRectMake(10, kHeadHeight+kIconHeight +kIconToContentBgDistance +4, TTApplicationFrame().size.width-40, _contentHeight)];
    contentLabel.font = [UIFont systemFontOfSize:16.0];
    contentLabel.textColor = RGBCOLOR(101,101,101);
    contentLabel.lineHeight = 26.0;
    contentLabel.textHeight = 16.0;
    contentLabel.text = content;
    [_actionView addSubview:contentLabel];
}

- (void)initButtonsWithDestructiveButtonTitle:(NSString *)destructiveButtonTitle
                            otherButtonTitles:(NSArray *)otherButtonTitles
{
    if (destructiveButtonTitle) {
        CGRect destructiveRect = CGRectMake(10, _viewHeight-kBottomHeight-2*kButtonHeight-kButtonDistance,kButtonWidth, kButtonHeight);
        NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSNActionSheetDestruButtonTitleColor];
        [self createButtonWithTitle:destructiveButtonTitle
                              frame:destructiveRect
                         titleColor:[UIColor colorFromString:strColor]
                        normalImage:[UIImage imageNamed:@"act_btn_destructive_normal.png"]
                     highlightImage:[UIImage imageNamed:@"act_btn_destructive_highlight.png"]
                          buttonTag:kButtonTag+1
                         buttonType:SNActionSheetButtonTypeDestructive];
    }
    
    if (otherButtonTitles) {
        if ([otherButtonTitles count] > 0) {
            NSInteger buttonsNum = buttonCount - [otherButtonTitles count];
            for (int i = 0; i < [otherButtonTitles count]; i++) {
                CGRect buttonRect = CGRectMake(10, _viewHeight-kBottomHeight-kButtonHeight-(buttonsNum+i)*(kButtonHeight+kButtonDistance),
                                               kButtonWidth, kButtonHeight);
                NSString *title = [otherButtonTitles objectAtIndex:i];
                
                [self createButtonWithTitle:title
                                      frame:buttonRect
                                 titleColor:[UIColor whiteColor]
                                normalImage:[UIImage imageNamed:@"act_otherbtn_normal.png"]
                             highlightImage:[UIImage imageNamed:@"act_otherbtn_highlight.png"]
                                  buttonTag:kButtonTag+buttonsNum+i
                                 buttonType:SNActionSheetButtonTypeOthers];
            }
        }
    }
    
}

- (void)initCancelButtonWithCancelButtonTitle:(NSString *) cancelButtonTitle
{
    if (!cancelButtonTitle) {
        return;
    }
    
    UIImage *normalImage = [UIImage imageNamed:@"act_btn_cancel_normal.png"];
    UIImage *highlightImage = [UIImage imageNamed:@"act_btn_cancel_highlight.png"];
    normalImage = [normalImage stretchableImageWithLeftCapWidth:25 topCapHeight:kButtonHeight/2];
    highlightImage = [highlightImage stretchableImageWithLeftCapWidth:25 topCapHeight:kButtonHeight/2];
    
    CGRect cancelRect = CGRectMake(10, _viewHeight-kBottomHeight-kButtonHeight,kButtonWidth, kButtonHeight);
    [self createButtonWithTitle:cancelButtonTitle
                          frame:cancelRect
                     titleColor:RGBCOLOR(101,101,101)
                    normalImage:normalImage
                 highlightImage:highlightImage
                      buttonTag:kButtonTag
                     buttonType:SNActionSheetButtonTypeCancel];
}

- (void)createButtonWithTitle:(NSString *) title
                        frame:(CGRect) buttonFrame
                   titleColor:(UIColor *) titleColor
                  normalImage:(UIImage *) normalImage
               highlightImage:(UIImage *) highlightImage
                    buttonTag:(NSInteger) tag
                   buttonType:(SNActionSheetButtonType ) type
{
    SNActionSheetButton *actionButton = [SNActionSheetButton buttonWithType:UIButtonTypeCustom];
    [actionButton setFrame:buttonFrame];
    [actionButton setTitle:title forState:UIControlStateNormal];
    [actionButton setBackgroundColor:[UIColor clearColor]];
    [actionButton setTag:tag];
    [actionButton setTitleEdgeInsets:UIEdgeInsetsMake(13, 0, 11, 0)];
    [actionButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [actionButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [actionButton setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [actionButton setTitleColor:titleColor forState:UIControlStateNormal];
    [actionButton setTitleColor:titleColor forState:UIControlStateHighlighted];
    [actionButton setActButtonType:type];
    
    [_actionView addSubview:actionButton];
}

- (void)createLoginView
{
    CGRect loginRect = CGRectMake(0, _viewHeight - kBottomHeight - kLoginViewHeight - kContentToButtonDistance -kButtonHeight
                                  , TTApplicationFrame().size.width, kLoginViewHeight);
    UIView *loginView = [[UIView alloc] initWithFrame:loginRect];
    [loginView setBackgroundColor:[UIColor clearColor]];
    [_actionView addSubview:loginView];
    
    for (int i = 0; i < 4; i++) {
        NSString *titleString = @"";
        UIImage *iconImage = nil;
        switch (i) {
            case 0: {
                titleString = @"新浪微博";
                iconImage = [UIImage imageNamed:@"timeline_login_sina.png"];
                break;
            }
            case 1: {
                titleString = @"腾讯微博";
                iconImage = [UIImage imageNamed:@"timeline_login_tencent.png"];
                break;
            }
            case 2: {
                titleString = @"QQ";
                iconImage = [UIImage imageNamed:@"timeline_login_qq.png"];
                break;
            }
            case 3: {
                titleString = @"其他方式";
                iconImage = [UIImage imageNamed:@"timeline_login_other.png"];
                break;
            }
            default:
                break;
        }
        
        CGRect buttonRect = CGRectMake(i*80, 0, 80, kLoginViewHeight);
        SNActionLoginButton *loginButton = [[SNActionLoginButton alloc] initWithFrame:buttonRect
                                                                            iconImage:iconImage
                                                                                title:titleString];
        loginButton.accessibilityLabel = [NSString stringWithFormat:@"%@登陆", titleString];
        [loginButton addTarget:self action:@selector(loginButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [loginButton setTag:kLoginButtonTag +i];
        [loginView addSubview:loginButton];
        
        CGRect lineRect = CGRectMake((i+1)*80, 5, 1, kLoginViewHeight-10);
        UIImageView *sepLineView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timeline_login_sepline.png"]];
        sepLineView.frame = lineRect;
        [loginView addSubview:sepLineView];
    }
}

- (NSInteger)getButtonsCountWithCancelTitle:(NSString *) cancelTitle
                           destructiveTitle:(NSString *) destrTitle
                                otherTitles:(NSArray *) otherTitles
{
    NSInteger buttonNum = 0;
    if (otherTitles) {
        buttonNum = [otherTitles count];
    }
    if (cancelTitle) {
        buttonNum++;
    }
    if (destrTitle) {
        buttonNum++;
    }
    return buttonNum;
}


- (int)getViewHeightWithContent:(NSString *) content buttonsCount:(NSInteger) buttonNum
{
    _viewHeight = kHeadHeight + kIconHeight + kIconToContentDistance;
    _contentHeight = 0;
    if (content) {
        _contentHeight = [SNLabel sizeForContent:content
                                         maxSize:CGSizeMake(TTApplicationFrame().size.width - 40, 2000)
                                            font:16.0
                                      lineHeight:26.0].height;
    }
    _viewHeight += _contentHeight;
    switch (_type) {
        case SNActionSheetTypeLogin:
            _viewHeight +=  kContentBgToLoginDistance + kLoginViewHeight + kLoginToButtonDistance + kButtonHeight;
            break;
        case SNActionSheetTypeDefault:
            _viewHeight += kContentToButtonDistance;
            _viewHeight += buttonNum * (kButtonHeight + kButtonDistance) - kButtonDistance;
            break;
        default:
            _viewHeight += kContentToButtonDistance;
            _viewHeight += buttonNum * (kButtonHeight + kButtonDistance) - kButtonDistance;
            break;
    }
    _viewHeight += kBottomHeight;
    return _viewHeight;
}

- (void)loginButtonAction:(SNActionLoginButton *) loginButton
{
    NSInteger buttonIndex = loginButton.tag - kLoginButtonTag;
    [[SNActionSheetLoginManager sharedInstance] loginWithIndex:buttonIndex];
    [self hideActionViewAnimation];
}

- (void)buttonAction:(SNActionSheetButton *) touchedButton
{
    NSInteger buttonIndex = touchedButton.tag - kButtonTag;
    if (delegate && [delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [delegate actionSheet:self clickedButtonAtIndex:buttonIndex];
    }
    
    if (touchedButton.actButtonType == SNActionSheetButtonTypeDestructive) {
        [self hideActionViewAnimation];
    }else {
        [self closeAction];
    }
}

- (void)dismissActionSheetByTouchBgView
{
    if (!_disableDismissAction) {
        if (delegate && [delegate respondsToSelector:@selector(dismissActionSheetByTouchBgView:)]) {
            [delegate dismissActionSheetByTouchBgView:self];
        }
        [self closeAction];
    }
}

- (void)removeView
{
    [self removeFromSuperview];
}

- (void)closeAction
{
    //发送键盘弹起通知
    if (isShowKeyBoard) {
        [SNNotificationManager postNotificationName:KGuideRegisterBackNotification object:nil];
    }
    [self hideActionViewAnimation];
}

- (void)showActionViewAnimation
{
    CGPoint center = CGPointMake(TTApplicationFrame().size.width/2, [UIScreen mainScreen].bounds.size.height -_viewHeight/2);
    [_actionView moveAnimationWithCenter:center stopSelector:nil animationDelegate:nil];
    [self backgroundAnimationWithShow:YES];
    
    // 如果是半屏的登录界面 增加一个pv
    if (_type == SNActionSheetTypeLogin) {
        SNUserTrack *curPage = [SNUserTrack trackWithPage:login_halfdome link2:nil];
        NSString *paramsString = [NSString stringWithFormat:@"_act=pv&page=%@&track=", [curPage toFormatString]];
        [SNNewsReport reportADotGifWithTrack:paramsString];
    }
}

- (void)hideActionViewAnimation
{
    CGPoint center = CGPointMake(TTApplicationFrame().size.width/2, TTApplicationFrame().size.height +10+ _viewHeight/2);
    [_actionView moveAnimationWithCenter:center stopSelector:@selector(removeView) animationDelegate:self];
    [self backgroundAnimationWithShow:NO];
}

- (void)backgroundAnimationWithShow:(BOOL) isShow
{
    [UIView beginAnimations:@"shadeAnimation" context:nil];
    [UIView setAnimationCurve:0.5];
    [UIView setAnimationDelay:0.2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    if (isShow) {
        _backgroundView.alpha = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? 0.1 : 0.3;
    }else {
        _backgroundView.alpha = 0.0;
    }
    [UIView commitAnimations];
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
    self.delegate = nil;
}

@end
