//
//  NSData+COMPAES.m
//  Compass
//
//  Created by 李耀忠 on 16/10/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import "NSData+COMPAES.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (COMPAES)

#pragma mark - Encrypt
- (NSData *)comp_AES256EncryptWithKey:(NSString *)key {
    return [self comp_AES256EncryptWithKeyData:[key dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSData *)comp_AES256EncryptWithKeyData:(NSData *)key {
    return [self comp_AES256EncryptWithKeyData:key isCBCMode:NO initVector:nil];
}

- (NSData *)comp_AES256EncryptWithKeyData:(NSData *)key isCBCMode:(BOOL)bCBCMode initVector:(NSData *)initVector {
    return [self comp_AES256DataWithOperation:kCCEncrypt keyData:key isCBCMode:bCBCMode initVector:initVector];
}

- (NSData *)comp_AES256DataWithOperation:(CCOperation)operation keyData:(NSData *)key isCBCMode:(BOOL)bCBCMode initVector:(NSData *)initVector {
    if (!([key length] == 16 || [key length] == 24 || [key length] == 32) || (bCBCMode && [initVector length] != kCCBlockSizeAES128)) {
        assert(NO);
        return nil;
    }

    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCOptions options = bCBCMode ? (kCCOptionPKCS7Padding) : (kCCOptionPKCS7Padding | kCCOptionECBMode);
    CCCryptorStatus cryptStatus = CCCrypt(operation, kCCAlgorithmAES128, options, [key bytes], [key length], [initVector bytes], [self bytes], dataLength, buffer, bufferSize, &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }

    free(buffer);
    return nil;
}

@end
