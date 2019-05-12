//
//  SNSubCenterSubsHelper.m
//  sohunews
//
//  Created by wang yanchen on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterSubsHelper.h"
#import "SNSubCenterAllSubsCell.h"
#import "SNDBManager.h"
#import "SNSubscribeHintPushAlertView.h"
#import "SNGuideRegisterManager.h"
#import "SNUserManager.h"
#import "SNNewsLoginManager.h"

// 服务器一页返回20条，其中可能包含‘专题快讯’，本地过滤后剩余19
// 服务器由于不能准确返回请求的个数  因此 客户端只要认为请求有数据返回 就认为有更多数据
#define HAS_MORE_COUNT (1)

@implementation SNSubCenterSubsHelper
@synthesize typeId= _typeId;
@synthesize subsArray = _subsArray;
@synthesize subsRunningOnAddToMySub = _subsRunningOnAddToMySub;
@synthesize needForceRefresh = _needForceRefresh;

- (id)init {
    self = [super init];
    if (self) {
        self.subsArray = [NSMutableArray array];
        self.subsRunningOnAddToMySub = [NSMutableArray array];
    }
    return self;
}

- (void)subsDataDidChanged:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(reloadSubData) withObject:nil waitUntilDone:[NSThread isMainThread]];
}

- (void)reloadSubData {
    self.subsArray = [NSMutableArray array];
    
    [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
    
    for (SCSubscribeObject *subObj in _subsArray) {
        if ([subObj.isSubscribed boolValue]) {
            [_subsRunningOnAddToMySub removeObject:subObj.subId];
        }
    }
    [self removeRepeatedItemsInSubsArray];
    [_tableView reloadData];
    [self setNeedsReload];
}

- (void)setTypeId:(NSString *)typeId {
    if (_typeId != typeId) {
         //(_typeId);
        _typeId = [typeId copy];
    }
    
    if ([_typeId length] > 0) {
        self.subsArray = [NSMutableArray array];
        _pageNum = 1;
        _hasMore = NO;
        _isLoading = NO;
        if ([_delegate respondsToSelector:@selector(subsFindDataToLoad)]) {
            [_delegate subsFindDataToLoad];
        }
        
        if (_moreCell) {
            [_moreCell showLoading:NO];
        }
        
        if ([_typeId isEqualToString:kSubTypeRankId]) {
            
            // 加载排行里面的刊物
            // 数据过期
            if ([SNSubscribeCenterService shouldReloadSubItemsForType:_typeId] || _needForceRefresh) {
                if (![SNUtility getApplicationDelegate].isNetworkReachable) {
                    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
                    [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
                    if ([_subsArray count] <= 0) {
                        if ([_delegate respondsToSelector:@selector(subsFindNoDataToLoad)]) {
                            [_delegate subsFindNoDataToLoad];
                        }
                    }
                }
                else {
                    [[SNSubscribeCenterService defaultService] loadSubRankListFromServer];
                    _isLoading = YES;
                    if ([_delegate respondsToSelector:@selector(subsStartToLoad)]) {
                        [_delegate subsStartToLoad];
                    }
                }
            }
            // 没过期  用本地
            else {
                [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
                // 本地没有   可能是上次返回就是空  也可能是从来没刷过
                if ([_subsArray count] <= 0) {
                    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
                        [[SNSubscribeCenterService defaultService] loadSubRankListFromServer];
                        _isLoading = YES;
                        if ([_delegate respondsToSelector:@selector(subsStartToLoad)]) {
                            [_delegate subsStartToLoad];
                        }
                    }
                    else {
                        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
                        if ([_delegate respondsToSelector:@selector(subsFindNoDataToLoad)]) {
                            [_delegate subsFindNoDataToLoad];
                        }
                    }
                }
                // 本地如果有数据 则需要判断是否需要预加载服务器更多的刊物（由于快速切换频道会导致加载更多失常）
                else {
                    [self checkIfNeedLoadMore];
                }
            }
            
        }
        else if ([typeId isEqualToString:kSubTypeRecomendId]) {
            // 加载精品推荐里面的刊物
            if ([SNSubscribeCenterService shouldReloadSubItemsForType:_typeId] || _needForceRefresh) {
                if (![SNUtility getApplicationDelegate].isNetworkReachable) {
                    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
                    [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
                    if ([_subsArray count] <= 0) {
                        if ([_delegate respondsToSelector:@selector(subsFindNoDataToLoad)]) {
                            [_delegate subsFindNoDataToLoad];
                        }
                    }
                }
                else {
                    [[SNSubscribeCenterService defaultService] loadSubHomeDataFromServer];
                    _isLoading = YES;
                    if ([_delegate respondsToSelector:@selector(subsStartToLoad)]) {
                        [_delegate subsStartToLoad];
                    }
                }
            }
            else {
                [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
                // 本地没有   可能是上次返回就是空  也可能是从来没刷过
                if ([_subsArray count] <= 0) {
                    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
                        [[SNSubscribeCenterService defaultService] loadSubHomeDataFromServer];
                        _isLoading = YES;
                        if ([_delegate respondsToSelector:@selector(subsStartToLoad)]) {
                            [_delegate subsStartToLoad];
                        }
                    }
                    else {
                        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
                        if ([_delegate respondsToSelector:@selector(subsFindNoDataToLoad)]) {
                            [_delegate subsFindNoDataToLoad];
                        }
                    }
                }
                // 本地如果有数据 则需要判断是否需要预加载服务器更多的刊物（由于快速切换频道会导致加载更多失常）
                else {
                    [self checkIfNeedLoadMore];
                }
            }
        }
        else {
            // 加载普通的subType
            // 数据过期
            if ([SNSubscribeCenterService shouldReloadSubItemsForType:_typeId] || _needForceRefresh) {
                if (![SNUtility getApplicationDelegate].isNetworkReachable) {
                    [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
                    [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
                    if ([_subsArray count] <= 0) {
                        if ([_delegate respondsToSelector:@selector(subsFindNoDataToLoad)]) {
                            [_delegate subsFindNoDataToLoad];
                        }
                    }
                }
                else {
                    [[SNSubscribeCenterService defaultService] loadSubscribesFromServerWithSubTypeId:_typeId];
                    _isLoading = YES;
                    if ([_delegate respondsToSelector:@selector(subsStartToLoad)]) {
                        [_delegate subsStartToLoad];
                    }
                }
            }
            // 没过期  用本地
            else {
                [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
                // 本地没有   可能是上次返回就是空  也可能是从来没刷过
                if ([_subsArray count] <= 0) {
                    if ([SNUtility getApplicationDelegate].isNetworkReachable) {
                        [[SNSubscribeCenterService defaultService] loadSubscribesFromServerWithSubTypeId:_typeId];
                        _isLoading = YES;
                        if ([_delegate respondsToSelector:@selector(subsStartToLoad)]) {
                            [_delegate subsStartToLoad];
                        }
                    }
                    else {
                        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
                        if ([_delegate respondsToSelector:@selector(subsFindNoDataToLoad)]) {
                            [_delegate subsFindNoDataToLoad];
                        }
                    }
                }
                // 本地如果有数据 则需要判断是否需要预加载服务器更多的刊物（由于快速切换频道会导致加载更多失常）
                else {
                    [self checkIfNeedLoadMore];
                }
            }
            
        }
        
        _needForceRefresh = NO;
        
        if (!_tableView.isDecelerating && !_tableView.isDragging && [_subsArray count] > 0) {
            BOOL isADViewShown = NO;
            if ([_delegate respondsToSelector:@selector(isAdViewShown)]) {
                isADViewShown = [_delegate isAdViewShown];
            }
            CGFloat y = isADViewShown ? 0 : -kHeadSelectViewHeight;
            [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x, y)];
        }
        [self removeRepeatedItemsInSubsArray];
        [_tableView reloadData];
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    [[SNSubscribeCenterService defaultService] removeListener:self];
}

- (void)startListen {
    [SNNotificationManager addObserver:self selector:@selector(subsDataDidChanged:) name:kSubscribeCenterMySubDidChangedNotify object:nil];
    [SNNotificationManager addObserver:self selector:@selector(pushWillCome) name:kNotifyDidReceive object:nil];
    
    [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRefreshSubTypeSubItems];
    [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRefreshSubTypeMoreSubItems];
    [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRefreshSubRankList];
    [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRefreshSubMoreRankList];
    [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddMySubToServer];
    [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRefreshSubHomeData];
    [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeRefeshHomeMoreData];
}

- (void)stopListen {
    [SNNotificationManager removeObserver:self];
    [[SNSubscribeCenterService defaultService] removeListener:self];
}

#pragma mark - table view datasource 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_hasMore) {
        return [_subsArray count] + 1; // more cell
    }
    else {
        return [_subsArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath row] < [_subsArray count]) {
        static NSString *cellIdt = @"subCell";
        SNSubCenterAllSubsCell *subCell = [tableView dequeueReusableCellWithIdentifier:cellIdt];
        
        if (nil == subCell) {
            subCell = [[SNSubCenterAllSubsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdt];
            subCell.delegate = self;
        }
        
        SCSubscribeObject *subObj = [_subsArray objectAtIndex:[indexPath row]];
        subCell.subObj = subObj;
        subCell.isRunning = [_subsRunningOnAddToMySub indexOfObject:subObj.subId] != NSNotFound;
        
        return subCell;
    }
    else if ([indexPath row] == [_subsArray count]) {
        if (!_moreCell) {
            _moreCell = [[SNSubCenterMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moreCell"];
        }
        return _moreCell;
    }
    else {
        return nil;
    }
}

#pragma mark - table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kSubCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[SNSubCenterAllSubsCell class]]) {
        SCSubscribeObject *subObj = [(SNSubCenterAllSubsCell *)cell subObj];
        if (![subObj open]) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:subObj forKey:@"subObj"];
            TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://subDetail"] applyAnimated:YES] applyQuery:dic];
            [[TTNavigator navigator] openURLAction:action];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    SNDebugLog(@"%@-----", NSStringFromSelector(_cmd));
    if ([_delegate respondsToSelector:@selector(allSubTableDidScroll:)]) {
        [_delegate allSubTableDidScroll:scrollView];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[SNSubCenterMoreCell class]]) {
        [_moreCell showLoading:YES];
        // loadMore
        SNDebugLog(@"loadMore !!!");
        [self loadMoreSubs];
    }
}

#pragma mark - sub center service delegate

// 统一的数据回调
- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeRefreshSubTypeSubItems) {
        if ([_typeId isEqualToString:[dataSet strongDataRef]]) {
            self.subsArray = [NSMutableArray array];
            [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
            [_moreCell showLoading:NO];
            _isLoading = NO;
            if ([_subsArray count] >= HAS_MORE_COUNT) {
                _hasMore = YES;
                _pageNum = 2;
            }
            
            // 第一次从服务器取20  如果返回0 则认为服务器抽风了  尝试加载本地
            if ([_subsArray count] <= 0) {
                [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
            }
            [self removeRepeatedItemsInSubsArray];
            [_tableView reloadData];
        }
    }
    else if ([dataSet operation] == SCServiceOperationTypeRefreshSubTypeMoreSubItems) {
        if ([_typeId isEqualToString:[dataSet strongDataRef]]) {
            NSArray *moreSubs = [dataSet reservedDataRef];
            [_moreCell showLoading:NO];
            _isLoading = NO;
            if ([moreSubs count] >= HAS_MORE_COUNT) {
                _hasMore = YES;
                _pageNum++;
            }
            
            [_subsArray addObjectsFromArray:moreSubs];
            [self removeRepeatedItemsInSubsArray];
            [_tableView reloadData];
            // 暂时不需要加载更多的这种特效
//            [self appendMoreSubs:moreSubs];
        }
    }
    else if ([dataSet operation] == SCServiceOperationTypeRefreshSubHomeData) {
        if ([_typeId length] > 0) {
            self.subsArray = [NSMutableArray array];
            [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
            [_moreCell showLoading:NO];
            _isLoading = NO;
            if ([_subsArray count] >= HAS_MORE_COUNT) {
                _hasMore = YES;
                _pageNum = 2;
            }
            
            // 第一次从服务器取20  如果返回0 则认为服务器抽风了  尝试加载本地
            if ([_subsArray count] <= 0) {
                [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
            }
            [self removeRepeatedItemsInSubsArray];
            [_tableView reloadData];
        }
    }
    else if ([dataSet operation] == SCServiceOperationTypeRefeshHomeMoreData) {
        NSArray *moreHomeData = [dataSet strongDataRef];
        [_moreCell showLoading:NO];
        _isLoading = NO;
        if ([moreHomeData count] >= HAS_MORE_COUNT) {
            _hasMore = YES;
            _pageNum++;
        }
        
        [_subsArray addObjectsFromArray:moreHomeData];
        [self removeRepeatedItemsInSubsArray];
        [_tableView reloadData];
    }
    else if ([dataSet operation] == SCServiceOperationTypeRefreshSubRankList) {
        self.subsArray = [NSMutableArray array];
        [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
        [_moreCell showLoading:NO];
        _isLoading = NO;
        if ([_subsArray count] >= HAS_MORE_COUNT) {
            _hasMore = YES;
            _pageNum = 2;
        }
        
        // 第一次从服务器取20  如果返回0 则认为服务器抽风了  尝试加载本地
        if ([_subsArray count] <= 0) {
            [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
        }
        [self removeRepeatedItemsInSubsArray];
        [_tableView reloadData];
    }
    else if ([dataSet operation] == SCServiceOperationTypeRefreshSubMoreRankList) {
        NSArray *moreRank = [dataSet strongDataRef];
        [_moreCell showLoading:NO];
        _isLoading = NO;
        if ([moreRank count] >= HAS_MORE_COUNT) {
            _hasMore = YES;
            _pageNum++;
        }
        
        [_subsArray addObjectsFromArray:moreRank];
        [self removeRepeatedItemsInSubsArray];
        [_tableView reloadData];
        
//        [self appendMoreSubs:moreRank];
    }
    else if ([dataSet operation] == SCServiceOperationTypeAddMySubToServer) {
        NSString *subId = [dataSet strongDataRef];
        [self.subsRunningOnAddToMySub removeObject:subId];
        
        BOOL bFound = NO;
        for (SCSubscribeObject *subObj in _subsArray) {
            if ([subObj.subId isEqualToString:subId]) {
                subObj.isSubscribed = @"1";
                bFound = YES;
                break;
            }
        }
        
        if (bFound) {
            [self removeRepeatedItemsInSubsArray];
            [_tableView reloadData];
        }
        
        return;
    }
    else if ([dataSet operation] == SCServiceOperationTypeAddMySubsAndSynchPush) {
        NSDictionary *dic = [dataSet strongDataRef];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSString *addStatementStr = [dic objectForKey:@"yes"];
            addStatementStr = [addStatementStr stringByReplacingOccurrencesOfString:@"&yes=" withString:@""];
            NSArray *subIds = [addStatementStr componentsSeparatedByString:@","];
            if ([subIds count] > 0) {
                NSString *subId = [subIds objectAtIndex:0];
                [self.subsRunningOnAddToMySub removeObject:subId];
                
                BOOL bFound = NO;
                
                for (SCSubscribeObject *subObj in _subsArray) {
                    if ([subObj.subId isEqualToString:subId]) {
                        subObj.isSubscribed = @"1";
                        bFound = YES;
                        break;
                    }
                }
                
                if (bFound) {
                    [self removeRepeatedItemsInSubsArray];
                    [_tableView reloadData];
                }
            }
        }
        return;
    }
    
    if ([_subsArray count] > 0) {
        if ([_delegate respondsToSelector:@selector(subsFindDataToLoad)]) {
            [_delegate subsFindDataToLoad];
        }
    }
    else {
        if ([_delegate respondsToSelector:@selector(subsFindNoDataToLoad)]) {
            [_delegate subsFindNoDataToLoad];
        }
    }
}

- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeRefreshSubTypeSubItems) {
        _isLoading = NO;
        // 第一次从服务器取20  如果服务器抽风了  尝试加载本地
        [_subsArray removeAllObjects];
        [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
        [self removeRepeatedItemsInSubsArray];
        [_tableView reloadData];
    }
    else if ([dataSet operation] == SCServiceOperationTypeRefreshSubTypeMoreSubItems) {
        [_moreCell showLoading:NO];
        _isLoading = NO;
    }
    else if ([dataSet operation] == SCServiceOperationTypeRefreshSubHomeData) {
        _isLoading = NO;
        // 第一次从服务器取20  如果服务器抽风了  尝试加载本地
        [_subsArray removeAllObjects];
        [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
        [self removeRepeatedItemsInSubsArray];
        [_tableView reloadData];
    }
    else if ([dataSet operation] == SCServiceOperationTypeRefeshHomeMoreData) {
        [_moreCell showLoading:NO];
        _isLoading = NO;
    }
    else if ([dataSet operation] == SCServiceOperationTypeRefreshSubRankList) {
        _isLoading = NO;
        // 第一次从服务器取20  如果服务器抽风了  尝试加载本地
        [_subsArray removeAllObjects];
        [_subsArray addObjectsFromArray:[[SNSubscribeCenterService defaultService] loadSubscribesFromLocalDBWithSubTypeId:_typeId]];
        [self removeRepeatedItemsInSubsArray];
        [_tableView reloadData];
    }
    else if ([dataSet operation] == SCServiceOperationTypeRefreshSubMoreRankList) {
        [_moreCell showLoading:NO];
        _isLoading = NO;
    }
    else if ([dataSet operation] == SCServiceOperationTypeAddMySubToServer) {
        NSString *subId = [dataSet strongDataRef];
        [self.subsRunningOnAddToMySub removeObject:subId];
        
        BOOL bFound = NO;
        for (SCSubscribeObject *subObj in _subsArray) {
            if ([subObj.subId isEqualToString:subId]) {
                bFound = YES;
                break;
            }
        }
        
        if (bFound) {
            [self removeRepeatedItemsInSubsArray];
            [_tableView reloadData];
        }
        
        return;
    }
    else if ([dataSet operation] == SCServiceOperationTypeAddMySubsAndSynchPush) {
        NSDictionary *dic = [dataSet strongDataRef];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSString *addStatementStr = [dic objectForKey:@"yes"];
            addStatementStr = [addStatementStr stringByReplacingOccurrencesOfString:@"&yes=" withString:@""];
            NSArray *subIds = [addStatementStr componentsSeparatedByString:@","];
            if ([subIds count] > 0) {
                NSString *subId = [subIds objectAtIndex:0];
                [self.subsRunningOnAddToMySub removeObject:subId];
                
                BOOL bFound = NO;
                
                for (SCSubscribeObject *subObj in _subsArray) {
                    if ([subObj.subId isEqualToString:subId]) {
                        bFound = YES;
                        break;
                    }
                }
                
                if (bFound) {
                    [self removeRepeatedItemsInSubsArray];
                    [_tableView reloadData];
                }
            }
        }
        return;
    }
    
    
    if ([_subsArray count] <= 0) {
        if ([_delegate respondsToSelector:@selector(subsFindNoDataToLoad)]) {
            [_delegate subsFindNoDataToLoad];
        }
    }
    else {
        if ([_delegate respondsToSelector:@selector(subsFindDataToLoad)]) {
            [_delegate subsFindDataToLoad];
        }
    }
}

- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet {
    if ([dataSet operation] == SCServiceOperationTypeRefreshSubTypeSubItems) {
        
    }
    else if ([dataSet operation] == SCServiceOperationTypeRefreshSubRankList) {
        
    }
    else if ([dataSet operation] == SCServiceOperationTypeAddMySubToServer) {
        NSString *subId = [dataSet strongDataRef];
        [self.subsRunningOnAddToMySub removeObject:subId];
        
        BOOL bFound = NO;
        for (SCSubscribeObject *subObj in _subsArray) {
            if ([subObj.subId isEqualToString:subId]) {
                bFound = YES;
                break;
            }
        }
        
        if (bFound) {
            [self removeRepeatedItemsInSubsArray];
            [_tableView reloadData];
        }
        
        return;
    }
    else if ([dataSet operation] == SCServiceOperationTypeAddMySubsAndSynchPush) {
        NSDictionary *dic = [dataSet strongDataRef];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSString *addStatementStr = [dic objectForKey:@"yes"];
            addStatementStr = [addStatementStr stringByReplacingOccurrencesOfString:@"&yes=" withString:@""];
            NSArray *subIds = [addStatementStr componentsSeparatedByString:@","];
            if ([subIds count] > 0) {
                NSString *subId = [subIds objectAtIndex:0];
                [self.subsRunningOnAddToMySub removeObject:subId];
                
                BOOL bFound = NO;
                
                for (SCSubscribeObject *subObj in _subsArray) {
                    if ([subObj.subId isEqualToString:subId]) {
                        bFound = YES;
                        break;
                    }
                }
                
                if (bFound) {
                    [self removeRepeatedItemsInSubsArray];
                    [_tableView reloadData];
                }
            }
        }
        return;
    }
}

#pragma mark - all sub cell delegate
- (void)allSubCellWillAddMySub:(SCSubscribeObject *)subObj {
    
    if (![SNUserManager isLogin]) {//login
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        NSValue* method = [NSValue valueWithPointer:@selector(loginSuccess)];
#pragma clang diagnostic pop
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:method,@"method",[NSNumber numberWithInteger:SNGuideRegisterTypeSubscribe], kRegisterInfoKeyGuideType, kLoginFromComment, kLoginFromKey, nil];
        //[SNUtility openLoginViewWithDict:dict];
        
        //wangshun login open
        [SNNewsLoginManager loginData:nil Successed:^(NSDictionary *info) {//000疑似废弃
           
        } Failed:nil];
        
        return ;
    }
    
    if ([SNSubscribeCenterService shouldLoginForSubscribeWithObj:subObj]) {
        [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_SUBCENTER referId:subObj.subId referAct:SNReferActSubscribe];
        [SNGuideRegisterManager showGuideWithSubId:subObj.subId];
        return;
    }
    
    // show loading
    [self.subsRunningOnAddToMySub addObject:subObj.subId];
    [self removeRepeatedItemsInSubsArray];
    [_tableView reloadData];
    
    SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubToServer request:nil refId:subObj.subId];
    NSString *sucMsg = [subObj succSubMsg];
    NSString *failMsg = [subObj failSubMsg];
    [opt addBackgroundListenerWithSuccMsg:sucMsg failMsg:failMsg];
    
    if ([_typeId isEqualToString:kSubTypeRankId]) {
        subObj.from = REFER_RANK;
    } else if ([_typeId isEqualToString:kSubTypeRecomendId]) {
        subObj.from = REFER_SUBCENTER_RECOMMENDLIST;
    } else {
        subObj.from = REFER_SUBCENTER;
    }
    
    [[SNSubscribeCenterService defaultService] addMySubToServerBySubObject:subObj];
}

- (void)allSubCell:(SNSubCenterAllSubsCell *)cell willAddMySub:(SCSubscribeObject *)subObj {
    _subAlertView = [[SNSubscribeHintPushAlertView alloc] initWithTitle:subObj.moreInfo
                                                                message:NSLocalizedString(@"unsubscribe hint", @"")
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"not subscribe for now", @"")
                                                       otherButtonTitle:NSLocalizedString(@"subscribe now", @"")];
    _subAlertView.snAlertUserData = cell;
    [_subAlertView show];
}

#pragma mark - SNSubscribeHintPushAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == _subAlertView) {
        
        // 订阅
        if (buttonIndex == 1) {
            SNSubCenterAllSubsCell *cell = _subAlertView.snAlertUserData;
            SCSubscribeObject *subObj = cell.subObj;
            if ([SNSubscribeCenterService shouldLoginForSubscribeWithObj:subObj]) {
                [[SNAnalytics sharedInstance] appendLoginAnalyzeArgumnets:REFER_SUBCENTER referId:subObj.subId referAct:SNReferActSubscribe];
                [SNGuideRegisterManager showGuideWithSubId:subObj.subId];
                return;
            }
            [cell setIsRunning:YES];
            
            [self.subsRunningOnAddToMySub addObject:subObj.subId];
            SNSubscribeCenterOperation *opt = [SNSubscribeCenterOperation operationWithType:SCServiceOperationTypeAddMySubsAndSynchPush request:nil refId:subObj.subId];
            NSString *sucMsg = [subObj succSubMsg];
            NSString *failMsg = [subObj failSubMsg];
            [opt addBackgroundListenerWithSuccMsg:sucMsg failMsg:failMsg];
            
            [[SNSubscribeCenterService defaultService] addListener:self forOperation:SCServiceOperationTypeAddMySubsAndSynchPush];
            [[SNSubscribeCenterService defaultService] addMySubsToServer:[NSArray arrayWithObject:subObj] withPushOpen:_subAlertView.isChecked];
        }
        
        _subAlertView = nil;
    }
}

