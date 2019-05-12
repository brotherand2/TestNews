//
//  SNTimelineLoginViewController.h
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBaseViewController.h"
#import "SNUserAccountService.h"
#import "SNUserinfoService.h"

#define kBtnTitleFontSize               (22 / 2)
#define kBtnTitleTopMargin              (24 / 2)
#define kInfoLabelFontSize              (30 / 2)
#define kBtnTitleTopMargin              (24 / 2)
#define kBtnTopMargin                   (32 / 2)

@interface SNTimelineLoginViewController : SNBaseViewController<SNUserAccountOpenLoginUrlDelegate, SNUserAccountLoginDelegate, SNUserinfoServiceGetUserinfoDelegate>
{
    CGFloat btnOffsetY;
    CGFloat _infoPanelBottom;
    UILabel *_infoLabel;
    
    UIButton *_loginBtnSinaWeibo;
    UIImageView *_infoImageView;
}

- (void)loginSuccess;
- (void)notifyLoginSuccess;
- (void)initInfoPanel;
- (void)layoutSubView;

- (void)loginActionWithOthers:(id)sender;
@end
