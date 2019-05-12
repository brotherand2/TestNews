//
//  SNChannelScrollTabItem.m
//  sohunews
//
//  Created by Cong Dan on 4/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNChannelScrollTabItem.h"

@implementation SNChannelScrollTabItem
@synthesize title = _title, channelId = _channelId;
@synthesize isRecom = _isRecom;
@synthesize tips = _tips;
@synthesize tipsInterval = _tipsInterval;
@synthesize isLocalChannel = _isLocalChannel;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithTitle:(NSString*)title channelId:(NSString *)channelId {
	self = [self init];
    if (self) {
        self.title = title;
        self.channelId = channelId;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setTabBar:(SNChannelScrollTabBar*)tabBar {
    _tabBar = tabBar;
}



@end
