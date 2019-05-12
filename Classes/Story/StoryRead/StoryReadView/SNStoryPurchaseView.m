//
//  SNStoryPurchaseView.m
//  sohunews
//
//  Created by chuanwenwang on 16/10/31.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryPurchaseView.h"
#import "SNStoryContanst.h"
#import "UIViewAdditions+Story.h"
#import "UIImage+Story.h"
#import "SNStoryPage.h"
#import "SNVoucherCenter.h"
#import "SNStoryUtility.h"
#import "SNDevice.h"
#import "ChapterList.h"

#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APAuthV2Info.h"
#import "SNStoryPageViewController.h"
#import "SNNewsLoginManager.h"

#define ChoseLabelGap                16.0
#define HelpBtnRightGap              8.0

#define PurchaseBtnOriginX           ([UIScreen mainScreen].bounds.size.width > 320 ? 70.0 : 55.0)
#define PurchaseBtn_ChoseLabelGap    19.0
#define PurchaseBtnOriginY           22.0
#define PurchaseBtnXGap              29.0
#define PurchaseBtnYGap              22.0
#define PurchaseBtnHeight            31.0

@interface SNStoryPurchaseView (){
    CGFloat _price;
    UIButton *choseBtn;
    CGFloat screenScale;
}
//分割线
@property(nonatomic, strong)UILabel *top_Label;
@property(nonatomic, strong)UIView *top_leftLine;
@property(nonatomic, strong)UIView *top_rightLine;

//使用帮助
@property(nonatomic, strong)UIButton *helpBtn;
@property(nonatomic, strong)UIImageView *helpImg;

//将从第XX章 XXXX 开始购买
@property(nonatomic, strong)UILabel *payTipLabel;

//@property(nonatomic, strong)UIView *topLineView;
@property(nonatomic, strong)UILabel *choseLabel;
@property(nonatomic, strong)UILabel *priceLabel;
@property(nonatomic, strong)UIView *leftLine;
@property(nonatomic, strong)UIView *rightLine;
@property(nonatomic, strong)UIButton *buyNowBtn;
@property(nonatomic, strong)UIImageView *selectImage;
@property(nonatomic, assign)NSInteger payChapterCount;
@end

@implementation SNStoryPurchaseView

- (instancetype)initWithFrame:(CGRect)frame pageViewController:(SNStoryPageViewController *)pageViewController chapterIndex:(NSInteger)currentIndex
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.pageViewController = pageViewController;
        self.currentIndex = currentIndex;
        //刷新余额信息
        [SNVoucherCenter refreshBalance];
        screenScale = [UIScreen mainScreen].bounds.size.height/670.f;//以670高的屏幕为标准算scale
        self.backgroundColor = [UIColor clearColor];

        UIFont *labelFont = [UIFont systemFontOfSize:kThemeFontSizeD];
        CGSize labelSize = [@"选择章节" boundingRectWithSize:CGSizeMake(self.width - 20,labelFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelFont} context: nil].size;
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
        titleLabel.text = @"选择章节";
        titleLabel.textColor = [UIColor colorFromKey:@"kThemeText1Color"];
        titleLabel.font = labelFont;
        titleLabel.centerX = self.width/2.f;
        titleLabel.centerY = 0;
        self.top_Label = titleLabel;
        [self addSubview:titleLabel];

        CGFloat lineWidth = (self.width - titleLabel.width)/2.f - 15;
        UIView *leftLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,lineWidth , 0.5)];
        leftLineView.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
        self.top_leftLine = leftLineView;
        [self addSubview:leftLineView];
        
        UIView *rightLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,lineWidth , 0.5)];
        rightLineView.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
        rightLineView.right = self.width;
        self.top_rightLine = rightLineView;
        [self addSubview:rightLineView];
        
        [self createHelpButton];
        
        UILabel * payTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
        payTipLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
        payTipLabel.text = @"将从本章开始购买";
        payTipLabel.textColor = [UIColor colorFromKey:@"kThemeText2Color"];
        payTipLabel.top = (self.helpBtn.bottom + 10) * screenScale;
        payTipLabel.centerX = self.width/2.f;
        self.payTipLabel = payTipLabel;
        [self addSubview:payTipLabel];
        
        self.payChapterCount = self.pageViewController.payArray.count;
        //购买按钮
        [self createPurchaseBtn];
        
        //注册余额变动通知
        [SNNotificationManager addObserver:self selector:@selector(didRefreshCoinBalance:) name:kSNNovelCoinBalanceRefreshSuccessedNotification object:nil];
        //自动购买按钮状态变化
        [SNNotificationManager addObserver:self selector:@selector(autoPurchaseStatusChanged) name:NovelAutoPurchaseStatusDidChangedNotification object:nil];
    }
    
    return self;
}

