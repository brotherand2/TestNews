//
//  SNTableHeaderDragRefreshView.h
//  sohunews
//
//  Created by Dan on 7/20/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTipsView.h"

// The number of pixels the table needs to be pulled down by in order to initiate the refresh.
extern const CGFloat kRefreshDeltaY;

// The height of the refresh header when it is in its "loading" state.
extern const CGFloat kHeaderVisibleHeight;

@interface SNDragRefreshView : UIView

@property (nonatomic, assign) TTTableHeaderDragRefreshStatus state;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) CGFloat refreshStartPosY;

- (void)setCurrentDate;
- (void)setUpdateDate:(NSDate *)date;
- (void)refreshUpdateDate; // 按照设置的Update Date重新设置要显示的文字
- (void)setStatus:(TTTableHeaderDragRefreshStatus)status;
- (void)setStatusText:(NSString *)text;
@end

@interface SNTableHeaderDragRefreshView : SNDragRefreshView {
    SNTipsView *_tipsView;
}

// ui property
@property (nonatomic, assign) CGFloat circleViewDiameter;
@property (nonatomic, strong) UIColor *circleViewBgColor;
@property (nonatomic, strong) UIColor *circleViewMaskColor;

- (id)initWithFrame:(CGRect)frame needTipsView:(BOOL)needTipsView;
- (void)removeObserver;
@end
