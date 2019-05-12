//
//  SNCgWangQiModel.m
//  sohunews
//
//  Created by wangxiang on 4/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#define KEY_PUBID					(@"pubId")
#define KEY_TERMID					(@"termId")
#define KEY_TERMLINK				(@"termLink")
#define KEY_TERMNAME				(@"termName")
#define KEY_PUSHNAME				(@"pushName")
#define KEY_TERMZIP					(@"termZip")
#define KEY_TERMTIME				(@"termTime")
#define KEY_TERMINFO				(@"termInfo")
#define KEY_PAPER					(@"paper")
#define SN_SUBSCRIBE_CACHE_EXPIRATION_AGE				(60 * 60 * 3)//3 hours

#import "SNHistoryModel.h"
#import "SNDBManager.h"
#import "SNHistoryController.h"
#import "SNURLJSONResponse.h"
#import "SNHistoryItem.h"
#import "SNURLRequest.h"
#import "SNPaperItem.h"

@interface SNHistoryModel ()
- (void)wangqiRequest:(BOOL)bASyn userInfo:(NSDictionary *)info;
- (void)updateFromDatabase:(SNHistoryItem *)item;
@end

@implementation SNHistoryModel
@synthesize wangqiArray = _wangqiArray;
@synthesize netArray = _netArray;
@synthesize localArray = _localArray;
@synthesize bLoadMore = _bLoadMore;
@synthesize existPapers = _existPapers;
@synthesize bLoadMoreFromCache = _bLoadMoreFromCache;
@synthesize isFirstRequest = _isFirstRequest;
@synthesize controller = _controller;

- (id)init {
	if (self = [super init]) {
		_bLoadMore = YES;
		_curPage = 1;
		_pageNum = 20;
		_isDelete = NO;
		_isFirstRequest = YES;
	}
	return self;
}

- (NSArray *)existPapers 
{
	if (!_existPapers) {
		if ([self.controller.linkType isEqualToString:@"SUBLIST"]) {
			_existPapers = [[SNDBManager currentDataBase] getNewspaperListBySubId:self.controller.paperItem.subId];
		}
		else {
			_existPapers = [[SNDBManager currentDataBase] getNewspaperListByPubId:self.controller.paperItem.pubId];
		}
        
	}
	return _existPapers;
}

- (NSMutableArray *)netArray {
	if (!_netArray) {
		_netArray = [[NSMutableArray alloc] init];
	}
	return _netArray;
}

- (NSMutableArray *)localArray {
	if (!_localArray) {
		_localArray = [[NSMutableArray alloc] init];
	}
	return _localArray;
}

- (void)setNetArray:(NSMutableArray *)newArray {
	if (_netArray != newArray) {
		 //(_netArray);
		_netArray = newArray;
		self.wangqiArray = _netArray;
	}
}

- (void)setLocalArray:(NSMutableArray *)newArray {
	if (_localArray != newArray) {
		 //(_localArray);
		_localArray = newArray;
		self.wangqiArray = _localArray;
	}
}

- (BOOL)shouldLoadMore {
	return _bLoadMore;
}

- (BOOL)isLoaded {
	return !!self.wangqiArray.count;
}

- (BOOL)isLoadingMore {
    return self.bLoadMore;
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    
	if (MANAGEMENT_MODE_WANGQI == _controller.historyMode) {
        
        self.hasNoMore = NO;
        _bLoadMore = more;
        //往期列表加载更多
		if (more) {
			if (!self.isLoading) {
				[self wangqiRequest:YES userInfo:nil];
			}
		}
        //往期列表刷新
		else {
            _curPage = 1;
			if (!self.isLoading) {
				[self wangqiRequest:YES userInfo:nil];
			}
        }
	}
    
    //离线内容
    else{
        if (!more) {
            [_controller showEmpty:NO];
            _bLoadMore = NO;
             //(_localArray);
            NSMutableArray *exsitArray = nil; 
            if (MANAGEMENT_MODE_LOCAL == _controller.historyMode) {
                exsitArray = [NSMutableArray arrayWithArray:[[SNDBManager currentDataBase] getNewspaperDownloadedList]];
            }
            else {
                exsitArray = [NSMutableArray arrayWithArray:[[SNDBManager currentDataBase] getNewspaperDownloadedListBySubId:self.controller.paperItem.subId]];
            }
            self.localArray = exsitArray;
            if ( self.localArray.count > 0) {
                _controller.isErrorView = YES;
            }
            if (![self isLoaded]) {
                [_controller showEmpty:YES];
            }
            [self didFinishLoad];
        }
        
    }
}

- (void)wangqiRequest:(BOOL)bASyn userInfo:(NSDictionary *)info {
	
	NSString *pubIDStr = nil;
	NSString *pagesStr = nil;
	NSString *numStr = nil;
    if (self.controller.pubIDsForWangQiAction && ![@"" isEqualToString:self.controller.pubIDsForWangQiAction]) {
        pubIDStr = self.controller.pubIDsForWangQiAction;
    } else {
        pubIDStr = self.controller.paperItem.pubId;
    }
	pagesStr = [NSString stringWithFormat:@"%d", _curPage];
	numStr = [NSString stringWithFormat:@"%d", _pageNum];
	NSString *requestStr = [NSString stringWithFormat:kUrlHistory, pubIDStr, pagesStr, numStr];
	SNDebugLog(@"wangqiRequest--%@--%@", requestStr, self.controller.paperItem.pubId);
	
	if (_wangqiRequest) {
		[_wangqiRequest cancel];
		 //(_wangqiRequest);
	}
	
	if (!_wangqiRequest) {
		_wangqiRequest = [SNURLRequest requestWithURL:requestStr delegate:self];
        //		_wangqiRequest.cacheExpirationAge = SN_SUBSCRIBE_CACHE_EXPIRATION_AGE;
        _wangqiRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
		if (info) {
			_wangqiRequest.userInfo = info;
		}
	}	
    
    if (isRefreshManually) {
        _wangqiRequest.isShowNoNetWorkMessage = YES;
    } else {
        _wangqiRequest.isShowNoNetWorkMessage = NO;
    }
    
	_wangqiRequest.response = [[SNURLJSONResponse alloc] init];
    
    
	if (bASyn) {
		[_wangqiRequest send];
	}
	else {
		[_wangqiRequest sendSynchronously];
	}
}

