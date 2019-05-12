//
//  SNPurchaseAlert.m
//  sohunews
//
//  Created by H on 2016/12/1.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNPurchaseAlert.h"

@interface SNPurchaseAlert ()

@property (nonatomic,strong) UILabel * titleLabel;
@property (nonatomic, strong) UIImageView * selectIAP;
@property (nonatomic, strong) UIImageView * selectBal;
@property (nonatomic, assign) SNPurchaseMode * purchaseModel;
@property (nonatomic, strong) UIView * backMask;

@property (nonatomic, copy) SNPurchaseAlertCancelEvent cancelEventBlock;
@property (nonatomic, copy) SNPurchaseAlertGoOnEvent goOnEventBlock;

@end

@implementation SNPurchaseAlert

+ (void)alertWithPrice:(NSString *)price cancelButtonEvent:(SNPurchaseAlertCancelEvent)cancelEvent goOnButtonEvent:(SNPurchaseAlertGoOnEvent)goOnEvent {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        SNPurchaseAlert * alert = [[SNPurchaseAlert alloc] initWithFrame:CGRectMake(0, 0, 472/2.f, 340/2.f)];
        alert.titleLabel.text = [NSString stringWithFormat:@"本次消费%@",price];
        alert.cancelEventBlock = cancelEvent;
        alert.goOnEventBlock = goOnEvent;
        [alert alert];
    });
}

- (void)alert {
    
    self.frame = CGRectMake(0, 0, 472/2.f, 340/2.f);
    self.alpha = 0;
    self.centerX = kAppScreenWidth/2.f;
    self.centerY = kAppScreenHeight/2.f + 40;
    if (!self.backMask) {
        self.backMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, kAppScreenHeight)];
    }
    self.backMask.backgroundColor = [UIColor blackColor];
    self.backMask.alpha = 0;
    [[TTNavigator navigator].window addSubview:self.backMask];
    [[TTNavigator navigator].window addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.backMask.alpha = 0.2;
        self.alpha = 1;
        self.centerY = kAppScreenHeight/2.f;
    } completion:^(BOOL finished) {
        
    }];

}

- (void)dismiss {
    [UIView animateWithDuration:0.15 animations:^{
        self.centerY = kAppScreenHeight/2.f + 40;
        self.backMask.alpha = 0.0;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backMask removeFromSuperview];
        [self removeFromSuperview];
    }];

}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = SNUICOLOR(kThemeBg4Color);
        self.layer.cornerRadius = 4;
        self.clipsToBounds = YES;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, self.width, 30)];
    self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    self.titleLabel.textColor = SNUICOLOR(kThemeText2Color);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
    UIImage *choseImage = [UIImage themeImageNamed:@"icofiction_xsxz_v5.png"];
    UIImage *unChoseImage = [UIImage themeImageNamed:@"icofiction_wxz_v5.png"];
    

    self.selectIAP = [[UIImageView alloc]initWithImage:unChoseImage];
    self.selectIAP.top = self.titleLabel.bottom + 12;
    self.selectIAP.left = 0.2 * self.width;
    [self addSubview:self.selectIAP];
    
    UILabel * IAPTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width/2.f, 20)];
    IAPTitle.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    IAPTitle.textColor = SNUICOLOR(kThemeText6Color);
    IAPTitle.textAlignment = NSTextAlignmentLeft;
    IAPTitle.left = self.selectIAP.right + 10;
    IAPTitle.top = self.selectIAP.top - 2;
    IAPTitle.text = @"使用苹果账户充值";
    [self addSubview:IAPTitle];
    
    UIButton * IAPBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    IAPBtn.frame = CGRectMake(_selectIAP.left, _selectIAP.top, _selectIAP.width + 10 + IAPTitle.width, 20);
    [IAPBtn addTarget:self action:@selector(selectIAP:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:IAPBtn];
    
    //默认走财富余额支付
    self.purchaseModel = SNPurchaseInBalance;
    self.selectBal = [[UIImageView alloc]initWithImage:choseImage];
    self.selectBal.top = self.selectIAP.bottom + 24;
    self.selectBal.left = 0.2 * self.width;
    [self addSubview:self.selectBal];
    
    UILabel * BalTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width/2.f, 20)];
    BalTitle.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    BalTitle.textColor = SNUICOLOR(kThemeText6Color);
    BalTitle.textAlignment = NSTextAlignmentLeft;
    BalTitle.left = self.selectBal.right + 10;
    BalTitle.top = self.selectBal.top - 2;
    BalTitle.text = @"使用财富余额充值";
    [self addSubview:BalTitle];
    
    UIButton * balBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    balBtn.frame = CGRectMake(_selectBal.left, _selectBal.top, _selectBal.width + 10 + BalTitle.width, 20);
    [balBtn addTarget:self action:@selector(selectBal:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:balBtn];

    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:SNUICOLOR(kThemeText1Color) forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    cancelButton.frame = CGRectMake(0, 0, self.width/2.f, 39);
    cancelButton.bottom = self.height;
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:cancelButton];
    
    UIButton * goButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [goButton setTitle:@"继续" forState:UIControlStateNormal];
    [goButton setTitleColor:SNUICOLOR(kThemeRed1Color) forState:UIControlStateNormal];
    goButton.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    goButton.frame = CGRectMake(self.width/2.f, 0, self.width/2.f, 39);
    goButton.bottom = self.height;
    [goButton addTarget:self action:@selector(go:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:goButton];

    UIView * v_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, goButton.height)];
    v_line.backgroundColor = SNUICOLOR(kThemeBg1Color);
    v_line.left = self.width/2.f;
    v_line.bottom = self.height;
    [self addSubview:v_line];
    
    UIView * h_line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
    h_line.backgroundColor = SNUICOLOR(kThemeBg1Color);
    h_line.bottom = self.height - goButton.height;
    [self addSubview:h_line];
}

- (void)selectBal:(id)sender {
    UIImage *choseImage = [UIImage themeImageNamed:@"icofiction_xsxz_v5.png"];
    UIImage *unChoseImage = [UIImage themeImageNamed:@"icofiction_wxz_v5.png"];
    self.selectIAP.image = unChoseImage;
    self.selectBal.image = choseImage;
    self.purchaseModel = SNPurchaseInBalance;
}
- (void)selectIAP:(id)sender {
    UIImage *choseImage = [UIImage themeImageNamed:@"icofiction_xsxz_v5.png"];
    UIImage *unChoseImage = [UIImage themeImageNamed:@"icofiction_wxz_v5.png"];
    self.selectIAP.image = choseImage;
    self.selectBal.image = unChoseImage;
    self.purchaseModel = SNPurchaseInAppstore;
}

- (void)cancel:(id)sender {
    [self dismiss];
    if (self.cancelEventBlock) {
        self.cancelEventBlock();
    }
}

- (void)go:(id)sender {
    [self dismiss];
    if (self.goOnEventBlock) {
        self.goOnEventBlock(self.purchaseModel);
    }
}

@end
