//
//  UCPostLog.m
//  H5GameClient
//
//  Created by zihong on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UCPostLog.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"
#import "SNCrashRequest.h"

#include <libkern/OSAtomic.h>
#include <execinfo.h>

#define CRASH_PATH @"crash.log"

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;
static UCPostLog* sharePostLog = nil;

@implementation UCPostLog

+ (UCPostLog*) sharedInstance
{
    static UCPostLog *logInstance;
    static dispatch_once_t dispatch;
    
    dispatch_once(&dispatch, ^(){
        logInstance = [[UCPostLog alloc] init];
    });
    
    return logInstance;
}

+ (UCPostLog*) sharePostLog
{
    @synchronized(self)
    {
        if (sharePostLog == nil) 
        {
            sharePostLog = [[self alloc] init] ;
            [sharePostLog release];;
        }
    }
    return sharePostLog;
}

+(id) allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharePostLog == nil) 
        {
            sharePostLog = [super allocWithZone:zone];
            return sharePostLog;
        } 
    }
    return nil;
    
}

+(NSString*)getCrashLogPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    return [path stringByAppendingPathComponent:CRASH_PATH];
}

+ (NSString *)getThirdCrashLogPath {//由于引用的第三方库，使用了NSSetUncaughtExceptionHandler,会拦截部分crash
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingString:@"/LX_richinfo/logs"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileArray = [fileManager contentsOfDirectoryAtPath:path error:nil];
    if ([fileArray count] > 0) {
        path = [NSString stringWithFormat:@"%@/%@", path, [fileArray objectAtIndex:0]];
    }
    else {
        return nil;
    }

    return path;
}

+ (void)postThirdLog {
    NSString *path = [self getThirdCrashLogPath];
    if (!path) {
        return;
    }
    NSString *encodeCrashLog = [[[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil] autorelease];
    NSString *decodeCrashLog = [encodeCrashLog URLDecodedString];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[decodeCrashLog componentsSeparatedByString:@"\n"]];
    if ([array indexOfObject:@"callStackSymbols:"] == NSNotFound) {
        return;
    }
    NSInteger index = [array indexOfObject:@"callStackSymbols:"];
    if (index < [array count]) {
        [array removeObjectsInRange:NSMakeRange(0, index+1)];
    }
    if ([array count] > 3) {
        [array removeLastObject];
        [array removeLastObject];
        [array removeLastObject];
    }
    
    NSString *encodeString = [self getCrashString:array reason:nil];

    
    [self postLogRequestWithParams:nil andCrashLog:encodeString];
}

+(void)postLog
{
    [UCPostLog postCrashLog];
}

+(void)postCrashLog
{
    NSString* crashLog = [[[NSString alloc]initWithContentsOfFile:[self getCrashLogPath] encoding:NSUTF8StringEncoding error:nil] autorelease];
    
    if(crashLog && crashLog.length>0)
    {
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
        [params setValue:[SNUserManager getP1] forKey:@"p1"];
        [params setValue:[SNAPI productId] forKey:@"u"];
        [params setValue:[NSString stringWithFormat:@"%zd",APIVersion] forKey:@"apiVersion"];
        [self postLogRequestWithParams:params andCrashLog:crashLog];
    }
    else {
        [self postThirdLog];
    }
}

+ (void)postLogRequestWithParams:(NSDictionary *)params andCrashLog:(NSString *)crashLog {
    
    [[[SNCrashRequest alloc] initWithDictionary:params andCrashLog:crashLog] send:^(NSURLRequest *request, id responseObject) {
        SNDebugLog(@"%@",responseObject);
        [[NSFileManager defaultManager] removeItemAtPath:[UCPostLog getCrashLogPath] error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[UCPostLog getThirdCrashLogPath] error:nil];
    } failure:^(NSURLRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
    }];
}


