//
//  SNPhotosChannelDataSource.m
//  sohunews
//
//  Created by wang yanchen on 13-1-5.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNPhotosChannelDataSource.h"
#import "CacheObjects.h"

@implementation SNPhotosChannelDataSource
@synthesize model = _model;

- (id)init {
    self = [super init];
    if (self) {
        _model = [[SNTagPhotoModel alloc] init];
        [_model.delegates addObject:self];
    }
    return self;
}

- (void)dealloc {
    TT_RELEASE_SAFELY(_model);
    [super dealloc];
}

- (NSUInteger)numberOfItemsForTabBar:(SNChannelScrollTabBar *)tabBar {
    return _model.subedCategories.count;
}

- (SNChannelScrollTabItem *)tabBar:(SNChannelScrollTabBar *)tabBar tabBarItemForIndex:(NSUInteger)index {
    CategoryItem *ch = [_model.subedCategories objectAtIndex:index];
    return [[[SNChannelScrollTabItem alloc] initWithTitle:ch.name channelId:ch.categoryID] autorelease];
}

- (void)modelDidFinishLoad:(id<TTModel>)model {
    if (_tabBar) {
        [_tabBar performSelectorOnMainThread:@selector(reloadChannels) withObject:nil waitUntilDone:[NSThread isMainThread]];
    }
}

- (void)loadFromCache {
    // not need
}

- (void)loadFromServer {
    //query update from server
    [_model load:TTURLRequestCachePolicyNone more:NO];
}

@end
