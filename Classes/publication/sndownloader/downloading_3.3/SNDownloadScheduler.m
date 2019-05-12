//
//  SNDownloadScheduler.m
//  sohunews
//
//  Created by handy wang on 1/24/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNDownloadScheduler.h"
#import "SNDownloaderAlert.h"
#import "SNSubDownloadManager.h"
#import "SNNewsDownloadManager.h"
#import "SNDownloadingSectionData.h"
#import "SNStatusBarMessageCenter.h"
#import "SNDownloadViewController.h"
#import "SNDownloadUtility.h"
#import "SNDownloadManager.h"

#import "SNNewAlertView.h"

//#define kWWANNetworkReachAlertViewTag                           (10)
//#define kCancelAllDownloadAlertViewTag                          (20)

@interface SNDownloadScheduler()
{
    NetworkStatus _netStatus;
}
@end

@implementation SNDownloadScheduler
@synthesize percent = _percent;
@synthesize failTime = _failTime;
@synthesize isDownloading = _isDownloading;
@synthesize currentDownloading = _currentDownloading;
@synthesize didUserCancelAllDownloads = _didUserCancelAllDownloads;

+ (SNDownloadScheduler *)sharedInstance {
    static SNDownloadScheduler *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNDownloadScheduler alloc] init];
        [SNNotificationManager addObserver:_sharedInstance selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    });
    return _sharedInstance;
}

- (void)setDelegate:(id)delegate {
    if (!_multicastDelegates) {
        _multicastDelegates = [[NSMutableArray alloc] init];
    }
    if ([_multicastDelegates indexOfObject:delegate] == NSNotFound) {
        [_multicastDelegates addObject:delegate];
    }
}

- (void)resetDelegates {
    [_multicastDelegates removeAllObjects];
}

- (void)removeDelegate:(id)delegate {
    if (!!delegate) {
        [_multicastDelegates removeObject:delegate];
    }
}

- (void)notifyDelegatesWithSelector:(SEL)selector withObject:(id)dataObj needResetDelegates:(BOOL)need {
    //SNDebugLog(@"===INFO: Before1 notifyDelegatesWithSelector main thread: %d, Selector: %@, delegates count: %d",
               //[NSThread isMainThread], NSStringFromSelector(selector), _multicastDelegates.count);
    for (int i=0; i<_multicastDelegates.count; i++) {
        //SNDebugLog(@"===INFO: Delegate %d: %@", i, NSStringFromClass([[_multicastDelegates objectAtIndex:i] class]));
    }
    
    //TODO: Crash here sometimes.
    dispatch_apply([_multicastDelegates count], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index){
        //SNDebugLog(@"===INFO: Before2 notifyDelegatesWithSelector main thread: %d, Selector: %@, delegates count: %d",
                   //[NSThread isMainThread], NSStringFromSelector(selector), _multicastDelegates.count);
        if(index<[_multicastDelegates count])
        {
            id _delegate = [_multicastDelegates objectAtIndex:index];
            [self performDelegate:_delegate selector:selector withObject:dataObj];
        }
    });
    if (need) {
        [self resetDelegates];
    }
}

- (void)performDelegate:(id)delegate selector:(SEL)delegateSelector withObject:(id)dataObj {
    if (!!delegate && [delegate respondsToSelector:delegateSelector]) {
        //获得类和方法的签名
        NSMethodSignature *_methodSignature = [[delegate class] instanceMethodSignatureForSelector:delegateSelector];
        //从签名获得调用对象
        NSInvocation *_invocation = [NSInvocation invocationWithMethodSignature:_methodSignature];
        //设置target
        [_invocation setTarget:delegate];
        //设置selector
        [_invocation setSelector:delegateSelector];
        if (dataObj) {
            __unsafe_unretained id _dataObj = dataObj;
            //设置参数，第一个参数index为2
            [_invocation setArgument:&_dataObj atIndex:2];
        }
        //必须retain一遍参数
        [_invocation retainArguments];
        [_invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:[NSThread isMainThread]];
    }
}

