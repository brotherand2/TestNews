//
//  SNPopoverView.m
//  sohunews
//
//  Created by wangyy on 15/11/26.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNPopoverView.h"
#import "UIFont+Theme.h"

#define kArrowHeight 15.f
#define SPACE 2.f


@interface SNPopoverView ()

@property (nonatomic) CGPoint showPoint;
@property (nonatomic) CGSize showSize;
@property (nonatomic) BOOL isDown;
@property (nonatomic, strong) UIImageView *popoverImage;
@property (nonatomic, strong) UILabel *titleTip;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) NSTimer *hideTimer;
@property (nonatomic, strong) UIImageView *middleView;
@property (nonatomic, strong) UIImageView *leftView;
@property (nonatomic, strong) UIImageView *rightView;
@property (nonatomic, strong) NSString *leftImageName;
@end

@implementation SNPopoverView

@synthesize popoverImage = _popoverImage;
@synthesize titleTip = _titleTip;
@synthesize closeBtn = _closeBtn;
@synthesize hideTimer = _hideTimer;
@synthesize endInterval = _endInterval;
@synthesize middleView = _middleView;
@synthesize leftView = _leftView;
@synthesize rightView = _rightView;


- (void)dealloc {
    [self.hideTimer invalidate];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithPoint:(CGPoint)point size:(CGSize)size {
    self = [super init];
    if (self) {
        self.showPoint = point;
        self.showSize = size;
        self.frame = [self getViewFrame];
    }
    
    return self;
}

- (id)initWithTitle:(NSString *)title Point:(CGPoint)point size:(CGSize)size leftImageName:(NSString *)leftImageName {
    self = [super init];
    if (self) {
        self.showPoint = point;
        self.showSize = size;
        self.frame = [self getViewFrame];
        
        [self initPopoverBackgroundView];
        
        if (title != nil && title.length != 0) {
            [self initTitle:title leftImageName:leftImageName];
        }
    }
    
    return self;
}

- (id)initWithDownTitle:(NSString *)title Point:(CGPoint)point size:(CGSize)size leftImageName:(NSString *)leftImageName {
    self = [super init];
    if (self) {
        self.isDown = YES;
        self.showPoint = point;
        self.showSize = size;
        self.frame = [self getViewFrame];
        
        [self initPopoverBackgroundView];
        
        if (title != nil && title.length != 0) {
            [self initTitle:title leftImageName:leftImageName];
        }
    }
    
    return self;
}

- (void)initPopoverBackgroundView {
    self.leftView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.leftView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.leftView];
    
    self.middleView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.middleView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.middleView];
    
    self.rightView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.rightView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.rightView];
}

- (void)initTitle:(NSString *)title leftImageName:(NSString *)leftImageName {
    CGFloat yValue = 16;
    if ([SNDevice sharedInstance].isPlus) {
        yValue = 52/3;
    }
    self.leftImageName = leftImageName;
    UIImage *image = [UIImage themeImageNamed:leftImageName];
    self.popoverImage = [[UIImageView alloc] initWithFrame:CGRectMake(13, yValue, image.size.width, image.size.height)];
    [self.popoverImage setImage:image];
    [self addSubview:self.popoverImage];
    
    int offsetX = 7;
    yValue = 20;
    if ([SNDevice sharedInstance].isPlus) {
        offsetX = 13;
        yValue = 65/3;
    }
    self.titleTip = [[UILabel alloc] initWithFrame:CGRectMake(self.popoverImage.right + offsetX, yValue, self.showSize.width - 10, 20)];
    self.titleTip.backgroundColor = [UIColor clearColor];
    self.titleTip.text = title;
    self.titleTip.textColor = SNUICOLOR(kThemeText6Color);
    self.titleTip.font = [UIFont systemFontOfSizeType:UIFontSizeTypeD];
    [self addSubview:self.titleTip];
    
    offsetX = 14;
    yValue = 43/2;
    if ([SNDevice sharedInstance].isPlus) {
        offsetX = 22 -8;
        yValue = 65/3;
    }
    image = [UIImage themeImageNamed:@"pop_ico_close_v5.png"];
    self.closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.showSize.width - offsetX - image.size.width, yValue, image.size.width, image.size.height)];
    self.closeBtn.backgroundColor = [UIColor clearColor];
    [self.closeBtn setImage:image forState:UIControlStateNormal];
    [self.closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeBtn];
    if (self.isDown == YES) {
        self.closeBtn.hidden = YES;
    }
}

