//
//  SNNetDiagnoRequest.h
//  sohunews
//
//  Created by ___TENG LI___ on 2017/3/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

/**
 网络请求步骤
 */
typedef NS_ENUM(NSUInteger, SNNetDiagnoseStep) {
    SNNetDiagnoseStepOne,
    SNNetDiagnoseStepTwo,
    SNNetDiagnoseStepThree
};

/**
 *  -----------------------SNNetDiagnoRequest-----------------------
 */
@interface SNNetDiagnoRequest : SNBaseRequest <SNRequestProtocol>

/**
 初始化方法

 @param step 网络诊断步骤
 @param randomDate 随机时间（当前时间的固定格式 @"yyyyMMddHHmmss"）
 @return request
 */
- (instancetype)initWithStep:(SNNetDiagnoseStep)step andRandomDate:(NSString *)randomDate;

@end


/**
 *  -----------------------SNNetDiagnoElementRequest-----------------------
 */
@interface SNNetDiagnoElementRequest : SNBaseRequest <SNRequestProtocol>

/**
 初始化方法
 
 @param urlString 诊断返回的网址字典对应value
 @return request
 */
- (instancetype)initWithElementUrl:(NSString *)urlString;

@end
