//
//  SNShareListItemCell.h
//  sohunews
//
//  Created by yanchen wang on 12-5-30.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNShareManager.h"
#import "SNTableViewCell.h"

#define kSNShareListItemCellHeight          (110 / 2)
#define kOverdueRightDistance ((kAppScreenWidth == 320.0 || kAppScreenWidth == 375.0)? 20.0/2 : 36.0/3)

@class SNMoreSwitcher;
@interface SNShareListItemCell : SNTableViewCell {
    SNWebImageView *_appIcon;
    UILabel *_appName;
    SNMoreSwitcher *_appSwitcher;
    UIButton *_bindingButton;
    
    ShareListItem *_shareItem;
    id __weak _delegate;
    
    BOOL isBinded;

}

@property(nonatomic, readonly)SNWebImageView *appIcon;
@property(nonatomic, readonly)UILabel *appName;
//@property(nonatomic, readonly)SNModeSwitch *appEnable;
@property(nonatomic, readonly)UIButton *bindingButton;
@property(nonatomic, strong)ShareListItem *shareItem;
@property(nonatomic, weak)id delegate;
@property(nonatomic, assign) BOOL needTopSepLine;
@property (nonatomic, strong) UILabel *overdueLabel;

@end
