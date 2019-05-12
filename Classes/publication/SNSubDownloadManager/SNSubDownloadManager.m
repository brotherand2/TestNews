//
//  SNPubDownloadManager.m
//
//  Created by handy wang on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNSubDownloadManager.h"
#import "SNDownloaderAlert.h"
#import "SNDownloadUtil.h"
#import "SNDBManager.h"
#import "SNStatusBarMessageCenter.h"
#import "SNDownloadViewController.h"
#import "SNNewsPaperWebController.h"
#import "SNPaperItem.h"
#import "SNDownloadUtility.h"
#import "SNDatabase_SubscribeCenter.h"
#import "SNNewsDownloadManager.h"

#define kDownloadingItem                                        (@"kDownloadingItem")

#define ksub                                                    (@"sub")
#define ksubId                                                  (@"subId")
#define kpaper                                                  (@"paper")
#define ktermId                                                 (@"termId")
#define kpubId                                                  (@"pubId")
#define ktermName                                               (@"termName")
#define ktopNews                                                (@"topNews")
#define ktermTime                                               (@"termTime")
#define ktermLink                                               (@"termLink")
#define ktermZip                                                (@"termZip")
#define kpublishTime                                            (@"publishTime")


#define kWWANNetworkReachAlertViewTag                           (1)
#define kCancelAllDownloadAlertViewTag                          (2)

#define kTmpDownloadingItem                                     (@"kTmpDownloadingItem")
#define kDownloadingRequest                                     (@"kDownloadingRequest")

@interface SNSubDownloadManager() {
    BOOL _isSuspending;
    SNDownloaderRequest *_downloadingRequest;
}

-(void)cancelSubObjectFromDownloadClickArray:(SCSubscribeObject*)aSubObject;
-(void)cancelAllSubObjectFromDownloadClickArray;
-(void)getZipUrlFromOfflineIfNeeded:(SCSubscribeObject*)aSubObject;
@end


@implementation SNSubDownloadManager

@synthesize delegate = _delegate;
@synthesize toBeDownloadedItems = _toBeDownloadedItems;
@synthesize toBeDownloadedItemsFromDownloadClick = _toBeDownloadedItemsFromDownloadClick;

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

+ (SNSubDownloadManager *)sharedInstance {
    static SNSubDownloadManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNSubDownloadManager alloc] init];
    });
    return _sharedInstance;
}

+(NSString*)channelFromProtocol:(NSString*)aProtocol type:(SNNewsChannelType*)aType
{
    if(aProtocol!=nil && [aProtocol length]>0)
    {
        //newsChannel://
        if((NSNotFound !=[aProtocol rangeOfString:kProtocolNewsChannel options:NSCaseInsensitiveSearch].location))
        {
            NSMutableDictionary* dictionary = [SNUtility parseProtocolUrl:aProtocol schema:kProtocolNewsChannel];
            if(dictionary!=nil && [dictionary objectForKey:kChannelId]!=nil)
            {
                if(aType!=nil) *aType = NewsChannelTypeNews;
                return [dictionary objectForKey:kChannelId];
            }
        }
        //weiboChannel://
        if((NSNotFound !=[aProtocol rangeOfString:kProtocolWeiboChannel options:NSCaseInsensitiveSearch].location))
        {
            NSMutableDictionary* dictionary = [SNUtility parseProtocolUrl:aProtocol schema:kProtocolWeiboChannel];
            if(dictionary!=nil && [dictionary objectForKey:kChannelId]!=nil)
            {
                if(aType!=nil) *aType = NewsChannelTypeWeiboHot;
                return [dictionary objectForKey:kChannelId];
            }
        }
    }
    
    //Default
    return nil;
}

+(NewsChannelItem*)newsItemFromSubItem:(SCSubscribeObject*)aSubItem
{
    if(aSubItem!=nil && aSubItem.link!=nil)
    {
        SNNewsChannelType type = NewsChannelTypeNewsUnknown;
        NSString* channelId = [SNSubDownloadManager channelFromProtocol:aSubItem.link type:&type];
        if(channelId!=nil)
        {
            NewsChannelItem* item = [[NewsChannelItem alloc] init];
            item.channelName = aSubItem.subName;
            item.channelId = channelId;
            item.channelType = [NSString stringWithFormat:@"%d", type];
            item.subId = aSubItem.subId;
            return item;
        }
    }
    
    //no match News Channel Item
    return nil;
}

+(NSArray*)generaNewsObjArrayFromSubObjArray:(NSArray*)aSubobjArray
{
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:0];
    for(NSInteger i=0; i<[aSubobjArray count]; i++)
    {
        id object = [aSubobjArray objectAtIndex:i];
        if(object!=nil && [object isKindOfClass:[SCSubscribeObject class]])
        {
            NewsChannelItem* channelItem = [SNSubDownloadManager newsItemFromSubItem:(SCSubscribeObject*)object];
            if(channelItem!=nil)
                [array addObject:channelItem];
        }
    }
    return array;
}

+(BOOL)validateDownloadPaper:(SCSubscribeObject*)aSubObject
{
    if(aSubObject!=nil && aSubObject.link==nil && (aSubObject.subId!=nil || aSubObject.termId!=nil))
        return YES;
    else if(aSubObject!=nil && aSubObject.link!=nil && ([aSubObject.link hasPrefix:kProtocolPaper] || [aSubObject.link hasPrefix:kProtocolDataFlow]))
        return YES;
    else
        return NO;
}

+(BOOL)validateDownloadChannel:(SCSubscribeObject*)aSubObject
{
    if(aSubObject!=nil && aSubObject.link!=nil)
    {
        NSString* channel = [SNSubDownloadManager channelFromProtocol:aSubObject.link type:nil];
        return channel!=nil && [channel length]>0;
    }
    else
        return NO;
}

- (void)dealloc {
     //(_downloadingRequest);
     //(_toBeDownloadedItems);
     //(_toBeDownloadedItemsFromDownloadClick);
}

#pragma mark - Public methods implementation
#pragma mark - 3.3 Refactored

