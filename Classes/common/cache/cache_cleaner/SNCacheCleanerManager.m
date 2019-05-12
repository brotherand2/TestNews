//
//  SNCacheCleanerManager.m
//  sohunews
//
//  Created by handy on 9/9/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNCacheCleanerManager.h"
#import "SNDBManager.h"
#import "DTAsyncFileDeleter.h"

#include <sys/stat.h>
#include <dirent.h>
#import "SNRollingNewsPublicManager.h"

@implementation SNCacheCleanerManager

#pragma mark - Lifecycle

- (id)init {
    if (self = [super init]) {
        _isCleaningAutomatically = NO;
        _isCleaningAll = NO;
    }
    
    return self;
}

#pragma mark - Public methods implementation

+ (SNCacheCleanerManager *)sharedInstance {
    static SNCacheCleanerManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNCacheCleanerManager alloc] init];
    });
    
    return _sharedInstance;
}

#pragma mark - Entry point

- (void)cleanAutomatically {
    /**
     * 解释：可能缓存过大以致于后台10分钟超时的时候都清理不完，当切换到前台的时候也没有删除完，然后再切换到后台时应该继续清理。
     * 所以这里是为了支持继续清理。
     */
    if (_isCleaningAutomatically && _isTimeout) {
        _isTimeout = NO;
        [self markBgTaskAsBegin];
        return;
    }
    //---
    
    if (_isCleaningAutomatically) {
        SNDebugLog(@"######INFO: Cache is cleaning, give up duplicated cleaning action.");
        return;
    }
    
    [self markBgTaskAsBegin];
    
    SNDebugLog(@"\n\n\n################################################################\n##################### Ready to clean cache #####################\n################################################################");
    
    //如果没有到清缓存的时间间隔
    if (![self reachTheCleanTime]) {
        SNDebugLog(@"######INFO: Give up cleaning because dont reach the clean time.");
        [self markBgTaskAsFinished];
        SNDebugLog(@"\n\n################################################################\n##################### Finish clean all cache #####################\n################################################################\n\n\n");
        
    } else {
        _isCleaningAutomatically = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            BOOL _hadCleanAllCacheBefore = [SNUserDefaults boolForKey:kHadCleanAllCacheBefore];
            if (!_hadCleanAllCacheBefore) {//以前没有全部清过
                SNDebugLog(@"######INFO: App never clean all cache before and check TTURLCache dir content size.");
                
                SNDebugLog(@"######INFO: Checking TTURLCache dir content whether out of %d ...", kMaxCapacityInTTURLCacheDir);
                NSString *_ttURLCacheDir = [TTURLCache cachePathWithName:kDefaultCacheName];
                unsigned long long int _size = [UIDevice getFolderSize:_ttURLCacheDir];
                if (_size > kMaxCapacityInTTURLCacheDir) {
                    SNDebugLog(@"######INFO: TTURLCache dir content whether is out of % dM, current is %lldM, so clean all.", (kMaxCapacityInTTURLCacheDir/1024/1024), (_size/1024/1024));
                    [self cleanAllCacheAutomaticallyInThread];
                }
                else {
                    SNDebugLog(@"######INFO: TTURLCache dir content whether isnt out of %dM, current is %lldM, so clean expired.", (kMaxCapacityInTTURLCacheDir/1024/1024), (_size/1024/1024));
                    [self cleanExpiredCache];
                }
            }
            else {
                SNDebugLog(@"######INFO: App had clean all cache before, so clean expired.");
                [self cleanExpiredCache];
            }
        });
    }
}

- (void)cleanManually {
    if (!_isCleaningAll) {
        [self cleanAllCacheManuallyInThread];
    }
}

#pragma mark - Private

- (BOOL)reachTheCleanTime {
    NSDate *_lastCleanCacheDate = [SNUserDefaults objectForKey:kLastCleanCacheTime];
    
    if (_lastCleanCacheDate == nil) {
        return YES;
    }
    
    if ([_lastCleanCacheDate isKindOfClass:[NSDate class]]) {
        NSTimeInterval _durationFromLastTimeClean = -[_lastCleanCacheDate timeIntervalSinceNow];
        return (_durationFromLastTimeClean > kMaxDurationBtwTwoTimesCleanCache);
    } else {
        return YES;
    }
}

