//
//  SNCommentEditorViewController.m
//  sohunews
//
//  Created by jialei on 13-6-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBaseEditorViewController.h"
#import "UIColor+ColorUtils.h"
#import "SNBaseEditorViewController+SNLayout.h"
#import "SNBaseEditorViewController+SNInput.h"
#import "Toast+UIView.h"
#import "SNCommentConfigs.h"
#import "SNUserManager.h"
#import "SNSoundManager.h"
#import "SNEmoticonObject.h"
#import "TextConfig.h"
#import "FastTextStorage.h"
#import "SNRollingNewsPublicManager.h"

#define kTipLabelGapX               10

@interface SNBaseEditorViewController ()
{
}

@end

@implementation SNBaseEditorViewController

@synthesize editorType;
@synthesize toolBarType;
@synthesize mediaMode;
@synthesize sendDelegateController;
@synthesize sendDataDictionary = _sendDataDictionary;
@synthesize confirmAlertView = _confirmAlertView;
@synthesize alertTitle;
@synthesize alertSubMessage;
@synthesize alertCancelTitle;
@synthesize alertOtherTitle;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query 
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    self = [super init];
    if (self) {
        _sendDataDictionary = [[NSMutableDictionary alloc] init];
        _sendEmoticonDic = [[NSMutableDictionary alloc] init];
        _needTextView = YES;
        
        [SNNotificationManager addObserver:self
		                                         selector:@selector(keyboardWillShow:)
		                                             name:UIKeyboardWillShowNotification
		                                           object:nil];
        
        [SNNotificationManager addObserver:self
		                                         selector:@selector(keyboardDidShow:)
		                                             name:UIKeyboardDidShowNotification
		                                           object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(guideLoginSuccess)
                                                     name:kGuideRegisterSuccessNotification
                                                   object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(guideRegisterViewOnBack)
                                                     name:KGuideRegisterBackNotification
                                                   object:nil];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(notifyPushDidReceive)
                                                     name:kNotifyDidReceive
                                                   object:nil];
        
        [SNNotificationManager addObserver:self selector:@selector(textFieldResignFirstResponder) name:kResignFirstResponder object:nil];

        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        {
            [SNNotificationManager addObserver:self
		                                         selector:@selector(keyboardHeight:)
		                                             name:UIKeyboardDidChangeFrameNotification
		                                           object:nil];
        }
        
    }
#pragma clang diagnostic pop

    return self;
}

- (id)initWithParams:(NSDictionary *)infoDict {
    self = [super init];
    if (self) {
        _sendDataDictionary = [[NSMutableDictionary alloc] init];
        _sendEmoticonDic = [[NSMutableDictionary alloc] init];
        _needTextView = YES;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        [SNNotificationManager addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(guideLoginSuccess)
                                                     name:kGuideRegisterSuccessNotification
                                                   object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(guideRegisterViewOnBack)
                                                     name:KGuideRegisterBackNotification
                                                   object:nil];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(notifyPushDidReceive)
                                                     name:kNotifyDidReceive
                                                   object:nil];
        
        [SNNotificationManager addObserver:self selector:@selector(textFieldResignFirstResponder) name:kResignFirstResponder object:nil];

        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0"))
        {
            [SNNotificationManager addObserver:self
                                                     selector:@selector(keyboardHeight:)
                                                         name:UIKeyboardDidChangeFrameNotification
                                                       object:nil];
        }

#pragma clang diagnostic pop
    }
    return self;
}

- (void)initAllSubviews {
    [self view];
    if (isFirstLoadView) {
        return;
    }
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _maskBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight)];
    _maskBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [self.view addSubview:_maskBackgroundView];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(outsideTap:)];
    [_maskBackgroundView addGestureRecognizer:tapGesture];

    _dynamicallyView = [[UIView alloc] initWithFrame:CGRectMake(0, kAppScreenHeight, kAppScreenWidth, kAppScreenHeight)];
    _dynamicallyView.backgroundColor = SNUICOLOR(kThemeBg4Color);
    [self.view addSubview:_dynamicallyView];
    
    _keyBoardHeight = 0;
    
    // 输入区.
    if (_needTextView) {
        [self initInputFieldView];
    }
    
    //工具栏
    _toolBar = [[SNCommentToolBarView alloc]initWithFrame:CGRectMake(0, kAppScreenHeight, self.view.bounds.size.width, kCommentToolBarHeight)];
    _toolBar.backgroundColor = [UIColor clearColor];
    _toolBar.delegate = self;
    _toolBar.bottom = self.view.bounds.size.height;
    [_dynamicallyView addSubview:_toolBar];
    isFirstLoadView = YES;
    
    if (self.noshow == YES) {
        _maskBackgroundView.hidden = YES;
        _dynamicallyView.hidden  = YES;
        _toolBar.hidden = YES;
        return;
    }
}