//Load将被下载的刊物数据（订阅的刊物且是在离线设置里勾选的）
- (NSArray *)loadToBeDownloadedMySubsInMainThread {
     //(_toBeDownloadedItems);
    
    NSMutableArray* failArray = [NSMutableArray arrayWithCapacity:0];
    NSArray* newsTempArray = [SNNewsDownloadManager sharedInstance].toBeDownloadedItemsFromDownloadClick;
    
    //从新闻页面触发，只下载用户点的；从一键下载触发，只下载用户勾选的
    if(newsTempArray!=nil && [newsTempArray count]>0)
    {
        self.toBeDownloadedItems = [NSMutableArray arrayWithCapacity:0];
        return self.toBeDownloadedItems;
    }
    //从刊物页面触发，只下载用户点的；从一键下载触发，只下载用户勾选的
    else if(_toBeDownloadedItemsFromDownloadClick!=nil && [_toBeDownloadedItemsFromDownloadClick count]>0)
    {
        self.toBeDownloadedItems = [NSMutableArray arrayWithCapacity:0];
        [self.toBeDownloadedItems addObjectsFromArray:_toBeDownloadedItemsFromDownloadClick];
        return self.toBeDownloadedItems;
    }

    //过滤下载失败项
//    if(hasUnDownloadItem)
//    {
//        self.toBeDownloadedItems = [NSMutableArray arrayWithCapacity:0];
//        [self.toBeDownloadedItems addObjectsFromArray:_toBeDownloadedItemsFromDownloadClick];
//    }
//    else
//    {
//        NSArray* toBeDownloadedItems = [[SNDBManager currentDataBase] getSubscribeCenterSelectedUndownloadedMySubList];
//        self.toBeDownloadedItems = [[[SNDBManager currentDataBase] filterNewsSubscribeFromSubscribeArray:toBeDownloadedItems] mutableCopy];
//    }
    
    //从外面触发
    for(SCSubscribeObject* object in _toBeDownloadedItemsFromDownloadClick)
    {
        if(object.status==nil || [[NSString stringWithFormat:@"%d", SNDownloadWait] isEqualToString:object.status])
        if([[NSString stringWithFormat:@"%d", SNDownloadFail] isEqualToString:object.status])
            [failArray addObject:object];
    }
    
    //不在过滤 所有需要下载项都加到队列里
    //NSArray* toBeDownloadedItems = [[SNDBManager currentDataBase] getSubscribeCenterSelectedUndownloadedMySubList];
    NSArray* toBeDownloadedItems = [[SNDBManager currentDataBase] getSubscribeCenterSelectedMySubList];
    
    _toBeDownloadedItems = [[[SNDBManager currentDataBase] filterNewsSubscribeFromSubscribeArray:toBeDownloadedItems] mutableCopy];
    
    //如有有失败的 放在前面
    for(NSInteger i=0; i<[failArray count]; i++)
    {
        id object = [failArray objectAtIndex:i];
        if([object isKindOfClass:[SCSubscribeObject class]])
        {
            if(![[SNSubDownloadManager sharedInstance] ifArrayContainItem:self.toBeDownloadedItems item:object])
               [self.toBeDownloadedItems insertObject:object atIndex:0];
        }
    }
    
    for (SCSubscribeObject *_subObject in _toBeDownloadedItems) {
        _subObject.downloadStatus = SNDownloadWait;
    }
    return _toBeDownloadedItems;
}

//下载用户设置的所有刊物的最新一期
- (void)start {
    [self prepareStartingDownloadWithMsg:YES];
}

- (void)startWithoutPreparingMsg {
    [self prepareStartingDownloadWithMsg:NO];
}

//暂停所有下载
-(BOOL)doSuspendIfNeeded
{
    if(!_isSuspending && _downloadingRequest!=nil)
    {
        //当前下载项置成未下载
        NSArray *_waitingItems = [self runningDownloadItems];
        if(_waitingItems!=nil && _waitingItems.count>0)
        {
            for(SCSubscribeObject* _tmpDownloadingItem in _waitingItems)
                _tmpDownloadingItem.downloadStatus = SNDownloadWait;
        }
        
        _isSuspending = YES;
        [_downloadingRequest clearDelegatesAndCancel];
         //(_downloadingRequest);
        return YES;
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
    if(_isSuspending && _downloadingRequest==nil)
    {
        _isSuspending = NO;
        [self performSelectorOnMainThread:@selector(startADownload) withObject:nil waitUntilDone:NO];
        return YES;
    }
    
    return NO;
}

-(BOOL)validateSubscribeObjectForDownload:(SCSubscribeObject*)aItem
{
    if(aItem!=nil && (aItem.termId!=nil || aItem.subId!=nil))
        return YES;
    else
        return NO;
}

-(BOOL)ifArrayContainItem:(NSArray*)aArray item:(SCSubscribeObject*)aItem
{
    for(SCSubscribeObject* item in aArray)
    {
        if(aItem.termId!=nil && [aItem.termId isEqualToString:item.termId]) //依赖termid的项，termid不能重
            return YES;
        else if(aItem.termId==nil && aItem.subId!=nil && [aItem.subId isEqualToString:item.subId]) //依赖subid的项，subid不能重
            return YES;
        else
            return NO;
    }
    return NO;
}

- (void)updateSub:(SCSubscribeObject *)sub toDownloadStatus:(SNDownloadStatus)downloadStatus ifExitedIn:(NSArray *)subs {
    for(SCSubscribeObject* subInArray in subs) {
        if(sub.termId!=nil && [sub.termId isEqualToString:subInArray.termId]) //依赖termid的项，termid不能重
            subInArray.downloadStatus = downloadStatus;
        else if(sub.termId==nil && sub.subId!=nil && [sub.subId isEqualToString:subInArray.subId]) //依赖subid的项，subid不能重
            subInArray.downloadStatus = downloadStatus;
    }
}

//下载某个刊物的某一期
- (void)downloadSub:(SCSubscribeObject *)sub {
    if (!sub) {
        return;
    }
    
    //是否已经下载，如果已经下载，则不让下载这一期内容，直接返回
    SNPaperItem *localNewspaper = (SNPaperItem *)[[SNDBManager currentDataBase] getNewspaperByTermId:sub.termId];
    if (localNewspaper && [@"1" isEqualToString:localNewspaper.downloadFlag]) {
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"publication_home_had_downloaded", nil), sub.termName];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
    }
    
    //是否和正在下载刊物是同一期，是则返回什么也不做。
    if ([self isSubDownloading:sub]) {
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"publication_home_pubisdownloading", nil), sub.termName];
        [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeOnlyText];
        return;
    }
    
    //网络是否连通
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", @"")];
        return;
    }
    
    //[[SNStatusBarMessageCenter sharedInstance] postImmediateMessage:NSLocalizedString(SN_String("sbm_addsub_to_download"), @"") canTap:YES];
    
    //如果当前没有处于下载状态，那么开始
    if(![SNDownloadScheduler sharedInstance].isDownloading)
    {
        if(_toBeDownloadedItemsFromDownloadClick==nil)
            _toBeDownloadedItemsFromDownloadClick = [NSMutableArray arrayWithCapacity:0];
        
        if(![self ifArrayContainItem:_toBeDownloadedItemsFromDownloadClick item:sub] /*&& ![self ifArrayContainItem:_toBeDownloadedItems item:sub]*/) {
            [_toBeDownloadedItemsFromDownloadClick addObject:sub];
        } else {
            [self updateSub:sub toDownloadStatus:SNDownloadWait ifExitedIn:_toBeDownloadedItemsFromDownloadClick];
        }
        
        [[SNDownloadScheduler sharedInstance] start];
    }
    else
    {
        if([self validateSubscribeObjectForDownload:sub] && ![self ifArrayContainItem:_toBeDownloadedItems item:sub]) {
            NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"sbm_addsub_to_download", nil), sub.subName];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:msg toUrl:nil mode:SNCenterToastModeOnlyText];
            [_toBeDownloadedItems addObject:sub];
        } else {
            [self updateSub:sub toDownloadStatus:SNDownloadWait ifExitedIn:_toBeDownloadedItems];
        }
        
        //如果没有zipUrl,那么需要动态下载一下
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self getZipUrlFromOfflineIfNeeded:sub];
        });
    }
    
    /* //是否目前刊物和新闻两队列都处于下载完成的状态
    BOOL _isAllSubsAndChannelsDownloadFinished = NO;
    if ([_delegate respondsToSelector:@selector(isAllDownloadFinished)]) {
        _isAllSubsAndChannelsDownloadFinished = [_delegate isAllDownloadFinished];
    }
    
    //如果同一期刊物存在于toBeDownloadedItems中，如果是下载失败的项，则修改状态为Wait，以便重试。
    BOOL _isExisted = NO;
    for (SCSubscribeObject *_scSubObject in _toBeDownloadedItems) {
        if ([sub.subId isEqualToString:_scSubObject.subId] && [sub.termId isEqualToString:_scSubObject.termId]) {
            _isExisted = YES;
            
            //只考虑是否是失败项，如果是则修改状态为wait以便进行自动重试下载。
            //下载成功和等待下载都不用考虑：因为下载成功的情况肯定是不用再下载；下载等待的情况自然就它让等着，会顺序下载到的。
            if (_scSubObject.downloadStatus == SNDownloadFail) {
                _scSubObject.downloadStatus = SNDownloadWait;
            }
            break;
        }
    }
    
    //如果同一期刊物不存在于toBeDownloadedItems中，则修改状态为Wait并加入队列进行等待
    if (!_isExisted) {
        sub.downloadStatus = SNDownloadWait;
        if (!_toBeDownloadedItems) {
            _toBeDownloadedItems = [[NSMutableArray array] retain];
        }
        [_toBeDownloadedItems addObject:sub];
    }
    
    //刷新正在下载列表
    if ([_delegate respondsToSelector:@selector(readyToDownloadASubInMainThread:)]) {
        [_delegate readyToDownloadASubInMainThread:sub];
    }
    
    //如果目前刊物和新闻都处于下载完成的状态，则启动下载刊物
    if (_isAllSubsAndChannelsDownloadFinished) {
        [SNDownloadUtility markBgTaskAsBegin];
        
        [self finishAllOrStartADownload];
    }
    //如果有刊物或频道新闻正在下载，则什么也不用做，会顺序下载到的
    else {
        //Do nothing.
    }*/
}

