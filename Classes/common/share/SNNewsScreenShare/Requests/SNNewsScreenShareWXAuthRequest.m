//
//  SNNewsScreenShareWXAuthRequest.m
//  sohunews
//
//  Created by wang shun on 2017/8/14.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsScreenShareWXAuthRequest.h"

@implementation SNNewsScreenShareWXAuthRequest

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
    return SNLinks_Path_Screen_WXAuth;
}

/**
 
 请求参数
 openid   微信openid
 accessToken  访问token
 cid         客户端cid
 pid       没登录狐友不传
 
 **/


/***

 {
 "statusCode": 200,
 "statusMsg": "ok",
 "data": {
 "userInfos": {
 "weixin": {
 "status": 1,
 "nickName": "aaa",
 "openid": "123",
 "avator": "1111"
 },
 "huyou": {
 "nickName": "aaa",
 "status": 1,
 "openid": "123",
 "avator": "1111"
 }
 },
 "tips": "长按识别二维码 凑凑热闹"
 }
 }
 
 **/


@end
