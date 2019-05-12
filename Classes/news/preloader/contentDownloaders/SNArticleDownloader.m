//
//  SNArticleDownloader.m
//  sohunews
//
//  Created by jojo on 13-11-13.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNArticleDownloader.h"
#import "SNArticle.h"

@implementation SNArticleDownloader

- (void)dealloc {

}

- (void)main {
    [super main];
    //  如果是对article.go的预加载的请求，增加一个参数：  preload=1
    [self.linkParams setObject:@"1" forKey:@"preload"];
    [SNArticle newsDownloadWithNewsId:self.newsId channelId:self.channelId paramsDic:self.linkParams];
//    [SNArticle newsForDownloadWithNewsId:self.newsId channelId:self.channelId paramsDic:self.linkParams];
}

@end
