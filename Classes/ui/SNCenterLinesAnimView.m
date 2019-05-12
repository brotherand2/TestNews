//
//  AnimView.m
//  Test
//
//  Created by Xiang Wei Jia on 4/10/15.
//  Copyright (c) 2015 Xiang Wei Jia. All rights reserved.
//

#import "SNCenterLinesAnimView.h"
#import "SNChannelManageContants.h"
#import "SNDynamicPreferences.h"
#import "SNCheckManager.h"
#import "SNTrainCellHelper.h"

#define DegreeToRadius(degree) ((degree)*M_PI/180.0f)

#define CenterTopBottomLineAnimTime 0.2f
#define CenterMidLineAnimTime 0.14f

#define kLineMargin 14
#define kLineWidthHorizon  48.0f
#define kLineWidthRotate   38.0f
#define kLineHeight  6
#define kLineCorner  1

#define kAnimAreaWidth 63
#define kAnimAreaHeight 63

#define kAnimLineLeftMargin 10.5
#define kAnimLineTopMargin 8.5

@interface SNCenterLinesAnimView()

@property (nonatomic,strong) UIView *lineTop;
@property (nonatomic,strong) UIView *lineMid;
@property (nonatomic,strong) UIView *lineBottom;

@property (nonatomic) CGAffineTransform topTransForm;
@property (nonatomic) CGAffineTransform midTransForm;
@property (nonatomic) CGAffineTransform bottomTransForm;

@property (nonatomic, assign) BOOL isUseDynamicSkin;

// 当前的动画状态。
// YES: 当前停留在箭头状态
// NO:  当前停留在三根线状态
@property (nonatomic) BOOL arrowAnim;

@property (nonatomic) CGFloat scale;

@property (nonatomic) NSTimeInterval playTime;

@end

@implementation SNCenterLinesAnimView

@synthesize scale = _scale;

- (instancetype)init {
    self = [super init];
    
    self.frame = CGRectMake(0, 0, 0, 0); // 宽高随便写，反正里面写死了
    [self createAnimLayerAndAddIt];
    _duration = CenterTopBottomLineAnimTime;
    
    self.isUseDynamicSkin = YES;
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    self.frame = CGRectMake(0, 0, 0, 0); // 宽高随便写，反正里面写死了
    [self createAnimLayerAndAddIt];
    _duration = CenterTopBottomLineAnimTime;
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x,
                                           frame.origin.y,
                                           kAnimAreaWidth,
                                           kAnimAreaHeight)];
    
    [self createAnimLayerAndAddIt];
    _duration = CenterTopBottomLineAnimTime;
    
    [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:CGRectMake(frame.origin.x,
                               frame.origin.y,
                               kAnimAreaWidth / self.scale,
                               kAnimAreaHeight / self.scale)];
}

- (CGFloat)scale {
    if (0 == _scale) {
        // iphone 6 plus
        if ([UIScreen mainScreen].bounds.size.height >= 400) {
            _scale = 3;
        }
        else {
            _scale = 2;
        }
    }
    
    return _scale;
}

