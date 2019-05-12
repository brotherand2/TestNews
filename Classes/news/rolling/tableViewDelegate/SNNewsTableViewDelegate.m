//
//  SNRollingNewsDragRefreshDelegate.m
//  sohunews
//
//  Created by Cong Dan on 3/22/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNNewsTableViewDelegate.h"
#import "SNRollingNewsViewController.h"
#import "NSCellLayout.h"
#import "SNCheckManager.h"
#import "SNNewsModel.h"
#import "SNRollingNewsPublicManager.h"
#import "SNSubscribeNewsModel.h"
#import "SNAppStateManager.h"
#import "SNSpecialActivity.h"

@interface SNNewsTableViewDelegate (){
    CGFloat _originOffsetY;
}
@end

@implementation SNNewsTableViewDelegate

- (BOOL)isModelEmpty {
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return YES;
}

- (BOOL)isHomeChannel {
    //是否有推荐新闻
    return NO;
}

- (BOOL)isNewHomeChannel {
    //是否全屏要闻
    return NO;
}

- (BOOL)isRecomendNewChannel {
    return NO;
}

- (void)reload {
    //判断是否重置刷新
    if ([self shouldReSetLoad]) {
        [self autoRefresh];
        return;
    }
    
    BOOL hasNoCache = [self isModelEmpty];
    
    if (hasNoCache) {
        //use cache first
        [_model load:TTURLRequestCachePolicyLocal more:NO];
        
        [_model load:TTURLRequestCachePolicyNetwork more:NO];
    } else {
        //query server every 5 min
        if ([self shouldReload]) {
            [_model load:TTURLRequestCachePolicyNetwork more:NO];
        }
    }
}

- (void)autoRefresh {
    if (_model.isLoading) {
        if ([SNRollingNewsPublicManager sharedInstance].resetOpen) {
            [SNRollingNewsPublicManager sharedInstance].resetOpen = NO;
        }
        return;
    }
    
    //自动刷新当下拉刷新处理
    if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *newsModel = (SNRollingNewsModel *)_model;
        newsModel.isPullRefresh = YES;
        if ([SNRollingNewsPublicManager sharedInstance].isRollingEditNewsShow && [SNRollingNewsPublicManager sharedInstance].isClickBackToHomePage && [SNRollingNewsPublicManager sharedInstance].resetOpen) {
            newsModel.showRecommend = NO;
        }
        newsModel.topNewsIndex = 0;//置顶新闻重头轮播，对非流式频道无效
        if (newsModel.isNewChannel && ![newsModel isHomeEidtPage] && [SNRollingNewsPublicManager sharedInstance].clearAllCache == NO/*增加最后这个条件是为了解决手动清理缓存后，回到首页不显示新闻问题,如有问题，请删掉*/) {
            [_model load:TTURLRequestCachePolicyLocal more:NO];
        }
    }
    
    if ([SNRollingNewsPublicManager sharedInstance].isRequestChannelData) {
        return;
    }
    [_model load:TTURLRequestCachePolicyNetwork more:NO];
}

- (void)onlyRefresh {
    BOOL isLoading = _model.isLoading;
    if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *model = (SNRollingNewsModel*)_model;
        isLoading = [model isLoadingTrainList] ? NO : isLoading;
        model.isPullRefresh = YES;
    }
    if (isLoading) {
        if ([SNRollingNewsPublicManager sharedInstance].resetOpen) {
            [SNRollingNewsPublicManager sharedInstance].resetOpen = NO;
        }
        return;
    }
    
    if ([SNRollingNewsPublicManager sharedInstance].isRequestChannelData) {
        return;
    }
    [_model load:TTURLRequestCachePolicyNetwork more:NO];
}

- (BOOL)shouldReloadLocalWithChannelId:(NSString *)channelId {
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return NO;
}

