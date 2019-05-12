//
//  SNWeixinOauthRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNWeixinOauthRequest.h"


@implementation SNWeixinOauthRequest

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_customUrl {
    return SNLinks_Weixin_Oauth2;
}

- (NSArray *)sn_excessResponseSerializerAcceptableContentTypes {
    return @[@"text/plain"];
}


- (id)sn_parameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:3];
//    if (!isINHOUSE) {
        [params setValue:kWX_APP_ID forKey:@"appid"];
        [params setValue:kWX_APP_KEY forKey:@"secret"];
//    } else {
//        [params setValue:kWX_APP_ID_Inhouse forKey:@"appid"];
//        [params setValue:kWX_APP_KEY_Inhouse forKey:@"secret"];
//    }
    [params setValue:@"authorization_code" forKey:@"grant_type"];
    [self.parametersDict setValuesForKeysWithDictionary:params];
    
    return [super sn_parameters];
}
@end