- (void)dealloc {
     //(_multicastDelegates);
     //(_currentDownloading);
    [SNNotificationManager removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)start {
    //如果目前正在下载，忽略
    if(self.isDownloading)
        return;
    
    //网络是否连通
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    _netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    [self startInWifi];
}

//暂停所有下载
- (void)doSuspendIfNeeded
{
    BOOL result = [[SNSubDownloadManager sharedInstance] doSuspendIfNeeded];
    if(!result)
        result = [[SNNewsDownloadManager sharedInstance] doSuspendIfNeeded];
    
    //成功挂起
    if(result)
    {
        [[SNStatusBarMessageCenter sharedInstance] hideMessageImmediately];

        [SNDownloadScheduler sharedInstance].isDownloading = NO;
        [SNDownloadScheduler sharedInstance].currentDownloading = nil;
        
        //暂停通知
        [SNNotificationManager postNotificationName:kDoSuspendNowNotification object:nil];
    }
}

//恢复所有下载
- (void)doResumeIfNeeded
{
    BOOL result = [[SNSubDownloadManager sharedInstance] doResumeIfNeeded];
    if(!result)
        result = [[SNNewsDownloadManager sharedInstance] doResumeIfNeeded];
    
    //成功恢复
    if(result)
    {
        //如果正在下载某刊物，那么把提示继续加上
        [SNDownloadScheduler sharedInstance].isDownloading = YES;
        NSString* currentDownlongding = [SNDownloadScheduler sharedInstance].currentDownloading;
        if(currentDownlongding!=nil && [currentDownlongding length]>0) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:currentDownlongding toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        //恢复通知
        [SNNotificationManager postNotificationName:kDoResumeNowNotification object:nil];
        //刷新页面
        [self refreshDownloadingListInMainThread];
    }
}

//是否正在下载
-(BOOL)isSuspending
{
    return [[SNSubDownloadManager sharedInstance] isSuspending] || [[SNNewsDownloadManager sharedInstance] isSuspending];
}

- (void)downloadSub:(SCSubscribeObject *)sub {
    sub.isSpecifiedTerm = YES;
    [[SNSubDownloadManager sharedInstance] setDelegate:self];
    [[SNSubDownloadManager sharedInstance] downloadSub:sub];
}

//取消全部刊物和频道下载
- (void)cancelAll {
    if([SNDownloadScheduler sharedInstance].isDownloading)
        [self cleanDownloadingListInMainThread];
}

//强制所有正在下载和等待下载的项失败
- (void)forceAllDownloadToFailWhenEndBgTask {
    SNDebugLog(@"===INFO: Ready to force updating all sub and news to fail...");
    
    [[SNSubDownloadManager sharedInstance] setDelegate:self];
    [[SNSubDownloadManager sharedInstance] forceAllDownloadToFailWhenEndBgTask];
    
    [[SNNewsDownloadManager sharedInstance] setDelegate:self];
    [[SNNewsDownloadManager sharedInstance] forceAllDownloadToFailWhenEndBgTask];
}

//取消指定的下载项
- (void)cancelDownload:(id)downloadItem {
    if (!downloadItem) {
        SNDebugLog(@"===INFO: Ignore canceling a download, because the item to be canceled is empty.");
        return;
    }
    
    //取消一个刊物下载
    if ([downloadItem isKindOfClass:[SCSubscribeObject class]]) {
        SCSubscribeObject *_sub = (SCSubscribeObject *)downloadItem;
        [[SNSubDownloadManager sharedInstance] cancelDownload:_sub];
    }
    //取消一个新闻频道下载
    else if ([downloadItem isKindOfClass:[NewsChannelItem class]]) {
        NewsChannelItem *_newChannelItem = (NewsChannelItem *)downloadItem;
        [[SNNewsDownloadManager sharedInstance] cancelDownload:_newChannelItem];
    }
}

//重试某失败项
- (void)retryDownload:(id)downloadItem {
    //网络是否连通
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        SNDebugLog(@"===INFO: Network is not available.");
        return;
    }
    
    if (!downloadItem) {
        SNDebugLog(@"===INFO: Ignore retrying a download, because the item to be retried is empty.");
        return;
    }
    
    //重试一个刊物下载
    if ([downloadItem isKindOfClass:[SCSubscribeObject class]]) {
        SCSubscribeObject *_sub = (SCSubscribeObject *)downloadItem;
        
        NSString *_itemName = (!!(_sub.termName) && ![@"" isEqualToString:_sub.termName]) ? _sub.termName : _sub.subName;
        self.currentDownloading = [NSString stringWithFormat:NSLocalizedString(@"sbm_downloading", nil), _itemName];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"retry_download_item", nil), _itemName] toUrl:nil mode:SNCenterToastModeOnlyText];
        
        self.isDownloading = YES;
        [self updateNewsOrPubDownloadProgressInMainThread];
        [[SNSubDownloadManager sharedInstance] retryDownload:_sub];
    }
    //重试一个新闻频道下载
    else if ([downloadItem isKindOfClass:[NewsChannelItem class]]) {
        NewsChannelItem *_newChannelItem = (NewsChannelItem *)downloadItem;
        NSString *_channelName = _newChannelItem.channelName;
        if (!!_channelName && ![@"" isEqualToString:_channelName]) {
            self.currentDownloading = [NSString stringWithFormat:NSLocalizedString(@"sbm_downloading", nil), _channelName];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"retry_download_item", nil), _channelName] toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        else {
            self.currentDownloading = nil;
            [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"retry_download_channel", nil), _channelName] toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        
        self.isDownloading = YES;
        [self updateNewsOrPubDownloadProgressInMainThread];
        [[SNNewsDownloadManager sharedInstance] retryDownload:_newChannelItem];
    }
}

//已全部下载完成（无论其中是否有下载失败的）－没有正在下载和等待的项就说明所有待下载项都已尝试下载过，可能其中有下载失败的。
- (BOOL)isAllDownloadFinished {
    return [[SNSubDownloadManager sharedInstance] isAllDownloadFinished]
        && [[SNNewsDownloadManager sharedInstance] isAllDownloadFinished];
}

//已全部下载完成但其中有失败的
- (BOOL)isAllDownloadFinishedButAndSomeFail {
    return [[SNSubDownloadManager sharedInstance] isAllDownloadFinishedButAndSomeFail]
    || [[SNNewsDownloadManager sharedInstance] isAllDownloadFinishedButAndSomeFail];
}

//已全部下载完成但其中有取消的
- (BOOL)isAllDownloadFinishedButAndSomeCancel {
    return [[SNSubDownloadManager sharedInstance] isAllDownloadFinishedButAndSomeCancel]
    || [[SNNewsDownloadManager sharedInstance] isAllDownloadFinishedButAndSomeCancel];
}

//已全部下载完成且其中没有有失败的
- (BOOL)isAllDownloadFinishedAndNoFail {
    return [[SNSubDownloadManager sharedInstance] isAllDownloadFinishedAndNoFail]
    && [[SNNewsDownloadManager sharedInstance] isAllDownloadFinishedAndNoFail];
}

//当前是否处于离线管理界面
- (BOOL)isDownloaderVisible {
    UIViewController *_vc = [TTNavigator globalNavigator].visibleViewController;
    return [_vc isKindOfClass:[SNDownloadViewController class]];
}

//刊物或频道新闻是否正在下载
- (BOOL)isDownloadingItem:(id)item {
    if ([item isKindOfClass:[SCSubscribeObject class]]) {
        return [[SNSubDownloadManager sharedInstance] isSubDownloading:item];
    }
    else if ([item isKindOfClass:[NewsChannelItem class]]) {
        return [[SNNewsDownloadManager sharedInstance] isChannelDownloading:item];
    }
    else {
        return NO;
    }
}

//刊物或频道新闻是否为失败项
- (BOOL)isFailedItem:(id)item {
    if ([item isKindOfClass:[SCSubscribeObject class]]) {
        return [[SNSubDownloadManager sharedInstance] isSubFailed:item];
    }
    else if ([item isKindOfClass:[NewsChannelItem class]]) {
        return [[SNNewsDownloadManager sharedInstance] isChannelFailed:item];
    }
    else {
        return NO;
    }
}

//刊物或频道新闻是否不在下载队列中
- (BOOL)isDetachedItem:(id)item {
    if ([item isKindOfClass:[SCSubscribeObject class]]) {
        return [[SNSubDownloadManager sharedInstance] isSubDetached:item];
    }
    else if ([item isKindOfClass:[NewsChannelItem class]]) {
        return [[SNNewsDownloadManager sharedInstance] isChannelDetached:item];
    }
    else {
        return YES;
    }
}

//重置本地下载状态
- (void)resetCurrentToDownloadingStart
{
    self.failTime = 0;
    self.percent = 0.0f;
    self.isDownloading = YES;
    self.didUserCancelAllDownloads = NO;
}

