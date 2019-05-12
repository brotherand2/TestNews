//
//  SNDefaultParamsRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/1/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//  

#import "SNBaseRequest.h"

@interface SNDefaultParamsRequest : SNBaseRequest <SNRequestProtocol>

@property (nonatomic, assign) BOOL needNetSafeParameters; // 是否需要网安监控参数
@property (nonatomic, assign) BOOL needCurrentNetStatusParam; // 是否需要当前网络状态参数
@end
