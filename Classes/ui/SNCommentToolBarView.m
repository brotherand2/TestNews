//
//  SNCommentToolBarView.m
//  sohunews
//
//  Created by jialei on 13-6-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNCommentToolBarView.h"
#import "SNThemeManager.h"
#import "UIImage+Utility.h"
#import "SNRollingNewsPublicManager.h"

@interface SNCommentToolBarView()
{
    UIButton *_cameraButton;
    UIButton *_recordButton;
    UIButton *_shareButton;
    UIButton *_sendButton;
    UIButton *_emoticonButton;
    
    UIImageView *_arrowView;
    UIView   *_leftArrowView;
    UIView   *_rightArrowView;
    
    BOOL _isCameraType;
    BOOL _isRecordType;
    BOOL _isEmoticonType;
}

@property (nonatomic, strong)UIImage *cameraImage;
@property (nonatomic, strong)UIImage *cameraImageHL;
@property (nonatomic, strong)UIImage *recordImage;
@property (nonatomic, strong)UIImage *recordImageHL;
@property (nonatomic, strong)UIImage *keyordImage;
@property (nonatomic, strong)UIImage *shareImage;
@property (nonatomic, strong)UIImage *shareImageHL;
@property (nonatomic, strong)UIImage *emoticonImage;
@property (nonatomic, strong)UIImage *emoticonImageHL;

@end

@implementation SNCommentToolBarView

@synthesize delegate = _delegate;
@synthesize commentToolBarType;
@synthesize funcButtons = _funcButtons;
@synthesize cameraImage = _cameraImage;
@synthesize cameraImageHL = _cameraImageHL;
@synthesize recordImage = _recordImage;
@synthesize recordImageHL = _recordImageHL;
@synthesize keyordImage = _keyordImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        //cameraButton
        self.cameraImage = [UIImage themeImageNamed:@"icopl_picture_v5.png"];
        self.cameraImageHL = [UIImage themeImageNamed:@"icopl_picturepress_v5.png"];
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraButton.accessibilityLabel = @"添加图片";
        [_cameraButton setImage:self.cameraImage forState:UIControlStateNormal];
        [_cameraButton setImage:self.cameraImageHL forState:UIControlStateHighlighted];

        [_cameraButton addTarget:self action:@selector(cameraButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cameraButton];
        _isCameraType = NO;
        
        //recordButton
        self.recordImage = [UIImage themeImageNamed:@"icopl_yuyin_v5.png"];
        self.recordImageHL = [UIImage themeImageNamed:@"icopl_yuyinpress_v5.png"];
        _recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _recordButton.accessibilityLabel = @"添加语音";
        [_recordButton addTarget:self action:@selector(recordButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton setImage:self.recordImage forState:UIControlStateNormal];
        [_recordButton setImage:self.recordImageHL forState:UIControlStateHighlighted];
        
        [self addSubview:_recordButton];
        _isRecordType = NO;
        
        //shareButton
        self.shareImage = [UIImage themeImageNamed:@"icopl_share_v5.png"];
        self.shareImageHL = [UIImage themeImageNamed:@"icopl_sharepress_v5.png"];
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.accessibilityLabel = @"添加分享源";
        [_shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_shareButton setImage:self.shareImage forState:UIControlStateNormal];
        [_shareButton setImage:self.shareImageHL forState:UIControlStateHighlighted];
        [self addSubview:_shareButton];
        
        self.keyordImage = [UIImage imageNamed:@"icopl_jp_v5.png"];
        
        //emoticonButton
        self.emoticonImage = [UIImage themeImageNamed:@"icopl_bq_v5.png"];
        self.emoticonImageHL = [UIImage themeImageNamed:@"icopl_bqpress_v5.png"];
        _emoticonButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _emoticonButton.accessibilityLabel = @"添加表情";
        [_emoticonButton addTarget:self action:@selector(emoticonButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_emoticonButton setImage:self.emoticonImage forState:UIControlStateNormal];
        [_emoticonButton setImage:self.emoticonImageHL forState:UIControlStateHighlighted];
        [self addSubview:_emoticonButton];
        _isEmoticonType = NO;
        
        //sendButton
        _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - kSendButtonRight - kSendButtonWidth, kSendButtonTop, kSendButtonWidth, kSendButtonHeight)];
        [_sendButton addTarget:self action:@selector(sendButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        _sendButton.backgroundColor = SNUICOLOR(kThemeBg1Color);
        [_sendButton setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
        [_sendButton setTitle:@"发表" forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _sendButton.layer.masksToBounds = YES;
        _sendButton.layer.cornerRadius = 2;
        
        _sendButton.enabled = NO;
        _sendButton.accessibilityLabel = @"发表当前评论";
        [self addSubview:_sendButton];
        
        self.showShare = YES;
        self.funcButtons = nil;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.commentToolBarType == SNCommentToolBarTypeTextAndCamAndRec)
    {
        self.funcButtons = [NSArray arrayWithObjects:_cameraButton, _recordButton, nil];
    }
    else if (self.commentToolBarType == SNCommentToolBarTypeTextAndRec)
    {
        self.funcButtons = [NSArray arrayWithObjects:_recordButton, nil];
    }
    else if (self.commentToolBarType == SNCommentToolBarTypeTextAndEmoticon)
    {
        self.funcButtons = [NSArray arrayWithObjects:_emoticonButton, nil];
    }
    else if (self.commentToolBarType == SNCommentToolBarTypeShowAll)
    {
        self.funcButtons = [NSArray arrayWithObjects:_recordButton, _emoticonButton, _cameraButton, _shareButton, nil];
    }
    else if (self.commentToolBarType == SNCommentToolBarTypeTextAndEmoticonAndShare)
    {
        self.funcButtons = [NSArray arrayWithObjects:_emoticonButton, _shareButton, nil];
    }
    else if (self.commentToolBarType == SNCommentToolBarTypeTextAndRecAndEmoticonAndCam)
    {
        self.funcButtons = [NSArray arrayWithObjects:_recordButton, _emoticonButton, _cameraButton, nil];
    }
    
    NSInteger buttonsCount = [self.funcButtons count];
    for (int i = 0; i < buttonsCount; i++)
    {
        UIButton *button = [self.funcButtons objectAtIndex:i];
        button.frame = CGRectMake(6 + kToolbarButtonWidth * i, kToolbarButtonOriginY, kToolbarButtonWidth, kToolbarButtonHeight);
    }
    [self setArrowView:self.showShare];
}

- (void)setSendButtonEnable
{
    _sendButton.backgroundColor = SNUICOLOR(kThemeRed1Color);
    [_sendButton setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    _sendButton.enabled = YES;
}

- (void)setSendButtonDisable
{
    _sendButton.backgroundColor = SNUICOLOR(kThemeBg1Color);
    [_sendButton setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    _sendButton.enabled = NO;
}

#pragma mark -
#pragma buttons function
//切换照相和键盘图标
- (void)changedCameraButtonState
{
    if (!_isCameraType) {
        [_cameraButton setImage:self.keyordImage forState:UIControlStateNormal];
//        [self changedOtherButtonState];
        _isCameraType = YES;
    } else {
        [_cameraButton setImage:self.cameraImage forState:UIControlStateNormal];
        _isCameraType = NO;
    }
}

//切换录音和键盘图标
- (void)changedRecordButtonState
{
    if (!_isRecordType) {
        [_recordButton setImage:self.keyordImage forState:UIControlStateNormal];
//        [self changedOtherButtonState];
        _isRecordType = YES;
    } else {
        [_recordButton setImage:self.recordImage forState:UIControlStateNormal];
        _isRecordType = NO;
    }
}

- (void)changedEmoticonButtonState
{
    if (!_isEmoticonType) {
        [_emoticonButton setImage:self.keyordImage forState:UIControlStateNormal];
//        [self changedOtherButtonState];
        _isEmoticonType = YES;
    } else {
        [_emoticonButton setImage:self.emoticonImage forState:UIControlStateNormal];
        _isEmoticonType = NO;
    }
}

- (void)changedOtherButtonState
{
    if (_isCameraType) {
        [_cameraButton setImage:self.cameraImage forState:UIControlStateNormal];
        _isCameraType = NO;
    }
    else if(_isRecordType) {
        [_recordButton setImage:self.recordImage forState:UIControlStateNormal];
        _isRecordType = NO;
    }
    else if(_isEmoticonType) {
        [_emoticonButton setImage:self.emoticonImage forState:UIControlStateNormal];
        _isEmoticonType = NO;
    }
}

- (void)cameraButtonPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SNCommentToolCamraFunction)])
    {
        BOOL result = [self.delegate SNCommentToolCamraFunction];
        if (result) {
//            [self changedCameraButtonState];
        }
    }
}

- (void)recordButtonPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SNCommentToolRecordFunction)])
    {
        BOOL result = [self.delegate SNCommentToolRecordFunction];
        if (result) {
//            [self changedRecordButtonState];
        }
    }
}

