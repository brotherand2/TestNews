//
//  SNAppConfigActivity.m
//  sohunews
//
//  Created by chenhong on 14-5-14.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNAppConfigActivity.h"

// 下拉刷新活动
static NSString *const keyActivityOpenChannels          = @"openChannels";
static NSString *const keyActivityPullDown              = @"pullDownCopyWriting";
static NSString *const keyActivityShotBefore            = @"shotBefore";
static NSString *const keyActivityShotFail              = @"shotFailCopyWriting";
static NSString *const keyActivityShotFailIcon          = @"shotFailIcon";
static NSString *const keyActivityShotFailBtnName       = @"shotFailLinkName";
static NSString *const keyActivityShotFailShareIcon     = @"shotFailShareIcon";
static NSString *const keyActivityShotFailShareStr      = @"shotFailShareCopyWriting";
static NSString *const keyActivityShotFailShareLink     = @"shotFailShareLink";
static NSString *const keyActivityShotFailShareTitle    = @"shotFailShareTitle";
static NSString *const keyActivityBgImgUrl              = @"groundFloorIcon";


@implementation SNAppConfigActivity


- (void)updateWithDic:(NSDictionary *)configDic {
    self.activityOpenChannels       = [[configDic stringValueForKey:keyActivityOpenChannels defaultValue:nil] componentsSeparatedByString:@","];
    self.activityPulldownStr        = [configDic stringValueForKey:keyActivityPullDown defaultValue:nil];
    self.activityShotBeforeStr      = [configDic stringValueForKey:keyActivityShotBefore defaultValue:nil];
    self.activityShotFailStrArray   = [[configDic stringValueForKey:keyActivityShotFail defaultValue:nil] componentsSeparatedByString:@"|"];
    self.activityShotFailIcon       = [configDic stringValueForKey:keyActivityShotFailIcon defaultValue:nil];
    self.activityShotFailBtnName    = [configDic stringValueForKey:keyActivityShotFailBtnName defaultValue:nil];
    self.activityShotFailShareIcon  = [configDic stringValueForKey:keyActivityShotFailShareIcon defaultValue:nil];
    self.activityShotFailShareStr   = [configDic stringValueForKey:keyActivityShotFailShareStr defaultValue:nil];
    self.activityShotFailShareLink  = [configDic stringValueForKey:keyActivityShotFailShareLink defaultValue:nil];
    self.activityShotFailShareTitle = [configDic stringValueForKey:keyActivityShotFailShareTitle defaultValue:nil];
    self.activityBgImgUrl           = [configDic stringValueForKey:keyActivityBgImgUrl defaultValue:nil];
}

@end