- (void)resetCurrentToDownloadingend
{
    self.percent = 0.0f;
    self.isDownloading = NO;
    self.failTime = 0;
}

#pragma mark -
#pragma mark SNActionSheetDelegate

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kWWANNetworkReachAlertViewTag) {
        //如果用户点“继续下载”
        if (buttonIndex == 1) {
            [self startInWifi];
        }
    }

    else if(actionSheet.tag == kWWANetworkResumeAlertViewTag){
        if (buttonIndex == 1) {
            [[SNDownloadScheduler sharedInstance] doResumeIfNeeded];
        }
        else {
            [self cleanDownloadingListInMainThread];
            [[SNSubDownloadManager sharedInstance] resetSuspendState];
            [[SNNewsDownloadManager sharedInstance] resetSuspendState];
            self.isDownloading = NO;
        }
    }
    //网络变换通知
    else if(actionSheet.tag == kNetworkStatusChangedAlertViewTag){
        _alreadyPopAlert = NO;
        if (buttonIndex == 1) {
            [[SNDownloadScheduler sharedInstance] doResumeIfNeeded];
        }
        else {
            [[SNSubDownloadManager sharedInstance] resetSuspendState];
            [[SNNewsDownloadManager sharedInstance] resetSuspendState];
            [self cleanDownloadingListInMainThread];
            self.isDownloading = NO;
        }
    }
}

#pragma mark - UIAlerViewDelegate methods implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //非wifi网络提醒
    if (alertView.tag == kWWANNetworkReachAlertViewTag) {
        //如果用户点“继续下载”
        if (buttonIndex == 1) {
            [self startInWifi];
        }
    }
    //取消全部下载提醒
//    else if (alertView.tag == kCancelAllDownloadAlertViewTag) {
//        //如果用户点“是”
//        if (buttonIndex == 1) {
//            [self cleanDownloadingListInMainThread];
//        }
//    }
    //后台切前台
    else if(alertView.tag == kWWANetworkResumeAlertViewTag){
        if (buttonIndex == 1) {
            [[SNDownloadScheduler sharedInstance] doResumeIfNeeded];
        }
        else {
            [self cleanDownloadingListInMainThread];
            [[SNSubDownloadManager sharedInstance] resetSuspendState];
            [[SNNewsDownloadManager sharedInstance] resetSuspendState];
            self.isDownloading = NO;
        }
    }
    //网络变换通知
    else if(alertView.tag == kNetworkStatusChangedAlertViewTag){
        _alreadyPopAlert = NO;
        if (buttonIndex == 1) {
            [[SNDownloadScheduler sharedInstance] doResumeIfNeeded];
        }
        else {
            [[SNSubDownloadManager sharedInstance] resetSuspendState];
            [[SNNewsDownloadManager sharedInstance] resetSuspendState];
            [self cleanDownloadingListInMainThread];
            self.isDownloading = NO;
        }
    }
}

#pragma mark - Private methods

#pragma mark - 刊物和新闻下载入口

- (void)startInWifi {
    [self loadToBeDownloadedPubsAndNewsFromDBInThread];
}

#pragma mark -

- (void)loadToBeDownloadedPubsAndNewsFromDBInThread {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /*
        //是否设置了刊物或频道
        NSArray *_selectedMySubs = [[SNDBManager currentDataBase] getSubscribeCenterSelectedMySubList];
        NSArray *_realSelectedMySubs = [[SNDBManager currentDataBase] filterNewsSubscribeFromSubscribeArray:_selectedMySubs];
        NSArray *_toBeDownloadedNews = [[SNNewsDownloadManager sharedInstance] loadToBeDownloadedNewsInMainThread];
        
        if ((_realSelectedMySubs.count + _toBeDownloadedNews.count) <= 0) {
//            [self notifyDelegatesWithSelector:@selector(plsSetDownloadItems) withObject:nil needResetDelegates:YES];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                TTURLAction *_urlAction = [[TTURLAction actionWithURLPath:@"tt://downloadSettingViewController"] applyAnimated:YES];
//                [[TTNavigator navigator] openURLAction:_urlAction];
//            });
//            return;
            return;
        }*/
        
        NSArray *_toBeDownloadedSubs = [[SNDBManager currentDataBase] getSubscribeCenterSelectedMySubList];
        NSArray *_realSelectedMySubs = [[SNSubDownloadManager sharedInstance] loadToBeDownloadedMySubsInMainThread];
        NSArray *_toBeDownloadedNews = [[SNNewsDownloadManager sharedInstance] loadToBeDownloadedNewsInMainThread];
        
        //没数据可下载
        //3.4版本频道也算作订阅，因此订阅里包含频道的信息
        if (_toBeDownloadedSubs.count<= 0 && _realSelectedMySubs.count<=0 &&_toBeDownloadedNews.count<=0) {
            [self notifyDelegatesWithSelector:@selector(thereIsNoTasksToDownloadInMainThread) withObject:nil needResetDelegates:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self resetCurrentToDownloadingend];
            });
        }
        //刷新显示下载列表项
        else {
            //开始下载不让自动待机
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            });
            
            [SNDownloadUtility markBgTaskAsBegin];
            
            //更新状态
            [self resetCurrentToDownloadingStart];
            [self resetSubDownloadingProgressBarInMainThread];
            
            //有数据可下载
            [self notifyDelegatesWithSelector:@selector(thereAreTasksToDownloadInMainThread) withObject:nil needResetDelegates:NO];
            
            [self refreshDownloadingListInMainThread];
            
            //开始下载刊物
            if (_realSelectedMySubs.count > 0) {
                /**
                 * 由于refreshDownloadingListInMainThread会刷新显示可下载的刊物和新闻列表，能单个取消刊物和新闻，
                 * 所以SNNewsDownloadManager和SNSubDownloadManager的delegate都要设上，不然单个取消下载时不能刷新UI；
                 */
                if ([SNNewsDownloadManager sharedInstance].toBeDownloadedItems.count > 0) {
                    [[SNNewsDownloadManager sharedInstance] setDelegate:self];
                }
                
                [[SNSubDownloadManager sharedInstance] setDelegate:self];
                [[SNSubDownloadManager sharedInstance] start];
            }
            //如果没有可下载的刊物则开始下载新闻
            else if (_toBeDownloadedNews.count > 0) {
                [[SNNewsDownloadManager sharedInstance] setDelegate:self];
                [[SNNewsDownloadManager sharedInstance] start];
            }
            //没有可下载的刊物和新闻
            else {
                [self didFinishedDownloadAllInMainThread];
            }
        }
    });
}