- (void)setPaymentTitle:(NSString *)title index:(NSInteger)index{
    NSString * text = [NSString stringWithFormat:@"将从 %@ 开始购买",title];
    UIFont *labelFont = [UIFont systemFontOfSize:kThemeFontSizeC];
    CGSize labelSize = [text boundingRectWithSize:CGSizeMake(self.width - 20,labelFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:labelFont} context: nil].size;
    self.payTipLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    self.payTipLabel.text = text;
    self.payTipLabel.width = labelSize.width;
    self.payTipLabel.centerX = self.width/2.f;
}

- (void)createHelpButton{
    
    UIButton * helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [helpBtn setFrame:CGRectMake(0, 0, 60, 30)];
    [helpBtn setTitle:@"使用帮助" forState:UIControlStateNormal];
    [helpBtn setTitleColor:[UIColor colorFromKey:@"kThemeText2Color"] forState:UIControlStateNormal];
    [helpBtn.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    [helpBtn addTarget:self action:@selector(helpBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    helpBtn.right = self.width - 14;
    helpBtn.top = self.top_Label.bottom + 2;
    self.helpBtn = helpBtn;
    [self addSubview:helpBtn];
    
    UIImageView * helpImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    helpImg.image = [UIImage imageStoryNamed:@"icofiction_sybz_v5.png"];
    helpImg.contentMode = UIViewContentModeScaleAspectFill;
    helpImg.centerY = helpBtn.centerY;
    helpImg.right = helpBtn.left - 3;
    self.helpImg = helpImg;
    [self addSubview:helpImg];
}

- (void)helpBtnClicked:(id)sender {
    [SNUtility shouldUseSpreadAnimation:NO];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:[SNAPI rootUrl:@"h5apps/novel.sohu.com/modules/novelhelp/novelhelp.html"] forKey:kLink];
    [dic setObject:[NSNumber numberWithInt:FictionWebViewType] forKey:kUniversalWebViewType];
    [SNUtility openUniversalWebView:dic];
}

-(void)createPurchaseBtn
{
    CGFloat topSpace = self.payTipLabel.bottom;
    CGFloat purchaseBtnBottom = 0;
    __block NSInteger remainCount = self.pageViewController.chapterArray.count - self.currentIndex;
    /// 处理一下剩余章节中已经购买的部分
    if (self.currentIndex < self.pageViewController.chapterArray.count) {
        remainCount = 0;
        NSArray * remainArray = [self.pageViewController.chapterArray subarrayWithRange:NSMakeRange(self.currentIndex, self.pageViewController.chapterArray.count - self.currentIndex)];
        [remainArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[ChapterList class]]) {
                if (!((ChapterList *)obj).hasPaid && !((ChapterList *)obj).isfree) {
                    remainCount ++;
                }
            }
        }];
    }
    BOOL hideOthers = NO;
    
    for (int i = 0; i < 4; i++) {
        
        
        float purchaseBtnWidth = (self.width -PurchaseBtnOriginX*2 - PurchaseBtnXGap)/2;
        
        UIButton *purchaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        purchaseBtn.tag = 7500+i;
        purchaseBtn.frame = CGRectMake(PurchaseBtnOriginX +(purchaseBtnWidth+PurchaseBtnXGap) * (i%2),
                                       topSpace * screenScale + PurchaseBtn_ChoseLabelGap +(PurchaseBtnOriginY + PurchaseBtnHeight)*(i/2)* screenScale,
                                       purchaseBtnWidth,
                                       PurchaseBtnHeight);
        purchaseBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        //小屏幕不做圆角了，太小了
        purchaseBtn.layer.masksToBounds = [UIScreen mainScreen].bounds.size.width != 320;
        purchaseBtn.layer.borderWidth = 0.5;
        purchaseBtn.layer.cornerRadius = 1;
        [purchaseBtn addTarget:self action:@selector(purchaseBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:purchaseBtn];
        purchaseBtnBottom = purchaseBtn.bottom;
        
        if (i == 0) {
            [purchaseBtn setTitle:@"购买本章" forState:UIControlStateNormal];
            purchaseBtn.selected = YES;
            self.purchaseType = StoryThisChapter;
            [purchaseBtn setTitleColor:[UIColor colorFromKey:@"kThemeText5Color"] forState:UIControlStateNormal];
            purchaseBtn.layer.borderColor = [UIColor colorFromKey:@"kThemeRed1Color"].CGColor;
            [purchaseBtn setBackgroundColor:[UIColor colorFromKey:@"kThemeRed1Color"]];
        }
        else
        {
            [purchaseBtn setTitleColor:[UIColor colorFromKey:@"kThemeRed1Color"] forState:UIControlStateNormal];
            purchaseBtn.layer.borderColor = [UIColor colorFromKey:@"kThemeBg1Color"].CGColor;
            [purchaseBtn setBackgroundColor:[UIColor colorFromKey:@"kThemeBg4Color"]];
            
            switch (i) {
                case 1:
                {
                    if (remainCount == 1) {
                        purchaseBtn.hidden = YES;
                        hideOthers = YES;
                        break;
                    }
                    if (remainCount > 10) {
                        [purchaseBtn setTitle:@"后10章" forState:UIControlStateNormal];
                    }else{
                         [purchaseBtn setTitle:[NSString stringWithFormat:@"剩余%d章",remainCount] forState:UIControlStateNormal];
                        hideOthers = YES;
                    }
                }
                    break;
                    
                case 2:
                {
                    if (hideOthers) {
                        purchaseBtn.hidden = YES;
                        break;
                    }
                    if (remainCount > 50) {
                        [purchaseBtn setTitle:@"后50章" forState:UIControlStateNormal];
                    }else{
                         [purchaseBtn setTitle:[NSString stringWithFormat:@"剩余%d章",remainCount] forState:UIControlStateNormal];
                        hideOthers = YES;
                    }
                 }
                    break;
                    
                case 3:
                {
                    if (hideOthers) {
                        purchaseBtn.hidden = YES;
                        break;
                    }
                    NSString *countStr = [NSString stringWithFormat:@"剩余%ld章",remainCount];
                    [purchaseBtn setTitle:countStr forState:UIControlStateNormal];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }

    UIFont *priceFont = [UIFont systemFontOfSize:kThemeFontSizeD];
    CGSize priceLabelSize = [@"价格0书币" boundingRectWithSize:CGSizeMake(self.width - 20,priceFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:priceFont} context: nil].size;
    
    UILabel *priceLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.width - priceLabelSize.width) / 2, purchaseBtnBottom + 20, priceLabelSize.width, priceFont.lineHeight)];
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.text = @"价格0书币";
    priceLabel.font = priceFont;
    priceLabel.textColor = [UIColor colorFromKey:@"kThemeText1Color"];
    self.priceLabel = priceLabel;
    [self addSubview:priceLabel];
    
    
    UIView *leftLineView = [[UIView alloc]initWithFrame:CGRectMake(0, (self.priceLabel.originY + (self.priceLabel.height - 0.5)/2)* screenScale, self.priceLabel.originX - 15, 0.5)];
    leftLineView.tag = 7511;
    leftLineView.centerY = priceLabel.centerY;
    leftLineView.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    self.leftLine = leftLineView;
    [self addSubview:leftLineView];
    
    UIView *rightLineView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.priceLabel.frame) + 15, (self.priceLabel.originY + (self.priceLabel.height - 0.5)/2)* screenScale, self.priceLabel.originX - 15, 0.5)];
    rightLineView.tag = 7512;
    rightLineView.centerY = priceLabel.centerY;
    rightLineView.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    self.rightLine = rightLineView;
    [self addSubview:rightLineView];
    
    CGFloat retract = [UIScreen mainScreen].bounds.size.height == 480 ? 15 : 0;
    
    UILabel *purchaseLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 20)];
    purchaseLabel.backgroundColor = [UIColor clearColor];
    purchaseLabel.textAlignment = NSTextAlignmentLeft;
    purchaseLabel.font = [UIFont systemFontOfSize:13];
    purchaseLabel.textColor = [UIColor colorFromKey:@"kThemeText6Color"];
    purchaseLabel.text = @"不再提示我，并自动购买下一章";
    purchaseLabel.centerX = self.centerX;
    purchaseLabel.top = self.priceLabel.bottom + 28 * screenScale - retract;
    [self addSubview:purchaseLabel];
        
    UIImage *choseImage = [UIImage imageStoryNamed:@"icofiction_xsxz_v5.png"];
    UIImage *unChoseImage = [UIImage imageStoryNamed:@"icofiction_wxz_v5.png"];
    BOOL autoPurchase = [SNVoucherCenter autoPurchase];
    if (autoPurchase) {
        self.selectImage = [[UIImageView alloc] initWithImage:choseImage];
    }else{
        self.selectImage = [[UIImageView alloc] initWithImage:unChoseImage];
    }
    self.selectImage.frame = CGRectMake(0, 0, unChoseImage.size.width, unChoseImage.size.height);
    self.selectImage.right = purchaseLabel.left - 10;
    self.selectImage.centerY = purchaseLabel.centerY;
    [self addSubview:self.selectImage];
    
    
    choseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    choseBtn.frame = CGRectMake(0, 0, choseImage.size.width + 30, choseImage.size.height+20);
    choseBtn.center = self.selectImage.center;
    choseBtn.selected = autoPurchase;
    [choseBtn addTarget:self action:@selector(chosePayBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:choseBtn];
    
    NSString * buyStr = @"购买";
    UIButton *buyNowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    buyNowBtn.frame = CGRectMake(14, 0, self.width - 14*2, 51);
    [buyNowBtn setTitle:buyStr forState:UIControlStateNormal];
    [buyNowBtn setTitleColor:[UIColor colorFromKey:@"kThemeText5Color"] forState:UIControlStateNormal];
    self.buyNowBtn = buyNowBtn;
    buyNowBtn.top = choseBtn.bottom + 20 * screenScale - retract;
    //buyNowBtn.top = self.priceLabel.bottom + 28 * screenScale - retract + 20 * screenScale - retract;
    [buyNowBtn setBackgroundColor:[UIColor colorFromKey:@"kThemeRed1Color"]];
    buyNowBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [buyNowBtn addTarget:self action:@selector(buyNowBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:buyNowBtn];
    
}

- (CGFloat)getPrice {
    return _price;
}

- (void)setPrice:(CGFloat)price {
    _price = price;
    NSString * priceStr = [NSString stringWithFormat:@"价格%.0f书币",_price];
    UIFont * priceFont = [UIFont systemFontOfSize:kThemeFontSizeD];
    CGSize priceLabelSize = [priceStr boundingRectWithSize:CGSizeMake(self.width - 20,priceFont.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:priceFont} context: nil].size;
    self.priceLabel.frame = CGRectMake((self.width - priceLabelSize.width) / 2, self.priceLabel.top, priceLabelSize.width, priceFont.lineHeight);
    self.priceLabel.text = priceStr;
    self.leftLine.frame = CGRectMake(0, 0, self.priceLabel.originX - 15, 0.5);
    self.rightLine.frame = CGRectMake(CGRectGetMaxX(self.priceLabel.frame) + 15, 0, self.priceLabel.originX - 15, 0.5);
    self.leftLine.centerY = self.priceLabel.centerY;
    self.rightLine.centerY = self.priceLabel.centerY;

    if ([SNVoucherCenter sufficientBalance:_price]) {
        NSUInteger amount = [SNVoucherCenter balance];
        //余额充足，可直接购买
        [self.buyNowBtn setTitle:[NSString stringWithFormat:@"余额%d书币，立即支付",amount] forState:UIControlStateNormal];
    }else {
        [self.buyNowBtn setTitle:@"余额不足，充值后购买" forState:UIControlStateNormal];
    }
}

- (void)didRefreshCoinBalance:(NSNotification *)notify {
    if ([SNVoucherCenter sufficientBalance:_price]) {
        NSDictionary * info = notify.userInfo;
        NSUInteger balance = 0;
        NSNumber * bal = info[@"amount"];
        if (bal) {
            balance = bal.integerValue;
        }else{
            balance = [SNVoucherCenter balance];
        }
        //余额充足，可直接购买
        [self.buyNowBtn setTitle:[NSString stringWithFormat:@"余额%d书币，立即支付",balance] forState:UIControlStateNormal];
    }else {
        [self.buyNowBtn setTitle:@"余额不足，充值后购买" forState:UIControlStateNormal];
    }
}

-(void)purchaseBtn:(UIButton *)button
{
    
    for (int i = 0; i < 4; i++) {
        
        UIButton *btn = [self viewWithTag:(7500+i)];
        btn.selected = NO;
        [btn setTitleColor:[UIColor colorFromKey:@"kThemeRed1Color"] forState:UIControlStateNormal];
        btn.layer.borderColor = [UIColor colorFromKey:@"kThemeBg1Color"].CGColor;
        [btn setBackgroundColor:[UIColor colorFromKey:@"kThemeBg4Color"]];
        
    }
    
    switch (button.tag - 7500) {
        case 0:
        {
            button.selected = YES;
            [button setTitleColor:[UIColor colorFromKey:@"kThemeText5Color"] forState:UIControlStateNormal];
            button.layer.borderColor = [UIColor colorFromKey:@"kThemeRed1Color"].CGColor;
            [button setBackgroundColor:[UIColor colorFromKey:@"kThemeRed1Color"]];
            self.purchaseType = StoryThisChapter;
        }
            break;
            
        case 1:
        {
            button.selected = YES;
            [button setTitleColor:[UIColor colorFromKey:@"kThemeText5Color"] forState:UIControlStateNormal];
            button.layer.borderColor = [UIColor colorFromKey:@"kThemeRed1Color"].CGColor;
            [button setBackgroundColor:[UIColor colorFromKey:@"kThemeRed1Color"]];
            self.purchaseType = StoryAfterTenChapter;
        }
            break;
            
        case 2:
        {
            button.selected = YES;
            [button setTitleColor:[UIColor colorFromKey:@"kThemeText5Color"] forState:UIControlStateNormal];
            button.layer.borderColor = [UIColor colorFromKey:@"kThemeRed1Color"].CGColor;
            [button setBackgroundColor:[UIColor colorFromKey:@"kThemeRed1Color"]];
            self.purchaseType = StoryAfterfiftyChapter;
        }
            break;
            
        case 3:
        {
            button.selected = YES;
            [button setTitleColor:[UIColor colorFromKey:@"kThemeText5Color"] forState:UIControlStateNormal];
            button.layer.borderColor = [UIColor colorFromKey:@"kThemeRed1Color"].CGColor;
            [button setBackgroundColor:[UIColor colorFromKey:@"kThemeRed1Color"]];
            self.purchaseType = StoryOtherChapter;
        }
            break;
            
        default:
            break;
    }
}

- (void)setPurchaseType:(StoryPurchaseType)purchaseType {
    _purchaseType = purchaseType;
    if (self.delegate && [self.delegate respondsToSelector:@selector(purchaseTypeDidChanged:)]) {
        [self.delegate purchaseTypeDidChanged:_purchaseType];
    }
}

-(void)chosePayBtn:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        UIImage *choseImage = [UIImage imageStoryNamed:@"icofiction_xsxz_v5.png"];
        self.selectImage.image = choseImage;
    }else{
        UIImage *unChoseImage = [UIImage imageStoryNamed:@"icofiction_wxz_v5.png"];
        self.selectImage.image = unChoseImage;
    }
    [SNVoucherCenter setAutoPurchase:button.selected];
}