//取消所有刊物的下载
- (void)cancelAll {
    //清除所有下载项
    [self cancelAllSubObjectFromDownloadClickArray];
    
    if (!(_downloadingRequest.isCancelled)) {
        [_downloadingRequest clearDelegatesAndCancel];
    }
     //(_downloadingRequest);
     //(_toBeDownloadedItems);
     //(_toBeDownloadedItemsFromDownloadClick);
    _delegate = nil;
}

//强制所有正在下载和等待下载的项失败
- (void)forceAllDownloadToFailWhenEndBgTask {
    SNDebugLog(@"===INFO: Ready to force updating all sub to fail...");
    
    //把正在等待下载的项设置为SNDownloadFail
    for (SCSubscribeObject *_scSubObj in [self waitingDownloadItems]) {
        _scSubObj.downloadStatus = SNDownloadFail;
    }
    
    //取消正在下载的项，并把状态设置为SNDownloadFail
    if (!!_downloadingRequest) {
        [_downloadingRequest clearDelegatesAndCancel];
        SCSubscribeObject *_downloadingItem =  (SCSubscribeObject *)[_downloadingRequest.userInfo objectForKey:kDownloadingItem];
        if (!!_downloadingItem) {
            _downloadingItem.downloadStatus = SNDownloadFail;
        }
    }
    SNDebugLog(@"===INFO: Finished to force updating all sub to fail...");
}

//取消某一刊物的下载
- (void)cancelDownload:(SCSubscribeObject *)downloadItem {
    SNDebugLog(@"===INFO: Canceling sub download......");
    
    if (!downloadItem) {
        SNDebugLog(@"===INFO: Invalid data when cancel.");
        return;
    }
    
    //清除临时下载项
    [self cancelSubObjectFromDownloadClickArray:downloadItem];
    
    SCSubscribeObject *_downloadingItem =  (SCSubscribeObject *)[_downloadingRequest.userInfo objectForKey:kDownloadingItem];
    //取消下载项为正在下载项
    if ([downloadItem.subId isEqualToString:_downloadingItem.subId]) {
        [_downloadingRequest clearDelegatesAndCancel];
         //(_downloadingRequest);
        
        downloadItem.downloadStatus = SNDownloadCancel;
        //刷新正在离线列表
        if ([_delegate respondsToSelector:@selector(didCancelDownloadItemInMainThread:)]) {
            [_delegate didCancelDownloadItemInMainThread:_downloadingItem];
        }
        [self finishAllOrStartADownload];
    }
    //取消下载的项为等待项
    else {
        downloadItem.downloadStatus = SNDownloadCancel;
        //刷新正在离线列表
        if ([_delegate respondsToSelector:@selector(didCancelDownloadItemInMainThread:)]) {
            [_delegate didCancelDownloadItemInMainThread:_downloadingItem];
        }
    }
}

//重试某一刊物的下载
- (void)retryDownload:(SCSubscribeObject *)downloadItem {
    SNDebugLog(@"===INFO: Retrying sub download......");
    
    //网络是否连通
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [SNNotificationCenter showExclamation:NSLocalizedString(@"network error", nil)];
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
        
        if ([_delegate respondsToSelector:@selector(resetSubDownloadingProgressBarInMainThread)]) {
            [_delegate resetSubDownloadingProgressBarInMainThread];
        }
        /**
         * 这种情况的重试是就地重试，不会从Scheduler走SubDownloadManager startWithoutMsg入口，所以这里不用设置isSpecifiedTerm = YES
         */
        downloadItem.downloadStatus = SNDownloadWait;
        [self finishAllOrStartADownload];
    }
    //否则只是改变downloadItem的状态并刷新UI样式;
    else {
        if ([_delegate respondsToSelector:@selector(readyToRetryInMainThread:)]) {
            /**
             * 防止：刊物下载完成，但部分失败了，然后再下载频道新闻，这时重试刊物，
             * 等新闻下完后会再下载刊物（会从Scheduler走SubDownloadManager startWithoutMsg入口）但有可能新的一期已经发布了，
             * 所以为了不让它去取最新一期数据则设置isSpecifiedTerm = YES，况且这个对象已经知道下载哪一期了，和下载指定的一期是一样道理；
             */
            downloadItem.isSpecifiedTerm = YES;
            downloadItem.downloadStatus = SNDownloadWait;
            [_delegate readyToRetryInMainThread:downloadItem];
        }
    }
}

//已全部下载完成（无论其中是否有下载失败的）－没有正在下载和等待的项就说明所有待下载项都已尝试下载过，可能其中有下载失败的。
- (BOOL)isAllDownloadFinished {
    //SNSubDownloadManager中的waiting项和正在下载项
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus==0 or downloadStatus==1"];//SNDownloadWait/SNDownloadRunning
    NSArray *_waitingSubItems = [_toBeDownloadedItems filteredArrayUsingPredicate:_predicate];
    return (_waitingSubItems.count <= 0);
}

//已全部下载完成但其中有失败的
- (BOOL)isAllDownloadFinishedButAndSomeFail {
    BOOL _isAllDownloadFinished = [self isAllDownloadFinished];
    if (_isAllDownloadFinished) {
        //SNSubDownloadManager中的fail项
        return ([self failedDownloadedItems].count>0);
    } else {
        return NO;
    }
}

//已全部下载完成但其中有取消的
- (BOOL)isAllDownloadFinishedButAndSomeCancel {
    BOOL _isAllDownloadFinished = [self isAllDownloadFinished];
    if (_isAllDownloadFinished) {
        //SNSubDownloadManager中的cancel项
        return ([self canceledDownloadedItems].count>0);
    } else {
        return NO;
    }
}

//已全部下载完成且其中没有有失败的
- (BOOL)isAllDownloadFinishedAndNoFail {
    BOOL _isAllDownloadFinished = [self isAllDownloadFinished];
    if (_isAllDownloadFinished) {
        //SNSubDownloadManager中的fail项
        return ([self failedDownloadedItems].count<=0);
    } else {
        return NO;
    }
}

