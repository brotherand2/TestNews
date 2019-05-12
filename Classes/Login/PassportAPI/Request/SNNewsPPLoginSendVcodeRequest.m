//
//  SNNewsPPLoginSendVcodeRequest.m
//  sohunews
//
//  Created by wang shun on 2017/10/30.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsPPLoginSendVcodeRequest.h"

@implementation SNNewsPPLoginSendVcodeRequest

- (NSString *)sn_requestUrl{
    return SNNewsPPLoginURL_SendVcode;
}

-(SNResponseType)sn_responseType{
    return SNResponseTypeJSON;
}

- (NSDictionary *)sn_requestHTTPHeader{
    return [super sn_requestHTTPHeader];
}

@end

/*****************************************************/
/*
 mobile    是    手机号
 biz       是    业务类型：
                 signup：注册
                 signin：登录
                 bind：绑定手机
                 unbind：解绑手机
 
 voice    否     是否发送语音：true\false
 captcha  否     图片验证码
 ctoken   否     图片验证码对应的token，生成验证码时所提交的参数，详见获取图片验证码
 */
/*****************************************************/
