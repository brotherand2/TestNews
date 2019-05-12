//
//  JKJsClassManager.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/15.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import "JKJsClassManager.h"
#import "JKJsClass.h"

@implementation JKJsClassManager{
    NSMutableDictionary<NSString*,JKJsClass*>* jsClasses;
}

+(JKJsClassManager*)manager{
    static JKJsClassManager* manager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[JKJsClassManager alloc] init];
    });
    return manager;
}

-(instancetype)init{
    if (self=[super init]) {
        jsClasses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(JKJsClass*) getJsClass:(Class)clz{
    NSString* clzName = NSStringFromClass(clz);
    JKJsClass* jsClz = [jsClasses objectForKey:clzName];
    if (!jsClz) {
        jsClz = [[JKJsClass alloc] initWithClass:clz];
        [jsClasses setObject:jsClz forKey:clzName];
    }
    return jsClz;
}


@end
