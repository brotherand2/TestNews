//
//  SNIAPProductsRequest.m
//  sohunews
//
//  Created by HuangZhen on 02/03/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNIAPProductsRequest.h"
#import "SNStoryUtility.h"

@implementation SNIAPProductsRequest
#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}

- (SNResponseType)sn_responseType {
    return SNResponseTypeJSON;
}

- (NSString *)sn_customUrl {
    return SNLink_Path_Product;
}

- (id)sn_parameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:20]; // 默认参数
    
    NSString * p1 = [SNStoryUtility getP1];
    NSString * pid = [SNStoryUtility getPid];
    NSString * token = [SNStoryUtility getToken];
    NSString * u = [SNStoryUtility getU];
    NSString * gid = [SNStoryUtility getGid];
    NSString * apiVer = [NSString stringWithFormat:@"%d", APIVersion];
    
    /*
     p1	String
     用户唯一标识
     
     pid	Long
     用户 passport 对应的 pid
     
     apiVersion	Integer
     版本号
     
     u	Integer
     productId产品 id
     
     token	String
     passport登录用户 token
     
     gid	String
     gid
     */
    [params setObject:p1 ? p1:@"" forKey:@"p1"];
    [params setObject:pid ? pid:@"" forKey:@"pid"];
    [params setObject:gid ? gid:@"" forKey:@"gid"];
    [params setObject:u ? u:@"" forKey:@"u"];
    [params setObject:apiVer ? apiVer:@"" forKey:@"apiVersion"];
    [params setObject:token ? token:@"" forKey:@"token"];
    
    return params;
}

@end
