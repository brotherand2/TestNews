//
//  SNCacheCleanerManager.h
//  sohunews
//
//  Created by handy on 9/9/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 一）自动清理缓存的逻辑规则如下：
 1.1）缓存包括：数据库表数据、离线下载的孤儿数据文件、TTURLCache目录下的图片和目录下缓存的接口返回的XML或JSON；
 
 1.2）触发时机：每次按Home键进入后台时；
 
 1.3）清理条件：
 1.2.1）当前App没有正在清理缓存；
 1.2.2）两次按Home键之间的间隔大于6小时；
 
 1.4）满足条件后的清理逻辑：
 1.3.1）如果App从未删除过全部缓存:
 若缓存大小总大于200M，则删除过期数据库数据（数据创建时间超过两天为过期）、删除离线下载的孤儿数据文件、删除TTURLCache目录下全部缓存：
 若缓存大小总小于200M，则删除过期数据库数据（数据创建时间超过两天为过期）、删除离线下载的孤儿数据文件、逐个检查TTURLCache目录下的每个文件，若文件的最后访问时间距离当前检查的时间点已大于两天则删除之，否则保留；
 1.3.2）如果App已删除过全部缓存: 则删除过期数据库数据（数据创建时间超过两天为过期）、删除离线下载的孤儿数据文件、逐个检查TTURLCache目录下的每个文件，若文件的最后访问时间距离当前检查的时间点已大于两天则删除之，否则保留；
 
 1.5）支持后台任务(按Home键后会继续清理缓存)；
 1.5.1）后台任务会有10分钟的时间(Actually 9分55秒)来进行清理缓存，目前的测试情况来看10分钟已足够；
 1.5.2）清理缓存耗时未到10分钟且缓存未清理完时，App被切换到前台后缓存会被继续清理；
 1.5.3）清理缓存耗时未到10分钟且缓存未清理完时，App被切换到前台后又被切换到后台，10分钟的时长会重新累加；
 1.5.4）清理缓存耗时未到10分钟但缓存已清理完时，App会被iOS挂起，当被切换到前台后，无论第一个可见UI是否为下载列表，下载列表都会更新为空列表；
 1.5.4）清理缓存耗时超过10分钟但缓存未清理完时，App会被iOS挂起，当被切换到前台后，无论第一个可见UI是否为下载列表，下载列表下载列表上都会保留未下载的项(刊物和频道)，显示的状态为失败，可重试；
 */

#define __kDBDataExpiredInterval__                                      (2*24*60*60)//(30)//(2*24*60*60)//某些数据表数据是否已存放2天
#define kMaxDurationBtwTwoTimesCleanCache                               (6*60*60)//(30)//(6*60*60)//两次进入后台时间间隔超过6小时就检查缓存并清理
#define kMaxDurationOfLastAccessSinceNow                                (2*24*60*60)//(30)//(2*24*60*60)//文件是否已2天没有被访问
#define kMaxCapacityInTTURLCacheDir                                     (200*1024*1024)//(1*1024*1024*1024)//(200*1024*1024)//Whether over 200M bettween duration kMaxDurationBtwTwoTimesCleanCache

#define kShouldContinueCleanCacheWhenAppEntersBackground                (1)
#define kTrashCanOfTTURLCache                                           (@"trashCanOfTTURLCache")

@interface SNCacheCleanerManager : NSObject {

    BOOL _isCleaningAutomatically;
    BOOL _isCleaningAll;
    BOOL _isTimeout;
    UIBackgroundTaskIdentifier _backgroundTask;

}

#pragma mark - Public methods implementation

+ (SNCacheCleanerManager *)sharedInstance;

- (void)cleanAutomatically;

// ’更多‘ - ‘清除缓存’
- (void)cleanManually;

@end
