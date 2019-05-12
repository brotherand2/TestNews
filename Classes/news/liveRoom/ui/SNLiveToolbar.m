//
//  SNLiveToolbar.m
//  sohunews
//
//  Created by chenhong on 13-6-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveToolbar.h"

#define kShadowHeight 7

@interface SNLiveToolbar () {
    UIImageView *_bgView;
    UIButton *_backBtn;
    UIButton *_inputBarBtn;
    UIButton *_recBarBtn;
    UIButton *_recBtn;
    UIButton *_shareBtn;
    UIButton *_statBtn;
    UILabel  *_placeHolder;
    BOOL _recMode;
    BOOL _bHasStatBtn;
}

@end

@implementation SNLiveToolbar
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)dealloc {
}

- (void)hideAllBtns:(BOOL)bHide {
    if (_recBtn.hidden != bHide) {
        if (_recMode) {
            _recBarBtn.hidden = bHide;
        } else {
            _inputBarBtn.hidden = bHide;
            _placeHolder.hidden = bHide;
        }
        _recBtn.hidden = bHide;
        //_shareBtn.hidden = bHide;
        _statBtn.hidden = bHide;
        
        NSString *bgImgName = bHide ? @"postTab0.png" : (_bHasStatBtn ? @"postTab.png" : @"postTab1.png");
        _bgView.image = [UIImage imageNamed:bgImgName];
    }
}

- (BOOL)isRecMode {
    return _recMode;
}

- (BOOL)hasStatBtn {
    return _bHasStatBtn;
}

- (void)setPlaceholderForWorldCup {
    NSString *placeholder = @"为世界杯加油";
    _inputBarBtn.accessibilityLabel = placeholder;
    _placeHolder.text = placeholder;
}

