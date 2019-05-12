//
//  SNSettingViewController.h
//  sohunews
//
//  Created by weibin cheng on 13-8-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SNUpgrade.h"
#import "SNUserAccountService.h"
#import "SNNewAlertView.h"

#define kReadingModeBttonHeight       ((kAppScreenWidth > 375.0) ? 144.0/3 : 96.0/2)
#define kReadingModeBttonFont         ((kAppScreenWidth == 320.0) ? kThemeFontSizeD : kThemeFontSizeD)
#define kReadingModeBttonTag          (1230)

@interface SNSettingViewController : SNBaseViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, SNUserAccountDelegate>

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) SNUpgrade *upgrade;
@property(nonatomic, strong) SNUpgradeInfo *upgradeInfo;
@property(nonatomic, strong) UIActionSheet *actionSheet;
@property(nonatomic, strong) SNNewAlertView *readModeAlertView;
@property(nonatomic, strong) UIView *readingModeView;
// 有一些老的方法 不得不放在这里
- (void)submitLogout;

@end
