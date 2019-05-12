//
//  SNRollingNewsHeadlineItem.h
//  sohunews
//
//  Created by Cong Dan on 3/19/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRollingNewsModel.h"
#import "SNRollingNewsTableController.h"
#import "SNRollingNewsTableItem.h"

@interface SNRollingNewsHeadlineItem : TTTableItem {
    NSMutableArray *headlines;
    NSMutableArray *newsList;
    NSMutableArray *photoList;
    NSMutableArray *specailList;
    NSMutableArray *liveList;
    NSMutableArray *allList;

    SNRollingNews *news;
    SNRollingNewsItemType type;
    SNRollingNewsModel *_newsModel;
    SNRollingNewsTableController *__weak controller;
    SNCommonNewsDatasource* __weak dataSource;
    BOOL newsMode;      //有推荐数据时焦点图样式不一样
}

@property (nonatomic, strong) SNRollingNewsModel *newsModel;
@property(nonatomic, strong)NSMutableArray *headlines;
@property(nonatomic, weak)SNRollingNewsTableController *controller;

@property(nonatomic, strong)SNRollingNews *news;
@property(nonatomic, assign)SNRollingNewsItemType type;
@property(nonatomic, strong)NSMutableArray *newsList;
@property(nonatomic, strong)NSMutableArray *photoList;
@property(nonatomic, strong)NSMutableArray *specailList;
@property(nonatomic, strong)NSMutableArray *liveList;
@property(nonatomic, strong)NSMutableArray *allList;
@property(nonatomic, weak)SNCommonNewsDatasource* dataSource;
@property(nonatomic, assign)BOOL newsMode;
@end
