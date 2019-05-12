//
//  SNListenNewsList.h
//  sohunews
//
//  Created by weibin cheng on 14-6-16.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SNListenNewsItemType)
{
    SNListenNewsItemNews,
    SNListenNewsItemJoke,
    SNListenNewsItemPhotoList
};

@interface SNListenNewsItem : NSObject

@property (nonatomic, strong) NSString* newsId;
@property (nonatomic, strong) NSString* channelId;
@property (nonatomic, strong) NSString* link;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, assign) SNListenNewsItemType type;
@end

@protocol SNListenNewsListDelegate;
@interface SNListenNewsList : NSObject
@property (nonatomic, weak) id<SNListenNewsListDelegate> delegate;

- (NSString *)startDownloadNewsList:(NSArray*)list;

- (NSInteger)startDownloadNewsWithIndex:(NSInteger)index;

- (NSInteger)count;

- (void)cancelAllDownloader;

- (SNListenNewsItem*)itemByIndex:(NSInteger)index;
@end

@protocol SNListenNewsListDelegate <NSObject>
@optional
- (void)downloadNewsDidFinished:(NSInteger)index withContent:(NSString*)content;
@end
