//
//  SohuARAlertView.m
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuARAlertView.h"

#define kScreen [UIScreen mainScreen].bounds
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScaleRatio (kScreenWidth / 375.0f)

@interface SohuARAlertView ()

@property(nonatomic,strong) UIView *backgroundView;
@property(nonatomic,strong) UIButton *alertButton;

@end

@implementation SohuARAlertView

+(BOOL)hideHUDForWindow{
    return YES;
}

-(instancetype)init{
    self=[super init];
    if (self) {
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self showAlertView];
    }
    return self;
}

#pragma mark - setupView
-(void)showAlertView{
    self.backgroundView.frame=self.frame;
    [self addSubview:self.backgroundView];
   
    [UIView animateWithDuration:0.3f animations:^{
        self.backgroundView.alpha=0.6;
    }];
    self.backgroundView.userInteractionEnabled=NO;
}

#pragma mark - some Action
-(void)tapOfBackgroundView{
}

-(void)tapOfAlertImageView{
     [self hideHUDForWindow];
    if ([_delegate respondsToSelector:@selector(sohuARAlertView:didClickItemType:parameter:)]) {
        [_delegate sohuARAlertView:self didClickItemType:ARAlertViewItemTypeImageView parameter:nil];
    }
}

#pragma mark - setter
-(void)setAlertImage:(UIImage *)alertImage{
    _alertImage=alertImage;
    self.alertImageView.image=alertImage;
}

#pragma mark - getter
-(UIView *)backgroundView{
    if (_backgroundView==nil) {
        _backgroundView=[[UIView alloc]init];
        _backgroundView.backgroundColor=[UIColor blackColor];
        _backgroundView.alpha=0.6;
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOfBackgroundView)];
        [_backgroundView addGestureRecognizer:tap];
       
    }
    return _backgroundView;
}

-(UIImageView *)alertImageView{
    if (_alertImageView==nil) {
        _alertImageView=[[UIImageView alloc]init];
        _alertImageView.bounds = CGRectMake(0, 0, 290 * kScaleRatio, 290 * kScaleRatio);
        _alertImageView.center = CGPointMake(self.center.x, self.center.y - 70 * kScaleRatio);
        _alertImageView.userInteractionEnabled=YES;
        [self addSubview:_alertImageView];
        UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOfAlertImageView)];
        [_alertImageView addGestureRecognizer:tap];
    }
    return _alertImageView;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{

}

-(BOOL)hideHUDForWindow{
    [self.alertImageView removeFromSuperview];
    [self.alertButton removeFromSuperview];
    [self.backgroundView removeFromSuperview];
    [self removeFromSuperview];
    self.alertImageView=nil;
    self.alertButton=nil;
    self.backgroundView=nil;
    return YES;
}

-(void)showAlertViewWithSize:(CGSize)size{
    [self showAlertView];
    self.alertImageView.bounds = CGRectMake(0, 0, size.width,size.height);
    self.alertImageView.center = CGPointMake(self.center.x, self.center.y);
    self.backgroundColor=[UIColor blackColor];
}

-(void)dealloc{
    
}

@end
