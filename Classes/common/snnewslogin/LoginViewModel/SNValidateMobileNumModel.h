//
//  SNValidateMobileNumModel.h
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNMobileValidateRequest.h"

@interface SNValidateMobileNumModel : NSObject


/** 验证手机号有效
 */
- (void)isValidateMobileNum:(NSString *)phone Successed:(void (^)(NSDictionary* resultDic))method;

@end
