//
//  SNCheckFollowRequest.m
//  sohunews
//
//  Created by HuangZhen on 2017/5/10.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCheckFollowRequest.h"
#import "SNUserManager.h"

@implementation SNCheckFollowRequest

#pragma mark - SNRequestProtocol
- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeJSON;
}

- (NSString *)sn_customUrl {
    return [SNAPI rootUrl:@"/api/subscribe/isSubscribed.go"];
}

- (CGFloat)sn_timeoutInterval {
    return 10;
}

- (id)sn_parameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:4]; // 默认参数
    NSString *pid = [SNUserManager getPid];
    [params setValue:self.subId forKey:@"subId"];
    [params setValue:[SNUserManager getP1] forKey:@"p1"];
    [params setValue:pid?pid:@"-1" forKey:@"pid"];
    [params setValue:@"json" forKey:@"rt"];
    return params;
}

@end
