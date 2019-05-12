//
//  SNPushSettingTableCell.h
//  sohunews
//
//  Created by Dan on 8/10/11.
//  update by sampanli
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNPushSettingTableItem.h"
#import "SNMoreSwitcher.h"
#import "SNRollingNews.h"

@interface SNPushSettingTableCell : TTTableViewCell<SNPushSwitcherDelegate> {
    SNPushSettingTableItem *_item;
    SNMoreSwitcher *_switcher;
    UILabel *_nameLabel;
    UIImageView *_indicatorView;
    BOOL novelPushSet;//小说push开关设置
    SNBook * novelBook;//小说信息
}
@property (nonatomic, strong)SNPushSettingTableItem *item;
@property (nonatomic, strong)SNMoreSwitcher *switcher;
@property (nonatomic, strong)UILabel *nameLabel;
@property (nonatomic, strong)UIImageView *indicatorView;
@property (nonatomic, assign)BOOL isNovelPushSetting;//是否是小说push设置入口
@property (nonatomic, assign)BOOL isSNSPushSetting;//SNS push设置

+(float)cellHeight;
- (void)openPushViewWithIndex:(NSInteger)cellIndex;

@end
