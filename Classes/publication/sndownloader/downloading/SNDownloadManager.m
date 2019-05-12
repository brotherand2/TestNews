//
//  FKDownloadManager.m
//  FK
//
//  Created by handy wang on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SNDownloadManager.h"
#import "SNDownloaderAlert.h"
#import "CacheObjects.h"
#import "SNDownloadUtil.h"
#import "ZipArchive.h"
#import "CacheDefines.h"
#import "SNDBManager.h"
#import "SNStatusBarMessageCenter.h"
#import "SNDownloadViewController.h"
#import "SNNewsPaperWebController.h"
#import "SNNewsDownloadManager.h"
#import "SNSubDownloadManager.h"

#import "SNNewAlertView.h"

#define kRequestUserInfoKeyPO                                   (@"PO")

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

#define kTmpDownloadingItem                                     (@"kTmpDownloadingItem")
#define kDownloadingRequest                                     (@"kDownloadingRequest")

@interface SNDownloadManager() {
    NetworkStatus _netStatus;
    BOOL _resumeCancelled;
}

@property(nonatomic, strong, readwrite)SNDownloaderRequest *downloadingRequest;

- (void)thereIsNoTasksToDownload;

- (void)doAddDownloadingItem:(NSString *)mysubscribeID;

- (void)prepareStartingDownload:(NSArray *)mysubPOs;

//- (void)batchGetLatestTermIdOfMySubs:(NSArray *)mysubPOs;
//
//- (void)parseTermIdsFromData:(id)data map:(NSDictionary *)map;
//
//- (void)parseOneSub:(id)_subData map:(NSDictionary *)map;

//- (void)parseOneTerm:(id)_paperData intoPO:(SubscribeHomeMySubscribePO *)_po;

- (void)startADownload;

- (void)performDelegateSelector:(SEL)delegateSelector withObject:dataObj;

- (void)performDelegateSelector:(SEL)delegateSelector withObject:(id)dataObj1 withObject:(id)dataObj2;

- (void)didFailedToBatchGetLatestTermId:(NSString *)message;

- (void)requestFailedAnyway:(ASIHTTPRequest *)request message:(NSString *)message;

- (void)doCancelAllDownloadItems;

- (void)excuteCancelAllDownloadItems;

- (void)unzipDownloadedData:(NSDictionary *)userInfo;

- (void)finishedToDownloadAllTasks;

- (void)finishedCancelDownload;

- (void)updateMySubLauncherItemDownloadedStyle:(NSString *)mySubID;

@end


@implementation SNDownloadManager

@synthesize delegate = _delegate;
@synthesize isDownloaderVisible;
@synthesize downloadingItemsForRender = _downloadingItemsForRender;
@synthesize downloadingRequest = _downloadingRequest;
@synthesize isAllFinished = _isAllFinished;


- (id)init {
    if (self = [super init]) {
        _isAllFinished = YES;
        _downloadingItemsForRender = [[NSMutableArray alloc] init];
        _downloadingItems = [[NSMutableArray alloc] init];
        _downloadingQueue = [[ASINetworkQueue alloc] init];
        [_downloadingQueue setShouldCancelAllRequestsOnFailure:NO];
        [_downloadingQueue setDelegate:self];
        [_downloadingQueue setShowAccurateProgress:YES];
        [_downloadingQueue setMaxConcurrentOperationCount:MaxConcurrentDownloadCount];
        [_downloadingQueue go];
        
    }
    return self;
}

+ (SNDownloadManager *)sharedInstance {
    static SNDownloadManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNDownloadManager alloc] init];
    });
    return _sharedInstance;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
     //(_downloadingItemsForRender);
    
     //(_downloadingRequest);
    
    _downloadingItems = nil;
    
    [_downloadingQueue reset];
    _downloadingQueue = nil;
    
}

#pragma mark - Public methods implementation

#pragma mark - Override

- (void)setIsAllFinished:(BOOL)isAllFinishedParam {
    _isAllFinished = isAllFinishedParam;
    [[UIApplication sharedApplication] setIdleTimerDisabled:!_isAllFinished];
}

#pragma mark - 下载指定一期的刊物

/**********************************************************************
 注意：立即下载指定一期刊物
 addingDownloadingItemWith:方法适用于下载确定的某一期刊物。
 场景：在刊物首页，点击下载按钮，此刊物会被单个加入到下载器下载队列；
 **********************************************************************/

- (void)addSpecifiedDownloadingItemImmediatlyWith:(SubscribeHomeMySubscribePO *)poParam {
    
    if (!poParam) {
        return;
    }
    
    //网络是否连通
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_addsub_to_download"), @"") toUrl:nil mode:SNCenterToastModeOnlyText];
    
    NSInteger _tmpCount = _downloadingItems.count;
    
    //Add to be downloading items to _downloadingItems and _downloadingItemsForRender;
    @synchronized(_downloadingItems) {
        SNDebugLog(SN_String("++++++, %@"), _downloadingItemsForRender);
        //没有单个下载过
        if (![self isInDownloadingItemsForRender:poParam.termId]) {
            [_downloadingItemsForRender addObject:poParam]; 
            [_downloadingItems addObject:poParam];
        } 
        //单个下载过，但失败了，所以_downloadingItemsForRender里有，_downloadingItems里没有；
        else if (![self isInDownloadingItems:poParam.termId]) {
            
            for (SubscribeHomeMySubscribePO *_tmpPO in _downloadingItemsForRender) {
                if ([_tmpPO.termId isEqualToString:poParam.termId]) {
                    [_tmpPO setDownloadStatus:SNDownloadWait];
                    break;
                }
            }
            
            [_downloadingItems addObject:poParam];
        }
        SNDebugLog(SN_String("------, %@"), poParam);
    }
    
    //为了让controller有机会刷新cell的title为termName;
    [self performDelegateSelector:@selector(reloadDownloadingTableView) withObject:nil];
    
    if (_isAllFinished) {
        [self performSelectorOnMainThread:@selector(startADownload) withObject:nil waitUntilDone:NO];
    }
    //为了更好的容错能力。
    else {
        //如果在新添加下载项之前的下载队列里已经空了，但是还没有finish说明有bug，这里就容错一下，把isAllFinished设置为YES。然后重新启动下载。
        if (_tmpCount <= 0) {
            self.isAllFinished = YES;
            [self performSelectorOnMainThread:@selector(startADownload) withObject:nil waitUntilDone:NO];
        }
    }
    
}

//此方法暂未在刊物首页的订阅时调用（已与产品确认暂不支持，所以没有开放成public方法）
/**********************************************************************
 注意：指订一期刊物单个下载（下载器在运行则下载，没有运行则不下载等到用户下次点批量下载时再下载）
 addDownloadingItemWhenAddSubInPubHome:方法适用于下载确定一期的刊物。
 场景：在一个未订阅的刊物首页里，点右上角的订阅，如果目前下载器正在下载，那么此刊物会被单个加入到下载器下载队列；
 **********************************************************************/

- (void)addDownloadingItemWhenAddSubInPubHome:(SubscribeHomeMySubscribePO *)poParam {
    if (_isAllFinished) {
        return;
    }
    
    [self addSpecifiedDownloadingItemImmediatlyWith:poParam];
    
}

#pragma mark - 下载最新一期刊物

/**********************************************************************
 注意：立即批量下载最新一期
 addDownloadingItems:方法适用于批量下载最新一期刊物；
 场景：在我的订阅处点下载按钮进行批量下载所有我的订阅最新一期刊物；
**********************************************************************/

