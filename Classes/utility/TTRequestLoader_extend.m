//
//  TTRequestLoader_extend.m
//  sohunews
//
//  Created by jojo on 13-8-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "TTRequestLoader_extend.h"
#import "JRSwizzle.h"

@implementation TTRequestLoader (extend)

+ (void)swithExtendMethod {
    NSError *error = nil;
    [self jr_swizzleMethod:@selector(dispatchLoaded:) withMethod:@selector(dispatchLoadedExtend:) error:&error];
    if (error) SNDebugLog(@"%@ - %@ error : %@",
                   NSStringFromClass([self class]),
                   NSStringFromSelector(_cmd),
                   error.localizedDescription);
}

- (void)dispatchLoadedExtend:(NSDate*)timestamp {
    for (TTURLRequest* request in [[_requests copy] autorelease]) {
        request.timestamp = timestamp;
        request.isLoading = NO;
        
        for (id<TTURLRequestDelegate> delegate in request.delegates) {
            // 上传log的话  开销太大  设置一个key来检测最后一个请求 
            if (delegate && [delegate respondsToSelector:@selector(requestDidFinishLoad:)]) {
                [delegate requestDidFinishLoad:request];
            }
        }
    }
}

@end