- (void)cleanAllCacheManuallyInThread {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _isCleaningAll = YES;
        
        [self cleanDBCacheAll];
        [self cleanDetachedPubDir];
        [self cleanIconsCache];
        [self cleanAllCachedImgInThread];
//        [[SNRollingNewsPublicManager sharedInstance] deleteAllChannelsRequestParams];
        [[SNRollingNewsPublicManager sharedInstance] clearAllContentToken];
        [SNRollingNewsPublicManager sharedInstance].clearAllCache = YES;
    });
}

- (void)cleanAllCacheAutomaticallyInThread {
    _isCleaningAll = YES;
    
    [self cleanDBCacheAll];
    [self cleanDetachedPubDir];
    [self cleanAllCachedImgInThread];
}

- (void)cleanExpiredCache {
    [self cleanDBCacheExpired];
    [self cleanDetachedPubDir];
    [self checkAndRemoveImgOneByOneInThread];
}

#pragma mark -

- (void)cleanDBCacheAll {
    SNDebugLog(@"######INFO: Begin cleaning all db data......");
    //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
    
    [[SNDBManager currentDataBase] clearAllCache];
    
    //[[_stopWatch stop] print:@"===Finish cleaning all db data==="];
    //SNDebugLog(@"######INFO: Finish cleaning all db data......");
}

//清理过期的部分数据库数据
//清理表tbNewsArticle、tbNewsImage、tbGallery、tbRecommendGallery、tbPhoto、tbRollingNewsList、tbGroupPhoto、tbGroupPhotoUrl、
//tbVotesInfo、 tbRecommendNews、tbSpecialNewsList、tbCommentJson、tbLivingGame、tbWeiboHotItem、tbWeiboHotDetail、tbWeiboHotComment中过期的数据
- (void)cleanDBCacheExpired {
    SNDebugLog(@"######INFO: Begin cleaning expired db data......");
    //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
    
    [[SNDBManager currentDataBase] cleanAllExpiredCache];
    
    //[[_stopWatch stop] print:@"===Finish cleaning expired db data==="];
    SNDebugLog(@"######INFO: Finish cleaning expired db data......");
}

//清理早期版本中删除离线数据时没有删除的离线包数据
- (void)cleanDetachedPubDir {
    return; // 暂时不自动清理刊物，有时间了再查具体原因chh
    
    
    
    SNDebugLog(@"######INFO: Begin cleaning detached pub data......");
    //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
    
    //从newspaper表中找到目前已下载的刊物
    NSArray *_downloadedNewspaperList = [[SNDBManager currentDataBase] getNewspaperDownloadedList];
    
    //遍历Caches/Newspaper目录并找到不属于数据表newspaper已下载的刊物的目录(可以考虑找到日期那一级)并将其删除(因为这种目录数据是不会被用到的已处于detached状态)
    NSString *_downloadDestinationDir = [SNDownloadConfig downloadDestinationDir];
    NSFileManager *_fileManager = [NSFileManager defaultManager];
    NSArray *_pubDirNames = [_fileManager contentsOfDirectoryAtPath:_downloadDestinationDir error:nil];
    
    for (NSString *_pubDirName in _pubDirNames) {
        NSString *_absolutePubDir = [_downloadDestinationDir stringByAppendingPathComponent:_pubDirName];
        NSArray *_pubDateDirNames = [_fileManager contentsOfDirectoryAtPath:_absolutePubDir error:nil];
        for (NSString *_pubDateDirName in _pubDateDirNames) {
            if ([self isPubDateDirDetached:_pubDateDirName baseOn:_downloadedNewspaperList]) {
                NSString *_absolutePubDateDir = [_absolutePubDir stringByAppendingPathComponent:_pubDateDirName];
                NSError *_error = nil;
                [_fileManager removeItemAtPath:_absolutePubDateDir error:&_error];
                if (!!_error) {
                    SNDebugLog(@"######INFO: %@--%@, Failed to remove detached dir %@ with comming message [%@]",
                               NSStringFromClass(self.class), NSStringFromSelector(_cmd), _absolutePubDateDir, [_error description]);
                }
            }
        }
    }
    
    //[[_stopWatch stop] print:@"===Finish clean detached pub data==="];
    SNDebugLog(@"######INFO: Finish cleaning detached pub data......");
}

