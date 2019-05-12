//
//  SNUserSettingRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUserSettingRequest.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"

@interface SNUserSettingRequest ()

@property (nonatomic, assign) SNUserSettingModeType userSettingModeType;

@end

@implementation SNUserSettingRequest

- (instancetype)initWithUserSettingMode:(SNUserSettingModeType)userSettingModeType andModeString:(NSString *)modeString
{
    self = [super init];
    if (self) {
        self.userSettingModeType = userSettingModeType;
        NSString *paramValue = nil;
        switch (userSettingModeType) {
            case SNUserSettingFontMode:
                paramValue = @"font";
                break;
            case SNUserSettingImageMode:
                paramValue = @"image";
                break;
            case SNUserSettingVideoMode:
                paramValue = @"video";
                break;
            case SNUserSettingNewsPushMode:
                paramValue = @"newsPush";
                break;
            case SNUserSettingDayMode:
                paramValue = @"dayMode";
                break;
            case SNUserSettingActionBarMode:
                paramValue = @"hide";
                break;
            case SNUserSettingMiniVideoMode:
                paramValue = @"videoMiniMode";
                break;
            case SNUserSettingLocationMode:
                paramValue = @"setUserLocation";
                break;
            case SNUserSettingHousePropLocationMode:
                paramValue = @"setHousePropLocation";
                break;
            case SNUserSettingThemeNight:
                paramValue = @"smartSwitchForNightMode";
                break;
            case SNUserSettingNovelPushMode:
                paramValue = @"readerPush";
                break;
            case SNUserSettingMediaPushMode:
                paramValue = @"paperPush";
                break;
            case SNUserSettingGetMode:
                break;
        }
        if (userSettingModeType != SNUserSettingGetMode) { // 获取用户设置
            [self.parametersDict setObject:paramValue forKey:@"m"];
        
            if (userSettingModeType != SNUserSettingLocationMode && userSettingModeType != SNUserSettingHousePropLocationMode) {
                if (modeString.length > 0) {
                    if (userSettingModeType == SNUserSettingNovelPushMode) {
                        [self.parametersDict setValue:modeString forKey:@"value"];
                    } else {
                        [self.parametersDict setObject:modeString forKey:paramValue];
                    }
                }
            } else { // 获取位置信息
                [self.parametersDict setObject:modeString forKey:@"gbcode"];
            }
        }
        
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeJSON;
}

- (NSString *)sn_baseUrl {
    return [SNAPI baseUrlWithDomain:SNLinks_Domain_BaseApiK];
}

- (NSString *)sn_requestUrl {
    
    if (self.userSettingModeType == SNUserSettingGetMode) {
        return SNLinks_Path_User_GetSet;
    } else {
        return SNLinks_Path_User_SaveSet;
    }
}


- (id)sn_parameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10]; // 默认参数
    NSString *pid = [SNUserManager getPid];
    [params setValue:[SNUserManager getP1] forKey:@"p1"];
    [params setValue:[SNUserManager getUserId] forKey:@"userId"];
    [params setValue:pid?pid:@"-1" forKey:@"pid"];
    [params setValue:[NSString stringWithFormat:@"%d", APIVersion] forKey:@"apiVersion"];
    [params setValue:[SNClientRegister sharedInstance].sid forKey:@"sid"];
    [params setValue:[SNAPI productId] forKey:@"u"];
    [params setValue:[SNAPI encodedBundleID] forKey:@"bid"];
    [params setValue:[SNUserManager getToken] forKey:@"token"];
    [params setValue:[SNUserManager getGid] forKey:@"gid"];
    if (self.parametersDict.count > 0) {
        [params setValuesForKeysWithDictionary:self.parametersDict]; // 外部可变参数拼接
    }
    return params;
}

@end
