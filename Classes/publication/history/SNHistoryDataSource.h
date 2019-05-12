//
//  SNCgWangQiDataSource.h
//  sohunews
//
//  Created by wangxiang on 4/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

@class SNHistoryModel;
@interface SNHistoryDataSource : TTSectionedDataSource
{
    SNHistoryModel *_modelHistory;
}

@property (nonatomic,strong) SNHistoryModel *modelHistory;
@end