//等待下载的项
- (NSArray *)waitingDownloadItems {
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus==0"];//SNDownloadWait
    return [_toBeDownloadedItems filteredArrayUsingPredicate:_predicate];
}

//正在下载的项
- (NSArray *)runningDownloadItems {
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus==1"];//SNDownloadRunning
    return [_toBeDownloadedItems filteredArrayUsingPredicate:_predicate];
}

//失败下载的项
- (NSArray *)failedDownloadedItems {
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus==2"];//SNDownloadFail
    return [_toBeDownloadedItems filteredArrayUsingPredicate:_predicate];
}

//取消下载的项
- (NSArray *)canceledDownloadedItems {
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"downloadStatus==4"];//SNDownloadCancel
    return [_toBeDownloadedItems filteredArrayUsingPredicate:_predicate];
}

//判断某刊物某一期是否正在下载
- (BOOL)isSubDownloading:(SCSubscribeObject *)sub {
    SCSubscribeObject *_downloadingItem =  (SCSubscribeObject *)[_downloadingRequest.userInfo objectForKey:kDownloadingItem];
    return !!(sub.subId) && ![@"" isEqualToString:sub.subId] && [sub.subId isEqualToString:_downloadingItem.subId] && [sub.termId isEqualToString:_downloadingItem.termId];
}

//刊物是否为失败项
- (BOOL)isSubFailed:(SCSubscribeObject *)sub {
    for (SCSubscribeObject *_failedSub in [self failedDownloadedItems]) {
        if ([_failedSub.subId isEqualToString:sub.subId] && [_failedSub.termId isEqualToString:sub.termId]) {
            return YES;
        }
    }
    return NO;
}

