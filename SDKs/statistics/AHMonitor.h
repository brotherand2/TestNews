//
//  ArchMonitor4AppStore.h
//  ArchMonitor4AppStore
//
//  Created by LiuNian on 14-11-28.
//  Copyright (c) 2014年 QuestMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AHMonitor:NSObject
+(AHMonitor*)shareInstanceWithAppkey:(NSString *)appkey;

/**
 *  启动系统检测
 */
-(void)startMonitor;
/**
 *  停止系统监测
 */
-(void)stopMonitor;


-(void)isEnableLog:(BOOL)yesOrNo;


-(void)testMode:(BOOL)yesOrNo;

@end
