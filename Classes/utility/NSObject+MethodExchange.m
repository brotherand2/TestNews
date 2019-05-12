//
//  NSObject+MethodExchange.m
//  sohunews
//
//  Created by guoyalun on 1/22/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "NSObject+MethodExchange.h"

#import <objc/runtime.h>

@implementation NSObject (MethodExchange)

+(void)exchangeMethod:(SEL)origSel withNewMethod:(SEL)newSel{
    Class class = [self class];
    
    Method origMethod = class_getInstanceMethod(class, origSel);
    if (!origMethod){
        origMethod = class_getClassMethod(class, origSel);
    }
    if (!origMethod)
        @throw [NSException exceptionWithName:@"Original method not found" reason:nil userInfo:nil];
    Method newMethod = class_getInstanceMethod(class, newSel);
    if (!newMethod){
        newMethod = class_getClassMethod(class, newSel);
    }
    if (!newMethod)
        @throw [NSException exceptionWithName:@"New method not found" reason:nil userInfo:nil];
    if (origMethod==newMethod)
        @throw [NSException exceptionWithName:@"Methods are the same" reason:nil userInfo:nil];
    method_exchangeImplementations(origMethod, newMethod);
}

+(void)replaceMethod:(SEL)origSel withNewMethod:(SEL)newSel
{
    Class class = [self class];
    
    Method origMethod = class_getInstanceMethod(class, origSel);
    if (!origMethod){
        origMethod = class_getClassMethod(class, origSel);
    }
    if (!origMethod)
        @throw [NSException exceptionWithName:@"Original method not found" reason:nil userInfo:nil];
    Method newMethod = class_getInstanceMethod(class, newSel);
    if (!newMethod){
        newMethod = class_getClassMethod(class, newSel);
    }
    if (!newMethod)
        @throw [NSException exceptionWithName:@"New method not found" reason:nil userInfo:nil];
    if (origMethod==newMethod)
        @throw [NSException exceptionWithName:@"Methods are the same" reason:nil userInfo:nil];

    method_setImplementation(origMethod, method_getImplementation(newMethod));
}

@end