//
//  SNNewsPPLoginHeader.m
//  sohunews
//
//  Created by wang shun on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginHeader.h"

#import "Reachability.h"
#import "SNUserLocationManager.h"

#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginEnvironment.h"

@implementation SNNewsPPLoginHeader

+ (NSMutableDictionary*)getPPBaseParams{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    //appid 应用ID，需和Header：PP-APPID 一致。
    [dic setObject:SNNewsPPLogin_APPID forKey:@"appid"];
    
    //vs 应用版本号，需和Header：PP-VS一致。
    NSString* appVerison = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [dic setObject:appVerison?:@"" forKey:@"vs"];
    
    //时间戳 单位：ms
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString* timestamp = [NSString stringWithFormat:@"%0.f",interval* 1000];
    [dic setObject:timestamp?:@"" forKey:@"timestamp"];
    
    //nonce 本次请求唯一标识，取32B UUID，每次刷新，保证唯一
    NSString* nonce = [SNNewsPPLoginHeader createUUID];
    [dic setObject:nonce?:@"" forKey:@"nonce"];
    
    /*********************************************************************/
    //签名 本次请求的签名，所有参数参与签名，签名方式为MD5（结果用小写十六进制表示），签名KEY和APPID由通行证提供
    //签名 放在外层了, 因所有参数都要参与签名 wangshun
//    NSString* sig = [SNNewsPPLoginHeader getSig:dic];
//    [dic setObject:sig forKey:@"sig"];
    /*********************************************************************/
    
    SNDebugLog(@"PP baseParams::%@",dic);
    return dic;
}

+ (NSMutableDictionary *)getPPHeader{
    NSMutableDictionary* dic = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    /*****************************************************************************/
    /*必传项*/
    
    /*
     wangshun 2017.10.27
     
     iPhone主线：110607
     iPhone简版：?
     */
    [dic setObject:SNNewsPPLogin_APPID forKey:@"PP-APPID"];
    
    //GID 设备唯一标识
    NSString* gid = [[NSUserDefaults standardUserDefaults] objectForKey:SNNewsLogin_PP_GID];
    if (gid && gid.length>0) {
        [dic setObject:gid?:@"" forKey:@"PP-GID"];
    }
    
    //设备操作系统 如：iOS 9.1、Android 6.0.1，格式：系统名称（iOS/Android） + 空格 + 版本号
    NSString* iosVersion = [NSString stringWithFormat:@"iOS %0.2f",[SNNewsPPLoginHeader getIOSVersion]];
    [dic setObject:iosVersion forKey:@"PP-OS"];
  
    //设备类型
    NSString* dv = [SNNewsPPLoginHeader getDV];
    [dic setObject:dv?:@"" forKey:@"PP-DV"];
    
    //客户端版本号
    NSString* appVerison = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [dic setObject:appVerison forKey:@"PP-VS"];
    
    //设备浏览器UA 获取系统浏览器的UA属性，禁止使用HTTP Client工具UA属性
    NSString* ua = [SNNewsPPLoginHeader getUA];
    [dic setObject:ua?:@"" forKey:@"PP-UA"];
    
    //设备屏幕像素高宽比 如：480.000000,320.000000，以逗号分割
    NSString* width = [SNNewsPPLoginHeader getScreenWidth];
    NSString* height = [SNNewsPPLoginHeader getScreenHeight];
    NSString* str = [NSString stringWithFormat:@"%@,%@",width,height];
    [dic setObject:str forKey:@"PP-HW"];
    
    NSString* idfa = [SNNewsPPLoginHeader getIDFA];
    //IDFA
    [dic setObject:idfa?:@"" forKey:@"PP-IDFA"];
    
    /*****************************************************************************/
    
    //设备MAC
    NSString *macAddress = [SNNewsPPLoginHeader getMac];
    [dic setObject:macAddress forKey:@"PP-MAC"];
    
    //经纬度
    NSString* longitude = [SNNewsPPLoginHeader getLongitude];
    [dic setObject:longitude?:@"" forKey:@"PP-LOT"];//经度
    NSString* latitude = [SNNewsPPLoginHeader getLatitude];
    [dic setObject:latitude?:@"" forKey:@"PP-LAT"];//纬度
    
    //IP
    NSString *ipAddress = [SNNewsPPLoginHeader getIPAddress];
    [dic setObject:ipAddress forKey:@"PP-IP"];
    
    //设备网络类型
    NSString* nw = [SNNewsPPLoginHeader getCurrentNetworkStatusString];
    [dic setObject:nw?:@"" forKey:@"PP-NW"];
    
    /*****************************************************************************/
    
    SNDebugLog(@"PP Header:%@",dic);
    return dic;
}

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
+ (NSString*)getIPAddress{
    return [UIDevice ipAddress];
}
+ (NSString*)getMac{
    return [[UIDevice currentDevice] macAddress];
}

