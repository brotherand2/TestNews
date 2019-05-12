//
//  SNNextSubRequestManager.m
//  sohunews
//
//  Created by H on 15/4/20.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//



#import "SNNextSubRequestManager.h"

@implementation SNNextSubRequestManager

+ (SNNextSubRequestManager *)sharedInstance {
    static SNNextSubRequestManager * sharedManager = nil;
    static dispatch_once_t t;
    dispatch_once(&t, ^{
        sharedManager = [[SNNextSubRequestManager alloc] init] ;
        sharedManager.subNewsList = [NSMutableArray array];
    });
    return sharedManager;
}

- (void)startAfRequestWithURL:(NSString *)URL {
    NSURLRequest * request  = [NSURLRequest requestWithURL:[NSURL URLWithString:URL]];
    _afOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [_afOperation start];
}

- (void)startRequestWithQuery:(NSDictionary *)query delegate:(id<SNNextSubRequestManagerDelegate>)delegate {

    self.delegate = delegate;
    if (_afOperation) {
        [_afOperation cancel];
    }
    
    NSString * url = kGetNextSubContextUrl;
    for (NSString * parameter in query) {
        url = [url stringByAppendingString:[NSString stringWithFormat:@"%@=",parameter]];
        url = [url stringByAppendingString:[NSString stringWithFormat:@"%@&",[query objectForKey:parameter ]]];
    }
    
    [self startAfRequestWithURL:url];
    __weak __typeof(&*self)weakSelf = self;
    [_afOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary * responseDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (responseObject && delegate && [delegate respondsToSelector:@selector(nextSubDidFinishedRequest:)]) {
            [weakSelf.delegate performSelector:@selector(nextSubDidFinishedRequest:) withObject:responseDic];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    
}


@end
