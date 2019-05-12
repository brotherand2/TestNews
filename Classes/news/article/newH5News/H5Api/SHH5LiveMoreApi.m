//
//  SHH5LiveMoreApi.m
//  sohunews
//
//  Created by Scarlett on 16/6/2.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SHH5LiveMoreApi.h"
//#import "JsKitClient.h"
#import <JsKitFramework/JsKitClient.h>
#import "SNLiveSubscribeService.h"

@implementation SHH5LiveMoreApi

#pragma mark liveMoreApi
- (id)jsInterface_liveMoreAttention:(JsKitClient *)client liveID:(id)liveID bookType:(id)bookType liveTime:(id)liveTime title:(id)title liveType:(id)liveType {
    NSString *status = @"0";
    NSInteger type = [[NSString stringWithFormat:@"%@", bookType] integerValue];
    // 订阅
    if (type == 1) {
        LivingGameItem *gameItem = [[LivingGameItem alloc] init];
        gameItem.liveId = [NSString stringWithFormat:@"%@", liveID];
        gameItem.liveTime = [NSString stringWithFormat:@"%@", liveTime];;
        gameItem.title = [NSString stringWithFormat:@"%@", title];;
        gameItem.liveType = [NSString stringWithFormat:@"%@", liveType];;
        
        BOOL isSub = [[SNLiveSubscribeService sharedInstance] subscribeWithLiveGame:gameItem];
        
        if (isSub) {
//            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已添加直播提醒" toUrl:nil mode:SNCenterToastModeSuccess];
        } else {
//            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"添加直播提醒失败" toUrl:nil mode:SNCenterToastModeWarning];
        }
        
        status = (isSub ? @"1" : @"0");
    }
    else if (type == 0) {// 取消
        NSString *liveIDStr = nil;
        if ([liveID isKindOfClass:[NSNumber class]]) {
            liveIDStr = [NSString stringWithFormat:@"%@", liveID];
        }
        else {
            liveIDStr = liveID;
        }
        BOOL isSub = [[SNLiveSubscribeService sharedInstance] unsubscribeLiveGame:liveIDStr ? : @""];
        
        if (isSub) {
//            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已取消直播提醒" toUrl:nil mode:SNCenterToastModeSuccess];
        } else {
//            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"取消直播提醒失败" toUrl:nil mode:SNCenterToastModeWarning];
        }
        
        status = (isSub ? @"1" : @"0");
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:status, @"status", nil];
}

- (id)jsInterface_getAttentionStyle:(JsKitClient *)client {
    NSArray *array = [[SNLiveSubscribeService sharedInstance] subscribedList];
    if (array) {
        return [NSDictionary dictionaryWithObjectsAndKeys:array, @"bookIds", nil];
    }
    
    return nil;
}

@end
