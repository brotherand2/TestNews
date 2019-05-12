//
//  SNMoreViewBaseCell.h
//  sohunews
//
//  Created by wang yanchen on 13-3-4.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDictionaryExtend.h"
#import "UIColor+ColorUtils.h"
#import "SNSettingViewController.h"
#import "SNBubbleTipView.h"
#import "SNTableViewCell.h"

#define kMoreViewCellHeight             (56)
#define kNewMarkShiftingX               (60)
//#define kNewMarkWidth           (56 / 2)
//#define kNewMarkHeight          (32 / 2)

#define kMoreViewCellDicKeyTitle        (@"title")
#define kMoreViewCellDicKeySelector     (@"selector")
#define kMoreViewCellDicKeyClass        (@"cellClass")
#define kMoreViewCellDicKeyOpenUrl      (@"openUrl")


typedef enum {
    SNMoreCellBgTypeTop,
    SNMoreCellBgTypeMiddle,
    SNMoreCellBgTypeBottom,
    SNMoreCellBgTypeSingle
}SNMoreCellBgType;

@interface SNSettingBaseCell : SNTableViewCell {
    NSDictionary *_cellData;
    
    UIImageView *_bgImageView;
    NSString *_bgImageName;
    SNMoreCellBgType _bgType;
    UILabel* _titleLabel;
    UIViewController *__weak _viewController;
    
    SNBubbleTipView *_newMark;
    
    BOOL _selectable;
}

@property(nonatomic, strong) NSDictionary *cellData;
@property(nonatomic, assign) SNMoreCellBgType cellBgType;
@property(nonatomic, weak) UIViewController *viewController;
@property(nonatomic, copy) NSString *bgImageName;
@property(nonatomic, assign) BOOL selectable;

// override by subclass
- (void)showSelectedBg:(BOOL)show;

- (void)setTipCount:(int)count;

@end

@interface SNSettingViewController (openUrl)

- (void)kickOpenUrl:(SNSettingBaseCell *)cell;
- (void)kickOpenMoreApp:(SNSettingBaseCell *)cell;

@end

