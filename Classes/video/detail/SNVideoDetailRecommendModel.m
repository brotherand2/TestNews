//
//  SNVideoDetailRecommendModel.m
//  sohunews
//
//  Created by jojo on 13-9-13.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoDetailRecommendModel.h"
#import "SNURLJSONResponse.h"
#import "NSDictionaryExtend.h"
#import "SNVideoObjects.h"


extern SNURLRequest * configuredVideoRequest(NSString *url, id delegate, id userInfo);

@interface SNVideoDetailRecommendModel ()

@property (nonatomic, copy) NSString *nextCursor;
@property (nonatomic, copy) NSString *preCursor;
@property (nonatomic, strong) SNURLRequest *currentRequest;

@end

@implementation SNVideoDetailRecommendModel
@synthesize delegate = _delegate;
@synthesize nextCursor = _nextCursor;
@synthesize preCursor = _preCursor;
@synthesize currentRequest = _currentRequest;
@synthesize messageId = _messageId;
@synthesize hasMore = _hasMore;
@synthesize totalCount = _totalCount;
@synthesize videos = _videos;

- (void)dealloc {
    self.delegate = nil;
    
     //(_nextCursor);
     //(_preCursor);
    
    [_currentRequest.delegates removeObject:self];
     //(_currentRequest);
     //(_messageId);
    
     //(_videos);
    
}

- (NSMutableArray *)videos {
    if (!_videos) {
        _videos = [[NSMutableArray alloc] init];
    }
    return _videos;
}

#pragma mark - public methods

- (id)initRecomemndModelWithMid:(NSString *)mid {
    if (self = [super init]) {
        self.messageId = mid;
        self.nextCursor = @"0";
    }
    return self;
}

+ (SNVideoDetailRecommendModel *)videoRecommendModelWithMid:(NSString *)mid {
    
    SNVideoDetailRecommendModel *aModel = [SNVideoDetailRecommendModel new];
    aModel.messageId = mid;
    aModel.nextCursor = @"0";
    return aModel;
}

- (NSArray *)loadRecommendVideosFromLocalCache {
    return nil;
}

- (void)cancelRequest {
    [self.currentRequest cancel];
    [self.currentRequest.delegates removeObject:self];
}
- (void)loadRecommendVideosFromServer {
    [self.currentRequest cancel];
    NSString *reqUrl = [NSString stringWithFormat:kSNVideoDetailRecommendUrlV2, self.messageId, self.nextCursor];
    self.currentRequest = configuredVideoRequest(reqUrl, self, nil);
    self.currentRequest.cacheExpirationAge = kSNVideoDetailRecommendCacheExpirationAge;
    self.currentRequest.cachePolicy = TTURLRequestCachePolicyDefault;
    [self.currentRequest send];
}

- (void)loadRecommendVideosMoreFromServer {
    [self.currentRequest cancel];
    NSString *reqUrl = [NSString stringWithFormat:kSNVideoDetailRecommendUrlV2, self.messageId, self.nextCursor];
    self.currentRequest = configuredVideoRequest(reqUrl, self, @"more");
    [self.currentRequest send];
}

#pragma mark - TTURLRequestDelegate

- (void)requestDidStartLoad:(TTURLRequest*)request {
    if (request == self.currentRequest) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoRecommendModelDidStartLoad:)]) {
            [self.delegate performSelectorOnMainThread:@selector(videoRecommendModelDidStartLoad:) withObject:self waitUntilDone:YES];
        }
    }
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
    if (request == self.currentRequest) {
        SNURLJSONResponse *jsonRes = request.response;
        SNDebugLog(@"%@-:\nurl %@\njsonData \n%@", NSStringFromClass([self class]), request.urlPath, jsonRes.rootObject);
        if ([jsonRes.rootObject isKindOfClass:[NSDictionary class]]) {
            BOOL isMore = !!request.userInfo;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self parseRecommendData:jsonRes.rootObject isMore:isMore];
            });
        }
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    if ([self.delegate respondsToSelector:@selector(videoRecommendModelDidFailLoadWithError:model:)]) {
        [self.delegate videoRecommendModelDidFailLoadWithError:error model:self];
    }
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
    
}

#pragma mark - data parsing

- (void)parseRecommendInfoData:(NSDictionary *)dataDic {
    // has more
    _hasMore = ([dataDic intValueForKey:@"hasnext" defaultValue:0] == 1);
    _totalCount = [dataDic intValueForKey:@"totalCount" defaultValue:0];
    self.nextCursor = [NSString stringWithFormat:@"%lld", [dataDic longlongValueForKey:@"nextCursor" defaultValue:0]];
    self.preCursor = [NSString stringWithFormat:@"%lld", [dataDic longlongValueForKey:@"preCursor" defaultValue:0]];
}

- (void)parseRecommendData:(NSDictionary *)dataDic isMore:(BOOL)isMore {
    [self parseRecommendInfoData:dataDic];
    
    NSArray *videoDataArray = [dataDic arrayValueForKey:@"data" defaultValue:nil];
    if (!isMore) {
        [self.videos removeAllObjects];
    }
    
    NSMutableArray *moreVideos = [NSMutableArray array];
    
    for (NSDictionary *videoDic in videoDataArray) {
        if ([videoDic isKindOfClass:[NSDictionary class]]) {
            SNVideoData *aVideoItem = [[SNVideoData alloc] initWithDict:videoDic];
            [self.videos addObject:aVideoItem];
            if (isMore) {
                [moreVideos addObject:aVideoItem];
            }
        }
    }
    
    // todo@jojo save data to db
    
    // notify
    dispatch_async(dispatch_get_main_queue(), ^{
        [SNNotificationManager postNotificationName:kSNVideoDetialRecommendModelDidFinishLoadNotification
                                                            object:self
                                                          userInfo:@{@"result": @(0), @"isMore" : @(isMore), @"moreData" : moreVideos}];
    });
}

@end