+ (float)getIOSVersion{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+ (NSString*)getScreenWidth{
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    CGSize size_screen = rect_screen.size;
    
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    
    CGFloat width = size_screen.width*scale_screen;
    SNDebugLog(@"width:%f",width);
    return [NSString stringWithFormat:@"%f",width];
}

+ (NSString*)getScreenHeight{
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    CGSize size_screen = rect_screen.size;
    
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    
    CGFloat height = size_screen.height*scale_screen;
    SNDebugLog(@"height:%f",height);
    return [NSString stringWithFormat:@"%f",height];
}

+ (NSString*)getIDFA{
    //00000000-0000-0000-0000-000000000000 代表限制广告标识 iOS 10
#if TARGET_IPHONE_SIMULATOR
    NSString *IDFA = @"20834213-0F5F-4631-83F2-3A4E2C47F688";
#else
    NSString *IDFA = [UIDevice deviceIDFA];
#endif
    return IDFA;
}

+ (NSString *)getCurrentNetworkStatusString {
    NSString *stateString = @"";
    /* NetworkStatus
     NotReachable = 0,
     ReachableViaWiFi,
     ReachableViaWWAN,
     ReachableVia2G,
     ReachableVia3G,
     ReachableVia4G
     */
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    switch (netStatus) {
        case NotReachable:
            stateString = @"";
            break;
        case ReachableViaWiFi:
            stateString = @"WiFi";
            break;
        case ReachableViaWWAN:
            stateString = @"WWAN";
            break;
        case ReachableVia2G:
            stateString = @"2G";
            break;
        case ReachableVia3G:
            stateString = @"3G";
            break;
        case ReachableVia4G:
            stateString = @"4G";
            break;
        default:
            break;
    }
    return stateString;
}

//经度
+ (NSString*)getLongitude{
    return [[SNUserLocationManager sharedInstance] getLongitude];
}

//纬度
+ (NSString*)getLatitude{
    return [[SNUserLocationManager sharedInstance] getLatitude];
}

//纬度
+ (NSString*)getDV{
    NSString* dv = @"iPhone";
    
#if TARGET_IPHONE_SIMULATOR
    dv = @"iPhone Simulator";
#else
    dv = @"iPhone";
#endif
    return dv;
}

+ (NSString*)getUA{
//    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
//    NSString* ua = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    return [SNNewsPPLogin getUA];
}

+ (NSString*)getSig:(NSDictionary*)dic{
    
    NSArray* allKeys = [dic allKeys];
    
    NSArray *result = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        //SNDebugLog(@"%@~%@",obj1,obj2); //3~4 2~1 3~1 3~2
        
        return [obj1 compare:obj2]; //升序
    }];
    
    SNDebugLog(@"result:%@",result);
    
    NSString* sig = @"";
    for (int i = 0; i < result.count; i++) {
        NSString* each_key = [result objectAtIndex:i];
        NSString* value = [dic objectForKey:each_key];
        sig  = [sig stringByAppendingFormat:@"%@=%@",each_key,value?:@""];
        
        if (i != allKeys.count-1) {
            sig  = [sig stringByAppendingFormat:@"&"];
        }
    }
//    NSString* md5_str = [SNNewsPPLogin_APPKEY md5Hash];
    
    NSString* appkey = [SNNewsPPLoginEnvironment getAPPKey];
    sig = [sig stringByAppendingString:appkey];
    NSString* md5_str = [sig md5Hash];
    return md5_str;
}


+ (NSString *)createUUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    
    // If needed, here is how to get a representation in bytes, returned as a structure
    // typedef struct {
    //   UInt8 byte0;
    //   UInt8 byte1;
    //   ...
    //   UInt8 byte15;
    // } CFUUIDBytes;
    CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidObject);
    
    CFRelease(uuidObject);
    
    uuidStr = [uuidStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    return uuidStr;
}

/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////

@end
