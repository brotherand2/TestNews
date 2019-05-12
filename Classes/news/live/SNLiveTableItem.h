//
//  SNLiveTableItem.h
//  sohunews
//
//  Created by yanchen wang on 12-6-14.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//
#import "CacheObjects.h"
@protocol SNLiveCellDelegate;
@interface SNLiveTableItem : TTTableSubtitleItem {
    LivingGameItem *_gameItem;
}

@property (nonatomic, strong) LivingGameItem *gameItem;

@end
