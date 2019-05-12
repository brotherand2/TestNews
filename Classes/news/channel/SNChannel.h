//
//  SNChannel.h
//  sohunews
//
//  Created by Cong Dan on 3/22/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NewsChannelItem;

@interface SNChannel : NSObject <NSCoding>
{
    NSString *channelName;                  // 频道名称
	NSString *channelId;                    // 频道ID
    NSString *channelIcon;
    NSString *channelType;                  // 频道类型
    NSString *channelPosition;              // 频道位置
    NSString *channelTop;                   // 频道置顶
    NSString *channelTopTime;               // 置顶时间
    NSString *isChannelSubed;
    NSString *lastModify;
    NSString *currPosition;
    NSString *localType;                    // 本地频道类型
    NSString *isRecom;                      // 是否支持推荐
    NSString *tips;                         // 提示语
    NSString *link;                         // H5 连接
    BOOL      add;                          // 是否新添加
    int      tipsInterval;                  // tips提示时间间隔
    NSString *serverVersion;                //频道支持的接口版本号
    int    isMixStream;                    //服务端决定是否支持混流
}

@property(nonatomic,copy) NSString *channelCaterotyName;
@property(nonatomic,copy) NSString *channelCaterotyID;
@property(nonatomic,copy) NSString *channelIconFlag;
@property(nonatomic,copy) NSString *channelName;
@property(nonatomic,copy) NSString *channelId;
@property(nonatomic,copy) NSString *channelIcon;
@property(nonatomic,copy) NSString *channelType;
@property(nonatomic,copy) NSString *channelPosition;
@property(nonatomic,copy) NSString *channelTop;
@property(nonatomic,copy) NSString *channelTopTime;
@property(nonatomic,copy) NSString *isChannelSubed;
@property(nonatomic,copy) NSString *lastModify;
@property(nonatomic,copy) NSString *currPosition;
@property(nonatomic,copy) NSString *localType;
@property(nonatomic,copy) NSString *isRecom;
@property(nonatomic,copy) NSString *tips;
@property(nonatomic,copy) NSString *link;
@property(nonatomic,copy) NSString *serverVersion;
@property(nonatomic,assign)int isMixStream;

@property(nonatomic,assign,getter = isAdd) BOOL add;
@property(nonatomic,assign)int tipsInterval;

@property(nonatomic, copy) NSString *gbcode;

@property (nonatomic, assign) BOOL isPreloadChannel;//该频道是否为流内预加载。（选中频道会加载左右两边的频道）
@property (nonatomic, copy) NSString *channelShowType;

- (void)setChannelTopTime:(NSString *)_channelTopTime formatter:(NSString *)formate;
- (void)setChannelTopTimeBySeconds:(NSString *)_channelTopTime;

- (BOOL)isLaterThan:(SNChannel *)other;
- (BOOL)orderChangedByItem:(NewsChannelItem *)item;
- (BOOL)isLocalChannel;
- (BOOL)isH5Channel;
- (BOOL)isHomeChannel;
- (BOOL)isNewChannel;
- (BOOL)isSurpportNewChannel;

@end
