//
//  SHH5CommonApi.h
//  sohunews
//
//  Created by 赵青 on 16/1/11.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "JsKitFramework.h"
#import <JsKitFramework/JsKitFramework.h>

@interface SHH5CommonApi : NSObject

@property (nonatomic, weak) id delegate;


+ (id)shareInstance;

- (id)jsInterface_switchLocation:(JsKitClient*)client;
- (id)jsInterface_getNetworkInfo:(JsKitClient*)client;
- (id)jsInterface_addLog:(JsKitClient*)client type:(NSNumber *)type content:(NSString *)constent;
- (id)jsInterface_getDeviceInfo:(JsKitClient*)client;
- (id)jsInterface_getPrivateInfo:(JsKitClient*)client;
- (id)jsInterface_getRequestParam:(JsKitClient*)client;
- (id)jsInterface_getAppInfo:(JsKitClient*)client;
- (id)jsInterface_clearCachedData:(JsKitClient*)client;

- (id)jsInterface_getCacheSize:(JsKitClient*)client;
- (id)jsInterface_md5:(JsKitClient*)client value:(NSString *)value;
- (id)jsInterface_getDebugInfo:(JsKitClient*)client;
- (id)jsInterface_getPackageInfo:(JsKitClient*)client appName:(NSString *)appName;
- (id)jsInterface_downloadFile:(JsKitClient*)client url:(NSString *)url;
- (void)jsInterfaceWithCallback_ajax:(JsKitClient*)client url:(NSString *)url option:(NSDictionary*)opt callback:(JKJsFunction*)callback;

- (id)jsInterface_isSubInfo:(JsKitClient *)client subId:(NSString *)subId;
- (void)jsInterface_changeSubInfo:(JsKitClient *)client jsonStr:(id)jsonStr isSub:(id)isSub;

/*
*
*   频道预览页打开大图模式
*/
- (void)jsInterface_zoomImage:(JsKitClient *)client imageUrl:(NSString *)imageUrl title:(NSString *)title x:(NSNumber *)x y:(NSNumber *)y;

/**
 供H5调用，用于判断debug开关是否开启

 @return 0 表示未开启; 1 表示已开启
 */
- (id)jsInterface_debugSwitchStatus:(JsKitClient*)client;

@end
