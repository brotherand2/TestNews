//
//  SHH5WidgetApi.m
//  sohunews
//
//  Created by 赵青 on 16/1/11.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SHH5WidgetApi.h"
#import "SHWebView.h"
#import "SNNewAlertView.h"

@interface SHH5WidgetApi ()

@property (nonatomic, strong) JKJsFunction * callBack;

@end

@implementation SHH5WidgetApi

+ (id)shareInstance
{
    static SHH5WidgetApi *instance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (nil != self) {
        
    }
    return self;
}

- (id)jsInterface_clientDownloadMainVer:(JsKitClient *)client type:(NSNumber *)type
{
    return nil;
}

- (void)jsInterface_toast:(JsKitClient *)client msg:(NSString *)msg type:(NSString *)type
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([type isEqualToString:@"warn"]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeWarning];
            
        } else  if ([type isEqualToString:@"ok"]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeSuccess];
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    });
}

- (id)jsInterface_sendShareInfo:(JsKitClient *)client title:(NSString *)title content:(NSString *)content link:(NSString *)link icon:(NSString *)icon description:(NSString *)description
{
    [client.callbackBlockDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        JsKitClientCallbackBlock block = [client.callbackBlockDic objectForKey:key];
        if(nil != block) {
            
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
            
            if(title){
                [paramDic setObject:title forKey:@"title"];
            }
            
            if(content){
                [paramDic setObject:content forKey:@"content"];
            }
            
            if(icon){
                [paramDic setObject:icon forKey:@"icon"];
            }
            
            if(link){
                [paramDic setObject:link forKey:@"link"];
            }
            
            if(description){
                [paramDic setObject:description forKey:@"shareComment"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                block(client,paramDic,key);
            });
        }
    }];
    
    return nil;
}

- (id)jsInterface_showNotifyDialog:(JsKitClient *)client title:(NSString *)title content:(NSString *)content icon:(NSString *)icon okLable:(NSString *)okLable cancelLable:(NSString *)cancelLable
{
    return nil;
}

- (void)jsInterfaceWithCallback_alert:(JsKitClient*)client title:(NSString *)title des:(NSString *)message okLabel:(NSString *)okString cancelLabel:(NSString *)cancelString callback:(JKJsFunction*)callback
{
    //执行弹窗动作，当点击确定后，执行[callback apply:@(YES), nil];点击取消后，执行[callback apply:@(NO), nil];
    self.callBack = callback;
    dispatch_async(dispatch_get_main_queue(), ^{

        SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:message cancelButtonTitle:cancelString otherButtonTitle:okString];
        [alert show];
        [alert actionWithBlocksCancelButtonHandler:^{
            [_callBack apply:@(NO),nil];
        } otherButtonHandler:^{
            [_callBack apply:@(YES),nil];
        }];

    });
}
- (void)jsInterfaceWithCallback_alertCenter:(JsKitClient*)client title:(NSString *)title des:(NSString *)message okLabel:(NSString *)okString cancelLabel:(NSString *)cancelString callback:(JKJsFunction*)callback{
    //执行弹窗动作，当点击确定后，执行[callback apply:@(YES), nil];点击取消后，执行[callback apply:@(NO), nil];
    self.callBack = callback;
    dispatch_async(dispatch_get_main_queue(), ^{

        SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:message cancelButtonTitle:cancelString otherButtonTitle:okString];
        [alert show];
        [alert actionWithBlocksCancelButtonHandler:^{
            [_callBack apply:@(NO),nil];
        } otherButtonHandler:^{
            [_callBack apply:@(YES),nil];
        }];

    });
}

@end
