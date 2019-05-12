//
//  SNBaseViewController.h
//  sohunews
//
//  Created by Chen Hong on 12-9-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNHeadSelectView.h"
#import "SNToolbar.h"
//#import "SNViewController.h"
#import "SNThemeViewController.h"
#import "NSJSONSerialization+String.h"
#import "SNCenterToast.h"

@interface SNBaseViewController : SNThemeViewController <UIGestureRecognizerDelegate>{
    SNHeadSelectView    *_headerView;
    SNToolbar           *_toolbarView;
}

@property(nonatomic, strong) SNHeadSelectView   *headerView;
@property(nonatomic, strong) SNToolbar          *toolbarView;

- (void)addHeaderView;
- (void)addToolbar;
- (void)updateTheme:(NSNotification *)notifiction;
- (void)onBack:(id)sender;

- (void)resetToolBarOrigin;

@end
