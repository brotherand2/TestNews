//
//  SNNewsDownloadManager.m
//  sohunews
//
//  Created by handy wang on 1/8/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNNewsDownloadManager.h"
#import "SNDBManager.h"
#import "SNRollingNewsDownloadManagerFinishType.h"
#import "SNNewsChannelType.h"
#import "SNRollingNewsChannelModule.h"
#import "SNWeiGuanDianChannelModule.h"
#import "SNVideoChannelModule.h"
#import "SNDownloadUtility.h"
#import "SNSubDownloadManager.h"
#import "SNDownloadScheduler.h"


@interface SNNewsDownloadManager() {
    BOOL _isSuspending;
    SNNewsChannelModule *_downloadingChannelModule;
}
@property(nonatomic, strong)SNNewsChannelModule *downloadingChannelModule;

-(void)cancelAllNewsChannelFromDownloadClickArray;
-(void)cancelNewsChannelFromDownloadClickArray:(NewsChannelItem*)aNewsChannle;
@end

@implementation SNNewsDownloadManager
@synthesize toBeDownloadedItems = _toBeDownloadedItems;
@synthesize downloadingChannelModule = _downloadingChannelModule;
@synthesize toBeDownloadedItemsFromDownloadClick = _toBeDownloadedItemsFromDownloadClick;

#pragma mark - Lifecycle

+ (SNNewsDownloadManager *)sharedInstance {
    static SNNewsDownloadManager *_sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstace = [[SNNewsDownloadManager alloc] init];
    });
    return _sharedInstace;
}

- (void)dealloc {
    _delegate = nil;
     //(_toBeDownloadedItems);
     //(_toBeDownloadedItemsFromDownloadClick);
}

#pragma mark - Public methods

//Load将被下载的频道数据（订阅的频道且是在离线设置里勾选的）
- (NSArray *)loadToBeDownloadedNewsInMainThread {
     //(_toBeDownloadedItems);
    
    NSArray* subTempArray = [SNSubDownloadManager sharedInstance].toBeDownloadedItemsFromDownloadClick;
    
    //从刊物页面触发，只下载用户点的；从一键下载触发，只下载用户勾选的
    if(subTempArray!=nil && [subTempArray count]>0)
    {
        self.toBeDownloadedItems = [NSMutableArray arrayWithCapacity:0];
        return self.toBeDownloadedItems;
    }
    //从新闻频道页面触发，只下载用户点的；从一键下载触发，只下载用户勾选的
    else if(_toBeDownloadedItemsFromDownloadClick!=nil && [_toBeDownloadedItemsFromDownloadClick count]>0)
    {
        self.toBeDownloadedItems = [NSMutableArray arrayWithCapacity:0];
        [_toBeDownloadedItems addObjectsFromArray:_toBeDownloadedItemsFromDownloadClick];
    }
    else
    {
        //NSArray* toBeDownloadedItems = [[[SNDBManager currentDataBase] getSelectedSubedNewsChannelList] retain];
        NSArray* toBeDownloadedSubItems = [[SNDBManager currentDataBase] getSubscribeCenterSelectedUndownloadedMySubList];
        NSArray* newsItems = [SNSubDownloadManager generaNewsObjArrayFromSubObjArray:toBeDownloadedSubItems];
        
        NSMutableArray* toBeDownloadedItemsAll = [NSMutableArray arrayWithCapacity:0];
        //if(toBeDownloadedItems!=nil) [toBeDownloadedItemsAll addObjectsFromArray:toBeDownloadedItems];
        if(newsItems!=nil) [toBeDownloadedItemsAll addObjectsFromArray:newsItems];
        _toBeDownloadedItems = toBeDownloadedItemsAll;
    }
    
    for (NewsChannelItem *_newChannelItem in _toBeDownloadedItems) {
        _newChannelItem.downloadStatus = SNDownloadWait;
    }
    return _toBeDownloadedItems;
    
    //TODO: 完成下载或下载失败时这个数组要回收
}