#pragma mark -
#pragma mark TTURLRequestDelegate
- (void)requestDidStartLoad:(TTURLRequest*)request {
	[super requestDidStartLoad:request];
    
}

- (void)requestDidFinishLoad:(TTURLRequest*)request 
{
    self.hasNoMore = YES;
	SNURLJSONResponse *dataRes = (SNURLJSONResponse *)request.response;
	NSDictionary *resData = dataRes.rootObject;
	SNDebugLog(@"requestDidFinishLoad1111---%@", resData);
	//id paperData = [resData objectForKey:KEY_PAPER];
	id paperData = dataRes.rootObject;
	NSMutableArray *newDataArray = [NSMutableArray array];
	if ([paperData isKindOfClass:[NSArray class]]) {
        if ([(NSArray *)paperData count] >= _pageNum) {
            self.hasNoMore = NO;
            _curPage++;
        }
		for (NSDictionary *itemDic in paperData) {
			SNHistoryItem *newItem = [[SNHistoryItem alloc] init];
			newItem.subId = self.controller.paperItem.subId;
			newItem.pubId = self.controller.paperItem.pubId;
			//newItem.pubId = [itemDic objectForKey:KEY_PUBID];
			newItem.termId = [itemDic objectForKey:KEY_TERMID];
			newItem.termLink = [itemDic objectForKey:KEY_TERMLINK];
			newItem.termName = [itemDic objectForKey:KEY_TERMNAME];
			newItem.termZip = [itemDic objectForKey:KEY_TERMZIP];
			newItem.termTitle = [itemDic objectForKey:KEY_TERMINFO];
			newItem.termTime = [itemDic objectForKey:KEY_TERMTIME];
            newItem.pushName = [itemDic objectForKey:KEY_PUSHNAME];
            newItem.readFlag = [NSString stringWithFormat:@"%d", 0];
            if (newItem && newItem.termName && newItem.termTime) {
				[self updateFromDatabase:newItem];
				[newDataArray addObject:newItem];
			}
			 //(newItem);
		}
	}
	else if ([paperData isKindOfClass:[NSDictionary class]]) {
		NSDictionary *paperDic = [resData objectForKey:KEY_PAPER];
		if (!paperDic) {
			paperDic = paperData;
		}
		SNHistoryItem *newItem = [[SNHistoryItem alloc] init];
		newItem.subId = self.controller.paperItem.subId;
		newItem.pubId = [paperDic objectForKey:KEY_PUBID];//self.controller.paperItem.pubId;
		newItem.termId = [paperDic objectForKey:KEY_TERMID];
		newItem.termLink = [paperDic objectForKey:KEY_TERMLINK];
		newItem.termName = [paperDic objectForKey:KEY_TERMNAME];
		newItem.termZip = [paperDic objectForKey:KEY_TERMZIP];
		newItem.termTitle = [paperDic objectForKey:KEY_TERMINFO];
		newItem.termTime = [paperDic objectForKey:KEY_TERMTIME];
        newItem.pushName = [paperDic objectForKey:KEY_PUSHNAME];
		newItem.readFlag = [NSString stringWithFormat:@"%d", 0];
		
		if (newItem.subId && newItem.termName && newItem.termTime) {
			[self updateFromDatabase:newItem];
			[newDataArray addObject:newItem];
		}
		 //(newItem);
	}
    
	if (newDataArray.count) {
		[[SNDBManager currentDataBase] addMultiNewspaper:newDataArray];
        if (_bLoadMore)
            [self.netArray addObjectsFromArray:newDataArray];
        else
            self.netArray = newDataArray;
	}

    if (!_bLoadMore) {
        [self setRefreshedTime];
    }
	[super requestDidFinishLoad:request];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
	SNDebugLog(@"didFailLoadWithError---%@", [request urlPath]);
    self.hasNoMore = YES;
	[super requestDidFinishLoad:request];
}

- (void)requestDidCancelLoad:(TTURLRequest*)request {
	[self didCancelLoad];
    
}

- (void)updateFromDatabase:(SNHistoryItem *)item 
{
	SNHistoryItem *updateItem =  (SNHistoryItem *)[[SNDBManager currentDataBase] getNewspaperByTermId:item.termId];
    if (updateItem) {
		item.readFlag = updateItem.readFlag;
		item.newspaperPath = updateItem.newspaperPath;
		item.readFlag = updateItem.readFlag;
		item.downloadFlag = updateItem.downloadFlag;
        item.downloadTime = updateItem.downloadTime;
	}
}

- (NSDate *)refreshedTime {
	NSDate *time = nil;
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:@"wangqi_refresh_time"];
	if (data && [data isKindOfClass:[NSDate class]]) {
		time = data;
	}
	return time;
}

- (void)setRefreshedTime {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"wangqi_refresh_time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc
{
     //(_wangqiRequest);
     //(_netArray);
     //(_localArray);
     //(_existPapers);
    
}

@end
