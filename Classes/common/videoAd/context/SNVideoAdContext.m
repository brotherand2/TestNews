//
//  SNVideoAdContext.m
//  sohunews
//
//  Created by handy wang on 5/6/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNVideoAdContext.h"
#import "SNAppConfigManager.h"
#import "SNAppConfigVideoAd.h"

@interface SNVideoAdContext() {
    SNVideoAdContextCurrentTabValue _currentTab;
    __strong NSMutableDictionary *_tabAndChannelIDDic;
    
    SNVideoAdContextCurrentVideoAdPosition _currentVideoAdPosition;
}
@end

@implementation SNVideoAdContext

#pragma mark - ========Lifecycle========
- (id)init {
    self = [super init];
    if (self) {
        _currentTab = SNVideoAdContextCurrentTabValue_None;
        _tabAndChannelIDDic = [NSMutableDictionary dictionary];
        
        _currentVideoAdPosition = SNVideoAdContextCurrentVideoAdPosition_Unknown;
    }
    return self;
}

+ (instancetype)sharedInstance {
    static SNVideoAdContext *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SNVideoAdContext alloc] init];
    });
    return sharedInstance;
}

#pragma mark - ========Public========
#pragma mark - Current tab
- (void)setCurrentTabIndex:(NSInteger)selectedTabIndex {
    switch (selectedTabIndex) {
        case 0:
            _currentTab = SNVideoAdContextCurrentTabValue_News;
            break;
            
        case 1:
            _currentTab = SNVideoAdContextCurrentTabValue_Video;
            break;
            
        case 2:
            _currentTab = SNVideoAdContextCurrentTabValue_Mine;
            break;
            
            //lijian 2017.02.20 补丁：如果出现3或者更多（现在有4项了不是3项），保证不出错。谁熟悉可以再确认一下更好的修改方式
        case 3:
        default:
            _currentTab = SNVideoAdContextCurrentTabValue_News;
            break;
    }
}

- (NSString *)getObjFromForCDotGif {
    switch ([self getCurrentTab]) {
        case SNVideoAdContextCurrentTabValue_News:
            return @"news";
            break;
        case SNVideoAdContextCurrentTabValue_Video:
            return @"video";
            break;
        case SNVideoAdContextCurrentTabValue_Mine:
            return @"mine";
            break;
        case SNVideoAdContextCurrentTabValue_None:
            return @"unknown";
            break;
    }
}

- (SNBusinessStatisticsObjFrom)getObjFromForExpsGif {
    switch ([self getCurrentTab]) {
        case SNVideoAdContextCurrentTabValue_News:
            return SNBusinessStatisticsObjFromNews;
        default:
            return SNBusinessStatisticsObjFromDefault;
    }
}

- (NSString *)getObjFromIdForCDotGif {
    NSString *objFromId = nil;
    SNVideoAdContextCurrentTabValue currentTab = [self getCurrentTab];
    if (currentTab == SNVideoAdContextCurrentTabValue_News) {
        objFromId = [self getCurrentNewsChannelID];
    } else if (currentTab == SNVideoAdContextCurrentTabValue_Video) {
        objFromId = [self getCurrentVideoChannelID];
    }
    return objFromId;
}

- (void)setCurrentChannelID:(NSString *)channelID {
    SNVideoAdContextCurrentTabValue currentTab = [self getCurrentTab];
    if (currentTab == SNVideoAdContextCurrentTabValue_News) {
        [self setCurrentNewsChannelID:channelID];
    }
    else if (currentTab == SNVideoAdContextCurrentTabValue_Video) {
        [self setCurrentVideoChannelID:channelID];
    }
}

- (NSString *)getCurrentChannelID {
    NSString *currentChannelID = nil;
    SNVideoAdContextCurrentTabValue currentTab = [self getCurrentTab];
    if (currentTab == SNVideoAdContextCurrentTabValue_News) {
        currentChannelID =  [self getCurrentNewsChannelID];
    } else if (currentTab == SNVideoAdContextCurrentTabValue_Video) {
        currentChannelID =  [self getCurrentVideoChannelID];
    }
    return currentChannelID;
}

- (BOOL)doesVideoPlayerNeedLoadAd {
    SNVideoAdContextCurrentTabValue currentTab = [self getCurrentTab];
    
    switch (currentTab) {
        case SNVideoAdContextCurrentTabValue_News: {
            NSString *currentNewsChannelID = [self getCurrentNewsChannelID];
            NSArray *newsChannelIDs = [[[SNAppConfigManager sharedInstance] videoAdConfig] newsChannelIDsOfVideoAdvOn];
            BOOL doesNeed = [newsChannelIDs containsObject:currentNewsChannelID];
            return doesNeed;
            break;
        }
        case SNVideoAdContextCurrentTabValue_Video: {
            NSString *currentVideoChannelID = [self getCurrentVideoChannelID];
            NSArray *videoChannelIDs = [[[SNAppConfigManager sharedInstance] videoAdConfig] videoChannelIDsOfVideoAdvOn];
            BOOL doesNeed = [videoChannelIDs containsObject:currentVideoChannelID];
            return doesNeed;
            break;
        }
        case SNVideoAdContextCurrentTabValue_Mine: {
            return NO;
            break;
        }
        case SNVideoAdContextCurrentTabValue_None: {
            return NO;
            break;
        }
    }
    return NO;
}

- (void)setCurrentVideoAdPosition:(SNVideoAdContextCurrentVideoAdPosition)currentVideoAdPosition {
    _currentVideoAdPosition = currentVideoAdPosition;
}

- (SNVideoAdContextCurrentVideoAdPosition)getCurrerntVideoAdPosition {
    return _currentVideoAdPosition;
}

- (NSString *)getAdTrace {
    SNVideoAdContextCurrentTabValue currentTab = [self getCurrentTab];
    NSString *adTracePattern = @"cat:%d;%d_%@";
    
    if (currentTab == SNVideoAdContextCurrentTabValue_News) {
        NSString *adTrace = [NSString stringWithFormat:adTracePattern, currentTab, currentTab, [self getCurrentNewsChannelID]];
        return adTrace;
    }
    else if (currentTab == SNVideoAdContextCurrentTabValue_Video) {
        NSString *adTrace = [NSString stringWithFormat:adTracePattern, currentTab, currentTab, [self getCurrentVideoChannelID]];
        return adTrace;
    }
    else {
        return nil;
    }
}

- (SNVideoAdContextCurrentTabValue)getCurrentTab {
    return _currentTab;
}

#pragma mark - Private

- (NSString *)getCurrentNewsChannelID {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)SNVideoAdContextCurrentTabValue_News];
    return [_tabAndChannelIDDic objectForKey:key];
}

- (void)setCurrentNewsChannelID:(NSString *)newsChannelID {
    if (newsChannelID.length > 0) {
        NSString *key = [NSString stringWithFormat:@"%ld", (long)SNVideoAdContextCurrentTabValue_News];
        [_tabAndChannelIDDic setObject:newsChannelID forKey:key];
    }
}

- (NSString *)getCurrentVideoChannelID {
    NSString *key = [NSString stringWithFormat:@"%ld", (long)SNVideoAdContextCurrentTabValue_Video];
    return [_tabAndChannelIDDic objectForKey:key];
}

- (void)setCurrentVideoChannelID:(NSString *)videoChannelID {
    if (videoChannelID.length > 0) {
        NSString *key = [NSString stringWithFormat:@"%ld", (long)SNVideoAdContextCurrentTabValue_Video];
        [_tabAndChannelIDDic setObject:videoChannelID forKey:key];
    }
}

@end