- (BOOL)isPubDateDirDetached:(NSString *)pubDateDirName baseOn:(NSArray *)downloadedNewspapaerList {
    for (NewspaperItem *_downloadedNewspaper in downloadedNewspapaerList) {
        //使用新版接口offline.go生成的路径
        if(_downloadedNewspaper.termZip!=nil && [_downloadedNewspaper.termZip containsString:pubDateDirName]){
            return NO;
        }
        
        if (_downloadedNewspaper.termTime.length == 0) {
            continue;
        }

        NSDate *_pubTermDate = [NSDate dateWithTimeIntervalSince1970:[_downloadedNewspaper.termTime longLongValue]/1000];
        
        //---
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
        NSDateComponents *comps = [calendar components:unitFlags fromDate:_pubTermDate];
        NSInteger _year = [comps year];
        NSInteger _month = [comps month];
        NSInteger _day = [comps day];
        //---
        
        NSString *_tmpPubDateDirName = [NSString stringWithFormat:@"%ld%02ld%02ld", _year, _month, _day];
        SNDebugLog(@"######INFO: Checking if dir name [%@] is detached base on [%@] ......", pubDateDirName, _tmpPubDateDirName);
        if ([pubDateDirName isEqualToString:_tmpPubDateDirName]) {
            return NO;
        }
    }
    
    SNDebugLog(@"######INFO: Dir [%@] is detached", pubDateDirName);
    return YES;
}

- (void)cleanIconsCache {
    SNDebugLog(@"######INFO: Begin cleaning icons cache......");
    //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
    
    NSArray *_paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *_cachesPath = [_paths objectAtIndex:0];
    NSString *_iconsCachePath = [_cachesPath stringByAppendingPathComponent:kIconsCacheFolderName];
    
    NSError *_error = nil;
    NSFileManager *_fm = [[NSFileManager alloc] init];
    if ([_fm fileExistsAtPath:_iconsCachePath]) {
        [_fm removeItemAtPath:_iconsCachePath error:&_error];
    }
    
    if (!!_error) {
        SNDebugLog(@"===Failed to clean icons cache.");
    } else {
        SNDebugLog(@"===Succeeded to clean icons cache.");
    }
    
    //[[_stopWatch stop] print:@"===Finish cleaning icons cache==="];
}

#pragma mark - CleanImgCache Schema1

