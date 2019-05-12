//
//  SNDataBase_Notification.h
//  sohunews
//
//  Created by weibin cheng on 13-6-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDatabase.h"
#import "SNNotificationModel.h"

@interface SNDatabase (Notification)

-(NSArray*)getAllNotification;

-(BOOL)addSingleNotification:(SNNotificationItem*)notification;
-(BOOL)addSingleNotification:(SNNotificationItem*)notification inDatabase:(FMDatabase*)db;

-(BOOL)addMutipleNotification:(NSArray*)itemArray;
-(int)selectMaxNotificationId;
-(BOOL)deleteAllNotification;
@end
