//
//  SHH5CommonApi.m
//  sohunews
//
//  Created by 赵青 on 16/1/11.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SHH5CommonApi.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"
#import "AFNetworking.h"
#import "SNDBManager.h"
#import "SNSubscribeCenterService.h"
//#import "JsKitFramework.h"
#import <JsKitFramework/JsKitFramework.h>
#import "SNRedPacketManager.h"

@implementation SHH5CommonApi

+ (id)shareInstance
{
    static SHH5CommonApi *instance = nil;
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

#pragma mark - apis
- (id)jsInterface_switchLocation:(JsKitClient*)client
{
    return nil;
}

- (id)jsInterface_getNetworkInfo:(JsKitClient*)client
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if ([SNUserManager getP1] != nil) {
        [dic setObject:[SNUserManager getP1] forKey:@"p1"];
    }
    [dic setObject:[SNUtility currentWebNetworkStatusString] forKey:@"type"];
    
    return dic;
}

- (id)jsInterface_addLog:(JsKitClient*)client type:(NSNumber *)type content:(NSString *)constent
{
    return nil;
}

- (id)jsInterface_getDeviceInfo:(JsKitClient*)client
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    //
    NSString *deviceInfo = [[UIDevice currentDevice] model];
    if(nil != deviceInfo){
        [dic setObject:deviceInfo forKey:@"model"];
        [dic setObject:deviceInfo forKey:@"device"];
    }
    //
    [dic setObject:@"APPLE" forKey:@"brand"];
    
    //
    NSString *screen = [NSString stringWithFormat:@"%f x %f", [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale, [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale];
    if(nil != screen){
        [dic setObject:screen forKey:@"display"];
    }
    //
    NSString *systemName = [[UIDevice currentDevice] systemName];
    if(nil != systemName){
        [dic setObject:systemName forKey:@"product"];
    }
    //
    NSString *hardware = [[UIDevice currentDevice] platformStringForSohuNews];
    if(nil != hardware){
        [dic setObject:hardware forKey:@"hardware"];
    }
    //
    [dic setObject:[NSNumber numberWithFloat:[UIScreen mainScreen].scale] forKey:@"density"];
    [dic setObject:@"" forKey:@"densityDpi"];
    
    return dic;
}

- (id)jsInterface_getPrivateInfo:(JsKitClient*)client
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:SNLinks_Domain_BaseURL forKey:@"info"];
    
    //pid
    NSString *temp = [SNUserManager getPid];
    if(temp && [temp length] > 0){
        [dic setObject:temp forKey:@"pid"];
    }else{
        [dic setObject:@"-1" forKey:@"pid"];
    }
    
    NSString *cid = [SNUserManager getCid];
    if (cid.length > 0) {
        [dic setObject:cid forKey:@"cid"];
    }
    NSString *gid = [SNUserManager getGid];
    if (gid.length > 0) {
        [dic setObject:gid forKey:@"gid"];
    }
    NSString *p1 = [SNUserManager getP1];
    if (p1.length > 0) {
        [dic setObject:p1 forKey:@"p1"];
    }
    NSString *p2 = [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier];
    if (p2.length > 0) {
        [dic setObject:p2 forKey:@"p2"];
    }
    
    return dic;
}

