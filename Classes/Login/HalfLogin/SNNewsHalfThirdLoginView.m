//
//  SNNewsHalfThirdLoginView.m
//  sohunews
//
//  Created by wang shun on 2017/10/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsHalfThirdLoginView.h"
#import "SNThirdLoginButton.h"

@interface SNNewsHalfThirdLoginView ()

@end

@implementation SNNewsHalfThirdLoginView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self createUI];
    }
    return self;
}

- (void)createUI{
    [self createLabel];
    [self createIcons];
}

- (void)createLabel{
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    label.textColor = SNUICOLOR(kThemeText3Color);
    label.font = [UIFont systemFontOfSize:13];
    label.text = @"其他登录方式";
    [self addSubview:label];
    [label sizeToFit];
    
    CGFloat w = label.bounds.size.width;
    CGFloat x = (self.bounds.size.width-w)/2.0;
    CGRect rect = CGRectMake(x, 0, label.bounds.size.width, label.bounds.size.height);
    [label setFrame:rect];
    
    CGFloat y = label.bounds.size.height/2.0;
    CGFloat l_w = (self.bounds.size.width - 40 - 26 - w)/2.0;
    CGFloat r_x = CGRectGetMaxX(label.frame)+13;
    UIView* left_line = [[UIView alloc] initWithFrame:CGRectMake(20, y, l_w, 0.5)];
    [self addSubview:left_line];
    UIView* right_line = [[UIView alloc] initWithFrame:CGRectMake(r_x, y, l_w, 0.5)];
    [self addSubview:right_line];
    
    [left_line setBackgroundColor:SNUICOLOR(kThemeBg6Color)];
    [right_line setBackgroundColor:SNUICOLOR(kThemeBg6Color)];
}

- (void)createIcons{
    CGFloat x = (self.bounds.size.width-112)/2.0;
    CGFloat i = (self.bounds.size.width-(34*4)-112)/3.0;
    if (![WXApi isWXAppInstalled])  {
        i = (self.bounds.size.width-(34*3)-112)/2.0;
    }
    
    CGRect itemRect = CGRectMake(56, 27, 34, 34);
    
    UIImage* normal = nil;
    UIImage* highLighted = nil;
    if ([WXApi isWXAppInstalled])  {
        //微信
        SNThirdLoginButton* weixinButton = [[SNThirdLoginButton alloc] initWithFrame:itemRect];
        weixinButton.thirdName = @"weixin";
        UIImage* normal = [UIImage themeImageNamed:@"icoland_weixin_v5.png"];
        UIImage* highLighted = [UIImage themeImageNamed:@"icoland_weixinpress_v5.png"];
        [weixinButton setImage:normal forState:UIControlStateNormal];
        [weixinButton setImage:highLighted forState:UIControlStateHighlighted];
        [weixinButton addTarget:self action:@selector(thirdLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:weixinButton];
        
        itemRect.origin.x += itemRect.size.width + i;
    }
    
    //qq
    SNThirdLoginButton* qqButton = [[SNThirdLoginButton alloc] initWithFrame:itemRect];
    qqButton.thirdName = @"qq";
    normal = [UIImage themeImageNamed:@"icoland_qq_v5.png"];
    highLighted = [UIImage themeImageNamed:@"icoland_qqpress_v5.png"];
    [qqButton setImage:normal forState:UIControlStateNormal];
    [qqButton setImage:highLighted forState:UIControlStateHighlighted];
    [qqButton addTarget:self action:@selector(thirdLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:qqButton];
    itemRect.origin.x += itemRect.size.width + i;
    
    //sohu
    SNThirdLoginButton* sohuButton = [[SNThirdLoginButton alloc] initWithFrame:itemRect];
    sohuButton.thirdName = @"sohu";
    normal = [UIImage themeImageNamed:@"icoland_sohu_v5.png"];
    highLighted = [UIImage themeImageNamed:@"icoland_sohupress_v5.png"];
    [sohuButton setImage:normal forState:UIControlStateNormal];
    [sohuButton setImage:highLighted forState:UIControlStateHighlighted];
    [sohuButton addTarget:self action:@selector(thirdLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sohuButton];
    itemRect.origin.x += itemRect.size.width + i;
    
    //weibo
    SNThirdLoginButton* weiboButton = [[SNThirdLoginButton alloc] initWithFrame:itemRect];
    weiboButton.thirdName = @"weibo";
    normal = [UIImage themeImageNamed:@"icoland_sina_v5.png"];
    highLighted = [UIImage themeImageNamed:@"icoland_sinapress_v5.png"];
    [weiboButton setImage:normal forState:UIControlStateNormal];
    [weiboButton setImage:highLighted forState:UIControlStateHighlighted];
    [weiboButton addTarget:self action:@selector(thirdLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:weiboButton];
    
}

- (void)thirdLoginBtnClick:(SNThirdLoginButton*)btn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(thirdLoginWithThirdName:)]) {
        [self.delegate thirdLoginWithThirdName:btn.thirdName];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