- (void)loadToBeDownloadedPubsAndNewsFromMemInThread {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *_toBeDownloadedSubs = [[SNSubDownloadManager sharedInstance] toBeDownloadedItems];
        NSArray *_toBeDownloadedNews = [[SNNewsDownloadManager sharedInstance] toBeDownloadedItems];
        if ((_toBeDownloadedSubs.count+_toBeDownloadedNews.count) > 0) {
            [self refreshDownloadingListInMainThread];
            //[self updateSubDownloadProgressInMainThread];
            //[self updateNewsDownloadProgressInMainThread];
            [self updateNewsOrPubDownloadProgressInMainThread];
        }
    });
}

- (void)refreshDownloadingListInMainThread {
    [self reloadDownloadingListInMainThreadAndIfNeedResetDelegate:NO];
}

- (void)cleanDownloadingListInMainThread {
    _didUserCancelAllDownloads = YES;
    
    //在delegate重置之前，更新进度条
    [self resetSubDownloadingProgressBarInMainThread];
    
    [[SNSubDownloadManager sharedInstance] setDelegate:self];
    [[SNSubDownloadManager sharedInstance] cancelAll];
    
    /**
     * 设置NewsDownloadManager delegate的原因：
     * 为了通过NewsDownloadManager的cancelAll方法回调到DownloadScheduler的didFinishDownloadAll从而更新UI并重置Scheduler的delegate，
     * 但有可能没有频道可以下载，这时NewsDownloadManager的delegate是空，这样通过NewsDownloadManager的cancelAll就回调不到Scheduler的didFinishDownloadAll，
     * 所以要在这里无论如何都要设置SNNewsDownloadManager的delegate，有则覆盖(完全可以覆盖，因类Scheduler是单例)，无则设上。
     */
    [[SNNewsDownloadManager sharedInstance] setDelegate:self];
    [[SNNewsDownloadManager sharedInstance] cancelAll];
}

- (void)reloadDownloadingListInMainThreadAndIfNeedResetDelegate:(BOOL)needResetDelegate {
    
    NSMutableArray *_tempToBeDownloadedItems = [NSMutableArray array];
    
    //------------------------------------------------
    //Load to be downloaded subs;
    SNDownloadingSectionData *_oneSectionData = [[SNDownloadingSectionData alloc] init];
    NSArray *_selectedMySubs = [[[SNSubDownloadManager sharedInstance] toBeDownloadedItems] copy];
    //下载成功和取消的项不显示
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus!=3 and downloadStatus!=4"];//SNDownloadSuccess/SNDownloadCancel
    NSArray *_selectedMySubsExceptSucceedAndCanceledItems = [_selectedMySubs filteredArrayUsingPredicate:_predicate];
    if (!!_selectedMySubsExceptSucceedAndCanceledItems && (_selectedMySubsExceptSucceedAndCanceledItems.count > 0)) {
        _oneSectionData.tag = kDownloadingSubSectionDataTag;
        [_oneSectionData.arrayData addObjectsFromArray:_selectedMySubsExceptSucceedAndCanceledItems];
        [_tempToBeDownloadedItems addObject:_oneSectionData];
    }
     //(_oneSectionData);
     //(_selectedMySubs);
    //------------------------------------------------
    
    //------------------------------------------------
    //Load to be downloaded news from local;
    _oneSectionData = [[SNDownloadingSectionData alloc] init];
    SNNewsDownloadManager *_newsDownloadManager = [SNNewsDownloadManager sharedInstance];
    NSArray *_selectedSubedChannels = [[_newsDownloadManager toBeDownloadedItems] copy];
    //下载成功和取消的项不显示
    _predicate = [NSPredicate predicateWithFormat:@"downloadStatus!=3 and downloadStatus!=4"];//SNDownloadSuccess/SNDownloadCancel
    NSArray *_selectedSubedNewsExceptSucceedAndCanceledItems = [_selectedSubedChannels filteredArrayUsingPredicate:_predicate];
    if (!!_selectedSubedNewsExceptSucceedAndCanceledItems && (_selectedSubedNewsExceptSucceedAndCanceledItems.count > 0)) {
        _oneSectionData.tag = kDownloadingNewsSectionDataTag;
        [_oneSectionData.arrayData addObjectsFromArray:_selectedSubedNewsExceptSucceedAndCanceledItems];
        [_tempToBeDownloadedItems addObject:_oneSectionData];
    }
     //(_oneSectionData);
     //(_selectedSubedChannels);

    //------------------------------------------------
    [self notifyDelegatesWithSelector:@selector(refreshDownloadingListInMainThread:) withObject:_tempToBeDownloadedItems needResetDelegates:needResetDelegate];
    
     //(_tempToBeDownloadedItems);
}

/*
- (void)updateSubDownloadProgressInMainThread {
    NSArray *_toBeDownloadedAllSubs = [[SNSubDownloadManager sharedInstance].toBeDownloadedItems retain];
    
    //下载失败和取消下载的项不计入百分比分母
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus!=2 and downloadStatus!=4"];//SNDownloadFail/SNDownloadCancel
    NSArray *_toBeDownloadedSubs = [_toBeDownloadedAllSubs filteredArrayUsingPredicate:_predicate];
    
    _predicate = [NSPredicate predicateWithFormat:@"downloadStatus==3"];//SNDownloadSuccess
    NSArray *_finishedSubs = [_toBeDownloadedAllSubs filteredArrayUsingPredicate:_predicate];

    if (!!_toBeDownloadedSubs && _toBeDownloadedSubs.count > 0) {
        //在主线程中更新UI
        CGFloat _progress = _finishedSubs.count*1.0/_toBeDownloadedSubs.count;
        SNDebugLog(@"===INFO: Updating progress %f #######################################", _progress);
        [self notifyDelegatesWithSelector:@selector(updateSubDownloadProgressNumber:) withObject:[NSNumber numberWithFloat:_progress] needResetDelegates:NO];
    }
     //(_toBeDownloadedAllSubs);
}*/

