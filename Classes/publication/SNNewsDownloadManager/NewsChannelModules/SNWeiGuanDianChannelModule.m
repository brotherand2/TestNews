//
//  SNWeiGuanDianChannelModule.m
//  sohunews
//
//  Created by handy wang on 1/8/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNWeiGuanDianChannelModule.h"
#import "NSObject+YAJL.h"
#import "SNWeiboHotDetailContentWorker.h"
#import "NSJSONSerialization+String.h"

#define kWeiGuanDianListStartPageNumber                     (1)

@implementation SNWeiGuanDianChannelModule

#pragma mark - Lifecycle

- (void)dealloc {
    _delegate = nil;
    _weiGuanDianListRequest.delegate = nil;
     //(_weiGuanDianListRequest);
     //(_newsItemArray);
    
}

#pragma mark - Public methods

//Override
- (void)startInThread {
    SNDebugLog(@"===INFO: %@,%@, Main thread:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [NSThread isMainThread]);

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kWeiboListUrl, kWeiGuanDianListStartPageNumber]];
    _weiGuanDianListRequest = [SNASIRequest requestWithURL:url];
    SNDebugLog(@"===INFO: Module start in thread, Fetching WeiGuanDian from %@", [_weiGuanDianListRequest.url absoluteString]);
    [SNASIRequest setShouldUpdateNetworkActivityIndicator:NO];
    [_weiGuanDianListRequest setValidatesSecureCertificate:NO];
    [_weiGuanDianListRequest setTimeOutSeconds:20];
    [_weiGuanDianListRequest setCachePolicy:ASIDoNotReadFromCacheCachePolicy|ASIDoNotWriteToCacheCachePolicy];
    _weiGuanDianListRequest.defaultResponseEncoding = NSUTF8StringEncoding;
    _weiGuanDianListRequest.delegate = self;
    [_weiGuanDianListRequest setValidatesSecureCertificate:NO];
    [_weiGuanDianListRequest startAsynchronous];
    
    [self notifyStartingDownloading];
}

//Override
- (void)cancel {
    [super cancel];
    
    if (!!(_channelName) && ![@"" isEqualToString:_channelName]) {
        SNDebugLog(@"===INFO: Main thread:%d, Canceling fetching %@ channel live news......", [NSThread isMainThread], _channelName);
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, Canceling fetching channel live news......", [NSThread isMainThread]);
    }
    
    [_weiGuanDianListRequest cancel];
    _weiGuanDianListRequest.delegate = nil;
     //(_weiGuanDianListRequest);
     //(_newsItemArray);
}

#pragma mark - 下载某频道RollingNews成功
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    NSString *jsonString = [[request responseString] copy];
    _weiGuanDianListRequest.delegate = nil;
     //(_weiGuanDianListRequest);
    
    id rootData = [NSJSONSerialization JSONObjectWithString:jsonString
                                                    options:NSJSONReadingMutableLeaves
                                                      error:NULL];
     //(jsonString);
    
    SNDebugLog(@"===INFO: Fetched %@ channel WeiGuanDian jsondata : %@, Main thread:%d", _channelName, rootData, [NSThread isMainThread]);
    
    if (rootData && [rootData isKindOfClass:[NSArray class]]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            SNDebugLog(@"===INFO: %@,%@, WeiGuanDian Main thread:%d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [NSThread isMainThread]);
            [self saveDataToDB:rootData];//保存WeiGuanDian以及下载图片
            [self scheduleANewsContentWorkerToWorkInThread];
            //下载下一个频道
            if ([_delegate respondsToSelector:@selector(didFinishDownloadingModule:)]) {
                [_delegate didFinishDownloadingModule:self];
            }
            _delegate = nil;
        });
    } else {
        SNDebugLog(@"===ERROR: Main thread:%d, fetched %@ channel rolling news list jsondata is invalid, and continue fetching next channel.",
                   [NSThread isMainThread], _channelName);
        //下载下一个频道
        if ([_delegate respondsToSelector:@selector(didFinishDownloadingModule:)]) {
            [_delegate didFinishDownloadingModule:self];
        }
        _delegate = nil;
    }
}

