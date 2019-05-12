//
//  SNMyMessageModel.h
//  sohunews
//
//  Created by jialei on 13-7-17.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNCommentListModel.h"

@interface SNMyMessageModel : NSObject
{
//    BOOL    _more;
    BOOL    _isLoading;
    int     _preCursor;
    int     _nextCursor;
    
//    SNURLRequest                    *_request;
}

@property (nonatomic, strong)NSString *pid;
@property (nonatomic, assign)BOOL hasMore;
@property (nonatomic, weak)id delegate;
@property (nonatomic, copy) NSString *lastErrorMsg;
@property (nonatomic, assign) NSInteger lastErrorCode;
@property (nonatomic, strong) NSDate *lastRefreshDate;
@property (nonatomic, assign)BOOL loadHistory;

@property(nonatomic,strong)NSMutableArray   *comments;

- (void)loadData:(BOOL)isMore;

@end
