//
//  SNSpecialNewsDataSource.h
//  sohunews
//
//  Created by handy wang on 7/4/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNSpecialNewsModel.h"

@class SNCommonNewsDatasource;
@interface SNSpecialNewsDataSource : TTSectionedDataSource {
    SNSpecialNewsModel *_snModel;
    SNCommonNewsDatasource* _dataSource;
}

@property(nonatomic,strong) SNCommonNewsDatasource* dataSource;

- (id)initWithTermId:(NSString *)termIdParam;

@end
