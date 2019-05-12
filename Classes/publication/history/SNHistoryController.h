//
//  SNCgWangQiController.h
//  sohunews
//
//  Created by wangxiang on 4/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableViewController.h"
#import "SNDragRefreshTableViewController.h"

typedef enum {
	MANAGEMENT_MODE_WANGQI,
	MANAGEMENT_MODE_LOCAL,
    MANAGEMENT_MODE_SETTING,
}HistoryMode;

@class SNHistoryDelegate;
@class SNPaperItem;
@class SNEmptyView;
@interface SNHistoryController : SNDragRefreshTableViewController{
   SNHistoryDelegate *_delegateHistory;
   SNEmptyView *_customEmptyView;
   SNPaperItem *_paperItem;
   HistoryMode _historyMode;
   NSString *_linkType; 
    BOOL   isErrorView;
    NSString *_pubIDsForWangQiAction;
}

@property (nonatomic,strong)SNHistoryDelegate *delegateHistory;
@property (nonatomic,strong)SNEmptyView *customEmptyView;
@property (nonatomic,strong)SNPaperItem *paperItem;
@property (nonatomic,assign)HistoryMode historyMode;
@property (nonatomic,copy)NSString *linkType;
@property (nonatomic,assign)BOOL   isErrorView;
@property (nonatomic, copy)NSString *pubIDsForWangQiAction;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query;
- (void)showEmptyNewsBg;
@end