- (void)loadView
{
    [super loadView];
    
    [self initAllSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGSize rect = [UIScreen mainScreen].bounds.size;
    [self.view setFrame:CGRectMake(0, 0, rect.width, rect.height)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	isViewVisible = YES;
//    [_textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [_textField resignFirstResponder];
    }
	isViewVisible = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isFirstLoadView)
    {
        isFirstLoadView = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [_textField resignFirstResponder];
    }
    
    isViewVisible = NO;
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
    
}

- (void)textFieldResignFirstResponder
{
    [_textField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initInputFieldView
{
    int inputWidth = kAppScreenWidth - kTextfieldLeft* 2;
    
    _textFieldBackView = [[UIView alloc] initWithFrame:CGRectMake(kTextfieldLeft, kTextfieldTop, inputWidth, kTextfieldHeight)];
    _textFieldBackView.backgroundColor = SNUICOLOR(kWebImageViewBackgroundColor);
    _textFieldBackView.layer.masksToBounds = YES;
    _textFieldBackView.layer.cornerRadius = 2.0f;
    [_dynamicallyView addSubview:_textFieldBackView];

    if (!_textField) {
        _textField = [[UITextView alloc] initWithFrame:CGRectMake(kTextfieldLeft + 3, kTextfieldTop, inputWidth - 6, kTextfieldHeight)];
        [_dynamicallyView addSubview:_textField];
    }
    _textField.text = @"";
    _textField.delegate = self;
    
//    _textField.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    _textField.font = [UIFont systemFontOfSize:KTextFieldFont];
//    _textField.textContainerInset = UIEdgeInsetsMake(8, 2, 0, 0);
    
    _textField.returnKeyType = UIReturnKeyDefault;
    _textField.enablesReturnKeyAutomatically = YES;
    _textField.backgroundColor = [UIColor clearColor];
    _textField.textColor = SNUICOLOR(kThemeTextRIColor);
    _textField.layer.masksToBounds = YES;
    _textField.layer.cornerRadius = 2.0f;
    [_textField setTintColor:SNUICOLOR(kThemeBlue1Color)];
    
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(kTextfieldLeft + 10, kTextfieldTop + 8,
                                                             _textField.width - 6, KTextFieldFont + 4)];
    }
    _tipLabel.font = [UIFont systemFontOfSize:KTextFieldFont];
    _tipLabel.textColor = SNUICOLOR(kThemeTextRI1Color);
    _tipLabel.backgroundColor = [UIColor clearColor];
    _tipLabel.hidden = NO;
    [_dynamicallyView addSubview:_tipLabel];
}

#pragma mark - SNActionSheetDelegate
- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 1: {
            [self popViewController];
            if (self.sendDelegateController && [self.sendDelegateController respondsToSelector:@selector(commentDidCancelPost)])
            {
                [self.sendDelegateController commentDidCancelPost];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - self method
- (void)showTips
{
    [_textField resignFirstResponder];
    
    NSString *contentString = @"";
    if ([_textField.text length] == 0) {
        NSString *imagePath = [self.sendDataDictionary objectForKey:kCommentDataKeyImagePath];
        NSString *audioPath = [self.sendDataDictionary objectForKey:kCommentDataKeyVoicePath];
        if (imagePath.length > 0) {
            contentString = @"您已经选择的图片将丢失";
        }
        if (audioPath.length > 0) {
            contentString = @"您已经录制的语音将丢失";
        }
    }else {
        contentString = @"您已经写下的文字将丢失";
    }

    SNActionSheet *commentActionSheet = [[SNActionSheet alloc] initWithTitle:@"取消评论?"
                                                                    delegate:self
                                                                   iconImage:[SNUtility chooseActEditIconImage]
                                                                     content:contentString
                                                                  actionType:SNActionSheetTypeDefault
                                                           cancelButtonTitle:@"取消"
                                                      destructiveButtonTitle:@"退出"
                                                           otherButtonTitles:nil];
    
    [[TTNavigator navigator].window addSubview:commentActionSheet];
    [commentActionSheet showActionViewAnimation];
}

- (void)popViewController
{
    if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [_textField resignFirstResponder];
        CGFloat height = _dynamicallyView.height;
        [UIView animateWithDuration:kCommentEditorViewShowTime animations:^(void) {
            _maskBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            _dynamicallyView.frame = CGRectMake(0, kAppScreenHeight, kAppScreenWidth, height);
        } completion:^(BOOL finished) {
            [self.flipboardNavigationController popViewControllerAnimated:NO];
        }];
    }
    else
        [self performSelectorOnMainThread:@selector(dismissModalViewController)
                               withObject:[NSNumber numberWithBool:YES] waitUntilDone:NO];
}

- (void)popCallBack:(void (^)(NSDictionary* info))method{
    if([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
        [_textField resignFirstResponder];
        CGFloat height = _dynamicallyView.height;
        [UIView animateWithDuration:0.1 animations:^(void) {
            _maskBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            _dynamicallyView.frame = CGRectMake(0, kAppScreenHeight, kAppScreenWidth, height);
        
        //xuejie 说要提前点
        
        } completion:^(BOOL finished) {
            [self.flipboardNavigationController popViewControllerAnimated:NO completion:^{
                if (method) {
                    method(nil);
                }
            }];
        }];
    }
    else{
        [self dismissCallBack:method];
    }
}

- (void)dismissCallBack:(void (^)(NSDictionary* info))method{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            if (method) {
                method(nil);
            }
        }];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self popViewController];
        
        if (self.sendDelegateController && [self.sendDelegateController respondsToSelector:@selector(commentDidCancelPost)])
        {
            [self.sendDelegateController commentDidCancelPost];
        }
    }
    else
    {
        self.confirmAlertView = nil;
    }
}

