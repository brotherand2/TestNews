//
//  SNHotPhotoModel.m
//  sohunews
//
//  Created by ivan on 3/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoModel.h"
#import "SNURLJSONResponse.h"
#import "SNDBManager.h"
#import "SNRollingNewsPublicManager.h"

#import "NSObject+YAJL.h"

@interface SNPhotoModel(Private)

-(void)requestHotPhotos:(BOOL)isASyn;
-(void)parseJsonData:(id)aData;
-(void)saveAsCache:(NSMutableArray *)aDataArray;

@end

@implementation SNPhotoModel

@synthesize hotPhotos, allPhotos, targetType, typeId, isFirst, more = _more;
@synthesize isQueryTargetChanged, page = _page ,offSet, lastOffset;
@synthesize pageWhenViewReleased, timelineWhenViewReleased, firstAndNoCache;

- (id)init {
	self = [super init];
	if (self) {
        isFirst = YES;
    }
	return self;
}

//发起网络请求获取hot photo news
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more 
{
    [super load:cachePolicy more:more];
    
    if (!self.isLoading) {
		_more = more;
        
        self.hasNoMore = NO;
        
        if (!self.targetType) {
            self.targetType = kGroupPhotoCategory;
            self.typeId = kGroupPhotoDefaultId;
        }
        
        if (cachePolicy == TTURLRequestCachePolicyLocal) {
            [self loadCacheFromDB];
        } else {
            if (self.isRecreate && isFirst) {
                [self loadCacheFromDBByTimeline];
                if (self.hotPhotos.count > 0) {
                    [self didFinishLoad];
                } else {
                    [self requestHotPhotos:YES];
                }
            } else  {
                if (isFirst) {
                    [self loadCacheFromDB];
                }
                [self requestHotPhotos:YES];
            }
        }
    }
}

- (BOOL)isLoaded {
	return self.hotPhotos != nil;
}

- (BOOL)isLoadingMore {
    return _more;
}

- (void)loadCacheFromDBByTimeline {
    isFirst = NO;
    _page = pageWhenViewReleased;
    
    NSMutableArray *cacheList = [[[SNDBManager currentDataBase] getAllCachedPhotoByTimeline:timelineWhenViewReleased andType:self.targetType andTypeId:self.typeId] mutableCopy];
    self.timelineWhenViewReleased = nil;
    self.hotPhotos = [NSMutableArray array];
    self.allPhotos = [NSMutableArray array];
    
    [self.hotPhotos addObjectsFromArray:cacheList];
    [self.allPhotos addObjectsFromArray:cacheList];
    self.firstAndNoCache = (allPhotos.count == 0);
    if (!firstAndNoCache) {
        self.hasNoMore = NO;
    }
     //(cacheList);
   // [self didFinishLoad];
}

- (void)loadCacheFromDB {
    isFirst = NO;
    NSMutableArray *cacheList = [[[SNDBManager currentDataBase] getFirstCachedPhoto:timelineWhenViewReleased andType:self.targetType andTypeId:self.typeId] mutableCopy];
    self.timelineWhenViewReleased = nil;
    self.hotPhotos = [NSMutableArray array];
    self.allPhotos = [NSMutableArray array];
    
    [self.hotPhotos addObjectsFromArray:cacheList];
    [self.allPhotos addObjectsFromArray:cacheList];
    self.firstAndNoCache = (allPhotos.count == 0);
    if (!firstAndNoCache) {
        self.hasNoMore = NO;
    }

    if (cacheList.count > 0) {
        [self didFinishLoad];
    } else {
        [self didFinishLoad];
        //[self didFailLoadWithError:nil];
    }
    
     //(cacheList);
    
    if (_page <= 1) {
        self.offSet = [self offSetByTargetType:self.targetType typeId:self.typeId];
    }
}