//下载用户设置的所有频道的最新数据
- (void)start {
    [self letAModuleGoInThread];
}

//暂停所有下载
-(BOOL)doSuspendIfNeeded
{
    //当前下载项置成未下载
    NSArray *_waitingItems = [self runningDownloadItems];
    if(_waitingItems!=nil && _waitingItems.count>0)
    {
        for(NewsChannelItem* _tmpDownloadingItem in _waitingItems)
            _tmpDownloadingItem.downloadStatus = SNDownloadWait;
        
        [_downloadingChannelModule cancel];
        
//        if (!!_downloadingChannelModule) {
//            [self cancelDownload:_downloadingChannelModule.newsChannelItem];
//        } else {
//            [self end:SNRNDMFinishTypeCancleDownload];
//        }
        
        _isCanceled = YES;
        _isSuspending = YES;
        return  YES;
    }
    
    return NO;
}

//重置suspend状态
- (void)resetSuspendState
{
    _isSuspending = NO;
}

//是否正在下载
-(BOOL)isSuspending
{
    return _isSuspending;
}

//恢复所有下载
-(BOOL)doResumeIfNeeded
{
//    if(_downloadingChannelModule!=nil)
//        return [_downloadingChannelModule doResumeIfNeeded];
//    
//    return NO;
    if(_isSuspending)
    {
        _isCanceled = NO;
        _isSuspending = NO;
        
//        NSArray *_runningItems = [self runningDownloadItems];
//        for (NewsChannelItem *_item in _runningItems)
//            _item.downloadStatus = SNDownloadWait;
        
        NSArray *_waitingItems = [self waitingDownloadItems];
        if(_waitingItems.count>0)
        {
            [self start];
            return YES;
        }
    }
    
    return NO;
}

//取消全部新闻频道下载
- (void)cancelAll {
    _isCanceled = YES;
    
    //清除所有下载项
    [self cancelAllNewsChannelFromDownloadClickArray];
    
    for (NewsChannelItem *_item in _toBeDownloadedItems) {
        _item.downloadStatus = SNDownloadCancel;
    }
    
    if (!!_downloadingChannelModule) {
        [self cancelDownload:_downloadingChannelModule.newsChannelItem];
    } else {
        [self end:SNRNDMFinishTypeCancleDownload];
    }
    
    //用户主动取消下载后删除下载项
     //(_toBeDownloadedItems);
     //(_toBeDownloadedItemsFromDownloadClick);
}

//强制所有正在下载和等待下载的项失败
- (void)forceAllDownloadToFailWhenEndBgTask {
    SNDebugLog(@"===INFO: Ready to force updating all news to fail...");
    
    //把正在等待下载的项设置为SNDownloadFail
    for (NewsChannelItem *_item in [self waitingDownloadItems]) {
        _item.downloadStatus = SNDownloadFail;
    }
    
    //取消正在下载的项，并把状态设置为SNDownloadFail
    if (!!_downloadingChannelModule) {
        _isForcedToFail = YES;
        [self cancelDownload:_downloadingChannelModule.newsChannelItem];
        SNDebugLog(@"===INFO: Finished1 to force updating all news to fail...");
    }
    else {
        SNDebugLog(@"===INFO: Finished2 to force updating all news to fail...");
        [self end:SNRNDMFinishTypeDownloadAll];
    }
}