- (void)cleanAllCachedImgInThread {
    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self cleanAllCachedImgInThread];
        });
        return;
    }
    
    SNDebugLog(@"######INFO: Ready to clean all cached img in TTURLCache dir.");    
    
    //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
    SNDebugLog(@"######INFO: Begin move ttURLCache dir into kTrashCanOfTTURLCache.");
    
    //创建Trashcan根本目录
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachesPath = [paths objectAtIndex:0];
    NSString *_trashCanOfTTURLCache = [cachesPath stringByAppendingPathComponent:kTrashCanOfTTURLCache];
    NSFileManager *_fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if (![_fileManager fileExistsAtPath:_trashCanOfTTURLCache]) {
        BOOL _rst = [_fileManager createDirectoryAtPath:_trashCanOfTTURLCache withIntermediateDirectories:YES attributes:nil error:&error];
        if (!_rst || !!error) {
            [self didFinishCleanAllCachedImg];
            return;
        }
    }
    
    NSString *_ttURLCacheDir = [TTURLCache cachePathWithName:kDefaultCacheName];
    
    CFUUIDRef   _newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef _newUniqueIdString = CFUUIDCreateString(kCFAllocatorDefault, _newUniqueId);
    NSString    *_renamedTTURLCacheDir = [_trashCanOfTTURLCache stringByAppendingPathComponent:(__bridge NSString *)_newUniqueIdString];
    CFRelease(_newUniqueId);
    CFRelease(_newUniqueIdString);
    
    error = nil;
    if ([_fileManager moveItemAtPath:_ttURLCacheDir toPath:_renamedTTURLCacheDir error:&error] && !error) {
        SNDebugLog(@"######INFO: Succeeded to move ttURLCache from %@ to %@", _ttURLCacheDir, _renamedTTURLCacheDir);
    } else {
        SNDebugLog(@"######INFO: Failed to move ttURLCache with comming message %@", [error localizedDescription]);
    }
    
    //[[_stopWatch stop] print:@"===Finish move ttURLCache dir into kTrashCanOfTTURLCache==="];
    
    //创建TTURLCache缓存空目录
    [[TTURLCache sharedCache] setCachePath:[TTURLCache cachePathWithName:kDefaultCacheName]];
    
    //异步删除kTrashCanOfTTURLCache
    SNDebugLog(@"######INFO: Begin clean kTrashCanOfTTURLCache.");
    [[DTAsyncFileDeleter sharedInstance] removeItemAtPath:_trashCanOfTTURLCache didFinishTarget:self selector:@selector(didFinishCleanAllCachedImg)];
}

- (void)didFinishCleanAllCachedImg {
    SNDebugLog(@"######INFO: Finish clean kTrashCanOfTTURLCache.");
    [SNUserDefaults setBool:YES forKey:kHadCleanAllCacheBefore];
    
    [self didFinishCleanAll];
}

#pragma mark - CleanImgCache Schema2

