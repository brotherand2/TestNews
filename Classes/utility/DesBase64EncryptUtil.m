//
//  EncryptUtil.m
//  CryptoTest
//
//  Created by chenhong on 13-9-10.
//  Copyright (c) 2013年 chenhong. All rights reserved.
//

#import "DesBase64EncryptUtil.h"
#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

@implementation DesBase64EncryptUtil
+ (NSString *)encrypt:(NSString *)sText encryptOrDecrypt:(CCOperation)encryptOperation key:(NSString *)key
{
    const void *vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOperation == kCCDecrypt)
    {
        NSData *decryptData = [YAJL_GTMBase64 decodeData:[sText dataUsingEncoding:NSUTF8StringEncoding]];
        plainTextBufferSize = [decryptData length];
        vplainText = [decryptData bytes];
    }
    else
    {
        NSData* encryptData = [sText dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [encryptData length];
        vplainText = (const void *)[encryptData bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSizeDES) & ~(kCCBlockSizeDES -1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
//    NSString *initVec = @"init Kurodo";
    const void *vkey = (const void *) [key UTF8String];
//    const void *vinitVec = (const void *) [initVec UTF8String];
    
    ccStatus = CCCrypt(encryptOperation,
                       kCCAlgorithmDES,
                       kCCOptionPKCS7Padding | kCCOptionECBMode,
                       vkey,
                       kCCKeySizeDES,
                       NULL,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    
    NSString *result = nil;
    
    if (encryptOperation == kCCDecrypt)
    {
        result = [[[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes] encoding:NSUTF8StringEncoding] autorelease];
    }
    else
    {
        NSData *data = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        result = [YAJL_GTMBase64 stringByEncodingData:data];
    }
    
    return result;
}

+ (NSString *)encryptWithText:(NSString *)sText
{
    return [self encrypt:sText encryptOrDecrypt:kCCEncrypt key:@"delcomts"];
}

+ (NSString *)decryptWithText:(NSString *)sText
{
    return [self encrypt:sText encryptOrDecrypt:kCCDecrypt key:@"delcomts"];
}

+ (NSString *)encryptWithText:(NSString *)sText key:(NSString *)aKey {
    return [self encrypt:sText encryptOrDecrypt:kCCEncrypt key:aKey];
}

+ (NSString *)decryptWithText:(NSString *)sText key:(NSString *)aKey {
    return [self encrypt:sText encryptOrDecrypt:kCCDecrypt key:aKey];
}

@end
