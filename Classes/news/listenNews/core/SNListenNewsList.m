//
//  SNListenNewsList.m
//  sohunews
//
//  Created by weibin cheng on 14-6-16.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNListenNewsList.h"
#import "SNListenNewsDownloader.h"

#import "SNListenNewsDownloaderDelegate.h"

@implementation SNListenNewsItem
@synthesize newsId = _newsId;
@synthesize channelId = _channelId;
@synthesize link = _link;
@synthesize title = _title;

@end

@interface SNListenNewsList ()<SNListenNewsDownloaderDelegate>
{
    NSInteger   currentIndex;
    BOOL        isDownloadFinished;
}

@property (nonatomic, strong) NSArray* newsList;
@property (nonatomic, strong) NSOperationQueue* downloadQueue;

@end

@implementation SNListenNewsList
@synthesize newsList = _newsList;
@synthesize downloadQueue = _downloadQueue;
@synthesize delegate = _delegate;

+ (instancetype)shareInstance
{
    static SNListenNewsList* listenNewsList = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        listenNewsList = [[SNListenNewsList alloc] init];
    });
    return listenNewsList;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        _downloadQueue = [[NSOperationQueue alloc] init];
        [_downloadQueue setMaxConcurrentOperationCount:1];
       // [_downloadQueue setSuspended:YES];
    }
    return self;
}

- (void)dealloc
{
    [_downloadQueue cancelAllOperations];
}

- (NSString*)startDownloadNewsList:(NSArray*)list
{
    isDownloadFinished = NO;
    [self.downloadQueue cancelAllOperations];
//    NSMutableArray *mutableNewslist = [NSMutableArray arrayWithArray:list];
//    for (SNListenNewsItem* item in mutableNewslist) {
//        if ([item.title isEqualToString:@"上次看到这里，点击刷新"] || item.title.length == 0) {
//            [mutableNewslist removeObject:item];
//            break;
//        }
//    }
    self.newsList = [NSArray arrayWithArray:list];
    SNListenNewsItem* item = self.newsList[0];
    currentIndex = 0;
    [self startDownload:item];
    return item.title;
}

- (NSInteger)startDownloadNewsWithIndex:(NSInteger)index
{
    if (index < 0 || index >= self.newsList.count)
        return nil;
    [self.downloadQueue cancelAllOperations];
    
    SNListenNewsItem *item = self.newsList[index];
    currentIndex = index;
    
    //修改NEWSCLIENT-15889: 听新闻的问题
    if ([item.title isEqualToString:@"上次看到这里，点击刷新"] || [item.title isEqualToString:@"展开，继续看今日要闻"]) {
        item = self.newsList[index + 1];
        currentIndex = index + 1;
    }
    
    [self startDownload:item];
    if (item.title == nil) {
        return @"正在语音播放新闻";
    }
    return currentIndex;
}

- (NSInteger)count
{
    return [self.newsList count];
}

- (void)cancelAllDownloader
{
    [self.downloadQueue cancelAllOperations];
}

- (SNListenNewsItem*)itemByIndex:(NSInteger)index
{
    if(index < 0 || index >= self.newsList.count)
        return nil;
    return self.newsList[index];
}

- (void)startDownload:(SNListenNewsItem*)item
{
    if(item.type == SNListenNewsItemNews)
    {
        SNListenNewsDownloader* downloader = [[SNListenNewsDownloader alloc] init];
        downloader.delegate = self;
        downloader.linkParams = [SNUtility parseLinkParams:item.link];
        downloader.newsId = item.newsId;
        downloader.channelId = item.channelId;
        //[_downloadQueue addOperation:downloader];
        
        [downloader main];
    }
    else if (item.type == SNListenNewsItemJoke) {
        
        SNListenNewsDownloader* downloader = [[SNListenNewsDownloader alloc] init];
        downloader.delegate = self;
        downloader.linkParams = [SNUtility parseLinkParams:item.link];
        downloader.newsId = item.newsId;
        downloader.channelId = item.channelId;
        //[_downloadQueue addOperation:downloader];

        [downloader main];
    }
    
}

#pragma mark SNListenNewsDownloaderDelegate
- (void)listenNewsDidFinishedWithContent:(NSString *)content
{
    SNDebugLog(@"------------------------index = %d, bytes = %ld, content = \n%@", currentIndex,[content lengthOfBytesUsingEncoding:NSUTF8StringEncoding],content);
    if(_delegate && [_delegate respondsToSelector:@selector(downloadNewsDidFinished:withContent:)])
        [_delegate downloadNewsDidFinished:currentIndex withContent:content];
    
    //lijian 2017.06.05 预加载功能根本没有用到，反而引起死循环试的加载。
//    //预下载下一条，如果不需要预下载可以注释掉
//    if(currentIndex < self.newsList.count-1 && !isDownloadFinished)
//    {
//        ++currentIndex;
//        SNListenNewsItem* item = self.newsList[currentIndex];
//        [self startDownload:item];
//    }
//    else if(currentIndex == self.newsList.count-1)
//    {
//        isDownloadFinished = YES;
//    }
}

@end
