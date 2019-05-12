//
//  SNQRView.m
//  HZQRCodeDemo
//
//  Created by H on 15/11/4.
//  Copyright © 2015年 Hz. All rights reserved.
//
#define kFuncMenuHeight         (122/2.f)

#import "SNQRView.h"

static NSTimeInterval kQrLineanimateDuration = 0.005;

@interface SNQRView ()<SNQRFuncMenuDelegate>

@property (nonatomic, assign) QRFuncType funcType;

@end

@implementation SNQRView
{
    UIImageView *_qrLine;
    CGFloat _qrLineY;
    SNQRMenu *_qrMenu;
    UIView *_maskView;
    UILabel * _tipLabel;
    SNQRFuncMenu * _funcMenu;
    BOOL _scanEnable;
}

- (instancetype)initWithFrame:(CGRect)frame scanType:(QRFuncType)type{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setTransparentAreaWithFuncType:type];
        _funcType = type;
        self.enable = YES;
//        UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToSwitchFunc:)];
//        [self addGestureRecognizer:swipe];
    }
    return self;
}

- (void)swipeToSwitchFunc:(UISwipeGestureRecognizer *)getsture {
    [_funcMenu setScanType:self.funcType];
    switch (getsture.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
        {
            if (self.funcType == QRFuncTypeScanQrCode) {
                return;
            }
            [self switchScanMode:QRFuncTypeScanQrCode];
            break;
        }
        case UISwipeGestureRecognizerDirectionRight:
        {
            if (self.funcType == QRFuncTypeScanImage) {
                return;
            }
            [self switchScanMode:QRFuncTypeScanImage];
            break;
        }
        default:
            break;
    }
}

- (void)setTransparentAreaWithFuncType:(QRFuncType)funcType{

    switch (funcType) {
        case QRFuncTypeScanQrCode:
        {
            CGFloat length = 0.0;
            if ([self is6Plus]) {
                length = 864.0/3.f;
            }else {
                length = 500.0/2.f;
            }
            self.transparentArea = CGSizeMake(length, length);
            _tipLabel.text = @"将二维码放入框内，即可自动扫描";

            break;
        }
        case QRFuncTypeScanImage:
        {
//            414x736
            /* 由于服务端要求方形图片，所以选取框调整为和二维码一样，于是注释掉了原逻辑
            CGFloat widthScale = 626/2.f/414.f;
            CGFloat heightScale = 898/2.f/736.f;
            CGFloat width = widthScale * kAppScreenWidth;
            CGFloat height = heightScale * kAppScreenHeight;
            if ([self isIphone4]) {
                width = 250;
                height = 250;
            }
            self.transparentArea = CGSizeMake(width, height);
            */
            
            CGFloat length = 0.0;
            if ([self is6Plus]) {
                length = 864.0/3.f;
            }else {
                length = 500.0/2.f;
            }
            self.transparentArea = CGSizeMake(length, length);

            _tipLabel.text = @"将logo、海报放入框内，即可自动扫描";
            break;
        }
        default:
            break;
    }

}

- (BOOL)is6Plus{
    return ([UIScreen mainScreen].bounds.size.width > 750/2.f);
}

- (BOOL)isIphone6{
    return [UIScreen mainScreen].bounds.size.width == 750/2.f ;
}

- (BOOL)isiphone5{
    return ([UIScreen mainScreen].bounds.size.width == 320 )&&([UIScreen mainScreen].bounds.size.height == 568) ;
}

- (BOOL)isIphone4{
    return ([UIScreen mainScreen].bounds.size.width == 320 )&&([UIScreen mainScreen].bounds.size.height == 480) ;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    if (!_qrLine) {
        
        [self initQRLine];
        
       NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:kQrLineanimateDuration target:self selector:@selector(show) userInfo:nil repeats:YES];
        [timer fire];    }
    
    if (!_qrMenu) {
        [self initQrMenu];
    }
    [self initTipLabel];
    [self initFuncMenu];
}

