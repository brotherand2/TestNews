//
//  SNNotificationManager.h
//  sohunews
//
//  Created by H on 2016/12/15.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNNotificationKeys.h"

@interface SNNotificationManager : NSObject

+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject;

+ (void)postNotification:(NSNotification *)aNotification;
+ (void)postNotificationName:(NSString *)aName object:(id)anObject;
+ (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

+ (void)removeObserver:(id)observer;
+ (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject;

+ (id)addObserverForName:(NSNotificationName)aName object:(id)obj queue:(NSOperationQueue *)aQueue usingBlock:(void (^)(NSNotification *note))aBlock;
@end
