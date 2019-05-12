//
//  SNChannelView.m
//  sohunews
//
//  Created by jojo on 13-10-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNChannelView.h"
#import "SNUserManager.h"

#define kChannelMarkViewWidth ((kAppScreenWidth > 375.0) ? 42.0/3 : 28.0/2)
#define kChannelMarkViewHeight ((kAppScreenWidth > 375.0) ? 48.0/3 : 32.0/2)
#define kChannelMarkOffsetX ((kAppScreenWidth > 375.0) ? 18 : 10)
#define kChannelMarkOffsetY ((kAppScreenWidth > 375.0) ? 2 : -4)

@interface SNChannelView ()<UIGestureRecognizerDelegate> {
    UILabel *_titleLabel;
    UIImageView *_channelNewMark;
}

@property (nonatomic, assign) CGPoint currentCenter;
@property (nonatomic, assign) CGPoint beginCenter;
@property (nonatomic, strong) UIImageView *channelNewMark;
@property (nonatomic, assign) BOOL isActiveTouch;
@property (nonatomic, assign) BOOL isTouched;
@property (nonatomic, strong) NSTimer *longPressTimer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIImageView *titleLabelBgImageView;
@property (nonatomic, assign) NSTimeInterval lastBeiginTouch;

@end

@implementation SNChannelView
@synthesize currentCenter, beginCenter;
@synthesize titleLabel = _titleLabel;
@synthesize channelNewMark = _channelNewMark;
@synthesize chObj = _chObj;
@synthesize isActiveTouch;
@synthesize isTouched;
@synthesize editMode = _editMode;
@synthesize delegate = _delegate;
@synthesize isSubed;
@synthesize isDull = _isDull;
@synthesize addNew = _addNew;
@synthesize longPressTimer = _longPressTimer;
@synthesize tapGesture = _tapGesture;
@synthesize isSelected = _isSelected;
@synthesize isMoveOut = _isMoveOut;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = SNUICOLOR(kThemeBg4Color);
        self.exclusiveTouch = YES;
        self.editMode = NO;
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionDullViewTapped:)];
        self.tapGesture.delegate = self;
        [self addGestureRecognizer:self.tapGesture];
        self.tapGesture.enabled = NO;
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)showShadow:(BOOL) isShow
{
    //不可排序无阴影
    if ([_chObj.channelTop isEqualToString:kHomePageChannelTop]) {
        isShow = NO;
    }
    
    if (isShow) {
        self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.4].CGColor;
        self.layer.shadowOffset = CGSizeMake(1, 3);
        self.layer.shadowOpacity = 0.7;
        self.layer.shadowRadius = 1.0;
    } else {
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 0.0;
    }
    
    _titleLabel.top = isShow ? -3 : 0;
}

- (void)dealloc {
    self.delegate = nil;
    [SNNotificationManager removeObserver:self];
    
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kChannelTitleWidth, kChannelTitleHeight)];
        _titleLabel.backgroundColor = SNUICOLOR(kThemeBg4Color);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.center = self.center;
        _titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        _titleLabel.textColor = SNUICOLOR(kThemeText1Color);
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIImageView *)channelNewMark {
    if (!_channelNewMark) {
        CGFloat centerX = CGRectGetMidX(self.bounds);
        CGFloat centerY = CGRectGetMidY(self.bounds);
        
        _channelNewMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icohome_dot_v5.png"]];
        
        _channelNewMark.frame = CGRectMake(centerX + kChannelViewWidth / 2 - 10,
                                           centerY - kChannelViewHeight / 2 + 2,
                                           _channelNewMark.image.size.width,
                                           _channelNewMark.image.size.height);
        _channelNewMark.backgroundColor = [UIColor clearColor];
        _channelNewMark.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _channelNewMark.hidden = YES;
        [self addSubview:_channelNewMark];
    }
    return _channelNewMark;
}

- (void)setChObj:(SNChannelManageObject *)chObj {
    _chObj = chObj;
    if ([_chObj.ID isEqualToString:@"1"]) {
        if ([_chObj.name isEqualToString:@"首页"]) {
            _chObj.name = @"要闻";
        }
    }
    if ([_chObj.channelTop isEqualToString:kHomePageChannelTop]) {
        self.isDull = YES;
    }
    if ([_chObj.name convertStringToLength] > 9) {
        self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    }
    else if ([_chObj.name convertStringToLength] > 8 && kAppScreenWidth == 320.0) {
        self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    }
    
    self.addNew = _chObj.addNew;
    self.isSubed = [_chObj.isSubed isEqualToString:@"1"];
    self.titleLabel.text = _chObj.name;
    if ([_chObj.channelIconFlag isEqualToString:@"1"]) {
        self.titleMarkImageView.image = [UIImage imageNamed:@"iconormalsetting_tagnew_v5.png"];
        self.titleMarkImageView.hidden = NO;
    }
    else if ([_chObj.channelIconFlag isEqualToString:@"2"]) {
        self.titleMarkImageView.image = [UIImage imageNamed:@"iconormalsetting_taghot_v5.png"];
        self.titleMarkImageView.hidden = NO;
    }
    else {
        self.titleMarkImageView.image = nil;
        self.titleMarkImageView.hidden = YES;
    }
}