- (void)initFuncMenu{
    if (!_funcMenu) {
        _funcMenu = [[SNQRFuncMenu alloc] initWithFrame:CGRectMake(0, 0, self.width, kFuncMenuHeight) funcType:_funcType];
    }
    _funcMenu.scanModeDelegate = self;
    _funcMenu.bottom = kAppScreenHeight - 44;
    [self addSubview:_funcMenu];
}

- (void)switchScanMode:(QRFuncType)scanType {
    
    self.funcType = scanType;
    //切换功能
    if (self.delegate && [self.delegate respondsToSelector:@selector(switchScanFunctionMode:)]) {
        [self.delegate switchScanFunctionMode:scanType];
    }
    
    //切换UI
    [self setTransparentAreaWithFuncType:scanType];
    [UIView animateWithDuration:0.1 animations:^{
        //tipLabel
        CGFloat space = [self tipLabelSpace];
        CGSize screenSize =[SNQRUtility screenBounds].size;
        CGRect screenDrawRect =CGRectMake(0, 0, screenSize.width,screenSize.height);
        _tipLabel.frame = CGRectMake(0,(screenDrawRect.size.height)/ 2 - self.transparentArea.height / 2 - kToolbarHeight +  space + self.transparentArea.height - 10, self.width, 30);
        
        //扫描框
        [self setNeedsDisplay];
        
    } completion:^(BOOL finished) {
        
    }];

}

- (void)beginScanAnimation{
    [_qrLine setHidden:NO];
    
}

- (void)stopScanAnimation{
    [_qrLine setHidden:YES];
}

- (CGFloat)tipLabelSpace {
    if ([self is6Plus]) {
        return 60/3.f;
    }
    return 34/2.f;
}

- (CGFloat)tipLabelFont {
    if ([self is6Plus]) {
        return kThemeFontSizeE;
    }
    return kThemeFontSizeD;
}

- (CGFloat)cornerLength{
    if ([self is6Plus]) {
        return 60/3.f;
    }
    return 40/2.f;
}

- (UIColor *)textColor{
    return SNUICOLOR(kThemeText5Color);
}

- (void)initTipLabel {
    CGFloat space = [self tipLabelSpace];
    CGSize screenSize =[SNQRUtility screenBounds].size;
    CGRect screenDrawRect =CGRectMake(0, 0, screenSize.width,screenSize.height);
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,(screenDrawRect.size.height)/ 2 - self.transparentArea.height / 2 - kToolbarHeight +  space + self.transparentArea.height - 10, self.width, 30)];
    }
//    _tipLabel.text = @"将二维码放入框内，即可自动扫描";
    _tipLabel.font = [UIFont systemFontOfSize:30/2.f];
    _tipLabel.textColor = [self textColor];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    switch (_funcType) {
        case QRFuncTypeScanQrCode:
        {
             _tipLabel.text = @"将二维码放入框内，即可自动扫描";
            break;
        }
        case QRFuncTypeScanImage:
        {
            _tipLabel.text = @"将logo、海报放入框内，即可自动扫描";
            break;
        }
        default:
        break;
    }
    [self addSubview:_tipLabel];
    if (!_scanEnable) {
        _tipLabel.textColor = [UIColor grayColor];
    }
}

- (void)initQRLine {
    
    
    CGRect screenBounds = [SNQRUtility screenBounds];
    CGSize screenSize =[SNQRUtility screenBounds].size;
    CGRect screenDrawRect =CGRectMake(0, 0, screenSize.width,screenSize.height);
    _qrLine  = [[UIImageView alloc] initWithFrame:CGRectMake(screenBounds.size.width / 2 - self.transparentArea.width / 2,
                                                             (screenDrawRect.size.height)/ 2 - self.transparentArea.height / 2 - kToolbarHeight,
                                                             self.transparentArea.width * 0.8f,
                                                             1)];
//    _qrLine.image = [UIImage imageNamed:@"qr_scan_line"];
//    _qrLine.backgroundColor = [UIColor colorWithRed:83/255.0 green:239/255.0 blue:111/255.0 alpha:0.5];
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    if (isNightTheme) {
        _qrLine.backgroundColor = [UIColor colorWithRed:0.44f green:0.16f blue:0.16f alpha:1.00f];
    }else{
        _qrLine.backgroundColor = [UIColor colorWithRed:0.95f green:0.17f blue:0.00f alpha:1.00f];

    }
    
    _qrLine.centerX = self.centerX;
    _qrLine.contentMode = UIViewContentModeScaleAspectFill;
    _qrLine.hidden = !_scanEnable;
    [self addSubview:_qrLine];
    _qrLineY = _qrLine.frame.origin.y;
}

