//
//  SNPassportEnvironment.m
//  sohunews
//
//  Created by wang shun on 2017/10/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginEnvironment.h"
#import "SNNewsPPLogin.h"
#import "SNNewsPPLoginAppKey.h"

@implementation SNNewsPPLoginEnvironment

+ (NSString*)domain{
    
    if ([SNPreference sharedInstance].testModeEnabled) {
        return Test_Passport_API;
    }
    else{
        return Online_Passport_API;
    }
    
    return Online_Passport_API;
}

+ (NSString*)getAPPKey{
    
    if ([[SNNewsPPLoginEnvironment domain] isEqualToString:Test_Passport_API]) {//如果是测试环境
        return [SNNewsPPLoginAppKey AppKey:@"test"];
    }
    else if ([[SNNewsPPLoginEnvironment domain] isEqualToString:Online_Passport_API]) {//如果是线上环境
        return [SNNewsPPLoginAppKey AppKey:@"online"];
    }
    
    return SNNewsPPLogin_APPKEY_Online;
}

+ (BOOL)isPPLogin{
    if ([[[SNAppConfigManager sharedInstance] config].ppLoginOpen isEqualToString:@"1"]) {
        SNDebugLog(@"wangshun ppLoginOpen");
        return YES;
    }
    else{
        SNDebugLog(@"wangshun newsLoginOpen");
    }
    return NO;
}

@end
