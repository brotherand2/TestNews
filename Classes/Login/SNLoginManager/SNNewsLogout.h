//
//  SNNewsLogout.h
//  sohunews
//
//  Created by wang shun on 2017/5/5.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsLogout : NSObject


+ (void)requestLogout:(void (^)(NSDictionary*info))method;

@end