//取消某一新闻频道下载
- (void)cancelDownload:(NewsChannelItem *)downloadItem {
    SNDebugLog(@"===INFO: Canceling news download......");
    
    if (!downloadItem) {
        SNDebugLog(@"===INFO: Invalid data when cancel.");
        return;
    }
    
    //清除临时下载项
    [self cancelNewsChannelFromDownloadClickArray:downloadItem];
    
    NewsChannelItem *_downloadingItem =  _downloadingChannelModule.newsChannelItem;
    //取消正在下载项
    /**
     * 要想取消正在下载的moduel以及其内部的newsContentWorkers是很困难的，
     * 所以这里的cancel只是取消module的JSON数据请求以及给每个newsContentWorker置一个cancel的标记位且不会回收任何对象的内存，
     * 这样就可以让正在执行的newsContentWorker内部正在下载的newsContent下完，然后在尝试下载下一次newsContent时就会直接完成，
     * 直到这个正在执行的newsContentWorker完成，以及module内部的其它worker都会直接完成从而回调到newsChannelModule的didFinish方法里，
     * 从而回调到SNNewsDownloadManager的didFinish方法并回收这个被取消的module及附属对象的内存，
     * 所以，在SNNewsDownloadManager的didFinish方法里要判断一下运行完成的module是被cancel的正在运行的module还是正常做完所有事儿的module。
     * 这样就不会在cancel时出现莫名其妙的crash;
     */
    if ([downloadItem.channelId isEqualToString:_downloadingItem.channelId]) {
         //(_canceledChannelModule);
        _canceledChannelModule = _downloadingChannelModule;
        [_downloadingChannelModule cancel];
    }
    //取消等待下载项
    else {
        downloadItem.downloadStatus = SNDownloadCancel;
        if ([_delegate respondsToSelector:@selector(didCancelDownloadItemInMainThread:)]) {
            [_delegate didCancelDownloadItemInMainThread:downloadItem];
        }
    }
}

//重试某一新闻频道下载
- (void)retryDownload:(NewsChannelItem *)downloadItem {
    SNDebugLog(@"===INFO: Retrying news download......");
    
    //网络是否连通
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        SNDebugLog(@"===INFO: Network is not available.");
        return;
    }
    
    if (!downloadItem) {
        SNDebugLog(@"===INFO: Invalid data when retry.");
        return;
    }
    
    //如果没有刊物和新闻正在下载才新起一个下载；
    if ([_delegate respondsToSelector:@selector(isAllDownloadFinished)] && [_delegate isAllDownloadFinished]) {
        [SNDownloadUtility markBgTaskAsBegin];
        
        if ([_delegate respondsToSelector:@selector(resetNewsDownloadingProgressBarInMainThread)]) {
            [_delegate resetNewsDownloadingProgressBarInMainThread];
        }
        downloadItem.downloadStatus = SNDownloadWait;
        [self letAModuleGoInThread];
    }
    //否则只是改变downloadItem的状态并刷新UI样式;
    else {
        if ([_delegate respondsToSelector:@selector(readyToRetryInMainThread:)]) {
            downloadItem.downloadStatus = SNDownloadWait;
            [_delegate readyToRetryInMainThread:downloadItem];
        }
    }
}

//添加某一个新闻频道的下载
-(id)objectFromNewsChannelItemArray:(NSArray*)aArray item:(NewsChannelItem*)aItem
{
    for(NewsChannelItem* item in aArray)
    {
        if(item.channelId!=nil && [item.channelId isEqualToString:aItem.channelId])
            return item;
    }
    return nil;
}

-(BOOL)ifArrayContainItem:(NSArray*)aArray item:(NewsChannelItem*)aItem
{
    return [self objectFromNewsChannelItemArray:aArray item:aItem]!=nil;
}

-(void)addDownloadSub:(SCSubscribeObject *)subdownloadItem
{
    NewsChannelItem* channelItem = [SNSubDownloadManager newsItemFromSubItem:(SCSubscribeObject*)subdownloadItem];
    if(channelItem!=nil)
        [self addDownload:channelItem];
}

-(void)addDownload:(NewsChannelItem *)downloadItem
{
    if (!downloadItem) {
        return;
    }

    //网络是否连通
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_addsub_to_download"), @"") toUrl:nil mode:SNCenterToastModeWarning];
    //如果当前没有处于下载状态，那么开始
    if(![SNDownloadScheduler sharedInstance].isDownloading)
    {
        if(_toBeDownloadedItemsFromDownloadClick==nil)
            _toBeDownloadedItemsFromDownloadClick = [NSMutableArray arrayWithCapacity:0];
        if(![self ifArrayContainItem:_toBeDownloadedItemsFromDownloadClick item:downloadItem])
            [_toBeDownloadedItemsFromDownloadClick addObject:downloadItem];
        
        [[SNDownloadScheduler sharedInstance] start];
    }
    else
    {
        if(![self ifArrayContainItem:_toBeDownloadedItems item:downloadItem])
            [_toBeDownloadedItems addObject:downloadItem];
    }
}

