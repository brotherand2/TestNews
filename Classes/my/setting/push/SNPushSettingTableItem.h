//
//  SNPushSettingTableItem.h
//  sohunews
//
//  Created by 李 雪 on 11-7-3.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNPushSettingItem.h"
#import "SNPushSettingController.h"
@interface SNPushSettingTableItem : TTTableSubtitleItem {
	int _nType;
    SNPushSettingItem *_pushSettingItem;
    SNPushSettingController *__weak _pushSettingController;
}
@property(nonatomic,assign)int nType;
@property(nonatomic,strong)SNPushSettingItem *pushSettingItem;
@property(nonatomic,weak)SNPushSettingController *pushSettingController;
@end
