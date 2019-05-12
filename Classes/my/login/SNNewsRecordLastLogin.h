//
//  SNNewsRecordLastLogin.h
//  sohunews
//
//  Created by wang shun on 2017/9/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsRecordLastLogin : NSObject

+ (NSDictionary*)getLastLogin:(id)sender;
+ (void)saveLogin:(NSDictionary*)lastLoginDic;

@end
