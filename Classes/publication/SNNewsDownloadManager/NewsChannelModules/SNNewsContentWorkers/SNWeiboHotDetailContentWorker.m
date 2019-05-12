//
//  SNWeiboHotDetailContentWorker.m
//  sohunews
//
//  Created by handy wang on 2/5/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNWeiboHotDetailContentWorker.h"
//#import "SNWeiboDetailCell.h"
//#import "SNWeiboDetailCommentCell.h"
#import "NSObject+YAJL.h"
#import "NSJSONSerialization+String.h"

@implementation SNWeiboHotDetailContentWorker

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
    
    SNDebugLog(@"===INFO: Main thread:%d, begin fetching weibo hot detail content ...", [NSThread isMainThread]);
    
    for (SNNewsContentWorkerNews *_news in _newsArray) {
        if (_isCanceled) {
            break;
        }
        
        [self fetchWeiboHotDetailContent:_news];
    }
    
    //进行下一个worker
    if ([_myDelegate respondsToSelector:@selector(didFinishWorking:)]) {
        [_myDelegate didFinishWorking:self];
    }
    _myDelegate = nil;
}

#pragma mark -

- (void)fetchWeiboHotDetailContentWithWeiboId:(NSString *)weiboId {
    
    // 先看本地数据库是否有这个weibo数据
    if ([[SNDBManager currentDataBase] getWeiboItemDetailById:weiboId]) {
        return;
    }
    
    SNDebugLog(@"===INFO: Main thread:%d, Begin fetching detail of weibo with id %@ json data...", [NSThread isMainThread], weiboId);
    
    [SNASIRequest setShouldUpdateNetworkActivityIndicator:NO];
    NSString *_urlString = nil;
    NSString *_weiboID = weiboId;
    if (!!_weiboID && ![@"" isEqualToString:_weiboID]) {
        _urlString = [NSString stringWithFormat:kWeiboCommentListUrl, kWeiboDetailModelPageSize, 1, _weiboID, @"1", @"1"];//加载第一页且要加载detail 并且要加载shareRead
    } else {
        SNDebugLog(@"===INFO: Give up fetching weibo detail because weibo id is empty.");
        return;
    }
    
    SNASIRequest *_request = [SNASIRequest requestWithURL:[NSURL URLWithString:_urlString]];
    SNDebugLog(@"===INFO: fetch term weibo detail from url : %@", _request.url.absoluteString);
    [_request setValidatesSecureCertificate:NO];
    [_request setCachePolicy:ASIDoNotReadFromCacheCachePolicy|ASIDoNotWriteToCacheCachePolicy];
    _request.defaultResponseEncoding = NSUTF8StringEncoding;
    [_request setValidatesSecureCertificate:NO];
    [_request startSynchronous];
    
    NSString *jsonString = [_request responseString];
    if (!jsonString || [@"" isEqualToString:jsonString]) {
        SNDebugLog(@"===INFO: Main thread:%d, Got empty for weibo with id %@", [NSThread isMainThread], weiboId);
        return;
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, Got weibo detail with id %@ and jsonstring is:%@", [NSThread isMainThread], weiboId, jsonString);
    }
    
    id root = [NSJSONSerialization JSONObjectWithString:jsonString
                                                options:NSJSONReadingMutableLeaves
                                                  error:NULL];
    if (!root) {
        SNDebugLog(@"===INFO: Main thread:%d, Got empty dic data for weibo detail with id %@", [NSThread isMainThread], weiboId);
        return;
    }
}

- (void)fetchWeiboHotDetailContent:(SNNewsContentWorkerNews *)workerNews {
    SNDebugLog(@"===INFO: Main thread:%d, Begin fetching detail of weibo %@ json data...", [NSThread isMainThread], workerNews.newsTitle);
    
    [SNASIRequest setShouldUpdateNetworkActivityIndicator:NO];
    NSString *_urlString = nil;
    NSString *_weiboID = workerNews.newsID;
    if (!!_weiboID && ![@"" isEqualToString:_weiboID]) {
        _urlString = [NSString stringWithFormat:kWeiboCommentListUrl, kWeiboDetailModelPageSize, 1, _weiboID, @"1", @"1"];//加载第一页且要加载detail 并且要加载shareRead
    } else {
        SNDebugLog(@"===INFO: Give up fetching weibo detail because weibo id is empty.");
        return;
    }
    
    SNASIRequest *_request = [SNASIRequest requestWithURL:[NSURL URLWithString:_urlString]];
    SNDebugLog(@"===INFO: fetch term weibo detail from url : %@", _request.url.absoluteString);
    [_request setValidatesSecureCertificate:NO];
    [_request setCachePolicy:ASIDoNotReadFromCacheCachePolicy|ASIDoNotWriteToCacheCachePolicy];
    _request.defaultResponseEncoding = NSUTF8StringEncoding;
    [_request setValidatesSecureCertificate:NO];
    [_request startSynchronous];
    
    NSString *jsonString = [_request responseString];
    if (!jsonString || [@"" isEqualToString:jsonString]) {
        SNDebugLog(@"===INFO: Main thread:%d, Got empty for weibo detail %@", [NSThread isMainThread], workerNews.newsTitle);
        return;
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, Got weibo detail %@ and jsonstring is:%@", [NSThread isMainThread], workerNews.newsTitle, jsonString);
    }
    
    id root = [NSJSONSerialization JSONObjectWithString:jsonString
                                                options:NSJSONReadingMutableLeaves
                                                  error:NULL];
    if (!root) {
        SNDebugLog(@"===INFO: Main thread:%d, Got empty dic data for weibo detail %@", [NSThread isMainThread], workerNews.newsTitle);
        return;
    }
    
    //Parsing
    if (root) {
        NSMutableArray *_imageURLArray = [NSMutableArray array];
        //Fetch images
        if (_imageURLArray.count > 0) {
            SNDebugLog(@"===INFO: Main  thread:%d, Begin fetching weibo hot detail %@ images : %@...", [NSThread isMainThread], workerNews.newsTitle, _imageURLArray);
            [[SNNewsImageFetcher sharedInstance] setDelegate:self];
            [[SNNewsImageFetcher sharedInstance] fetchImagesInThread:_imageURLArray forNewsContent:workerNews];
        }
        else {
            SNDebugLog(@"===INFO: Main  thread:%d, There is no image need to download for weibo hot detail %@ images...", [NSThread isMainThread], workerNews.newsTitle);
        }
    }
}

