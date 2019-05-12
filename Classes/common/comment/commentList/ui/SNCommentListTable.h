//
//  SNCommentListTable.h
//  sohunews
//
//  Created by jialei on 13-10-11.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTableHeaderDragRefreshView.h"

@protocol SNCommentTableEventDelegate <NSObject>

@optional
- (void)commentTableDragToLoadData:(int)tag;
- (NSDate *)commentTableGetLastRefreshDate:(int)tag;
- (BOOL)commentTableIsLoadHistory:(int)tableTag;
- (BOOL)commentTableIsLoading:(int)tableTag;
- (void)commentTableRefreshModel;
- (void)commentTableEmptyTap;

@end

@interface SNCommentListTable : UITableView
{
    UIImageView *_emptyView;
    UIView *_emptyViewBack;
    UILabel *_emptyLabel;
}

@property (nonatomic, strong) SNTableHeaderDragRefreshView *dragView;
@property (nonatomic, weak) id<SNCommentTableEventDelegate> eventDelegate;
@property (nonatomic, assign) int tableTag;
@property (nonatomic, assign) BOOL isLoading;

- (id)initWithFrame:(CGRect)frame;
- (void)showLoading;
- (void)hideLoading;
- (void)showError;
- (void)hideError;
- (void)showEmpty:(BOOL)show;
//- (void)scrollViewDidEndDragging:(UIScrollView*)scrollView willDecelerate:(BOOL)decelerate;

@end
