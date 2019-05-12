//
//  SNDataInputStream.h
//  sohunews
//
//  Created by chenhong on 13-12-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNDataInputStream : NSObject

//
- (id)initWithData:(NSData *)data;

//
+ (id)dataInputStreamWithData:(NSData *)aData;

// 从输入流读取 char 值。
- (int8_t)readChar;

//从输入流读取 short 值。
- (int16_t)readShort16;

//从输入流读取 int 值。
- (int32_t)readInt32;

//从输入流读取 long 值。
- (int64_t)readLong64;

//从输入流读取 NSString 字符串。
- (NSString *)readUTF;

//将输入流转换为NSString
- (NSString *)readString;

@end
