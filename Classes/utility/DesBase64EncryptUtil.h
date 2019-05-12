//
//  EncryptUtil.h
//  CryptoTest
//
//  Created by chenhong on 13-9-10.
//  Copyright (c) 2013年 chenhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DesBase64EncryptUtil : NSObject
+ (NSString *)encryptWithText:(NSString *)sText;
+ (NSString *)decryptWithText:(NSString *)sText;

+ (NSString *)encryptWithText:(NSString *)sText key:(NSString *)aKey;
+ (NSString *)decryptWithText:(NSString *)sText key:(NSString *)aKey;
@end
