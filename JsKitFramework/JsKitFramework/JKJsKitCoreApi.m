//
//  JKJsKitCoreApi.m
//  sohunews
//
//  Created by sevenshal on 16/3/29.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "JKJsKitCoreApi.h"

#import "AFNetworking.h"

#import "JsKitClient.h"

#import "JKJsFunction.h"

@interface JKJsKitCoreApi()

@property(nonatomic,strong) NSMutableDictionary* memoryStorage;

@end

@implementation JKJsKitCoreApi

-(instancetype)init{
    self = [super init];
    if (self) {
        _memoryStorage = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)jsInterfaceWithCallback_ajax:(JsKitClient*)client option:(NSDictionary*)opt callback:(JKJsFunction*)callback
{
    AFHTTPRequestOperationManager* httpRequestManager = [AFHTTPRequestOperationManager manager];
    if (opt == (id)[NSNull null]) {
        opt = nil;
    }
    NSString* method = [[opt objectForKey:@"method"] lowercaseString];
    NSDictionary* headers = [opt objectForKey:@"headers"];
    if (!headers) {
        [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [httpRequestManager.requestSerializer setValue:obj forHTTPHeaderField:key];
        }];
    }
    NSDictionary* data = [opt objectForKey:@"data"];
    void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        [callback applyWithArgCount:2, @(YES), responseObject];
    };
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error)= ^(AFHTTPRequestOperation *operation, NSError *error) {
        [callback applyWithArgCount:1, @(NO)];
    };
    if (method==nil) {
        method = @"get";
    }
    NSString* url = [opt objectForKey:@"url"];
    if([method isEqualToString:@"get"]){
        [httpRequestManager GET:url parameters:data success:success failure:failure];
    }else if([method isEqualToString:@"post"]){
        [httpRequestManager POST:url parameters:data success:success failure:failure];
    }else if([method isEqualToString:@"put"]){
        [httpRequestManager PUT:url parameters:data success:success failure:failure];
    }else if([method isEqualToString:@"delete"]){
        [httpRequestManager DELETE:url parameters:data success:success failure:failure];
    }else if([method isEqualToString:@"patch"]){
        [httpRequestManager PATCH:url parameters:data success:success failure:failure];
    }else {
        failure(nil, nil);
    }
}

- (id)jsInterface_getStorageItem:(JsKitClient*)client host:(NSString*)host key:(NSString*)key{
    JsKitStorage* jskit = [[JsKitStorageManager manager] storageForWebApp:host];
    return [jskit getItem:key];
}


- (void)jsInterface_setClipboardText:(JsKitClient*)client text:(NSString*)text{
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    [board setString:text];
}


- (NSString*)jsInterface_getClipboardText:(JsKitClient*)client{
    UIPasteboard *board = [UIPasteboard generalPasteboard];
    return [board string];
}


- (NSString*)jsInterface_getMemoryItem:(JsKitClient*)client key:(NSString*)key{
    return [_memoryStorage objectForKey:key];
}

- (void)jsInterface_setMemoryItem:(JsKitClient*)client key:(NSString*)key value:(id)val{
    [_memoryStorage setObject:val forKey:key];
}


-(void)setMemoryItem:(id)val forKey:(NSString*)key{
    [_memoryStorage setObject:val forKey:key];
}

-(id)memoryItemForKey:(NSString*)key{
    return [_memoryStorage objectForKey:key];
}

@end
