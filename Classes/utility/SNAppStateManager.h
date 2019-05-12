//
//  SNAppStateManager.h
//  sohunews
//
//  Created by wangyy on 15/7/3.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppStateManager : NSObject

@property (nonatomic, strong) NSDate *activeDate;
@property (nonatomic, strong) NSDate *inactiveDate;

+ (SNAppStateManager *)sharedInstance;
- (BOOL)reloadWithChannelNewsTime:(NSTimeInterval)timeInterval;
- (void)resetAppStateDate;

//app首次启动进入频道判断
- (BOOL)appFinishLaunchLoadNewsWithChannelId:(NSString *)channelId;
//加载历史纪录
- (void)loadedChannelNewsWith:(NSString *)channelId;
//app退出时清空加载记录
- (void)removeAllChannelRefreshList;

@end
