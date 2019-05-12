//
//  SNStoryLoginButton.m
//  sohunews
//
//  Created by Huang Zhen on 13/02/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNStoryLoginButton.h"
#import "UIColor+StoryColor.h"

@interface SNStoryLoginButton ()

@property (nonatomic, copy) loginAndBuyBlock loginAndBuy;

@property (nonatomic, strong) UILabel * tips;
@property (nonatomic, strong) UIView * leftLineView;
@property (nonatomic, strong) UIView * rightLineView;
@property (nonatomic, strong) UIButton * loginBtn;

@end

@implementation SNStoryLoginButton


- (instancetype)initWithFrame:(CGRect)frame loginBlock:(loginAndBuyBlock)loginBlock{
    if (self = [super initWithFrame:frame]) {
        self.loginAndBuy = loginBlock;
        [self createContent];
    }
    return self;
}

- (void)createContent {
    
    self.tips = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 160, 30)];
    self.tips.backgroundColor = [UIColor clearColor];
    self.tips.text = @"此章节需要登录购买后阅读";
    self.tips.textColor = [UIColor colorFromKey:@"kThemeText3Color"];
    self.tips.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    self.tips.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.tips];
    self.tips.centerX = self.centerX;
    
    self.leftLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 5 + (self.tips.height - 0.5)/2, self.tips.left- 15, 0.5)];
    self.leftLineView.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    [self addSubview:self.leftLineView];
    
    self.rightLineView = [[UIView alloc]initWithFrame:CGRectMake(self.tips.right + 15, self.tips.top + (self.tips.height - 0.5)/2, self.tips.left - 15, 0.5)];
    self.rightLineView.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    [self addSubview:self.rightLineView];
    
    NSString * loginStr = @"登录并购买";
    self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginBtn.frame = CGRectMake(14, self.height/2.f + 20, self.width - 14*2, 51);
    [self.loginBtn setTitle:loginStr forState:UIControlStateNormal];
    [self.loginBtn setTitleColor:[UIColor colorFromKey:@"kThemeText5Color"] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundColor:[UIColor colorFromKey:@"kThemeRed1Color"]];
    self.loginBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [self.loginBtn addTarget:self action:@selector(loginAndBuy:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.loginBtn];
}

- (void)loginAndBuy:(id)sender {
    if (self.loginAndBuy) {
        self.loginAndBuy();
    }
}

- (void)updateNovelTheme {
    self.tips.textColor = [UIColor colorFromKey:@"kThemeText2Color"];
    self.leftLineView.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    self.rightLineView.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    [self.loginBtn setTitleColor:[UIColor colorFromKey:@"kThemeText5Color"] forState:UIControlStateNormal];
    [self.loginBtn setBackgroundColor:[UIColor colorFromKey:@"kThemeRed1Color"]];
}

@end
