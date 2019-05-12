//
//  SNRollingGroupPhotoModel.h
//  sohunews
//
//  Created by Dan on 10/26/13.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNRollingGroupPhotoModel.h"
#import "SNURLJSONResponse.h"
#import "SNDBManager.h"
#import "NSObject+YAJL.h"
#import "SNPhotoChannelNewsRequest.h"

@interface SNRollingGroupPhotoModel ()
@property (nonatomic, assign) BOOL requestLoaing;
@end

@implementation SNRollingGroupPhotoModel

- (id)init {
	self = [super init];
	if (self) {
        isFirst = YES;
        
        self.targetType = kGroupPhotoChannel;
        self.typeId = kGroupPhotoChannelDefaultId;
    }
	return self;
}

//发起网络请求获取hot photo news
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    [super load:cachePolicy more:more];
}

//- (void)requestHotPhotos:(BOOL)isASyn {
//    int pageSize = KPhotoPaginationNum;
//    if (!_more) {
//        _page = 0;
//        pageSize =  KPhotoPaginationNum;
//        self.lastOffset = nil;
//    } else {
//        if (_page == 0) {
//            _page = 1;
//        }
//    }
//    
//    NSString *url = [NSString stringWithFormat:kUrlPhotoListInChannel, _page + 1, pageSize, self.typeId];
//    if (_more && self.offSet) {
//        self.isRecreate = NO;
//        url = [NSString stringWithFormat:@"%@&offset=%@", url, self.offSet];
//    }
//    
//	if (!_request) {
//		_request = [SNURLRequest requestWithURL:url delegate:self isParamP:YES scookie:YES];
//		_request.cachePolicy = TTURLRequestCachePolicyNoCache;
//	} else {
//        if (![_request.delegates containsObject:self]) {
//            [_request.delegates addObject:self];
//        }
//		_request.urlPath = url;
//	}
//    
//    if (isRefreshManually || _more) {
//        _request.isShowNoNetWorkMessage = YES;
//    } else {
//        _request.isShowNoNetWorkMessage = NO;
//    }
//	
//	_request.response = [[SNURLJSONResponse alloc] init];
//	if (isASyn) {
//		[_request send];
//	} else {
//		[_request sendSynchronously];
//	}
//}

- (void)requestHotPhotos:(BOOL)isASyn {// rt=json&pageNo=%d&pageSize=%d&channelId=%@
    int pageSize = KPhotoPaginationNum;
    if (!_more) {
        _page = 0;
        pageSize =  KPhotoPaginationNum;
        self.lastOffset = nil;
    } else {
        if (_page == 0) {
            _page = 1;
        }
    }
    NSMutableDictionary *params = [ NSMutableDictionary dictionaryWithCapacity:4];
    [params setValue:[NSString stringWithFormat:@"%zd",_page + 1] forKey:@"pageNo"];
    [params setValue:[NSString stringWithFormat:@"%zd",pageSize] forKey:@"pageSize"];
    [params setValue:self.typeId forKey:@"channelId"];
    if (_more && self.offSet) {
        self.isRecreate = NO;
        [params setValue:self.offSet forKey:@"offset"];
    }
    if (isRefreshManually || _more) {
        if (![SNUtility getApplicationDelegate].isNetworkReachable) {
            [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
            return;
        }
    }
    self.requestLoaing = YES;
    [[[SNPhotoChannelNewsRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id rootData) {
        self.requestLoaing = NO;
        [super requestDidFinishLoadWithResponse:rootData];
    } failure:^(SNBaseRequest *request, NSError *error) {
        self.requestLoaing = NO;
        [super requestDidFinishLoad:nil];
    }];
    [self didStartLoad];
}

- (BOOL)isLoading {
    return self.requestLoaing;
}
//- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
//    [super requestDidFinishLoad:nil];
//}


- (NSDate *)refreshedTime {
	NSDate *time = nil;
    NSString *timeKey = [NSString stringWithFormat:@"channel_%@_refresh_time", self.typeId];
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:timeKey];
	if (data && [data isKindOfClass:[NSDate class]]) {
		time = data;
	}
	return time;
}

- (void)setRefreshedTime {
	NSString *timeKey = [NSString stringWithFormat:@"channel_%@_refresh_time", self.typeId];
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:timeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setRefreshStatusOfUpgrade {
    NSString *key = [NSString stringWithFormat:@"channel_%@_force_refresh", self.typeId];
	[[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
