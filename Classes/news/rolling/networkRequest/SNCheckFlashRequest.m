//
//  SNCheckFlashRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/9.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNCheckFlashRequest.h"

@implementation SNCheckFlashRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeHTTP;
}

- (NSString *)sn_requestUrl {
    
    return SNLinks_Path_Channel_CheckLatest;
}

- (NSString *)sn_requestWithNewManager {
    return SNNet_Request_ResponseHttpManager;
}

- (id)sn_parameters {
    
    return [super sn_parameters];
}
@end
