//
//  SNSharePlatformBase.h
//  sohunews
//
//  Created by wang shun on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//
//  微信 狐友 微博 qq 支付宝 复制链接

#import <Foundation/Foundation.h>

#import "SNNewsShareParamsHeader.h"


typedef void (^UploadBlock)(NSDictionary* dic);

@interface SNSharePlatformBase : NSObject

@property (nonatomic,strong) NSMutableDictionary* shareData;
@property (nonatomic,assign) SNActionMenuOption optionPlatform;
@property (nonatomic,copy)   UploadBlock uploadMethod;

@property (nonatomic,assign) ShareTargetType shareTarget;//埋点

- (instancetype)initWithOption:(NSInteger)option;

- (NSString *)getLinkFromString:(NSString *)content;

- (void)shareTo:(NSDictionary*)dic;

- (void)shareTo:(NSDictionary*)dic Upload:(UploadBlock)method;

- (BOOL)isVideo;
- (BOOL)isOnlyImage;
    
- (void)log;

//访问shareOn参数
- (NSDictionary*)getShareParams:(NSDictionary*)dic;

@end