- (void)createAnimLayerAndAddIt {
    // add by Cae.
    // 哥数学好，这些变形算的出来。都是手算的。
    // 绝对不会告诉你，其实是程序算好了然后复制粘贴过来的。
    _topTransForm.a = 0.55979288248829961;
    _topTransForm.b = -0.55979288248829961;
    _topTransForm.c = 0.70710678118654746;
    _topTransForm.d = 0.70710678118654757;
    _topTransForm.tx = -3.9038188212657516;
    _topTransForm.ty = 6.7322459460119415;
    
    _bottomTransForm.a = 0.55979288248829961;
    _bottomTransForm.b = 0.55979288248829961;
    _bottomTransForm.c = -0.70710678118654746;
    _bottomTransForm.d = 0.70710678118654757;
    _bottomTransForm.tx = 4.314847934129296;
    _bottomTransForm.ty = -6.5540194640824954;
    
    _midTransForm.a = 0.5;
    _midTransForm.b = 0;
    _midTransForm.c = 0;
    _midTransForm.d = 1;
    _midTransForm.tx = 0;
    _midTransForm.ty = 0;
    
    _arrowAnim = NO;
    [_lineTop removeFromSuperview];
    [_lineMid removeFromSuperview];
    [_lineBottom removeFromSuperview];
    
    CGFloat y = kAnimLineTopMargin / self.scale;
    CGFloat margin = (self.frame.size.height - y * 2 - (kLineHeight / self.scale) * 3) / 2;
    NSString *colorString = [[SNDynamicPreferences sharedInstance] getDynmicColor:kThemeBlackColor type:SNTopChannelEditButtonColorType];
    
    _lineTop = [[UIView alloc] initWithFrame:CGRectMake(kAnimLineLeftMargin / self.scale,
                                                        y,
                                                        kLineWidthHorizon / self.scale,
                                                        kLineHeight / self.scale)];
    _lineTop.layer.cornerRadius = kLineCorner;
    _lineTop.layer.position = CGPointMake(_lineTop.layer.position.x - 0.5, _lineTop.layer.position.y);
    _lineTop.backgroundColor = [UIColor colorFromString:colorString];
    [self addSubview:_lineTop];
    
    _lineMid = [[UIView alloc] initWithFrame:CGRectMake(kAnimLineLeftMargin / self.scale,
                                                        _lineTop.frame.origin.y + _lineTop.frame.size.height + margin,
                                                        kLineWidthHorizon / self.scale,
                                                        kLineHeight / self.scale)];
    _lineMid.layer.cornerRadius = kLineCorner;
    _lineMid.layer.position = CGPointMake(_lineMid.layer.position.x - 0.5, _lineMid.layer.position.y);
    _lineMid.backgroundColor = [UIColor colorFromString:colorString];
    [self addSubview:_lineMid];
    
    _lineBottom = [[UIView alloc] initWithFrame:CGRectMake(kAnimLineLeftMargin / self.scale,
                                                           _lineMid.frame.origin.y + _lineMid.frame.size.height + margin,
                                                           kLineWidthHorizon / self.scale,
                                                           kLineHeight / self.scale)];
    _lineBottom.layer.cornerRadius = kLineCorner;
    _lineBottom.layer.position = CGPointMake(_lineBottom.layer.position.x - 0.5, _lineBottom.layer.position.y);
    _lineBottom.backgroundColor = [UIColor colorFromString:colorString];
    [self addSubview:_lineBottom];
    
    if ([SNCheckManager checkDynamicPreferences]) {
        self.backgroundColor = [UIColor clearColor];
    }
    else {
        if (_isFullScreenMode) {
            self.backgroundColor = [UIColor clearColor];
        }else{
            self.backgroundColor = [[SNThemeManager sharedThemeManager] isNightTheme] ? [UIColor colorFromString:@"#1f1f1f"] : [UIColor colorFromString:@"##ffffff"];
        }
    }
    self.alpha = kChannelEditTabBarAlpha;
}

- (void)startAnimating {
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    
    if (now - _playTime < _duration && (now - _playTime)>0) {
        return ;
    }
    
    if (!_isAnimating)  {
        _playTime = now;
        _isAnimating = YES;
     
        if (_arrowAnim) {
            [self playLineAnim];
        }
        else {
            [self playArrowAnim];
        }
        _arrowAnim = !_arrowAnim;
    }
}

- (void)playArrowAnim {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:CenterTopBottomLineAnimTime];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDidStopSelector:@selector(animDidStop)];
        
        _lineTop.transform = _topTransForm;
        
        _lineBottom.transform = _bottomTransForm;
        
        [UIView commitAnimations];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:CenterMidLineAnimTime];
        
        _lineMid.alpha = 0;
        _lineMid.transform = _midTransForm;
        
        [UIView commitAnimations];
    });
}

