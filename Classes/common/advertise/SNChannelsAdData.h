//
//  SNChannelsAdData.h
//  sohunews
//
//  Created by HuangZhen on 11/07/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 渠道广告类型
typedef enum : NSUInteger {
    SNChannelADTypeShareMenu,
    SNChannelADTypeSearchHeader,
} SNChannelADType;

/**
 非标渠道广告数据模型
 */
@interface SNChannelsAdData : NSObject

@property (nonatomic, copy) NSString * adImageUrl;
@property (nonatomic, copy) NSString * adClickUrl;
@property (nonatomic, copy) NSString * adId;

@property (nonatomic, assign, readonly) BOOL enable;
@property (nonatomic, assign) SNChannelADType adType;

- (instancetype)initWithDic:(NSDictionary *)dic adType:(SNChannelADType)type;
- (BOOL)checkEnable;
- (void)didManualClosedAD;

@end
