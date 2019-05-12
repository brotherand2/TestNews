//
//  SNStoryAesEncryptDecrypt.h
//  sohunews
//
//  Created by chuanwenwang on 16/11/1.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SNStoryAesEncryptDecrypt : NSObject {

}

+ (NSString *)encrypt:(NSString *)data withKey:(NSString *)key;
+ (NSString *)decrypt:(NSString *)string;
+ (NSString *)decrypt:(NSString *)data withKey:(NSString *)key;

+ (NSData *)encryptData:(NSString *)data withKey:(NSString *)key;
+ (NSString *)decryptData:(NSData *)data withKey:(NSString *)key;

@end