- (void)setAddNew:(BOOL)addNew {
    _addNew = addNew;
    
    if (_addNew) {
        self.channelNewMark.hidden = NO;
        self.chObj.addNew = NO;
    } else {
        self.channelNewMark.hidden = YES;
    }
}

- (void)setEditMode:(BOOL)editMode {
    _editMode = editMode;
    self.titleLabelBgImageView.alpha = 0;
    self.titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    
    if (self.isSelected) {
        _titleLabel.textColor = SNUICOLOR(kThemeRed1Color);
    }
    if ([_chObj.channelTop isEqualToString:kHomePageChannelTop]) {
        if (!self.isSelected) {
            _titleLabel.textColor = SNUICOLOR(kThemeText4Color);
        }
    }
}

- (void)setIsDull:(BOOL)isDull {
    _isDull = isDull;
    self.tapGesture.enabled = _isDull;
}

- (void)setIsSelected:(BOOL)isSelected {
    _isSelected = isSelected;
    self.editMode = self.isEditMode;
}

- (BOOL)isExpanding{
    if (_titleLabelBgImageView.alpha == 1.0) {
        return YES;
    }else{
        return NO;
    }
}

- (void)showExpanding:(BOOL)show {
    if (!show) {
        self.transform = CGAffineTransformIdentity;
        _titleLabelBgImageView.alpha = 0;
        if (self.delegate && [self.delegate respondsToSelector:@selector(channelViewDidExpading:)]) {
            [self.delegate channelViewDidExpading:self];
        }
        return;
    }
    
    [UIView animateWithDuration:kSNChannelManageViewMovingAnimationDuration animations:^{
        if (show) {
            self.transform = CGAffineTransformMakeScale(kChannelViewExpandingScale, kChannelViewExpandingScale);
            _titleLabelBgImageView.alpha = 1.0;
        }
        else {
            self.transform = CGAffineTransformIdentity;
            _titleLabelBgImageView.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(channelViewDidExpading:)]) {
            [self.delegate channelViewDidExpading:self];
        }
    }];
}

- (void)moveToMoreChannelAnimationWithCenter:(CGPoint) center
{
    [UIView animateWithDuration:kSNChannelViewMovingToSwitchAnimationDuration animations:^{
        self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        self.alpha = 0.0f;
        self.center = center;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)showEditMode:(BOOL)show {
    if (!self.isDull) {
        if ([_chObj.name convertStringToLength] > 10) {
            if (kAppScreenWidth == 320.0) {
                _titleLabel.width = kChannelTitleWidth;
            }
            else if (kAppScreenWidth == 375.0) {
                _titleLabel.width = kChannelTitleWidth - 10.0;
            }
            else {
                _titleLabel.width = kChannelTitleWidth - 20.0;
            }
        }
        else {
            _titleLabel.width = kChannelTitleWidth;
        }
        _titleLabel.centerX = self.width/2;
    }
}

#pragma mark - touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    if (self.isEditMode) {
        if ([self isExpanding]) {
            [self showExpanding:NO];
        }
    }
    if (self.isDull) {
        return;
    }
    
    if (CFAbsoluteTimeGetCurrent() - self.lastBeiginTouch > 0 && CFAbsoluteTimeGetCurrent() - self.lastBeiginTouch < 3.0) {
        self.isMoveOut = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(resetChannelMoveOut)]) {
            [self.delegate resetChannelMoveOut];
        }
    }
    self.lastBeiginTouch = CFAbsoluteTimeGetCurrent();
    
    self.currentCenter = self.center;
    UITouch *aTouch = [touches anyObject];
    self.beginCenter = [aTouch locationInView:self.superview];
    self.isTouched = YES;
    
    CGFloat delayTime = 0;
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        delayTime = kSNChannelViewActiveTimeInterval;
    }
    else {
        delayTime = 0.0008;
    }
    [self performSelector:@selector(activeLongPress:) withObject:nil afterDelay:delayTime];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.isDull) {
        return;
    }
    
    if (self.isActiveTouch) {
        UITouch *aTouch = [touches anyObject];
        CGPoint movingPt = [aTouch locationInView:self.superview];
        CGFloat dX = movingPt.x - self.beginCenter.x;
        CGFloat dY = movingPt.y - self.beginCenter.y;
        
        BOOL isRealMove = NO;
        if (ABS(dX) > self.width/2 || ABS(dY) > self.height/2) {
            self.isMoveOut = YES;
            isRealMove = YES;
        }
        
        CGPoint newCenter = CGPointMake(self.currentCenter.x + dX, self.currentCenter.y + dY);
        self.center = newCenter;
        
        if (self.delegate) {
            NSString * platformString = [SNUtility platformStringForSohuNews];
            if ([platformString isEqualToString:IPHONE_6SPLUS_NAMESTRING] || [platformString isEqualToString:IPHONE_6S_NAMESTRING]) {
                if (isRealMove) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate channelViewDidMoved:self];
                    });
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate channelViewDidMoved:self];
                });
            }
        }
    }
    else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(activeLongPress:) object:nil];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if (self.isDull) {
        [SNNewsReport reportADotGif:@"_act=pullchannel2fix&_tp=pv"];
        return;
    }
    
    self.isTouched = NO;
    
    [self handleTouchEnded:[touches anyObject]];
    
    self.currentCenter = CGPointZero;
    self.beginCenter = CGPointZero;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.isDull) {
        return;
    }
    UITouch *aTouch = [touches anyObject];
    CGPoint pt = [aTouch locationInView:self];
    self.isTouched = CGRectContainsPoint(self.bounds, pt);
    [self handleTouchEnded:aTouch];
    
    self.currentCenter = CGPointZero;
    self.beginCenter = CGPointZero;
}

