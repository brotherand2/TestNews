//
//  SNNovelChannelLoginTipView.m
//  sohunews
//
//  Created by H on 2016/11/24.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNNovelChannelLoginTipView.h"

static NSString const * tipString = @"登录后书架内容可云同步哟~立即登录";

@interface SNNovelChannelLoginTipView ()

@property (nonatomic, strong) UILabel * textLabel;
@property (nonatomic, strong) UIButton * closeBtn;
@property (nonatomic, strong) UIView * line;

@end

@implementation SNNovelChannelLoginTipView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    NSString * content = [NSString stringWithFormat:@"%@",tipString];
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:content];
    [str addAttribute:NSForegroundColorAttributeName value:SNUICOLOR(kThemeText3Color) range:NSMakeRange(0,content.length - 4)];
    [str addAttribute:NSForegroundColorAttributeName value:SNUICOLOR(kThemeBlue1Color) range:NSMakeRange(content.length - 4,4)];
    self.textLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    self.textLabel.attributedText = str;
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.textLabel];
    self.backgroundColor = SNUICOLOR(kThemeBg5Color);
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setImage:[UIImage themeImageNamed:@"nickClose.png"] forState:UIControlStateNormal];
    self.closeBtn.frame = CGRectMake(0, 0, self.height, self.height);
    self.closeBtn.right = self.right - 14;
    [self.closeBtn addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeBtn];
    
    UIButton * login = [UIButton buttonWithType:UIButtonTypeCustom];
    login.frame = CGRectMake(0, 0, 60, self.height);
    login.left = self.centerX + 50;
    [login addTarget:self action:@selector(loginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:login];
    
    self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 0.5f)];
    self.line.backgroundColor = SNUICOLOR(kThemeBg1Color);
    self.line.clipsToBounds = NO;
    self.line.bottom = self.height - 0.5f;
    [self addSubview:self.line];
}


- (void)hideCloseButton{
    self.closeBtn.hidden = YES;
}

- (void)closeBtnClicked {
    if (self.delegate && [self.delegate respondsToSelector:@selector(novelLoginTipDidClickClose)]) {
        [self.delegate novelLoginTipDidClickClose];
    }
}

- (void)loginBtnClicked {
    if (self.delegate && [self.delegate respondsToSelector:@selector(novelLoginTipDidClickLogin)]) {
        [SNUtility shouldUseSpreadAnimation:NO];
        [self.delegate novelLoginTipDidClickLogin];
    }
}

- (void)updateTheme {
    self.backgroundColor = SNUICOLOR(kThemeBg5Color);
    NSString * content = [NSString stringWithFormat:@"%@",tipString];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:content];
    [str addAttribute:NSForegroundColorAttributeName value:SNUICOLOR(kThemeText3Color) range:NSMakeRange(0,content.length - 4)];
    [str addAttribute:NSForegroundColorAttributeName value:SNUICOLOR(kThemeBlue1Color) range:NSMakeRange(content.length - 4,4)];
    self.textLabel.attributedText = str;
    self.line.backgroundColor = SNUICOLOR(kThemeBg1Color);
    [self.closeBtn setImage:[UIImage themeImageNamed:@"nickClose.png"] forState:UIControlStateNormal];
}

@end
