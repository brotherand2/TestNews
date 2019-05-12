//
//  SNLogManager.h
//  sohunews
//
//  Created by wangyy on 15/4/29.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kLogType_qrcode, // 扫一扫
} LogType;

typedef enum : NSUInteger {
    kLogStatType_open,//打开扫一扫二维码功能
    kLogStatType_kp,//扫一扫功能操作过程
} LogStatType;

typedef enum : NSUInteger{
    QRViewRefer_Other = 0,
    QRViewRefer_HomePage,
    QRViewRefer_LocalChannel
} QRViewReferType;

@interface SNLogManager : NSObject

- (void)logManagerWithCid:(NSString *)cid
                     Plat:(NSString *)plat
                  Version:(NSString *)version
                  Channle:(NSString *)channle
                  NetType:(NSString *)netType
                ProductId:(NSString *)productId
                     Time:(NSString *)time
                   GbCode:(NSString *)gbCode
                     Type:(NSString *)type
                 StatType:(NSString *)statType
                  ObjType:(NSString *)objType
              Immediately:(BOOL)immediately;

- (void)addLog:(NSString *)log;
- (void)logAndFileSend;

+ (SNLogManager *)sharedInstance;

/**
 *  通用log上报接口。LogType为业务类型项(必传),LogStatType为统计需求项(必传).
 */
+ (BOOL)sendLogWithType:(LogType)type StatType:(LogStatType)statType Query:(NSDictionary *)query;



@end
