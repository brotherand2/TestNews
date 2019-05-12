//
//  AesEncryptDecrypt.h
//  SohuNewspaper
//
//  Created by zhukx on 10-8-26.
//  Copyright 2010 sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AesEncryptDecrypt : NSObject {

}

+ (NSString *)encrypt:(NSString *)data withKey:(NSString *)key;
+ (NSString *)decrypt:(NSString *)string;
+ (NSString *)decrypt:(NSString *)data withKey:(NSString *)key;

+ (NSData *)encryptData:(NSString *)data withKey:(NSString *)key;
+ (NSString *)decryptData:(NSData *)data withKey:(NSString *)key;

@end