- (void)playLineAnim {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:CenterTopBottomLineAnimTime];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animDidStop)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        _lineTop.transform = CGAffineTransformIdentity;
        _lineBottom.transform = CGAffineTransformIdentity;
        
        [UIView commitAnimations];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:CenterMidLineAnimTime];
        
        _lineMid.alpha = 1;
        _lineMid.transform = CGAffineTransformIdentity;
        
        [UIView commitAnimations];
    });
}

- (void)animDidStop {
    _isAnimating = NO;
}

- (void)reset:(BOOL)arrow {
    if (arrow) {
        _lineTop.transform = _topTransForm;
        _lineBottom.transform = _bottomTransForm;
        _lineMid.transform = _midTransForm;
        _lineMid.alpha = 0;
    }
    else {
        _lineTop.transform = CGAffineTransformIdentity;
        _lineBottom.transform = CGAffineTransformIdentity;
        _lineMid.transform = CGAffineTransformIdentity;
        _lineMid.alpha = 1;
    }
}

- (void)updateTheme {
    UIColor *color = [self shouldUseColor];
    if (_isFullScreenMode) {//huangzhen 全屏模式下强制求改color
        color = [SNTrainCellHelper newsTitleColor];
        self.backgroundColor = [UIColor clearColor];
    }
    _lineTop.backgroundColor = color;
    _lineMid.backgroundColor = color;
    _lineBottom.backgroundColor = color;
}

- (void)resetLineNormalColor:(BOOL)isNormal {
    if (![SNCheckManager checkDynamicPreferences]) {
        self.isUseDynamicSkin = YES;
        [self updateTheme];
        return;
    }
    self.isUseDynamicSkin = !isNormal;
    UIColor *color = [self shouldUseColor];
    if (_isFullScreenMode) {//huangzhen 全屏模式强制修改颜色
        color = [SNTrainCellHelper newsTitleColor];
        self.backgroundColor = [UIColor clearColor];
    }
    _lineTop.backgroundColor = color;
    _lineMid.backgroundColor = color;
    _lineBottom.backgroundColor = color;
}

- (UIColor *)shouldUseColor {
    BOOL shouldUserSkin = self.isUseDynamicSkin;
    UIColor * color = nil;
    if (shouldUserSkin) {
        NSString *colorString = [[SNDynamicPreferences sharedInstance] getDynmicColor:kThemeBlackColor type:SNTopChannelEditButtonColorType];
        color = [UIColor colorFromString:colorString];
        self.backgroundColor = [UIColor clearColor];
    }
    else {
        color = SNUICOLOR(kThemeBlackColor);
        if (_isFullScreenMode) {
            self.backgroundColor = [UIColor clearColor];
        }else{
            self.backgroundColor = [[SNThemeManager sharedThemeManager] isNightTheme] ? [UIColor colorFromString:@"#1f1f1f"] : [UIColor colorFromString:@"#ffffff"];
        }
    }
    return color;
}

- (void)setIsFullScreenMode:(BOOL)isFullScreenMode {
    _isFullScreenMode = isFullScreenMode;
    [self updateTheme];
}

- (void)setLineColorWithRatio:(CGFloat)ratio {
    //ratio 0~1
    UIColor * color = [SNTrainCellHelper newsTitleColor];
    UIColor * normalColor = [self shouldUseColor];
    UIColor * finalColor = [UIColor mixColor1:normalColor color2:color ratio:ratio];
    _lineTop.backgroundColor = finalColor;
    _lineMid.backgroundColor = finalColor;
    _lineBottom.backgroundColor = finalColor;
    self.backgroundColor = [UIColor clearColor];
    if (ratio == 1) {
        _isFullScreenMode = NO;
    }else{
        _isFullScreenMode = YES;
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end