- (BOOL)shouldRequestNetwork {
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        //return NO;
    }
    
    BOOL hasNoCache = [self isModelEmpty];
    if (hasNoCache) {
        if ([_model isKindOfClass:[SNNewsModel class]]) {
            SNNewsModel *newsMode = (SNNewsModel *)_model;
            [[SNRollingNewsPublicManager sharedInstance] deleteRequestParamsWithChannelId:newsMode.channelId];
        }
        if ([SNRollingNewsPublicManager sharedInstance].refreshChannel == YES) {
            [SNRollingNewsPublicManager sharedInstance].refreshChannel = NO;
        }
        
        //频道刷新1小时逻辑 wyy
        if ([self isRecomendNewChannel]) {
            [SNUtility setTimeToResetChannel];
        }
        
        //新版全屏幕要闻频道每天6点重置，其他刷新
        if ([self isNewHomeChannel] && [SNUtility isTimeToResetChannel]) {
            [SNUtility deleteChannelParamsWithChannelId:[SNUtility sharedUtility].currentChannelId];
            [SNNewsFullscreenManager setOpenAppToday:YES];
            
            //要闻重置删除不必要的历史
            SNRollingNewsModel *rollingModel = (SNRollingNewsModel *)_model;
            [[SNDBManager currentDataBase] clearRollingNewsHistoryByChannelID:rollingModel.channelId days:[[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsSaveDays]];
            return YES;
        }
        
        return YES;
    } else {
        if ([self shouldReload]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)hasNoCache{
    BOOL noCache = NO;
    if ([_model isKindOfClass:[SNRollingNewsModel class]]) {
        SNRollingNewsModel *rollingModel = (SNRollingNewsModel *)_model;
        noCache = rollingModel.rollingNews.count == 0;
    }
    else if ([_model isKindOfClass:[SNSubscribeNewsModel class]]){
        SNSubscribeNewsModel *subscribeModel = (SNSubscribeNewsModel *)_model;
        noCache = subscribeModel.isSubscribeEmpty;
    }
    else if ([_model isKindOfClass:[SNLiveModel class]]){
        SNLiveModel *livingModel = (SNLiveModel *)_model;
        noCache = ((livingModel.livingGamesToday.count + livingModel.livingGamesForecast.count) == 0);
    }
    else if (_model == nil){
        noCache = YES;
    }
    else{
        noCache = [self isModelEmpty];
    }

    _controller.tableView.scrollEnabled = !noCache;
    return noCache;
}

- (void)loadLocal {
    [_model load:TTURLRequestCachePolicyLocal more:NO];
}

- (void)loadNetwork {
    [_model load:TTURLRequestCachePolicyNetwork more:NO];
}

- (BOOL)reloadWithChannelNewsTime:(NSTimeInterval)channelInterval {
    SNNewsModel *model = (SNNewsModel *)_model;
    NSString *channelId = [model channelId];
    NSTimeInterval interval = [model refreshIntervalWithDefault:channelInterval];
    
    NSString *timeKey = [NSString stringWithFormat:@"channel_%@_refresh_time", channelId];
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:timeKey];
    if (data && [data isKindOfClass:[NSDate class]]) {
        return [(NSDate *)[data dateByAddingTimeInterval:interval] compare:[NSDate date]] < 0;
    } else {
        return YES;
    }
}

//重置刷新
- (BOOL)shouldReSetLoad {
    //后台激活app，判断频道是否刷新过1小时;
    //第二天早上6点，需要重置频道
    if ([self isNewHomeChannel]) {
        if ([SNUtility isTimeToResetChannel]) {
            [SNUtility deleteChannelParamsWithChannelId:[SNUtility sharedUtility].currentChannelId];
            [SNNewsFullscreenManager setOpenAppToday:YES];
            
            //要闻重置删除不必要的历史
            SNRollingNewsModel *rollingModel = (SNRollingNewsModel *)_model;
            [[SNDBManager currentDataBase] clearRollingNewsHistoryByChannelID:rollingModel.channelId days:[[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsSaveDays]];
            return YES;
        }
        if ([SNUtility shouldResetChannel]) {
            //一小时刷新
            return YES;
        }
    }
    
    if ([self isRecomendNewChannel]) {
        if ([SNUtility isTimeToResetChannel]) {
            [SNUtility deleteChannelParamsWithChannelId:[SNUtility sharedUtility].currentChannelId];
            
            return YES;
        }
        
        if ([SNUtility shouldResetChannel]) {
            //一小时刷新
            return YES;
        }
    }

    NSString *channelId = [SNUtility sharedUtility].currentChannelId;
    //5.2.2 启动首次进入频道, 刷新 wyy
    if ([[SNAppStateManager sharedInstance] appFinishLaunchLoadNewsWithChannelId:channelId]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)shouldReload {
    //5.3如果股票频道有添加或删除，刷新股票频道,此标志，刷新结束后，置为no
    if ([SNRollingNewsPublicManager sharedInstance].refreshStock == YES) {
        return YES;
    }
    
    //判断如果是本地频道, 正在切换城市的时候
    if ([_controller.model isKindOfClass:[SNRollingNewsModel class]]) {
        BOOL isLocalChannel = ((SNRollingNewsModel *)_controller.model).isLocalChannel;
        if (isLocalChannel && [SNRollingNewsPublicManager sharedInstance].isChangingLocalChannel) {
            return NO;
        }
    }

    //娱乐本地频道刷新1小时逻辑 wyy
    if ([self isRecomendNewChannel]) {
        if ([SNRollingNewsPublicManager needResetCurChannel] ||
            [SNUtility isTimeToResetChannel] ||
            [SNUtility shouldResetChannel]) {
            //重启，重置
            [SNUtility deleteChannelParamsWithChannelId:[SNUtility sharedUtility].currentChannelId];
            return YES;
        }
    }
    
    //新版全屏幕要闻频道每天6点重置，其他刷新
    if ([self isNewHomeChannel]) {
        if ([SNUtility isTimeToResetChannel]) {
            [SNUtility deleteChannelParamsWithChannelId:[SNUtility sharedUtility].currentChannelId];
            [SNNewsFullscreenManager setOpenAppToday:YES];
            
            //要闻重置删除不必要的历史
            SNRollingNewsModel *rollingModel = (SNRollingNewsModel *)_model;
            [[SNDBManager currentDataBase] clearRollingNewsHistoryByChannelID:rollingModel.channelId days:[[SNAppConfigManager sharedInstance].config.appNewsSettingConfig getNewsSaveDays]];
            return YES;
        }
        
        if ([SNUtility shouldResetChannel]) {
            //一小时刷新
            return YES;
        }
    }
    
    //5.2.2 点击当前频道tab，重置刷新 wyy
    SNNewsModel *model = (SNNewsModel *)_model;
    NSString *channelId = [model channelId];
    
    BOOL isHome = [self isHomeChannel];
    //5.2.2 启动首次进入频道，刷新 wyy
    if ([[SNAppStateManager sharedInstance] appFinishLaunchLoadNewsWithChannelId:channelId]) {
        if (isHome) {
            [SNRollingNewsPublicManager sharedInstance].resetOpen = YES;
        }
        return YES;
    }
    
    if (isHome &&
        [SNRollingNewsPublicManager sharedInstance].resetOpen == YES) {
        return YES;
    } else if ([self shouldReloadAfterUpgrade]) {
        return YES;
    } else {
        //进入首页的必经入口,如果是首页，且没有达到刷新条件，提示用户刷新 --wyy
        if (isHome) {
            SNHomePageLeave timeMode = [[SNRollingNewsPublicManager sharedInstance] getLeaveHomeTimeMode];
            if (timeMode == SNHomePageLeave1Hour) {
                SNNewsModel *model = (SNNewsModel *)_model;
                NSString *channelId = [model channelId];
                if (![[NSUserDefaults standardUserDefaults] boolForKey:kEnterToNewsTabKey]) {
                    if (![[NSUserDefaults standardUserDefaults] boolForKey:kShowLoadingPageKey]) {
                        if ([SNNewsFullscreenManager manager].fullscreenMode == YES
                            && [self isHomePage]) {
                        } else {
                            [self initInsertToast:kEnterForegroundTips channelId:channelId];
                            [self insertToastAnimation];
                        }
                    }
                } else {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kEnterToNewsTabKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                [[SNRollingNewsPublicManager sharedInstance] resetLeaveHomeTime];
            }
        }
        return NO;
    }
}

- (BOOL)shouldReloadAfterUpgrade {
    SNNewsModel *model = (SNNewsModel *)_model;
    NSString *channelId = [model channelId];
    NSString *key = [NSString stringWithFormat:@"channel_%@_force_refresh", channelId];
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return !data;
}

- (BOOL)reloadChannelNews {
    return [self reloadWithChannelNewsTime:[SNCheckManager sharedInstance].contentRefreshInterval];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)modelDidFinishLoad:(id<TTModel>)model {
    [self hasNoCache];
	[super modelDidFinishLoad:model];
    if (_enablePreload) {
        [self startFetchDataInWifi];
    }
    _originOffsetY = 0;
}

- (void)startFetchDataInWifi {
    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [super tableView:tableView viewForHeaderInSection:section];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    if ([_controller respondsToSelector:@selector(scrollViewWillBeginDragging)]) {
        [_controller performSelector:@selector(scrollViewWillBeginDragging) withObject:nil];
    }
    [SNNotificationManager postNotificationName:kCloseTipsImageViewNotification object:nil];
    if (_originOffsetY == 0) {
        _originOffsetY = scrollView.contentOffset.y;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    if ([_controller respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_controller performSelector:@selector(scrollViewDidScroll:) withObject:scrollView];
    }
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    if ([_controller respondsToSelector:@selector(scrollViewDidEndDragging:willBeDecelerate:)]) {
        [_controller performSelector:@selector(scrollViewDidEndDragging:willBeDecelerate:) withObject:scrollView withObject:@(decelerate)];
    }
    if (scrollView.contentOffset.y < _originOffsetY || scrollView.contentOffset.y > (_originOffsetY + 250/2.f)) {
        if (_originOffsetY != 0) {
            [[SNSpecialActivity shareInstance] dismissLastChannelSpecialAlert];
        }
    }
}
#pragma clang diagnostic pop
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [SNRollingNewsPublicManager sharedInstance].pageViewTimer = YES;
    if ([_controller respondsToSelector:@selector(scrollViewDidEndDecelerating)]) {
        [_controller performSelector:@selector(scrollViewDidEndDecelerating) withObject:nil];
    }
    
//    SNDebugLog(@"scrollViewDidEndDecelerating YES");
}

@end
