//
//  SNListenNewsDownloader.h
//  sohunews
//
//  Created by weibin cheng on 14-6-16.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNListenNewsDownloaderDelegate.h"

@interface SNListenNewsDownloader : NSOperation
@property (nonatomic, weak) id<SNListenNewsDownloaderDelegate> delegate;
@property (nonatomic, copy) NSString *newsId;
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, strong) NSMutableDictionary *linkParams;

//lijian 2017.06.05 直接提供接口加载，这个类根本没实现下载功能，不需要使用异步加载，异步加载反而容易引起问题
- (void)main;

@end