- (void)autoPurchaseStatusChanged {
    if ([SNVoucherCenter autoPurchase]) {
        UIImage *choseImage = [UIImage imageStoryNamed:@"icofiction_xsxz_v5.png"];
        self.selectImage.image = choseImage;
        choseBtn.selected = YES;
    }else{
        UIImage *unChoseImage = [UIImage imageStoryNamed:@"icofiction_wxz_v5.png"];
        self.selectImage.image = unChoseImage;
        choseBtn.selected = NO;
    }
}

-(void)buyNowBtn:(UIButton *)button
{
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        
        return;
    }

    if ([SNVoucherCenter sufficientBalance:_price]) {
        //余额充足，可直接购买
        if (self.delegate && [self.delegate respondsToSelector:@selector(purchaseButtonClicked)]) {
            [self.delegate purchaseButtonClicked];
        }
    }
    else
    {
        //余额不足，充值并购买
        //打开充值页面
        [SNStoryUtility openUrlPath:@"tt://voucherCenter" applyQuery:nil applyAnimated:YES];
    }
}

- (void)loginSuccess {
    //登录成功
    //打开充值页面
    [SNStoryUtility openUrlPath:@"tt://voucherCenter" applyQuery:nil applyAnimated:YES];
    //刷新书架数据
    [[NSNotificationCenter defaultCenter] postNotificationName:kNovelDidAddBookShelfNotification object:nil];
}

