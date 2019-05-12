//
//  SNDatabase+LiveInvite.h
//  sohunews
//
//  Created by chenhong on 13-12-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase.h"

@class SNLiveInviteStatusObj;

// 记录待处理的直播邀请，处理后删除记录
@interface SNDatabase (LiveInvite)
// add
- (BOOL)addOrUpdateLiveInviteItem:(SNLiveInviteStatusObj *)item;

// delete
- (BOOL)clearAllLiveInviteItems;

- (BOOL)clearLiveInviteItems:(NSNumber *)expiredPoint;

- (BOOL)deleteLiveInviteItemByLiveId:(NSString *)liveId
                            passport:(NSString *)passport;

// get
- (SNLiveInviteStatusObj *)getLiveInviteItemByLiveId:(NSString *)liveId
                                            passport:(NSString *)passport;
@end
