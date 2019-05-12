//
//  SNNotificationModel.h
//  sohunews
//
//  Created by weibin cheng on 13-6-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SNURLRequest.h"
#import "SNNotifyTimeLineRequest.h"
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
@interface SNNotificationItem : NSObject

@property(nonatomic, assign)NSInteger ID;
@property(nonatomic, copy) NSString* pid;
@property(nonatomic, copy) NSString* msgid;
@property(nonatomic, copy) NSString* type;
@property(nonatomic, copy) NSString* alert;
@property(nonatomic, copy) NSString* nickName;
@property(nonatomic, copy) NSString* dataPid;
@property(nonatomic, copy) NSString* headUrl;
@property(nonatomic, copy) NSString* time;
@property(nonatomic, copy) NSString* url;
@property(nonatomic, assign) NSInteger height;
-(void)parseNotificationDic:(NSDictionary*) dic;
-(BOOL)isSupportNotification;
-(NSInteger)height;
@end

/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
@protocol SNNotificationModelDelegate <NSObject>
@optional
-(void)didFinishLoadNotificaiton:(NSInteger)num;

-(void)didFailLoadWithError:(NSError *)error;

-(void)didServerFailWithCode:(NSInteger)code WithMsg:(NSString*)msg;
@end

/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////
@interface SNNotificationModel : NSObject<TTURLRequestDelegate>
{
    NSDate* _refreshDate;
}

@property(nonatomic, readonly) NSMutableArray* itemArray;
//@property(nonatomic, strong) SNURLRequest* notificationRequest;
@property(nonatomic, strong) SNNotifyTimeLineRequest *notificationRequest;

@property(nonatomic, weak) id<SNNotificationModelDelegate> notificationDelegate;
@property(nonatomic, strong) NSString* preCursor;
@property(nonatomic, strong) NSString* nextCursor;
@property(nonatomic, assign) NSInteger allNum;
@property(nonatomic, readonly) BOOL hasMore;

+(int)getMaxMsgId;
+(void)resetMaxMsgId;
//-(void)loadAllLocalNotification;
//-(void)requestNewNotification;
-(NSDate*)getLastRefreshDate;
-(void)removeAllNotification;
-(BOOL)isSupportNotification:(NSInteger)index;
-(SNNotificationItem*)getNotificationItem:(NSInteger)index;
-(BOOL)isNotificationItemExist:(NSString*)msgId;

-(void)refresh;
-(void)loadMore;

@end