- (void)updateNewsDownloadProgressInOneInMainThread:(NSNumber*)aNumber {
    /*
    NSArray *_toBeDownloadedAllSubs = [[SNSubDownloadManager sharedInstance].toBeDownloadedItems retain];
    
    //下载失败和取消下载的项不计入百分比分母
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus!=2 and downloadStatus!=4"];//SNDownloadFail/SNDownloadCancel
    NSArray *_toBeDownloadedSubs = [_toBeDownloadedAllSubs filteredArrayUsingPredicate:_predicate];
    
    _predicate = [NSPredicate predicateWithFormat:@"downloadStatus==3"];//SNDownloadSuccess
    NSArray *_finishedSubs = [_toBeDownloadedAllSubs filteredArrayUsingPredicate:_predicate];
    
    if (!!_toBeDownloadedSubs && _toBeDownloadedSubs.count > 0) {
        //在主线程中更新UI
        CGFloat _progress = _finishedSubs.count*1.0/_toBeDownloadedSubs.count;
        //本次下载所占比例
        CGFloat _currentPercent = [aNumber floatValue];
        _currentPercent = (_currentPercent>=0&&_currentPercent<=1 ? _currentPercent*(1.0/_toBeDownloadedSubs.count) : 0);
        _progress += _currentPercent;
        SNDebugLog(@"===INFO: Updating progress %f #######################################", _progress);
        [self notifyDelegatesWithSelector:@selector(updateSubDownloadProgressNumber:) withObject:[NSNumber numberWithFloat:_progress] needResetDelegates:NO];
    }
     //(_toBeDownloadedAllSubs);*/
}

- (void)updateNewsOrPubDownloadProgressInMainThread
{
    [self updateNewsOrPubDownloadProgressInMainThread:[NSNumber numberWithFloat:0]];
}

- (void)updateNewsOrPubDownloadProgressInMainThread:(NSNumber*)aCurrentPercent
{
    NSArray *_toBeDownloadedAllNews = [SNNewsDownloadManager sharedInstance].toBeDownloadedItems;
    //下载失败和取消下载的项不计入百分比分母
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus!=2 and downloadStatus!=4"];//SNDownloadFail/SNDownloadCancel
    NSArray *_toBeDownloadedNews = [_toBeDownloadedAllNews filteredArrayUsingPredicate:_predicate];
    //过滤下载完成的
    _predicate = [NSPredicate predicateWithFormat:@"downloadStatus==3"];//SNDownloadSuccess
    NSArray *_finishedNews = [_toBeDownloadedAllNews filteredArrayUsingPredicate:_predicate];
    
    NSArray *_toBeDownloadedAllSubs = [SNSubDownloadManager sharedInstance].toBeDownloadedItems;
    //下载失败和取消下载的项不计入百分比分母
    _predicate = [NSPredicate predicateWithFormat:@"downloadStatus!=2 and downloadStatus!=4"];//SNDownloadFail/SNDownloadCancel
    NSArray *_toBeDownloadedSubs = [_toBeDownloadedAllSubs filteredArrayUsingPredicate:_predicate];
    //过滤下载完成的
    _predicate = [NSPredicate predicateWithFormat:@"downloadStatus==3"];//SNDownloadSuccess
    NSArray *_finishedSubs = [_toBeDownloadedAllSubs filteredArrayUsingPredicate:_predicate];
    
    //SNDebugLog(@"===INFO: *******************_toBeDownloadedNews+Sub count is %d", _toBeDownloadedNews.count+_toBeDownloadedSubs.count);
    
    if(!!_toBeDownloadedNews &&!!_toBeDownloadedSubs && _toBeDownloadedNews.count+_toBeDownloadedSubs.count>0)
    {
        //在主线程中更新UI
        CGFloat _progress = (_finishedNews.count+_finishedSubs.count)*1.0/(_toBeDownloadedNews.count+_toBeDownloadedSubs.count);
        //本次下载所占比例
        if(aCurrentPercent!=nil)
        {
            CGFloat _currentPercent = [aCurrentPercent floatValue];
            _currentPercent = (_currentPercent>=0&&_currentPercent<=1 ? _currentPercent*(1.0/(_toBeDownloadedNews.count+_toBeDownloadedSubs.count)) : 0);
            _progress += _currentPercent;
        }
        //SNDebugLog(@"===INFO: Updating progress %f #######################################", _progress);
        self.percent = _progress;
        [self notifyDelegatesWithSelector:@selector(updateSubDownloadProgressNumber:) withObject:[NSNumber numberWithFloat:_progress] needResetDelegates:NO];
    }
    //刊物下完了，频道下载中
    /*else if(!!_toBeDownloadedNews && _toBeDownloadedNews.count>0)
    {
        //在主线程中更新UI
        CGFloat _progress = _finishedNews.count*1.0/_toBeDownloadedNews.count;
        SNDebugLog(@"===INFO: Updating progress %f #######################################", _progress);
        [self notifyDelegatesWithSelector:@selector(updateSubDownloadProgressNumber:) withObject:[NSNumber numberWithFloat:_progress] needResetDelegates:NO];
    }*/
     //(_toBeDownloadedAllNews);
     //(_toBeDownloadedAllSubs);
}

/*
- (void)updateNewsDownloadProgressInMainThread {
    NSArray *_toBeDownloadedAllNews = [[SNNewsDownloadManager sharedInstance].toBeDownloadedItems retain];
    
    //下载失败和取消下载的项不计入百分比分母
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus!=2 and downloadStatus!=4"];//SNDownloadFail/SNDownloadCancel
    NSArray *_toBeDownloadedNews = [_toBeDownloadedAllNews filteredArrayUsingPredicate:_predicate];
    
    _predicate = [NSPredicate predicateWithFormat:@"downloadStatus==3"];//SNDownloadSuccess
    NSArray *_finishedNews = [_toBeDownloadedAllNews filteredArrayUsingPredicate:_predicate];
    
    SNDebugLog(@"===INFO: *******************_toBeDownloadedNews count is %d", _toBeDownloadedNews.count);
    
    if (!!_toBeDownloadedNews && _toBeDownloadedNews.count > 0) {
        //在主线程中更新UI
        CGFloat _progress = _finishedNews.count*1.0/_toBeDownloadedNews.count;
        SNDebugLog(@"===INFO: Updating progress %f #######################################", _progress);
        [self notifyDelegatesWithSelector:@selector(updateNewsDownloadProgressNumber:) withObject:[NSNumber numberWithFloat:_progress] needResetDelegates:NO];
    }
     //(_toBeDownloadedAllNews);
}*/

