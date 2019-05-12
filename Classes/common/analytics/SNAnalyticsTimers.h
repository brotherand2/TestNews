//
//  SNAnalyticsTimers.h
//  sohunews
//
//  Created by jojo on 13-11-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SNAnalyticsTimerPageTypeRollingNewsList = 1, // 及时新闻列表页
    SNAnalyticsTimerPageTypeNewsArticle = 2, // 图文新闻正文
    SNAnalyticsTimerPageTypeNewsPhotoList = 3, // 组图新闻正文页
}SNAnalyticsTimerPageType;

// 统计时常的数据结构 记一次start和stop的时间
@interface SNAnalyticsTimer : NSObject {
    NSDate *_weakTime;
    NSDate *_fireTime;
}

@property (nonatomic, assign, readonly) BOOL isFired;
@property (nonatomic, assign, readonly) int timeDiff; // 一次统计行为涵盖的时间长度 (单位是s)
@property (nonatomic, assign) SNAnalyticsTimerPageType page;

+ (id)timer;
- (void)fire;
- (void)reportTM;

@end

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

// 及时新闻 滑动行为统计
@interface SNAnalyticsRollingSlideTimer : SNAnalyticsTimer

@property (nonatomic, assign) NSInteger  slideCount; // 一次统计行为过程中滑过的新闻条数
@property (nonatomic, copy) NSString *channelId;

@end

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

@interface SNAnalyticsNewsReadTimer : SNAnalyticsTimer

@property (nonatomic, copy) NSString *newsId;
@property (nonatomic, assign) BOOL isEnd;
@property (nonatomic, assign) NSInteger isFavour;
@property (nonatomic, copy) NSString* subId;
@property (nonatomic, copy) NSString* channelId;
@property (nonatomic, copy) NSString* groudId;
@property (nonatomic, copy) NSString* newsfrom;
@property (nonatomic, copy) NSString* recomInfo;
@property (nonatomic, copy) NSString* link;

@end
