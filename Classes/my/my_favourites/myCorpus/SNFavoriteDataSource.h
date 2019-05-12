//
//  SNFavoriteDataSource.h
//  sohunews
//
//  Created by 李腾 on 2016/11/4.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNCorpusChannelTopBar.h"
@interface SNFavoriteDataSource : NSObject <SNCorpusChannelTopBarDataSource>

@property (nonatomic, strong) NSMutableArray *channelsArrayM;
@property(nonatomic, weak) SNCorpusChannelTopBar *tabBar;
// datasource
- (NSUInteger)numberOfItemsForTabBar:(SNCorpusChannelTopBar *)tabBar;
- (SNCorpusChannelTopBarItem *)tabBar:(SNCorpusChannelTopBar *)tabBar tabBarItemForIndex:(NSUInteger)index;
@end
