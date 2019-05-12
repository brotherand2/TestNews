//
//  SNLiveInputBar.m
//  sohunews
//
//  Created by chenhong on 13-6-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveInputBar.h"
#import "UIColor+ColorUtils.h"
#import "Toast+UIView.h"
#import "SNPlaceholderTextView.h"
#import "SNUserManager.h"

#define FRONT   15.0
#define TEXTVIEW_X 10
#define TEXTVIEW_Y (14.5)
#define TEXTVIEW_W kAppScreenWidth - 20
#define TEXTVIEW_H 33.5

#define BTN_POST_BOTTOM_GAP (8/2)
#define BTN_POST_X kAppScreenWidth - 68
#define BTN_IMG_X 60
#define BTN_IMG_BOTTOM_GAP (8/2)

#define kToolbarButtonWidth         50
#define kToolbarButtonHeight        40

#define ENABLE_FACE 1

@interface SNLiveInputBar () {
    SNPlaceholderTextView *_textView;
    UIButton *_pickImgBtn;
    UIButton *_pickImgPreviewBtn;
    UIImage *_editedImage;
    UIButton *_recBtn;
    UIButton *_faceBtn;
    CGFloat _initHeight;
    UIButton *_sendBtn;
}

@end

@implementation SNLiveInputBar
@synthesize delegate=_delegate;
@synthesize pickingImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addKeyboardAccessoryInputView];
        _initHeight = frame.size.height;
    }
    return self;
}

- (void)dealloc {
}

- (float) heightForTextView: (UITextView *)textView WithText: (NSString *) strText{
    float fPadding = 16.0;
    CGSize constraint = CGSizeMake(textView.contentSize.width - fPadding, CGFLOAT_MAX);
    CGSize size = [strText textSizeWithFont:textView.font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    float fHeight = size.height + 16.0;
    return fHeight;
}

- (NSInteger)txtContentCount:(NSString *)s {
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
	return l + (NSInteger)ceilf((float)(a + b)/2.0);
}

- (void)addKeyboardAccessoryInputView {
    @autoreleasepool {
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
        bg = [bg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
        bgView.image = bg;
        bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:bgView];
        bgView.tag = 102;
        
        SNPlaceholderTextView *textView = [[SNPlaceholderTextView  alloc] initWithFrame:CGRectMake(TEXTVIEW_X,TEXTVIEW_Y,TEXTVIEW_W,TEXTVIEW_H)];
        textView.returnKeyType = UIReturnKeyDefault;
        textView.font = [UIFont  systemFontOfSize:15];
        textView.layer.masksToBounds = YES;
        textView.scrollEnabled = NO;
        textView.layer.cornerRadius = 3;
        textView.layer.borderColor = [[UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1.0] CGColor];
        textView.layer.borderWidth = 0.7;
        textView.contentInset = UIEdgeInsetsMake(0, 0, 2, 0);
        textView.delegate = self;
        textView.exclusiveTouch = YES;
        textView.scrollsToTop = NO;
        textView.textColor = [UIColor blackColor];
        textView.placeholderColor = [UIColor darkGrayColor];
        textView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCommentPostBgColor]];
        _textView = textView;
        [self addSubview:_textView];
        
        UIImage *imgNomal = [UIImage imageNamed:@"comment_send_button_enable.png"];
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendBtn.frame = CGRectMake(BTN_POST_X,self.bounds.size.height-BTN_POST_BOTTOM_GAP-imgNomal.size.height,imgNomal.size.width,imgNomal.size.height);
        [_sendBtn setBackgroundImage:imgNomal  forState:UIControlStateNormal];
        _sendBtn.exclusiveTouch = YES;
        _sendBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _sendBtn.accessibilityLabel = @"发表评论";
        [_sendBtn addTarget:self action:@selector(doPost:) forControlEvents:UIControlEventTouchUpInside];
        _sendBtn.tag = 101;
        [self addSubview:_sendBtn];
        
        // 录音
        UIImage *recImgNormal = [UIImage imageNamed:@"comment_record_icon.png"];
        UIImage *recImgPress = [UIImage imageNamed:@"comment_record_icon_hl.png"];
        
        _recBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recBtn addTarget:self action:@selector(onRecBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_recBtn];
        
        _recBtn.accessibilityLabel = @"录音";
        _recBtn.frame = CGRectMake(0, self.height-BTN_IMG_BOTTOM_GAP-recImgNormal.size.height, recImgNormal.size.width, recImgNormal.size.height);
        _recBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_recBtn setImage:recImgNormal forState:UIControlStateNormal];
        [_recBtn setImage:recImgPress forState:UIControlStateHighlighted];
        
        // 表情
