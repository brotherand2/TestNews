//
//  SNPhoneLoginViewModel.h
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNPhoneLoginViewModel : NSObject

@property (nonatomic,strong) NSString* sourceChannelID;
@property (nonatomic,strong) NSString* screen;//埋点
@property (nonatomic,strong) NSString* entrance;//埋点

/** 手机号登录
 */
- (void)loginWithPhoneAndVcode:(NSDictionary*)params Successed:(void (^)(NSDictionary* resultDic))method;

@end
