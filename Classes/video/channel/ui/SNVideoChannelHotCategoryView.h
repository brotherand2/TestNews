//
//  SNVideoHotView.h
//  sohunews
//
//  Created by jojo on 13-9-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNVideoChannelObjects.h"

@class SNWaitingActivityView;

typedef enum {
    SNVideoChannelHotCategoryViewSeplineBottomLeft = 1 << 0,
    SNVideoChannelHotCategoryViewSeplineBottomRight = 1 << 1,
    SNVideoChannelHotCategoryViewSeplineLeft = 1 << 2,
    SNVideoChannelHotCategoryViewSeplineRight = 1 << 3,
}SNVideoChannelHotCategoryViewSepline;

@interface SNVideoChannelHotCategoryView : UIView <UIGestureRecognizerDelegate> {
    SNVideoChannelCategoryObject *_categoryObj;
    
    UILabel *_categoryTitleLabel;
    UILabel *_categoryDesLabel;
    SNWaitingActivityView *_loadingView;
    UIImageView *_subStatusIcon;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL isSubed;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, strong) SNVideoChannelCategoryObject *categoryObj;
@property (nonatomic, assign) SNVideoChannelHotCategoryViewSepline seplineType;

- (void)showLoading:(BOOL)bShow;

// overrides
- (void)viewTappedAction:(id)sender;

@end

@protocol SNVideoChannelHotCategoryViewDelegate <NSObject>

@optional
- (BOOL)shouldUnsubCategory:(SNVideoChannelHotCategoryView *)categoryView;
- (void)snsCategoryWillSub:(SNVideoChannelHotCategoryView *)categoryView;

@end