#if ENABLE_FACE
        UIImage *faceImgNormal = [UIImage imageNamed:@"comment_emoticon_icon.png"];
        UIImage *faceImgHL = [UIImage imageNamed:@"comment_emoticon_icon_hl.png"];
        _faceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _faceBtn.contentMode = UIViewContentModeScaleAspectFit;
        _faceBtn.exclusiveTouch = YES;
        _faceBtn.frame = CGRectMake(0, 0, faceImgNormal.size.width, faceImgNormal.size.height);
        _faceBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_faceBtn setImage:faceImgNormal forState:UIControlStateNormal];
        [_faceBtn setImage:faceImgHL forState:UIControlStateHighlighted];
        [_faceBtn addTarget:self action:@selector(onFaceBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_faceBtn];
#endif
        
        // 上传图片
        _pickImgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pickImgBtn.contentMode = UIViewContentModeScaleAspectFit;
        _pickImgBtn.exclusiveTouch = YES;
        _pickImgBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        UIImage *img = [UIImage imageNamed:@"comment_camra_icon.png"];
        UIImage *imghl = [UIImage imageNamed:@"comment_camra_icon_hl.png"];
        _pickImgBtn.frame = CGRectMake(BTN_IMG_X, self.height-BTN_IMG_BOTTOM_GAP-img.size.height, img.size.width, img.size.height);
        [_pickImgBtn setImage:img forState:UIControlStateNormal];
        [_pickImgBtn setImage:imghl forState:UIControlStateHighlighted];
        [_pickImgBtn addTarget:self action:@selector(doImagePick:) forControlEvents:UIControlEventTouchUpInside];
        _pickImgBtn.accessibilityLabel = @"选择图片";
        [self addSubview:_pickImgBtn];
        
        // 照片背景
        _pickImgPreviewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _pickImgPreviewBtn.contentMode= UIViewContentModeScaleToFill;
        _pickImgPreviewBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        UIImage *delImg = [UIImage imageNamed:@"post_follow_del_bg.png"];
        _pickImgPreviewBtn.frame = CGRectInset(_pickImgBtn.frame, 5, 5);
        [_pickImgPreviewBtn setImage:delImg forState:UIControlStateNormal];
        [_pickImgPreviewBtn addTarget:self action:@selector(doImagePick:) forControlEvents:UIControlEventTouchUpInside];
        _pickImgPreviewBtn.hidden = YES;
        _pickImgPreviewBtn.clipsToBounds = YES;
        [self addSubview:_pickImgPreviewBtn];
        
#if ENABLE_FACE
        NSArray *btnArray = [NSArray arrayWithObjects:_recBtn, _faceBtn, _pickImgBtn, nil];
#else
        NSArray *btnArray = [NSArray arrayWithObjects:_recBtn, _pickImgBtn, nil];
#endif
        
        NSInteger buttonsCount = [btnArray count];
        float centerY = self.height - 44/2;
        
        for (int i = 0; i < buttonsCount; i++) {
            UIButton *button = [btnArray objectAtIndex:i];
            button.center = CGPointMake(kToolbarButtonWidth * i + kToolbarButtonWidth/2, centerY);
            
            if (i > 0) {
                NSString *sepName = @"comment_sepline.png";
                UIImage *sepImage = [UIImage imageNamed:sepName];
                UIImageView *sepImageView = [[UIImageView alloc] initWithImage:sepImage];
                CGRect imageRect = CGRectMake(kToolbarButtonWidth * i, centerY - sepImage.size.height/2, sepImage.size.width, sepImage.size.height);
                sepImageView.frame = imageRect;
                sepImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
                [self addSubview:sepImageView];
            }
        }
        
        _pickImgBtn.top -= 1;
        _pickImgPreviewBtn.frame = CGRectInset(_pickImgBtn.frame, 5, 5);
    }
}

- (void)setPlaceHolder:(NSString *)txt {
    _textView.placeholder = txt;
}

- (void)focus {
    [_textView becomeFirstResponder];
    self.pickingImage = NO;
    [self changeToFaceBtn];
    [self changeToCameraBtn];
}

- (void)resignFocus {
    [_textView resignFirstResponder];
}

- (BOOL)isFirstResponder {
    return [_textView isFirstResponder];
}

