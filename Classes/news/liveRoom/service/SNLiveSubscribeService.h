//
//  SNLiveSubscribeService.h
//  sohunews
//
//  Created by Chen Hong on 12-7-9.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LivingGameItem;

@interface SNLiveSubscribeService : NSObject {
    NSMutableDictionary *_subscribedLiveIdInfo;
}

+ (SNLiveSubscribeService *)sharedInstance;

- (BOOL)subscribeWithLiveGame:(LivingGameItem *)liveItem;
- (BOOL)unsubscribeLiveGame:(NSString *)liveId;
- (BOOL)hasLiveGameSubscribed:(NSString *)liveId;
- (void)refreshSubscribeInfo;

// 返回已经订阅的包含liveId的数组
- (NSArray *)subscribedList;

@end