#pragma mark -

//已全部下载完成（无论其中是否有下载失败的）－没有正在下载和等待的项就说明所有待下载项都已尝试下载过，可能其中有下载失败的。
- (BOOL)isAllDownloadFinished {
    //SNNewsDownloadManager中的waiting和正在下载项
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus==0 or downloadStatus==1"];//SNDownloadWait/SNDownloadRunning
    NSArray *_waitingNewsItems = [_toBeDownloadedItems filteredArrayUsingPredicate:_predicate];
    return (_waitingNewsItems.count <= 0);
}

//已全部下载完成但其中有失败的
- (BOOL)isAllDownloadFinishedButAndSomeFail {
    BOOL _isAllDownloadFinished = [self isAllDownloadFinished];
    if (_isAllDownloadFinished) {
        //SNNewsDownloadManager中的fail项
        return ([self failedDownloadedItems].count>0);
    } else {
        return NO;
    }
}

//已全部下载完成但其中有取消的
- (BOOL)isAllDownloadFinishedButAndSomeCancel {
    BOOL _isAllDownloadFinished = [self isAllDownloadFinished];
    if (_isAllDownloadFinished) {
        //SNNewsDownloadManager中的取消项
        return ([self canceledDownloadedItems].count>0);
    } else {
        return NO;
    }
}

//已全部下载完成且其中没有有失败的
- (BOOL)isAllDownloadFinishedAndNoFail {
    BOOL _isAllDownloadFinished = [self isAllDownloadFinished];
    if (_isAllDownloadFinished) {
        //SNNewsDownloadManager中的fail项
        return ([self failedDownloadedItems].count<=0);
    } else {
        return NO;
    }
}

//判断频道是否正在下载
- (BOOL)isChannelDownloading:(NewsChannelItem *)channel {
    return !!(channel.channelId) && ([channel.channelId isEqualToString:_downloadingChannelModule.newsChannelItem.channelId]);
}

//频道是否为失败项
- (BOOL)isChannelFailed:(NewsChannelItem *)channel {
    for (NewsChannelItem *_failedNewsItem in [self failedDownloadedItems]) {
        if (!!(channel.channelId) && ([channel.channelId isEqualToString:_failedNewsItem.channelId])) {
            return YES;
        }
    }
    return NO;
}

//频道是否不在下载队列中
- (BOOL)isChannelDetached:(NewsChannelItem *)channel {
    for (NewsChannelItem *_channelItem in _toBeDownloadedItems) {
        if (!!(channel.channelId) && ([channel.channelId isEqualToString:_channelItem.channelId])) {
            return NO;
        }
    }
    return YES;
}

//频道是否在下载队列中
- (BOOL)isSubChannelInList:(SCSubscribeObject*)subscribe{
    NewsChannelItem* channel = [SNSubDownloadManager newsItemFromSubItem:(SCSubscribeObject*)subscribe];
    for (NewsChannelItem *_channelItem in _toBeDownloadedItems) {
        if ((channel.channelId!=nil) && ([channel.channelId isEqualToString:_channelItem.channelId])) {
            if((channel.downloadStatus==SNDownloadWait) || (channel.downloadStatus==SNDownloadRunning))
            return YES;
        }
    }
    return NO;
}

#pragma mark - Private methods