- (CGFloat)qrMenuBottom{
    if ([self is6Plus]) {
        return 430/3.f;
    }else if ([self isIphone6]){
        return 300/2.f;
    }else if([self isiphone5]){
        return 200/2.f;
    }else if ([self isIphone4]){
        return 120/2.f;
    }
    return kToolbarHeight;
}

- (void)initQrMenu {
    
    CGFloat height = 50;
//    CGFloat width = [SNQRUtility screenBounds].size.width;
    if (!_qrMenu) {
        _qrMenu = [[SNQRMenu alloc] initWithFrame:CGRectMake(0, 22 , ([self is6Plus] ? 144/3.f : 96/2.f)*2+60, height)];
    }
    _qrMenu.backgroundColor = [UIColor clearColor];
//    _qrMenu.alpha = 0.5;
    _qrMenu.centerX = self.centerX;
    _qrMenu.userInteractionEnabled = _scanEnable;
    [self addSubview:_qrMenu];
    
    self.ligthButton = _qrMenu.lightBtn;
    
    __block typeof(self)weakSelf = self;
    
    _qrMenu.didSelectedBlock = ^(SNQRItem *item){
                
        if ([weakSelf.delegate respondsToSelector:@selector(scanTypeConfig:)] ) {
            
            [weakSelf.delegate scanTypeConfig:item];
        }
    };
    if (!_scanEnable && _maskView) {
        [self bringSubviewToFront:_maskView];
    }
}

- (void)show {
    
    CGSize screenSize =[SNQRUtility screenBounds].size;

    [UIView animateWithDuration:kQrLineanimateDuration animations:^{
        
        CGRect rect = _qrLine.frame;
        rect.origin.y = _qrLineY;
        _qrLine.frame = rect;
        
    } completion:^(BOOL finished) {
        
        CGFloat maxBorder = (screenSize.height)/ 2 - self.transparentArea.height / 2 - kToolbarHeight + self.transparentArea.height - 4;
        if (_qrLineY > maxBorder) {
            
            _qrLineY = (screenSize.height)/ 2 - self.transparentArea.height / 2 - kToolbarHeight;
        }
        _qrLineY++;
    }];
}

- (void)drawRect:(CGRect)rect {
    
    //整个二维码扫描界面的颜色
    CGSize screenSize =[SNQRUtility screenBounds].size;
    CGRect screenDrawRect =CGRectMake(0, 0, screenSize.width,screenSize.height);
    
    //中间清空的矩形框
    CGRect clearDrawRect = CGRectMake(screenDrawRect.size.width / 2 - self.transparentArea.width / 2,
                                      (screenDrawRect.size.height )/ 2 - self.transparentArea.height / 2 - kToolbarHeight,
                                      self.transparentArea.width,self.transparentArea.height);
    self.translateAreaRect = clearDrawRect;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [self addScreenFillRect:ctx rect:screenDrawRect];
    
    [self addCenterClearRect:ctx rect:clearDrawRect];
    
    [self addWhiteRect:ctx rect:clearDrawRect];
    
    [self addCornerLineWithContext:ctx rect:clearDrawRect];
    
}

- (void)addCornerWithRect:(CGRect)rect {
    
}

- (void)addScreenFillRect:(CGContextRef)ctx rect:(CGRect)rect {
    CGContextSetRGBFillColor(ctx, 0 / 255.0,0 / 255.0,0 / 255.0,0.5);
    CGContextFillRect(ctx, rect);   //draw the transparent layer
}

