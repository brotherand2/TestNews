//
//  SNThirdPartRequestManager.m
//  sohunews
//
//  Created by lhp on 12/25/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNThirdPartRequestManager.h"
#import "SNURLDataResponse.h"

@interface SNThirdPartRequestManager ()

@end

@implementation SNThirdPartRequestManager
@synthesize urlArray;

+ (SNThirdPartRequestManager *)sharedInstance {
    static SNThirdPartRequestManager *_sharedInstance = nil;
    @synchronized(self) {
        if (!_sharedInstance) {
            _sharedInstance = [[SNThirdPartRequestManager alloc] init];
        }
    }
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        connectionArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)sendRequestWithUrl:(NSString *) url
{
    if (url && url.length > 0) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [connection start];
        [connectionArray addObject:connection];
    }
}

- (void)sendAllRequest {
    if ([self.urlArray count] && [[SNUtility getApplicationDelegate] currentNetworkStatus] == ReachableViaWiFi) {
        for (NSDictionary *urlDic in self.urlArray) {
            if (urlDic && [urlDic isKindOfClass:[NSDictionary class]]) {
                NSString *url = [urlDic objectForKey:@"url"];
                [self sendRequestWithUrl:url];
            }
        }
    }
}

- (void)cancel
{
    for (NSURLConnection *conection in connectionArray) {
        [conection cancel];
    }
}

#pragma mark -
#pragma mark NSURLConnectionDelegate

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    SNDebugLog(@"SNThirdPartRequest succeed!");
	//针对外网带量需求,无需处理返回结果
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    SNDebugLog(@"SNThirdPartRequest failed!");
}

- (void)dealloc
{
    [self cancel];
     //(urlArray);
     //(connectionArray);
}

@end