- (WeiboHotItemDetail *)parseWeiboHotItem:(NSDictionary *)root {
    WeiboHotItemDetail *item = [[WeiboHotItemDetail alloc] init];
    item.weiboId = [root stringValueForKey:@"id" defaultValue:nil];
    item.head = [root stringValueForKey:@"head" defaultValue:nil];
    item.homeUrl = [root stringValueForKey:@"homeUrl" defaultValue:nil];
    item.wapUrl = [root stringValueForKey:@"wapUrl" defaultValue:nil];
    item.isVip = [root stringValueForKey:@"isVip" defaultValue:nil];
    item.nick = [root stringValueForKey:@"nick" defaultValue:nil];
    item.time = [root stringValueForKey:@"time" defaultValue:nil];
    item.title = [root stringValueForKey:@"title" defaultValue:nil];
    item.weiboType = [root stringValueForKey:@"weiboType" defaultValue:nil];
    item.commentCount = [root stringValueForKey:@"commentCount" defaultValue:nil];
    item.content = [root stringValueForKey:@"content" defaultValue:nil];
    item.newsId = [root stringValueForKey:@"newsId" defaultValue:nil];
    item.shareContent = [root stringValueForKey:@"shareContent" defaultValue:nil];
    item.resourceJSON = [[root arrayValueForKey:@"resourceList" defaultValue:nil] yajl_JSONString];
    NSArray *resourceArr = [root arrayValueForKey:@"resourceList" defaultValue:nil];
    if (resourceArr) {
        item.resourceList = resourceArr;
    }
    
    return item;
}

- (WeiboHotCommentItem *)parseWeiboHotCommentItem:(NSDictionary *)root {
    WeiboHotCommentItem *item = [[WeiboHotCommentItem alloc] init];
    item.commentId = [root stringValueForKey:@"id" defaultValue:nil];
    item.head = [root stringValueForKey:@"head" defaultValue:nil];
    item.isVip = [root stringValueForKey:@"isVip" defaultValue:nil];
    item.type = [root stringValueForKey:@"type" defaultValue:nil];
    item.homeUrl = [root stringValueForKey:@"homeUrl" defaultValue:nil];
    item.nick = [root stringValueForKey:@"nick" defaultValue:nil];
    item.time = [root stringValueForKey:@"time" defaultValue:nil];
    item.content = [root stringValueForKey:@"content" defaultValue:nil];
    return item;
}

- (NSMutableArray *)mergeComments:(NSMutableArray *)comments withMyComments:(NSMutableArray *)mycomments {
    if ([mycomments count] == 0) {
        return comments;
    }
    
    // 去重，时间5分钟之内，内容相同
    NSMutableArray* delArray = [NSMutableArray arrayWithCapacity:0];
    for (WeiboHotCommentItem* myobj in mycomments) {
        for (WeiboHotCommentItem* objreal in comments) {
            if ([myobj isSameWith:objreal]) {
                [delArray addObject:myobj];
                break;
            }
        }
    }
    
    if ([delArray count] > 0) {
        [mycomments removeObjectsInArray:delArray];
    }
    
    // 如果合并后的myComments队列长度为0 返回不继续合并了
    NSInteger commentCnt = [comments count];
    NSInteger mycommentsCnt = [mycomments count];
    if (mycommentsCnt == 0) {
        return comments;
    }
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:commentCnt + mycommentsCnt];
    
    int i = 0, j = 0;
    
    while (i<commentCnt && j<mycommentsCnt) {
        WeiboHotCommentItem *comA = [comments objectAtIndex:i];
        WeiboHotCommentItem *comB = [mycomments objectAtIndex:j];
        long long timeA = [[comA time] longLongValue];
        long long timeB = [[comB time] longLongValue];
        
        if (timeA > timeB) {
            [resultArray addObject:comA];
            ++i;
        } else {
            [resultArray addObject:comB];
            ++j;
        }
    }
    
    while (i < commentCnt) {
        [resultArray addObject:[comments objectAtIndex:i++]];
    }
    
    while (j < mycommentsCnt) {
        [resultArray addObject:[mycomments objectAtIndex:j++]];
    }
    
    return resultArray;
}

#pragma mark - 下载某个Weibo hot detail 图片完成
- (void)finishedToFetchImagesInThreadForNewsContent:(id)newsContent {
    if ([newsContent isKindOfClass:[SNNewsContentWorkerNews class]]) {
        SNNewsContentWorkerNews *_workerNews = (SNNewsContentWorkerNews *)newsContent;
        SNDebugLog(@"===INFO: Main thread:%d, finish downloading images for weibo hot detail %@ .", [NSThread isMainThread], _workerNews.newsTitle);
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, finish downloading images for weibo hot detail.", [NSThread isMainThread]);
    }
}

@end