- (void)shareButtonPressed
{
    self.showShare = !self.showShare;
    if (self.delegate && [self.delegate respondsToSelector:@selector(SNCommentToolShareFunction)]) {
        [self.delegate SNCommentToolShareFunction];
    }
    [self setArrowView:self.showShare];
}

- (void)emoticonButtonPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SNCommentToolEmoticonFunction)]) {
        [self.delegate SNCommentToolEmoticonFunction];
//        [self changedEmoticonButtonState];
    }
}

- (void)sendButtonPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SNCommentToolSendFunction)])
    {
        [SNRollingNewsPublicManager sharedInstance].homeRecordTimeClose = YES;
//        [SNRollingNewsPublicManager sharedInstance].refreshClose = YES;
        [self.delegate SNCommentToolSendFunction];
    }
}

#pragma mark - Show / Hide Buttons
- (void)showRecordButton
{
    _recordButton.hidden = NO;
}

- (void)showCameraButton
{
    _cameraButton.hidden = NO;
}

- (void)showKeyboardWithCamButton
{
    _cameraButton.hidden = YES;
}

- (void)setArrowView:(BOOL)show
{
    self.showShare = show;
    _arrowView.centerX = _shareButton.centerX;
    _arrowView.hidden = !show;
    
    _leftArrowView.top = _arrowView.top;
    _leftArrowView.left = 0;
    _leftArrowView.size = CGSizeMake(_arrowView.left, .5f);
    _leftArrowView.hidden = !show;
    
    _rightArrowView.top = _arrowView.top;
    _rightArrowView.left = _arrowView.right;
    _rightArrowView.size = CGSizeMake(kAppScreenWidth - _arrowView.right, .5f);
    _rightArrowView.hidden = !show;
}

#pragma mark - Memory Management
- (void)dealloc
{    
}

@end
