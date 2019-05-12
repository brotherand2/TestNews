//
//  SNSubCenterTypesHelper.m
//  sohunews
//
//  Created by wang yanchen on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterTypesHelper.h"
#import "SNSubCenterTypesCell.h"
#import "CacheObjects.h"

#define kTypeCellHeight                         (90 / 2)

@implementation SNSubCenterTypesHelper
@synthesize typesArray = _typesArray;
@synthesize isLoading;

- (id)initWithTableView:(UITableView *)tableView delegate:(id)delegate {
    self = [self init];
    if (self) {
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        self.delegate = delegate;
        
        [self refreshDataWithCheckExpired:YES];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        self.typesArray = [NSMutableArray array];
        [_typesArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubTypesFromLocalDB]];
        [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRefreshSubHomeData];
    }
    return self;
}

- (void)dealloc {
    [[SNSubscribeCenterService defaultService] removeListener:self];
     //(_typesArray);
}

- (void)refreshDataWithCheckExpired:(BOOL)bCheck {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        return;
    }
    if (bCheck && ![SNSubscribeCenterService shouldReloadHomeData]) {
        return;
    }
    
    // fix 强刷订阅中心之后 导致分类的选中效果丢失 by jojo
    if (!bCheck) {
        _selectIndex = 0;
        [TTURLRequestQueue mainQueue].suspended = NO;
    }
    
    [[SNSubscribeCenterService defaultService] loadSubHomeDataFromServer];
    self.isLoading = YES;
    
    if ([_typesArray count] <= 0) {
        if ([_delegate respondsToSelector:@selector(typesStartToLoad)]) {
            [_delegate typesStartToLoad];
        }
    }
}

- (void)startListen {
    [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRefreshSubHomeData];
}

- (void)stopListen {
    [[SNSubscribeCenterService defaultService] removeListener:self];
}

#pragma mark - table data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_typesArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdt = @"typeCell";
    SNSubCenterTypesCell *typeCell = [tableView dequeueReusableCellWithIdentifier:cellIdt];
    if (nil == typeCell) {
        typeCell = [[SNSubCenterTypesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdt];
    }
    typeCell.typeObj = [_typesArray objectAtIndex:[indexPath row]];
    return typeCell;
}

#pragma mark - table delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTypeCellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 第一次  默认选中第一个
    if ([indexPath row] == 0 && _selectIndex == 0) {
        [cell setSelected:YES];
        if ([_delegate respondsToSelector:@selector(didSelectTypeWithTypeId:)] && !bInitFirstSelection) {
            [_delegate didSelectTypeWithTypeId:[(SCSubscribeTypeObject *)[_typesArray objectAtIndex:0] typeId]];
            bInitFirstSelection = YES;
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] > 0 && _selectIndex == 0) {
        [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setSelected:NO];
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectIndex == [indexPath row]) {
        return;
    }
    _selectIndex = [indexPath row];
    if ([_delegate respondsToSelector:@selector(didSelectTypeWithTypeId:)]) {
        [_delegate didSelectTypeWithTypeId:[(SCSubscribeTypeObject *)[_typesArray objectAtIndex:_selectIndex] typeId]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    SNDebugLog(@"%@-----", NSStringFromSelector(_cmd));
    if ([_delegate respondsToSelector:@selector(typesTableDidScroll:)]) {
        [_delegate typesTableDidScroll:scrollView];
    }
}

#pragma mark - sub center service delegate

// 统一的数据回调
- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeRefreshSubHomeData) {
        self.isLoading = NO;
        //
        NSString *oldSelecedTypeId = nil;
        if ([_typesArray count] > 0) {
            [(SCSubscribeTypeObject *)[_typesArray objectAtIndex:_selectIndex] typeId];
        }
        
        [_typesArray removeAllObjects];
        [_typesArray addObjectsFromArray:[dataSet strongDataRef]];
        
        NSString *newSelectedTypeId = nil;
        if (_selectIndex < [_typesArray count]) {
            newSelectedTypeId = [(SCSubscribeTypeObject *)[_typesArray objectAtIndex:_selectIndex] typeId];
        }
        // 原来选择的type不幸被服务器下了 重新选中第一个
        else {
            _selectIndex = 0;
        }
        
        // 同一个_selectIndex 变成了不同的typeId
        if (oldSelecedTypeId && newSelectedTypeId && ![oldSelecedTypeId isEqualToString:newSelectedTypeId]) {
            if ([_delegate respondsToSelector:@selector(didSelectTypeWithTypeId:)]) {
                [_delegate didSelectTypeWithTypeId:[(SCSubscribeTypeObject *)[_typesArray objectAtIndex:_selectIndex] typeId]];
            }
        }
        
        [_tableView reloadData];
        
        // check home data sublist is empty
        NSArray *homeData = [[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:kSubTypeRecomendId];
        if ([homeData count] > 0) {
            if ([_typesArray count] > 0 && [_delegate respondsToSelector:@selector(didFinishLoadHomeDataWithTypeId:)]) {
                [_delegate didFinishLoadHomeDataWithTypeId:[[_typesArray objectAtIndex:0] typeId]];
            }
        }
        else {
            if ([_delegate respondsToSelector:@selector(didFailLoadHomeData)]) {
                [_delegate didFailLoadHomeData];
            }
        }
    }
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeRefreshSubHomeData) {
        self.isLoading = NO;
        SNDebugLog(@"%@--%@ fail with error : %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [dataSet lastError]);
        // 如果第一次从本地加载的都失败了  显示重刷页面
        if ([_typesArray count] <= 0) {
            if ([_delegate respondsToSelector:@selector(typesFindNoDataToLoad)]) {
                [_delegate typesFindNoDataToLoad];
            }
        }
    }
}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    self.isLoading = NO;
}

@end