-(void)payInfoRequset:(NSNotification *)sender
{
    if ([sender.object isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *dic = sender.object;
        
        if ([[dic objectForKey:@"statusMsgEn"]isEqualToString:@"failure"]) {
            //
        } else {
            
            switch (self.purchaseType) {
                    
                case StoryThisChapter:
                {
                    
                }
                    break;
                    
                case StoryAfterTenChapter:
                {
                    
                }
                    break;
                    
                case StoryAfterfiftyChapter:
                {
                    
                }
                    break;
                    
                case StoryOtherChapter:
                {
                    
                }
                    break;
                    
                    
                default:
                    break;
            }
            
            if (self.payType == StoryWiXinPay) {//调起微信
                
                if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
                    
                    BOOL registerWX = [WXApi registerApp:[dic objectForKey:@"appid"] enableMTA:NO];
                    if (registerWX) {
                        
                        PayReq *request = [[PayReq alloc] init];
                        request.partnerId = [dic objectForKey:@"partnerid"];//财付通商家id
                        request.prepayId= [dic objectForKey:@"prepayid"];
                        
                        request.package = [dic objectForKey:@"package"];
                        request.nonceStr = [dic objectForKey:@"noncestr"];
                        request.timeStamp = [[dic objectForKey:@"timestamp"]integerValue];
                        request.sign = [dic objectForKey:@"sign"];
                        
                        BOOL re = [WXApi sendReq:request];
                        if (!re) {
                            return;
                        }
                        else
                        {
                            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(WXCallBack:) name:WXPurchaseChapterContentNotification object:nil];
                        }
                        
                    } else {
                        
                         return;
                    }
                }
                
            } else if(self.payType == StoryZhiFuBaoPay){//调起支付宝
                
                //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
                NSString *appScheme = @"aliStorySohu";
                
                NSMutableString *orderString = [NSMutableString stringWithFormat:@"partner=\"%@\"",[dic objectForKey:@"partner"]];
                [orderString appendFormat:@"&seller_id=\"%@\"",[dic objectForKey:@"seller_id"]];
                [orderString appendFormat:@"&out_trade_no=\"%@\"",[dic objectForKey:@"out_trade_no"]];
                [orderString appendFormat:@"&subject=\"%@\"",[dic objectForKey:@"subject"]];
                [orderString appendFormat:@"&body=\"%@\"",[dic objectForKey:@"body"]];
                [orderString appendFormat:@"&total_fee=\"%@\"",[dic objectForKey:@"total_fee"]];
                [orderString appendFormat:@"&notify_url=\"%@\"",[dic objectForKey:@"notify_url"]];
                [orderString appendFormat:@"&service=\"%@\"",[dic objectForKey:@"service"]];
                [orderString appendFormat:@"&payment_type=\"%@\"",[dic objectForKey:@"payment_type"]];
                [orderString appendFormat:@"&_input_charset=\"%@\"",[dic objectForKey:@"_input_charset"]];
                [orderString appendFormat:@"&sign=\"%@\"",[dic objectForKey:@"sign"]];
                [orderString appendFormat:@"&sign_type=\"%@\"",[dic objectForKey:@"sign_type"]];
                
                [[AlipaySDK defaultService]payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    
                    if ([[resultDic objectForKey:@"resultStatus"]integerValue] == 9000) {//支付成功
                        
                        //NSString *result = [resultDic objectForKey:@"result"];
                    }
                    // result = "partner=\"2088221384467458\"&seller_id=\"2088221384467458\"&out_trade_no=\"t02673272000035573938\"&subject=\"book\"&body=\"book\"&total_fee=\"0.01\"&notify_url=\"http://123.125.123.244/channel/gw/dyna/mobile_res/alipay_mobile_notify\"&service=\"mobile.securitypay.pay\"&payment_type=\"1\"&_input_charset=\"utf-8\"&success=\"true\"&sign_type=\"RSA\"&sign=\"KZNe3rjJg/LmyaSVJIlSRa+RZ15eM0N0oQTBv3ny1C37s0Xod2oGQbRiOU7lP+9BWHM1Ry3hDDTcDJMyLYc5cXsNP/jnhxgNES0GGw46g/zyT7s+RNyhalUBFSa4y2oEJbWSgN1nth+eygxAalig9fs+tRnUEFjgQe1WxE0tAFg=\""
                }];
                
            }else{//调起余额支付
                //
            }
        }
    }
}

