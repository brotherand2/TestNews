//
//  SNCameraConfig.h
//  sohunews
//
//  Created by H on 16/5/26.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNCameraConfig : NSObject

@property (nonatomic,copy) NSString * tabStr;

- (void)updateWithDic:(NSDictionary *)dic;

@end
