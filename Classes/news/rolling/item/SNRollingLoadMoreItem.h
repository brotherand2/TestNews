//
//  SNRollingLoadMoreItem.h
//  sohunews
//
//  Created by lhp on 8/5/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRollingNews.h"
#import "SNRollingNewsDataSource.h"

@interface SNRollingLoadMoreItem : TTTableSubtitleItem
{
    BOOL isLoadingNews;
    SNRollingNewsDataSource *__weak dataSource;
    SNRollingNews *news;
}

@property(nonatomic,assign)BOOL isLoadingNews;
@property(nonatomic,weak)SNRollingNewsDataSource *dataSource;
@property(nonatomic,strong)SNRollingNews *news;

@end