- (void)letAModuleGoInThread {
    if (_isCanceled) {
        [self end:SNRNDMFinishTypeCancleDownload];
        return;
    }
    
    //网络是否连通
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        NSArray *_waitingDownloadItems = [self waitingDownloadItems];
        if (!!_waitingDownloadItems && (_waitingDownloadItems.count > 0)) {
            for (NewsChannelItem *_item in _waitingDownloadItems) {
                _item.downloadStatus = SNDownloadFail;
            }
        }
        
        //Exit Point2
        SNDebugLog(@"===INFO: ExitPoint2, End news download manager with network unreachable.");
        [self end:SNRNDMFinishTypeNetworkUnreachable];
        return;
    }
    
    if ([self isAllDownloadFinished]) {
        //Exit Point3
        SNDebugLog(@"===INFO: ExitPoint3, End news download manager with finishing download all.");
        [self end:SNRNDMFinishTypeDownloadAll];
        return;
    }
    
    //-----------Create module
    NSArray *_waitingDownloadItems = [self waitingDownloadItems];
    SNDebugLog(@"==========INFO: Main thread:%d, there are %d channels to be downloaded.", [NSThread isMainThread], _waitingDownloadItems.count);
    
    if (!!_waitingDownloadItems && _waitingDownloadItems.count > 0) {
        NewsChannelItem *_channelItem = [_waitingDownloadItems objectAtIndex:0];
        if (!!(_channelItem.channelType) && ![@"" isEqualToString:_channelItem.channelType]) {
            SNDebugLog(@"===INFO: Ready to download channel %@", _channelItem.channelName);
            
            switch ([_channelItem.channelType intValue]) {
                case NewsChannelTypeNews: {
                    self.downloadingChannelModule = [[SNRollingNewsChannelModule alloc] initWithDelegate:self];
                    break;
                }
//4.0.1版去掉
//                case SNNewsChannelType_Live: {
//                    self.downloadingChannelModule = [[[SNLiveChannelModule alloc] initWithDelegate:self] autorelease];
//                    break;
//                }
                case NewsChannelTypeVideo: {
                    self.downloadingChannelModule = [[SNVideoChannelModule alloc] initWithDelegate:self];
                    break;
                }
                case NewsChannelTypeWeiboHot: {
                    self.downloadingChannelModule = [[SNWeiGuanDianChannelModule alloc] initWithDelegate:self];
                    break;
                }
            }
            
            if (!!_downloadingChannelModule) {
                _downloadingChannelModule.channelID = _channelItem.channelId;
                _downloadingChannelModule.channelName = _channelItem.channelName;
                _downloadingChannelModule.channelType = [_channelItem.channelType intValue];
                _downloadingChannelModule.newsChannelItem = _channelItem;
                [_downloadingChannelModule startInThread];
            }
        }
    }
}

- (NSArray *)waitingDownloadItems {
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus==0"];//SNDownloadWait
    return [_toBeDownloadedItems filteredArrayUsingPredicate:_predicate];
}

- (NSArray *)runningDownloadItems {
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus==1"];//SNDownloadRunning
    return [_toBeDownloadedItems filteredArrayUsingPredicate:_predicate];
}

- (NSArray *)failedDownloadedItems {
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus==2"];//SNDownloadFail
    return [_toBeDownloadedItems filteredArrayUsingPredicate:_predicate];
}

- (NSArray *)canceledDownloadedItems {
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus==4"];//SNDownloadCancel
    return [_toBeDownloadedItems filteredArrayUsingPredicate:_predicate];
}

#pragma mark -

- (void)didStartDownloadingModule:(SNNewsChannelModule *)module {
    module.newsChannelItem.downloadStatus = SNDownloadRunning;
    
    //这是一个更新UI的机会
    if ([_delegate respondsToSelector:@selector(didStartDownloadAItemInMainThread:)]) {
        [_delegate didStartDownloadAItemInMainThread:module.newsChannelItem];
    }
}

