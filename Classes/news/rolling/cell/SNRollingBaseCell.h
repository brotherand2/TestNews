//
//  SNRollingBaseCell.h
//  sohunews
//
//  Created by lhp on 5/9/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableSelectStyleCell2.h"
#import "SNRollingNewsTableItem.h"
#import "NSCellLayout.h"
#import "SNRollingNewsPublicManager.h"
#import "SNStatisticsManager.h"
#import "SNUninterestedItem.h"

#define kMoreButtonWidth    (74 / 2)
#define kMoreButtonHeight   (74 / 2)

@interface SNCellMoreButton : UIButton {
    UIImageView *_moreImageView;
}
@end

@interface SNRollingBaseCell : SNTableSelectStyleCell2 {
    SNCellMoreButton *moreButton;
    SNRollingNewsTableItem *item;
    UIView *lineView;   //cell分割线 by 5.9.4 wangchuanwen add
    BOOL exposure;      //是否曝光
    BOOL isAdRecom;     //是否为推荐流广告
    NSString *_monitorkey;   //广告唯一标识，用于不感兴趣上报
}

@property (nonatomic, strong) SNRollingNewsTableItem *item;
@property (nonatomic, assign) BOOL exposure;
@property (nonatomic, strong) SNCellMoreView *moreView;
@property (nonatomic, strong) SNUninterestedItem *uninterestedItem;

- (void)updateContentView;
- (SNActionMenuContent *)getShareContentInfo;
- (BOOL)hasUninterested;
- (void)updateTitleColor;
- (void)uninterested;
- (void)updateImage;
- (void)dismissPopover;//qz 关闭pop

+ (void)calculateCellHeight:(SNRollingNewsTableItem *)item;
@end
