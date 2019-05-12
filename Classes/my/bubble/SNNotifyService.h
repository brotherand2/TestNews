//
//  SNNotifyService.h
//  sohunews
//
//  Created by weibin cheng on 13-9-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SNURLRequest.h"


@interface SNNotifyService : NSObject
{
//    SNURLRequest* _notificationRequest;
    BOOL _isRunning;
}

+(SNNotifyService*)shareInstance;
-(void)startRequestNotify;
-(void)cancelRequestNotify;
+(int)getMaxMsgId;
+(void)saveMaxMsgId:(int)msgId;
@end