- (void)didFinishDownloadingModule:(SNNewsChannelModule *)module {
    
    if ([_canceledChannelModule.newsChannelItem.channelId isEqualToString:module.newsChannelItem.channelId]) {
        [self didCancelDownloadingModule:module];
         //(_canceledChannelModule);
        return;
    }
    
    /**
     * 因为网络连接异常时，SNNewsDownloadManager的didFinishDownloadingModule也会被回调到，这时很可能正在下载某频道，所以做了如下判断：
     * 即：网络不可用时且当前回调的频道处于下载状态，则把这个回调的频道视为下载失败，至于其它等待下载的频道的失败状态会在下面调用到letAModuleGoInThread方法里时设置。
     */
    if ((![SNUtility getApplicationDelegate].isNetworkReachable) && (module.newsChannelItem.downloadStatus == SNDownloadRunning)) {
        module.newsChannelItem.downloadStatus = SNDownloadFail;
    }
    else {
        module.newsChannelItem.downloadStatus = SNDownloadSuccess;
    }
    
    //如果网络不可用则把所有等待的项设为fail，这要在下面的didFinishedDownloadAItemInMainThread方法更新进度时就会更新为100％
    if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        NSArray *_waitingDownloadItems = [self waitingDownloadItems];
        if (!!_waitingDownloadItems && (_waitingDownloadItems.count > 0)) {
            for (NewsChannelItem *_item in _waitingDownloadItems) {
                _item.downloadStatus = SNDownloadFail;
            }
        }
    }
    
    SNDebugLog(@"===INFO: Finished channel %@ downloaded, there are %d channels left.", module.channelName, [self waitingDownloadItems].count);
    
    //清除临时下载项
    for(NSInteger i=[_toBeDownloadedItemsFromDownloadClick count]-1; i>=0; i--)
    {
        id object = [_toBeDownloadedItemsFromDownloadClick objectAtIndex:i];
        if(object!=nil && [object isKindOfClass:[NewsChannelItem class]])
        {
            NewsChannelItem* item = (NewsChannelItem*)object;
            if(item.channelId!=nil && [item.channelId isEqualToString:module.channelID])
                [_toBeDownloadedItemsFromDownloadClick removeObjectAtIndex:i];
        }
    }
    
    // 更新下载状态
    SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:module.newsChannelItem.subId];
    
    BOOL bChangeStatus = NO;

        bChangeStatus = [subObj setStatusValue:[KHAD_BEEN_OFFLINE intValue] forFlag:SCSubObjStatusFlagSubStatus];

    subObj.isDownloaded = kHAD_DOWNLOADED;
    
    [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:NO];
    
    if (bChangeStatus) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:subObj.subId, @"subId", subObj.status, @"status", nil];
        [SNNotificationManager postNotificationName:kSubscribeObjectStatusChangedNotification object:nil userInfo:dict];
    }    
    
    //这是一个更新UI的机会
    if ([_delegate respondsToSelector:@selector(didFinishedDownloadAItemInMainThread:)]) {
        [_delegate didFinishedDownloadAItemInMainThread:module.newsChannelItem];
    }
    
    [self letAModuleGoInThread];
}
- (void)didFailedToDownloadModule:(SNNewsChannelModule *)module {
    module.newsChannelItem.downloadStatus = SNDownloadFail;
    
    SNDebugLog(@"===INFO: Failed download channel %@, there are %d channels left.", module.channelName, [self waitingDownloadItems].count);
    
    //这是一个更新UI的机会
    if ([_delegate respondsToSelector:@selector(didFailedToDownloadAItemInMainThread:)]) {
        module.newsChannelItem.downloadStatus = SNDownloadFail;
        [_delegate didFailedToDownloadAItemInMainThread:module.newsChannelItem];
    }

    [self letAModuleGoInThread];
}

- (void)didCancelDownloadingModule:(SNNewsChannelModule *)module {
    if (_isForcedToFail) {
        _isForcedToFail = NO;
        module.newsChannelItem.downloadStatus = SNDownloadFail;
        SNDebugLog(@"===INFO: Force channel %@ to fail.", module.newsChannelItem.channelName);
    }
    else {
        module.newsChannelItem.downloadStatus = SNDownloadCancel;
    }
    
    SNDebugLog(@"===INFO: Did cancel download channel %@, there are %d channels left.", module.channelName, [self waitingDownloadItems].count);
    
    //这是一个更新UI的机会
    if ([_delegate respondsToSelector:@selector(didCancelDownloadItemInMainThread:)]) {
        [_delegate didCancelDownloadItemInMainThread:module.newsChannelItem];
    }
    
    [self letAModuleGoInThread];
}