- (NSInteger)txtContentCount:(NSString*)s
{
	NSInteger i,n =[s length],l = 0,a = 0,b = 0;
	unichar c;
	for(i = 0;i < n;i++){
		c = [s characterAtIndex:i];
		if(isblank(c)){
			b ++;
		} else if(isascii(c)){
			a ++;
		} else {
			l ++;
		}
	}
	if(a == 0 && l == 0) return 0;
	return l + (int)ceilf((float)(a + b)/2.0);
}

- (BOOL)checkNeedToLogin
{
    if(![SNUserManager isLogin])
    {
//        [_textView resignFirstResponder];
        [self changeInputViewStateTo:kSNCommentInputStateBottom
                      keyboardHeight:_keyBoardHeight
                   animationDuration:.25];
        [self setTextViewFrame];
        [self startLogin];
        return YES;
    }
    return NO;
}

- (void)focusInput
{
//    [_textView becomeFirstResponder];
}

- (BOOL)shouldShowLogin
{
    id data = [SNUserDefaults objectForKey:kCommontLoginTip];
    if (data && [data isKindOfClass:[NSDate class]])
    {
        return [(NSDate *)[data dateByAddingTimeInterval:kCommontLoginTipInterval] compare:[NSDate date]] < 0;
    }
    else
    {
        return YES;
    }
}

- (void)showMessage:(NSString*)message
{
    [[SNCenterToast shareInstance] showCenterToastWithTitle:message toUrl:nil mode:SNCenterToastModeWarning];
}

#pragma mark -
#pragma mark guideNotifacation
- (void)guideLoginSuccess
{
    [self focusInput];
}

- (void)guideRegisterViewOnBack
{
    [self focusInput];
}


#pragma mark -
#pragma mark overwrite
- (void)setSendButtonState
{
}

- (void)setMediaMode:(SNCommentMediaMode)mode
{
}

- (void)setMediaViewPosition:(BOOL)animation
{
}

- (void)layoutSubViews:(SNCommentMediaMode)modeType animation:(BOOL)animation
{
}

