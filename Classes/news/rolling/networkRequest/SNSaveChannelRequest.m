//
//  SNSaveChannelRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSaveChannelRequest.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"
#import "SNUserLocationManager.h"

@implementation SNSaveChannelRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    
    return SNLinks_Path_Channel_SaveChannel;
}

- (id)sn_parameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10]; // 默认参数
    NSString *localChannelId = [SNUserLocationManager sharedInstance].localChannelId;
    [params setObject:(localChannelId.length > 0 ? localChannelId:@"0") forKey:@"local"];
    NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    if (cid.length > 0) {
        [params setObject:cid forKey:@"cid"];
    }
    [self.parametersDict setValuesForKeysWithDictionary:params];
    return [super sn_parameters];
}

@end