//缩小图片以处理相框周边透明的问题
-(UIImage*)imageForFrame:(CGRect)desRect image:(UIImage*)scaleImage
{
    UIGraphicsBeginImageContext(CGSizeMake(desRect.size.width*2, desRect.size.height*2));
    desRect.origin.x = 6;
    desRect.origin.y = 6;
    desRect.size.width = desRect.size.width*2 - 12;
    desRect.size.height = desRect.size.height*2 - 12;
    [scaleImage drawInRect:desRect];
    UIImage* resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

- (NSString *)strContent {
    return [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)setContent:(NSString *)str {
    if (str) {
        _textView.text = str;
        [self textViewDidChange:_textView];
    }
}

- (UIImage *)editedImage {
    return _editedImage;
}

- (void)setInputImage:(UIImage *)image {
    image = [UIImage rotateImage:image];
    
    CGSize imgSize = image.size;
    //所有直播间上传照片最大像素1080等比例压缩
    CGFloat maxPix = 1080/2;
    
    if (imgSize.width > imgSize.height) {
       CGFloat  scale = imgSize.height/imgSize.width;
        if (imgSize.width > maxPix) {
            imgSize.width = maxPix;
            imgSize.height = scale * maxPix;
        }
    }else {
      CGFloat  scale = imgSize.width/imgSize.height;
        if (imgSize.height > maxPix) {
            imgSize.height = maxPix;
            imgSize.width = scale * maxPix;
        }
    }

    image = [UIImage imageWithImage:image scaledToSize:imgSize];
    if (_editedImage != image) {
        _editedImage = image;
    }
    
    if (_editedImage) {
        CGRect desRect = _pickImgBtn.frame;
        UIImage *resultingImage = [self imageForFrame:desRect image:_editedImage];
        [_pickImgBtn setImage:resultingImage forState:UIControlStateNormal];
        [_pickImgBtn setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        
        _pickImgPreviewBtn.hidden = NO;
    }
    else {
        _pickImgPreviewBtn.hidden = YES;
        if (self.inputMode == INPUT_PIC) {
            [self changeToKeyboardBtn:_pickImgBtn];
        } else {
            [self changeToCameraBtn];
        }
    }
    [self updateSendBtnState];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (range.location == 0 && range.length == 0 && [text isEqualToString:@"\n"]) {
        return NO;
    }
    textView.scrollEnabled = YES;
    return YES;
}

- (void)setTextViewFrameByContentSize {
    CGFloat maxHeight = 102.0f;
    CGFloat fixedWidth = _textView.frame.size.width;
    CGSize newSize = [_textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = _textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), fminf(newSize.height, maxHeight));
    
    if (!CGRectEqualToRect(_textView.frame, newFrame)) {
        float diff = newFrame.size.height - _textView.frame.size.height;
        if (fabs(diff) > 10) {
            _textView.frame = newFrame;
            self.height += round(diff);
        }
    }
    
    if (_textView.frame.size.height >= maxHeight) {
        if (_textView.scrollEnabled == NO) {
            _textView.scrollEnabled = YES;
            _textView.contentOffset = CGPointMake(0, newSize.height - maxHeight);
            [_textView flashScrollIndicators];
        }
    } else {
        if (_textView.scrollEnabled == YES) {
            _textView.scrollEnabled = NO;
            [_textView scrollRangeToVisible:NSMakeRange(_textView.text.length, 0)];
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat oldH = self.height;
    [self setTextViewFrameByContentSize];
    
    [self fixIOS7UITextView:textView];
    
    if (self.height - oldH) {
        self.top -= (self.height - oldH);
        if ([_delegate respondsToSelector:@selector(liveInputBarFrameChanged:)]) {
            [_delegate liveInputBarFrameChanged:self.frame];
        }
    }
    
    [self updateSendBtnState];
}

// http://stackoverflow.com/questions/18966675/uitextview-in-ios7-clips-the-last-line-of-text-string
- (void)fixIOS7UITextView:(UITextView *)textView {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        CGRect line = [textView caretRectForPosition:
                       textView.selectedTextRange.start];
        CGFloat overflow = line.origin.y + line.size.height
        - ( textView.contentOffset.y + textView.bounds.size.height
           - textView.contentInset.bottom - textView.contentInset.top );
        if ( overflow > 0 ) {
            // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
            // Scroll caret to visible area
            CGPoint offset = textView.contentOffset;
            offset.y += overflow + 7; // leave 7 pixels margin
            // Cannot animate with setContentOffset:animated: or caret will not appear
            [UIView animateWithDuration:.2 animations:^{
                [textView setContentOffset:offset];
            }];
        }
    } else {
        [textView scrollRangeToVisible:[textView selectedRange]];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.inputMode == INPUT_EMO) {
        [self changeToFaceBtn];
    }
    else if (self.inputMode == INPUT_PIC) {
        [self changeToCameraBtn];
    }
    
    self.inputMode = INPUT_KEYBOARD;
    [self changeTextColorToGray:NO];
    [self updateSendBtnState];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [textView scrollRangeToVisible:[textView selectedRange]];
    }
}

- (void)updateSendBtnState {
    if (_textView.text.length == 0 && _pickImgPreviewBtn.hidden == YES) {
        _sendBtn.enabled = NO;
    } else {
        _sendBtn.enabled = YES;
    }
}

- (void)textViewInsertText:(NSString *)str {
    NSRange selectRange = _textView.selectedRange;
    NSMutableString *currentText = [NSMutableString stringWithString:_textView.text];
    [currentText insertString:str atIndex:selectRange.location];
    _textView.text = currentText;
    [self textViewDidChange:_textView];

    NSRange r = selectRange;
    if (r.location == (_textView.text.length - str.length) && r.length == 0) {
        [self performSelector:@selector(scrollCursorToEnd) withObject:nil afterDelay:0.1];
    }
}

- (void)scrollCursorToEnd {
    CGRect r = CGRectMake(0, _textView.contentSize.height-10, _textView.bounds.size.width, 8);
    [_textView scrollRectToVisible:r animated:YES];
}

- (void)textViewDeleteEmoticon {
    NSRange selectRange = _textView.selectedRange;
    if (selectRange.location > 0) {
        NSRange deleteRange = NSMakeRange(selectRange.location - 1, 1);
        NSMutableString *currentText = [NSMutableString stringWithString:_textView.text];
        
        if ([[_textView.text substringWithRange:deleteRange] isEqualToString:@"]"]) {
            NSString *subtext = [_textView.text substringToIndex:deleteRange.location];
            if (subtext.length > 0) {
                [self deleteEmoticonStringInRange:currentText range:deleteRange];
            }
        }
        else {
            [currentText deleteCharactersInRange:deleteRange];
            _textView.text = currentText;
            [self textViewDidChange:_textView];
        }
    }
}

- (void)deleteEmoticonStringInRange:(NSMutableString *)currentText range:(NSRange)range
{
    NSString *subtext = [_textView.text substringToIndex:range.location];
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
            _textView.text = currentText;
            [self textViewDidChange:_textView];
        }
    }
}

