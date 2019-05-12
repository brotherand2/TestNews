//
//  SNSpecialNewsTableItem.h
//  sohunews
//
//  Created by handy wang on 7/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNSpecialNews.h"
#import "SNRollingNewsTableItem.h"

#import "SNSpecialNewsModel.h"

@interface SNSpecialNewsTableItem : TTTableSubtitleItem {
    NSString *_termId;
    SNSpecialNews *_news;
    NSMutableArray *_excludePhotoNewsIds;
    NSMutableArray *_photoNewsIds;
    NSMutableArray *_allNews;
    float cellHeight;
    SNRollingNewsItemType _type;
    SNSpecialNewsModel *_snModel;
    SNCommonNewsDatasource* __weak _dataSource;
}

@property(nonatomic, strong)NSString *termId;
@property(nonatomic, strong)SNSpecialNews *news;
@property(nonatomic, strong)NSMutableArray *excludePhotoNewsIds;
@property(nonatomic, strong)NSMutableArray *photoNewsIds;
@property(nonatomic, strong)NSMutableArray *allNews;
@property(nonatomic, assign)float cellHeight;
@property(nonatomic, assign)SNRollingNewsItemType type;
@property(nonatomic, strong)SNSpecialNewsModel *snModel;
@property(nonatomic, weak)SNCommonNewsDatasource* dataSource;
@end
