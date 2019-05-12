//
//  SNVideoChannelManager.h
//  sohunews
//
//  Created by jojo on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNVideoChannelObjects.h"
#import "NSDictionaryExtend.h"

// 由于视频频道这个单例manager可能同时在多个地方引用，所以不使用delegate这种一对一回应的模式
// 采用与订阅中一样的 观察者模式
// 这个简单做一下  用系统的notificationCenter去中转 不再自己去维护一个观察者阵容
// 用完了记得及时removeListioner

extern NSString *const kVideoChannelHotCategoryIdKey; // value -- category id
extern NSString *const kVideoChannelHotCategorySubResultKey; // value -- @"0" success ; @"other" fail

#define kVideoChannelHotCategorySubDidChangeNotification            (@"kVideoChannelHotCategorySubDidChangeNotification")

@interface SNVideoChannelManager : NSObject

@property (nonatomic, assign) BOOL hasMoreHotChannelCategories;
@property (nonatomic, strong) NSMutableArray *channels;
@property (nonatomic, strong) NSMutableArray *hotChannelCategories; // array of  SNVideoHotChannelCategoriSectionObj

+ (SNVideoChannelManager *)sharedManager;

// local
- (NSArray *)loadVideoChannelsFromLocal;

// all channels
- (void)loadVideoChannelsFromServer;

// reset all channels after edit , cache and upload to server
- (void)syncAllVideosAndCache:(NSArray *)channels;

// upload channels to server
- (void)uploadVideoChannelsToServer;

// == refresh , reset cursor
- (void)refreshHotCategories;

// load more hot categories (接口暂时用不上，热播栏目一次全加载)
- (void)loadMoreHotCategories;

// 热播管理
- (BOOL)subscribeACategoryWithColumnId:(NSString *)columnId;
- (BOOL)unsubscribeACategoryWithColumnId:(NSString *)columnId;

@end