- (void)addDownloadingItems:(NSArray *)downloadingItemsParam {
    //网络是否连通
	if (![SNUtility getApplicationDelegate].isNetworkReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    //无下载任务
    if (downloadingItemsParam.count <= 0) {
        [self performSelectorOnMainThread:@selector(thereIsNoTasksToDownload) withObject:nil waitUntilDone:NO];
        [self performDelegateSelector:@selector(noTasksToDownload) withObject:nil];
        return;
    }
    
    //2G、3G网络下进行流量警告
    if ([SNUtility getApplicationDelegate].isWWANNetworkReachable) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"waste_data_bandwidth", @"") cancelButtonTitle:@"取消" otherButtonTitle:NSLocalizedString(@"stop_downloading", @"")];
            [alert show];
            [alert actionWithBlocksCancelButtonHandler:^{
                
            } otherButtonHandler:^{
                [self prepareStartingDownload:downloadingItemsParam];
            }];

        });
        return;
    }
    
    //准备下载新任务
    [self prepareStartingDownload:downloadingItemsParam];
}

//此方法暂未在所有订阅列表的订阅时调用（已与产品确认暂不支持，所以没有开放成public方法）
/**********************************************************************
 注意：最新一期单个下载
 addDownloadingItem:方法适用于单个下载最新一期刊物；
 场景：  在所有订阅列表中，添加订阅一份刊物：
        如果下载器正在下载，那么此刊物会被单个加入到下载器下载队列；
        如果下载器没有正在下载，则不加到下载队列；
 **********************************************************************/

- (void)addDownloadingItem:(NSString *)mysubscribeID {
    if (_isAllFinished) {
        return;
    }
    
    if (!mysubscribeID || [@"" isEqualToString:mysubscribeID]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_failed_to_addsub_to_download"), @"") toUrl:nil mode:SNCenterToastModeWarning];
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self doAddDownloadingItem:mysubscribeID];
    });
}

#pragma mark - Other publics

- (void)removeAllDownloadingItems {
    [self excuteCancelAllDownloadItems];
    if (_downloadingItems && _downloadingItems.count <= 0) {
        [SNNotificationManager removeObserver:self name:kReachabilityChangedNotification object:nil];
        self.isAllFinished = YES;
         //(_downloadingRequest);
    }
    [self performDelegateSelector:@selector(reloadDownloadingTableView) withObject:nil];
    
    SNDebugLog(SN_String("INFO: %@--%@, _downloadingItems is %@, _downloadingItemsForRender is %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), _downloadingItems, _downloadingItemsForRender);
}

- (void)retryDownloadWithItem:(id)itemParam {
    if (_downloadingQueue) {
        NSNumber *_index = [NSNumber numberWithInteger:[_downloadingItemsForRender indexOfObject:itemParam]];
        NSNumber *_downloadStatus = [NSNumber numberWithInt:SNDownloadWait];
        SNDebugLog(SN_String("INFO: %@-%@, Retry download %@ in index %d"), 
                   NSStringFromClass(self.class), NSStringFromSelector(_cmd), [(SubscribeHomeMySubscribePO *)itemParam subName], [_index intValue]);
        
        SubscribeHomeMySubscribePO *_tmpPO = (SubscribeHomeMySubscribePO *)itemParam;
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_retry_a_download"), @"") toUrl:nil mode:SNCenterToastModeWarning];
        
        //用户在所有可下载的刊物下载完后再点“重试”按钮，则直接下载；
        if (_downloadingItems && _downloadingItems.count <= 0) {
            [self performDelegateSelector:@selector(changeToDownloadStatus:forItemIndex:) withObject:_downloadStatus withObject:_index];
            @synchronized(_downloadingItems) {
                [_downloadingItems addObject:itemParam];
            }
            [self performSelectorOnMainThread:@selector(startADownload) withObject:nil waitUntilDone:NO];
        }
        //用户在有正在下载的刊物下载时点“重试”按钮，则只用把要重试下载的项加到_downloadingItems最后面；
        else {
            @synchronized(_downloadingItems) {
                [_downloadingItems addObject:itemParam];
            }
            [(SubscribeHomeMySubscribePO *)itemParam setDownloadStatus:SNDownloadWait];
            [self performDelegateSelector:@selector(changeToDownloadStatus:forItemIndex:) 
                               withObject:_downloadStatus 
                               withObject:_index];
        }
    }
}

- (void)cancelDownloadItem:(id)itemParam {
    
    if (_downloadingQueue) {
        
        //--- 如果是取消正在下载的项，则要先取消正在下载的request；
        SubscribeHomeMySubscribePO *_downloadingPO = [_downloadingRequest.userInfo objectForKey:kRequestUserInfoKeyPO];
        
        SubscribeHomeMySubscribePO *_toBeCanceledPO = (SubscribeHomeMySubscribePO *)itemParam;
        
        if ([_downloadingPO.subId isEqualToString:_toBeCanceledPO.subId]) {
            
            _downloadingPO.isCanceled = YES;
            
            _toBeCanceledPO.isCanceled = YES;
            
            [_downloadingRequest clearDelegatesAndCancel];
             //(_downloadingRequest);

            @synchronized(_downloadingItems) {
                
                if (_downloadingItems) {
                    [_downloadingItems removeObject:itemParam];
                }
                
                if (_downloadingItemsForRender) {
                    [_downloadingItemsForRender removeObject:itemParam];
                }
                
            }
            
            [self finishedCancelDownload];
            
            [self performSelectorOnMainThread:@selector(startADownload) withObject:nil waitUntilDone:NO];
            
        }
        //--- 被取消项不是正在下载项；
        else {
            
            @synchronized(_downloadingItems) {
                if (_downloadingItems) {
                    [_downloadingItems removeObject:itemParam];
                }
                if (_downloadingItemsForRender) {
                    [_downloadingItemsForRender removeObject:itemParam];
                }
            }
            
            [self finishedCancelDownload];

        }
    }
    
}

- (void)cancelAllDownloadItems {
    
//    SNActionSheet *actionSheet = [[SNActionSheet alloc] initWithTitle:NSLocalizedString(SN_String("Cancel"), @"")
//                                                             delegate:self
//                                                            iconImage:[SNUtility chooseActDefaultIconImage]
//                                                              content:NSLocalizedString(SN_String("cancel all downloading subs"), @"")
//                                                           actionType:SNActionSheetTypeDefault
//                                                    cancelButtonTitle:NSLocalizedString(SN_String("no to cancel all"), @"")
//                                               destructiveButtonTitle:nil
//                                                    otherButtonTitles:@[NSLocalizedString(SN_String("yes to cancel all"), @"")]];
//    actionSheet.tag = kCancelAllDownloadAlertViewTag;
//    [[TTNavigator navigator].window addSubview:actionSheet];
//    [actionSheet showActionViewAnimation];
//    [actionSheet release];
//    SNConfirmFloatView* confirmView = [[SNConfirmFloatView alloc] init];
//    confirmView.message = NSLocalizedString(SN_String("cancel all downloading subs"), @"");
//    [confirmView setConfirmText:NSLocalizedString(SN_String("yes to cancel all"), @"") andBlock:^{
//        [self doCancelAllDownloadItems];
//    }];
//    [confirmView show];
    
    SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(SN_String("cancel all downloading subs"), @"") cancelButtonTitle:@"取消" otherButtonTitle:NSLocalizedString(SN_String("yes to cancel all"), @"")];
    [alert show];
    [alert actionWithBlocksCancelButtonHandler:^{
        
    } otherButtonHandler:^{
        [self doCancelAllDownloadItems];
    }];

}

- (BOOL)isDownloaderVisible {
    UIViewController *_vc = [TTNavigator globalNavigator].visibleViewController;
    return [_vc isKindOfClass:[SNDownloadViewController class]];
}

- (void)suspend {
    if (_downloadingQueue) {
        self.isAllFinished = YES;
        _isPaused = YES;
        [_downloadingQueue setSuspended:YES];
        [_downloadingQueue cancelAllOperations];
        if (_downloadingRequest) {
            [SNNotificationManager removeObserver:self name:kReachabilityChangedNotification object:nil];
            [_downloadingRequest clearDelegatesAndCancel];
             //(_downloadingRequest);
        }
//        [[SNStatusBarMessageCenter sharedInstance] hideMessageImmediately];
        [self performDelegateSelector:@selector(reloadDownloadingTableView) withObject:nil];
    }
}

- (void)resume {
    
    if (_downloadingQueue && _isPaused && !_resumeCancelled) {
        
        NSArray* newsArray = [SNNewsDownloadManager sharedInstance].toBeDownloadedItems;
        NSArray* subArray = [SNSubDownloadManager sharedInstance].toBeDownloadedItems;
        if ((newsArray && newsArray.count> 0) || (subArray && subArray.count>0)) {
            _netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
            if (_netStatus == ReachableViaWWAN ||
                _netStatus == ReachableVia2G   ||
                _netStatus == ReachableVia3G   ||
                _netStatus == ReachableVia4G) {
                
//                SNActionSheet *actionSheet = [[SNActionSheet alloc] initWithTitle:NSLocalizedString(@"network_2g_3g", @"")
//                                                                         delegate:self
//                                                                        iconImage:[UIImage imageNamed:@"act_dataflow_notice.png"]
//                                                                          content:NSLocalizedString(@"waste_data_bandwidth", @"")
//                                                                       actionType:SNActionSheetTypeDefault
//                                                                cancelButtonTitle:NSLocalizedString(@"stop_downloading", @"")
//                                                           destructiveButtonTitle:nil
//                                                                otherButtonTitles:@[NSLocalizedString(@"download anyway", @"")]];
//                actionSheet.tag = kWWANetworkResumeAlertViewTag;
//                [[TTNavigator navigator].window addSubview:actionSheet];
//                [actionSheet showActionViewAnimation];
//                [actionSheet release];
//                return;
//                SNConfirmFloatView* confirmView = [[SNConfirmFloatView alloc] init];
//                confirmView.message = NSLocalizedString(@"waste_data_bandwidth", @"");
//                [confirmView setConfirmText:NSLocalizedString(@"stop_downloading", @"") andBlock:^{
//                    [self doResume];
//                }];
//                [confirmView show];
                SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"waste_data_bandwidth", @"") cancelButtonTitle:@"取消" otherButtonTitle:NSLocalizedString(@"stop_downloading", @"")];
                [alert show];
                [alert actionWithBlocksCancelButtonHandler:^{
                    
                } otherButtonHandler:^{
                    [self doResume];
                }];

                return;
            }
        }
        
        [self doResume];
    }
}

