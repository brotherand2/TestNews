//
//  SNNewsScreenShareUserInfo.m
//  sohunews
//
//  Created by wang shun on 2017/8/14.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsScreenShareUserInfoRequest.h"

@implementation SNNewsScreenShareUserInfoRequest

//api/usercenter/screenshot/share/userinfo
- (instancetype)initWithDictionary:(NSDictionary *)dict WithFile:(NSData*)file{
    if (self = [super initWithDictionary:dict]) {
        
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Screen_UserInfo;
}

/**
 请求参数
 cid   客户端cid
 pid  登录狐友后带上pid,没登录则不传
 
 
 0 未授权 此时nickName avator为空
 1 已授权
 2 授权过期
 
 **/


@end
