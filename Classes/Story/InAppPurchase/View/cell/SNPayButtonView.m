//
//  SNPayButtonView.m
//  sohunews
//
//  Created by Huang Zhen on 2017/9/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNPayButtonView.h"
#import "SNVoucherCenter.h"

#define kTipText        @"1.在iOS上充值的书币，在非iOS终端不能使用\n\n2.使用Appstore充值前，请查看充值帮助"
#define kHelpButtonString   @"2.使用Appstore充值前，请查看"

@interface SNPayButtonView ()

@property (nonatomic, strong) UILabel * tip;
@property (nonatomic, strong) UIButton * helpBtn;
@property (nonatomic, strong) UIButton * purchaseButton;

@end

@implementation SNPayButtonView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    CGFloat topSpace = 80.f;
    
    self.purchaseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat purchaseBtnWidth = TTScreenBounds().size.width - 2 * 25;
    self.purchaseButton.frame = CGRectMake(0, topSpace, purchaseBtnWidth, 51);
    self.purchaseButton.centerX = TTScreenBounds().size.width/2.f;
    [self.purchaseButton setTitle:@"立即支付" forState:UIControlStateNormal];
    [self.purchaseButton setTitleColor:SNUICOLOR(kThemeText5Color) forState:UIControlStateNormal];
    [self.purchaseButton.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.purchaseButton setBackgroundColor:SNUICOLOR(kThemeRed1Color)];
    self.purchaseButton.layer.borderWidth = 0.5;
    self.purchaseButton.layer.borderColor = SNUICOLORREF(kThemeBg4Color);
    self.purchaseButton.layer.cornerRadius = 2;
    self.purchaseButton.clipsToBounds = YES;
    [self.purchaseButton addTarget:self action:@selector(purchaseButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.purchaseButton];
    
    self.tip = [[UILabel alloc] initWithFrame:CGRectMake(28, self.purchaseButton.bottom + 30, kAppScreenWidth - 14 * 2, 60)];
    self.tip.textColor = SNUICOLOR(kThemeText3Color);
    self.tip.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    self.tip.numberOfLines = 0;
    //    self.tip.text = kTipText;
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:kTipText];
    [str addAttribute:NSForegroundColorAttributeName value:SNUICOLOR(kThemeBlue1Color) range:NSMakeRange(kTipText.length - 4,4)];
    self.tip.attributedText = str;
    self.tip.userInteractionEnabled = YES;
    [self addSubview:self.tip];
    
    self.helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.helpBtn addTarget:self action:@selector(showHelpView) forControlEvents:UIControlEventTouchUpInside];
    self.helpBtn.frame = CGRectMake(0, 0, 60, 25);
    CGSize titleSize = [kHelpButtonString sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    self.helpBtn.left = titleSize.width;
    self.helpBtn.bottom = self.tip.height;
    [self.tip addSubview:self.helpBtn];

}

- (void)purchaseButtonClicked {
    if (self.delegate && [self.delegate respondsToSelector:@selector(payButtonClicked:)]) {
        [self.delegate payButtonClicked:self.purchaseButton];
    }
}

- (void)showHelpView {
    [SNUtility shouldUseSpreadAnimation:NO];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:[SNAPI rootUrl:@"h5apps/novel.sohu.com/modules/rechargehelp/rechargehelp.html"] forKey:kLink];
    [dic setObject:[NSNumber numberWithInt:FictionWebViewType] forKey:kUniversalWebViewType];
    [SNUtility openUniversalWebView:dic];
}

@end
