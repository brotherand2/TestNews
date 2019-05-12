//
//  SNSohuHaoChannelListRequest.m
//  sohunews
//
//  Created by HuangZhen on 2017/6/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSohuHaoChannelListRequest.h"
#import "SNUserManager.h"

@implementation SNSohuHaoChannelListRequest
#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeJSON;
}

- (NSString *)sn_customUrl {
    return SNLinks_Path_Subscribe_GetChannelList;
}

- (CGFloat)sn_timeoutInterval {
    return 5;
}

- (id)sn_parameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10]; // 默认参数
    NSString *pid = [SNUserManager getPid];
    [params setObject:[SNUserManager getToken] forKey:@"token"];
    [params setObject:[SNUserManager getUserId] forKey:@"passport"];
    [params setObject:[SNUserManager getGid] forKey:@"gid"];
    [params setObject:pid?pid:@"-1" forKey:@"pid"];
    [params setObject:[SNUserManager getP1] forKey:@"p1"];
    return params;
}
@end
