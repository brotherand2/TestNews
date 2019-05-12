//
//  SNBaseTableViewController.h
//  sohunews
//
//  Created by Chen Hong on 12-9-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewController.h"

@interface SNBaseTableViewController : SNTableViewController {
    SNHeadSelectView    *_headerView;
    SNToolbar           *_toolbarView;
}

@property(nonatomic, strong) SNHeadSelectView   *headerView;
@property(nonatomic, strong) SNToolbar          *toolbarView;

- (void)addHeaderView;
- (void)addToolbar;
- (void)updateTheme;

@end
