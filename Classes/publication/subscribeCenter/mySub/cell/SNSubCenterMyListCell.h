//
//  SNSubCenterMyListCell.h
//  sohunews
//
//  Created by Chen Hong on 12-11-20.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNSubCenterBaseCell.h"
#import "SNSubCenterMyListCellMenuView.h"
#import "SNWebImageView.h"
#import "SNGuideRegisterViewController.h"

#define CELL_H                              (148.0 / 2)
#define CELL_W                              320.0


// 我的订阅
@interface SNSubCenterMyListCell : SNSubCenterBaseCell<SNSubCenterMyListCellMenuViewDelegate> {
    UIView                  *_backView;
    UIImageView             *_iconBGView;
    SNWebImageView          *_iconView;
    UILabel                 *_titleLabel;
    UILabel                 *_topNewsLabel;
    UILabel                 *_timeLabel;
    UIImageView             *_pinView;          // 置顶

    // badge
    UIImageView             *_badgeView;      // badge标记
    UIImage                 *_unreadImg;
    UIImage                 *_downloadedImg;
    // menu
    SNSubCenterMyListCellMenuView *_cellMenuView;
    
    BOOL isNewItem;
    BOOL _bShowMenu;

    id _parentController;
    NSIndexPath *_indexPath;
    
    onLoginComplete _onComp;
}

@property(nonatomic,strong) id parentController;
@property(nonatomic,strong) NSIndexPath *indexPath;
@property(nonatomic, copy) onLoginComplete onComp;

- (void)showMenu:(BOOL)bShow;

- (void)refreshBadgeView;

- (void)didSelect:(SCSubscribeObject *)obj;

@end
