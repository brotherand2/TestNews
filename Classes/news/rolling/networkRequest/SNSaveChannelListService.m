//
//  SNSaveChannelListService.m
//  sohunews
//
//  Created by lhp on 4/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNSaveChannelListService.h"
#import "SNUserLocationManager.h"
#import "SNUserManager.h"
#import "SNSaveChannelRequest.h"


@implementation SNSaveChannelListService

- (void)saveChannelRequestWithIdStirng:(NSString *) idString {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
    
    if (idString) {
        [SNUserDefaults setObject:idString forKey:kSavedChannelIDStingKey];
        [params setObject:idString  forKey:@"up"];
    }
     
    [[[SNSaveChannelRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        SNDebugLog(@"save channels succeed!");
        
        // 保存频道编辑动作
        [SNUserDefaults setValue:@(1) forKey:@"localChannelChangeFlag"];
        
        [SNUserDefaults removeObjectForKey:kSavedChannelIDStingKey];
        [SNUserDefaults removeObjectForKey:kClickUnSubedChannelKey];
        
        [SNNotificationManager postNotificationName:kRollingChannelChangedNotification object:[NSNumber numberWithBool:NO]];
        
//        //刷新list.go获取频道属性（是否为流式频道）
//        NSDictionary *dict = nil;
//        if (idString.length > 0) {
//            dict = @{kSavedChannelIDStingKey : idString};
//        }
//        [SNNotificationManager postNotificationName:kLoadChannelListNotification object:nil userInfo:dict];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"save channels failed!");
    }];
    
}

@end
