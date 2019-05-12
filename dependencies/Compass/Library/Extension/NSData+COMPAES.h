//
//  NSData+COMPAES.h
//  Compass
//
//  Created by 李耀忠 on 16/10/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (COMPAES)

#pragma mark - Encrypt
- (NSData *)comp_AES256EncryptWithKey:(NSString *)key;
- (NSData *)comp_AES256EncryptWithKeyData:(NSData *)key;
- (NSData *)comp_AES256EncryptWithKeyData:(NSData *)key isCBCMode:(BOOL)bCBCMode initVector:(NSData *)initVector;

@end