- (BOOL)shouldShowUserInfo
{
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:kCommontLoginTip];
    if (data && [data isKindOfClass:[NSDate class]])
    {
        return [(NSDate *)[data dateByAddingTimeInterval:kCommontLoginTipInterval] compare:[NSDate date]] < 0;
    }
    else
    {
        return YES;
    }
}

- (void)doPost:(id)sender {
    if (![SNUserManager isLogin]) {
        if ([self shouldShowUserInfo]) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kCommontLoginTip];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if ([_delegate respondsToSelector:@selector(liveInputBarDoLogin)]) {
                [_delegate liveInputBarDoLogin];
                return;
            }
        }
    }
    
    NSInteger count = [self txtContentCount:[_textView.text trim]];
    
    if (count > 1000) {
        [self showMessageAboveKeyboard:@"评论内容应不多于1000个字"];
    }
    else if ((count > 0 && count <= 1000) || self.editedImage != nil) {
        self.height = _initHeight;
        _textView.frame = CGRectMake(TEXTVIEW_X,TEXTVIEW_Y,TEXTVIEW_W,TEXTVIEW_H);

        if ([_delegate respondsToSelector:@selector(liveInputBarDoPost)]) {
            [_delegate liveInputBarDoPost];
            _textView.text = nil;
        }
    }
    else {
        _textView.text = nil;
        [self showMessageAboveKeyboard:@"请输入评论内容"];
    }
}

- (void)onRecBtn:(id)sender {
    if ([_delegate respondsToSelector:@selector(liveInputBarDoRecord)]) {
        self.inputMode = INPUT_REC;
        [_delegate liveInputBarDoRecord];
        return;
    }
}

- (void)onFaceBtn:(id)sender {
    if ([self isFirstResponder]) {
            [self changeToInputFaceMode];
    } else {
        if (self.inputMode == INPUT_EMO) {
            [self focus];
        } else {
            [self changeToInputFaceMode];
        }
    }
}

- (void)changeToInputFaceMode {
    if ([_delegate respondsToSelector:@selector(liveInputBarDoEmoPick)]) {
        [_delegate liveInputBarDoEmoPick];
    }
    self.pickingImage = YES;
    self.inputMode = INPUT_EMO;
    [self changeToKeyboardBtn:_faceBtn];
    [self changeToCameraBtn];
    [self resignFocus];
}

