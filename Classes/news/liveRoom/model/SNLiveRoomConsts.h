//
//  SNLiveRoomConsts.h
//  sohunews
//
//  Created by chenhong on 13-4-23.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#ifndef SOHUNEWS_SNLIVEROOMCONSTS_H
#define SOHUNEWS_SNLIVEROOMCONSTS_H

#import "SNSkinManager.h"

#define AUTHOR_FONT ([UIFont systemFontOfSize:14])
#define CONTENT_FONT ([UIFont systemFontOfSize:15])
#define CONTENT_LINE_HEIGHT (17)
#define SHOWALL_BTN_FONT ([UIFont systemFontOfSize:14])
#define TIME_FONT ([UIFont systemFontOfSize:11])
#define MEDIA_LENGTH_FONT ([UIFont digitAndLetterFontOfSize:12])
//#define IMG_W 70
#define AUTHOR_CONTENT_GAP 6
#define kGap 8//15 //cell上下文字空白15
#define BOTTOM_GAP 5

#define HEAD_X 8
#define HEAD_Y 12
#define HEAD_W 30

#define ROLE_FONT ([UIFont systemFontOfSize:10])
#define ROLE_X (HEAD_X - 4)
#define ROLE_Y (HEAD_Y + HEAD_W + 3)
#define ROLE_W (HEAD_W + 8)
#define ROLE_H (11)

#define AUTHOR_X 17
#define AUTHOR_Y 10
#define AUTHOR_W 152
#define AUTHOR_H 16

#define AUTHOR_X_R 14
#define TIME_RIGHT_GAP 14
#define TIME_W 100
#define CONTENT_W (kAppScreenWidth - 88)
#define LINK_H  31
#define REPLY_LINE_H 7
#define SOUND_H 38
#define SOUND_OFFSETX 3
#define SOUND_X (AUTHOR_X - SOUND_OFFSETX)

#define CONTENT_LINE_NUM 6
#define CONTENT_H (CONTENT_LINE_NUM*(15+3))
#define CONTENT_H_2 (3*(15+3))
#define SHOW_MORE_GAP (0)
#define SHOW_MORE_H 16

// 大图尺寸
#define IMG_W CONTENT_W
#define IMG_H 174 //CONTENT_W/4*3

// 回复网友
#define kReplyLiveComment @"1"

// 回复直播员
#define kReplyLiveContent @"2"

#define kLiveContentModelReceivedData       (@"kLiveContentModelReceivedData")
#define kLiveContentModelInfoChanged        (@"kLiveContentModelInfoChanged")
#define kLiveRefreshModelInfo               (@"kLiveRefreshModelInfo")

#define kLiveRoomInputModeKey @"kLiveRoomInputModeKey"

#define kLiveWorldCupWhiteColor ([UIColor colorWithWhite:1.0 alpha:1])
#define kLiveWorldCupWhiteAlphaColor ([UIColor colorWithWhite:1.0 alpha:0.5])

typedef NS_ENUM(NSUInteger, SNLiveCommentType) {
    SNLiveCommentTypePicAndTxt = 0,
    SNLiveCommentTypeAudio,
    SNLiveCommentTypeDynamicEmo
};

#endif //SOHUNEWS_SNLIVEROOMCONSTS_H
