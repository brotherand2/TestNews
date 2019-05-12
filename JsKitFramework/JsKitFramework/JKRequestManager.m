//
//  JKRequestManager.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/23.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import "JKRequestManager.h"
#import "JsKitFramework.h"

#import "JKReachability.h"

#import "Define.h"

#define SDK_BASE_URL kBaseURL

//int netType,
//String deviceId, int sdkVer, String pkg, JSONArray array,
@implementation JKRequestManager{
    AFHTTPRequestOperationManager* httpRequestManager;
    JKReachability* reach;
}

+(JKRequestManager*)manager{
    static JKRequestManager* manager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        manager = [[JKRequestManager alloc] init];
    });
    return manager;
}

-(instancetype)init{
    if (self=[super init]) {
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        [AFHTTPRequestOperationManager manager].securityPolicy = securityPolicy;
        httpRequestManager = [AFHTTPRequestOperationManager manager];
        httpRequestManager.securityPolicy = securityPolicy;
        reach = [JKReachability reachabilityForInternetConnection];
    }
    return self;
}

-(void)REQUEST:(BOOL)GET URL:(NSString*)URL parameters:(id)parameters success:(void (^)(id data))success
       failure:(void (^)(NSError *error))failure{
    void (^successHandler)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    };
    void (^faliureHandler)(AFHTTPRequestOperation *operation, NSError *error) = ^(AFHTTPRequestOperation *operation, NSError *error) {
//        JSLog(@"Error: %@", error);
        failure(error);
    };
    if (GET) {
        [httpRequestManager GET:URL parameters:parameters success:successHandler failure:faliureHandler];
    }else{
        [httpRequestManager POST:URL parameters:parameters success:successHandler failure:faliureHandler];
    }
    
}

-(void)GET:(NSString*)URL parameters:(id)parameters success:(void (^)(id data))success
   failure:(void (^)(NSError *error))failure{
    [self REQUEST:YES URL:URL parameters:parameters success:success failure:failure];
}

-(void)POST:(NSString*)URL parameters:(id)parameters success:(void (^)(id data))success
    failure:(void (^)(NSError *error))failure{
    [self REQUEST:NO URL:URL parameters:parameters success:success failure:failure];
}

-(void)getUpgradeInfo:(NSString* _Nonnull)deviceId sdkVer:(NSInteger)sdkVer hostAppName:(NSString* _Nonnull)hostAppName hostVer:(id)hostVer pluginInfos:(NSArray*_Nonnull)infos  success:(void (^)(id data))success
              failure:(void (^)(NSError *error))failure{
    JKNetworkStatus status = [reach currentReachabilityStatus];
    int net = 1;
    switch (status) {
        case JKNotReachable:{
            net = 0;
            break;
        }
        case JKReachableViaWiFi:{
            net = 1;
            break;
        }
        case JKReachableViaWWAN:{
            net = 2;
            break;
        }
        default:
            break;
    }
    id params = @{@"sid":deviceId,
                  @"sdkVer":@(sdkVer),
                  @"pkg":hostAppName,
                  @"hostVer":hostVer,
                  @"channel":[JKGlobalSettings defaultSettings].debugMode?@"ios_test":@"ios",
                  @"net":@(net),
                  @"plugins":[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:infos options:kNilOptions error:nil] encoding:NSUTF8StringEncoding]};
//    [self GET:@"http://10.13.94.193:8090/api/client/sdkupgrade.go?" parameters:params success:success failure:failure];
    [self GET:SDK_BASE_URL"/api/client/sdkupgrade.go?" parameters:params success:success failure:failure];
}

@end
