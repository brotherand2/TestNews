//
//  SNTableViewDragRefreshDelegate.h
//  sohunews
//
//  Created by Dan on 7/20/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTableHeaderDragRefreshView.h"
#import "SNTableAutoLoadMoreCell.h"
#import "SNRollingLoadMoreCell.h"
#import "SNDragRefreshURLRequestModel.h"
#import "SNTwinsLoadingView.h"
#import "SNAutoPlayVideoContentView.h"

typedef enum {
    SNNewsDragLoadingViewTypeNormal,
    SNNewsDragLoadingViewTypeTwins,
} SNNewsDragLoadingViewType;

@protocol TTModel;
@interface SNTableViewDragRefreshDelegate : TTTableViewVarHeightDelegate<TTModelDelegate> {
	SNDragRefreshURLRequestModel *_model;
    BOOL shouldUpdateRefreshTime;
    
    BOOL canLoadMore;
    BOOL isScrollingDown;
    CGFloat _lastVerticalOffset;
    
    SNTableAutoLoadMoreCell *_moreCell;
    SNRollingLoadMoreCell *_editMoreCell;
    
    SNNewsDragLoadingViewType dragViewType;
    UIScrollView *_pullDownBgView;

    BOOL isLoadingMore;
    int _lastPosition;
}

@property (nonatomic, assign) BOOL isRecommendChannel;
@property (nonatomic, assign) CGFloat topInsetNormal;      // 正常状态topInset
@property (nonatomic, assign) CGFloat topInsetRefresh;     // 下拉刷新时topInset
@property (nonatomic, assign) BOOL isAutoPlay;
@property (nonatomic, strong) UIView *tipsBackView;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) NSString *tipsMessage;

@property (nonatomic, assign) BOOL isHomePage;
@property (nonatomic, strong) SNTwinsLoadingView *dragLoadingView;

- (void)reload;

- (id)initWithController:(TTTableViewController *)controller
                headView:(SNDragRefreshView *)header;

- (void)setDragRefreshView:(SNDragRefreshView *)refreshView;

- (void)setModel:(id<TTModel>)aModel;
- (void)resetTableViewContentInset;
- (void)setDragLoadingViewType:(SNNewsDragLoadingViewType) newType;
- (void)dragLoadingViewRemove;

- (void)setDragLoadingViewNil;
- (void)transformationAutoPlayTop:(TTTableView *)tableView;

- (void)initInsertToast:(NSString *)string channelId:(NSString *)channelId;
- (void)insertToastAnimation;

- (void)newsFullscreenModeToast;
- (void)resetTableViewFullscreenMode;

@end