- (void)checkAndRemoveImgOneByOneInThread {
    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self checkAndRemoveImgOneByOneInThread];
        });
        return;
    }
    
    //SNStopWatch *_stopWatch = [[SNStopWatch watch] begin];
    SNDebugLog(@"######INFO: Begin checking and remove image onebyone......");

    NSString *_ttURLCacheDir = [TTURLCache cachePathWithName:kDefaultCacheName];
    NSFileManager *_outterFileManager = [[NSFileManager alloc] init];
    NSError *_error = nil;
    NSArray *_subFileNames = [_outterFileManager contentsOfDirectoryAtPath:_ttURLCacheDir error:&_error];
    if (!!_error) {
        SNDebugLog(@"######INFO: Give up checking for some error ocurred with message [%@]", [_error localizedDescription]);
        //[[_stopWatch stop] print:@"===Finish checking and remove image onebyone==="];
    }
    else {
        dispatch_queue_t _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_apply(_subFileNames.count, _queue, ^(size_t _index) {
            NSString *_fileName = [_subFileNames objectAtIndex:_index];
            NSFileManager *_innerFileManager = [[NSFileManager alloc] init];
            NSString *_path = [_ttURLCacheDir stringByAppendingPathComponent:_fileName];
            if ([_innerFileManager fileExistsAtPath:_path]) {
                struct stat st;
                int _rst = stat([_path cStringUsingEncoding:NSUTF8StringEncoding], &st);
                if (_rst == 0) {
                    NSTimeZone *_timezone = [NSTimeZone systemTimeZone];
                    
                    //当前系统时区下的当前时间
                    NSDate *_now = [NSDate date];
                    NSInteger _nInterval = [_timezone secondsFromGMTForDate:_now];
                    _now = [_now dateByAddingTimeInterval:_nInterval];
                    
                    //当前系统时区下的文件最后访问时间
                    long long _aSeconds = st.st_atimespec.tv_sec+st.st_atimespec.tv_nsec/1000;
                    NSDate *_aDate = [NSDate dateWithTimeIntervalSince1970:_aSeconds];
                    NSInteger _aInterval = [_timezone secondsFromGMTForDate:_aDate];
                    _aDate = [_aDate  dateByAddingTimeInterval:_aInterval];

#if 0
                    //当前系统时区下的文件数据修改时间
                    long long _mSeconds = st.st_mtimespec.tv_sec+st.st_mtimespec.tv_nsec/1000;
                    NSDate *_mDate = [NSDate dateWithTimeIntervalSince1970:_mSeconds];
                    NSInteger _mInterval = [_timezone secondsFromGMTForDate:_mDate];
                    _mDate = [_mDate dateByAddingTimeInterval:_mInterval];
                    
                    //当前系统时区下的文件状态改变时间
                    long long _cSeconds = st.st_ctimespec.tv_sec+st.st_ctimespec.tv_nsec/1000;
                    NSDate *_cDate = [NSDate dateWithTimeIntervalSince1970:_cSeconds];
                    NSInteger _cInterval = [_timezone secondsFromGMTForDate:_cDate];
                    _cDate = [_cDate dateByAddingTimeInterval:_cInterval];
                    
                    //当前系统时区下的文件创建时间
                    long long _birthSeconds = st.st_birthtimespec.tv_sec+st.st_birthtimespec.tv_nsec/1000;
                    NSDate *_birthDate = [NSDate dateWithTimeIntervalSince1970:_birthSeconds];
                    NSInteger _birthInterval = [_timezone secondsFromGMTForDate:_birthDate];
                    _birthDate = [_birthDate dateByAddingTimeInterval:_birthInterval];
                    
                    SNDebugLog(@"\n\n\n######INFO:\nFile:%@ \naccesstime:%@ \nmodifytime:%@ \nchangetime:%@ \ncreatetime:%@ \ncurrent: %@", _fileName, _aDate, _mDate, _cDate, _birthDate, _now);
#endif
                    
                    //文件没有被访问的时长
                    double _lastAccessDurationSinceNow = fabs([_aDate timeIntervalSinceDate:_now]);
                    if (_lastAccessDurationSinceNow > kMaxDurationOfLastAccessSinceNow) {
                        SNDebugLog(@"######INFO: File %@ is expired.", _fileName);
                        NSError *_rError = nil;
                        BOOL _rResult = [_innerFileManager removeItemAtPath:_path error:&_rError];
                        if (!_rResult) {
                            SNDebugLog(@"######INFO: Failed to remove file %@", _fileName);
                        }
                        if (!!_rError) {
                            SNDebugLog(@"######INFO: Failed to remove file %@ with error: %@", _fileName, [_rError localizedDescription]);
                        }
                        if (_rResult && !_rError) {
                            SNDebugLog(@"######INFO: Succeeded to remove file %@", _fileName);
                        }
                        _rError = nil;
                    }
                }
            }
        });
    
        //[[_stopWatch stop] print:@"===Finish checking and remove image onebyone==="];
    }
    
    /**
     * 清理ttURLCache垃圾桶，原因：
     * 举例说明：假设背景:有2G缓存图片，当超过500M时，就要全部删除。
     * App第一次在后台删除全部缓存时，当删除到400M时程序crash或用户kill了app或iOS kill了App，这时删除缓存的工作自然就结束了。
     * 下次App再次进入后台时按目前的逻辑约定，虽然没有完成过一次全部删除，但是假设sohunews(ttURLCache目录)下的缓存图片没有大于500M，
     * 所以不会把当前sohunews(ttURLCache目录)移到trashcanOfTTURLCache目录下并把trashcanOfTTURLCache目录删除掉，
     * 反而是逐一检查并删除每个图片文件。但是为了把那没有删除完的400M删除完，所以补充下面的代码。
     *
     * 另外，如果上面举例的中下次App再次进入后台时，假设sohunews(ttURLCache目录)下的缓存图片大于500M时，这样正好，
     * 可以把当前sohunews(ttURLCache目录)移到trashcanOfTTURLCache目录下把trashcanOfTTURLCache目录删除掉，这样就一并删除上次没有删除完的和新的缓存图片；
     */
    //[_stopWatch begin];
    SNDebugLog(@"===INFO: Ready to clean unfinished trashcanOfTTURLCache");
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* _cachesPath = [paths objectAtIndex:0];
    NSString *_trashCanOfTTURLCache = [_cachesPath stringByAppendingPathComponent:kTrashCanOfTTURLCache];
    _error = nil;
    if ([_outterFileManager fileExistsAtPath:_trashCanOfTTURLCache]) {
        [_outterFileManager removeItemAtPath:_trashCanOfTTURLCache error:&_error];
    }
    if (!!_error) {
        //[[_stopWatch stop] print:@"===Failed to clean unfinished trashcanOfTTURLCache==="];
    } else {
        //[[_stopWatch stop] print:@"===Succeeded to clean unfinished trashcanOfTTURLCache==="];
    }
    


    [self didFinishCheckAndRemoveImgOneByOne];
}

