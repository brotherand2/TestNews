//
//  SNPushSettingController.h
//  sohunews
//
//  Created by 李 雪 on 11-6-30.
//  update by sampanli
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNBaseTableViewController.h"
#import "SNMoreSwitcher.h"
#import "SNPushSettingItem.h"
@interface SNPushSettingController : SNBaseTableViewController {
    NSString *_strONorOFF;
    
}
@property(nonatomic, strong)NSString *strONorOFF;
-(void)changePushSettingWith:(SNPushSettingItem*)settingItem switchCtl:(SNPushSwitcher*)switcher;
@end
