//
//  SNStoryRSA.h
//  sohunews
//
//
//  Created by chuanwenwang on 16/11/1.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNStoryRSA : NSObject

/**
 *  加密方法
 *
 *  @param str         需要加密的字符串
 *  @param path        '.p12'格式的私钥文件路径
 *  @param password    私钥文件密码
 */
+ (NSString *)encryptString:(NSString *)str privateKeyWithContentsOfFile:(NSString *)path;

/**
 *  解密方法
 *
 *  @param str         需要解密的字符串
 *  @param path        '.der'格式的公钥文件路径
 */
//+ (NSString *)decryptString:(NSString *)str privateKeyWithContentsOfFile:(NSString *)path password:(NSString *)password;
+ (NSString *)decryptString:(NSString *)str publicKeyWithContentsOfFile:(NSString *)path;

/**
 *  加密方法
 *
 *  @param str        需要加密的字符串
 *  @param privKey    私钥字符串
 */
//+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;
+ (NSString *)encryptString:(NSString *)str privateKey:(NSString *)pubKey;

/**
 *  解密方法
 *
 *  @param str       需要解密的字符串
 *  @param pubKey    公钥字符串
 */
//+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)privKey;
+ (NSString *)decryptString:(NSString *)str publicKey:(NSString *)publicKey;
@end