- (void)didFinishDownloadingCount:(NSInteger)aFininsh total:(NSInteger)aTotal{
    CGFloat percent = (CGFloat)aFininsh/(CGFloat)aTotal;
    SNDebugLog(@"~~~~~~~~~~%f~~~~~~~~~~", percent);
    
    if ([_delegate respondsToSelector:@selector(updateNewsOrPubDownloadProgressInMainThread:)])
        [_delegate updateNewsOrPubDownloadProgressInMainThread:[NSNumber numberWithFloat:percent]];
}

- (void)end:(SNRollingNewsDownloadManagerFinishType)finishType {
    SNDebugLog(@"===INFO: Finished to download all channels.");
    
    switch (finishType) {
        case SNRNDMFinishTypeNetworkUnreachable: {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
            break;
        }
        case SNRNDMFinishTypeChannelsIsEmpty: {
            if (![NSThread isMainThread]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"nothing to download", @"") toUrl:nil mode:SNCenterToastModeWarning];
                });
            } else {
                [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"nothing to download", @"") toUrl:nil mode:SNCenterToastModeWarning];
            }
            break;
        }
        case SNRNDMFinishTypeDownloadAll: {
            break;
        }
        case SNRNDMFinishTypeCancleDownload: {
            SNDebugLog(@"===INFO: SNNewsDownloadManager is canceled.");
            _isCanceled = NO;
            break;
        }
        case SNRNDMFinishTypeUnknown: {
            //Do nothing;
            break;
        }
        default:
            break;
    }
    
    if ([_delegate respondsToSelector:@selector(didFinishedDownloadAllNewsInMainThread)]) {
        //[self releaseToBeDownloadedItemsIfNeeded];
        [_delegate didFinishedDownloadAllNewsInMainThread];
        /**
         * 如果全部完成，但有失败的下载项千万不能把delegate置为nil；
         * 因为置为nil后，在cancel和retry单个失败项时scheduler将不影响，应该delegate<scheduler>已经为nil了。
         */
        if ([self isAllDownloadFinishedAndNoFail]) {
            _delegate = nil;
        }
    }
    
     //(_downloadingChannelModule);
}

- (void)releaseToBeDownloadedItemsIfNeeded {
    if (!_toBeDownloadedItems || (_toBeDownloadedItems.count <= 0)) {
         //(_toBeDownloadedItems);
    }
    
    NSArray *_failedItems = [self failedDownloadedItems];
    
     //(_toBeDownloadedItems);
    if (_failedItems.count > 0) {
        _toBeDownloadedItems = [NSMutableArray arrayWithArray:_failedItems];
    }
}

-(void)cancelAllNewsChannelFromDownloadClickArray
{
    [_toBeDownloadedItemsFromDownloadClick removeAllObjects];
}

-(void)cancelNewsChannelFromDownloadClickArray:(NewsChannelItem*)aNewsChannle
{
    if(aNewsChannle==nil || ![aNewsChannle isKindOfClass:[NewsChannelItem class]])
        return;
    
    for(NSInteger i=[_toBeDownloadedItemsFromDownloadClick count]-1; i>=0; i--)
    {
        id object = [_toBeDownloadedItemsFromDownloadClick objectAtIndex:i];
        if(object!=nil && [object isKindOfClass:[NewsChannelItem class]])
        {
            NewsChannelItem* item = (NewsChannelItem*)object;
            if(item.channelId!=nil && [item.channelId isEqualToString:aNewsChannle.channelId])
                [_toBeDownloadedItemsFromDownloadClick removeObjectAtIndex:i];
        }
    }
}
@end