//刊物是否不在下载队列中
- (BOOL)isSubDetached:(SCSubscribeObject *)sub {
    for (SCSubscribeObject *_subObj in _toBeDownloadedItems) {
        if ([_subObj.subId isEqualToString:sub.subId] && [_subObj.termId isEqualToString:sub.termId]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Private methods implementation

//mysubPOs<SCSubscribeObject>
- (void)prepareStartingDownloadWithMsg:(BOOL)showPreparingMsg {
    if ([_delegate respondsToSelector:@selector(didPrepareDownloadAllSubInMainThreadWithMsg:)]) {
        [_delegate didPrepareDownloadAllSubInMainThreadWithMsg:showPreparingMsg];
    }
    
    //获取待下载我的订阅的最新一期termId;
    //这样做的目的是为了防止：刊物首页(HomeV3接口)长时间不刷新但后台服务器已发布了订阅刊物的最新一期或几期，如果直接用我的订阅里的termId那么下载的数据并不是最新的，所有要从服务器获取已订阅刊物的最新一期termId
    [self batchGetLatestTermIdOfMySubs];
}

//mysubPOs<SCSubscribeObject>
- (void)batchGetLatestTermIdOfMySubs {
    
    if (!!_toBeDownloadedItems && _toBeDownloadedItems.count > 0) {
        /**
         * 这个Dictionary的作用：一次性取回所有我的订阅的最新一期历史后，批量的按mysubPOs中对象顺序给各个对象设上最新一期的termId、termTime和termName;
         */
        NSMutableDictionary *_downloadingSubIdsAndItemsMap = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *_downloadingTermdsAndItemsMap = [[NSMutableDictionary alloc] init];
        
        BOOL _containSubsOfSpecifiedTerm = NO;
        
        //缓存一下我的订阅ID和我的订阅映射关系，拼接我的订阅id
        NSMutableString *_tmpSubIds = [[NSMutableString alloc] init];
        NSMutableString *_tmpTermIds = [[NSMutableString alloc] init];
        for (SCSubscribeObject *_tmpDownloadingItem in _toBeDownloadedItems) {
            /*if (_tmpDownloadingItem.isSpecifiedTerm) {
                _containSubsOfSpecifiedTerm = YES;
                continue;
            }*/
            
            //把我订阅数据缓存到Dictionary里，后面获取到所有我的订阅最新期号时会用到
            if(_tmpDownloadingItem.termId!=nil && [_tmpDownloadingItem.termId length]>0)
                [_downloadingTermdsAndItemsMap setObject:_tmpDownloadingItem forKey:_tmpDownloadingItem.termId];
            else if(_tmpDownloadingItem.subId!=nil && [_tmpDownloadingItem.subId length]>0)
                [_downloadingSubIdsAndItemsMap setObject:_tmpDownloadingItem forKey:_tmpDownloadingItem.subId];
            
            //拼接我的订阅id
            if ([_toBeDownloadedItems indexOfObject:_tmpDownloadingItem] > 0) {
                if(_tmpDownloadingItem.termId!=nil && [_tmpDownloadingItem.termId length]>0) {
                    if (_tmpTermIds.length <= 0) {
                        [_tmpTermIds appendFormat:@"%@", _tmpDownloadingItem.termId];
                    } else {
                        [_tmpTermIds appendFormat:@",%@", _tmpDownloadingItem.termId];
                    }
                }
                else if(_tmpDownloadingItem.subId!=nil && [_tmpDownloadingItem.subId length]>0) {
                    if (_tmpSubIds.length <= 0) {
                        [_tmpSubIds appendFormat:@"%@", _tmpDownloadingItem.subId];
                    } else {
                        [_tmpSubIds appendFormat:@",%@", _tmpDownloadingItem.subId];
                    }
                }
            }
            else
            {
                if(_tmpDownloadingItem.termId!=nil && [_tmpDownloadingItem.termId length]>0) {
                    if (_tmpTermIds.length <= 0) {
                        [_tmpTermIds appendFormat:@"%@", _tmpDownloadingItem.termId];
                    } else {
                        [_tmpTermIds appendFormat:@",%@", _tmpDownloadingItem.termId];
                    }
                }
                else if(_tmpDownloadingItem.subId!=nil && [_tmpDownloadingItem.subId length]>0) {
                    if (_tmpSubIds.length <= 0) {
                        [_tmpSubIds appendFormat:@"%@", _tmpDownloadingItem.subId];
                    } else {
                        [_tmpSubIds appendFormat:@",%@", _tmpDownloadingItem.subId];
                    }
                }
            }
        }
        
        /**
         * 如果_tmpSubIds为空说明但_containSubsOfSpecifiedTerm为YES，这说明里面的数据都是下载指定一期刊物（单个添加和失败重试的刊物）
         * 这种情况则直接开始下载
         */
        if ((!_tmpSubIds || [@"" isEqualToString:_tmpSubIds]) && _containSubsOfSpecifiedTerm) {
            _containSubsOfSpecifiedTerm = NO;
            [self finishAllOrStartADownload];
        }
        /**
         * 如果_tmpSubIds不为空，则下面的逻辑只获取最新一期的数据(上面没有拼接指定一期刊物的subID)然后下载包括指定一期在内的刊物；
         */
        else {
            //发起我的订阅最近5期的查询请求(5条是接口服务器限制的)
            //NSURL *_url = [NSURL URLWithString:[NSString stringWithFormat:kInputBox, _tmpSubIds]];
            //3.4 服务端发布offline接口替掉原来的Inputbox接口
            NSString* offline = [NSString stringWithFormat:kOffline, [SNUtility getP1]];
            if([_tmpSubIds length]>0) offline = [NSString stringWithFormat:@"%@&subIds=%@", offline, _tmpSubIds];
            if([_tmpTermIds length]>0) offline = [NSString stringWithFormat:@"%@&termIds=%@", offline, _tmpTermIds];
            NSURL *_url = [NSURL URLWithString:offline];
            
            SNDownloaderRequest *_latestSubTermIdsRequest = [SNDownloaderRequest requestWithURL:_url];
             //(_tmpSubIds);
             //(_tmpTermIds);
            
            SNDebugLog(@"INFO: %@--%@, _url is %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _url);
            [_latestSubTermIdsRequest startSynchronous];
            
            int _responseStatus = [_latestSubTermIdsRequest responseStatusCode];
            NSString *_responseString = [_latestSubTermIdsRequest responseString];
            if ((_responseStatus == HttpSucceededResponseStatusCode) && !!_responseString) {
                //SNDebugLog(@"INFO: %@--%@, response data is \n %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _responseString);
                
                id _rootData =  [NSJSONSerialization JSONObjectWithString:_responseString
                                                                  options:NSJSONReadingMutableLeaves
                                                                    error:NULL];
                if (!_rootData) {
                    SNDebugLog(@"ERROR: %@--%@, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [[_latestSubTermIdsRequest error] localizedDescription]);
                    [self failedToBatchGetLatestTermId:[NSString stringWithFormat:@"Failed to parse json data from rootData."]];
                } else {
                    [self parseTermIdsFromData:_rootData subIdMap:_downloadingSubIdsAndItemsMap termIdMap:_downloadingTermdsAndItemsMap];
                     //(_downloadingSubIdsAndItemsMap);
                     //(_downloadingTermdsAndItemsMap);
                    
                    //为了让controller有机会刷新cell的title为termName;
                    if ([_delegate respondsToSelector:@selector(didGetNewTermOfToBeDownloadedSubsInMainThread)]) {
                        [_delegate didGetNewTermOfToBeDownloadedSubsInMainThread];
                    }
                    
                    [self finishAllOrStartADownload];
                }
            }
            else {
                SNDebugLog(@"ERROR: %@--%@, %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [[_latestSubTermIdsRequest error] localizedDescription]);
                [self failedToBatchGetLatestTermId:[NSString stringWithFormat:@"Failed to parse json data from rootData."]];
                 //(_toBeDownloadedItems);
            }
             //(_latestSubTermIdsRequest);
             //(_downloadingSubIdsAndItemsMap);
             //(_downloadingTermdsAndItemsMap);
        }
    }
}

- (void)parseTermIdsFromData:(id)data subIdMap:(NSDictionary*)submap termIdMap:(NSDictionary*)termmap{
    SNDebugLog(@"INFO: %@--%@, data is %@, [data isKindOfClass:[NSDictionary class]]:%d, [data isKindOfClass:[NSArray class]]:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), data, [data isKindOfClass:[NSDictionary class]], [data isKindOfClass:[NSArray class]]);
    //只查询了一个订阅
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        NSDictionary *_tmpData = [(NSDictionary *)data objectForKey:ksub];
        [self parseOneSub:_tmpData subIdMap:submap termIdMap:termmap];
    }
    //查询了多个订阅
    else if (data && [data isKindOfClass:[NSArray class]]) {
        NSArray *_subs = (NSArray *)data;
        for (id _subData in _subs) {
            [self parseOneSub:_subData subIdMap:submap termIdMap:termmap];
        }
    }
}

//这是3.4版本解析offline.go的方法
- (void)parseOneSub:(id)_subData subIdMap:(NSDictionary*)submap termIdMap:(NSDictionary*)termmap {
    if (_subData && [_subData isKindOfClass:[NSDictionary class]]) {
        NSNumber* _subId = [_subData objectForKey:ksubId];
        NSNumber* _termId = [_subData objectForKey:ktermId];
        
        SCSubscribeObject* _po = [termmap objectForKey:[_termId stringValue]];
        if(_po==nil) _po = [submap objectForKey:[_subId stringValue]];
        
        id publishTime = [_subData objectForKey:kpublishTime];
        if(publishTime!=nil &&  [publishTime isKindOfClass:[NSString class]])
            _po.publishTime = publishTime;
        else if(publishTime!=nil &&  [publishTime isKindOfClass:[NSNumber class]])
        {
            NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
            _po.publishTime  = [numberFormatter stringFromNumber:publishTime];
        }
        
        NewspaperItem* item =[[SNDBManager currentDataBase] getNewspaperByTermId:[_termId stringValue]];
        if(item!=nil && [item.publishTime isEqualToString:_po.publishTime] && [@"1" isEqualToString:item.downloadFlag])
            _po.downloadStatus = SNDownloadSuccess;
        else
        {
            NSArray* items =[[SNDBManager currentDataBase] getNewspaperListBySubId:[_subId stringValue]];
            for(NewspaperItem* item in items)
            {
                if(item!=nil && [item.publishTime isEqualToString:_po.publishTime] && [@"1" isEqualToString:item.downloadFlag])
                {
                    _po.downloadStatus = SNDownloadSuccess;
                    break;
                }
            }
        }
        
        _po.termName = [_subData objectForKey:ktermName];
        //Zipurl不行的话使用动态打包地址
        _po.zipUrl = [_subData objectForKey:@"zipUrl"];
        if(_po.zipUrl==nil)
            _po.zipUrl = [_subData objectForKey:@"dynamicZipUrl"];
    }
}

//这是3.3版本解析inputBox.go的方法
/*
- (void)parseOneSub:(id)_subData map:(NSDictionary *)map {
    if (_subData && [_subData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *_sub = (NSDictionary *)_subData;
        NSString *_subId = [_sub objectForKey:ksubId];
        id papersData = [_sub objectForKey:kpaper];
        
        if (_subId) {
            SCSubscribeObject *_po = [map objectForKey:_subId];
            //接口只返回一期刊物数据
            if (papersData && [papersData isKindOfClass:[NSDictionary class]]) {
                [self parseOneTerm:papersData intoPO:_po];
            }
            //接口返回多期刊物数据
            else if (papersData && [papersData isKindOfClass:[NSArray class]]) {
                NSArray *_papers = (NSArray *)papersData;
                if (_papers.count > 0) {
                    id _paperData = [_papers objectAtIndex:0];
                    [self parseOneTerm:_paperData intoPO:_po];
                }
            }
        }
    }
}

- (void)parseOneTerm:(id)_paperData intoPO:(SCSubscribeObject *)_po {
    if (_paperData && [_paperData isKindOfClass:[NSDictionary class]]) {
        SNDebugLog(@"INFO: mysub %@ before setting termId %@ and termTime is %@", [_po subName], [_po termId], [_po publishTime]);
        NSDictionary *_paper = (NSDictionary *)_paperData;
        //termId
        NSString *_termId = [_paper objectForKey:ktermId];
        if (_termId) {
            _po.termId = [_termId URLDecodedString];
        }
        
        //termTime
        NSString *_termTime = [_paper objectForKey:ktermTime];
        if (_termTime) {
            _po.publishTime = [_termTime URLDecodedString];
        }
        
        //termName
        NSString *_termName = [_paper objectForKey:ktermName];
        if (_termName) {
            _po.termName = [_termName URLDecodedString];
        }
        SNDebugLog(@"INFO: mysub %@ after setting termId %@ and termTime is %@", [_po subName], [_po termId], [_po publishTime]);
    }
}*/

- (void)failedToBatchGetLatestTermId:(NSString *)message {
    if ([_delegate respondsToSelector:@selector(didFailedToDownloadAllSubInMainThread)]) {
        [_delegate didFailedToDownloadAllSubInMainThread];
    }
     //(_toBeDownloadedItems);
    _delegate = nil;
}

#pragma mark -

- (void)startADownload {
    NSArray *_waitingItems = [self waitingDownloadItems];
    
    if (!!_waitingItems && _waitingItems.count > 0) {
        SCSubscribeObject *_tmpDownloadingItem = [_waitingItems objectAtIndex:0];
        _tmpDownloadingItem.downloadStatus = SNDownloadRunning;
        
        NSString *_urlString = _tmpDownloadingItem.zipUrl;
        if(_urlString==nil)
            _urlString = [NSString stringWithFormat:kUrlTermZip, _tmpDownloadingItem.termId];
        
        SNDebugLog(@"===INFO:Ready to download item %@ from url [%@]", [_tmpDownloadingItem subName], _urlString);
        
        _downloadingRequest = [SNASIRequest requestWithURL:[NSURL URLWithString:_urlString]];
        [_downloadingRequest setDownloadProgressDelegate:self];
        [_downloadingRequest setNumberOfTimesToRetryOnTimeout:1];
        _downloadingRequest.delegate = self;
        _downloadingRequest.allowResumeForFileDownloads = YES;
        _downloadingRequest.validatesSecureCertificate = NO;
        _downloadingRequest.temporaryFileDownloadPath = [SNDownloadConfig temporaryFileDownloadPathWithURL:[[_downloadingRequest url] absoluteString]];
        _downloadingRequest.downloadDestinationPath = [SNDownloadConfig downloadDestinationPathWithURL:[[_downloadingRequest url] absoluteString]];
        _tmpDownloadingItem.tmpDownloadZipPath = _downloadingRequest.temporaryFileDownloadPath;
        _tmpDownloadingItem.finalDownloadZipPath = _downloadingRequest.downloadDestinationPath;
        [_downloadingRequest setUserInfo:[NSDictionary dictionaryWithObject:_tmpDownloadingItem forKey:kDownloadingItem]];
        [_downloadingRequest setValidatesSecureCertificate:NO];
        [_downloadingRequest startAsynchronous];
        
        if ([_delegate respondsToSelector:@selector(didStartDownloadAItemInMainThread:)]) {
            [_delegate didStartDownloadAItemInMainThread:_tmpDownloadingItem];
        }
    }
    
    SNDebugLog(@"===INFO:To be downloaded items count is %d", _toBeDownloadedItems.count);
}

#pragma mark - ASIHTTPRequestDelegate methods implementation

- (void)requestStarted:(ASIHTTPRequest *)request {
}

/**
 * 对于每一个刊物下载，这个方法会被调两次：
 * 第一次，请求termZip.go接口；
 * 第二次，通过termZip.go接口返回的header 'Location'数据进行重定向请求；
 */
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    SCSubscribeObject *_tmpDownloadingItem = [[request userInfo] objectForKey:kDownloadingItem];
    
    int __responseStatusCode = [request responseStatusCode];
    SNDebugLog(@"===INFO:Receive responseHeaders of %@ \n, %@, status code: %d, Main thread:%d",
               _tmpDownloadingItem.subName, responseHeaders, __responseStatusCode, [NSThread isMainThread]);
    
    /**
     * 判断是否200、301、302、303
     * 因为：
     * ASIHTTPRequest will automatically redirect to a new URL when it encounters one of the following HTTP status codes, assuming a Location header was sent:
     * 301 Moved Permanently
     * 302 Found
     * 303 See Other
     */
    
    if(!(__responseStatusCode >= HttpSucceededResponseStatusCode && __responseStatusCode <= 299) &&
       __responseStatusCode != 301 &&
       __responseStatusCode != 302 &&
       __responseStatusCode != 303){
        SNDebugLog(@"===ERROR:[didReceiveResponseHeaders]:Status code is not 200 but %d.", [request responseStatusCode]);
        
        //debug mode时保留现场，以便分析；
        if (![SNPreference sharedInstance].debugModeEnabled) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:request.temporaryFileDownloadPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:request.temporaryFileDownloadPath error:NULL];
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:request.downloadDestinationPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:request.downloadDestinationPath error:NULL];
            }
        }
        
        NSString *_msg = [NSString stringWithFormat:@"[ReceiveResponseHeaders]:Failed to download subName %@, subId %@, from %@, termId %@",
                          _tmpDownloadingItem.subName,
                          _tmpDownloadingItem.subId,
                          [NSURL URLWithString:_tmpDownloadingItem.zipUrl],
                          _tmpDownloadingItem.zipUrl
                          //[NSURL URLWithString:[NSString stringWithFormat:kUrlTermZip, _tmpDownloadingItem.termId]],
                          //[NSString stringWithFormat:kUrlTermZip, _tmpDownloadingItem.termId]
                          ];
        
        [self requestFailedAnyway:request message:_msg];
        [self finishAllOrStartADownload];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    SCSubscribeObject *_tmpDownloadingItem = [[request userInfo] objectForKey:kDownloadingItem];
    SNDebugLog(@"===INFO:Finish downloading sub %@, Main thread:%d", _tmpDownloadingItem.subName, [NSThread isMainThread]);
    
    // 因为这里已经到完成方法里，所以只判断是否200
    //下载失败
    if(!([request responseStatusCode] >= HttpSucceededResponseStatusCode && [request responseStatusCode] <= 299)){
        
        //debug mode时保留现场，以便分析；
        if (![SNPreference sharedInstance].debugModeEnabled) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:request.temporaryFileDownloadPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:request.temporaryFileDownloadPath error:NULL];
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:request.downloadDestinationPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:request.downloadDestinationPath error:NULL];
            }
        }
        
        SNDebugLog(@"===INFO:[requestFinished]:Failed to download with httpStatusCode %d, Main thread:%d",
                   [request responseStatusCode], [NSThread isMainThread]);
        NSString *_msg = [NSString stringWithFormat:@"[requestFinished]:Failed to download subName %@, subId %@, from %@, termId %@",
                          _tmpDownloadingItem.subName,
                          _tmpDownloadingItem.subId,
                          [NSURL URLWithString:_tmpDownloadingItem.zipUrl],
                          _tmpDownloadingItem.zipUrl
                          //[NSURL URLWithString:[NSString stringWithFormat:kUrlTermZip, _tmpDownloadingItem.termId]],
                          //[NSString stringWithFormat:kUrlTermZip, _tmpDownloadingItem.termId]
                          ];
        [self requestFailedAnyway:request message:_msg];
        [self finishAllOrStartADownload];
    }
    //下载成功并解压数据包。
    //注意：下载数据包成功并不意味着下载成功，必须解压数据包、更新本地数据库数据都成功后才算是下载成功并把_tmpDownloadingItem的downloadStatus置为SNDownloadSuccess
    else {
        //Unzip in thread;
        NSMutableDictionary *_userInfo = [[NSMutableDictionary alloc] init];
        [_userInfo setObject:_tmpDownloadingItem forKey:kTmpDownloadingItem];
        [_userInfo setObject:request forKey:kDownloadingRequest];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self unzipDownloadedDataInThread:_userInfo];
        });
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    SCSubscribeObject *_tmpDownloadingItem = [[request userInfo] objectForKey:kDownloadingItem];
    SNDebugLog(@"===INFO:[requestFailed]: Failed to download %@ with comming message: %@", _tmpDownloadingItem.subName, [[request error] localizedDescription]);
    [self requestFailedAnyway:request message:[NSString stringWithFormat:@"[requestFailed]:Failed to download sub %@ with comming message: %@",
                                               _tmpDownloadingItem.subName, [[request error] localizedDescription]]];
    [self finishAllOrStartADownload];
}

