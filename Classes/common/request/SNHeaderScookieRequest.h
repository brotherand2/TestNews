//
//  SNHeaderScookieRequest.h
//  sohunews
//
//  Created by Valar__Morghulis on 11/05/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
/*
 此类用途: 增加 请求头 HTTPHeader
              @"SCOOKIE": [SNClientRegister sharedInstance].s_cookie
 以后网路请求如果需要增加此请求头，请继承此类
 ##登录相关接口请继承此类##
 */

#import "SNDefaultParamsRequest.h"

@interface SNHeaderScookieRequest : SNDefaultParamsRequest

@end