- (void)requestHotPhotos:(BOOL)isASyn {
    int pageSize = KPhotoPaginationNum;
    SNDebugLog(@"pageWhenViewReleased:%d",pageWhenViewReleased);
    if (!_more) {
        _page = 0;
        pageSize =  KPhotoPaginationNum;
        self.lastOffset = nil;
    }
    SNDebugLog(@"%d",pageSize);
    NSString *url = nil;
    if ([self.targetType isEqualToString:kGroupPhotoCategory]) {
        url = [NSString stringWithFormat:kUrlCategoryPhoto, _page + 1, pageSize, self.typeId];
    } else if ([self.targetType isEqualToString:kGroupPhotoTag]) {
        url = [NSString stringWithFormat:kUrlTagPhoto, _page + 1, pageSize, self.typeId];
    }
    if ((_more && self.offSet) || (self.isRecreate && self.offSet)) {
        self.isRecreate = NO;
        url = [NSString stringWithFormat:@"%@&offset=%@",url,self.offSet];
    }
    
    SNDebugLog(@"SNPhotoModel url %@", url);
    
	if (!_request) {
		_request = [SNURLRequest requestWithURL:url delegate:self isParamP:YES scookie:YES];
		_request.cachePolicy = TTURLRequestCachePolicyNoCache;
	} else {
        if (![_request.delegates containsObject:self]) {
            [_request.delegates addObject:self];
        }
		_request.urlPath = url;
	}
    
    if (isRefreshManually || _more) {
        _request.isShowNoNetWorkMessage = YES;
    } else {
        _request.isShowNoNetWorkMessage = NO;
    }
    
	_request.response = [[SNURLJSONResponse alloc] init];
	if (isASyn) {
		[_request send];
	} else {
		[_request sendSynchronously];
	}
}

- (void)saveAsCache:(NSMutableArray *)aDataArray {
	if (!aDataArray || [aDataArray count] <= 0) {
		return;
	}
	
	[[SNDBManager currentDataBase] addMultiGroupPhoto:aDataArray];
}

- (void)requestDidFinishLoadWithResponse:(id)rootData {
    if (!_more) {
        self.allPhotos = [NSMutableArray array];
    }
    self.hotPhotos = [NSMutableArray array];

    if ([rootData isKindOfClass:[NSDictionary class]]) {
        [self parseJsonData:rootData];
        [self setPhotoTimelineIndex];
        [self saveAsCache:self.hotPhotos];
        [super requestDidFinishLoad:_request];
    } else {
        [super requestDidFinishLoad:_request];
    }
    
    if (!_more) {
        [self setRefreshedTime];
        [self setRefreshStatusOfUpgrade];
        [[SNAppStateManager sharedInstance] loadedChannelNewsWith:self.channelId];
    }

}

- (void)requestDidFinishLoad:(id)data {
    
    if (!data) {
        [super requestDidFinishLoad:nil];
        return;
    }
    
    if (!_more) {
        self.allPhotos = [NSMutableArray array];
        //[[SNDBManager currentDataBase] deleteCachedPhotosByType:self.targetType
        //                                                                                      andTypeId:self.typeId];
    }
    self.hotPhotos = [NSMutableArray array];
	
	SNURLJSONResponse *dataResponse = (SNURLJSONResponse *)_request.response;
	id rootData = dataResponse.rootObject;
    
    //id newsData = [rootData objectForKey:kHotNews];
    if ([rootData isKindOfClass:[NSDictionary class]]) {
        [self parseJsonData:rootData];
        [self setPhotoTimelineIndex];
        [self saveAsCache:self.hotPhotos];
        [super requestDidFinishLoad:_request];
	} else {
		[super requestDidFinishLoad:_request];
	}
    
    if (!_more) {
        [self setRefreshedTime];
        [self setRefreshStatusOfUpgrade];
        [[SNAppStateManager sharedInstance] loadedChannelNewsWith:self.channelId];
    }
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    SNDebugLog(@"didFailLoadWithError---%@", [error localizedDescription]);
    NSString *timelineIndex = nil;
    
    if (_more) {
        GroupPhotoItem *lastPhoto = (GroupPhotoItem *)[self.allPhotos lastObject];
        timelineIndex = lastPhoto.timelineIndex;
    }
    NSMutableArray *cacheList = [[[SNDBManager currentDataBase] getCachedGroupPhotoByTimelineIndex:timelineIndex andType:self.targetType andTypeId:self.typeId] mutableCopy];
    self.hotPhotos = [NSMutableArray array];
    
    if ([cacheList count] > 0) {
        if (!self.allPhotos) {
            self.allPhotos = [NSMutableArray array];
        }
        
        [self.hotPhotos addObjectsFromArray:cacheList];
        [self.allPhotos addObjectsFromArray:cacheList];
        
        self.hasNoMore = NO;
    }
    
     //(cacheList);
    [super requestDidFinishLoad:request];
}