#pragma mark - SNSubDownloadManagerDelegate

/**
 * 在点“一键下载”后，开始获取刊物最新一期termID之前SNSubDownloadManager回调此方法；
 * 为了在UI上显示一些状态信息
 */
- (void)didPrepareDownloadAllSubInMainThreadWithMsg:(BOOL)showMsg {
    if (showMsg) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"sbm_addsub_to_download", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
    }
}

/**
 * 批量获取刊物的最新一期id失败时，SNSubDownloadManager回调此方法。
 * 从而尝试下载新闻或完成全部下载。
 */
- (void)didFailedToDownloadAllSubInMainThread {
    self.currentDownloading = nil;
    
    //下载新闻
    if ([SNNewsDownloadManager sharedInstance].toBeDownloadedItems.count > 0) {
        [[SNNewsDownloadManager sharedInstance] setDelegate:self];
        [[SNNewsDownloadManager sharedInstance] start];
    }
    //由于没有新闻可下载，结束全部下载
    else {
        [self didFinishedDownloadAllInMainThread];
    }
}

/**
 * 成功批量获取最新刊物的数据，从而刷新刊物显示的名称为期刊名。
 * 数据状态已在SNSubDownloadManager中修改，所以刷新时直接取这些数据进行刷新即可。
 */
- (void)didGetNewTermOfToBeDownloadedSubsInMainThread {
    [self refreshDownloadingListInMainThread];
}

/**
 * 完成全部刊物的下载，从而可以刷新“正在离线”列表以及着手下载新闻或结束全部下载。
 */
- (void)didFinishedDownloadAllSubInMainThread {
    self.currentDownloading = nil;
    
    [self refreshDownloadingListInMainThread];
    
    //下载新闻
    if ([SNNewsDownloadManager sharedInstance].toBeDownloadedItems.count > 0) {
        [[SNNewsDownloadManager sharedInstance] setDelegate:self];
        [[SNNewsDownloadManager sharedInstance] start];
    }
    //由于没有新闻可下载，结束全部下载
    else {
        [self didFinishedDownloadAllInMainThread];
    }
}

//重置Sub section header的progress bar为0
- (void)resetSubDownloadingProgressBarInMainThread {
    [self notifyDelegatesWithSelector:@selector(updateSubDownloadProgressNumber:) withObject:[NSNumber numberWithFloat:0] needResetDelegates:NO];
}

//添加单个下载后刷新UI
- (void)readyToDownloadASubInMainThread:(SCSubscribeObject *)sub {
    [self refreshDownloadingListInMainThread];
    //[self updateSubDownloadProgressInMainThread];
    [self updateNewsOrPubDownloadProgressInMainThread];
}

#pragma mark - SNNewsDownloadManagerDelegate

- (void)didFinishedDownloadAllNewsInMainThread {
    self.currentDownloading = nil;
    //这种情况只可能出现在刊物和新闻区段中都在下载失败的项，用户先重试几个新闻频道再重试几个刊物，当新闻下载完后应该继续下载刊物；
    if ([[SNSubDownloadManager sharedInstance] waitingDownloadItems].count > 0 && self.failTime++<DOWNLOAD_FAILTIME_MAX) {
        [[SNSubDownloadManager sharedInstance] setDelegate:self];
        [[SNSubDownloadManager sharedInstance] startWithoutPreparingMsg];
    }
    else {
        [self didFinishedDownloadAllInMainThread];
    }
}

//重置News section header的progress bar为0
- (void)resetNewsDownloadingProgressBarInMainThread {
    [self notifyDelegatesWithSelector:@selector(updateNewsDownloadProgressNumber:) withObject:[NSNumber numberWithFloat:0] needResetDelegates:NO];
}

#pragma mark - For both SNSubDownloadManager and SNNewsDownloadManager

//开始下载一个刊物或新闻
- (void)didStartDownloadAItemInMainThread:(id)toBeDownloadedItem {
    [self refreshDownloadingListInMainThread];
    
    //刊物
    if ([toBeDownloadedItem isKindOfClass:[SCSubscribeObject class]]) {
        SCSubscribeObject *_tmpDownloadingItem = (SCSubscribeObject *)toBeDownloadedItem;

        NSString *_nameStuff = (!!(_tmpDownloadingItem.termName) && ![@"" isEqualToString:_tmpDownloadingItem.termName]) ?
        _tmpDownloadingItem.termName : _tmpDownloadingItem.subName;
        
         self.currentDownloading = [NSString stringWithFormat:NSLocalizedString(@"sbm_downloading", nil), _nameStuff];
//        [[SNStatusBarMessageCenter sharedInstance] postNormalMessage:[NSString stringWithFormat:NSLocalizedString(@"sbm_downloading", nil), _nameStuff]];
//        [[SNToast shareInstance] showToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"sbm_downloading", nil), _nameStuff]
//                                              toUrl:nil
//                                               mode:SNToastUIModeFeedBackCommon];
        
        if (!_nameStuff || [@"" isEqualToString:_nameStuff]) {
            self.currentDownloading = nil;
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"sbm_downloading_unknown_publication", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    }
    //新闻
    else if ([toBeDownloadedItem isKindOfClass:[NewsChannelItem class]]) {
        NewsChannelItem *_newsChannelItem = (NewsChannelItem *)toBeDownloadedItem;        
        if (_newsChannelItem.channelName && ![@"" isEqualToString:_newsChannelItem.channelName]) {
            self.currentDownloading = [NSString stringWithFormat:NSLocalizedString(@"sbm_downloading_newschannel", nil), _newsChannelItem.channelName];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"sbm_downloading_newschannel", nil), _newsChannelItem.channelName] toUrl:nil mode:SNCenterToastModeOnlyText];
        } else {
            self.currentDownloading = nil;
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"sbm_downloading_unknown_news", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
        }
    }
}

//取消了一个下载
- (void)didCancelDownloadItemInMainThread:(id)canceledDownloadItem {
    [self refreshDownloadingListInMainThread];
    
    //刊物
    if ([canceledDownloadItem isKindOfClass:[SCSubscribeObject class]]) {
        //[self updateSubDownloadProgressInMainThread];
        [self updateNewsOrPubDownloadProgressInMainThread];
    }
    //新闻
    else if ([canceledDownloadItem isKindOfClass:[NewsChannelItem class]]) {
        //[self updateNewsDownloadProgressInMainThread];
        [self updateNewsOrPubDownloadProgressInMainThread];
    }
}

