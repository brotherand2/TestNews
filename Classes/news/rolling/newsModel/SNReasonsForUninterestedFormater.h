//
//  SNReasonsForUninterestedFormater.h
//  sohunews
//
//  Created by 赵青 on 2016/12/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNBaseRequest.h"

@interface SNReasonsForUninterestedFormater : NSObject<SNDataFormatProtocol>

/**
 请求不感兴趣理由

 @param dic 请求所需参数
 @param completion 返回Block
 */
+ (void)requestUninterestedDataWithDic:(NSDictionary *)dic Completion:(void(^)(NSError *error, id data))completion;

/**
 不感兴趣理由上报

 @param dic 上报所需参数
 @param completion 返回Block
 */
+ (void)requestUninterestedReportWithDic:(NSDictionary *)dic Completion:(void(^)(NSError *error, id data))completion;

@end
