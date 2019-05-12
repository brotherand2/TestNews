//
//  SNShareSettingController.h
//  sohunews
//
//  Created by 李 雪 on 11-6-30.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNTableViewController.h"
#import "SNShareManager.h"
#import "SNBaseTableViewController.h"

@interface SNShareSettingController : SNBaseTableViewController<SNShareManagerDelegate, SNShareListDelegate> {
    UIView *loadEmptyView;
}
@end