//下载一个刊物或新闻频道失败
- (void)didFailedToDownloadAItemInMainThread:(id)toBeDownloadedItem {
    self.currentDownloading = nil;
    [self refreshDownloadingListInMainThread];
    
    //刊物
    if ([toBeDownloadedItem isKindOfClass:[SCSubscribeObject class]]) {
        SCSubscribeObject *_tmpDownloadingItem = (SCSubscribeObject *)toBeDownloadedItem;
        
        NSString *_nameStuff = (!!(_tmpDownloadingItem.termName) && ![@"" isEqualToString:_tmpDownloadingItem.termName]) ?
        _tmpDownloadingItem.termName : _tmpDownloadingItem.subName;
        [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"sbm_fail_a_download", nil), _nameStuff] toUrl:nil mode:SNCenterToastModeOnlyText];
        [NSString stringWithFormat:NSLocalizedString(@"sbm_fail_a_download", nil), _nameStuff];
        
        SNDebugLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!INFO: Failed to download sub《%@》, subID:%@", _nameStuff, _tmpDownloadingItem.subId);
        
        if (!_nameStuff || [@"" isEqualToString:_nameStuff]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"failed_to_download_a_unknown_sub", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
            SNDebugLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!INFO: Failed to download a sub, subID:%@", _tmpDownloadingItem.subId);
        }
        
        //[self updateSubDownloadProgressInMainThread];
        [self updateNewsOrPubDownloadProgressInMainThread];
        
        //如果SNNewsPaperWebController可见则告知它下载失败，从而enble下载按钮
        [self notifyDelegatesWithSelector:@selector(didFailedDownloadSub:) withObject:_tmpDownloadingItem needResetDelegates:NO];
    }
    //新闻
    else if ([toBeDownloadedItem isKindOfClass:[NewsChannelItem class]]) {
        NewsChannelItem *_newsChannelItem = (NewsChannelItem *)toBeDownloadedItem;
        
        if (_newsChannelItem.channelName && ![@"" isEqualToString:_newsChannelItem.channelName]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"sbm_fail_a_download", nil),
                                                                     _newsChannelItem.channelName] toUrl:nil mode:SNCenterToastModeOnlyText];
            SNDebugLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!INFO: Failed to download channel《%@》, channelID:%@。",
                       _newsChannelItem.channelName, _newsChannelItem.channelId);
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"failed_to_download_a_unknown_channel", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
            SNDebugLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!INFO: Failed to download a channel, channelID: %@.", _newsChannelItem.channelId);
        }
        
        //[self updateNewsDownloadProgressInMainThread];
        [self updateNewsOrPubDownloadProgressInMainThread];
    }
}

//成功下载一个刊物或新闻频道
- (void)didFinishedDownloadAItemInMainThread:(id)toBeDownloadedItem{    
    //这个动画需要先调，因为refreshDownloadingListInMainThread这行会触发数据刷新，导致要做动画的cell数据被干掉!通过data索引到的数据被改变，看起来一塌糊涂
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if(toBeDownloadedItem!=nil)
        [self notifyDelegatesWithSelector:@selector(doSuckNow:) withObject:toBeDownloadedItem needResetDelegates:NO];
#pragma clang diagnostic pop
    
    self.currentDownloading = nil;
    [self refreshDownloadingListInMainThread];
    
    if ([toBeDownloadedItem isKindOfClass:[SCSubscribeObject class]]) {
        SCSubscribeObject *_tmpDownloadingItem = (SCSubscribeObject *)toBeDownloadedItem;
        
        NSString *_nameStuff = (!!(_tmpDownloadingItem.termName) && ![@"" isEqualToString:_tmpDownloadingItem.termName]) ?
        _tmpDownloadingItem.termName : _tmpDownloadingItem.subName;
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"sbm_finish_a_download", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
        if (!_nameStuff || [@"" isEqualToString:_nameStuff]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"sbm_finish_a_download_unknown_sub", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        sleep(2);
        
        //[self updateSubDownloadProgressInMainThread];
        [self updateNewsOrPubDownloadProgressInMainThread];
        
        [self notifyDelegatesWithSelector:@selector(refreshDownloadedListInMainThread) withObject:nil needResetDelegates:NO];

        //如果SNNewsPaperWebController可见则在SNNewsPaperWebController里判断打开的刊物是否是正在下载的刊物，从而disable下载按钮
        [self notifyDelegatesWithSelector:@selector(didFinishedDownloadSub:) withObject:_tmpDownloadingItem needResetDelegates:NO];
    }
    //新闻
    else if ([toBeDownloadedItem isKindOfClass:[NewsChannelItem class]]) {
        NewsChannelItem *_newsChannelItem = (NewsChannelItem *)toBeDownloadedItem;
        
        if (_newsChannelItem.channelName && ![@"" isEqualToString:_newsChannelItem.channelName]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"sbm_finish_a_download", nil), _newsChannelItem.channelName] toUrl:nil mode:SNCenterToastModeOnlyText];
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:NSLocalizedString(@"sbm_finish_a_download_unknown_channel", nil), _newsChannelItem.channelName] toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        sleep(2);
        
        //[self updateNewsDownloadProgressInMainThread];
        [self updateNewsOrPubDownloadProgressInMainThread];
    }
}

- (void)readyToRetryInMainThread:(id)retryDownloadItem {
    [self refreshDownloadingListInMainThread];
    
    //刊物
    if ([retryDownloadItem isKindOfClass:[SCSubscribeObject class]]) {
        //[self updateSubDownloadProgressInMainThread];
        [self updateNewsOrPubDownloadProgressInMainThread];
    }
    //新闻
    else if ([retryDownloadItem isKindOfClass:[NewsChannelItem class]]) {
        //[self updateNewsDownloadProgressInMainThread];
        [self updateNewsOrPubDownloadProgressInMainThread];
    }
}

#pragma mark - 刊物和新闻下载出口

