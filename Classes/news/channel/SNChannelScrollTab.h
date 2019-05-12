//
//  SNChannelScrollTab.h
//  sohunews
//
//  Created by Cong Dan on 4/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNChannelScrollTabBar.h"

#import "SNChannelScrollTabItem.h"

@class SNChannelScrollTabBar;

@interface SNChannelScrollTab : UIControl
@property (nonatomic, weak) SNChannelScrollTabItem *tabItem;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *maskTitleLabel;//全屏模式字色变化
@property (nonatomic, assign) CGFloat scale;

- (id)initWithItem:(SNChannelScrollTabItem *)tabItem
            tabBar:(SNChannelScrollTabBar *)tabBar;
- (CGSize)titleSize;

- (void)changeFullscreenMode:(BOOL)fullscreenMode;
- (void)changeFullscreenModeWithRatio:(CGFloat)ratio;

@end
