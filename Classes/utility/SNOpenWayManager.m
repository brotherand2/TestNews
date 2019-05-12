
//
//  SNOpenWayManager.m
//  sohunews
//
//  Created by wangyy on 15/5/4.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNOpenWayManager.h"
#import "SNPickStatisticRequest.h"


@implementation SNOpenWayManager

@synthesize hotstart = _hotstart;

+ (SNOpenWayManager *)sharedInstance {
    static SNOpenWayManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SNOpenWayManager alloc] init];
    });
    return sharedInstance;
}


- (NSString *)getParamValueForm:(NSString *)string
                         forKey:(NSString *)key {
    if (string == nil) {
        return @"";
    }
    
    string = [string lowercaseString];
    key = [key lowercaseString];
    NSRange range = [string rangeOfString:key];
    if (range.location != NSNotFound) {
        NSString *subStr = [string substringFromIndex:range.location + key.length + 1];//去除＝号
        NSRange range2 = [subStr rangeOfString:@"&"];//newsid=%@&
        if (range2.location != NSNotFound) {
            return [subStr substringToIndex:range2.location];
        } else {//newsid=%@
            return subStr;
        }
    }
    
    return @"";
}


- (void)analysisAndPostURL:(NSString *)urlString from:(NSString *)fromType openOrigin:(NSString *)openOrigin {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:20];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleVersionKey];
    UIDevice *device = [UIDevice currentDevice];
    [params setValue:version forKey:@"Version"];
    [params setValue:device.platformForSohuNews forKey:@"MachineId"];
    [params setValue:device.screenSizeStringForSohuNews forKey:@"Resolution"];
    [params setValue:device.screenSizeStringForSohuNews forKey:@"ssize"];
    [params setValue:[NSString stringWithFormat:@"%0.2fGB",device.totalMemory / (1024.0 * 1024.0 * 1024.0)] forKey:@"ram"];
    [params setValue:[NSString stringWithFormat:@"%0.2fGB",[UIDevice getTotalDiskSpaceBySDK] / 1024.0] forKey:@"rom"];
    [params setValue:[NSString stringWithFormat:@"%@_%@",[device getCPUType],[NSNumber numberWithInteger:[device cpuCount]]] forKey:@"cpu"];
    [params setValue:[[UIDevice currentDevice] systemVersion] forKey:@"ui"];
    [params setValue:@"start" forKey:@"act"];
    
    if (openOrigin != nil) {
        [params setValue:openOrigin forKey:@"startfrom"];
    }
    else{
        [params setValue:kOther forKey:@"startfrom"];
    }
    NSNumber *numberTime = [NSNumber numberWithInt:[SNOpenWayManager getAppLeaveTime]];
    if (numberTime.intValue == 0) {
        return;//不可能出现时差为0的上报，避免H5回调上报2次
    }
    [params setValue:numberTime forKey:@"leavetime"];
    [params setValue:[NSNumber numberWithBool:[[self class] sharedInstance].hotstart] forKey:@"process"];
    
    if (fromType != nil) {
        [params setValue:fromType forKey:@"tp"];
        if (urlString.length > 0) {
            [params setValue:[self getParamValueForm:urlString forKey:@"newsid"] forKey:@"newsid"];
            [params setValue:[self getParamValueForm:urlString forKey:@"newstype"] forKey:@"newstype"];
            [params setValue:[self getParamValueForm:urlString forKey:@"channelid"] forKey:@"channelid"];
            [params setValue:[self getParamValueForm:urlString forKey:@"subid"] forKey:@"subid"];
            [params setValue:[self getParamValueForm:urlString forKey:@"termid"] forKey:@"termid"];
            [params setValue:[self getParamValueForm:urlString forKey:@"objReferSite"] forKey:@"objReferSite"];
            [params setValue:[self getParamValueForm:urlString forKey:@"refererUrl"] forKey:@"refererUrl"];
        }

    } else {
        if (urlString != nil || [urlString length] != 0) {
            [params setValuesForKeysWithDictionary:[NSString getURLParas:urlString]];
        }
    }
    [self postRequest:params];
}

- (void)postRequest:(NSDictionary *)params {
    
    [[[SNPickStatisticRequest alloc] initWithDictionary:params andStatisticType:PickLinkDotGifTypeA] send:nil failure:nil];
    
    [SNUtility missingCheckReportWithUrl:[SNAPI aDotGifUrlWithParameters:[params toUrlString]]];
}

#define kOpenWayAppLeaveTime   @"kOpenWayAppLeaveTime"
+ (void)setAppLeaveTime:(NSDate *)leaveTime{
    [SNUserDefaults setObject:leaveTime forKey:kOpenWayAppLeaveTime];
}

+ (NSTimeInterval)getAppLeaveTime{
    NSDate *leaveDate = [SNUserDefaults objectForKey:kOpenWayAppLeaveTime];
    if (leaveDate == nil) {
        return 0;
    }
    
    NSDate *nowDate = [NSDate date];
    NSTimeInterval secondsInterval = [nowDate timeIntervalSinceDate:leaveDate];
    [SNUserDefaults removeObjectForKey:kOpenWayAppLeaveTime];
    return secondsInterval*1000;
}

@end
