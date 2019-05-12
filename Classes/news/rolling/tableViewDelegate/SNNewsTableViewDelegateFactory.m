//
//  SNNewsTableViewDelegateFactory.m
//  sohunews
//
//  Created by chenhong on 14-3-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNNewsTableViewDelegateFactory.h"
#import "SNRollingNewsTableViewDelegate.h"
#import "SNLiveNewsTableViewDelegate.h"
#import "SNGroupPhotoNewsTableViewDelegate.h"
#import "SNSubscribeNewsTableViewDelegate.h"

@implementation SNNewsTableViewDelegateFactory

+ (SNNewsTableViewDelegate *)tableViewDelegateWithNewsChannelType:(SNNewsChannelType)type
                                                        channelId:(NSString *)channelId
                                                       controller:(TTTableViewController *)controller
                                                         headView:(SNDragRefreshView *)header {
    SNNewsTableViewDelegate *delegate = nil;
    // 新闻tab-直播频道
    if (type == NewsChannelTypeLive) {
        delegate = [[SNLiveNewsTableViewDelegate alloc] initWithController:controller headView:header];
        delegate.enablePreload = NO;
    }
    // 新闻tab-微闻频道
    else if (type == NewsChannelTypeWeiboHot) {
        //delegate = [[SNWeiboNewsTableViewDelegate alloc] initWithController:controller headView:header];
        //delegate.enablePreload = YES;
    }
    // 新闻tab-组图频道
    else if (type == NewsChannelTypePhotos) {
        delegate = [[SNGroupPhotoNewsTableViewDelegate alloc] initWithController:controller headView:header];
        delegate.enablePreload = NO;
    }
    // 新闻tab-订阅频道
    else if (type == NewsChannelTypeSubscribe) {
        delegate = [[SNSubscribeNewsTableViewDelegate alloc] initWithController:controller headView:header];
        delegate.enablePreload = NO;
    }
    // 新闻tab-普通新闻频道
    else {
        delegate = [[SNRollingNewsTableViewDelegate alloc] initWithController:controller headView:header];
        delegate.enablePreload = YES;
        if ([channelId isEqualToString:@"1"]) {
            delegate.isRecommendChannel = YES;
        }
    }
    return delegate;
}

@end
