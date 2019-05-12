//
//  SNVoucherCenterViewModel.m
//  sohunews
//
//  Created by H on 2016/11/28.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNTransactionHistoryViewModel.h"
#import "SNTransactionHistoryCell.h"
#import "SNKeyChainHelper.h"
#import "SNPurchaseListRequest.h"
#import "SNIAPHelper.h"

const CGFloat kRefreshDistanceY = -44.0f;

@interface SNTransactionHistoryViewModel ()<UIScrollViewDelegate>{
    BOOL _isVerifying;
    NSInteger _cursor;//游标，页码
    BOOL _isLoading;
    UILabel * _allDidLoadView;
}

@end

@implementation SNTransactionHistoryViewModel
#pragma mark -load data
/*
 {
 "statusCode": 30140000,
 "statusMsg": "成功",
 "data":{
        "cursor": 100,
        "list": [
                {
                "id": 10000,  //订单号
                "amount": 1000, //金额
                "status": 0,    //状态 0=待支付,1=支付成功,2=支付失败
                "ctime": "今天 19:20" //时间
                },
                {
                "id": 10001,
                "amount": 1000, //金额
                "status": 0,    //状态
                "ctime": "今天 19:20" //时间
                },
                ]
        }
 }
 */
- (void)loadData {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        
        return;
    }
    if (_isLoading) {
        return;
    }
    if ([self.controller respondsToSelector:@selector(didRefresh)]) {
        [self.controller didRefresh];
    }
    _isLoading = YES;
    SNPurchaseListRequest * request = [[SNPurchaseListRequest alloc] init];
    request.cursor = @"0";
    [request send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * resData = (NSDictionary *)responseObject;
            NSNumber * statusCode = [resData objectForKey:@"statusCode"];
            if (statusCode.integerValue == 30140000) {
                _cursor = 0;
                if (self.dataArr.count > 0) {
                    [self.dataArr removeAllObjects];
                }
 
                NSDictionary * data = resData[@"data"];
                NSArray * list = data[@"list"];
                if (list.count < 20) {
                    [self addAllDidLoadView];
                }else{
                    [self removeAllDidLoadView];
                }

                [self formatData:list];
                [self.tableView scrollToTop:YES];
                [self.tableView reloadData];
            }else{
                
            }
        }else{
            
        }
        _isLoading = NO;
        if ([self.controller respondsToSelector:@selector(refreshFinished)]) {
            [self.controller refreshFinished];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        _isLoading = NO;
        if ([self.controller respondsToSelector:@selector(refreshFinished)]) {
            [self.controller refreshFinished];
        }
    }];
}

- (void)loadMoreData {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        
        return;
    }
    if (_isLoading) {
        return;
    }
    if ([self.controller respondsToSelector:@selector(didLoadMore)]) {
        [self.controller didLoadMore];
    }
    _isLoading = YES;
    SNPurchaseListRequest * request = [[SNPurchaseListRequest alloc] init];
    request.cursor = [NSString stringWithFormat:@"%d",_cursor + 1];
    [request send:^(SNBaseRequest *request, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary * resData = (NSDictionary *)responseObject;
            NSNumber * statusCode = [resData objectForKey:@"statusCode"];
            if (statusCode.integerValue == 30140000) {
                _cursor += 1;
                NSDictionary * data = resData[@"data"];
                NSArray * list = data[@"list"];
                if (list.count == 0) {
                    [self addAllDidLoadView];
                    if ([self.controller respondsToSelector:@selector(allDidLoad)]) {
                        [self.controller allDidLoad];
                    }
                    return;
                }else{
                    if (list.count < 20) {
                        [self addAllDidLoadView];
                    }else{
                        [self removeAllDidLoadView];
                    }
                    [self formatData:list];
                    [self.tableView reloadData];
                }
            }else{
                
            }
        }else{
            
        }
        _isLoading = NO;
        if ([self.controller respondsToSelector:@selector(loadMoreFinished)]) {
            [self.controller loadMoreFinished];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        _isLoading = NO;
        if ([self.controller respondsToSelector:@selector(loadMoreFinished)]) {
            [self.controller loadMoreFinished];
        }
    }];
}

- (void)formatData:(NSArray *)array{
    if (array.count == 0) {
        return;
    }
    if (!self.dataArr) {
        self.dataArr = [NSMutableArray array];
    }
    for (NSDictionary * dic in array) {
        if ([dic isKindOfClass:[NSDictionary class]]) {
            SNTransactionHistoryItem * item = [SNTransactionHistoryItem createWithDic:dic];
            if (item) {
                [_dataArr addObject:item];
            }
        }
    }
}

- (void)addAllDidLoadView {
    if (!_allDidLoadView) {
        _allDidLoadView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40)];
        _allDidLoadView.text = @"已全部加载";
        _allDidLoadView.textAlignment = NSTextAlignmentCenter;
        [_allDidLoadView setFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
        [_allDidLoadView setTextColor:SNUICOLOR(kThemeText4Color)];
    }
    self.tableView.tableFooterView = _allDidLoadView;
}

- (void)removeAllDidLoadView {
    if (_allDidLoadView) {
        [_allDidLoadView removeFromSuperview];
        _allDidLoadView = nil;
        self.tableView.tableFooterView = nil;
    }
}

#pragma mark - TableView
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    SNTransactionHistoryItem * item = self.dataArr[indexPath.row];
    if (item.transactionType == SNTransactionTypeSuccessed || _isVerifying) {
        return;
    }
    _isVerifying = YES;
    [self showLoadingWithMsg:@"正在验证..."];
    [SNKeyChainHelper verifyReceiptWithTransactionID:item.transactionId completed:^(BOOL successed, NSNumber *amount, NSData *receipt, NSString * errMsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (successed) {
                [self showSuccessToast];
                ///验证成功了就刷新tableview，但是有个问题是会回顶
                ///这里逻辑可以再优化一下，比如做本地数据
                [self loadData];
            }else{
                [self showFailedToast:errMsg];
            }
        });
        _isVerifying = NO;
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellId = @"SNTransactionHistoryCell";
    SNTransactionHistoryCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (nil == cell) {
        cell = [[SNTransactionHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell layoutWithItem:self.dataArr[indexPath.row]];
    return cell;

}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    if (scrollView.contentOffset.y+_tableView.contentInset.top<= kRefreshDistanceY) {
        [self loadData];
    }else if (scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.frame.size.height)) {
        [self loadMoreData];
    }
}

#pragma mark - UI
- (void)showSuccessToast {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:@"充值成功" toUrl:nil mode:SNCenterToastModeSuccess];
}

- (void)showFailedToast:(NSString *)errMsg {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:errMsg toUrl:nil mode:SNCenterToastModeError];
}

- (void)showLoadingWithMsg:(NSString *)msg {
    [[SNCenterToast shareInstance] showCenterLoadingToastWithTitle:nil
                                                 cancelButtonEvent:nil];
}

- (void)hideLoading {
    [[SNCenterToast shareInstance] hideCenterLoadingToast];
}

@end