- (void)saveDataToDB:(id)rootData {
    NSMutableArray *_newsItemImageArray = [NSMutableArray array];
    
    if (rootData && [rootData isKindOfClass:[NSArray class]]) {
        SNDebugLog(@"===INFO: Main thread:%d, Saving WeiGuanDianData to DB......", [NSThread isMainThread]);     
        NSMutableArray *newItems = [NSMutableArray array];
        for (NSDictionary *weiboItemInfo in rootData) {
            if ([weiboItemInfo isKindOfClass:[NSDictionary class]]) {
                WeiboHotItem *item = [[WeiboHotItem alloc] init];
                item.weiboId = [weiboItemInfo stringValueForKey:@"id" defaultValue:nil];
                item.head = [weiboItemInfo stringValueForKey:@"head" defaultValue:nil];
                item.isVip = [weiboItemInfo stringValueForKey:@"isVip" defaultValue:nil];
                item.nick = [weiboItemInfo stringValueForKey:@"nick" defaultValue:nil];
                item.time = [weiboItemInfo stringValueForKey:@"time" defaultValue:nil];
                item.title = [weiboItemInfo stringValueForKey:@"title" defaultValue:nil];
                item.type = [weiboItemInfo stringValueForKey:@"weiboType" defaultValue:nil];
                item.commentCount = [weiboItemInfo stringValueForKey:@"commentCount" defaultValue:nil];
                item.content = [weiboItemInfo stringValueForKey:@"content" defaultValue:nil];
                item.abstract = [weiboItemInfo stringValueForKey:@"abstract" defaultValue:nil];
                item.focusPic = [weiboItemInfo stringValueForKey:@"focusPic" defaultValue:nil];
                item.weight = [weiboItemInfo stringValueForKey:@"weight" defaultValue:nil];
                item.pageNo = [NSString stringWithFormat:@"%d", 1];
                
                NSArray *userList = [weiboItemInfo objectForKey:@"userList"];
                if (userList && [userList isKindOfClass:[NSArray class]]) {
                    item.userJson = [userList yajl_JSONString];
                }
                
                //---Collect imgae url
                if (!!(item.focusPic) && ![@"" isEqualToString:item.focusPic]) {
                    [_newsItemImageArray addObject:item.focusPic];
                }
                if (!!(item.usersList) && (item.usersList.count > 0)) {
                    for (WeiboHotUserItem *_hotUserItem in item.usersList) {
                        if (!!(_hotUserItem.head) && ![@"" isEqualToString:_hotUserItem.head]) {
                            [_newsItemImageArray addObject:_hotUserItem.head];
                        }
                    }
                }
                //---
                
                [newItems addObject:item];
            }
        }
        
        [[SNDBManager currentDataBase] setWeiboHotItems:newItems withPageNo:1];
        SNDebugLog(@"===INFO: Main thread:%d, Saved WeiGuanDianData to DB......", [NSThread isMainThread]);
        
        if (!newItems || (newItems.count <= 0)) {
            SNDebugLog(@"===INFO: Main thread:%d, Ignore1 fetching images for WeiGuanDian %@, because newsItems is empty.",
                       [NSThread isMainThread], _channelName);
        } else {
             //(_newsItemArray);
            _newsItemArray = newItems;
            
            if (_newsItemImageArray.count <= 0) {
                SNDebugLog(@"===INFO: Main thread:%d, Ignore2 fetching images for WeiGuanDian %@, because newsItems is empty.",
                           [NSThread isMainThread], _channelName);
            } else {
                SNDebugLog(@"===INFO: Main thread:%d, Begin fetching images %@ for WeiGuanDian %@ ...", [NSThread isMainThread], _newsItemImageArray, _channelName);
                [[SNNewsImageFetcher sharedInstance] setDelegate:self];
                [[SNNewsImageFetcher sharedInstance] fetchImagesInThread:_newsItemImageArray forNewsContent:_channelName];
            }
        }
    }
    else {
        SNDebugLog(@"===INFO: Main thread:%d, WeiGuanDian data is empty, so ignore saving WeiGuanDian data to DB.", [NSThread isMainThread]);
    }
    
     //(_newsItemImageArray);
}

- (void)finishedToFetchImagesInThreadForNewsContent:(id)newsContent {
    if ([newsContent isKindOfClass:[NSString class]]) {
        SNDebugLog(@"===INFO: Main thread:%d, Finished fetching images for WeiGuanDian %@.", [NSThread isMainThread], newsContent);
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, Finished fetching images for WeiGuanDian.", [NSThread isMainThread]);
    }
}