#pragma mark - private methods

- (void)pushWillCome {
    if (_subAlertView) {
        [_subAlertView dismissWithClickedButtonIndex:0 animated:NO];
    }
}

- (void)checkIfNeedLoadMore {
    NSInteger subsCount = _subsArray.count;
    int wrongOffset = (subsCount + 1) % 20;
    if (subsCount >= HAS_MORE_COUNT && wrongOffset <= 1) {
        _hasMore = YES;
        _pageNum = subsCount / 19 + 1;
    }
    SNDebugLog(@"%@ _hasMore %@ _pageNum %d subsCount %d typeId %@", NSStringFromSelector(_cmd), _hasMore ? @"YES" : @"NO", _pageNum, _subsArray.count, _typeId);
}

- (void)loadMoreSubs {
    if (_hasMore && !_isLoading) {
        if (![SNUtility getApplicationDelegate].isNetworkReachable) {
            [_moreCell showLoading:NO];
            
            _hasMore = NO;
            [self removeRepeatedItemsInSubsArray];
            [_tableView reloadData];
            
            [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
            return;
        }
        _hasMore = NO;
        if ([_typeId isEqualToString:kSubTypeRankId]) {
            [[SNSubscribeCenterService defaultService] loadSubMoreRankListFromServer:_pageNum];
        }
        else if ([_typeId isEqualToString:kSubTypeRecomendId]) {
            [[SNSubscribeCenterService defaultService] loadSubHomeMoreDataFromServerWithPageNo:_pageNum];
        }
        else {
            [[SNSubscribeCenterService defaultService] loadSubscribesFromServerWithSubTypeId:_typeId pageNum:_pageNum];
        }
        _isLoading = YES;
    }
}

- (void)appendMoreSubs:(NSArray *)moreSubs {
    if ([moreSubs count] <= 0) {
        return;
    }
    
    BOOL bMoreCellVisible = (_moreCell.top < (_tableView.contentOffset.y + _tableView.height));
    
    if (bMoreCellVisible) {
        NSInteger moreCellIndex = [[_tableView indexPathForCell:_moreCell] row];
        NSMutableArray *moreSubCellIndexs = [NSMutableArray array];
        
        for (SCSubscribeObject *subObj in moreSubs) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:moreCellIndex inSection:0];
            [moreSubCellIndexs addObject:newIndexPath];
            [_subsArray addObject:subObj];
            moreCellIndex++;
        }
        
        BOOL bNeedReload = NO;
        
        @try {
            [_tableView beginUpdates];
            if (!_hasMore) {
                [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[_tableView indexPathForCell:_moreCell]] withRowAnimation:UITableViewRowAnimationFade];
            }
            [_tableView insertRowsAtIndexPaths:moreSubCellIndexs withRowAnimation:UITableViewRowAnimationBottom];
            [_tableView endUpdates];
        }
        @catch (NSException *exception) {
            bNeedReload = YES;
            SNDebugLog(@"%@-- we catched an exception %@", NSStringFromSelector(_cmd), exception);
        }
        @finally {
            if (bNeedReload) {
                [self removeRepeatedItemsInSubsArray];
                [_tableView reloadData];
            }
        }
    }
    else {
        [_subsArray addObjectsFromArray:moreSubs];
        [self removeRepeatedItemsInSubsArray];
        [_tableView reloadData];
    }
}

- (void)removeRepeatedItemsInSubsArray {
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < [_subsArray count]; i++){
        SCSubscribeObject *subObj = [_subsArray objectAtIndex:i];
        if (![tempArray containsObject:subObj] && !!subObj){
            [tempArray addObject:subObj];
        }
    }
     //(_subsArray);
    _subsArray = tempArray;
}

@end
