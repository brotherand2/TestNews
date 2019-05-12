//
//  SNCgWangQiModel.h
//  sohunews
//
//  Created by wangxiang on 4/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNDragRefreshURLRequestModel.h"

@class SNHistoryController;
@class SNURLRequest;
@interface SNHistoryModel : SNDragRefreshURLRequestModel
{
    NSMutableArray	*__weak _wangqiArray;
	NSMutableArray *_localArray;
	NSMutableArray *_netArray;
	NSArray	*_existPapers;
	SNURLRequest *_wangqiRequest;
	BOOL _bLoadMore;
	BOOL _bLoadMoreFromCache;
	int _curPage;
	int _pageNum;
	BOOL _isDelete;
	BOOL _isFirstRequest;
    SNHistoryController *__weak _controller;
}

@property (nonatomic, weak) NSMutableArray *wangqiArray;
@property (nonatomic, strong) NSMutableArray *localArray; 
@property (nonatomic, strong) NSMutableArray *netArray; 
@property (nonatomic, strong) NSArray *existPapers;
@property (nonatomic, weak) SNHistoryController *controller;
@property (nonatomic, assign) BOOL bLoadMore;
@property (nonatomic, assign) BOOL bLoadMoreFromCache;
@property (nonatomic, assign) BOOL isFirstRequest;

@end
