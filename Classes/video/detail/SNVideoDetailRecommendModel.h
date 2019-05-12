//
//  SNVideoDetailRecommendModel.h
//  sohunews
//
//  Created by jojo on 13-9-13.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSNVideoDetailRecommendCacheExpirationAge                                   (60 * 30)

@interface SNVideoDetailRecommendModel : NSObject

@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, weak) id delegate;

// type参数暂时不用
+ (SNVideoDetailRecommendModel *)videoRecommendModelWithMid:(NSString *)mid;
- (id)initRecomemndModelWithMid:(NSString *)mid;

// from server (== hasnext - -||)
@property (nonatomic, assign, readonly) BOOL hasMore;

// total count of videos
@property (nonatomic, assign, readonly) int totalCount;

@property (nonatomic, strong) NSMutableArray *videos;

// if there`s no cache, return nil
- (NSArray *)loadRecommendVideosFromLocalCache;

// 加载更多与阅读圈一样，model自己管理cursor
- (void)loadRecommendVideosFromServer;
- (void)loadRecommendVideosMoreFromServer;

- (void)cancelRequest;

@end


@protocol SNVideoDetailRecommendModelDelegate <NSObject>

@optional
- (void)videoRecommendModelDidStartLoad:(SNVideoDetailRecommendModel *)recModel;
- (void)videoRecommendModelDidFailLoadWithError:(NSError*)error model:(SNVideoDetailRecommendModel *)recModel;
@end
