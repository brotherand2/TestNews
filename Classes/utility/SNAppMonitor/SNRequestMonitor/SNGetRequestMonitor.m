//
//  SNGetRequestMonitor.m
//  sohunews
//
//  Created by WongHandy on 8/15/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNGetRequestMonitor.h"
#import "SNDNSResolver.h"
#import "GCDAsyncSocket.h"
#import "SNStopWatch.h"
//#import "ASIHTTPRequest.h"
#import "SNPickStatisticRequest.h"

@implementation SNGetRequestMonitorKPI


@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface SNGetRequestMonitor() {
    SNStopWatch *_stopWatch;
    NSString *_resolvedIpAddress;
    NSURLConnection *_connection;
    BOOL _isRequestFinished;
}
@property(nonatomic, strong, readwrite) NSURL *url;
@property(nonatomic, strong, readwrite) SNGetRequestMonitorKPI *kpi;
@end

@implementation SNGetRequestMonitor

- (id)initWithURL:(NSURL *)url {
    if (self = [super init]) {
        _url = url;
        _kpi = [[SNGetRequestMonitorKPI alloc] init];
        _stopWatch = [SNStopWatch watch];
    }
    return self;
}

- (void)dealloc {
    [self recycle];
}

- (void)recycle {
    _url = nil;
    
    _kpi = nil;
    
    [_stopWatch stop];
    _stopWatch = nil;
    
    _resolvedIpAddress = nil;
    
    [_connection cancel];
    _connection = nil;
}

#pragma mark - Public method
- (BOOL)start {
    if (!_url) {
        SNDebugLog(@"Cant monitor for nil url.");
        return NO;
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //request url
            _kpi.urlString = [_url absoluteString];
            NSRange questionMarkRange = [_kpi.urlString rangeOfString:@"?"];
            if (questionMarkRange.location != NSNotFound) {
                _kpi.urlString = [_kpi.urlString substringToIndex:questionMarkRange.location];
            }

            //DNS resolve timecost
            SNDNSResolver *resolver = [[SNDNSResolver alloc] initWithURL:_url]; //lijian 2015.01.29 修改内存泄露
            [_stopWatch begin];
            [resolver resolve];
            [_stopWatch stop];
            _kpi.dnsResolveTimeCost = _stopWatch.diff;
            _resolvedIpAddress = nil;
            _resolvedIpAddress = [resolver.resolvedIpAddress copy];
            SNDebugLog(@"DNS resolving...");
            
            //Connect timecost
            _isRequestFinished = NO;
            _connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:_url] delegate:self startImmediately:NO];
            [_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
            [_stopWatch begin];
            [_connection start];
            SNDebugLog(@"Request will connect...");
            while (!_isRequestFinished) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        });
        return YES;
    }
}

#pragma mark - Private

- (void)uploadStatInfo {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:[NSString stringWithFormat:@"%f",_kpi.dnsResolveTimeCost*1000] forKey:@"dns"];
    [params setValue:[NSString stringWithFormat:@"%f",_kpi.conectTimeCost*1000] forKey:@"connect"];
    [params setValue:[NSString stringWithFormat:@"%f",_kpi.requestTimeCost*1000] forKey:@"request"];
    [params setValue:[NSString stringWithFormat:@"%f",_kpi.responseTimeCost*1000] forKey:@"response"];
    [params setValue:[NSString stringWithFormat:@"%f",_kpi.receiveDataTimeCost*1000] forKey:@"download"];
    [params setValue:[NSString stringWithFormat:@"%zd",_kpi.responseDataLengthInBytes] forKey:@"rspSize"];
    [params setValue:[NSString stringWithFormat:@"%zd",_kpi.responseStatusCode] forKey:@"rspCode"];
    [params setValue:_kpi.urlString forKey:@"objType"];
    
    [[[SNPickStatisticRequest alloc] initWithDictionary:params andStatisticType:PickLinkDotGifTypeReqstat] send:nil failure:nil];
    [self recycle];

}

#pragma mark - NSURLConnectionDelegate/NSURLConnectionDataDelegate
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    [_stopWatch stop];
    _kpi.conectTimeCost = _stopWatch.diff;//Connect timecost
    SNDebugLog(@"Request is connected...");
    
    //Request timecost
    SNDebugLog(@"Request will be send...");
    [_stopWatch begin];
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_stopWatch stop];
    _kpi.requestTimeCost = _stopWatch.diff;//Request timecost
    SNDebugLog(@"Finish sending request");
    
    //response statuscode
    _kpi.responseStatusCode = ((NSHTTPURLResponse *)response).statusCode;
    
    //Response timecost
    [_stopWatch begin];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    SNDebugLog(@"Get response...");
    [_stopWatch stop];
    _kpi.responseTimeCost = _stopWatch.diff;//Response timecost
    
    //response datasize
    _kpi.responseDataLengthInBytes = data.length;
    
    //Download data timecost
    SNDebugLog(@"Receiving data...");
    [_stopWatch begin];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _isRequestFinished = YES;
    
    SNDebugLog(@"Finish request...");
    [_stopWatch stop];
    _kpi.receiveDataTimeCost = _stopWatch.diff;//Receive data timecost
    
    //上传采样信息
    [self uploadStatInfo];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    _isRequestFinished = YES;
    
    SNDebugLog(@"Finish request...");
    [_stopWatch stop];
    _kpi.receiveDataTimeCost = _stopWatch.diff;//Receive data timecost
    
    //上传采样信息
    [self uploadStatInfo];
}

@end
