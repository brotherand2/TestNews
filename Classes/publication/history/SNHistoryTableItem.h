//
//  SNHistoryTableItem.h
//  sohunews
//
//  Created by wangxiang on 4/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNHistoryItem;
@class SNHistoryModel;
@interface SNHistoryTableItem : TTTableSubtitleItem
{
    SNHistoryItem *_historyItem;
    SNHistoryModel *__weak _historyModels;
}

@property (nonatomic, strong) SNHistoryItem *historyItem;
@property (nonatomic, weak) SNHistoryModel *historyModels;

@end
