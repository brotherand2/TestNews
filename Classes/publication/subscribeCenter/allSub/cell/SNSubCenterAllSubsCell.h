//
//  SNSubCenterAllSubsCell.h
//  sohunews
//
//  Created by wang yanchen on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNWebImageView.h"
#include "SNTableViewCell.h"

@class SNStarGradeView;
@class SCSubscribeObject;
@class SNWaitingActivityView;

@interface SNSubCenterAllSubsCell : SNTableViewCell {
    SCSubscribeObject *_subObj;
    
    UIButton *_subButton;
    SNWaitingActivityView *_loadingView;
    
    UIImageView *_sepLine;
    
    UIImageView *_subIconBgnView;
    SNWebImageView *_subIconView;
    
    UILabel *_subNameLabel;
    
    SNStarGradeView *_starGradeView;
    
    UILabel *_subPersonCountLabel;
    
    id __weak _delegate;
    
    BOOL _isRunning;
    
    UIImageView *_cellSelectedBg;
}

@property(nonatomic, strong) SCSubscribeObject *subObj;
@property(nonatomic, weak) id delegate;
@property(nonatomic, assign) BOOL isRunning;

@end

@protocol SNSubCenterAllSubCellDelegate <NSObject>

@optional
- (void)allSubCellWillAddMySub:(SCSubscribeObject *)subObj;
- (void)allSubCell:(SNSubCenterAllSubsCell *)cell willAddMySub:(SCSubscribeObject *)subObj;

@end
