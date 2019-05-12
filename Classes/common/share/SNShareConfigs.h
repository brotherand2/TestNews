//
//  ShareConfigs.h
//  sohunews
//
//  Created by jialei on 14-4-9.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

//wiki: http://smc.sohuno.com/wiki/pages/viewpage.action?pageId=6947156
#ifndef sohunews_SNShareConfigs_h
#define sohunews_SNShareConfigs_h

typedef NS_ENUM(NSInteger, SNShareSourceType)
{
    SNShareSourceTypeNews       = 3,
    SNShareSourceTypePhoto      = 4,
    SNShareSourceTypeLive       = 9,
    SNShareSourceTypeSpecial    = 10,
    SNShareSourceTypeSub        = 11,
    SNShareSourceTypeWeibo      = 13,
    SNShareSourceTypeVedio      = 14,
    SNShareSourceTypeUGC        = 15,
    SNShareSourceTypeH5         = 16,            //h5直播间管理页面邀请
    SNShareSourceTypeActivityNoUgc = 42,    //活动只分享但不进动态
    SNShareSourceTypeChannel = 33,
    SNShareSourceTypeADSpread = 43, //为了和安卓统一，推广、调查的分享type
    SNShareSourceTypeVedioTab = 141,
    SNShareSourceTypeQianfan  = 65,
    SNShareSourceTypeStory  = 50,//小说50 wangshun 2017.3.10
};

#define MAXINPUT_FOR_SINA		140

#pragma mark- notification

static NSString *const NotificationShareBindedFinished = @"shareBindedFinished";
static NSString *const SharelistRestoreObject = @"SharelistRestoreObject";

#endif
