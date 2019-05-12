//
//  SNNewsChannelType.h
//  sohunews
//
//  Created by handy wang on 1/8/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

//新闻频道列表
typedef enum {
    NewsChannelTypeNewsUnknown      = -1,
    NewsChannelTypeNews             = 0,    // 新闻频道
    NewsChannelTypeLive             = 1,    // 直播频道
    NewsChannelTypeVideo            = 2,    // 视频频道
    NewsChannelTypeWeiboHot         = 3,    // 微热议频道
    NewsChannelTypePhotos           = 4,    // 组图频道
    NewsChannelTypeSubscribe        = 8,    // 订阅频道
} SNNewsChannelType;

//新闻频道列表
typedef enum {
    NewsChannelEdit                 = 0, // 普通编辑流
    NewsChannelRecommand            = 1, // 普通推荐流(流式频道)
    NewsChannelEditAndRecom         = 2, // 要闻全屏幕(编辑流 + 推荐流)
} SNNewsChannelMixSteamType;