- (void)addCenterClearRect :(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextClearRect(ctx, rect);  //clear the center rect  of the layer
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    
//    CGContextStrokeRect(ctx, rect);
//    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
//    CGContextSetLineWidth(ctx, 0.8);
//    CGContextAddRect(ctx, rect);
//    CGContextStrokePath(ctx);
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect{
    
    CGFloat cornerLength = [self cornerLength];
//    [UIColor colorWithRed:0.95f green:0.17f blue:0.00f alpha:1.00f];
    //[UIColor colorWithRed:0.44f green:0.16f blue:0.16f alpha:1.00f];
    BOOL isNightTheme = [[SNThemeManager sharedThemeManager] isNightTheme];
    
    //画四个边角
    CGContextSetLineWidth(ctx, 2);
    
    if (isNightTheme) {
        CGContextSetRGBStrokeColor(ctx, 0.44f, 0.16f, 0.16f, 1.00f);
    }else{
        CGContextSetRGBStrokeColor(ctx, 0.95f, 0.17f, 0.00f, 1.00f);
    }
    
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x+0.7, rect.origin.y),
        CGPointMake(rect.origin.x+0.7 , rect.origin.y + cornerLength)
    };
    
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y +0.7),CGPointMake(rect.origin.x + cornerLength, rect.origin.y+0.7)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x+ 0.7, rect.origin.y + rect.size.height - cornerLength),CGPointMake(rect.origin.x +0.7,rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x , rect.origin.y + rect.size.height - 0.7) ,CGPointMake(rect.origin.x+0.7 + cornerLength, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - cornerLength, rect.origin.y+0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y +0.7 )};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width-0.7, rect.origin.y),CGPointMake(rect.origin.x + rect.size.width-0.7,rect.origin.y + cornerLength +0.7 )};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width -0.7 , rect.origin.y+rect.size.height+ - cornerLength),CGPointMake(rect.origin.x-0.7 + rect.size.width,rect.origin.y +rect.size.height )};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - cornerLength , rect.origin.y + rect.size.height-0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height - 0.7 )};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

- (void)setScanEnable:(BOOL)enable errorType:(QRDisableType)errorType{
    _scanEnable = enable;
    self.enable = enable;
    if (enable) {
        _qrMenu.userInteractionEnabled = YES;
        _funcMenu.userInteractionEnabled = YES;
        [self beginScanAnimation];
        _tipLabel.textColor = [self textColor];
        [_maskView removeFromSuperview];
        _maskView = nil;
    }
    
    else {
        if (!_maskView) {
            CGSize screenSize =[SNQRUtility screenBounds].size;
            _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
            _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
            UILabel * msgLabel = [[UILabel alloc] initWithFrame: CGRectMake(_maskView.size.width / 2 - self.transparentArea.width / 2,
                                                                            (_maskView.size.height )/ 2 - self.transparentArea.height / 2 - kToolbarHeight,
                                                                            self.transparentArea.width,self.transparentArea.height)];
            msgLabel.font = [UIFont systemFontOfSize:[self tipLabelFont]];
            msgLabel.textColor = [self textColor];
            msgLabel.textAlignment = NSTextAlignmentCenter;
            [_maskView addSubview:msgLabel];

            if (errorType == QRDisableType_NoNetwork) {
                msgLabel.text = @"当前网络不可用\n请检查网络设置";
                msgLabel.numberOfLines = 2;
            }else if (errorType == QRDisableType_NoResult){
                msgLabel.text = @"未能识别";
                
                UILabel * tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.transparentArea.width, 30)];
                tipLabel.left = msgLabel.left;
                tipLabel.top = msgLabel.top + msgLabel.height/2.f + 4;
                tipLabel.text = @"轻触屏幕继续扫描";
                tipLabel.textAlignment = NSTextAlignmentCenter;
                tipLabel.font = [UIFont systemFontOfSize:[self is6Plus] ? kThemeFontSizeD : kThemeFontSizeE];
                tipLabel.textColor = [self textColor];
                [_maskView addSubview:tipLabel];
            }
            
            [self addSubview:_maskView];

        }
        [self stopScanAnimation];
        _tipLabel.textColor = [UIColor grayColor];
        _qrMenu.userInteractionEnabled = NO;
        _funcMenu.userInteractionEnabled = NO;
    }
}

@end
