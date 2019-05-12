//
//  SNDNSResolver.m
//  sohunews
//
//  Created by WongHandy on 8/14/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNDNSResolver.h"
#include <netdb.h>

@interface SNDNSResolver()
@property(nonatomic, strong, readwrite) NSURL *url;
@property(nonatomic, copy, readwrite) NSString *resolvedIpAddress;
@end

@implementation SNDNSResolver

- (id)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
    }
    return self;
}

- (void)resolve {
    _resolvedIpAddress = nil;
    
    CFStringRef hostName = (__bridge CFStringRef)[_url host];
    if (hostName == NULL) {
        return;
    }
    
    CFHostRef host;
    CFStreamError error;
    Boolean success;
    CFArrayRef addressArray;
    
    host = CFHostCreateWithName(kCFAllocatorDefault, hostName);
    if (host == NULL) {
        return;
    }
    
    success = CFHostStartInfoResolution(host, kCFHostAddresses, &error);
    if (!success) {//DNS解析地址失败
        SNDebugLog(@"Failed to DNS resolution with error(%ld, %ld)", error.domain, error.error);
    }else {
        addressArray = CFHostGetAddressing(host, nil);
        _resolvedIpAddress = [[self getAddressFromArray:addressArray] copy];
        SNDebugLog(@"Succeed to DNS resolution with ipAddress %@", _resolvedIpAddress);
    }
    CFRelease(host); // v5.2.0
}

- (NSString*)getAddressFromArray:(CFArrayRef)addresses {
    if (addresses == NULL) {
        return nil;
    }
    struct sockaddr  *addr;
    char             ipAddress[INET6_ADDRSTRLEN];
    CFIndex          index, count;
    int              err;
    count = CFArrayGetCount(addresses);
    for (index = 0; index < count; index++) {
        addr = (struct sockaddr *)CFDataGetBytePtr(CFArrayGetValueAtIndex(addresses, index));
        if (addr == NULL) {
            continue;
        }
        /* getnameinfo coverts an IPv4 or IPv6 address into a text string. */
        err = getnameinfo(addr, addr->sa_len, ipAddress, INET6_ADDRSTRLEN, NULL, 0, NI_NUMERICHOST);
        if (err == 0) {
            SNDebugLog(@"解析到ip地址：%s\n", ipAddress);
        } else {
            SNDebugLog(@"地址格式转换错误：%d\n", err);
        }
    }
    //通过循环得知：当解析到多个ip时取最后一个ip.
    return [[NSString alloc] initWithFormat:@"%s",ipAddress];
}


@end