- (void)setProgress:(float)newProgress {
    //SNDebugLog(SN_String("===INFO:Downloading a sub progress is [%f]"), newProgress);
    SNDebugLog(@"~~~~~~~~~~%f~~~~~~~~~~", newProgress);
    
    if ([_delegate respondsToSelector:@selector(updateNewsOrPubDownloadProgressInMainThread:)])
        [_delegate updateNewsOrPubDownloadProgressInMainThread:[NSNumber numberWithFloat:newProgress]];
}

#pragma mark -

- (void)unzipDownloadedDataInThread:(NSDictionary *)userInfo {
    @autoreleasepool {
        SCSubscribeObject *_tmpDownloadingItem = [userInfo objectForKey:kTmpDownloadingItem];
        ASIHTTPRequest *request = [userInfo objectForKey:kDownloadingRequest];
        
        //解压zip文件
        ZipArchive *zip	= [[ZipArchive alloc] init];
        zip.delegate = self;
        zip.needUnzipProcessNotify	= YES;
        BOOL unzipSucceed = NO;
        
        if ([zip UnzipOpenFile:[_tmpDownloadingItem finalDownloadZipPath]]) {
            if ([zip UnzipFileTo:[SNDownloadConfig downloadDestinationDir] overWrite:YES]) {
                
                //解压成功
                unzipSucceed = YES;
                
                //删除压缩包
                NSFileManager *_fm = [NSFileManager defaultManager];
                NSString *_tmpDownloadFilePath = [_tmpDownloadingItem tmpDownloadZipPath];
                NSString *_destDownloadFilePath = [_tmpDownloadingItem finalDownloadZipPath];
                if ([_fm fileExistsAtPath:_tmpDownloadFilePath]) {
                    [_fm removeItemAtPath:_tmpDownloadFilePath error:nil];
                }
                if ([_fm fileExistsAtPath:_destDownloadFilePath]) {
                    [_fm removeItemAtPath:_destDownloadFilePath error:nil];
                }
                
                //数据库操作--------------------------------------
                //保存newspaperItem数据到数据库
                NSString *termLinkURL = [NSString stringWithFormat:kUrlTermPaper, _tmpDownloadingItem.termId];
                NSString *zipURL = _tmpDownloadingItem.zipUrl;
                //NSString *zipURL = [NSString stringWithFormat:kUrlTermZip, _tmpDownloadingItem.termId];
                NewspaperItem *_downloadingNewspaper    = [[NewspaperItem alloc] init];
                _downloadingNewspaper.subId             = _tmpDownloadingItem.subId;
                _downloadingNewspaper.pubId             = _tmpDownloadingItem.pubIds;
                _downloadingNewspaper.termId            = _tmpDownloadingItem.termId;
                NSString *_tmpTermName                  = _tmpDownloadingItem.termName;
                _downloadingNewspaper.termName          = (!!_tmpTermName && ![@"" isEqualToString:_tmpTermName]) ? _tmpTermName : _tmpDownloadingItem.subName;
                _downloadingNewspaper.termLink          = termLinkURL;
                _downloadingNewspaper.termZip           = zipURL;
                //_downloadingNewspaper.termTime          = _tmpDownloadingItem.publishTime;
                _downloadingNewspaper.readFlag          = @"0";
                _downloadingNewspaper.downloadFlag      = @"1";
                _downloadingNewspaper.downloadTime      = [NSString stringWithFormat:@"%lf", [(NSDate *)[NSDate date] timeIntervalSince1970]];
                _downloadingNewspaper.publishTime       = _tmpDownloadingItem.publishTime;
                _downloadingNewspaper.termTime          = _tmpDownloadingItem.publishTime;
                
                //获得到了newspaper首页的html决对路径
                if (_downloadingZipIndexFilePath) {
                    SNDebugLog(@"===INFO: Zip file of sub %@ had unzipped to path %@", _tmpDownloadingItem.subName, _downloadingZipIndexFilePath);
                    _downloadingNewspaper.newspaperPath = [[SNDownloadConfig downloadDestinationDir] stringByAppendingPathComponent:_downloadingZipIndexFilePath];
                     //(_downloadingZipIndexFilePath);
                    
                    if ([[SNDBManager currentDataBase] addSingleNewspaper:_downloadingNewspaper]) {
                        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:_tmpDownloadingItem.subId];
                        
                        // 只有最新一期时才更新我的订阅图标的已下载状态
                        BOOL bChangeStatus = NO;
                        if ([subObj.termId isEqualToString:_downloadingNewspaper.termId] /*&& [subObj.publishTime isEqualToString:_downloadingNewspaper.publishTime]*/) {
                            bChangeStatus = [subObj setStatusValue:[KHAD_BEEN_OFFLINE intValue] forFlag:SCSubObjStatusFlagSubStatus];
                        }
                        subObj.isDownloaded = kHAD_DOWNLOADED;
                        
                        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:NO];
                        
                        if (bChangeStatus) {
                            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:subObj.subId, @"subId", subObj.status, @"status", nil];
                            [SNNotificationManager postNotificationName:kSubscribeObjectStatusChangedNotification object:nil userInfo:dict];
                        }
                        
                        _tmpDownloadingItem.downloadStatus = SNDownloadSuccess;
                        
                        //清除临时下载项
                        for(NSInteger i=[_toBeDownloadedItemsFromDownloadClick count]-1; i>=0; i--)
                        {
                            id object = [_toBeDownloadedItemsFromDownloadClick objectAtIndex:i];
                            if(object!=nil && [object isKindOfClass:[SCSubscribeObject class]])
                            {
                                SCSubscribeObject* item = (SCSubscribeObject*)object;
                                if(item.subId!=nil && [item.subId isEqualToString:_tmpDownloadingItem.subId])
                                    [_toBeDownloadedItemsFromDownloadClick removeObjectAtIndex:i];
                            }
                        }
                        
                        if ([_delegate respondsToSelector:@selector(didFinishedDownloadAItemInMainThread:)]) {
                            [_delegate didFinishedDownloadAItemInMainThread:_tmpDownloadingItem];
                        }
                        [self finishAllOrStartADownload];
                    }
                    else {
                        SNDebugLog(@"===INFO:Failed to download sub %@ with cant updating newspaper data to db.", _tmpDownloadingItem.subName);
                        
                        NSString *_msg = [NSString stringWithFormat:@"Failed to add data to database after unzip file, subName %@, subId %@. ",
                                          _tmpDownloadingItem.subName, _tmpDownloadingItem.subId];
                        [self requestFailedAnyway:request message:_msg];
                        [self finishAllOrStartADownload];
                    }
                     //(_downloadingNewspaper);
                }
                //没有获得到了newspaper首页的html决对路径
                else {
                    SNDebugLog(@"===INFO:Failed to download sub %@ with cant get newspaper's index file path.", _tmpDownloadingItem.subName);
                    
                    NSString *_msg = [NSString stringWithFormat:@"Failed to get newspaper's index file path, subName %@, subId %@. ",
                                      _tmpDownloadingItem.subName, _tmpDownloadingItem.subId];
                    [self requestFailedAnyway:request message:_msg];
                    [self finishAllOrStartADownload];
                     //(_downloadingNewspaper);
                }
            }
        }
        
        [zip UnzipCloseFile];
        zip.delegate = nil;
         //(zip);
        
        //打开zip失败或解压失败则删除数据包
        if (!unzipSucceed) {
            SNDebugLog(@"ERROR: Failed to open zip file %@", [_tmpDownloadingItem finalDownloadZipPath]);
            
            NSFileManager *_fm = [NSFileManager defaultManager];
            NSString *_tmpDownloadFilePath = [_tmpDownloadingItem tmpDownloadZipPath];
            NSString *_destDownloadFilePath = [_tmpDownloadingItem finalDownloadZipPath];
            if ([_fm fileExistsAtPath:_tmpDownloadFilePath]) {
                [_fm removeItemAtPath:_tmpDownloadFilePath error:nil];
            }
            if ([_fm fileExistsAtPath:_destDownloadFilePath]) {
                [_fm removeItemAtPath:_destDownloadFilePath error:nil];
            }
            
            SNDebugLog(@"===INFO:Failed to download %@ with cant unzip file.", _tmpDownloadingItem.subName);
            
            NSString *_msg = [NSString stringWithFormat:@"Failed to unzip file, sub name %@, sub id %@. ",
                              [_tmpDownloadingItem subName], [_tmpDownloadingItem subId]];
            [self requestFailedAnyway:request message:_msg];
            [self finishAllOrStartADownload];
        }
        
         //(userInfo);
    }
}