#pragma mark 微信支付回调
-(void)WXCallBack:(NSNotification *)sender
{
    if ([sender isKindOfClass:[PayReq class]]) {
        
        PayResp*response=(PayResp*)sender;
        if (response.errCode == WXSuccess) {
            //
        } else {
            //
        }
    }
}

-(void)updateNovelTheme
{
    self.payTipLabel.textColor = [UIColor colorFromKey:@"kThemeText2Color"];

    [self.helpBtn setTitleColor:[UIColor colorFromKey:@"kThemeText2Color"] forState:UIControlStateNormal];
    self.helpImg.image = [UIImage imageStoryNamed:@"icofiction_sybz_v5.png"];
    
    self.top_Label.textColor = [UIColor colorFromKey:@"kThemeText1Color"];
    self.top_leftLine.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    self.top_rightLine.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];

    self.choseLabel.textColor = [UIColor colorFromKey:@"kThemeText6Color"];
    [self.helpBtn setTitleColor:[UIColor colorFromKey:@"kThemeText6Color"] forState:UIControlStateNormal];
    
    if ([SNVoucherCenter autoPurchase]) {
        UIImage *choseImage = [UIImage imageStoryNamed:@"icofiction_xsxz_v5.png"];
        self.selectImage.image = choseImage;
    }else{
        UIImage *unChoseImage = [UIImage imageStoryNamed:@"icofiction_wxz_v5.png"];
        self.selectImage.image = unChoseImage;
    }

    
    for (int i = 0; i < 4; i++) {
        
        UIButton *btn = [self viewWithTag:(7500+i)];
        if (btn.isSelected) {
            [btn setTitleColor:[UIColor colorFromKey:@"kThemeText5Color"] forState:UIControlStateNormal];
            btn.layer.borderColor = [UIColor colorFromKey:@"kThemeRed1Color"].CGColor;
            [btn setBackgroundColor:[UIColor colorFromKey:@"kThemeRed1Color"]];
            
        } else {
            
            [btn setTitleColor:[UIColor colorFromKey:@"kThemeRed1Color"] forState:UIControlStateNormal];
            btn.layer.borderColor = [UIColor colorFromKey:@"kThemeBg1Color"].CGColor;
            [btn setBackgroundColor:[UIColor colorFromKey:@"kThemeBg4Color"]];
        }
    }
    
    self.priceLabel.textColor = [UIColor colorFromKey:@"kThemeText1Color"];
    UIView *leftLine = [self viewWithTag:7511];
    leftLine.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    UIView *rightLine = [self viewWithTag:7512];
    rightLine.backgroundColor = [UIColor colorFromKey:@"kThemeBg1Color"];
    
    for (int i = 0; i < 3; i++) {        
        UIImageView *imageView = [self viewWithTag:(7540+i)];
        switch (i) {
            case 0://微信支付
            {
                imageView.image = [UIImage imageStoryNamed:@"icofiction_weixin_v5.png"];
            }
                break;
                
            case 1://支付宝支付
            {
                imageView.image = [UIImage imageStoryNamed:@"icofiction_zfb_v5.png"];
            }
                break;
                
            case 2://财富余额
            {
                imageView.image = [UIImage imageStoryNamed:@"icofiction_balance_v5.png"];
            }
                break;
                
            default:
                break;
        }
        
        UILabel *label = [self viewWithTag:(7550+i)];
        label.textColor = [UIColor colorFromKey:@"kThemeText6Color"];
    }
    
    [self.buyNowBtn setTitleColor:[UIColor colorFromKey:@"kThemeText5Color"] forState:UIControlStateNormal];
    [self.buyNowBtn setBackgroundColor:[UIColor colorFromKey:@"kThemeRed1Color"]];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:WXPurchaseChapterContentNotification object:nil];
    [SNNotificationManager removeObserver:self];
}

@end
