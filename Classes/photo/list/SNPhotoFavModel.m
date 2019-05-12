//
//  SNPhotoFavModel.m
//  sohunews
//
//  Created by qi pei on 3/30/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoFavModel.h"
#import "SNURLJSONResponse.h"

@implementation SNPhotoFavModel 

@synthesize delegate;

- (id)initWithDelegate:(id)aDelegate {
    if ((self = [super init])) {
        self.delegate = aDelegate;
    }
    return self;
}

-(void)favoriteCurrentNews:(NSString *)newsId termId:(NSString *)termId {
    NSString *url = nil;
    SNDebugLog(@"%@---%@",newsId,termId);
    if ([termId isEqualToString:@"0"]) {
        url = [NSString stringWithFormat:kUrlLikeNewsByGid, newsId];
    } else {
        url = [NSString stringWithFormat:kUrlLikeNewsByNewsId, newsId, termId];
    }
    if (!_favRequest) {
		_favRequest = [[SNURLRequest requestWithURL:url delegate:self] retain];
        _favRequest.isShowNoNetWorkMessage = NO;
		_favRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
	} else {
		_favRequest.urlPath = url;
	}
	
	_favRequest.response = [[[SNURLJSONResponse alloc] init] autorelease];
    
    if (delegate && [delegate respondsToSelector:@selector(favRequestWillStart)]) {
        [delegate favRequestWillStart];
    }
    [_favRequest send];
}

- (void)requestDidFinishLoad:(id)data {
    SNURLJSONResponse *dataResponse = (SNURLJSONResponse *)_favRequest.response;
	id rootData = dataResponse.rootObject;
    
    int status = 0;
    //parse Json Data
    if ([rootData isKindOfClass:[NSDictionary class]]) {
        status = [(NSString *)[rootData objectForKey:kStatus] intValue];
    }
    if (status == 1) {
        if (delegate && [delegate respondsToSelector:@selector(favRequestFinished:)]) {
            [delegate favRequestFinished:1];
        }
    }
    else if (status == 0) {
        // 离线内容 提交喜欢的请求 失败
        if (delegate && [delegate respondsToSelector:@selector(favRequestFinished:)]) {
            [delegate favRequestFinished:4];
        }
    }
    else {
        if (delegate && [delegate respondsToSelector:@selector(favRequestFinished:)]) {
            [delegate favRequestFinished:2];
        }
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    if (delegate && [delegate respondsToSelector:@selector(favRequestFinished:)]) {
        [delegate favRequestFinished:3];
    }
}

-(void)cancelRequest {
    [_favRequest cancel];
}

-(void)dealloc {
    [_favRequest cancel];
    TT_RELEASE_SAFELY(_favRequest);
    [super dealloc];
}

@end