- (void)setEndInterval:(float)endInterval {
    if (endInterval == 0.0f) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
    }
    _endInterval = endInterval;
    //重置显示时长timer
    if (self.hideTimer && [self.hideTimer isValid]) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
        self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:_endInterval
                                                          target:self
                                                        selector:@selector(dismiss)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}

-(CGRect)getViewFrame {
    CGRect frame = CGRectZero;
    frame.size.height = SPACE + kArrowHeight + self.showSize.height;
    frame.size.width = self.showSize.width;

    frame.origin.x = self.showPoint.x - frame.size.width/2;
    frame.origin.y = self.showPoint.y + SPACE;
    
    //左间隔最小5x
    if (frame.origin.x < 5) {
        frame.origin.x = 5;
    }
    //右间隔最小5x
    if ((frame.origin.x + frame.size.width) > kAppScreenWidth - 5) {
        frame.origin.x = kAppScreenWidth - 5 - frame.size.width;
    }
    
    return frame;
}

- (void)drawMiddleViewInView:(UIView *)view {
   
    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:view];
    
    UIImage *middleImage = [UIImage themeImageNamed:@"2_background_v6.png"];
    
    CGRect frame = CGRectZero;
    frame.size = middleImage.size;
    
    frame.origin.x = arrowPoint.x - middleImage.size.width/2;
    frame.origin.y = 0;
    
    if (self.isDown == YES) {
        frame.origin.y = 7;
        CGAffineTransform transform = CGAffineTransformMakeRotation(180 * M_PI/180.0);
        [self.middleView setTransform:transform];
    }
    
    self.middleView.frame = frame;
    [self.middleView setImage:middleImage];

}

- (void)drawLeftView {
    UIImage *leftImage = [UIImage themeImageNamed:@"1_background_v6.png"];
    leftImage = [leftImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    
    CGRect frame = CGRectZero;
    
    frame.size.height = leftImage.size.height;
    frame.size.width = self.middleView.origin.x;
    
    frame.origin.x = 0;
    frame.origin.y = 7;
    
    self.leftView.frame = frame;
    [self.leftView setImage:leftImage];
}

- (void)drawRightView {
    UIImage *rightImage = [UIImage themeImageNamed:@"3_background_v6.png"];
    rightImage = [rightImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 5, 10, 5) resizingMode:UIImageResizingModeStretch];
    
    CGRect frame = CGRectZero;
    
    frame.size.height = rightImage.size.height;
    frame.size.width = self.size.width - self.middleView.width - self.leftView.width;
    
    frame.origin.x = self.middleView.right;
    frame.origin.y = 7;
    
    self.rightView.frame = frame;
    [self.rightView setImage:rightImage];
}

- (void)drawPopoverBackgroundViewInView:(UIView *)view {
    [self drawMiddleViewInView:view];
    [self drawLeftView];
    [self drawRightView];
}

-(void)show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self showView:window];
}

- (void)showView:(UIView *)view {
    [view addSubview:self];
    
    [self drawPopoverBackgroundViewInView:view];
    
    CGPoint arrowPoint = [self convertPoint:self.showPoint fromView:view];
    self.layer.anchorPoint = CGPointMake(arrowPoint.x / self.frame.size.width, arrowPoint.y / self.frame.size.height);
    self.frame = [self getViewFrame];
    
    self.alpha = 0.f;
    self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
    [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeScale(1.05f, 1.05f);
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
}

-(void)dismiss {
    [self dismiss:YES];
}

-(void)dismiss:(BOOL)animate {
    if (!animate) {
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        ;
    }];
}

- (void)updateTheme {
    self.titleTip.textColor = SNUICOLOR(kThemeText6Color);
    [self.closeBtn setImage:[UIImage imageNamed:@"pop_ico_close_v5.png"] forState:UIControlStateNormal];
    
    UIImage *leftImage = [UIImage imageNamed:@"1_background_v6.png"];
    leftImage = [leftImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    UIImage *rightImage = [UIImage imageNamed:@"3_background_v6.png"];
    rightImage = [rightImage resizableImageWithCapInsets:UIEdgeInsetsMake(10, 5, 10, 5) resizingMode:UIImageResizingModeStretch];
    
    [self.middleView setImage:[UIImage imageNamed:@"2_background_v6.png"]];
    [self.leftView setImage:leftImage];
    [self.rightView setImage:rightImage];
    
    [self.popoverImage setImage:[UIImage imageNamed:self.leftImageName]];
}

@end
