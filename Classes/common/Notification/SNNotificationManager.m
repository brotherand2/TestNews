//
//  SNNotificationManager.m
//  sohunews
//
//  Created by H on 2016/12/15.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNNotificationManager.h"

@implementation SNNotificationManager

+ (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:aSelector name:aName object:anObject];
}

+ (void)postNotification:(NSNotification *)aNotification {
    SNDebugLog(@"NSNotificationCenter postNotification");
    [[NSNotificationCenter defaultCenter] postNotification:aNotification];
}

+ (void)postNotificationName:(NSString *)aName object:(id)anObject {
    SNDebugLog(@"NSNotificationCenter postNotification : %@ ",aName);
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject];
}

+ (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    SNDebugLog(@"NSNotificationCenter postNotification : %@ ",aName);
    [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
}

+ (void)removeObserver:(id)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

+ (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:aName object:anObject];
}

+ (id)addObserverForName:(NSNotificationName)aName object:(id)obj queue:(NSOperationQueue *)aQueue usingBlock:(void (^)(NSNotification *note))aBlock {
    return [[NSNotificationCenter defaultCenter] addObserverForName:aName object:obj queue:aQueue usingBlock:aBlock];
}
@end