+ (NSString *)getCrashString:(NSArray *)stackArray reason:(NSString *)reason {
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleVersionKey];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleBuild];
    UIDevice *device = [UIDevice currentDevice];
    
    NSMutableDictionary *dicDevice = [NSMutableDictionary dictionary];
    if ([SNUserManager getP1] != nil) {
        [dicDevice setObject:[SNUserManager getP1] forKey:@"p1"];
    }
    if ([SNAPI productId] == nil) {
        [dicDevice setObject:@"1" forKey:@"uid"];
    }
    else{
        [dicDevice setObject:[SNAPI productId] forKey:@"uid"];
    }
    [dicDevice setObject:@"IOS" forKey:@"platform"];
    [dicDevice setObject:version forKey:@"version"];
    [dicDevice setObject:build forKey:@"build"];
    [dicDevice setObject:device.platformForSohuNews forKey:@"machineId"];
    [dicDevice setObject:[[UIDevice currentDevice] systemVersion] forKey:@"platformVersion"];
    [dicDevice setObject:device.screenSizeStringForSohuNews forKey:@"ssize"];
    [dicDevice setObject:device.screenSizeStringForSohuNews forKey:@"screenResolutio"];
    NSString *ramStr = [NSString stringWithFormat:@"%0.2fGB", device.totalMemory/(1024.0*1024*1024)];
    [dicDevice setObject:ramStr forKey:@"ram"];
    NSString *romStr = [NSString stringWithFormat:@"%0.2fGB", [UIDevice getTotalDiskSpaceBySDK]/1024.0];
    [dicDevice setObject:romStr forKey:@"rom"];
    NSString *cpuStr = [NSString stringWithFormat:@"%@_%lu", [device getCPUType], (unsigned long)[device cpuCount]];
    [dicDevice setObject:cpuStr forKey:@"cpu"];
    NSString *date = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    date = [date stringByAppendingString:@"000"];//服务端让末尾加3个0
    [dicDevice setObject:date forKey:@"ctime"];
    NSString *reachStatus = [[SNUtility getApplicationDelegate] currentNetworkStatusString];
    if (reachStatus == nil ) {
        reachStatus = @"";
    }
    [dicDevice setObject:reachStatus forKey:@"net"];
    [dicDevice setObject:[[UIDevice currentDevice] systemVersion] forKey:@"ui"];
    
    NSMutableDictionary *exceptionDic = [NSMutableDictionary dictionary];
    NSMutableArray *noAddressArray = [[[NSMutableArray alloc] init] autorelease];
    for (NSString * str in stackArray) {//删除栈中的地址
        NSRange range = [str rangeOfString:@"0x"];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 9.0) {
            range = NSMakeRange(range.location, range.length + 8);//因为是32进制
        }
        else {
            range = NSMakeRange(range.location, range.length + 16);//因为是32进制
        }
        
        str = [str stringByReplacingCharactersInRange:range withString:@""];
        [noAddressArray addObject:str];
    }
    
    if (reason && [noAddressArray count] > 0) {
        [noAddressArray insertObject:reason atIndex:0];
    }
    
    NSString *callStack = [noAddressArray componentsJoinedByString:@"\n"];
    [exceptionDic setObject:callStack forKey:@"stack"];
    [exceptionDic setObject:[callStack md5Hash] forKey:@"stackMd5"];
    
    NSDictionary *stackDic = [NSDictionary dictionaryWithObjectsAndKeys:exceptionDic, @"crashInfo", dicDevice, @"crashContext",nil];
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:stackDic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *crashJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *encodeCrashString = [NSString stringWithFormat:@"crash=%@", [crashJson URLEncodedString]];
    [crashJson autorelease];
    
    return encodeCrashString;
}

void registerExceptionHandler () {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    signal(SIGHUP, SignalHandler);
    signal(SIGINT, SignalHandler);
    signal(SIGQUIT, SignalHandler);
//    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}

void uncaughtExceptionHandler(NSException *exception) {
    NSString *str = [UCPostLog getCrashString:[exception callStackSymbols] reason:exception.reason];
    [str writeToFile:[UCPostLog getCrashLogPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

void SignalHandler(int signal) {
    NSArray *callStack = [UCPostLog backtrace];
    NSString *str = [UCPostLog getCrashString:callStack reason:nil];
    [str writeToFile:[UCPostLog getCrashLogPath] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

+ (NSArray *)backtrace {
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int i = UncaughtExceptionHandlerSkipAddressCount; i < UncaughtExceptionHandlerSkipAddressCount + UncaughtExceptionHandlerReportAddressCount; i++) {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    
    free(strs);
    
    return backtrace;
}

@end
