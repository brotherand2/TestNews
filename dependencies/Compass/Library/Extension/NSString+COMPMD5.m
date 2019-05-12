//
//  NSString+COMPMD5.m
//  Compass
//
//  Created by 李耀忠 on 24/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import "NSString+COMPMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (COMPMD5)

- (NSString *)comp_md5 {
    const char *value = [self UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);

    NSMutableString *md5 = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [md5 appendFormat:@"%02x", outputBuffer[count]];
    }
    return md5.copy;
}

@end
