//
//  SNRollingNewsCheckLatest.m
//  sohunews
//
//  Created by Hong Chen on 5/14/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNRollingNewsCheckLatest.h"
#import "SNTabBarController.h"
#import "SNCheckFlashRequest.h"
#import "SNDBManager.h"

@implementation SNRollingNewsCheckLatest


- (void)checkExpressNews {
    // 当前Tab不在‘新闻’页时，检查是否有快讯
    sohunewsAppDelegate *appDelegate = [SNUtility getApplicationDelegate];
    if (appDelegate.appTabbarController.selectedIndex == TABBAR_INDEX_NEWS) {
        return;
    }
    
    NSString *newsId = nil;
    NSString *channelId = @"1";
    
    //查询推荐和编辑流是否有快讯新闻
    NSMutableArray *itemList = [NSMutableArray array];
    NSArray *recomendList = [[SNDBManager currentDataBase] getLastRollingRecomendListByChannelId:channelId];
    NSArray *newsList = [[SNDBManager currentDataBase] getRollingNewsListNextPageByChannelId:channelId
                                                                                timelineIndex:nil
                                                                                     pageSize:KPaginationNum];
    if (recomendList) {
        [itemList addObjectsFromArray:recomendList];
    }
    if (newsList) {
        [itemList addObjectsFromArray:newsList];
    }
    
    for (RollingNewsListItem *item in itemList) {
        if (item.isFlash && [item.isFlash isEqualToString:@"1"]) {
            newsId = item.newsId;
            break;
        }
    }
    
    [self checkLatestWithNewsId:newsId channelId:channelId];
}

/* 判断是否有快讯新闻
 参数：aNewsId  默认为0；
 参数：aChannelId 默认为1要闻；
 */

- (void)checkLatestWithNewsId:(NSString *)aNewsId channelId:(NSString *)aChannelId {
    
    if (aNewsId == nil) aNewsId = @"0";
    if (aChannelId == nil) aChannelId = @"1";
    
    NSMutableDictionary *parmas = [NSMutableDictionary dictionaryWithCapacity:2];
    [parmas setValue:aNewsId forKey:@"newsId"];
    [parmas setValue:aChannelId forKey:@"channelId"];
    
    [[[SNCheckFlashRequest alloc] initWithDictionary:parmas] send:^(SNBaseRequest *request, id responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        SNDebugLog(@"%@",str);
        [self rollingNewsCheckRequestFinished:str];
    } failure:nil];
}


/*  result值
    no   没有新的快讯新闻；
    数字 有快讯新闻，数字为快讯新闻ID
 */
- (void)rollingNewsCheckRequestFinished:(NSString *)result {
    //SNDebugLog(@"%@", result);
    sohunewsAppDelegate *appDelegate = [SNUtility getApplicationDelegate];

    if (result != nil && ![result isEqualToString:@"no"]) {
        if (appDelegate.appTabbarController.selectedIndex != TABBAR_INDEX_NEWS) {
            [(SNTabBarController *)appDelegate.appTabbarController flashTabBarItem:YES atIndex:TABBAR_INDEX_NEWS];
        }
    }
    else {
        if (appDelegate.appTabbarController.selectedIndex != TABBAR_INDEX_NEWS) {
            [(SNTabBarController *)appDelegate.appTabbarController flashTabBarItem:NO atIndex:TABBAR_INDEX_NEWS];
        }
    }
}

@end