- (void)doResume {
    if (_downloadingQueue && _isPaused) {
        _isPaused = NO;
        _resumeCancelled = NO;
        [_downloadingQueue setSuspended:NO];
        [self performSelectorOnMainThread:@selector(startADownload) withObject:nil waitUntilDone:NO];
    }
}


#pragma mark -
#pragma mark SNActionSheetDelegate

- (void)actionSheet:(SNActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //非wifi网络提醒
    if (actionSheet.tag == kWWANNetworkReachAlertViewTag) {
        //如果用户点“继续下载”
        if (buttonIndex == 1) {
            if (actionSheet.userInfo) {
                [self prepareStartingDownload:[actionSheet.userInfo objectForKey:kToBeDownloadingData]];
            }
        }
    }
    //取消全部下载提醒
    else if (actionSheet.tag == kCancelAllDownloadAlertViewTag) {
        //如果用户点“是”
        if (buttonIndex == 1) {
            [self doCancelAllDownloadItems];
        }
    } else if (actionSheet.tag == kNetworkStatusChangedAlertViewTag) {
        if (buttonIndex == 1) {
            [self doResume];
        } else {
            [self doCancelAllDownloadItems];
        }
    } else if (actionSheet.tag == kWWANetworkResumeAlertViewTag) {
        if (buttonIndex == 1) {
            [self doResume];
        } else {
            _resumeCancelled = YES;
            [self doCancelAllDownloadItems];
        }
    }
}


#pragma mark - Private methods implementation

- (void)thereIsNoTasksToDownload {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"nothing to download", @"") toUrl:nil mode:SNCenterToastModeOnlyText];
}

- (void)doAddDownloadingItem:(NSString *)mysubscribeID {
    @autoreleasepool {
        
        SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:mysubscribeID];
        SubscribeHomeMySubscribePO *_mySub = [subObj toSubscribeHomeMySubscribePO];
        if (_mySub) {
            [self performSelectorOnMainThread:@selector(addDownloadingItems:) withObject:[NSArray arrayWithObject:_mySub] waitUntilDone:NO];
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_failed_to_addsub_to_download"), @"") toUrl:nil mode:SNCenterToastModeWarning];
        }
        
    }
}

- (void)prepareStartingDownload:(NSArray *)mysubPOs {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_addsub_to_download"), @"") toUrl:nil mode:SNCenterToastModeWarning];
    
    //获取待下载我的订阅的最新一期termId;
    //这样做的目的是为了防止：刊物首页(HomeV3接口)长时间不刷新但后台服务器已发布了订阅刊物的最新一期或几期，如果直接用我的订阅里的termId那么下载的数据并不是最新的，所有要从服务器获取已订阅刊物的最新一期termId
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self batchGetLatestTermIdOfMySubs:mysubPOs];
    });
}

