//
//  SNNavigationView.h
//  sohunews
//
//  替换系统的navigation bar
//
//  Created by wang yanchen on 12-9-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

@interface SNNavigationView : UIView {
    UIButton *_leftBtn;
    UIButton *_rightBtn;
    
    UIView *_titleView;
    UIImageView *_backgroundView;
}

@property(nonatomic, strong) UIButton *leftBtn;
@property(nonatomic, strong) UIButton *rightBtn;
@property(nonatomic, strong) UIView *titleView;
@property(nonatomic, strong) UIImageView *backgroundView;

+ (SNNavigationView *)defautlNavigationView;
- (void)setBackgroundImage:(UIImage *)backgroundImage;

@end
