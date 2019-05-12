//
//  JKAuthUtils.m
//  sohunews
//
//  Created by sevenshal on 16/3/17.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "JKAuthUtils.h"
#import "JKGlobalSettings.h"

@implementation JKAuthUtils

+(BOOL)checkWebAppAuth:(NSURL*)url{
    BOOL auth = url!=nil && ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])
    && url.host !=nil && ([url.host hasSuffix:@".k.sohu.com"] || [url.host isEqualToString:@"k.sohu.com"]
                              ||[url.host hasSuffix:@".w.sohu.com"] || [url.host isEqualToString:@"w.sohu.com"]
                              ||[url.host hasSuffix:@".m.sohu.com"] || [url.host isEqualToString:@"m.sohu.com"]
                              ||[url.host hasSuffix:@".stock.sohu.com"] || [url.host isEqualToString:@"stock.sohu.com"]);
    if (auth) {
        return YES;
    }
    id<JKAuthDelegate> delegate = [JKGlobalSettings defaultSettings].authDelegate;
    if (delegate!=nil && [delegate respondsToSelector:@selector(shouldUrlUseJsKit:)]) {
        return [delegate shouldUrlUseJsKit:url];
    }
    return auth;
}

@end
