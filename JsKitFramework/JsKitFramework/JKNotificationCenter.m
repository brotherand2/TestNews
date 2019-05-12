//
//  JKNotificationCenter.m
//  JsKitFramework
//
//  Created by sevenshal on 15/11/9.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import "JKNotificationCenter.h"
#import "JKValue.h"

@implementation JKNotificationCenter{
    NSMutableArray* clients;
}


+(JKNotificationCenter*) defaultCenter{
    static JKNotificationCenter* notification;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        notification = [[JKNotificationCenter alloc] init];
    });
    return notification;

}

-(instancetype)init{
    if(self=[super init]){
        clients = [[NSMutableArray alloc] init];
        [JsKitClient addGlobelJavascriptInterface:self forName:@"_jsKitNotification"];
    }
    return self;
}

-(void)addClient:(JsKitClient*)client{
    [clients addObject:[NSValue valueWithNonretainedObject:client]];
}

-(void)removeClient:(JsKitClient*)client{
    [clients removeObject:[NSValue valueWithNonretainedObject:client]];
}

-(void)dispatchNotification:(NSString*) action withObject:(id)obj{
    for (NSValue* value in clients) {
        JsKitClient* client = [value nonretainedObjectValue];
        [client evaluatingJavaScriptFunction:@"jsKitClient._dispatchNotificationFromNative",action,obj,[JKValue argEnd]];
    }
}

-(void)jsInterface_dispatchNotification:(id)client action:(NSString*)action object:(id)obj{
    if ([[NSThread currentThread] isMainThread]) {
        [self dispatchNotification:action withObject:obj];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dispatchNotification:action withObject:obj];
        });
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:action object:obj];
}

@end