- (void)batchGetLatestTermIdOfMySubs:(NSArray *)mysubPOs {
    @autoreleasepool {
        if (mysubPOs && mysubPOs.count > 0) {
            /**
             * 这个Dictionary的作用：一次性取回所有我的订阅的最新一期历史后，批量的按mysubPOs中对象顺序给各个对象设上最新一期的termId、termTime和termName;
             */
            NSMutableDictionary *_downloadingSubIdsAndItemsMap = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *_downloadingTermdsAndItemsMap = [[NSMutableDictionary alloc] init];
            
            //缓存一下我的订阅ID和我的订阅映射关系，拼接我的订阅id
            NSMutableString *_tmpSubIds = [[NSMutableString alloc] init];
            NSMutableString *_tmpTermIds = [[NSMutableString alloc] init];
            for (SubscribeHomeMySubscribePO *_tmpDownloadingItem in mysubPOs) {
                //把我订阅数据缓存到Dictionary里，后面获取到所有我的订阅最新期号时会用到
                if(_tmpDownloadingItem.termId!=nil && [_tmpDownloadingItem.termId length]>0)
                    [_downloadingTermdsAndItemsMap setObject:_tmpDownloadingItem forKey:_tmpDownloadingItem.termId];
                else if(_tmpDownloadingItem.subId!=nil && [_tmpDownloadingItem.subId length]>0)
                    [_downloadingSubIdsAndItemsMap setObject:_tmpDownloadingItem forKey:_tmpDownloadingItem.subId];
                
                //拼接我的订阅id
                if ([mysubPOs indexOfObject:_tmpDownloadingItem] > 0) {
                    if(_tmpDownloadingItem.termId!=nil && [_tmpDownloadingItem.termId length]>0)
                        [_tmpTermIds appendFormat:SN_String(",%@"), _tmpDownloadingItem.termId];
                    else if(_tmpDownloadingItem.subId!=nil && [_tmpDownloadingItem.subId length]>0)
                        [_tmpSubIds appendFormat:SN_String(",%@"), _tmpDownloadingItem.subId];
                }
                else
                {
                    if(_tmpDownloadingItem.termId!=nil && [_tmpDownloadingItem.termId length]>0)
                        [_tmpTermIds appendFormat:SN_String("%@"), _tmpDownloadingItem.termId];
                    else if(_tmpDownloadingItem.subId!=nil && [_tmpDownloadingItem.subId length]>0)
                        [_tmpSubIds appendFormat:SN_String("%@"), _tmpDownloadingItem.subId];
                }
            }
            
            //发起我的订阅最近5期的查询请求(5条是接口服务器限制的)
            //NSURL *_url = [NSURL URLWithString:[NSString stringWithFormat:kInputBox, _tmpSubIds]];
            //3.4 服务端发布offline接口替掉原来的Inputbox接口
            NSString* offline = [NSString stringWithFormat:kOffline, [SNUtility getP1]];
            if([_tmpSubIds length]>0) offline = [NSString stringWithFormat:@"%@&subIds=%@", offline, _tmpSubIds];
            if([_tmpTermIds length]>0) offline = [NSString stringWithFormat:@"%@&termIds=%@", offline, _tmpTermIds];
            NSURL *_url = [NSURL URLWithString:offline];
            
            SNDownloaderRequest *_latestSubTermIdsRequest = [SNDownloaderRequest requestWithURL:_url];
            _tmpSubIds = nil;
            
            SNDebugLog(SN_String("INFO: %@--%@, _url is %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), _url);
            [_latestSubTermIdsRequest startSynchronous];
            int _responseStatus = [_latestSubTermIdsRequest responseStatusCode];
            NSData *_responseData = [_latestSubTermIdsRequest responseData];
            if ((_responseStatus == HttpSucceededResponseStatusCode) && _responseData) {
                id _rootData = [SNDownloadUtil makeUncompressedJsonToObject:_responseData];
                if (!_rootData) {
                    SNDebugLog(SN_String("ERROR: %@--%@, %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), [[_latestSubTermIdsRequest error] localizedDescription]);
                    
                    [self didFailedToBatchGetLatestTermId:[NSString stringWithString:SN_String("Failed to parse json data from rootData.")]];
                } else {
                    [self parseTermIdsFromData:_rootData subIdMap:_downloadingSubIdsAndItemsMap termIdMap:_downloadingTermdsAndItemsMap];
                     //(_downloadingSubIdsAndItemsMap);
                     //(_downloadingTermdsAndItemsMap);
                    
                    NSInteger _tmpCount = _downloadingItems.count;
                    
                    //Add to be downloading items to _downloadingItems and _downloadingItemsForRender;
                    @synchronized(_downloadingItems) {
                        for (SubscribeHomeMySubscribePO *_tmpPO in mysubPOs) {
                            if (![self isInDownloadingItemsForRender:_tmpPO.termId]) {
                                [_downloadingItemsForRender addObject:_tmpPO];
                                [_downloadingItems addObject:_tmpPO];
                            }
                            else if (![self isInDownloadingItems:_tmpPO.termId]) {
                                [_downloadingItems addObject:_tmpPO];
                            }
                        }
                    }
                    
                    //为了让controller有机会刷新cell的title为termName;
                    [self performDelegateSelector:@selector(reloadDownloadingTableView) withObject:nil];
                    
                    if (_isAllFinished) {
                        
                        [self performSelectorOnMainThread:@selector(startADownload) withObject:nil waitUntilDone:NO];
                        
                    }
                    //为了更好的容错能力。预防_isAllFinished没有完成，但是实际上在追加到_downloadingItems里时_downloadingItems已经空了。
                    else {
                        
                        if (_tmpCount <= 0) {
                            
                            self.isAllFinished = YES;
                            
                            [self performSelectorOnMainThread:@selector(startADownload) withObject:nil waitUntilDone:NO];
                            
                        }
                        
                    }
                }
            }
            else {
                SNDebugLog(SN_String("ERROR: %@--%@, %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), [[_latestSubTermIdsRequest error] localizedDescription]);
                
                [self didFailedToBatchGetLatestTermId:[NSString stringWithString:SN_String("Failed to parse json data from rootData.")]];
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
            SubscribeHomeMySubscribePO *_po = [map objectForKey:_subId];
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

- (void)parseOneTerm:(id)_paperData intoPO:(SubscribeHomeMySubscribePO *)_po {
    if (_paperData && [_paperData isKindOfClass:[NSDictionary class]]) {
        SNDebugLog(SN_String("INFO: mysub %@ before setting termId and termTime is %@"), [_po subName], [_po toString]);
        NSDictionary *_paper = (NSDictionary *)_paperData;
        //termId
        NSString *_termId = [_paper objectForKey:ktermId];
        if (_termId) {
            _po.termId = [_termId URLDecodedString];
        }
        
        //termTime
        NSString *_termTime = [_paper objectForKey:ktermTime];
        if (_termTime) {
            _po.termTime = [_termTime URLDecodedString];
        }
        
        //termName
        NSString *_termName = [_paper objectForKey:ktermName];
        if (_termName) {
            _po.termName = [_termName URLDecodedString];
        }
        SNDebugLog(SN_String("INFO: mysub %@ after setting termId and termTime is %@"), [_po subName], [_po toString]);
    }    
}*/

- (void)startADownload {

    if (_downloadingItems && _downloadingItems.count > 0) {
        //检测网络状态变化，从wifi变为2/3G时给予提示
        _resumeCancelled = NO;
        _netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
        [SNNotificationManager addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

        self.isAllFinished = NO;
        SubscribeHomeMySubscribePO *_tmpDownloadingItem = [_downloadingItems objectAtIndex:0];
        NSString *_tmpDownloadingURLString = [SNUtility addParamP1ToURL:_tmpDownloadingItem.zipUrl];
        //NSString *_tmpDownloadingURLString = [SNUtility addParamP1ToURL:[NSString stringWithFormat:kUrlTermZip, _tmpDownloadingItem.termId]];
        NSURL *_tmpDownloadingURL = [NSURL URLWithString:_tmpDownloadingURLString];
        SNDebugLog(SN_String("INFO: %@--%@, Ready to download item %@ from url [%@]"), 
                   NSStringFromClass(self.class), NSStringFromSelector(_cmd), [_tmpDownloadingItem toString], _tmpDownloadingURL);
        self.downloadingRequest = [SNDownloaderRequest requestWithURL:_tmpDownloadingURL];
        _downloadingRequest.delegate = self;
        _downloadingRequest.downloadProgressDelegate = self;
        _downloadingRequest.allowResumeForFileDownloads = YES;
        _downloadingRequest.showAccurateProgress = YES;
        _downloadingRequest.validatesSecureCertificate = NO;
        _downloadingRequest.temporaryFileDownloadPath = [SNDownloadConfig temporaryFileDownloadPathWithURL:[[_downloadingRequest url] absoluteString]];
        _downloadingRequest.downloadDestinationPath = [SNDownloadConfig downloadDestinationPathWithURL:[[_downloadingRequest url] absoluteString]];
        _tmpDownloadingItem.tmpDownloadZipPath = _downloadingRequest.temporaryFileDownloadPath;
        _tmpDownloadingItem.finalDownloadZipPath = _downloadingRequest.downloadDestinationPath;
        [_downloadingRequest setUserInfo:[NSDictionary dictionaryWithObject:_tmpDownloadingItem forKey:kRequestUserInfoKeyPO]];
        [_downloadingQueue addOperation:_downloadingRequest];
    } else {
        self.isAllFinished = YES;
        [SNNotificationManager removeObserver:self name:kReachabilityChangedNotification object:nil];
    }
    SNDebugLog(SN_String("INFO: %@--%@, _downloadingItems count is %d"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), _downloadingItems.count);
}

- (void)performDelegateSelector:(SEL)delegateSelector withObject:(id)dataObj {
    [self performDelegateSelector:delegateSelector withObject:dataObj withObject:nil];
}

- (void)performDelegateSelector:(SEL)delegateSelector withObject:(id)dataObj1 withObject:(id)dataObj2 {
    if (!_delegate || !self.isDownloaderVisible) {
        return;
    }
    if ([_delegate respondsToSelector:delegateSelector]) {
        SEL _selector = delegateSelector;
        //获得类和方法的签名 
        NSMethodSignature *_methodSignature = [[_delegate class] instanceMethodSignatureForSelector:_selector];
        //从签名获得调用对象 
        NSInvocation *_invocation = [NSInvocation invocationWithMethodSignature:_methodSignature]; 
        //设置target
        [_invocation setTarget:_delegate]; 
        //设置selector
        [_invocation setSelector:_selector];
        if (dataObj1) {
            __unsafe_unretained id _dataObj1 = dataObj1;
            __unsafe_unretained id _dataObj2 = dataObj2;
            //设置参数，第一个参数index为2 
            [_invocation setArgument:&_dataObj1 atIndex:2];
            if (dataObj2) {
                [_invocation setArgument:&_dataObj2 atIndex:3];
            }
        }
        //必须retain一遍参数
        [_invocation retainArguments];
        [_invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:[NSThread isMainThread]];
    }
}

- (void)didFailedToBatchGetLatestTermId:(NSString *)message {
    [SNNotificationManager removeObserver:self name:kReachabilityChangedNotification object:nil];
    [self performDelegateSelector:@selector(didFailedToBatchGetLatestTermId:) withObject:message];
    
    //如果SNNewsPaperWebController可见则立即告知它启动单个下载失败，从而enble下载按钮
    UIViewController *_vc = [TTNavigator globalNavigator].visibleViewController;
    if (_vc && [_vc isKindOfClass:[SNNewsPaperWebController class]]) {
        SNNewsPaperWebController *_newspaperWebController = (SNNewsPaperWebController *)_vc;
        if ([_newspaperWebController respondsToSelector:@selector(didFailStartDownload)]) {
            [_newspaperWebController performSelectorOnMainThread:@selector(didFailStartDownload) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)requestFailedAnyway:(ASIHTTPRequest *)request message:(NSString *)message {
    SubscribeHomeMySubscribePO *_tmpDownloadingItem = [[request userInfo] objectForKey:kRequestUserInfoKeyPO];
    
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_fail_a_download"), @"") toUrl:nil mode:SNCenterToastModeWarning];
    NSInteger _index = [_downloadingItemsForRender indexOfObject:_tmpDownloadingItem];
    NSDictionary *_userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:_index]
                                                          forKey:SN_String("downloading_item_index")];
    NSError *_error = [NSError errorWithDomain:message code:0 userInfo:_userInfo];
    _tmpDownloadingItem.downloadStatus = SNDownloadFail;
    SNDebugLog(SN_String("ERROR: %@--%@, %@, index is %d"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), message , _index);
    [self performDelegateSelector:@selector(requestFailed:error:) withObject:_tmpDownloadingItem withObject:_error];
    [request setDelegate:nil];
    [request setDownloadProgressDelegate:nil];
    [request setUploadProgressDelegate:nil];
    
    //如果SNNewsPaperWebController可见则告知它下载失败，从而enble下载按钮
    UIViewController *_vc = [TTNavigator globalNavigator].visibleViewController;
    if (_vc && [_vc isKindOfClass:[SNNewsPaperWebController class]]) {
        SNNewsPaperWebController *_newspaperWebController = (SNNewsPaperWebController *)_vc;
        if ([_newspaperWebController respondsToSelector:@selector(didFailSingleDownload:)]) {
            [_newspaperWebController performSelectorOnMainThread:@selector(didFailSingleDownload:) withObject:_tmpDownloadingItem waitUntilDone:NO];
        }
    }
}

- (void)doCancelAllDownloadItems {
    //Fixed: 重置状态(在wifi和2G/3G变化时暂停下载时，用户不继续下载。但过一会用户又一键下载时不能却不下载了，所以要设置下面状态。)
    _isPaused = NO;
    [_downloadingQueue setSuspended:NO];
    
    [self excuteCancelAllDownloadItems];
    [self finishedCancelDownload];
}

- (void)excuteCancelAllDownloadItems {

    //取消所有在队列中但没有开始下载的项
    if (_downloadingQueue) {
        
        [_downloadingQueue cancelAllOperations];
        
    }
    
    //取消正在下载的项
    [_downloadingRequest setDelegate:nil];
    [_downloadingRequest setDownloadProgressDelegate:nil];
    [_downloadingRequest setUploadProgressDelegate:nil];
    [_downloadingRequest cancel];
     //(_downloadingRequest);
    
    @synchronized(_downloadingItems) {
        if (_downloadingItems) {
            [_downloadingItems removeAllObjects];
        }
        if (_downloadingItemsForRender) {
            [_downloadingItemsForRender removeAllObjects];
        }
    }
}

- (void)unzipDownloadedData:(NSDictionary *)userInfo {
    @autoreleasepool {
        SubscribeHomeMySubscribePO *_tmpDownloadingItem = [userInfo objectForKey:kTmpDownloadingItem];
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
                
                if (_tmpDownloadingItem.isCanceled) {
                    
                    SNDebugLog(@"INFO: ##### downloading item is canceled while unziping, so cancel unzip.");
                    return;
                }
                
                
                //数据库操作--------------------------------------
                //保存newspaperItem数据到数据库
                NSString *termLinkURL = [NSString stringWithFormat:kUrlTermPaper, _tmpDownloadingItem.termId];
                NSString *zipURL = _tmpDownloadingItem.zipUrl;
                //NSString *zipURL = [NSString stringWithFormat:kUrlTermZip, _tmpDownloadingItem.termId];
                NewspaperItem *_downloadingNewspaper       = [[NewspaperItem alloc] init];
                _downloadingNewspaper.subId     = _tmpDownloadingItem.subId;
                _downloadingNewspaper.pubId     = _tmpDownloadingItem.pubIds;
                _downloadingNewspaper.termId	= _tmpDownloadingItem.termId;
                NSString *_tmpTermName = _tmpDownloadingItem.termName;
                _downloadingNewspaper.termName  = (!!_tmpTermName && ![@"" isEqualToString:_tmpTermName]) ? _tmpTermName : _tmpDownloadingItem.subName;
                _downloadingNewspaper.pushName  = _tmpDownloadingItem.pushName;
                _downloadingNewspaper.termLink	= termLinkURL;
                _downloadingNewspaper.termZip	= zipURL;
                _downloadingNewspaper.termTime  = _tmpDownloadingItem.termTime;
                _downloadingNewspaper.readFlag  = SN_String("0");
                
                if (!(_tmpDownloadingItem.isCanceled)) {
                    _downloadingNewspaper.downloadFlag = SN_String("1");
                } else {
                    _downloadingNewspaper.downloadFlag = SN_String("0");
                }
                
                _downloadingNewspaper.downloadTime = [NSString stringWithFormat:SN_String("%lf"), [(NSDate *)[NSDate date] timeIntervalSince1970]];
                
                
                //获得到了newspaper首页的html决对路径
                if (_downloadingZipIndexFilePath && !(_tmpDownloadingItem.isCanceled)) {
                    
                    SNDebugLog(@"%@", _downloadingZipIndexFilePath);
                    
                    _downloadingNewspaper.newspaperPath = [[SNDownloadConfig downloadDestinationDir] stringByAppendingPathComponent:_downloadingZipIndexFilePath];
                    _downloadingZipIndexFilePath = nil;
                    
                    if ([[SNDBManager currentDataBase] addSingleNewspaper:_downloadingNewspaper]) {
                        
                        if (!(_tmpDownloadingItem.isCanceled)) {
                            
                            
#if USE_NEW_SUBCENTER
                            
                            SCSubscribeObject *subObj = [[SNDBManager currentDataBase] getSubscribeCenterSubscribeObjectBySubId:_tmpDownloadingItem.subId];
                            
                            // 只有最新一期时才更新我的订阅图标的已下载状态
                            BOOL bChangeStatus = NO;
                            if ([subObj.termId isEqualToString:_downloadingNewspaper.termId]) {
                                bChangeStatus = [subObj setStatusValue:[KHAD_BEEN_OFFLINE intValue] forFlag:SCSubObjStatusFlagSubStatus];
                            }
                            subObj.isDownloaded = kHAD_DOWNLOADED;
                            
                            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:NO];
                            
                            if (bChangeStatus) {
                                NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:subObj.subId, @"subId", subObj.status, @"status", nil];
                                [SNNotificationManager postNotificationName:kSubscribeObjectStatusChangedNotification object:nil userInfo:dict];
                            }
                            
#else
                            //更新我的订阅的已下载状态(注意：这里不能更新termId，因为如果下载了一个往期刊物后，
                            //termId就是往期那一期的termId，导致在我的订阅里打开这个刊物时，只能打开刚下载这一期，就是因为termId是过去的一期)
                            NSMutableDictionary *valuePairs = [NSMutableDictionary dictionary];
                            //                        [valuePairs setObject:[_tmpDownloadingItem termId] forKey:TB_SUBSCRIBE_TERMID];
                            [valuePairs setObject:kHAD_DOWNLOADED forKey:TB_SUBSCRIBE_DOWNLOADED];
                            [valuePairs setObject:KHAD_BEEN_OFFLINE forKey:TB_SUBSCRIBE_STATUS];
                            [[SNDBManager currentDataBase] updateSubHomeMySubscribePOBySubId:_tmpDownloadingItem.subId withValuePairs:valuePairs];
#endif
                        }
                        
                        //---
                        NSInteger _index = [_downloadingItemsForRender indexOfObject:_tmpDownloadingItem];
                        
                        //只有下载成功后，用行显示的数组才移除刚才下载的项。
                        @synchronized(_downloadingItemsForRender) {
                            [_downloadingItemsForRender removeObject:_tmpDownloadingItem];
                        }
                        
                        _tmpDownloadingItem.downloadStatus = SNDownloadSuccess;
                        
                        SNDebugLog(SN_String("%@--%@, totalBytesRead is %lld, totalBytes is %lld, index is %d"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), [request totalBytesRead], ([request contentLength]+[request partialDownloadSize]), _index);
                        
                        if (_tmpDownloadingItem.isCanceled == NO) {
                            [[SNCenterToast shareInstance] showCenterToastWithTitle:[NSString stringWithFormat:NSLocalizedString(SN_String("sbm_finish_a_download"), @""), _tmpDownloadingItem.subName] toUrl:nil mode:SNCenterToastModeSuccess];
                            [self performDelegateSelector:@selector(requestFinished:downloadingItemIndex:) withObject:_tmpDownloadingItem withObject:[NSNumber numberWithInteger:_index]];
                            
                        } else {
                            
                            SNDebugLog(@"INFO: ++++++ downloading item is canceled while unziping, so cancel unzip.");
                            
                        }
                        
                        
                        //如果SNNewsPaperWebController可见则在SNNewsPaperWebController里判断打开的刊物是否是正在下载的刊物，从而disable下载按钮
                        UIViewController *_vc = [TTNavigator globalNavigator].visibleViewController;
                        if (_vc && [_vc isKindOfClass:[SNNewsPaperWebController class]] && !(_tmpDownloadingItem.isCanceled)) {
                            SNNewsPaperWebController *_newspaperWebController = (SNNewsPaperWebController *)_vc;
                            if ([_newspaperWebController respondsToSelector:@selector(didSucceedSingleDownload:)]) {
                                [_newspaperWebController performSelectorOnMainThread:@selector(didSucceedSingleDownload:) withObject:_tmpDownloadingItem waitUntilDone:NO];
                            }
                        }
                        
                        if (!(_tmpDownloadingItem.isCanceled)) {
                            //更新对应的我的订阅LauncherItem的样式为“已离线”
                            [self performSelectorOnMainThread:@selector(updateMySubLauncherItemDownloadedStyle:)
                                                   withObject:_tmpDownloadingItem.subId waitUntilDone:NO];
                        }
                        
                    }
                    else {
                        
                        SNDebugLog(SN_String("INFO:############## %@--%@, Fail......"), NSStringFromClass(self.class), NSStringFromSelector(_cmd));
                        
                        [self requestFailedAnyway:request message:
                         [NSString stringWithFormat:SN_String("Failed to add data to database after unzip file, subName %@, subId %@. "), _tmpDownloadingItem.subName, _tmpDownloadingItem.subId]
                         ];
                        
                    }
                    
                }
                //没有获得到了newspaper首页的html决对路径
                else {
                    
                    SNDebugLog(SN_String("INFO:XXXXXXXXXXXXXXX %@--%@, Fail......"), NSStringFromClass(self.class), NSStringFromSelector(_cmd));
                    
                    [self requestFailedAnyway:request message:
                     [NSString stringWithFormat:SN_String("Failed to get newspaper's index file path, subName %@, subId %@. "), _tmpDownloadingItem.subName, _tmpDownloadingItem.subId]
                     ];
                    
                }
                 //(_downloadingNewspaper);
            }
        }
        
        [zip UnzipCloseFile];
        zip.delegate = nil;
         //(zip);
        
        //打开zip失败或解压失败则删除数据包
        if (!unzipSucceed) {
            
            SNDebugLog(SN_String("ERROR: Failed to open zip file %@"), [_tmpDownloadingItem finalDownloadZipPath]);
            
            NSFileManager *_fm = [NSFileManager defaultManager];
            NSString *_tmpDownloadFilePath = [_tmpDownloadingItem tmpDownloadZipPath];
            NSString *_destDownloadFilePath = [_tmpDownloadingItem finalDownloadZipPath];
            if ([_fm fileExistsAtPath:_tmpDownloadFilePath]) {
                [_fm removeItemAtPath:_tmpDownloadFilePath error:nil];
            }
            if ([_fm fileExistsAtPath:_destDownloadFilePath]) {
                [_fm removeItemAtPath:_destDownloadFilePath error:nil];
            }
            
            SNDebugLog(SN_String("INFO:@@@@@@@@@@@@@@@@@@ %@--%@, Fail......"), NSStringFromClass(self.class), NSStringFromSelector(_cmd));
            
            [self requestFailedAnyway:request message:[NSString stringWithFormat:SN_String("Failed to unzip file, sub name %@, sub id %@. "), [_tmpDownloadingItem subName], [_tmpDownloadingItem subId]]];
            
        }
        
        //无论下载成功与否，都要从_downloadingItems移除下载项；
        @synchronized(_downloadingItems) {
            [_downloadingItems removeObject:_tmpDownloadingItem];
        }
        
        [request setDelegate:nil];
        [request setDownloadProgressDelegate:nil];
        [request setUploadProgressDelegate:nil];
        
        userInfo = nil;
        
        if (!(_tmpDownloadingItem.isCanceled)) {
            
            [self performSelectorOnMainThread:@selector(startADownload) withObject:nil waitUntilDone:NO];
            
        }
        
        [self finishedToDownloadAllTasks];
    }
}

- (void)finishedToDownloadAllTasks {
    SNDebugLog(SN_String("INFO: %@--%@, _downloadingItems count is %d, _downloadingItemsForRender count is %d"), 
               NSStringFromClass(self.class), NSStringFromSelector(_cmd), _downloadingItems.count, _downloadingItemsForRender.count);
    if (_downloadingItems && _downloadingItems.count <= 0) {
        [SNNotificationManager removeObserver:self name:kReachabilityChangedNotification object:nil];
        
        SNDebugLog(SN_String("INFO: %@--%@, Finished to download all tasks."), NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        
        if (_downloadingItemsForRender && _downloadingItemsForRender.count > 0) {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_finish_all_downloads_but_somefailed"), @"") toUrl:nil mode:SNCenterToastModeWarning];
        } else {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_finish_all_downloads"), @"") toUrl:nil mode:SNCenterToastModeWarning];
        }
        
        self.isAllFinished = YES;
         //(_downloadingRequest);
        [self performDelegateSelector:@selector(reloadDownloadingTableView) withObject:nil];
    }
}

- (void)finishedCancelDownload {

    SNDebugLog(SN_String("INFO: %@--%@, _downloadingItems is %@, _downloadingItemsForRender is %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), _downloadingItems, _downloadingItemsForRender);
    
    if (_downloadingItems && _downloadingItems.count <= 0) {
        [SNNotificationManager removeObserver:self name:kReachabilityChangedNotification object:nil];
        self.isAllFinished = YES;
         //(_downloadingRequest);
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_finish_cancel_all_downloads"), @"") toUrl:nil mode:SNCenterToastModeOnlyText];
    }
    
    [self performDelegateSelector:@selector(reloadDownloadingTableView) withObject:nil];
    
}

- (void)updateMySubLauncherItemDownloadedStyle:(NSString *)mySubID {
    //[[SNUtility getApplicationDelegate].subHomeController updateMySubLauncherItemDownloadedStyle:mySubID];
}

- (BOOL)isInDownloadingItemsForRender:(NSString *)termIdPram {
    
    @synchronized(_downloadingItemsForRender) {
    
        if (!termIdPram || [@"" isEqualToString:termIdPram]) {
            return NO;
        }
        
        for (SubscribeHomeMySubscribePO *_tmpPO in _downloadingItemsForRender) {
            if ([_tmpPO.termId isEqualToString:termIdPram]) {
                return YES;
            }
        }
        return NO;
        
    }
}

- (BOOL)isInDownloadingItems:(NSString *)termIdParam {
    
    @synchronized(_downloadingItems) {
    
        if (!termIdParam || [@"" isEqualToString:termIdParam]) {
            return NO;
        }
        
        for (SubscribeHomeMySubscribePO *_tmpPO in _downloadingItems) {
            if ([_tmpPO.termId isEqualToString:termIdParam]) {
                return YES;
            }
        }
        return NO;
        
    }
}

#pragma mark - ASIProgressDelegate

////有多大的数据需要下载 
//- (void)request:(ASIHTTPRequest *)theRequest incrementDownloadSizeBy:(long long)newLength {
//    SubscribeHomeMySubscribePO *_tmpDownloadingItem = [[theRequest userInfo] objectForKey:kRequestUserInfoKeyPO];
//    SNDebugLog(SN_String("INFO: %@--%@, Downloading item %@ size %lld bytes."), NSStringFromClass(self.class), NSStringFromSelector(_cmd), _tmpDownloadingItem.subName, newLength);
//	[self request:theRequest didReceiveBytes:0];
//}
//
////下载中每次接收到数据长度
//- (void)request:(ASIHTTPRequest *)theRequest didReceiveBytes:(long long)newLength {
//    SubscribeHomeMySubscribePO *_tmpDownloadingItem = [[theRequest userInfo] objectForKey:kRequestUserInfoKeyPO];    
//    if ([theRequest totalBytesRead] == 0) {
//        
//    } else if ([theRequest contentLength]+[theRequest partialDownloadSize] > 0) {
//        float progressAmount = (float)(([theRequest totalBytesRead]*1.0)/(([theRequest contentLength]+[theRequest partialDownloadSize])*1.0));
//        progressAmount *= 0.9;
//        int _index = [_downloadingItemsForRender indexOfObject:_tmpDownloadingItem];
//        SNDebugLog(SN_String("INFO: %@--%@, DidReceiveBytes %@ size %lld, content length %lld, partialDownloadSize %lld, totalBytesRead %lld, newLength %lld, index is %d"), 
//                   NSStringFromClass(self.class), NSStringFromSelector(_cmd), _tmpDownloadingItem.subName, newLength, [theRequest contentLength], [theRequest partialDownloadSize], 
//                   [theRequest totalBytesRead], newLength, _index);
//        _tmpDownloadingItem.downloadStatus = SNDownloadRunning;
//        _tmpDownloadingItem.tmpProgress = [NSNumber numberWithFloat:progressAmount];
//        
//        [self performDelegateSelector:@selector(updateProgress:downloadingItemIndex:) 
//                           withObject:[NSNumber numberWithFloat:progressAmount] 
//                           withObject:[NSNumber numberWithInt:_index]];
//    }
//}

- (void)setProgress:(float)newProgress {
    SNDebugLog(SN_String("INFO: %@--%@, Downloading progress is [%f]"), 
               NSStringFromClass(self.class), NSStringFromSelector(_cmd), newProgress);
    
    if (!!_downloadingRequest) {
        SubscribeHomeMySubscribePO *_tmpDownloadingItem = [[_downloadingRequest userInfo] objectForKey:kRequestUserInfoKeyPO];
        
        SNDebugLog(SN_String("INFO: %@--%@, Downloading subName:[%@], subID:[%@] progress is [%f]"), 
                   NSStringFromClass(self.class), NSStringFromSelector(_cmd), _tmpDownloadingItem.subName, _tmpDownloadingItem.subId, newProgress);
        
        NSInteger _index = [_downloadingItemsForRender indexOfObject:_tmpDownloadingItem];
        
        [self performDelegateSelector:@selector(updateProgress:downloadingItemIndex:) 
                           withObject:[NSNumber numberWithFloat:(newProgress*0.9)] 
                           withObject:[NSNumber numberWithInteger:_index]];
    }
}

#pragma mark - ASIHTTPRequestDelegate methods implementation

- (void)requestStarted:(ASIHTTPRequest *)request {
    SNDebugLog(SN_String("INFO: %@--%@, Request originalURL is %@, url is %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), [request originalURL], [request url]);
    
    SubscribeHomeMySubscribePO *_tmpDownloadingItem = [[request userInfo] objectForKey:kRequestUserInfoKeyPO];
    
    if (_tmpDownloadingItem.subName && ![@"" isEqualToString:_tmpDownloadingItem.subName]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_downloading"), @"") toUrl:nil mode:SNCenterToastModeOnlyText];
        
    } else {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_downloading_unknown_publication"), @"") toUrl:nil mode:SNCenterToastModeWarning];
    }
    
    _tmpDownloadingItem.downloadStatus = SNDownloadWait;
    SNDebugLog(SN_String("INFO: %@--%@, _downloadingItems count %d, Start download %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), _downloadingItems.count, _tmpDownloadingItem.subName);
    [self performDelegateSelector:@selector(requestStarted:) withObject:_tmpDownloadingItem];
}

/**
 * 对于每一个刊物下载，这个方法会被调两次：
 * 第一次，请求termZip.go接口；
 * 第二次，通过termZip.go接口返回的header 'Location'数据进行重定向请求；
 */
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    
    SubscribeHomeMySubscribePO *_tmpDownloadingItem = [[request userInfo] objectForKey:kRequestUserInfoKeyPO];
    
    int __responseStatusCode = [request responseStatusCode];    
    
    SNDebugLog(SN_String("INFO: %@--%@, Receive responseHeaders %@ \n, %@, status code: %d"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), _tmpDownloadingItem.subName, responseHeaders, __responseStatusCode);
    
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
        SNDebugLog(SN_String("\n\nERROR: %@--%@, Status code is not 200 but %d.\n\n"), 
                   NSStringFromClass(self.class), NSStringFromSelector(_cmd), [request responseStatusCode]);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:request.downloadDestinationPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:request.downloadDestinationPath error:NULL];
        }
        
        SNDebugLog(SN_String("INFO:KKKKKKKKKKKK %@--%@, Fail with http status code %d......"), 
                   NSStringFromClass(self.class), NSStringFromSelector(_cmd), [request responseStatusCode]);
        
        NSString *_msg = [NSString stringWithFormat:SN_String("Failed to download subName %@, subId %@, from %@, termId %@"), 
                          _tmpDownloadingItem.subName, 
                          _tmpDownloadingItem.subId,
                          //[NSURL URLWithString:[NSString stringWithFormat:kUrlTermZip, _tmpDownloadingItem.termId]],
                          [NSURL URLWithString:_tmpDownloadingItem.zipUrl],
                          //[NSString stringWithFormat:kUrlTermZip, _tmpDownloadingItem.termId]
                          _tmpDownloadingItem.zipUrl
                          ];
        
        [self requestFailedAnyway:request message:_msg];
        
        //无论下载成功与否，都要从_downloadingItems移除下载项；
        @synchronized(_downloadingItems) {
            [_downloadingItems removeObject:_tmpDownloadingItem];
        }

        [self performSelectorOnMainThread:@selector(startADownload) withObject:nil waitUntilDone:NO];
        
        [self finishedToDownloadAllTasks];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    SubscribeHomeMySubscribePO *_tmpDownloadingItem = [[request userInfo] objectForKey:kRequestUserInfoKeyPO];

    SNDebugLog(SN_String("INFO: %@--%@, Finish a download %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), _tmpDownloadingItem.subName);
    
    // 因为这里已经到完成方法里，所以只判断是否200
    if(!([request responseStatusCode] >= HttpSucceededResponseStatusCode && [request responseStatusCode] <= 299)){
        if ([[NSFileManager defaultManager] fileExistsAtPath:request.downloadDestinationPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:request.downloadDestinationPath error:NULL];
        }
        SNDebugLog(SN_String("INFO:OOOOOOOOOOOOOO %@--%@, Fail with http status code %d......"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), [request responseStatusCode]);
        NSString *_msg = [NSString stringWithFormat:SN_String("Failed to download subName %@, subId %@, from %@, termId %@"), 
                          _tmpDownloadingItem.subName, 
                          _tmpDownloadingItem.subId,
                          [NSURL URLWithString:_tmpDownloadingItem.zipUrl],
                          _tmpDownloadingItem.zipUrl
                          //[NSURL URLWithString:[NSString stringWithFormat:kUrlTermZip, _tmpDownloadingItem.termId]],
                          //[NSString stringWithFormat:kUrlTermZip, _tmpDownloadingItem.termId]
                          ];
        [self requestFailedAnyway:request message:_msg];
        
        //无论下载成功与否，都要从_downloadingItems移除下载项；
        @synchronized(_downloadingItems) {
            [_downloadingItems removeObject:_tmpDownloadingItem];
        }
        
        [self performSelectorOnMainThread:@selector(startADownload) withObject:nil waitUntilDone:NO];
        
        [self finishedToDownloadAllTasks];
        
    } else {
        //Unzip in thread;
        NSMutableDictionary *_userInfo = [[NSMutableDictionary alloc] init];
        [_userInfo setObject:_tmpDownloadingItem forKey:kTmpDownloadingItem];
        [_userInfo setObject:request forKey:kDownloadingRequest];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self unzipDownloadedData:_userInfo];
        });
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    SubscribeHomeMySubscribePO *_tmpDownloadingItem = [[request userInfo] objectForKey:kRequestUserInfoKeyPO];
    [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(SN_String("sbm_fail_a_download"), @"") toUrl:nil mode:SNCenterToastModeWarning];
    NSInteger _index = [_downloadingItemsForRender indexOfObject:_tmpDownloadingItem];
    NSDictionary *_userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:_index]
                                                          forKey:SN_String("downloading_item_index")];
    NSError *_error = [NSError errorWithDomain:[request error].domain code:[request error].code userInfo:_userInfo];
    SNDebugLog(SN_String("INFO: %@--%@, Failed to download %@ with comming message: %@, index is %d"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), _tmpDownloadingItem.subName, [[request error] localizedDescription], _index);
    [self performDelegateSelector:@selector(requestFailed:error:) withObject:_tmpDownloadingItem withObject:_error];
    _tmpDownloadingItem.downloadStatus = SNDownloadFail;
    
    [_downloadingRequest setDelegate:nil];
    [_downloadingRequest setDownloadProgressDelegate:nil];
    [_downloadingRequest setUploadProgressDelegate:nil];
    [_downloadingRequest cancel];
     //(_downloadingRequest);
    
    //无论下载成功与否，都要从_downloadingItems移除下载项；而_downloadingItemsForRender不能下载失败的项，因为下载失败的项要留在“正在离线”的界面上以供重试下载；
    @synchronized(_downloadingItems) {
        [_downloadingItems removeObject:_tmpDownloadingItem];    
    }
    
    [self performSelectorOnMainThread:@selector(startADownload) withObject:nil waitUntilDone:NO];
    
    [self finishedToDownloadAllTasks];
}

#pragma mark - ZipArchiveDelegate

-(void) FileUnzipped:(NSString*)filePath fromZipArchive:(ZipArchive*)zip {
	if ([filePath length] == 0 || zip == nil) {
		return;
	}
	
	if ([filePath rangeOfString:kNewspaperHomePageFlag].location != NSNotFound) {
        SNDebugLog(SN_String("INFO: %@"), filePath);
        _downloadingZipIndexFilePath = filePath;
	}
}

#pragma mark - Network reachability

- (void)reachabilityChanged:(NSNotification* )note {
    if (self.isAllFinished) {
        [SNNotificationManager removeObserver:self forKeyPath:kReachabilityChangedNotification];
        return;
    }
    
    if (!_isPaused && !self.isAllFinished) {
        
        if (_downloadingItems && _downloadingItems.count > 0) {
            Reachability* curReach = [note object];
            if ([curReach isKindOfClass:[Reachability class]]) {
                NetworkStatus status = [curReach currentReachabilityStatus];
                if (_netStatus == ReachableViaWiFi && (status == ReachableViaWWAN ||
                                                       status == ReachableVia2G  ||
                                                       status == ReachableVia3G  ||
                                                       status == ReachableVia4G)) {
                    // 暂停下载
                    [self suspend];
                    
//                    SNActionSheet *actionSheet = [[SNActionSheet alloc] initWithTitle:NSLocalizedString(@"network_2g_3g", @"")
//                                                                             delegate:self
//                                                                            iconImage:[UIImage imageNamed:@"act_dataflow_notice.png"]
//                                                                              content:NSLocalizedString(@"waste_data_bandwidth", @"")
//                                                                           actionType:SNActionSheetTypeDefault
//                                                                    cancelButtonTitle:NSLocalizedString(@"stop_downloading", @"")
//                                                               destructiveButtonTitle:nil
//                                                                    otherButtonTitles:@[NSLocalizedString(@"download anyway", @"")]];
//                    actionSheet.tag = kNetworkStatusChangedAlertViewTag;
//                    [[TTNavigator navigator].window addSubview:actionSheet];
//                    [actionSheet showActionViewAnimation];
//                    [actionSheet release];
//                    SNConfirmFloatView* confirmView = [[SNConfirmFloatView alloc] init];
//                    confirmView.message = NSLocalizedString(@"waste_data_bandwidth", @"");
//                    [confirmView setConfirmText:NSLocalizedString(@"stop_downloading", @"") andBlock:^{
//                        [self doCancelAllDownloadItems];
//                    }];
//                    confirmView.dismissBlock = ^{
//                        [self doResume];
//                    };
//                    [confirmView show];
                    
                    SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"waste_data_bandwidth", @"") cancelButtonTitle:@"取消" otherButtonTitle:NSLocalizedString(@"stop_downloading", @"")];
                    [alert show];
                    [alert actionWithBlocksCancelButtonHandler:^{
                        [self doResume];
                    } otherButtonHandler:^{
                        [self doCancelAllDownloadItems];

                    }];

                }
            }
        }
    }
}

@end
