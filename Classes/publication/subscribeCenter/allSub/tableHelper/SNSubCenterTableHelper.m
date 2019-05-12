//
//  SNSubCenterTableHelper.m
//  sohunews
//
//  Created by wang yanchen on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterTableHelper.h"

@implementation SNSubCenterTableHelper
@synthesize delegate = _delegate;
@synthesize bDataInvalidate = _bDataInvalidate;

- (id)initWithTableView:(UITableView *)tableView delegate:(id)delegate {
    self = [self init];
    if (self) {
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        self.delegate = delegate;
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    _tableView = nil;
    _delegate = nil;
}

- (void)startListen {
    
}

- (void)stopListen {
    
}

- (void)setNeedsReload {
    self.bDataInvalidate = YES;
}

- (void)reloadData {
    if (_bDataInvalidate) {
        [_tableView reloadData];
        _bDataInvalidate = NO;
    }
}

#pragma mark - table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - sub center service delegate

// 统一的数据回调
- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    
}
- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    
}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    
}

@end
