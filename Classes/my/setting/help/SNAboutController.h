//
//  SNAboutController.h
//  sohunews
//
//  Created by 李 雪 on 11-8-1.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNMultiRowsButtonView.h"
#import "SNNewsShareManager.h"

@interface SNAboutController : SNBaseViewController<SNMultiRowsButtonViewDelegate> {
    
    UIImageView *aboutImgView;
    SNMultiRowsButtonView *rowsButtonView;
    
}

@property(nonatomic, strong) UIButton *versionBtn;
@property(nonatomic, strong) SNActionMenuController *actionMenuController;
@property(nonatomic, strong) SNNewsShareManager *shareManager;

@end