-(BOOL)isContainsPhotoItem:(GroupPhotoItem *)aItem {
    BOOL exist = NO;
    for (GroupPhotoItem *item in self.allPhotos) {
        if ([item.newsId isEqualToString:aItem.newsId]
            && [item.typeId isEqualToString:aItem.typeId]
            && [item.type isEqualToString:aItem.type]) {
            exist = YES;
            break;
        }
    }
    return exist;
}

- (void)parseJsonData:(id)aData {
    id newsData = [aData objectForKey:kHotNews];
    if ([newsData isKindOfClass:[NSArray class]]) {
        for (NSDictionary *newsDic in newsData) {
            GroupPhotoItem *hotNews = [[GroupPhotoItem alloc] init];
            hotNews.newsId = [newsDic stringValueForKey:kGid defaultValue:nil];
            hotNews.title = [newsDic objectForKey:kHotTitle];
            hotNews.sublink = [newsDic objectForKey:kSubLink];
            hotNews.time = [newsDic stringValueForKey:kTime defaultValue:@""];
            NSNumber *cnum = [newsDic objectForKey:kCommentNum];
            hotNews.commentNum = [cnum stringValue];
            NSNumber *fnum = [newsDic objectForKey:kHotFavoriteNum];
            hotNews.favoriteNum = [fnum stringValue];
            NSNumber *inum = [newsDic objectForKey:kHotImageNum];
            hotNews.imageNum = [inum stringValue];
            hotNews.type = self.targetType;
            hotNews.typeId = self.typeId;
            
            //update readFlag from database    
            hotNews.readFlag = [[SNDBManager currentDataBase] checkPhotoNewsReadOrNot:hotNews.newsId 
                                                                               typeId:hotNews.typeId
                                                                                 type:hotNews.type];
            
            id imagesData = [newsDic objectForKey:kShareImageUrls];
            if ([imagesData isKindOfClass:[NSArray class]]) {
                hotNews.images = [NSMutableArray array];
                for (NSString *img in imagesData) {
                    [hotNews.images addObject:img];
                }
            }
            if (![self isContainsPhotoItem:hotNews]) {
                [self.allPhotos addObject:hotNews];
                [self.hotPhotos addObject:hotNews];
            }
             //(hotNews);
        }
        
        NSUInteger count = [(NSArray *)newsData count] ;
        if (count > 0) {
            _page++;
            self.hasNoMore = NO;
            [SNRollingNewsPublicManager sharedInstance].moreCellStatus = SNMoreCellLoadMore;
        }
        else{
            [SNRollingNewsPublicManager sharedInstance].moreCellStatus = SNMoreCellAllLoad;
        }
    }
    NSNumber *kOffsetNum = [aData objectForKey:kOffset];
    self.lastOffset = self.offSet;
    self.offSet = [kOffsetNum stringValue];
    
    // 加载列表第一页时，不一定会loadNetWork，所以需要保存offset，当只loadLocal时初始化offset，
    if (!_more) {
        [self saveOffset:self.offSet targetType:self.targetType typeId:self.typeId];
    }
}

- (void)saveOffset:(NSString *)offset targetType:(NSString *)aTargetType typeId:(NSString *)aTypeId {
    if (offset && aTargetType && aTypeId) {
        NSString *key = [NSString stringWithFormat:@"SNPhotoModel_%@_%@", aTargetType, aTypeId];
        [[NSUserDefaults standardUserDefaults] setObject:offset forKey:key];
    }
}

