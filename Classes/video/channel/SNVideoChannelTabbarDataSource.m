//
//  SNVideoChannelTabbarDataSource.m
//  sohunews
//
//  Created by jojo on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoChannelTabbarDataSource.h"
#import "SNVideosViewController.h"
#import "SNTimelineSharedVideoPlayerView.h"

#define kVideoChannelRefreshTimeKey         (@"kVideoChannelRefreshTimeKey")
#define kVideoChannelRefreshTimeInterval    (60)

@interface SNVideoChannelTabbarDataSource ()

@property(nonatomic, strong) NSLock *dataSyncLock;
@property(nonatomic, assign) BOOL isSilenceRefresh;

@end

@implementation SNVideoChannelTabbarDataSource
@synthesize dataSyncLock = _dataSyncLock;
@synthesize videoChannels = _videoChannels;
@synthesize subedChannels = _subedChannels;
@synthesize hasNew = _hasNew;
@synthesize hasRefreshedSuccessForOnce;
@synthesize isSilenceRefresh;

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
     //(_dataSyncLock);
     //(_videoChannels);
     //(_subedChannels);
    
}

- (NSMutableArray *)videoChannels {
    if (!_videoChannels) {
        _videoChannels = [[NSMutableArray alloc] init];
    }
    return _videoChannels;
}

- (NSMutableArray *)subedChannels {
    if (!_subedChannels) {
        _subedChannels = [[NSMutableArray alloc] init];
    }
    
    // fill dada
    if (_subedChannels.count == 0) {
        for (SNVideoChannelObject *ch in self.videoChannels) {
            if ([ch.up isEqualToString:@"1"]) {
                [_subedChannels addObject:ch];
            }
        }
        
        // 如果一个订阅的频道没有，说明这很可能是第一次跑起来，没有填充接口新加的up字段，这个时候 默认全都是up的；
        if (_subedChannels.count == 0) {
            for (SNVideoChannelObject *ch in self.videoChannels) {
                ch.up = @"1";
                [_subedChannels addObject:ch];
            }
        }
    }
    
    return _subedChannels;
}

- (NSLock *)dataSyncLock {
    if (!_dataSyncLock) {
        _dataSyncLock = [[NSLock alloc] init];
    }
    return _dataSyncLock;
}

- (void)sychAllVideoChannels:(NSArray *)allChannels {
    if (allChannels.count == 0) {
        return;
    }
    
    [self.dataSyncLock tryLock];
    
    [self.videoChannels removeAllObjects];
    [self.subedChannels removeAllObjects];
    [self.videoChannels addObjectsFromArray:allChannels];
    
    [[SNVideoChannelManager sharedManager] syncAllVideosAndCache:self.videoChannels];
    
    [self.dataSyncLock unlock];
}

// overrides
- (NSUInteger)numberOfItemsForTabBar:(SNChannelScrollTabBar *)tabBar {
    return self.subedChannels.count;
}

- (SNChannelScrollTabItem *)tabBar:(SNChannelScrollTabBar *)tabBar tabBarItemForIndex:(NSUInteger)index {
    SNVideoChannelObject *ch = [self.subedChannels objectAtIndex:index];
    return [[SNChannelScrollTabItem alloc] initWithTitle:ch.title channelId:ch.channelId];
}

- (void)loadFromCache {
    NSArray *channels = [[SNVideoChannelManager sharedManager] loadVideoChannelsFromLocal];
    
    [self.dataSyncLock tryLock];
    
    [self.videoChannels removeAllObjects];
    [self.subedChannels removeAllObjects];
    [self.videoChannels addObjectsFromArray:channels];
    
    [self.dataSyncLock unlock];
    
    if (_tabBar) {
        [_tabBar performSelectorOnMainThread:@selector(reloadChannels) withObject:nil waitUntilDone:[NSThread isMainThread]];
    }
}

- (void)loadFromServer {
    [SNNotificationManager removeObserver:self name:kVideoChannelDidFinishLoadNotification object:nil];
    [SNNotificationManager addObserver:self selector:@selector(videoChannelDidFinishLoad:) name:kVideoChannelDidFinishLoadNotification object:nil];
    
//    [[SNVideoChannelManager sharedManager] loadVideoChannelsFromServer];
}

