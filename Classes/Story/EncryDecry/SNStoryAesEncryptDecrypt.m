//
//  SNStoryAesEncryptDecrypt.h
//  sohunews
//
//  Created by chuanwenwang on 16/11/1.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import "SNStoryAesEncryptDecrypt.h"

@implementation SNStoryAesEncryptDecrypt

+ (NSString *)encrypt:(NSString *)data withKey:(NSString *)key
{
	char *inputChar = (char *)[data UTF8String];
	NSInteger inputCharLength = strlen(inputChar);
	NSInteger plainLength = (inputCharLength / 16 + 1) * 16;
	
	char *inputCharFormated = (char*)malloc(plainLength);
	memset(inputCharFormated, plainLength-inputCharLength, plainLength);
	memcpy(inputCharFormated, inputChar, inputCharLength);
	
	size_t nBytesEncrypted = 0;
	void *buffer = malloc( (plainLength) * sizeof(uint8_t));
	memset((void *)buffer, 0x0, (plainLength)* sizeof(uint8_t));
	
	uint8_t iv[kCCBlockSizeAES128];
	memset((void *) iv, plainLength-inputCharLength, (size_t) sizeof(iv));
	
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionECBMode,
										  [key UTF8String],
										  kCCKeySizeAES128,
										  iv, 									 
										  (const void *)inputCharFormated, plainLength, 
										  (void *) buffer, plainLength,
										  &nBytesEncrypted);
	free(inputCharFormated);
	
	// create return string
	NSString *returnString = nil;
	if (cryptStatus == kCCSuccess) {
		returnString = [NSString stringWithFormat:@"%@", [NSData dataWithBytes:buffer length:(plainLength)]];
		free(buffer);buffer=nil;
		NSString *returnedString = [returnString stringByReplacingOccurrencesOfString:@" " withString:@""];
		returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<"]];
		returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@">"]];
		return returnedString;
	}

    if (buffer) {
        free(buffer);buffer=nil;
    }
    
	return nil;
}

+ (NSString *)decrypt:(NSString *)string
{
	return nil;
}

+ (NSString *)decrypt:(NSString *)data withKey:(NSString *)key
{
    char *inputChar = (char *)[data UTF8String];
    NSInteger inputCharLength = strlen(inputChar);
    NSInteger plainLength = (inputCharLength / 16 + 1) * 16;
    
    char *inputCharFormated = (char*)malloc(plainLength);
    memset(inputCharFormated, plainLength-inputCharLength, plainLength);
    memcpy(inputCharFormated, inputChar, inputCharLength);
    
    size_t nBytesEncrypted = 0;
    void *buffer = malloc( (plainLength) * sizeof(uint8_t));
    memset((void *)buffer, 0x0, (plainLength)* sizeof(uint8_t));
    
    uint8_t iv[kCCBlockSizeAES128];
    memset((void *) iv, plainLength-inputCharLength, (size_t) sizeof(iv));
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeAES128,
                                          iv,
                                          (const void *)inputCharFormated, plainLength,
                                          (void *) buffer, plainLength,
                                          &nBytesEncrypted);
    free(inputCharFormated);
    
    // create return string
    NSString *returnString = nil;
    if (cryptStatus == kCCSuccess) {
        returnString = [NSString stringWithFormat:@"%@", [NSData dataWithBytes:buffer length:(plainLength)]];
        free(buffer);buffer=nil;
        NSString *returnedString = [returnString stringByReplacingOccurrencesOfString:@" " withString:@""];
        returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<"]];
        returnedString = [returnedString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@">"]];

        return returnedString;
    }
    
    if (buffer) {
        free(buffer);buffer=nil;
    }
    
    return nil;
}

+ (NSData *)encryptData:(NSString *)data withKey:(NSString *)key{
    NSData *crtptData = [data dataUsingEncoding:NSUTF8StringEncoding];
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [crtptData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [crtptData bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        return data;
    }
    free(buffer);
    return nil;
}

+ (NSString *)decryptData:(NSData *)data withKey:(NSString *)key{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeAES128,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSString *decryptStr = [[NSString alloc] initWithBytes:buffer length:numBytesDecrypted encoding:NSUTF8StringEncoding];
        free(buffer);
        return decryptStr;
    }
    free(buffer);
    return nil;
}


@end