#pragma mark - actions

- (void)handleTouchEnded:(UITouch *)aTouch {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(activeLongPress:) object:nil];
    
    if (self.isActiveTouch) {
        if (self.delegate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate channelViewDidEndMove:self];
            });
        }
    }
    else if (self.isTouched) {
        [self actionViewTapped:nil];
    }
    
    self.isActiveTouch = NO;
    self.isTouched = NO;
}

- (void)handleLongPress:(id)sender {
    if (self.delegate) {
        self.isActiveTouch = [self.delegate channelViewShouldActiveEditModeAfterLongPressed:self];
        [self showExpanding:YES];
        if (self.isActiveTouch) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate channelViewDidStartMove:self];
            });
        }
    }
}

- (void)activeLongPress:(id)sender {
    if (self.isEditMode) {
        [self showExpanding:YES];
    }
    if (self.delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate channelViewDidStartMove:self];
        });
    }
    self.isActiveTouch = YES;
    self.isMoveOut = NO;
}

- (void)actionViewTapped:(id)sender {
    if (self.delegate && !self.isActiveTouch) {
        // 强制置顶的频道 编辑状态下 点击无效
        if (self.isEditMode && self.isDull) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
           [self.delegate channelViewDidTapped:self];
        });
    }
}

- (void)actionDullViewTapped:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.delegate channelViewDidTapped:self];
    });
}

- (void)actionDelete:(id)sender {
    if (self.delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate channelViewDidSelectDelete:self];
        });
    }
}

- (UIImageView *)titleLabelBgImageView {
    if (!_titleLabelBgImageView) {
        _titleLabelBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kChannelTitleBackgroundOriginX, kChannelTitleBackgroundOriginY, kChannelTitleBackgroundWidth, kChannelTitleBackgroundHeight)];
        _titleLabelBgImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabelBgImageView];
    }
    return _titleLabelBgImageView;
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]
        && [touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (UIImageView *)titleMarkImageView {
    if (!_titleMarkImageView) {
        _titleMarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kChannelMarkViewWidth, kChannelMarkViewHeight)];
        _titleMarkImageView.center = CGPointMake(self.width - _titleMarkImageView.width / 2, 0);
        [self addSubview:_titleMarkImageView];
    }
    return _titleMarkImageView;
}

- (void)updateTheme {
    self.backgroundColor = SNUICOLOR(kThemeBg4Color);
    _titleLabel.backgroundColor = SNUICOLOR(kThemeBg4Color);
     _titleLabel.textColor = SNUICOLOR(kThemeText1Color);
    if (self.isSelected) {
        _titleLabel.textColor = SNUICOLOR(kThemeRed1Color);
    }
    
    if ([_chObj.channelTop isEqualToString:kHomePageChannelTop]) {
        if (!self.isSelected) {
            _titleLabel.textColor = SNUICOLOR(kThemeText4Color);
        }
    }
    
    _channelNewMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icohome_dot_v5.png"]];
    if ([_chObj.channelIconFlag isEqualToString:@"1"]) {
        self.titleMarkImageView.image = [UIImage imageNamed:@"iconormalsetting_tagnew_v5.png"];
    }
    else if ([_chObj.channelIconFlag isEqualToString:@"2"]) {
        self.titleMarkImageView.image = [UIImage imageNamed:@"iconormalsetting_taghot_v5.png"];
    }
}

@end
