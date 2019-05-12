//
//  SNSpecialHeadlineNewsTableItem.h
//  sohunews
//
//  Created by handy wang on 7/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNSpecialNewsModel.h"
#import "SNCommonNewsDatasource.h"
@interface SNSpecialHeadlineNewsTableItem : TTTableItem {
    
    NSString *_termId;
    NSMutableArray *_headlines;
    NSMutableArray *_excludePhotoNewsIds;
    NSMutableArray *_photoNewsIds;
    NSMutableArray *_allNewsIds;
    SNSpecialNewsModel *_snModel;
    SNCommonNewsDatasource* __weak _dataSource;
}

@property(nonatomic, strong)NSString *termId;
@property(nonatomic, strong)NSMutableArray *headlines;
@property(nonatomic, strong)NSMutableArray *excludePhotoNewsIds;
@property(nonatomic, strong)NSMutableArray *photoNewsIds;
@property(nonatomic, strong)NSMutableArray *allNewsIds;
@property(nonatomic, strong)SNSpecialNewsModel *snModel;
@property(nonatomic, weak)SNCommonNewsDatasource* dataSource;
@end
