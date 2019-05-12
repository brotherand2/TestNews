//
//  SNVideoAdContextConst.h
//  sohunews
//
//  Created by handy wang on 5/6/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SNVideoAdContextCurrentTabValue) {
    SNVideoAdContextCurrentTabValue_None,
    SNVideoAdContextCurrentTabValue_News,
    SNVideoAdContextCurrentTabValue_Video,
    SNVideoAdContextCurrentTabValue_Mine
};

static NSString *const kCurrentTab = @"kCurrentTab";
static NSString *const kCurrentNewsChannelID = @"kCurrentNewsChannelID";
static NSString *const kCurrentVideoChannelID = @"kCurrentVideoChannelID";

typedef NS_ENUM(NSInteger, SNVideoAdContextCurrentVideoAdPosition) {
    SNVideoAdContextCurrentVideoAdPosition_Unknown,
    SNVideoAdContextCurrentVideoAdPosition_Article,
    SNVideoAdContextCurrentVideoAdPosition_VideoTimeline,
    SNVideoAdContextCurrentVideoAdPosition_VideoDetail,
    SNVideoAdContextCurrentVideoAdPosition_LiveBanner
};