- (NSString *)offSetByTargetType:(NSString *)aTargetType typeId:(NSString *)aTypeId {
    if (aTargetType && aTypeId) {
        NSString *key = [NSString stringWithFormat:@"SNPhotoModel_%@_%@", aTargetType, aTypeId];
        NSString *offset = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        return offset;
    }
    return nil;
}


//计算出滚动新闻所在的时间线上的序号
//翻页的新闻是旧新闻，序号递减
//刷新的新闻是新新闻，序号递增
- (void)setPhotoTimelineIndex
{
    if (_more) {
        int minTimelineIndex = _minTimelineIndex;
        SNDebugLog(@"minTimelineIndex = %d", minTimelineIndex);
        //for (GroupPhotoItem *photo in [[self.hotPhotos reverseObjectEnumerator] allObjects]) {
        for (GroupPhotoItem *photo in self.hotPhotos) {
            photo.timelineIndex = [NSString stringWithFormat:@"%d", --minTimelineIndex];
        }
        _minTimelineIndex = minTimelineIndex;
    } else {
        NSString *maxIndex = [[SNDBManager currentDataBase] getMaxPhotoTimelineIndexByType:self.targetType andTypeId:self.typeId];
        int maxTimelineIndex = [maxIndex intValue];
        
        //和当前最大值拉开1000条(50页)的距离，确保这个最大值不会导致翻页后覆盖现有缓存的timelineIndex,
        //否则会导致很久不看新闻时翻页后和以前的新闻timelineIndex值重复。除非用户翻50页，还会重复，不过不太可能，50页呢。
        //就算每秒刷一次，每秒加1000，也需要3亿年(9223372036854775807/1000/60/60/24/30/12=296533309)才达到sqlite表里timelineIndex上限。
        maxTimelineIndex += KPaginationNum * 50;
        SNDebugLog(@"maxTimelineIndex = %d", maxTimelineIndex);
        _minTimelineIndex = maxTimelineIndex;
        for (GroupPhotoItem *photo in [[self.hotPhotos reverseObjectEnumerator] allObjects]) {
            photo.timelineIndex = [NSString stringWithFormat:@"%d", ++maxTimelineIndex];
        }
    }
}

-(void)setTargetType:(NSString *)aTargetType {
    if (![targetType isEqualToString:aTargetType]) {
        isQueryTargetChanged = YES;
    }
    
    if (targetType) {
         //(targetType);
    }
    
    targetType = [aTargetType copy];
}

-(void)setTypeId:(NSString *)aTypeId {
    if (![typeId isEqualToString:aTypeId]) {
        isQueryTargetChanged = YES;
    }
    
    if (typeId) {
         //(typeId);
    }
    
    typeId = [aTypeId copy];
}

- (void)cancelAllRequest {
	if (_request) {
		[_request cancel];
        [_request.delegates removeObject:self];
	}
}

-(void)dealloc {
     //(timelineWhenViewReleased);
     //(lastOffset);
     //(offSet);
     //(targetType);
     //(typeId);
     //(hotPhotos);
     //(allPhotos);
     //(_request);
}

#pragma mark - SNNewsModel Protocol
- (NSString *)channelId {
    return self.typeId;
}

- (BOOL)hasRecommendNews {
    return NO;
}

- (NSTimeInterval)refreshIntervalWithDefault:(NSTimeInterval)interval {
    return interval;
}

#pragma mark drag refresh

- (NSDate *)refreshedTime {
	NSDate *time = nil;
    
    NSString *timeKey = [NSString stringWithFormat:@"group_photo_%@_%@_refresh_time", self.targetType, self.typeId];
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:timeKey];
	if (data && [data isKindOfClass:[NSDate class]]) {
		time = data;
	}
	return time;
}

- (void)setRefreshedTime {
	NSString *timeKey = [NSString stringWithFormat:@"group_photo_%@_%@_refresh_time", self.targetType, self.typeId];
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:timeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}



@end
