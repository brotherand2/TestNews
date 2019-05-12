//
//  SNNewsPPLoginSynchronize.h
//  sohunews
//
//  Created by wang shun on 2017/11/7.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsPPLoginSynchronize : NSObject

+ (void)ppLoginSynchronize:(NSDictionary*)params LoginType:(NSString*)loginType UserInfo:(NSDictionary*)userInfo callback:(void (^)(NSDictionary*))method;

@end
