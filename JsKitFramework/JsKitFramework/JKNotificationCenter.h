//
//  JKNotificationCenter.h
//  JsKitFramework
//
//  Created by sevenshal on 15/11/9.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JsKitClient.h"

@interface JKNotificationCenter : NSObject

+(JKNotificationCenter*) defaultCenter;

-(void)dispatchNotification:(NSString*) action withObject:(id)obj;

-(void)addClient:(JsKitClient*)client;

-(void)removeClient:(JsKitClient*)client;

@end
