//
//  JsKitStorageManager.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/19.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import "JsKitStorageManager.h"

@implementation JsKitStorageManager{
    NSMutableDictionary* dic;
}

+(JsKitStorageManager *)manager{
    static JsKitStorageManager* manager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[JsKitStorageManager alloc] init];
    });
    return manager;
}

-(instancetype)init{
    if (self=[super init]) {
        dic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(JsKitStorage*) storageForWebApp:(NSString*)webAppName{
    JsKitStorage* storage = [dic objectForKey:webAppName];
    if (!storage) {
        storage = [[JsKitStorage alloc] initWithWebAppName:webAppName];
        [dic setObject:storage forKey:webAppName];
    }
    return storage;
}

@end
