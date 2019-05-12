//
//  SNSSOAdapter.m
//  sohunews
//
//  Created by wang yanchen on 13-2-20.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSSOAdapter.h"

static SNSSOAdapter *__instance;

@implementation SNSSOAdapter
@synthesize ssoClient = _ssoClient;

- (void)dealloc {
     //(_ssoClient);
}

+ (SNSSOAdapter *)shareAdapter {
    @synchronized(self) {
        if (nil == __instance) {
            __instance = [[SNSSOAdapter alloc] init];
        }
    }
    return __instance;
}

- (BOOL)isSupportForAppId:(NSString *)appId {
    if ([appId length] > 0) {
        NSString *selector = [NSString stringWithFormat:@"isSupportFor_%@", appId];
        SEL sel = NSSelectorFromString(selector);
        if ([self respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            BOOL ret = (BOOL)[self performSelector:sel];
#pragma clang diagnostic pop
            
#if DEBUG_MODE
            if (!ret) {
                SNDebugLog(@"~~########################  不支持 SSO ##################");
            }
#endif
            
            return ret;
        }
        
#if DEBUG_MODE
        else {
            SNDebugLog(@"~~########################  不支持 SSO ##################");
        }
#endif
        
    }
    return NO;
}

- (void)loginForAppId:(NSString *)appId {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ([appId length] > 0) {
        NSString *selector = [NSString stringWithFormat:@"loginFor_%@", appId];
        SEL sel = NSSelectorFromString(selector);
        if ([self respondsToSelector:sel]) {
            [self performSelector:sel];
            if (_ssoClient) {
                _ssoClient.appId = appId;
            }
        }
        
#if DEBUG_MODE
        else {
            SNDebugLog(@"~~########################  不支持 SSO ##################");
        }
#endif
    }
#pragma clang diagnostic pop
}

+ (BOOL)handleOpenUrl:(NSURL *)url {
    if (__instance && __instance.ssoClient) {
        return [__instance.ssoClient handleOpenUrl:url];
    }
    return NO;
}

+ (void)handleApplicationDidBecomeActive {
    if (__instance && __instance.ssoClient) {
        [__instance.ssoClient handleApplicationDidBecomeActive];
    }
}

#pragma mark - SNSSOWrapperDelegate
- (void)ssoDidLogin:(SNSSOWrapper *)wrapper {
    [[SNShareManager defaultManager] syncToken:wrapper.accessToken
                                  refreshToken:wrapper.refreshToken
                                        expire:wrapper.expirationDate
                                      userName:wrapper.userName
                                        userId:wrapper.userId
                                         appId:wrapper.appId];
}

- (void)ssoDidCancelLogin:(SNSSOWrapper *)wrapper {
    SNDebugLog(@"%@->%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    [SNNotificationManager postNotificationName:kSSOLoginDidCancelOrFailNotification object:nil];
}

- (void)ssoDidFailLogin:(SNSSOWrapper *)wrapper {
    SNDebugLog(@"%@->%@ : error %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), wrapper.lastErrorMessage);
    [SNNotificationManager postNotificationName:kSSOLoginDidCancelOrFailNotification object:nil];
}

@end
