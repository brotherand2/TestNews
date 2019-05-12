//
//  SNAnalytics.m
//  sohunews
//
//  Created by sohunews on 12-3-20.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNAnalytics.h"
//#import "SNURLJSONResponse.h"
#import "SNUserLocationManager.h"
#import "SNUserManager.h"
//#import "AFNetworking.h"

static SNAnalytics *_sharedInstance = nil;

@interface SNAnalytics ()

@property(nonatomic, readonly) NSString *lastLoginReferArgumentsString;

@end

@implementation SNAnalytics
@synthesize lastLoginReferArgumentsString = _lastLoginReferArgumentsString;

- (id)init {
	if (_sharedInstance != nil) {
		[NSException raise:@"singletonClassError" format:@"不要直接初始化单例类 SNAnalytics."];
	} else if (self = [super init]) {
		_sharedInstance = self;
        _sharedInstance.channelRcs = [NSMutableDictionary dictionary];
    }
    return _sharedInstance;
}

- (void)dealloc {
}

+ (NSString *)loginLinkStringForLocationId:(NSString *)locationId {
    NSString *linkStr = nil;
    if (locationId.length > 0) {
        linkStr = [NSString stringWithFormat:@"login://locationId=%@", locationId];
    }
    return linkStr;
}

#pragma mark - common arguments
// 通用参数包括
// p1: client id hash
// p: platform - ios
// v: version
// u: 产品id  - 1

- (NSString *)configureUrlString:(NSString *)urlString {
    NSString *aConfiguredUrl = nil;
    if (urlString && [urlString isKindOfClass:[NSString class]]) {
        aConfiguredUrl = [NSString stringWithString:urlString];
        // p1
        if ([aConfiguredUrl rangeOfString:@"p1="].location == NSNotFound) {
            NSString *p1Str = [SNUtility getP1];
            
            if (p1Str.length) {
                if (NSNotFound == [aConfiguredUrl rangeOfString:@"?" options:NSCaseInsensitiveSearch].location) {
                    aConfiguredUrl = [aConfiguredUrl stringByAppendingFormat:@"?p1=%@", p1Str];
                }
                else {
                    aConfiguredUrl = [aConfiguredUrl stringByAppendingFormat:@"&p1=%@", p1Str];
                }
            }
        }
        
        // pid
        if([SNUserManager isLogin])
        {
            aConfiguredUrl = [aConfiguredUrl stringByAppendingFormat:@"&pid=%@", [SNUserManager getPid]];
        }
        else
        {
            aConfiguredUrl = [aConfiguredUrl stringByAppendingFormat:@"&pid=%@", @"-1"];
        }
        
        // p
        if ([aConfiguredUrl rangeOfString:@"p="].location == NSNotFound) {
            aConfiguredUrl = [aConfiguredUrl stringByAppendingString:@"&p=i"];
        }
        
        // u
        if ([aConfiguredUrl rangeOfString:@"u="].location == NSNotFound) {
            aConfiguredUrl = [aConfiguredUrl stringByAppendingFormat:@"&u=%@", [SNAPI productId]];
        }
        
        // v
        if ([aConfiguredUrl rangeOfString:@"v="].location == NSNotFound) {
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:kBundleVersionKey];
            if (![version length]) {
                version = @"other";
            }
            
            aConfiguredUrl = [aConfiguredUrl stringByAppendingFormat:@"&v=%@", version];
        }
        
        //net
        int marketId = [SNUtility marketID];
        NSString *reachStatus = [[SNUtility getApplicationDelegate] currentNetworkStatusString];
        if (reachStatus && ![reachStatus isEqualToString:@""]) {
            aConfiguredUrl = [aConfiguredUrl stringByAppendingFormat:@"&net=%@",reachStatus];
        }
        
        //market
        if (marketId > 0) {
            aConfiguredUrl = [aConfiguredUrl stringByAppendingFormat:@"&h=%d",marketId];
        }
        
        //经纬度
        SNUserLocationManager *locationManager = [SNUserLocationManager sharedInstance];
        NSString *locationString = [locationManager getNewsLocationString];
        if (locationString) {
            aConfiguredUrl = [aConfiguredUrl stringByAppendingFormat:@"&%@",locationString];
        }
        
    }
    return aConfiguredUrl;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark static methods
+ (SNAnalytics *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNAnalytics alloc] init];
    });
    return _sharedInstance;
}


- (void)appendLoginAnalyzeArgumnets:(SNReferFrom)refer referId:(NSString *)referId referAct:(SNReferAct)act {
    if (referId.length == 0) {
        referId = @"";
    }
    if (act > 0) {
        _lastLoginReferArgumentsString = [[NSString alloc] initWithFormat:@"%d&%@&%d", refer, referId, act];
    }
    else {
        _lastLoginReferArgumentsString = [[NSString alloc] initWithFormat:@"%d", refer];
    }
}

- (NSString *)configureLoginReferUrl:(NSString *)url {
    NSString *aConfiguredUrl = url;
    if (url) {
        if ([url rangeOfString:@"refer="].location == NSNotFound
            && self.lastLoginReferArgumentsString.length > 0) {
            aConfiguredUrl = [url stringByAppendingFormat:@"&refer=%@", self.lastLoginReferArgumentsString];
        }
    }
    return aConfiguredUrl;
}

- (NSDictionary *)addConfigureLoginReferParams {
    NSDictionary *param = [NSDictionary dictionary];
    if (self.lastLoginReferArgumentsString.length > 0) {
        param = @{@"refer":self.lastLoginReferArgumentsString};
    }
    return param;
}

@end
