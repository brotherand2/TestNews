//
//  SNNetworkConfiguration.m
//  TT_AllInOne
//
//  Created by tt on 15/5/29.
//  Copyright (c) 2015年 tt. All rights reserved.
//

#import "SNNetworkConfiguration.h"

@interface SNNetworkConfiguration () {
}

@property (nonatomic, readwrite) NSString *buildInUrl;;

@end

@implementation SNNetworkConfiguration

+ (SNNetworkConfiguration *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSString *)buildInUrl {
    if (_buildInUrl == nil && _buildInParameters) {
        _buildInUrl = [SNQueryStringFromParameters(_buildInParameters) copy];
    }
    return _buildInUrl;
}

@end
