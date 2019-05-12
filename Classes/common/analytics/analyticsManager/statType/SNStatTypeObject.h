//
//  SNStateType.h
//  sohunews
//
//  Created by jialei on 14-7-31.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//  定义统计对象类型和统计对象所需属性
//  For ARC
//

#import <Foundation/Foundation.h>
#import "SNStatInfo.h"
#import "SNStatisticsConst.h"

@interface SNStatTypeObject : NSObject

//统计上传数据组URL
@property(nonatomic, strong) NSString *dataServerUrl;
@property (nonatomic, strong) NSMutableDictionary *dataServerParams;// 统计上传需要的参数
//事件参数
@property(nonatomic, strong) SNStatInfo *info;

+ (Class)classForStatisticsType:(SNStatInfoUseType)type;
- (id)initWithStateInfo:(SNStatInfo *)statInfo;

/*上报广告服务器
 *
 */
- (void)uploadAdServerEvent;

@end