- (id)jsInterface_getRequestParam:(JsKitClient*)client
{
    NSString *temp = nil;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    //p1
    temp = [SNUserManager getP1];
    if(temp && [temp length] > 0){
        [dic setObject:[SNUserManager getP1] forKey:@"p1"];
    }else{
        [dic setObject:@"" forKey:@"p1"];
    }
    
    //pid
    temp = [SNUserManager getPid];
    if(temp && [temp length] > 0){
        [dic setObject:temp forKey:@"pid"];
    }else{
        [dic setObject:@"-1" forKey:@"pid"];
    }
    
    //token
    temp = [SNUserManager getToken];
    if(temp && [temp length] > 0){
        [dic setObject:temp forKey:@"token"];
    }else{
        [dic setObject:@"" forKey:@"token"];
    }
    
    //gid
    temp = [SNUserManager getGid];
    if(temp && [temp length] > 0){
        [dic setObject:temp forKey:@"gid"];
    }else{
        [dic setObject:@"" forKey:@"gid"];
    }
    
    //version
    temp = [NSString stringWithFormat:@"%d",APIVersion];
    if(temp && [temp length] > 0){
        [dic setObject:temp forKey:@"apiVersion"];
    }else{
        [dic setObject:@"" forKey:@"apiVersion"];
    }
    
    //sid
    temp = [SNClientRegister sharedInstance].sid;
    if(temp && [temp length] > 0){
        [dic setObject:temp forKey:@"sid"];
    }else{
        [dic setObject:@"" forKey:@"sid"];
    }
    
    //productId
    temp = [SNAPI productId];
    if(temp && [temp length] > 0){
        [dic setObject:temp forKey:@"productId"];
    }else{
        [dic setObject:@"" forKey:@"productId"];
    }
    
    //bid
    temp = [SNAPI encodedBundleID];
    if(temp && [temp length] > 0){
        [dic setObject:temp forKey:@"bid"];
    }else{
        [dic setObject:@"" forKey:@"bid"];
    }
    
    //scookie
    temp = [SNUserDefaults objectForKey:kProfileCookieKey];
    if (temp && [temp length] > 0) {
        [dic setObject:temp forKey:@"sCookie"];
    }
    
    //version
    [dic setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey] forKey:@"versionName"];
    
    [dic setObject:[NSString stringWithFormat:@"%d", [SNUtility marketID]] forKey:@"h"];
    
    return dic;

}

- (id)jsInterface_getAppInfo:(JsKitClient*)client
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [dic setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey] forKey:@"version"];
    [dic setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleBuild] forKey:@"buildVersion"];
    [dic setObject:[NSNumber numberWithInteger:1000 * 1000 * 500] forKey:@"cachedSize"];
    [dic setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:@"appName"];
    [dic setObject:[NSString stringWithFormat:@"%d", [SNUtility marketID]] forKey:kCanalsKey];
    [dic setObject:[SNAPI productId] forKey:kProductIDKey];
    return dic;
}

- (id)jsInterface_clearCachedData:(JsKitClient*)client
{
    return nil;
}

- (id)jsInterface_getCacheSize:(JsKitClient*)client
{
    return nil;
}

- (id)jsInterface_md5:(JsKitClient*)client value:(NSString *)value
{
    return [value stringFromMD5];
}

- (id)jsInterface_getDebugInfo:(JsKitClient*)client
{
    NSMutableString* builder = [[NSMutableString alloc] initWithCapacity:1024];
    [builder appendString:@"<p>p1:"];
    [builder appendString:[SNUserManager getP1]];
    [builder appendString:@"<p>"];
    [builder appendString:@"<br/>webapps:<br/><table><tr><th>webapp名</th><th>默认版本</th><th>当前版本</th></tr>"];
    JKWebAppManager* webAppManager = [JKWebAppManager manager];
    NSArray* webAppNames = [webAppManager getAllWebAppNames];
    for (NSString* webAppName in webAppNames) {
        JKWebApp* webApp = [webAppManager getWebAppWithName:webAppName];
        [builder appendString:@"<tr><td>"];
        [builder appendString:webAppName];
        [builder appendString:@"</td><td>"];
        [builder appendFormat:@"%d",webApp.buildInAppInfo.versionCode];
        [builder appendString:@"("];
        [builder appendString:[[NSDate dateWithTimeIntervalSince1970:(webApp.buildInAppInfo.buildTime/1000)] description]];
        [builder appendString:@")</td><td>"];
        [builder appendFormat:@"%d", webApp.currentVersion];
        [builder appendString:@"("];
        [builder appendString:[[NSDate dateWithTimeIntervalSince1970:(webApp.installedAppInfo.buildTime/1000)] description]];
        [builder appendString:@")</td></tr>"];
    }
    [builder appendString:@"</table>"];
    [builder appendString:@"<a href='https://api.k.sohu.com/h5apps/videoTest.html'>视频测试地址</a>\
     <p>长安文字可选择复制</p>\
     <a href='javascript:commonApi.enableH5Debug();'>点击"];
    [builder appendString:[JKGlobalSettings defaultSettings].debugMode?@"关闭":@"开启"];
    [builder appendString:@"H5调试</a>"];
    return builder;
}

