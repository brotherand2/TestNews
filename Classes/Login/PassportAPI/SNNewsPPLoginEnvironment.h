//
//  SNPassportEnvironment.h
//  sohunews
//
//  Created by wang shun on 2017/10/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Online_Passport_API @"api.passport.sohu.com"
#define Test_Passport_API   @"tst.passport.sohu.com"

@interface SNNewsPPLoginEnvironment : NSObject

+ (NSString*)domain;

+ (NSString*)getAPPKey;

+ (BOOL)isPPLogin;


@end
