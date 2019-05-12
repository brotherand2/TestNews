//
//  SNShareAlipay.h
//  sohunews
//
//  Created by wang shun on 2017/2/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSharePlatformBase.h"

#import "APOpenAPI.h"
#import "APOpenAPIObject.h"

@interface SNShareAlipay : SNSharePlatformBase

@property (nonatomic,strong) NSString* alipayType;

- (instancetype)initWithOption:(NSInteger)option;

+ (BOOL)isAliPayAppInstalled;

@end
