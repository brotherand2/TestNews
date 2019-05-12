//
//  SNNewsModel.h
//  sohunews
//
//  Created by chenhong on 14-3-7.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNDragRefreshURLRequestModel.h"

@protocol SNNewsModel <NSObject>
- (NSString *)channelId;
- (BOOL)hasRecommendNews;
- (NSTimeInterval)refreshIntervalWithDefault:(NSTimeInterval)interval;
@end


@interface SNNewsModel : SNDragRefreshURLRequestModel<SNNewsModel>

@property(nonatomic, assign) BOOL isRecreate;
@property(nonatomic, assign) BOOL isFromSub;
@property(nonatomic, assign) BOOL isPreloadChannel;//是否为预加载的频道
@property(nonatomic, assign) BOOL isNewChannel;  //是否是新版频道
@property(nonatomic, assign) BOOL showRecommend; //首页下拉显示推荐流
@property(nonatomic, assign) int isMixStream;  //是否是混流频道
@property(nonatomic, copy) NSString *link;

- (NSDate *)refreshedTime;
- (void)setRefreshedTime;
- (void)setRefreshStatusOfUpgrade;

@end
