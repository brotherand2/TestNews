//
//  SNDBManager.m
//  sohunewsipad
//
//  Created by ivan on 9/29/12.
//  Copyright (c) 2012 sohu. All rights reserved.
//

#import "SNDBManager.h"

@implementation SNDBManager
- (id)init {
    if (self = [super init]) {
//        s_cacheMgrInstanceDic = [[NSMutableDictionary alloc] init];
        s_downloadingNewsArticle = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (SNDBManager *)sharedInstance {
    static SNDBManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNDBManager alloc] init];
    });
    return _sharedInstance;
}

- (void)dealloc {
//     //(s_cacheMgrInstanceDic);
     //s_downloadingNewsArticle);
}

#pragma mark -
#pragma mark 新闻下载控制
-(BOOL)addDownloadingNewsArticle:(NewsArticleItem*)newsArticle
{
	@synchronized(self)
	{
		if(s_downloadingNewsArticle == nil)
		{
			s_downloadingNewsArticle = [[NSMutableArray alloc] init];
		}
		
		if (newsArticle != nil) {
			[s_downloadingNewsArticle addObject:newsArticle];
			return YES;
		}
		else {
			return NO;
		}
	}
}

-(BOOL)removeDownloadingNewsArticle:(NewsArticleItem*)newsArticle
{
	@synchronized(self)
	{
		if(s_downloadingNewsArticle == nil || newsArticle == nil)
		{
			return NO;
		}
		
		[s_downloadingNewsArticle removeObject:newsArticle];
		return YES;
	}
}

-(BOOL)isNewsArticleInDownloading:(NewsArticleItem*)newsArticle
{
	@synchronized(self)
	{
		if(s_downloadingNewsArticle == nil || newsArticle == nil)
		{
			return NO;
		}
		
		for (NewsArticleItem *item in s_downloadingNewsArticle) {
			if ([item.newsId isEqualToString:newsArticle.newsId]
				&& ([item.channelId isEqualToString:newsArticle.channelId]
					//|| [item.pubId isEqualToString:newsArticle.pubId]
					|| [item.termId isEqualToString:newsArticle.termId])) {
					return YES;
				}
		}
		
		return NO;
	}
}

+ (SNDatabase *)currentDataBase
{
    static SNDatabase *database = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        database = [[SNDatabase alloc] init];
    });
    return database;
}

@end