- (void)setupWithStatBtn:(BOOL)bHasStatBtn recMode:(BOOL)mode {
    _bHasStatBtn = bHasStatBtn;
    _recMode = mode;
    
    // bg
    UIImage *bgImg = [UIImage imageNamed:(_bHasStatBtn ? @"postTab.png" : @"postTab1.png")];
    if (!_bgView) {
        _bgView = [[UIImageView alloc] initWithImage:[bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, bgImg.size.width / 2 - 1, 0, bgImg.size.width / 2 + 1)]];
        _bgView.frame = self.bounds;
        _bgView.userInteractionEnabled = YES;
        [self addSubview:_bgView];
    } else {
        _bgView.image = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(0, bgImg.size.width / 2 - 1, 0, bgImg.size.width / 2 + 1)];
    }

    float top   = 14;
    float left  = 41;
    float barW = _bHasStatBtn ? (kAppScreenWidth - 175) : (kAppScreenWidth - 133);
    
    // 返回按钮
    UIImage *imgNormal = [UIImage imageNamed:@"tb_new_back.png"];
    UIImage *imgPress = [UIImage imageNamed:@"tb_new_back_hl.png"];
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, kShadowHeight, imgNormal.size.width + 10, imgNormal.size.height)];
        _backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        [_backBtn addTarget:self action:@selector(onBackBtn:) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.accessibilityLabel = @"返回";
        [self addSubview:_backBtn];        
    }
    [_backBtn setImage:imgNormal forState:UIControlStateNormal];
    [_backBtn setImage:imgPress forState:UIControlStateHighlighted];
    
    // bar
    imgNormal = [[UIImage themeImageNamed:@"post.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    if (!_inputBarBtn) {
        _inputBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_inputBarBtn addTarget:self action:@selector(onInputBtn:) forControlEvents:UIControlEventTouchUpInside];
        _inputBarBtn.accessibilityLabel = @"我来说两句";
        [self addSubview:_inputBarBtn];
    }
    _inputBarBtn.frame = CGRectMake(left, top, barW, imgNormal.size.height);
    [_inputBarBtn setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [_inputBarBtn setBackgroundImage:imgNormal forState:UIControlStateHighlighted];
    _inputBarBtn.hidden = _recMode;
    
    // placehoder
    if (!_placeHolder) {
        _placeHolder = [[UILabel alloc] init];
        _placeHolder.userInteractionEnabled = NO;
        _placeHolder.font = [UIFont systemFontOfSize:13.0f];
        _placeHolder.backgroundColor = [UIColor clearColor];
        _placeHolder.textAlignment = NSTextAlignmentCenter;
        _placeHolder.textColor = [UIColor grayColor];
        _placeHolder.text = @"我来说两句";
        [_inputBarBtn addSubview:_placeHolder];
    }
    _placeHolder.frame = _inputBarBtn.bounds;
    _placeHolder.top += 1;

    // recBar    
    imgNormal = [[UIImage imageNamed:@"tb_press_speak.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    imgPress = [[UIImage imageNamed:@"tb_press_speak_hl.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    if (!_recBarBtn) {
        _recBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recBarBtn setTitle:@"按住说话" forState:UIControlStateNormal];
        [_recBarBtn setTitle:@"松开结束" forState:UIControlStateHighlighted];
        [_recBarBtn setTitle:@"松开结束" forState:UIControlStateSelected];
        [_recBarBtn setTitleEdgeInsets:UIEdgeInsetsMake(2, _bHasStatBtn?20:10, 0, 0)];
        [_recBarBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_recBarBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _recBarBtn.accessibilityLabel = @"按住说话";
        
        //添加长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recBarBtnLongPressed:)];
        longPress.delegate = self;
        [_recBarBtn addGestureRecognizer:longPress];
        
        [self addSubview:_recBarBtn];
    }
    _recBarBtn.frame = CGRectMake(left-5, kShadowHeight-1, barW+9, imgNormal.size.height);
    [_recBarBtn setBackgroundImage:imgNormal forState:UIControlStateNormal];
    [_recBarBtn setBackgroundImage:imgPress forState:UIControlStateHighlighted];
    [_recBarBtn setBackgroundImage:imgPress forState:UIControlStateSelected];
    [_recBarBtn setImage:[UIImage imageNamed:@"tb_speaker.png"] forState:UIControlStateNormal];
    [_recBarBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _bHasStatBtn?-15:-20, 0, 0)];
    _recBarBtn.hidden = !_inputBarBtn.hidden;
    
    if (_bHasStatBtn) {
        // stat btn
        imgNormal = [UIImage imageNamed:@"live_stat_btn.png"];
        imgPress = [UIImage imageNamed:@"live_stat_btn_press.png"];
        if (!_statBtn) {
            _statBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            _statBtn.accessibilityLabel = @"技术统计";
            [_statBtn addTarget:self action:@selector(onStatBtn:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_statBtn];
        }
        _statBtn.frame = CGRectMake(kAppScreenWidth - 90, kShadowHeight, imgNormal.size.width, imgNormal.size.height); // 460/2
        [_statBtn setImage:imgNormal forState:UIControlStateNormal];
        [_statBtn setImage:imgPress forState:UIControlStateHighlighted];
    } else {
        [_statBtn removeFromSuperview];
         //(_statBtn);
    }
    
    // 录音
    if (_recMode) {
        imgNormal = [UIImage imageNamed:@"tb_keyboard.png"];
        imgPress = [UIImage imageNamed:@"tb_keyboard_hl.png"];
    } else {
        imgNormal = [UIImage imageNamed:@"comment_record_icon.png"];
        imgPress = [UIImage imageNamed:@"comment_record_icon_hl.png"];
    }
    
    if (!_recBtn) {
        _recBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recBtn addTarget:self action:@selector(onRecBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_recBtn];
    }

    _recBtn.accessibilityLabel = _recMode ? @"键盘" : @"录音";
    
    if (_bHasStatBtn) {
        _recBtn.frame = CGRectMake(kAppScreenWidth - 133, kShadowHeight, imgNormal.size.width, imgNormal.size.height); // 374/2
    } else {
        _recBtn.frame = CGRectMake(kAppScreenWidth - 92, kShadowHeight, imgNormal.size.width, imgNormal.size.height); // 456/2
    }
    [_recBtn setImage:imgNormal forState:UIControlStateNormal];
    [_recBtn setImage:imgPress forState:UIControlStateHighlighted];
    
    // 转发
    imgNormal = [UIImage imageNamed:@"icotext_share_v5.png"];
    imgPress = [UIImage imageNamed:@"icotext_sharepress_v5.png"];

    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareBtn.accessibilityLabel = @"分享";
        [_shareBtn addTarget:self action:@selector(onShareBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_shareBtn];
    }
    _shareBtn.frame = CGRectMake(kAppScreenWidth - 38, kShadowHeight, imgNormal.size.width, imgNormal.size.height); // 548/2
    [_shareBtn setImage:imgNormal forState:UIControlStateNormal];
    [_shareBtn setImage:imgPress forState:UIControlStateHighlighted];
}

// event
- (void)onBackBtn:(id)sender {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    if ([delegate respondsToSelector:@selector(liveToolBarBack)]) {
        [delegate liveToolBarBack];
    }
}

- (void)onInputBtn:(id)sender {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    if ([delegate respondsToSelector:@selector(liveToolBarInput)]) {
        [delegate liveToolBarInput];
    }
}

- (void)onRecBtn:(id)sender {
    if (_recMode == NO && [delegate respondsToSelector:@selector(liveToolBarCanRec:)]) {
        if (![delegate liveToolBarCanRec:YES]) {
            return;
        }
    }
    
    if (_recMode == NO) {
        // text -> rec
        _recMode = YES;
        UIImage *imgNormal = [UIImage imageNamed:@"tb_keyboard.png"];
        UIImage *imgPress = [UIImage imageNamed:@"tb_keyboard_hl.png"];
        [_recBtn setImage:imgNormal forState:UIControlStateNormal];
        [_recBtn setImage:imgPress forState:UIControlStateHighlighted];
        _recBtn.accessibilityLabel = @"键盘";

        _recBarBtn.hidden = NO;
        _recBarBtn.enabled = YES;
        _inputBarBtn.hidden = YES;
        _placeHolder.hidden = YES;
        
    } else {
        // rec -> text
        _recMode = NO;
        UIImage *imgNormal = [UIImage imageNamed:@"comment_record_icon.png"];
        UIImage *imgPress = [UIImage imageNamed:@"comment_record_icon_hl.png"];
        [_recBtn setImage:imgNormal forState:UIControlStateNormal];
        [_recBtn setImage:imgPress forState:UIControlStateHighlighted];
        _recBtn.accessibilityLabel = @"录音";
        
        _recBarBtn.hidden = YES;
        _recBarBtn.enabled = YES;
        _inputBarBtn.hidden = NO;
        _placeHolder.hidden = NO;
        
//        [self onInputBtn:nil];
    }
}

- (void)onStatBtn:(id)sender {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    if ([delegate respondsToSelector:@selector(liveToolBarStat)]) {
        [delegate liveToolBarStat];
    }
}

- (void)onShareBtn:(id)sender {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    if ([delegate respondsToSelector:@selector(liveToolBarShare)]) {
        [delegate liveToolBarShare];
    }
}

#pragma mark - 长按录音
- (void)recBarBtnLongPressed:(UILongPressGestureRecognizer*)longPressedRecognizer {
    //长按开始
    if(longPressedRecognizer.state == UIGestureRecognizerStateBegan) {
        if (_recBarBtn == longPressedRecognizer.view) {
            SNDebugLog(@"%@: begin of longP", NSStringFromSelector(_cmd));
            [_recBarBtn setSelected:YES];
            if ([delegate respondsToSelector:@selector(liveToolBarRecBtnLongPressBegin)]) {
                [delegate liveToolBarRecBtnLongPressBegin];
            }
        }
    }//长按结束
    else if(longPressedRecognizer.state == UIGestureRecognizerStateEnded || longPressedRecognizer.state == UIGestureRecognizerStateCancelled) {
        SNDebugLog(@"%@: end of longP", NSStringFromSelector(_cmd));
        [_recBarBtn setSelected:NO];
        if ([delegate respondsToSelector:@selector(liveToolBarRecBtnLongPressEnd)]) {
            [delegate liveToolBarRecBtnLongPressEnd];
        }
    }
}

#pragma mark - 
- (void)updateTheme {
    [self setupWithStatBtn:_bHasStatBtn recMode:_recMode];
    [self setNeedsDisplay];
}

@end
