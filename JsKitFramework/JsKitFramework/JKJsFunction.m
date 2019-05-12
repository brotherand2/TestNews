//
//  JKJsFunction.m
//  LiteSohuNews
//
//  Created by sevenshal on 16/1/18.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "JKJsFunction.h"

@interface JKJsFunction() {
    id funId;
    JsKitClient* client;
}

@end

@implementation JKJsFunction

-(instancetype)initWithClient:(JsKitClient*)aClient funName:(id)aFunId{
    if (self=[super init]) {
        funId = aFunId;
        client = aClient;
    }
    return self;
}


-(id)applyWithArgCount:(NSInteger) argCount,...{
    NSString* callbackJs = [NSString stringWithFormat:@"jsKitClient._callbacks['%@']",funId];
    NSMutableArray* array = [[NSMutableArray alloc] init];
    va_list args;
    va_start(args, argCount);
    id arg;
    while (argCount--) {
        arg = va_arg(args, id);
        [array addObject:arg==nil?[NSNull null]:arg];
    }
    va_end(args);
    id result = [client evaluatingJavaScriptFunction:callbackJs arguments:array];
    [self cancel];
    return result;
}

-(id)apply:(id) firstParam,...{
    NSString* callbackJs = [NSString stringWithFormat:@"jsKitClient._callbacks['%@']",funId];
    NSMutableArray* array = [[NSMutableArray alloc] init];
    if (firstParam!=nil) {
        [array addObject:firstParam];
        va_list args;
        va_start(args, firstParam);
        id arg;
        while ((arg=va_arg(args, id))!=nil) {
            [array addObject:arg];
        }
        va_end(args);
    }
    
    id result = [client evaluatingJavaScriptFunction:callbackJs arguments:array];
    [self cancel];
    return result;
}

-(void)cancel{
    [client evaluatingJavaScriptWithFormat:@"delete(jsKitClient._callbacks['%@'])",funId];
}

-(void)dealloc{
    
}

@end
