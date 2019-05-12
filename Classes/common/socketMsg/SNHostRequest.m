//
//  SNHostRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNHostRequest.h"
#import "SNMessageMgrConsts.h"


@implementation SNHostRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_customUrl {
    return SNLinks_Path_GetBroker;
}

- (NSDictionary *)sn_requestHTTPHeader {
    return [NSDictionary dictionaryWithObject:kDevice forKey:@"device"];
}

- (NSString *)sn_requestWithNewManager {
    return SNNet_Request_HostManager;
}

- (NSArray *)sn_excessResponseSerializerAcceptableContentTypes {
    return @[@"text/plain"];
}

- (id)sn_parameters {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    [params setValue:@"2" forKey:@"v"];
    NSString *cid = [[NSUserDefaults standardUserDefaults] objectForKey:kProfileClientIDKey];
    NSString *lastMsgId = [[NSUserDefaults standardUserDefaults] objectForKey:kMessageMgrLastMsgIdReceivedKey];
    //返回当前网络的信息状况 0 无网络 1 wifi 2 2G 3 3G
    int status = ([[SNUtility getApplicationDelegate] currentNetworkStatus] == ReachableViaWiFi) ? 1 : 2;
    
    [params setValue:[NSString stringWithFormat:@"news-%@",cid] forKey:@"imei"];
    [params setValue:[NSString stringWithFormat:@"%zd",status] forKey:@"status"];
    if (lastMsgId) {
        [params setValue:lastMsgId forKey:@"lmsg"];
    }
    [self.parametersDict setValuesForKeysWithDictionary:params];
    
    return [super sn_parameters];
}

@end
