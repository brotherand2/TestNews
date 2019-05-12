//
//  SNVoucherCenterViewModel.h
//  sohunews
//
//  Created by H on 2016/11/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNTransactionHistoryViewModelDelegate <NSObject>
@optional
- (void)willRefresh;
- (void)shouldRefresh;
- (void)didRefresh;
- (void)refreshFinished;

- (void)willLoadMore;
- (void)shouldLoadMore;
- (void)didLoadMore;
- (void)loadMoreFinished;
- (void)allDidLoad;

@end

@interface SNTransactionHistoryViewModel : NSObject<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray * dataArr;

@property (nonatomic, weak) UITableView * tableView;

@property (nonatomic, weak) id<SNTransactionHistoryViewModelDelegate> controller;

- (void)loadData;

@end
