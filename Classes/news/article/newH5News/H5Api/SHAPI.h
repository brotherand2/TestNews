//
//  SHAPI.h
//  LiteSohuNews
//
//  Created by lijian on 15/7/30.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SHAPI : NSObject

/**
 *  取得Base URL
 *
 *  @return 默认返回
 */
+ (NSString *)getBaseURL;

/**
 *  取得特定的URL, 默认同Base URL拼接而成
 *
 *  @param URLString URL
 *
 *  @return 返回拼接而成的URL
 */
+ (NSString *)getURLWithString:(NSString *)URLString;

+ (NSString *)getParam:(NSDictionary *)dic;

@end
