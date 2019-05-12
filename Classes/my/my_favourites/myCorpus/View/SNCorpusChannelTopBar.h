//
//  SNCorpusChannelTopBar.h
//  sohunews
//
//  Created by TengLi on 2017/9/21.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCorpusChannelTopBarItem.h"

@class SNCorpusChannelTopBar;

@protocol SNCorpusChannelTopBarDelegate <NSObject>

@optional
- (void)tabBar:(SNCorpusChannelTopBar *)tabBar tabSelected:(NSInteger)selectedIndex;

- (void)tabBarChannelReloaded;

@end

@protocol SNCorpusChannelTopBarDataSource <NSObject>

@required
- (NSUInteger)numberOfItemsForTabBar:(SNCorpusChannelTopBar *)tabBar;
- (SNCorpusChannelTopBarItem *)tabBar:(SNCorpusChannelTopBar *)tabBar tabBarItemForIndex:(NSUInteger)index;

@end

@interface SNCorpusChannelTopBar : UIView
@property (nonatomic, assign) NSInteger selectedTabIndex;
@property (nonatomic, strong) SNCorpusChannelTopBarItem *selectedCorpusTabItem;
@property (nonatomic, strong) NSArray *tabItems;
@property (nonatomic, weak) id<SNCorpusChannelTopBarDelegate> delegate;
@property (nonatomic, weak) id<SNCorpusChannelTopBarDataSource> dataSource;

- (instancetype)initWithEditHandle:(void(^)(UIButton *editBtn))handle;
- (void)reloadChannels:(NSInteger)index;
- (void)editButtonEnabled:(BOOL)enable; // 管理按钮是否可点
@end