- (void)didFinishCheckAndRemoveImgOneByOne {
    SNDebugLog(@"######INFO: Finish check and remove img onebyone.");
    [self didFinishCleanAll];
}

#pragma mark -

- (void)didFinishCleanAll {
    [self updateLastCleanCacheTimeToNow];
    SNDebugLog(@"\n\n################################################################\n##################### Finish clean all cache #####################\n################################################################\n\n\n");
    [self setTimeoutForTimeIntervalOfCalculatingCacheSize];
    [self markBgTaskAsFinished];
}

- (void)updateLastCleanCacheTimeToNow {
    [SNUserDefaults setObject:[NSDate date] forKey:kLastCleanCacheTime];
}

#pragma mark - Private About background task feature

/**
 * 标记支持后台任务：只要在要运行的代码前调用这个方法那么程序进入后台后会继续执行后面的代码直到标记为结束或超时；
 * example:
 *          [SNDownloadUtility markBgTaskAsBegin];
 *          ...costomize your code...
 */
- (void)markBgTaskAsBegin {
    #if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    if ([self isMultitaskingSupported] && kShouldContinueCleanCacheWhenAppEntersBackground) {
        if (!_backgroundTask || _backgroundTask == UIBackgroundTaskInvalid) {
            _backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [self setTimeoutForTimeIntervalOfCalculatingCacheSize];
                [self markBgTaskAsTimeout];
            }];
        }
    }
    #endif
}

- (void)markBgTaskAsTimeout {
    SNDebugLog(@"######INFO: Bg task had timeout, ready to cancel all clean action.");
    dispatch_async(dispatch_get_main_queue(), ^{
        _isTimeout = YES;
        if (_backgroundTask != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
            _backgroundTask = UIBackgroundTaskInvalid;
        }
    });
}

/**
 * 标记结束后台任务：只要在要运行的代码后面调用这个方法那么程序进入后台后运行完业务逻辑后就会结束后台任务；
 * example:
 *          ...costomize your code...
 *          [SNDownloadUtility markBgTaskAsFinished];
 */
- (void)markBgTaskAsFinished {
    #if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	if ([self isMultitaskingSupported] && kShouldContinueCleanCacheWhenAppEntersBackground) {
		dispatch_async(dispatch_get_main_queue(), ^{
            _isCleaningAutomatically = NO;
            _isCleaningAll = NO;
			if (_backgroundTask != UIBackgroundTaskInvalid) {
				[[UIApplication sharedApplication] endBackgroundTask:_backgroundTask];
				_backgroundTask = UIBackgroundTaskInvalid;
			}
		});
	}
    #endif
}

//判断当前设备是否支持后台任务
- (BOOL)isMultitaskingSupported {
    UIDevice* device = [UIDevice currentDevice];
    return [device respondsToSelector:@selector(isMultitaskingSupported)] && device.multitaskingSupported;
}

- (void)setTimeoutForTimeIntervalOfCalculatingCacheSize {
    NSDate *_timeoutDate = [NSDate dateWithTimeIntervalSinceNow:-kUpdateCacheSizeInterval];
    [SNUserDefaults setObject:_timeoutDate forKey:kCacheSizeUpdateDate];
}

@end
