//
//  SNVideoRetryRequest.m
//  sohunews
//
//  Created by qz on 2017/11/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNVideoRetryRequest.h"

@implementation SNVideoRetryRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Check_Video_Site;
}

////测试用
//- (NSString *)sn_baseUrl {
//    return [SNAPI baseUrlWithDomain:SNLinks_Domain_TestApiK];
//}

//- (id)sn_parameters {
//    
//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[super sn_parameters]];
//    if (dic[@"p1"]) {
//        //测试服务器的p1值
//        [dic setObject:@"NjEyMDgyMzQ1NjE3MjI1NzM4OA==" forKey:@"p1"];
//        NSLog(@"%@",dic[@"p1"]);
//    }
//    return [NSDictionary dictionaryWithDictionary:dic];
//}

@end
