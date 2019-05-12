//
//  SNRollingChannelListRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingChannelListRequest.h"
#import "SNUserLocationManager.h"

@implementation SNRollingChannelListRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Channel_List;
}

- (id)sn_parameters {//?rt=json&supportLive=1&supportWeibo=1
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"json" forKey:@"rt"];
    [params setValue:@"1" forKey:@"supportLive"];
    [params setValue:@"1" forKey:@"supportWeibo"];
 
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault boolForKey:kLaunchAppKey]) {
        [params setValue:@"1" forKey:@"isStartUp"];
    }
    
    if (![userDefault boolForKey:kChannelListFirstVisitKey]) {
        [params setValue:@"1" forKey:@"isFirstVisit"];
        [userDefault setBool:YES forKey:kChannelListFirstVisitKey];
        [userDefault synchronize];
    }
    
    NSDictionary *locationParams = [[SNUserLocationManager sharedInstance] getNewsLocationParams];
    if (locationParams.count > 0) {
        [params setValuesForKeysWithDictionary:locationParams];
    }
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey: kBundleVersionKey];
    if (version) {
        [params setValue:version forKey:@"v"];
    }

    //localChannel
    NSString *localChannelId = [SNUserLocationManager sharedInstance].localChannelId;
    if (localChannelId.length > 0) {
        [params setValue:localChannelId forKey:@"local"];
    } else {
        [params setValue:@"0" forKey:@"local"];
    }
    
    NSInteger isChannelChanged = [[NSUserDefaults standardUserDefaults] integerForKey:@"localChannelChangeFlag"];
    [params setValue:(isChannelChanged == 1 ? @"1" : @"0") forKey:@"change"];
    [self.parametersDict setValuesForKeysWithDictionary:params];
    return [super sn_parameters];
}
@end
