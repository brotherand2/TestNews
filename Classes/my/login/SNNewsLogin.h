//
//  SNNewsLogin.h
//  sohunews
//
//  Created by wang shun on 2017/5/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsLogin : NSObject

+ (void)loginWithParams:(NSDictionary*)params Success:(void (^)(NSDictionary* info))method;

+ (void)loginSuccess:(void (^)(NSDictionary* info))method;
+ (void)bindSuccess:(void (^)(NSDictionary* info))method;

@end
