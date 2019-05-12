//
//  SNDatabase+VideoTimeline.h
//  sohunews
//
//  Created by chenhong on 13-10-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDatabase.h"
#import "SNVideoObjects.h"

@interface SNDatabase (VideoTimeline)

- (BOOL)updateATimelineVideo:(NSDictionary *)data byVid:(NSString *)vid;

#pragma mark - Query
- (SNVideoData *)getVideoTimeLineByVid:(NSString *)vid;
- (NSArray *)getAllOfflinePlayVideos;
- (SNVideoData *)getOfflinePlayVideoByVid:(NSString *)vid;
- (NSArray*)getVideoTimeLineListByChannelId:(NSString*)channelId;

// 保存timeline列表
- (BOOL)addVideoTimeLineList:(NSArray*)videoList channelId:(NSString *)channelId;
- (BOOL)addVideoData:(SNVideoData *)video channelId:(NSString *)channelId;

// 清空timeline列表
- (BOOL)clearVideoTimeLineList;

- (BOOL)clearVideoTimeLineListByChannelId:(NSString *)channelId;

// 取热播maxVid
- (NSString *)getVideoTimeLineListMaxVid;

@end
