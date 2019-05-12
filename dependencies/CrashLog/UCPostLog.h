//
//  UCPostLog.h
//  H5GameClient
//
//  Created by zihong on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UCPostLog : NSObject <ASIHTTPRequestDelegate>

+(void)postLog;

void uncaughtExceptionHandler(NSException *exception);
void registerExceptionHandler();

@end