- (void)requestFailedAnyway:(ASIHTTPRequest *)request message:(NSString *)message {
    SNDebugLog(@"===ERROR:[requestFailedAnyway]: message: %@", message);
    
    SCSubscribeObject *_tmpDownloadingItem = [[request userInfo] objectForKey:kDownloadingItem];
    _tmpDownloadingItem.downloadStatus = SNDownloadFail;
    
    [_downloadingRequest setDelegate:nil];
    [_downloadingRequest setDownloadProgressDelegate:nil];
     //(_downloadingRequest);
    
    if ([_delegate respondsToSelector:@selector(didFailedToDownloadAItemInMainThread:)]) {
        [_delegate didFailedToDownloadAItemInMainThread:_tmpDownloadingItem];
    }
}

- (void)finishAllOrStartADownload {
    NSArray *_waitingItems = [self waitingDownloadItems];
    
    //没有等待下载的刊物
    if (_waitingItems.count <= 0) {
        SNDebugLog(@"INFO: %@--%@, Finished to download all tasks.", NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        _downloadingRequest.delegate = nil;
        _downloadingRequest.downloadProgressDelegate = nil;
         //(_downloadingRequest);
        
        //[self releaseToBeDownloadedItemsIfNeeded];
        
        if ([_delegate respondsToSelector:@selector(didFinishedDownloadAllSubInMainThread)]) {
            [_delegate didFinishedDownloadAllSubInMainThread];
        }
        
        /**
         * 如果全部完成，但有失败的下载项千万不能把delegate置为nil；
         * 因为置为nil后，在cancel和retry单个失败项时scheduler将不影响，应该delegate<scheduler>已经为nil了。
         */
        if ([self isAllDownloadFinishedAndNoFail]) {
            _delegate = nil;
        }
    }
    //开启下次下载
    else {
        _downloadingRequest.delegate = nil;
        _downloadingRequest.downloadProgressDelegate = nil;
         //(_downloadingRequest);
        
        if (!self.isSuspending) {
            [self startADownload];
        }
    }
}

- (void)releaseToBeDownloadedItemsIfNeeded {
    if (!_toBeDownloadedItems || (_toBeDownloadedItems.count <= 0)) {
         //(_toBeDownloadedItems);
    }
    
    NSArray *_failedItems = [self failedDownloadedItems];
    
     //(_toBeDownloadedItems);
    if (_failedItems.count > 0) {
        _toBeDownloadedItems = [_failedItems mutableCopy];
    }
}

#pragma mark - ZipArchiveDelegate

-(void) FileUnzipped:(NSString*)filePath fromZipArchive:(ZipArchive*)zip {
	if ([filePath length] == 0 || zip == nil) {
		return;
	}
	
	if ([filePath rangeOfString:kNewspaperHomePageFlag].location != NSNotFound) {
        SNDebugLog(@"INFO: %@", filePath);
        _downloadingZipIndexFilePath = filePath;
	}
}


-(void)cancelAllSubObjectFromDownloadClickArray
{
    [_toBeDownloadedItemsFromDownloadClick removeAllObjects];
}

-(void)cancelSubObjectFromDownloadClickArray:(SCSubscribeObject*)aSubObject
{
    if(aSubObject==nil || ![aSubObject isKindOfClass:[SCSubscribeObject class]])
        return;
    
    for(NSInteger i=[_toBeDownloadedItemsFromDownloadClick count]-1; i>=0; i--)
    {
        id object = [_toBeDownloadedItemsFromDownloadClick objectAtIndex:i];
        if(object!=nil && [object isKindOfClass:[SCSubscribeObject class]])
        {
            SCSubscribeObject* item = (SCSubscribeObject*)object;
            if(item.subId!=nil && [item.subId isEqualToString:aSubObject.subId])
                [_toBeDownloadedItemsFromDownloadClick removeObjectAtIndex:i];
        }
    }
}

-(void)getZipUrlFromOfflineIfNeeded:(SCSubscribeObject*)aSubObject
{
    @autoreleasepool {
        
        if(aSubObject!=nil && aSubObject.zipUrl==nil && (aSubObject.termId!=nil || aSubObject.subId!=nil))
        {
            NSMutableDictionary *_downloadingSubIdsAndItemsMap = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *_downloadingTermdsAndItemsMap = [[NSMutableDictionary alloc] init];
            
            NSString* offline = [NSString stringWithFormat:kOffline, [SNUtility getP1]];
            if(aSubObject.termId!=nil && [aSubObject.termId length]>0)
            {
                offline = [NSString stringWithFormat:@"%@&termIds=%@", offline, aSubObject.termId];
                [_downloadingTermdsAndItemsMap setObject:aSubObject forKey:aSubObject.termId];
            }
            else if(aSubObject.subId!=nil && [aSubObject.subId length]>0)
            {
                offline = [NSString stringWithFormat:@"%@&subIds=%@", offline, aSubObject.subId];
                [_downloadingSubIdsAndItemsMap setObject:aSubObject forKey:aSubObject.subId];
            }
            
            NSURL *_url = [NSURL URLWithString:offline];
            SNDownloaderRequest *_latestSubTermIdsRequest = [SNDownloaderRequest requestWithURL:_url];
            SNDebugLog(@"INFO: %@--%@, _url is %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _url);
            [_latestSubTermIdsRequest startSynchronous];
            
            int _responseStatus = [_latestSubTermIdsRequest responseStatusCode];
            NSString *_responseString = [_latestSubTermIdsRequest responseString];
            if((_responseStatus == HttpSucceededResponseStatusCode) && !!_responseString)
            {
                id _rootData =  [NSJSONSerialization JSONObjectWithString:_responseString
                                                                  options:NSJSONReadingMutableLeaves
                                                                    error:NULL];
                if(_rootData!=nil)
                {
                    [self parseTermIdsFromData:_rootData subIdMap:_downloadingSubIdsAndItemsMap termIdMap:_downloadingTermdsAndItemsMap];
                }
            }
             //(_latestSubTermIdsRequest);
             //(_downloadingSubIdsAndItemsMap);
             //(_downloadingTermdsAndItemsMap);
        }
        

    }
}
@end
