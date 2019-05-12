//
//  SNDataInputStream.m
//  sohunews
//
//  Created by chenhong on 13-12-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDataInputStream.h"

@implementation SNDataInputStream {
    NSData  *_data;
    NSInteger     _offset;
}


- (id)initWithData:(NSData *)aData {
    self = [self init];
    if (self != nil){
        _data = [[NSData alloc] initWithData:aData];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        _offset = 0;
    }
    return self;
}

+ (id)dataInputStreamWithData:(NSData *)aData {
    SNDataInputStream *dataInputStream = [[self alloc] initWithData:aData];
    return dataInputStream;
}

- (int32_t)read {
    int8_t v;
    [_data getBytes:&v range:NSMakeRange(_offset, 1)];
    ++_offset;
    return ((int32_t)v & 0x0ff);
}

- (int8_t)readChar {
    int8_t v;
    [_data getBytes:&v range:NSMakeRange(_offset, 1)];
    ++_offset;
    return (v & 0x0ff);
}

- (int16_t)readShort16 {
    int32_t ch1 = [self read];
    int32_t ch2 = [self read];
    if ((ch1 | ch2) < 0) {
        @throw [NSException exceptionWithName:@"Exception" reason:@"EOFException" userInfo:nil];
    }
    return (int16_t)((ch1 << 8) + (ch2 << 0));
}

- (int32_t)readInt32 {
    int32_t ch1 = [self read];
    int32_t ch2 = [self read];
    int32_t ch3 = [self read];
    int32_t ch4 = [self read];
    if ((ch1 | ch2 | ch3 | ch4) < 0){
        @throw [NSException exceptionWithName:@"Exception" reason:@"EOFException" userInfo:nil];
    }
    return ((ch1 << 24) + (ch2 << 16) + (ch3 << 8) + (ch4 << 0));
}

- (int64_t)readLong64 {
    int8_t ch[8] = {0};
    [_data getBytes:&ch range:NSMakeRange(_offset, 8)];
    _offset += 8;
    
    return (((int64_t)ch[0] << 56) +
            ((int64_t)(ch[1] & 255) << 48) +
            ((int64_t)(ch[2] & 255) << 40) +
            ((int64_t)(ch[3] & 255) << 32) +
            ((int64_t)(ch[4] & 255) << 24) +
            ((int64_t)(ch[5] & 255) << 16) +
            ((int64_t)(ch[6] & 255) <<  8) +
            ((int64_t)(ch[7] & 255) <<  0));
}



- (NSString *)readUTF {
    short utfLength = [self readShort16];
    NSData *d = [_data subdataWithRange:NSMakeRange(_offset, utfLength)];
    NSString *str = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    _offset += utfLength;
    return str;
}

- (NSString *)readString {
    NSData *d = [_data subdataWithRange:NSMakeRange(_offset, _data.length - _offset)];
    NSString *str = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    _offset = _data.length;
    return str;
}

@end
