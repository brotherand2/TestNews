//
//  SNVideosViewController.h
//  sohunews
//
//  Created by chenhong on 13-8-27.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNThemeViewController.h"
#import "SNChannelScrollTabBar.h"
#import "SNVideoChannelTabbarDataSource.h"

@interface SNVideosViewController : SNThemeViewController <SNChannelScrollTabBarDelegate, UIScrollViewDelegate> {

    UIScrollView *_scrollView;
    
    SNChannelScrollTabBar *_tabBar;
    
    SNVideoChannelTabbarDataSource *_channelDatasource;
    
    NSString *_selectedChannelId;
    
    NSTimeInterval _channelActionDate;
}

@property(nonatomic, strong) NSString *selectedChannelId;
@property(nonatomic, strong) SNChannelScrollTabBar *tabBar;
@property(nonatomic, strong) SNVideoChannelTabbarDataSource *channelDatasource;

@end
