//
//  SNAppConfigRequestMonitorConditions.h
//  sohunews
//
//  Created by WongHandy on 8/15/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppConfigRequestMonitorConditions : NSObject

//运营商, 取值范围:Unicom(联通),mobile (移动),telecom(电信),else(其他); 多个以","逗号相连
@property(nonatomic, copy) NSString *carrier;

//地域码, 形如:110000,2200,xb,可以是6位表示精确到区，可以是4位表示省，可以2位代表国家; 多个以","逗号相连, 表这几个地区做抽样
@property(nonatomic, copy) NSString *gbcode;

//随机数种子, 客户端按req_monitor_scale进行random(req_monitor_scale)随机数, 如果随机到0, 则进行监控数据的上传
//如: req_monitor_scale=10000, 表示进行所有请求万分之一随机采样, 客户端进行random(10000), 如为0, 则上传请求监测数据
@property(nonatomic, copy) NSString *monitorScale;

//网络, 取值范围: wifi、4g、3g、2g; 多个以","逗号相连
@property(nonatomic, copy) NSString *network;

//移动设备平台, 取值范围: android、iphone、ipad、wphone
@property(nonatomic, copy) NSString *devicePlatform;

//搜狐新闻客户端App版本号; 多个以","逗号相连
@property(nonatomic, copy) NSString *appVersion;

- (void)updateWithDic:(NSDictionary *)configDic;
@end