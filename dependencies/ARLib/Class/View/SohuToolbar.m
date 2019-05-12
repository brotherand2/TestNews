//
//  SohuToolbar.m
//  SohuAR
//
//  Created by sun on 2016/11/28.
//  Copyright © 2016年 Sohu.com Inc. All rights reserved.
//

#import "SohuToolbar.h"
#import <UIKit/UIKit.h>

@interface SohuToolbar ()

@property(nonatomic,strong) UIView *backgroundView;

@end

@implementation SohuToolbar

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        [self addSubview:self.backButton];
    }
    return self;
}

#pragma mark - getter
-(UIView *)backgroundView{
    if (_backgroundView==nil) {
        _backgroundView=[[UIView alloc]initWithFrame:self.frame];
        _backgroundView.backgroundColor=[UIColor blackColor];
        _backgroundView.alpha=0.4;
    }
    return _backgroundView;
}

-(UIButton *)backButton{
    if (_backButton==nil) {
        _backButton=[UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame=CGRectMake(0, 0, 50, 40);
        _backButton.imageView.contentMode=UIViewContentModeScaleAspectFit;
        _backButton.imageEdgeInsets=UIEdgeInsetsMake(15, 5, 0, 0);
    }
    return _backButton;
}

@end
