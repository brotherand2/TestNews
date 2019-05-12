//
//  SNShareOnRequest.m
//  sohunews
//
//  Created by ___TENG LI___ on 2017/2/22.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNShareOnRequest.h"
#import "SNUserManager.h"

@interface SNShareOnRequest ()

/**
 外部字典 [kShareOnKey] 对应 Value;如果不为空,则以此链接为请求地址.
 */
@property (nonatomic, copy) NSString *shareOnUrl;

@end

@implementation SNShareOnRequest

/**
 初始化方法
 
 @param dict 外部传入参数
 @param shareOnUrl kShareOnKey 对应Value
 @return request
 */
- (instancetype)initWithDictionary:(NSDictionary *)dict andShareOnUrl:(NSString *)shareOnUrl
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.shareOnUrl = shareOnUrl;
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_customUrl {
    
    if (self.shareOnUrl.length > 0) {
        return [self.shareOnUrl URLDecodedString];
    }
    return [NSString stringWithFormat:@"%@%@",[SNAPI baseUrlWithDomain:SNLinks_Domain_BaseApiK],SNLinks_Path_Share_ShareOn];
}

- (id)sn_parameters {
    
    if (self.shareOnUrl.length > 0) {
        return nil;
    } else {
        NSString *pid = [SNUserManager getPid];
        [self.parametersDict setValue:[SNUserManager getP1] forKey:@"p1"];
        [self.parametersDict setValue:pid?pid:@"-1" forKey:@"pid"];
        return self.parametersDict;
    }
}

@end