//完成所有刊物和频道的下载
- (void)didFinishedDownloadAllInMainThread {
    self.currentDownloading = nil;
    [self notifyDelegatesWithSelector:@selector(didFinishedDownloadAllInMainThread) withObject:nil needResetDelegates:NO];
    
    //主动刷新一下数据
    //fix 如果网络异常导致全部失败，用户点击某一个下载成功；之后系统认为是1/1 进度条蹦到100%的问题
    NSArray* subArray = [SNSubDownloadManager sharedInstance].toBeDownloadedItems;
    //更换一下过滤规则，只有fail的被留在列表里，而不是非成功的都进列表
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus==2"];//SNDownloadFail
    NSArray * subArrayEx = [subArray filteredArrayUsingPredicate:_predicate];
    if([subArrayEx count]!=[subArray count])
        [SNSubDownloadManager sharedInstance].toBeDownloadedItems = [NSMutableArray arrayWithArray:subArrayEx];
    
    subArray = [SNNewsDownloadManager sharedInstance].toBeDownloadedItems;
    subArrayEx = [subArray filteredArrayUsingPredicate:_predicate];
    if([subArrayEx count]!=[subArray count])
        [SNNewsDownloadManager sharedInstance].toBeDownloadedItems = [NSMutableArray arrayWithArray:subArrayEx];
    
    /**
     * 刷新下载列表UI：
     * 如果下载列表中有失败项（无论刊物还是新闻），不能重置Scheduler的delegate，因为如果重置了，用户再cancelAll时由于scheduler的delegate为空，则无法刷新下载列表UI；
     */
    if ([self isAllDownloadFinishedButAndSomeFail]) {
        [self refreshDownloadingListInMainThread];
    }
    else {
        [self reloadDownloadingListInMainThreadAndIfNeedResetDelegate:YES];
    }
    
    //无论是正在载时还是下载完成有失败项时取消全部下载，都提示：“离线下载已全部取消√”
    if (_didUserCancelAllDownloads) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"sbm_finish_cancel_all_downloads", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    else {
        //走到这个地方八成意味着offline.go挂了，失败了三回
        if(self.failTime>DOWNLOAD_FAILTIME_MAX)
        {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"sbm_finish_all_downloads_fail", nil) toUrl:nil mode:SNCenterToastModeOnlyText];
        }
        //下载完成但有失败项，则提示：“离线下载完毕，但部分下载失败√”
        else if ([self isAllDownloadFinishedButAndSomeFail]) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_finish_all_downloads_with_fails"), @"") toUrl:nil mode:SNCenterToastModeWarning];
        }
        //下载完成但有取消项，则提示：“离线下载完毕，但部分下载取消√”
//        else if ([self isAllDownloadFinishedButAndSomeCancel]) {
//            [[SNStatusBarMessageCenter sharedInstance] postNormalMessage:NSLocalizedString(@"sbm_finish_all_downloads_but_somecanceled", nil)];
//            [[SNStatusBarMessageCenter sharedInstance] hideMessageDalay:2];
//        }
        //全部下载成功，则提示：“离线下载完毕，可进入离线内容查看√”
        else {
//            [[SNToast shareInstance] showToastWithTitle:NSLocalizedString(@"sbm_finish_all_downloads_ok", nil)
//                                                  toUrl:nil
//                                                   mode:SNToastUIModeSuccess];
        }
    }
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [SNDownloadUtility updateMySubsAndChannelsFromServer];
//    });
    
    [SNDownloadUtility markBgTaskAsFinished];
    
    //重置自己的下载状态
    [self resetCurrentToDownloadingend];
    
}

-(void)resume
{
    _netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (_netStatus == ReachableViaWWAN ||
        _netStatus == ReachableVia2G   ||
        _netStatus == ReachableVia3G   ||
        _netStatus == ReachableVia4G) {
        NSArray* newsArray = [SNNewsDownloadManager sharedInstance].toBeDownloadedItems;
        NSArray* subArray = [SNSubDownloadManager sharedInstance].toBeDownloadedItems;
        if ((newsArray.count>0 || subArray.count>0) && [self isSuspending]) {
            
            SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"waste_data_bandwidth", @"") cancelButtonTitle:NSLocalizedString(@"2g3g_downloadvideo_actionsheet_option_cancel", @"") otherButtonTitle:NSLocalizedString(@"2g3g_downloadvideo_actionsheet_option_continue", @"")];
            [alertView show];
            [alertView actionWithBlocksCancelButtonHandler:^{
                _alreadyPopAlert = NO;
                [[SNSubDownloadManager sharedInstance] resetSuspendState];
                [[SNNewsDownloadManager sharedInstance] resetSuspendState];
                [self cleanDownloadingListInMainThread];
                self.isDownloading = NO;
            } otherButtonHandler:^{
                _alreadyPopAlert = NO;
                [[SNDownloadScheduler sharedInstance] doResumeIfNeeded];

            }];
            
            return;
        }
    }
    
    [self doResumeIfNeeded];
}


-(void)reachabilityChanged:(NSNotification* )note
{
    if (!self.isDownloading) {
        return;
    }
    
    NSArray* subArray = [SNSubDownloadManager sharedInstance].toBeDownloadedItems;
    NSArray* newsArray = [SNNewsDownloadManager sharedInstance].toBeDownloadedItems;
    if((subArray.count>0 || newsArray.count>0))
    {
        Reachability* curReach = [note object];
        if ([curReach isKindOfClass:[Reachability class]])
        {
            NetworkStatus status = [curReach currentReachabilityStatus];
            if(_netStatus==ReachableViaWiFi && (status == ReachableViaWWAN ||
                                                status == ReachableVia2G  ||
                                                status == ReachableVia3G  ||
                                                status == ReachableVia4G))
            {
                if(_alreadyPopAlert)
                    return;
                else
                    _alreadyPopAlert = YES;
                
                [[SNDownloadScheduler sharedInstance] doSuspendIfNeeded];
                
                SNNewAlertView *alertView = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"waste_data_bandwidth", @"") cancelButtonTitle:NSLocalizedString(@"2g3g_downloadvideo_actionsheet_option_cancel", @"") otherButtonTitle:NSLocalizedString(@"2g3g_downloadvideo_actionsheet_option_continue", @"")];
                [alertView show];
                [alertView actionWithBlocksCancelButtonHandler:^{
                    _alreadyPopAlert = NO;
                    [[SNSubDownloadManager sharedInstance] resetSuspendState];
                    [[SNNewsDownloadManager sharedInstance] resetSuspendState];
                    [self cleanDownloadingListInMainThread];
                    self.isDownloading = NO;
                } otherButtonHandler:^{
                    _alreadyPopAlert = NO;
                    [[SNDownloadScheduler sharedInstance] doResumeIfNeeded];
                    
                }];

            }
        }
    }
}
@end
