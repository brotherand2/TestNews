//
//  SNVideoDetailModel.m
//  sohunews
//
//  Created by jojo on 13-8-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoDetailModel.h"
#import "SNURLJSONResponse.h"

extern SNURLRequest * configuredVideoRequest(NSString *url, id delegate, id userInfo);


@interface SNVideoDetailModel ()

@property (nonatomic, strong) SNURLRequest *refreshRequest;
@property (nonatomic, strong) SNURLRequest *refreshShareContentRequest;

@end

@implementation SNVideoDetailModel
@synthesize vid = _vid, mid = _mid, channelId = _channelId;

@synthesize refreshRequest = _refreshRequest;
@synthesize refreshShareContentRequest = _refreshShareContentRequest;

@synthesize videoDetailItem = _videoDetailItem;
@synthesize shareContent = _shareContent;

- (void)dealloc {
    [self cancelAndCleanAllRequest];
    
     //(_vid);
     //(_mid);
     //(_channelId);
    
     //(_refreshRequest);
     //(_refreshShareContentRequest);
    
     //(_videoDetailItem);
     //(_shareContent);
    
}

- (BOOL)refreshVideoDetail {
    if (!self.mid || ![self.mid isKindOfClass:[NSString class]]) {
        SNDebugLog(@"%@-%@ : error with mid %@", NSStringFromClass([self  class]), NSStringFromSelector(_cmd), self.mid);
        return NO;
    }
    if (self.refreshRequest && self.refreshRequest.isLoading) {
        SNDebugLog(@"%@-%@ : an existed request already running !", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    NSString *requestUrl = [NSString stringWithFormat:kVideoDetailUrl, self.mid];
    self.refreshRequest = configuredVideoRequest(requestUrl, self, nil);
    [self.refreshRequest send];
    return YES;
}

- (BOOL)refreshShareContent {
    if (!self.mid || ![self.mid isKindOfClass:[NSString class]]) {
        SNDebugLog(@"%@-%@ : error with mid %@", NSStringFromClass([self  class]), NSStringFromSelector(_cmd), self.mid);
        return NO;
    }
    if (self.refreshShareContentRequest && self.refreshShareContentRequest.isLoading) {
        SNDebugLog(@"%@-%@ : an existed request already running !", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return NO;
    }
    
    NSString *requestUrl = [NSString stringWithFormat:kVideoShareContentUrl, self.mid];
    self.refreshShareContentRequest = configuredVideoRequest(requestUrl, self, nil);
    [self.refreshShareContentRequest send];
    return YES;
}

#pragma mark - TTURLRequestDelegate

- (void)requestDidFinishLoad:(TTURLRequest*)request {
    [request.delegates removeAllObjects];
    // video detail
    if (self.refreshRequest == request) {
        SNURLJSONResponse *jsonObj = request.response;
        if (jsonObj && [jsonObj isKindOfClass:[SNURLJSONResponse class]]) {
            if ([jsonObj.rootObject isKindOfClass:[NSDictionary class]]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self parseVideoDetail:jsonObj.rootObject];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SNNotificationManager postNotificationName:kSNVideoDetailDidFinishLoadNotification
                                                                            object:self
                                                                          userInfo:nil];
                    });
                });
            }
        }
    }
    
    // video share content
    else if (self.refreshShareContentRequest == request) {
        SNURLJSONResponse *jsonObj = request.response;
        if (jsonObj && [jsonObj isKindOfClass:[SNURLJSONResponse class]]) {
            if ([jsonObj.rootObject isKindOfClass:[NSDictionary class]]) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self parseVideoShareContent:jsonObj.rootObject];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SNNotificationManager postNotificationName:kSNVideoDetailShareContentDidFinishLoadNotification
                                                                            object:self
                                                                          userInfo:nil];
                    });
                });
            }
        }
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    [request.delegates removeAllObjects];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    [request.delegates removeAllObjects];
}

#pragma mark - private & parse methods

- (void)parseVideoDetail:(NSDictionary *)jsonDic {
    if ([jsonDic isKindOfClass:[NSDictionary class]]) {
        self.videoDetailItem = [[SNVideoData alloc] initWithDict:[jsonDic dictionaryValueForKey:@"message" defalutValue:nil]];
    }
}

- (void)parseVideoShareContent:(NSDictionary *)jsonDic {
    self.shareContent = [jsonDic stringValueForKey:@"info" defaultValue:nil];
}

- (void)cancelAndCleanAllRequest {
    if (_refreshRequest) {
        [_refreshRequest.delegates removeObject:self];
        [_refreshRequest cancel];
    }
    self.refreshRequest = nil;
    
    if (_refreshShareContentRequest) {
        [_refreshShareContentRequest.delegates removeObject:self];
        [_refreshShareContentRequest cancel];
    }
    self.refreshShareContentRequest = nil;
}

@end
