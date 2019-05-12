//
//  SNThirdLoginViewModel.h
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNThirdLoginViewModel : NSObject

/** 第三方登录
 */
- (void)thirdLoginWithName:(NSString*)name WithParams:(NSDictionary*)params Success:(void (^)(NSDictionary* resultDic))method;

@end
