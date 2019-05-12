//
//  SNThirdLoginViewModel.h
//  sohunews
//
//  Created by wang shun on 2017/4/4.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNThirdLoginViewModel : NSObject

@property (nonatomic,assign) BOOL isOpeningThrid;//第三方登录中...
@property (nonatomic,strong) NSString* screen;//埋点

/** 第三方登录
 */
- (void)thirdLoginWithName:(NSString*)name WithParams:(NSDictionary*)params Success:(void (^)(NSDictionary* resultDic))method;

@end