- (void)onBack
{
    [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = YES;
    [[SNSoundManager sharedInstance] stopAmr];
    [self popViewController];
    if (self.sendDelegateController && [self.sendDelegateController respondsToSelector:@selector(commentDidCancelPost)])
    {
        [self.sendDelegateController commentDidCancelPost];
    }
}

- (void)outsideTap:(UITapGestureRecognizer *)recognizer
{
    
}

- (void)startLogin
{
    switch (loginType) {
        case SNCommentLoginTypeImage:
            [SNGuideRegisterManager showGuideWithContentCommentImage];
            break;
        case SNCommentLoginTypeAudio:
            [SNGuideRegisterManager showGuideWithContentCommentAudio];
            break;
        default:
            [SNGuideRegisterManager showGuideWithContentComment:nil];
            break;
    }
}

- (void)setTextViewFrame
{
}

- (void)fastTextInsertText:(NSString *)text selectRange:(NSRange)sRange markedRange:(NSRange)mRange
{
    if (text.length > 0 && !_tipLabel.hidden) {
        _tipLabel.hidden = YES;
    }
    else if(text.length == 0)
    {
        _tipLabel.hidden = NO;
    }
    [self setSendButtonState];
}

- (void)fastTextDeleteText
{
//    if (_textView.text.length == 0 && _tipLabel.hidden) {
//        _tipLabel.hidden = NO;
//    }
}

- (void)emoticonDidSelect:(SNEmoticonObject *)emoticon
{
    NSRange selectRange = _textField.selectedRange;
    NSMutableString *currentText = [NSMutableString stringWithString:_textField.text];
    [currentText insertString:emoticon.chineseName atIndex:selectRange.location];
    _textField.text = currentText;
    [self textViewDidChange:_textField];
    
    NSRange r = selectRange;
    if (r.location == (_textField.text.length - emoticon.chineseName.length) && r.length == 0) {
        [self performSelector:@selector(scrollCursorToEnd) withObject:nil afterDelay:0.1];
    }
}

- (void)scrollCursorToEnd {
    CGRect r = CGRectMake(0, _textField.contentSize.height-10, _textField.bounds.size.width, 8);
    [_textField scrollRectToVisible:r animated:YES];
}

- (void)emoticonDidDelete
{
    NSRange selectRange = _textField.selectedRange;
    if (selectRange.location > 0) {
        NSRange deleteRange = NSMakeRange(selectRange.location - 1, 1);
        NSMutableString *currentText = [NSMutableString stringWithString:_textField.text];
        
        if ([[_textField.text substringWithRange:deleteRange] isEqualToString:@"]"]) {
            NSString *subtext = [_textField.text substringToIndex:deleteRange.location];
            if (subtext.length > 0) {
                [self deleteEmoticonStringInRange:currentText range:deleteRange];
            }
        }
        else {
            [currentText deleteCharactersInRange:deleteRange];
            _textField.text = currentText;
            [self textViewDidChange:_textField];
        }
    }
}

- (void)deleteEmoticonStringInRange:(NSMutableString *)currentText range:(NSRange)range
{
    NSString *subtext = [_textField.text substringToIndex:range.location];
    if (subtext.length > 0) {
        NSInteger index = subtext.length - 1;
        for (; index >= 0; index--) {
            NSString *subChar = [currentText substringWithRange:NSMakeRange(index, 1)];
            if ([subChar isEqualToString:@"["]) {
                break;
            }
        }
        NSRange deleteRange = NSMakeRange(index, range.location - index + 1);
        if (deleteRange.location + deleteRange.length <= currentText.length) {
            [currentText deleteCharactersInRange:deleteRange];
            _textField.text = currentText;
            [self textViewDidChange:_textField];
        }
    }
}

- (BOOL)hasText
{
    return (_textField.text.length != 0);
}

- (void)insertText:(NSString *)text
{
    
}

- (void)deleteBackward
{
    
}

-(NSDictionary *)defaultAttributes{
    UIFont *font = [UIFont systemFontOfSize:KTextFieldFont];
    NSString *fontName = [font fontName]; //@"Hiragino Sans GB";
    CGFloat fontSize = font.pointSize;
    UIColor *color = SNUICOLOR(kPhotoListDetailColor);       //字体颜色
    UIColor *strokeColor = [UIColor whiteColor];
    CGFloat strokeWidth = 0.0;
    CGFloat paragraphSpacing = 0.0;
    CGFloat paragraphSpacingBefore = 0.0;
    CGFloat lineSpacing = 5.0;
    CGFloat minimumLineHeight = 21.0;
    CGFloat leading = font.lineHeight - font.ascender + font.descender;
    
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName,
                                             fontSize, NULL);
    
    CTParagraphStyleSetting settings[] = {
        { kCTParagraphStyleSpecifierParagraphSpacingBefore, sizeof(CGFloat), &paragraphSpacingBefore },
        { kCTParagraphStyleSpecifierParagraphSpacing, sizeof(CGFloat), &paragraphSpacing },
        { kCTParagraphStyleSpecifierLineSpacing, sizeof(CGFloat), &lineSpacing },
        { kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(CGFloat), &minimumLineHeight },
        { kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(CGFloat), &minimumLineHeight },
        { kCTParagraphStyleSpecifierLineSpacingAdjustment, sizeof (CGFloat), &leading },
        //{ kCTParagraphStyleSpecifierFirstLineHeadIndent, sizeof(CGFloat), &headIndent },
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, ARRSIZE(settings));
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)color.CGColor, kCTForegroundColorAttributeName,
                           (__bridge id)fontRef, kCTFontAttributeName,
                           (id)strokeColor.CGColor, (NSString *) kCTStrokeColorAttributeName,
                           (id)[NSNumber numberWithFloat: strokeWidth], (NSString *)kCTStrokeWidthAttributeName,
                           (__bridge id) paragraphStyle, (NSString *) kCTParagraphStyleAttributeName,
                           nil];
    
    CFRelease(fontRef);
    CFRelease(paragraphStyle);
    return attrs;
}

#pragma mark- fastTextViewDelegate
- (BOOL)fastTextViewShouldBeginEditing:(FastTextView *)textView {
    return YES;
}

- (BOOL)fastTextViewShouldEndEditing:(FastTextView *)textView {
    return YES;
}

@end
