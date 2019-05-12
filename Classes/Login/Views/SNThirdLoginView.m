//
//  SNThirdLoginView.m
//  sohunews
//
//  Created by wang shun on 2017/4/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNThirdLoginView.h"

#import "SNThirdLoginButton.h"
#import "SNNewsLastThirdLoginIcon.h"
@interface SNThirdLoginView ()

@property (nonatomic,strong) SNNewsLastThirdLoginIcon* last_icon;

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
    
    UILabel* label = [[UILabel alloc] init];
    [label setText:@"其他登录方式"];
    label.font = [UIFont systemFontOfSize:11];
    label.textColor = SNUICOLOR(kThemeText3Color);
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    [self addSubview:label];
    
    CGFloat w = label.bounds.size.width;
    CGFloat x = (self.bounds.size.width-w)/2.0;
    [label setFrame:CGRectMake(x, 0, w, 15)];
    
    UIView* left_line = [[UIView alloc] initWithFrame:CGRectMake(0, 7.5, (self.bounds.size.width-w)/2.0, 0.5)];
    [left_line setBackgroundColor:SNUICOLOR(kThemeBg6Color)];
    [self addSubview:left_line];
    UIView* right_line = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), 7.5, (self.bounds.size.width-w)/2.0, 0.5)];
    [right_line setBackgroundColor:SNUICOLOR(kThemeBg6Color)];
    [self addSubview:right_line];
}

- (void)createThirdBtn{
    
    NSString* lastLoginPlatform = @"";
    CGRect last_icon_rect = CGRectZero;
    NSDictionary* dic = [SNNewsRecordLastLogin getLastLogin:nil];
    if (dic) {
        lastLoginPlatform = [dic allKeys].firstObject;
        
//        if (key) {
//            if ([key isEqualToString:@"weibo"]) {
//                lastLoginPlatform = @"新浪微博";
//            }
//            else if ([key isEqualToString:@"qq"]){
//                lastLoginPlatform = @"QQ";
//            }
//            else if ([key isEqualToString:@"weixin"]){
//                lastLoginPlatform = @"微信";
//            }
//            else if ([key isEqualToString:@"sohu"]){
//                lastLoginPlatform = @"搜狐账号";
//            }
//        }
    }
    
    
    
    float originX = 37;
    float originY = 34;
    
    UIImage *commonImage = [UIImage imageNamed:@"icoland_sohu_v5.png"];
    CGRect itemRect = CGRectMake(originX, originY, commonImage.size.width, commonImage.size.height);
    
    float between = (self.bounds.size.width-37*2-commonImage.size.width*3)/2.0;
    if ([WXApi isWXAppInstalled])  {
        between = (self.bounds.size.width-37*2-commonImage.size.width*4)/3.0;
    }
    
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
        
        if ([lastLoginPlatform isEqualToString:@"weixin"]) {
            last_icon_rect = CGRectMake(itemRect.origin.x+20, itemRect.origin.y+1-10, 42, 17);
        }
        
        itemRect.origin.x += itemRect.size.width + between;
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
    if ([lastLoginPlatform isEqualToString:@"qq"]) {
        last_icon_rect = CGRectMake(itemRect.origin.x+20, itemRect.origin.y+1-10, 42, 17);
    }
    
    itemRect.origin.x += itemRect.size.width + between;
    
    //sohu
    SNThirdLoginButton* sohuButton = [[SNThirdLoginButton alloc] initWithFrame:itemRect];
    sohuButton.thirdName = @"sohu";
    normal = [UIImage themeImageNamed:@"icoland_sohu_v5.png"];
    highLighted = [UIImage themeImageNamed:@"icoland_sohupress_v5.png"];
    [sohuButton setImage:normal forState:UIControlStateNormal];
    [sohuButton setImage:highLighted forState:UIControlStateHighlighted];
    [sohuButton addTarget:self action:@selector(thirdLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sohuButton];
    if ([lastLoginPlatform isEqualToString:@"sohu"]) {
        last_icon_rect = CGRectMake(itemRect.origin.x+20, itemRect.origin.y+1-10, 42, 17);
    }
    
    itemRect.origin.x += itemRect.size.width + between;
    
    //weibo
    SNThirdLoginButton* weiboButton = [[SNThirdLoginButton alloc] initWithFrame:itemRect];
    weiboButton.thirdName = @"weibo";
    normal = [UIImage themeImageNamed:@"icoland_sina_v5.png"];
    highLighted = [UIImage themeImageNamed:@"icoland_sinapress_v5.png"];
    [weiboButton setImage:normal forState:UIControlStateNormal];
    [weiboButton setImage:highLighted forState:UIControlStateHighlighted];
    [weiboButton addTarget:self action:@selector(thirdLoginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:weiboButton];
    if ([lastLoginPlatform isEqualToString:@"weibo"]) {
        last_icon_rect = CGRectMake(itemRect.origin.x+20, itemRect.origin.y+1-10, 42, 17);
    }
    
    
    if (lastLoginPlatform && lastLoginPlatform.length>0) {
        //上次登录显示icon
        SNNewsLastThirdLoginIcon* icon = [[SNNewsLastThirdLoginIcon alloc] initWithFrame:last_icon_rect];
        [self addSubview:icon];
        self.last_icon = icon;
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
