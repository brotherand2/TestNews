//
//  SNThirdLoginView.m
//  sohunews
//
//  Created by wang shun on 2017/4/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNThirdLoginView.h"

#import "SNThirdLoginButton.h"

@interface SNThirdLoginView ()

@end

@implementation SNThirdLoginView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self createOtherTitle];
        [self createThirdBtn];
    }
    return self;
}

#pragma mark - third click

- (void)thirdLoginBtnClick:(SNThirdLoginButton*)b{
    if (self.delegate && [self.delegate respondsToSelector:@selector(thirdLoginWithThirdName:)]) {
        [self.delegate thirdLoginWithThirdName:b.thirdName];
    }
}

- (void)createOtherTitle{
    //其他登录方式
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(14, 4, 320, 15)];
    [label setText:@"其他登录方式"];
    label.font = [UIFont systemFontOfSize:11];
    label.textColor = SNUICOLOR(kThemeText3Color);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    [self addSubview:label];
}

- (void)createThirdBtn{
    
    float originX = 14;
    float originY = 19 + 14;
    
    UIImage *commonImage = [UIImage imageNamed:@"icoland_sohu_v5.png"];
    CGRect itemRect = CGRectMake(originX, originY, commonImage.size.width, commonImage.size.height);
    
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
        
        itemRect.origin.x += itemRect.size.width + (kAppScreenWidth - 5*normal.size.width - 28)/4;
    }
    
    //weibo
    SNThirdLoginButton* weiboButton = [[SNThirdLoginButton alloc] initWithFrame:itemRect];
    weiboButton.thirdName = @"weibo";
    normal = [UIImage themeImageNamed:@"icoland_sina_v5.png"];
    highLighted = [UIImage themeImageNamed:@"icoland_sinapress_v5.png"];
    [weiboButton setImage:normal forState:UIControlStateNormal];
    [weiboButton setImage:highLighted forState:UIControlStateHighlighted];
    [weiboButton addTarget:self action:@selector(thirdLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:weiboButton];
    itemRect.origin.x += itemRect.size.width + (kAppScreenWidth - 5*normal.size.width - 28)/4;
    
    //qq
    SNThirdLoginButton* qqButton = [[SNThirdLoginButton alloc] initWithFrame:itemRect];
    qqButton.thirdName = @"qq";
    normal = [UIImage themeImageNamed:@"icoland_qq_v5.png"];
    highLighted = [UIImage themeImageNamed:@"icoland_qqpress_v5.png"];
    [qqButton setImage:normal forState:UIControlStateNormal];
    [qqButton setImage:highLighted forState:UIControlStateHighlighted];
    [qqButton addTarget:self action:@selector(thirdLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:qqButton];
    itemRect.origin.x += itemRect.size.width + (kAppScreenWidth - 5*normal.size.width - 28)/4;
    
    //sohu
    SNThirdLoginButton* sohuButton = [[SNThirdLoginButton alloc] initWithFrame:itemRect];
    sohuButton.thirdName = @"sohu";
    normal = [UIImage themeImageNamed:@"icoland_sohu_v5.png"];
    highLighted = [UIImage themeImageNamed:@"icoland_sohupress_v5.png"];
    [sohuButton setImage:normal forState:UIControlStateNormal];
    [sohuButton setImage:highLighted forState:UIControlStateHighlighted];
    [sohuButton addTarget:self action:@selector(thirdLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sohuButton];

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
