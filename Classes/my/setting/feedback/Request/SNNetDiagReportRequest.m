//
//  SNNetDiagReport.m
//  sohunews
//
//  Created by ___TENG LI___ on 2017/3/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNetDiagReportRequest.h"

@implementation SNNetDiagReportRequest

/**
 初始化方法
 
 @param jsonData 诊断结果json数据
 @param type 上报类型
 @return request
 */
- (instancetype)initWithUploadJson:(NSString *)jsonData andType:(NSString *)type
{
    self = [super init];
    if (self) {
        if (jsonData.length > 0) {
            NSString *josn = [@{@"data":@[jsonData]} translateDictionaryToJsonString];
            [self.parametersDict setObject:josn forKey:@"data"];
            [self.parametersDict setValue:type forKey:@"type"];
        }
    }
    return self;
}

#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodPost;
}

- (NSString *)sn_requestUrl {
    
    return SNLinks_Path_NetDiag_Report;
}

- (id)sn_parameters {

    return [super sn_parameters];
}

@end
