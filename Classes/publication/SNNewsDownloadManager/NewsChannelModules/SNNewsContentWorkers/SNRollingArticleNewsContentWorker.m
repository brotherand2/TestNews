//
//  SNRollingNewsContentWorker.m
//  sohunews
//
//  Created by handy wang on 1/9/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNRollingArticleNewsContentWorker.h"
#import "SNArticle.h"
#import "CacheObjects.h"
#import "SNNewsImageFetcher.h"

@implementation SNRollingArticleNewsContentWorker

#pragma mark - Public methods

- (void)startInThread {
    if (_isCanceled) {
        //进行下一个worker
        if ([_myDelegate respondsToSelector:@selector(didFinishWorking:)]) {
            [_myDelegate didFinishWorking:self];
        }
        _myDelegate = nil;
        return;
    }
    
    [self notifyStartingWorking];
    
    SNDebugLog(@"===INFO: Main thread:%d, begin fetching news article ...", [NSThread isMainThread]);

    for (SNNewsContentWorkerNews *_news in _newsArray) {
        if (_isCanceled) {
            break;
        }
        
        NSString *newsId        = _news.newsID;
        NSString *channelId	    = [self channelID];
        SNArticle *article	= [SNArticle newsForDownloadWithNewsId:newsId channelId:channelId paramsDic:nil];
        if (!!article) {
            SNDebugLog(@"===INFO: Main thread:%d, succeed to fetch article content.", [NSThread isMainThread]);
            [self fetchImagesInThreadForArticle:article];
        } else {
            SNDebugLog(@"===INFO: Main thread:%d, rolling news article content existed in local, so neednt resave.", [NSThread isMainThread]);
        }
    }

    //进行下一个worker
    if ([_myDelegate respondsToSelector:@selector(didFinishWorking:)]) {
        [_myDelegate didFinishWorking:self];
    }
    _myDelegate = nil;
}

#pragma mark - 下载Article图片

- (void)fetchImagesInThreadForArticle:(SNArticle *)article {
    
    if (!article || (article.newsImageItems.count <= 0 && article.thumbnailImages.count <= 0)) {
        SNDebugLog(@"===INFO: Main thread:%d, Ignore fetching images for article %@, because there is no images need fetching.", [NSThread isMainThread], article.title);
        return;
    }
    
    SNDebugLog(@"===INFO: Main thread:%d, begin fetching images for a article %@...", [NSThread isMainThread], article.title);
    
    NSMutableArray *_imageURLArray = [NSMutableArray array];
    if (article.thumbnailImages.count > 0) {
        [_imageURLArray addObjectsFromArray:article.thumbnailImages];
    }
    
    if (article.newsImageItems.count > 0) {
        for (NewsImageItem *_newsImageItem in article.newsImageItems) {
            if (!!(_newsImageItem.url) && ![@"" isEqualToString:_newsImageItem.url]) {
                [_imageURLArray addObject:_newsImageItem.url];
            }
        }
    }
    
    if (_imageURLArray.count <= 0) {
        SNDebugLog(@"===INFO: Main thread:%d, Ignore fetching images for article %@, because there is no images need fetching.", [NSThread isMainThread], article.title);
        return;
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, Fetching article %@ images %@ ...", [NSThread isMainThread], article.title, _imageURLArray);
    }
    
    [[SNNewsImageFetcher sharedInstance] setDelegate:self];
    [[SNNewsImageFetcher sharedInstance] fetchImagesInThread:_imageURLArray forNewsContent:article];
}

#pragma mark - 下载某个Article图片完成

- (void)finishedToFetchImagesInThreadForNewsContent:(id)newsContent {
    if ([newsContent isKindOfClass:[SNArticle class]]) {
        SNArticle *_article = (SNArticle *)newsContent;
        SNDebugLog(@"===INFO: Main thread:%d, Finished to fetch images for a article %@.", [NSThread isMainThread], _article.title);
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, Finished to fetch images for a article.", [NSThread isMainThread]);
    }
}

@end
