//
//  JKBridgeHandler.m
//  sohunews
//
//  Created by sevenshal on 16/6/3.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "JKBridgeHandler.h"
#import "JKRequestManager.h"

#import <UIKit/UIKit.h>

@interface JKBridgeHandler()<NSURLConnectionDelegate>

@property(strong, nonatomic) NSURLRequest* request;
@property(strong, nonatomic) NSMutableData* mutableData;
@property(copy,nonatomic) HANDLER callback;
@property(copy,nonatomic) HANDLER handler;
@property(strong, nonatomic) NSString* MIMEType;
@property(assign, nonatomic) NSInteger statusCode;
@property(assign, nonatomic) NSURLConnection* connection;

@end

@implementation JKBridgeHandler

-(void)handleUrl:(NSURLRequest*) request callback:(HANDLER)callback{
    NSString* funName = [request.URL lastPathComponent];
    if (funName==nil) {
        callback(self, nil, nil);
    }
    self.request = request;
    self.callback = callback;
    if ([funName isEqualToString:@"gif2png"]) {
        [self gif2png];
    }else if([funName isEqualToString:@"cross_domain"]){
        [self cross_domain];
    }else if([funName isEqualToString:@"local_file"]){
        [self local_file];
    }else {
        self.request = nil;
        self.callback = nil;
    }
}

-(void)gif2png {
    self.handler = ^(JKBridgeHandler* _self, NSData *data, NSString* mimeType) {
        UIImage* image = [UIImage imageWithData:data];
        data = UIImagePNGRepresentation(image);
        _self.callback(_self, data, @"image/png");
    };
    [self doRequest];
}

-(void)cross_domain{
    self.handler = ^(JKBridgeHandler* _self,NSData *data, NSString* mimeType) {
        _self.callback(_self, data, mimeType);
    };
    [self doRequest];
}

-(void)local_file{
    NSString* url = [[_request.URL query] substringFromIndex:@"url=".length];
    NSData* data = [NSData dataWithContentsOfFile:url];
    _callback(self, data, @"application/octet-stream");
}

-(void)doRequest{
    NSString* url = [[_request.URL query] substringFromIndex:@"url=".length];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    if ([[UIDevice currentDevice].systemVersion floatValue]>=9.0) {
//        NSURLSession *session = [NSURLSession sharedSession];
//        [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
//                                                                  NSURLResponse *response,
//                                                                  NSError *error) {
//            NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
//            if (error || httpResponse.statusCode!=200) {
//                _callback(nil, nil);
//            }else {
//                if (_handler != nil) {
//                    _handler(data, response.MIMEType);
//                }
//            }
//        }] resume];
//    }else{
        _connection = [NSURLConnection connectionWithRequest:request delegate:self];
        [_connection start];
//    }
}


-(void)stopHandle{
    [_connection cancel];
    _connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _mutableData = [[NSMutableData alloc] init];
    _MIMEType = response.MIMEType;
    _statusCode = ((NSHTTPURLResponse*)response).statusCode;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_mutableData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (_statusCode==200) {
        _handler(self, _mutableData, _MIMEType);
    }else{
        _callback(self, nil, nil);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _callback(self, nil, nil);
}

@end
