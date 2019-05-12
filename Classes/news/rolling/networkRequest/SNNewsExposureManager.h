//
//  SNNewsExposureManager.h
//  sohunews
//
//  Created by lhp on 3/28/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNNewsExposureManager : NSObject {
    
    NSMutableArray *exposureNewsArray;   //所以曝光新闻
    NSMutableDictionary *lastNewsDic;   //上组曝光新闻用于排重
    TTURLRequest *exposureRequest;
    BOOL sending;
}

+ (SNNewsExposureManager *)sharedInstance;

//曝光记录一组新闻(包含滤重逻辑)
- (void)exposureNewsInfoWithDic:(NSDictionary *) newsDic;

//曝光记录一条（适用记录广告曝光）
- (void)exposureNewsInfoWithLink:(NSString *) newsLink;

//清空上次曝光一组新闻（为了不滤重）
- (void)clearLastExposureNews;

//保存曝光记录到缓存文件
- (void)saveAllExposureNewsToFile;
//清理缓存
- (void)clearAllExposureNewsInFile;
@end
