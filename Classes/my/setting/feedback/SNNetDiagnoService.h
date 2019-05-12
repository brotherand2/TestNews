//
//  SNNetDiagnoService.h
//  netAnimation
//
//  Created by 李腾 on 2016/10/25.
//  Copyright © 2016年 李腾. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 * @protocol 监控网络诊断的过程信息
 *
 */
@protocol SNNetDiagnoServiceDelegate <NSObject>
/**
 * 告诉调用者诊断开始
 */
- (void)netDiagnosisDidStarted;


/**
 * 逐步返回监控信息，
 * 如果需要实时显示诊断数据，实现此接口方法
 */
- (void)netDiagnosisStepInfo:(NSString *)stepInfo;


/**
 * 因为监控过程是一个异步过程，当监控结束后告诉调用者；
 * 在监控结束的时候，对监控字符串进行处理
 */
- (void)netDiagnosisDidEnd:(NSDictionary *)resultsInfo;

@end


/**
 * @class 网络诊断服务
 */

@interface SNNetDiagnoService : NSObject

@property (nonatomic, weak, readwrite) id<SNNetDiagnoServiceDelegate> delegate;      //向调用者输出诊断信息接口

+ (instancetype)sharedInstance;
/**
 * 开始诊断网络(不弹框)
 */
- (void)startNetDiagnosis;

/**
 开始诊断网络(提示弹框)
 */
- (void)startNetDiagnosisWithTipToast;


/**
 * 停止诊断网络
 */
- (void)stopNetDialogsis;


/**
 * 打印整体loginInfo；
 */
- (void)printLogInfo;


@end