- (BOOL)shouldReload {
    
    //lijian 2015.05.21 如果当前界面不在视频tab内，就忽略掉
    SNTabBarController *vc = (SNTabBarController *)[TTNavigator navigator].rootViewController;
    UIViewController *controller = [vc.viewControllers objectAtIndex:vc.selectedIndex];
    if(nil != controller && nil != controller.childViewControllers){
        UIViewController *childController = controller.childViewControllers.lastObject;
        if(childController && ![childController isKindOfClass:[SNVideosViewController class]]){
            SNTimelineSharedVideoPlayerView *timelineVideoPlayer = [SNTimelineSharedVideoPlayerView sharedInstance];
            //[SNTimelineSharedVideoPlayerView fakeStop];
            //[SNTimelineSharedVideoPlayerView forceStop];
            [timelineVideoPlayer stop];
            [timelineVideoPlayer resetModel];
            return NO;
        }
    }
    
    NSTimeInterval interval = kVideoChannelRefreshTimeInterval;
    NSString *timeKey = [NSString stringWithFormat:kVideoChannelRefreshTimeKey];
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:timeKey];
    if (data && [data isKindOfClass:[NSDate class]]) {
        return [(NSDate *)[data dateByAddingTimeInterval:interval] compare:[NSDate date]] < 0;
    }
    
    return YES;
}

- (void)saveVideoChannelRefreshTime {
    NSDate *dateNow = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:dateNow forKey:kVideoChannelRefreshTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadFromServerInSilence {
    self.isSilenceRefresh = YES;
    [self loadFromServer];
}

#pragma mark - video channel manager notify handler
- (void)videoChannelDidFinishLoad:(NSNotification *)notification {
    
    [self.dataSyncLock tryLock];
    
    [self.videoChannels removeAllObjects];
    [self.subedChannels removeAllObjects];
    [self.videoChannels addObjectsFromArray:[[SNVideoChannelManager sharedManager] channels]];
    
    [self.dataSyncLock unlock];
    
    if ([notification isKindOfClass:[NSNotification class]]) {
        self.hasNew = [[[notification userInfo] stringValueForKey:@"hasNew" defaultValue:nil] isEqualToString:@"1"];
    }

    [self saveVideoChannelRefreshTime];
    self.hasRefreshedSuccessForOnce = YES;
    
    if (_tabBar) {
        BOOL needReloadAllTables = [self needReloadAllTables];
        if (needReloadAllTables) {
            [SNNotificationManager postNotificationName:kRefreshChannelTabNotification object:nil];
        }
    }
    
    self.isSilenceRefresh = NO;
}

- (BOOL)needReloadAllTables {
    //---
    NSString *oldSelectedChannelID = self.tabBar.selectedTabItem.channelId;
    int oldSelectedTabIndex = 0;
    NSArray *oldTabItems = self.tabBar.tabItems;
    for (int i=0; i< oldTabItems.count; i++) {
        SNChannelScrollTabItem *channelItem = [oldTabItems objectAtIndex:i];
        if ([channelItem.channelId isEqualToString:oldSelectedChannelID]) {
            oldSelectedTabIndex = i;
            break;
        }
    }
    
    NSString *oldLeftChannelID = [@"" copy];
    if ((oldSelectedTabIndex - 1) > 0) {
         //(oldLeftChannelID);
        oldLeftChannelID = [((SNChannelScrollTabItem *)[oldTabItems objectAtIndex:(oldSelectedTabIndex - 1)]).channelId copy];
    }
    
    NSString *oldRightChannelID = [@"" copy];
    if ((oldSelectedTabIndex + 1) < oldTabItems.count) {
         //(oldRightChannelID);
        oldRightChannelID = [((SNChannelScrollTabItem *)[oldTabItems objectAtIndex:(oldSelectedTabIndex + 1)]).channelId copy];
    }
    
    //---
    
    [_tabBar reloadChannels];
    
    //---
    NSString *newSelectedChannelID = self.tabBar.selectedTabItem.channelId;
    int newSelectedTabIndex = 0;
    NSArray *newTabItems = self.tabBar.tabItems;
    for (int i=0; i< newTabItems.count; i++) {
        SNChannelScrollTabItem *channelItem = [newTabItems objectAtIndex:i];
        if ([channelItem.channelId isEqualToString:newSelectedChannelID]) {
            newSelectedTabIndex = i;
            break;
        }
    }
    
    NSString *newLeftChannelID = @"";
    if ((newSelectedTabIndex - 1) >= 0) {
        newLeftChannelID = ((SNChannelScrollTabItem *)[newTabItems objectAtIndex:(newSelectedTabIndex - 1)]).channelId;
    }
    
    NSString *newRightChannelID = @"";
    if ((newSelectedTabIndex + 1) < newTabItems.count) {
        newRightChannelID = ((SNChannelScrollTabItem *)[newTabItems objectAtIndex:(newSelectedTabIndex + 1)]).channelId;
    }
    //---
    
    //频道刷新前后，如果选中频道的位置(index)没有变，且选中频道左右频道还是原来的频道(channelId还是原来的channelId)则不reloadAllTables
    BOOL needReloadAllTables = !((oldSelectedTabIndex == newSelectedTabIndex)
                                 && [oldLeftChannelID isEqualToString:newLeftChannelID]
                                 && [oldRightChannelID isEqualToString:newRightChannelID]);
    
     //(oldLeftChannelID);
     //(oldRightChannelID);
    
    return needReloadAllTables;
}

@end
