//
//  SNNetDiagReport.h
//  sohunews
//
//  Created by ___TENG LI___ on 2017/3/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@interface SNNetDiagReportRequest : SNDefaultParamsRequest

/**
 初始化方法

 @param jsonData 诊断结果json数据
 @param type 上报类型
 @return request
 */
- (instancetype)initWithUploadJson:(NSString *)jsonData andType:(NSString *)type;

@end
