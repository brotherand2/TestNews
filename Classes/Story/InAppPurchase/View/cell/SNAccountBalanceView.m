//
//  SNAccountBalanceView.m
//  sohunews
//
//  Created by Huang Zhen on 2017/9/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNAccountBalanceView.h"
#import "SNUserManager.h"
#import "SNVoucherCenter.h"

@interface SNAccountBalanceView ()

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * balanceLabel;

@end

@implementation SNAccountBalanceView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    NSString * nickName = [SNUserManager getNickName];
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, kAppScreenWidth/2.f-14, 44)];
    self.nameLabel.text =[NSString stringWithFormat: @"充值账户：%@",nickName];
    self.nameLabel.textColor = SNUICOLOR(kThemeText1Color);
    self.nameLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.nameLabel];
    
    CGFloat balance = [SNVoucherCenter balance];
    self.balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 10, kAppScreenWidth/2.f-14, 44)];
    self.balanceLabel.left = self.nameLabel.right;
    self.balanceLabel.text =[NSString stringWithFormat: @"书币余额：%.0f书币",balance];
    self.balanceLabel.textColor = SNUICOLOR(kThemeText1Color);
    self.balanceLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    self.balanceLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.balanceLabel];

    //注册余额变化监测
    [SNNotificationManager addObserver:self selector:@selector(refreshBalance:) name:kSNNovelCoinBalanceRefreshSuccessedNotification object:nil];
}

#pragma mark - SNBalanceObserverNotification
/*
 "data": {
 "nickName": "用户昵称",
 "amount": 5000
 }
 */
- (void)refreshBalance:(NSNotification *)notify {
    NSDictionary * info = notify.userInfo;
    NSNumber * balanceNum = info[@"amount"];
    NSString * nickName = info[@"nickName"];
    NSInteger balance = balanceNum.integerValue;
    if (!balanceNum) {
        balance = [SNVoucherCenter balance];
    }
    self.balanceLabel.text = balance ? [NSString stringWithFormat: @"书币余额：%d书币",balance] :self.balanceLabel.text;
    self.nameLabel.text = nickName ? [NSString stringWithFormat: @"充值账户：%@",nickName] : self.nameLabel.text;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end
