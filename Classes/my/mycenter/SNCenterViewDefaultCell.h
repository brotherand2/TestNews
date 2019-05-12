//
//  SNCenterViewTable.h
//  sohunews
//
//  Created by jialei on 13-12-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCommentListTable.h"
#import "SNTimelineCircleModel.h"

@interface SNCenterViewDefaultCell : UITableViewCell

@property (nonatomic, weak) id<SNCommentTableEventDelegate> eventDelegate;
@property (nonatomic, assign) int tableTag;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) SNCircleErrorCode status;

- (void)showLoading;
- (void)hideLoading;
- (void)showError;
- (void)hideError;
- (void)showEmpty:(BOOL)show;
- (void)updateTheme;

@end
