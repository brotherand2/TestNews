//
//  SNChannelScrollTabBarDataSource.m
//  sohunews
//
//  Created by wang yanchen on 13-1-5.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNChannelScrollTabBarDataSource.h"

@implementation SNChannelScrollTabBarDataSource

- (id)initWithController:(id)controller {
    self = [super init];
    if (self) {
        self.model = [[SNChannelModel alloc] init];
        [self.model.delegates addObject:self];
        if (controller) {
            [self.model addObserver:controller
                         forKeyPath:@"hasNewChannel"
                            options:NSKeyValueObservingOptionNew
                            context:nil];
            [self.model addObserver:controller
                         forKeyPath:@"showLogo"
                            options:NSKeyValueObservingOptionNew
                            context:nil];
        }
        //去掉编辑我的频道提示
        //[self.model addObserver:controller forKeyPath:@"firstLaunch" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)removeObservers:(id)controller {
    @try {
        [self.model removeObserver:controller
                        forKeyPath:@"hasNewChannel"];
        [self.model removeObserver:controller
                        forKeyPath:@"showLogo"];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }

}

- (void)dealloc {

}

- (NSUInteger)numberOfItemsForTabBar:(SNChannelScrollTabBar *)tabBar {
    return self.model.subedChannels.count;
}

- (SNChannelScrollTabItem *)tabBar:(SNChannelScrollTabBar *)tabBar tabBarItemForIndex:(NSUInteger)index {
    SNChannel *ch = [self.model.subedChannels objectAtIndex:index];
    SNChannelScrollTabItem *channelItem = [[SNChannelScrollTabItem alloc] initWithTitle:ch.channelName channelId:ch.channelId];
    channelItem.isRecom = ch.isRecom;
    channelItem.tips = ch.tips;
    channelItem.tipsInterval = ch.tipsInterval;
    channelItem.isLocalChannel = [ch isLocalChannel];
    return channelItem;
}

- (void)modelDidFinishLoad:(id<TTModel>)model {
    if (_tabBar) {
        [_tabBar performSelectorOnMainThread:@selector(reloadChannels) withObject:nil waitUntilDone:[NSThread isMainThread]];
    }
}

- (void)loadFromCache {
    [self.model load:TTURLRequestCachePolicyLocal more:NO];
}

- (void)loadFromServer {
    self.model.savedIDString = self.savedIDString;
    [self.model load:TTURLRequestCachePolicyNetwork more:NO];
}

- (BOOL)shouldReload {
    NSTimeInterval interval = kChannelNewsRefreshInterval;
    NSString *timeKey = [NSString stringWithFormat:kChannelModelRefreshTime];
    id data = [SNUserDefaults objectForKey:timeKey];
    if (data && [data isKindOfClass:[NSDate class]]) {
        return [(NSDate *)[data dateByAddingTimeInterval:interval] compare:[NSDate date]] < 0;
    } else {
        return YES;
    }
}

@end