- (void)doImagePick:(id)sender {
    if (_pickImgPreviewBtn.hidden) {
        if ([self isFirstResponder]) {
            if (![SNUserManager isLogin]) {
                if ([_delegate respondsToSelector:@selector(liveInputBarPostImageDoLogin)]) {
                    [_delegate liveInputBarPostImageDoLogin];
                    return;
                }
            }
            
            BOOL bAllowPicImage = YES;
            if ([_delegate respondsToSelector:@selector(liveInputBarImageAllowed:)]) {
                bAllowPicImage = [_delegate liveInputBarImageAllowed:YES];
            }
            
            if (bAllowPicImage) {
                [self changeToInputPicMode];
            }
        } else {
            if (self.inputMode == INPUT_PIC) {
                [self focus];
            } else {
                [self changeToInputPicMode];
            }
        }
    } else {
        [self setInputImage:nil];
    }
}

- (void)changeToInputPicMode {
    self.inputMode = INPUT_PIC;
    if ([_delegate respondsToSelector:@selector(liveInputBarDoImagePick)]) {
        [_delegate liveInputBarDoImagePick];
    }
    self.pickingImage = YES;
    [self changeToKeyboardBtn:_pickImgBtn];
    [self changeToFaceBtn];
    [self resignFocus];
}

- (void)postSucccess:(SNLiveCommentType)type {
    if (type == SNLiveCommentTypePicAndTxt) {
    }
}

- (void)postFailure:(NSString *)txt {
    // 发送失败后，文本框恢复上次发送的文本
    if (_textView.text.length == 0 && !_textView.isFirstResponder) {
        //_textView.text = txt;
        [self setContent:txt];
    }
}

- (void)showMessageAboveKeyboard:(NSString *)text {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:text toUrl:nil mode:SNCenterToastModeOnlyText];
}

#pragma mark -
- (void)updateTheme {
    
    UIImage *bg = [UIImage imageNamed:@"postTab0.png"];
    bg = [bg resizableImageWithCapInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
    
    UIImageView *bgImgView = (UIImageView *)[self viewWithTag:102];
    [bgImgView setImage:bg];
    
    NSString *strColor1 = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kCommentPostBgColor];
    _textView.backgroundColor = [UIColor colorFromString:strColor1];
    
    UIImage *imgNomal = [UIImage imageNamed:@"comment_send_button_enable.png"];
    UIButton *btnPost = (UIButton *)[self viewWithTag:101];
    [btnPost setBackgroundImage:imgNomal  forState:UIControlStateNormal];
    [btnPost setTitleColor:kThemeColor forState:UIControlStateNormal];
    
    [_pickImgPreviewBtn setImage:[UIImage imageNamed:@"post_follow_del_bg.png"] forState:UIControlStateNormal];
    
    if (_pickImgPreviewBtn.hidden) {
        if (self.pickingImage) {
            if (self.inputMode == INPUT_PIC) {
                [self changeToKeyboardBtn:_pickImgBtn];
            } else if (self.inputMode == INPUT_EMO) {
                [self changeToKeyboardBtn:_faceBtn];
            }
        } else {
            [self changeToCameraBtn];
        }
    }
}

- (void)changeTextColorToGray:(BOOL)bGray {
    UIColor *txtColor = bGray ? [UIColor grayColor] : [UIColor blackColor];
    [_textView setTextColor:txtColor];
}

- (void)changeToKeyboardBtn:(UIButton *)btn {
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [btn setImage:[UIImage imageNamed:@"tb_keyboard.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"tb_keyboard_hl.png"] forState:UIControlStateHighlighted];
}

- (void)changeToCameraBtn {
    if (_pickImgPreviewBtn.hidden) {
        [_pickImgBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_pickImgBtn setImage:[UIImage imageNamed:@"comment_camra_icon.png"] forState:UIControlStateNormal];
        [_pickImgBtn setImage:[UIImage imageNamed:@"comment_camra_icon_hl.png"] forState:UIControlStateHighlighted];
    }
}

- (void)changeToFaceBtn {
    [_faceBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_faceBtn setImage:[UIImage imageNamed:@"comment_emoticon_icon.png"] forState:UIControlStateNormal];
    [_faceBtn setImage:[UIImage imageNamed:@"comment_emoticon_icon_hl.png"] forState:UIControlStateHighlighted];
}

- (void)setInputMode:(SNLiveInputModeEnum)inputMode {
    SNDebugLog(@"inputMode: %d -> %d", _inputMode, inputMode);
    _inputMode = inputMode;
}

@end
