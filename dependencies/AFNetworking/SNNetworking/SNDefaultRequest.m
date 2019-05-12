//
//  SNDefaultRequest.m
//  TT_AllInOne
//
//  Created by tt on 15/5/28.
//  Copyright (c) 2015年 tt. All rights reserved.
//

#import "SNDefaultRequest.h"
#import "SNNetworkConfiguration.h"

@implementation SNDefaultRequestBuilder

- (id)build {
    return [[SNDefaultRequest alloc] initWithBuilder:self];
}

@end

@implementation SNDefaultRequest

#pragma mark SNRequestProtocol
- (NSString *)sn_requestUrl {
    return nil;
}

- (SNRequestMethod)sn_requestMethod {
    return _requestMethod;
}

- (SNResponseType)sn_responseType {
    return _responseType;
}

- (id)sn_parameters {
    return _parameters;
}

- (NSString *)sn_baseUrl {
    return nil;
}

- (NSString *)sn_customUrl {
    return _customUrl;
}

- (id)sn_buildInParameters {
    return nil;
}

- (BOOL)sn_checkResponse:(SNBaseRequest *)request
          responseObject:(id)responseObject {
    return NO;
}

#pragma mark 对外
- (instancetype)initWithBuilder:(SNDefaultRequestBuilder *)builder {
    if (self = [super init]) {
        _requestMethod = builder.requestMethod;
        _responseType = builder.responseType;
        _parameters = builder.parameters;
        _customUrl = builder.customUrl;
    }
    return self;
}


+ (instancetype)createWithBuilder:(BuilderBlock)builderBlock {
    NSParameterAssert(builderBlock);
    SNDefaultRequestBuilder *builder = [[SNDefaultRequestBuilder alloc] init];
    builderBlock(builder);
    return [builder build];
}

@end