#pragma mark - 下载某频道RollingNews失败;
- (void)requestFailed:(ASIHTTPRequest *)request {
    _weiGuanDianListRequest.delegate = nil;
     //(_weiGuanDianListRequest);
    
    SNDebugLog(@"===ERROR: Main thread:%d, failed to fetched %@ channel WeiGuanDian data, and continue fetching next channel.", [NSThread isMainThread], _channelName);
    
    if ([_delegate respondsToSelector:@selector(didFailedToDownloadModule:)]) {
        [_delegate didFailedToDownloadModule:self];
    }
    _delegate = nil;
}

#pragma mark -

- (NSArray *)waitingItems {
    if (!_newsItemArray || (_newsItemArray.count <= 0)) {
        SNDebugLog(@"===INFO: There is no undownloaded rolling news items.");
        return nil;
    }
    
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"isDownloadFinished==0"];//未下载的新闻
    return [_newsItemArray filteredArrayUsingPredicate:_predicate];
}

- (void)scheduleANewsContentWorkerToWorkInThread {
    [super scheduleANewsContentWorkerToWorkInThread];
    
    NSArray *_waitingItems = [self waitingItems];
    if (!_waitingItems || (_waitingItems.count <= 0)) {
         //(_runningNewsContentWorker);
        //Exit Point
        SNDebugLog(@"===INFO: Main thread:%d, ExitPoint, finish downloading %@ channel content.", [NSThread isMainThread], _channelName);
        return;
    }
    
    //更新下载数量
    NSInteger total = [_newsItemArray count];
    NSInteger finish = total - _waitingItems.count;
    if (total>0 && finish>=0 && total>=finish && [_delegate respondsToSelector:@selector(didFinishDownloadingCount:total:)])
        [_delegate didFinishDownloadingCount:finish total:total];
    
    SNDebugLog(@"===INFO: Creating a running content worker for channel %@...", _channelName);
    //注意：虽然下现把新闻分为多类，但是从实际新闻内容接口来看可以合并为：Article新闻(标题，文本，图文，投票新闻)，组图新闻，专题新闻，直播
    WeiboHotItem *_weiboHotItem = [_waitingItems objectAtIndex:0];
    if (!!(_weiboHotItem.weiboId) && ![@"" isEqualToString:_weiboHotItem.weiboId]
        && !!(_weiboHotItem.title) && ![@"" isEqualToString:_weiboHotItem.title]) {
        [self createOrUpdateWeiBoDetailContentWorker:_weiboHotItem];
        _weiboHotItem.isDownloadFinished = YES;
    }
    
    if (!!_runningNewsContentWorker && !_isCanceled)
    {
        SNDebugLog(@"===INFO: Start a running content worker for channel %@...", _channelName);
        [_runningNewsContentWorker startInThread];
    } else {
        SNDebugLog(@"===INFO: Give up start content worker for channel %@ with nil _runningNewsContentWorker.", _channelName);
    }
}

- (void)createOrUpdateWeiBoDetailContentWorker:(WeiboHotItem *)weiboHotItem {
    self.runningNewsContentWorker = [[SNWeiboHotDetailContentWorker alloc] initWithDelegate:self];
    [_runningNewsContentWorker appenNewsID:weiboHotItem.weiboId newsTitle:weiboHotItem.title newsType:nil];
}

//暂停所有下载
-(BOOL)doSuspendIfNeeded
{
    if(!_isSuspending && (_weiGuanDianListRequest!=nil || _runningNewsContentWorker!=nil))
    {
        _isSuspending = YES;
        [_runningNewsContentWorker cancel];
         //(_runningNewsContentWorker);
        [_weiGuanDianListRequest clearDelegatesAndCancel];
         //(_weiGuanDianListRequest);
         //(_newsItemArray);
        return YES;
    }
    
    return NO;
}

//恢复所有下载
-(BOOL)doResumeIfNeeded
{
    if(_isSuspending && _weiGuanDianListRequest==nil)
    {
        _isSuspending = NO;
        [self performSelectorOnMainThread:@selector(startInThread) withObject:nil waitUntilDone:NO];
        return YES;
    }
    
    return NO;
}
@end
