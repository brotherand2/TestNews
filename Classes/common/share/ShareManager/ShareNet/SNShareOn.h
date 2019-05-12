//
//  SNShareOn.h
//  sohunews
//
//  Created by wang shun on 2017/2/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSharePlatformHeader.h"
#import "SNUnifyShareServer.h"
#import "SNNewsShareOnService.h"

typedef void (^ShareOnCompletionBlock)(NSDictionary* responseDic);

@interface SNShareOn : NSObject<SNUnifyShareServerDelegate,SNNewsShareOnServiceDelegate>

@property (nonatomic,strong) SNSharePlatformBase* platForm;
@property (nonatomic,copy) ShareOnCompletionBlock completionMethod;

@property (nonatomic,strong) SNNewsShareOnService* shareOnService;//为防止逻辑复杂 再抽象一层

- (instancetype)initWithPlatForm:(SNSharePlatformBase*)p;

- (void)shareOnRequestWithCompletion:(ShareOnCompletionBlock)method;

@end