-(void)jsInterface_enableH5Debug:(JsKitClient*)client{
    dispatch_async(dispatch_get_main_queue(), ^{
        [JKGlobalSettings defaultSettings].debugMode = ![JKGlobalSettings defaultSettings].debugMode;
        [[SNCenterToast shareInstance] showCenterToastWithTitle:[JKGlobalSettings defaultSettings].debugMode?@"开启H5调试":@"关闭H5调试" toUrl:nil mode:SNCenterToastModeSuccess];
        [client.webView reload];
    });
}

- (id)jsInterface_getPackageInfo:(JsKitClient*)client appName:(NSString *)appName
{
    if ([appName isEqualToString:@"com.sohu.sohuvideo"]) {
        appName = @"sohuvideo://";
    }

    BOOL ret = [SNUtility isWhiteListURL:[NSURL URLWithString:appName]];
    return [NSNumber numberWithBool:ret];
}

- (id)jsInterface_downloadFile:(JsKitClient*)client url:(NSString *)url
{
    return nil;
}

- (void)jsInterfaceWithCallback_ajax:(JsKitClient*)client url:(NSString *)url option:(NSDictionary*)opt callback:(JKJsFunction*)callback
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

- (id)jsInterface_isSubInfo:(JsKitClient *)client subId:(NSString *)subId
{
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:subId];
    if (subObj && [subObj.isSubscribed isEqualToString:@"1"]) {
        return [NSNumber numberWithBool:YES];
    } else {
        return [NSNumber numberWithBool:NO];
    }
}

- (void)jsInterface_changeSubInfo:(JsKitClient *)client jsonStr:(id)jsonStr isSub:(id)isSub
{
    if (isSub) {
        BOOL isSubscribe = YES;
        if ([isSub isKindOfClass:[NSNumber class]]) {
            isSubscribe = [isSub boolValue];
        } else if ([isSub isKindOfClass:[NSString class]] && ((NSString *)isSub).length > 0) {
            isSubscribe = [(NSString *)isSub isEqualToString:@"1"] ? YES : NO;
        }
        if (isSubscribe) {
            if (jsonStr) {
                NSDictionary *dict = (NSDictionary *)jsonStr;
                [[SNSubscribeCenterService defaultService] h5NewsAddMySubscribe:jsonStr];
            }
        } else {
            if ([jsonStr isKindOfClass:[NSString class]] && ((NSString *)jsonStr).length > 0) {
                [[SNSubscribeCenterService defaultService] h5NewsRemoveMySubscribeSubId:(NSString *)jsonStr];
            }
        }
    }
}

- (void)jsInterface_zoomImage:(JsKitClient *)client imageUrl:(NSString *)imageUrl title:(NSString *)title x:(NSNumber *)x y:(NSNumber *)y
{
//    if (self.universalWebController && [self.universalWebController respondsToSelector:@selector(clickImage:title:point:)]) {
//        [self.universalWebController clickImage:imageUrl title:title point:CGPointMake(x.floatValue, y.floatValue)];
//    }
//    if (self.delegate && [self.delegate respondsToSelector:@selector(clickImage:title:point:)]) {
//        [self.delegate clickImage:imageUrl title:title point:CGPointMake(x.floatValue, y.floatValue)];
//    }
}


- (id)jsInterface_debugSwitchStatus:(JsKitClient*)client {
    NSString *switchKey = @"0";
    if ([SNUserDefaults stringForKey:SNH5DebugSwitchKey]) {
        switchKey = [SNUserDefaults stringForKey:SNH5DebugSwitchKey];
    }
    return [NSNumber numberWithBool:switchKey.integerValue];
}

//获取setting.go
- (id)jsInterface_getSettingInfo:(JsKitClient *)client {
    return [NSNumber numberWithBool:[SNRedPacketManager sharedInstance].showRedPacketTheme];
}

- (void)dealloc {
    self.delegate = nil;
}

@end
