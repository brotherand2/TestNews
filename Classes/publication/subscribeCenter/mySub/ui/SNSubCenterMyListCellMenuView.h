//
//  SNSubCenterMyListCellMenuView.h
//  sohunews
//
//  Created by Chen Hong on 12-11-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CacheObjects.h"

/// 我的订阅列表刊物cell菜单
@interface SNSubCenterMyListCellMenuView : UIView {
    id __weak delegate;
    id _object;
    
    UIImageView *_bgView;           // 背景
    UIImageView *_sepLine1;
    UIImageView *_sepLine2;
    
    UIButton *_keepTopBtn;
    UIButton *_pushBtn;
    UIButton *_subBtn;
}

@property(nonatomic,weak) id delegate;
@property(nonatomic,strong) id object;

- (void)updateTheme;

@end

/// SNSubCenterMyListCellMenuViewDelegate
@protocol SNSubCenterMyListCellMenuViewDelegate <NSObject>

@optional
- (void)subCenterMyListCellMenuViewKeepOnTop:(BOOL)bTop;   // 置顶/取消置顶
- (void)subCenterMyListCellMenuViewPushOn:(BOOL)bOn;       // 推送开/关
- (void)subCenterMyListCellMenuViewSubscribeOn:(BOOL)bOn;  // 订阅/取消订阅

@end

