//
//  SHH5WidgetApi.h
//  sohunews
//
//  Created by 赵青 on 16/1/11.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "JsKitFramework.h"
#import <JsKitFramework/JsKitFramework.h>

@interface SHH5WidgetApi : NSObject
+ (id)shareInstance;

- (id)jsInterface_clientDownloadMainVer:(JsKitClient *)client type:(NSNumber *)type;
- (void)jsInterface_toast:(JsKitClient *)client msg:(NSString *)msg type:(NSString *)type;
- (id)jsInterface_sendShareInfo:(JsKitClient *)client title:(NSString *)title content:(NSString *)content link:(NSString *)link icon:(NSString *)icon description:(NSString *)description;
- (id)jsInterface_showNotifyDialog:(JsKitClient *)client title:(NSString *)title content:(NSString *)content icon:(NSString *)icon okLable:(NSString *)okLable cancelLable:(NSString *)cancelLable;
- (void)jsInterfaceWithCallback_alert:(JsKitClient*)client title:(NSString *)title des:(NSString *)message okLabel:(NSString *)okString cancelLabel:(NSString *)cancelString callback:(JKJsFunction*)callback;
- (void)jsInterfaceWithCallback_alertCenter:(JsKitClient*)client title:(NSString *)title des:(NSString *)message okLabel:(NSString *)okString cancelLabel:(NSString *)cancelString callback:(JKJsFunction*)callback;
@end
