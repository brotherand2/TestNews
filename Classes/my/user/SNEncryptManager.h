//
//  SNEncryptManager.h
//  sohunews
//
//  Created by Diaochunmeng on 12-12-26.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNEncryptManager : NSObject

+(SNEncryptManager*)GetInstance;
+(NSString*)EncrptUpdateUserinfoString:(NSString*)aUrlString;
+(NSDictionary*)dictionaryFromQuery:(NSString*)query usingEncoding:(NSStringEncoding)encoding;
@end
