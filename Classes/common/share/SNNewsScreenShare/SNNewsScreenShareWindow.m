//
//  SNNesScreenShareWindow.m
//  sohunews
//
//  Created by wang shun on 2017/7/18.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsScreenShareWindow.h"

@interface SNNewsScreenShareWindow ()


@property (nonatomic,strong) UIView* bgView;

@property (nonatomic,strong) UIImageView* imageView;

@property (nonatomic,strong) UIView* line;

@property (nonatomic,strong) UIButton* shareBtn;
@property (nonatomic,strong) UIButton* fbBtn;

@property (nonatomic,strong) UIImage* screenShotImg;

@end

@implementation SNNewsScreenShareWindow

-(instancetype)initWithFrame:(CGRect)frame WithImage:(UIImage*)img{
    if (self = [super initWithFrame:frame]) {
        self.screenShotImg = img;
        [self createbgView];
        [self createImage];
        [self createShareBtn];
        [self createfbBtn];
        
        //阴影
        self.layer.shadowColor=[UIColor blackColor].CGColor;
        self.layer.shadowOffset=CGSizeMake(-1, 1);
        self.layer.shadowOpacity=0.4;
        self.layer.shadowRadius=1;
        self.layer.cornerRadius=2;
        self.layer.masksToBounds = YES;
        
        UISwipeGestureRecognizer* swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipePress:)];
        swipe.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipe];
        //kPushViewControllerNotification
        //kPopViewControllerNotification

        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPress:)];
        [self addGestureRecognizer:tap];
        
        [SNNotificationManager addObserver:self selector:@selector(closeWindow) name:kPushViewControllerNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(closeWindow) name:kPopViewControllerNotification object:nil];
    
    }
    return self;
}

- (void)dealloc{
    [SNNotificationManager removeObserver:self];
}

- (void)swipePress:(UIGestureRecognizer*)gesture{
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake([UIScreen mainScreen].bounds.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished) {
        [self closeWindow];
    }];
    
}

- (void)tapPress:(UIGestureRecognizer*)gesture{
    [self shareClick:nil];
}

- (void)createImage{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_imageView setImage:self.screenShotImg];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
}

- (void)createShareBtn{
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"划重点" forState:UIControlStateNormal];
    [btn setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [self addSubview:btn];
    self.shareBtn = btn;
    [btn addTarget:self action:@selector(shareClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createfbBtn{
    self.line = [[UIView alloc] initWithFrame:CGRectZero];
    [self.line setBackgroundColor:SNUICOLOR(kThemeBg4Color)];
    self.line.alpha = 0.25;
    [self addSubview:self.line];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"反馈" forState:UIControlStateNormal];
    [btn setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    [self addSubview:btn];
    self.fbBtn = btn;
    [btn addTarget:self action:@selector(fbClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createbgView{
    self.bgView = [[UIView alloc] initWithFrame:self.bounds];
    self.bgView.backgroundColor = [UIColor clearColor];
    self.bgView.alpha = 1;
    [self addSubview:self.bgView];
}

- (void)show{

    CGRect rect = CGRectMake(self.frame.size.width-14-96, self.frame.size.height-121-76-35, 96, 121+32);
    CGRect img_rect = CGRectMake((96-84)/2.0, 5, 84, 81);
    
    self.backgroundColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.25 animations:^{
        _imageView.frame = img_rect;
        self.backgroundColor = [UIColor clearColor];
        self.frame = rect;
        self.bgView.frame = self.bounds;
        self.bgView.backgroundColor = SNUICOLOR(kThemeCenterScreenWindowColor);
        self.line.frame = CGRectMake(0, CGRectGetMaxY(_imageView.frame)+35, self.bounds.size.width, 0.5);
        
        self.shareBtn.frame = CGRectMake(0, CGRectGetMaxY(_imageView.frame), self.bounds.size.width, 35-1);
        self.fbBtn.frame = CGRectMake(0, CGRectGetMaxY(_shareBtn.frame), self.bounds.size.width, self.frame.size.height-CGRectGetMaxY(_shareBtn.frame));

    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview]; // 2s后 没有操作自动消失
        });
    }];
}

- (void)showOnlyShare{
    CGRect rect = CGRectMake(self.frame.size.width-14-96, self.frame.size.height-121-76, 96, 121);
    CGRect img_rect = CGRectMake((96-84)/2.0, 5, 84, 81);
    
    self.backgroundColor = [UIColor whiteColor];
    [UIView animateWithDuration:0.25 animations:^{
        _imageView.frame = img_rect;
        self.backgroundColor = [UIColor clearColor];
        self.frame = rect;
        self.bgView.frame = self.bounds;
        self.bgView.backgroundColor = SNUICOLOR(kThemeCenterScreenWindowColor);
        
        self.shareBtn.frame = CGRectMake(0, CGRectGetMaxY(_imageView.frame), self.bounds.size.width, 35-1);
        
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview]; // 2s后 没有操作自动消失
        });
    }];

}


- (void)shareClick:(UIButton*)b{
    [self removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(sharePress:)]) {
        [self.delegate sharePress:b];
    }
}

- (void)fbClick:(UIButton*)b{
    [self removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(fbPress:)]) {
        [self.delegate fbPress:b];
    }
}

- (void)closeWindow{
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
