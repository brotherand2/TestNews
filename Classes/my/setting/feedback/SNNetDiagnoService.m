//
//  SNNetDiagnoService.m
//  netAnimation
//
//  Created by 李腾 on 2016/10/25.
//  Copyright © 2016年 李腾. All rights reserved.
//

#import "SNNetDiagnoService.h"
#import "SNNetDiagnoRequest.h"
#import "SNNetDiagReportRequest.h"
//#import "JKNotificationCenter.h"
#import <JsKitFramework/JKNotificationCenter.h>
#import "SNUserLocationManager.h"

#define kCityCode            @"cityCode"
#define kNetUploadType       @"ios_reportNetworkSituation"

/**
 诊断结果类型
 */
typedef NS_ENUM(NSInteger,NetDiagnosisType)
{
    NetDiagnosisNormal = 0,
    NetDiagnosisWorse,
    NetDiagnosisUnusual
};

@interface SNNetDiagnoService ()

@property (nonatomic, assign) NetDiagnosisType netType;           // 诊断结果类型
@property (nonatomic, assign) BOOL tipToastEnable;                // 是是否弹窗提示
@property (nonatomic, copy) NSString *uploadJson;                 // 上传的json数据
@property (nonatomic, strong) NSDictionary *results;              // 请求图片返回的结果
@property (nonatomic, assign) NSInteger elementCount;             // 下载图片总个数
@end

@implementation SNNetDiagnoService

static id _instance;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

#pragma mark - public func

- (void)startNetDiagnosisWithTipToast{
    self.tipToastEnable = YES;
    [self startNetDiagnosis];
}

/**
 * 开始诊断网络
 */
- (void)startNetDiagnosis {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    [[[SNNetDiagnoRequest alloc] initWithStep:SNNetDiagnoseStepOne andRandomDate:nil] send:^(SNBaseRequest *request, id responseObject) {
        NSDictionary *elements = (NSDictionary *)responseObject;
        self.elementCount = elements.count;
        dispatch_group_t group = dispatch_group_create();
        NSMutableDictionary *resluts = [NSMutableDictionary dictionary];
        for (NSInteger i = 0; i < elements.count; i++) {
            NSString *urlStr = elements.allValues[i];
            dispatch_group_enter(group);
            [[[SNNetDiagnoElementRequest alloc] initWithElementUrl:urlStr] send:^(SNBaseRequest *request, id responseObject) {
                [resluts setObject:@"1" forKey:elements.allKeys[i]];
                // SNDebugLog(@"第%zd个请求成功",i);
                dispatch_group_leave(group);
            } failure:^(SNBaseRequest *request, NSError *error) {
                [resluts setObject:@"0" forKey:elements.allKeys[i]];
                // SNDebugLog(@"第%zd个请求失败",i);
                dispatch_group_leave(group);
            }];
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            self.results = resluts;
            [self startNetDialogsisRequestWithResponse:resluts];
        });
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self handleResultsWithResponse:nil];
    }];
}


#pragma mark - private func

- (void)startNetDialogsisRequestWithResponse:(NSDictionary *)results {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *randomDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [[[SNNetDiagnoRequest alloc] initWithStep:SNNetDiagnoseStepTwo andRandomDate:randomDate] send:^(SNBaseRequest *request, id responseObject) {
        
        [[[SNNetDiagnoRequest alloc] initWithStep:SNNetDiagnoseStepThree andRandomDate:randomDate] send:^(SNBaseRequest *request, id responseObject) {
            
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
            [dictM addEntriesFromDictionary:dict];
            [dictM addEntriesFromDictionary:results];
            NSString *gbCode = [SNUserLocationManager sharedInstance].currentChannelGBCode;
            if (gbCode.length > 0) {
                
                [dictM setObject:gbCode forKey:kCityCode];
            }
            self.uploadJson = [dictM.copy translateDictionaryToJsonString];
            
            [self handleResultsWithResponse:results];     // 处理下载图片返回结果
            
        } failure:^(SNBaseRequest *request, NSError *error) {
            [self handleResultsWithResponse:self.results];
        }];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        [self handleResultsWithResponse:self.results];
    }];
    
}

/**
 上传诊断结果到服务端

 @param jsonData 网络诊断数据
 */
- (void)uploadJsonWithJsonData:(NSString *)jsonData {
    
    [[[SNNetDiagReportRequest alloc] initWithUploadJson:jsonData andType:kNetUploadType] send:^(SNBaseRequest *request, id responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        SNDebugLog(@"%@",responseObject);
    } failure:^(SNBaseRequest *request, NSError *error) {
//        SNDebugLog(@"%@",error.localizedDescription);
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}


/**
 * 处理下载图片返回结果
 */
- (void)handleResultsWithResponse:(NSDictionary *)results {
    if (results.count >0 && results != nil) {
        NSInteger count = 0;
        
        for (NSString *result in results.allValues) {
            if (result.integerValue == 0) {
                count++;
            }
        }
        CGFloat percent = (float)count / self.elementCount; // 改为根据百分比来判断
        if (percent == 0) {
            self.netType = NetDiagnosisNormal;
        } else {
            if (percent > 0.3) {
                self.netType = NetDiagnosisUnusual;
            } else {
                self.netType = NetDiagnosisWorse;
            }
        }
    } else {
        self.netType = NetDiagnosisUnusual;
    }
    
    if (self.tipToastEnable) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [[JKNotificationCenter defaultCenter] dispatchNotification:kNetDiagnosisDidEnd withObject:nil]; // js广播
            [SNNotificationManager postNotificationName:kNetDiagnosisDidEnd object:self];
            [self popUPNetDialogsisToastWithType:self.netType];
            self.tipToastEnable = NO;
        });
    }
    
    [self uploadJsonWithJsonData:self.uploadJson];
    if ([self.delegate respondsToSelector:@selector(netDiagnosisDidEnd:)]) {
        [self.delegate netDiagnosisDidEnd:results];
    }
    
}


/**
 *  弹框提示
 */
- (void)popUPNetDialogsisToastWithType:(NetDiagnosisType )type {
    NSString *tipTitle = nil;
    switch (type) {
        case NetDiagnosisNormal:
            tipTitle = @"您的网络链接良好，可畅快阅读";
            break;
        case NetDiagnosisWorse:
            tipTitle = @"您的网络信号较差，建议您选择其他网络进行阅读";
            break;
        case NetDiagnosisUnusual:
            tipTitle = @"您的网络连接有些问题，请检测您的网络连接";
            break;
        default:
            break;
    }
    [[SNCenterToast shareInstance] showCenterToastWithTitle:tipTitle toUrl:nil mode:SNCenterToastModeOnlyText];
}

@end
