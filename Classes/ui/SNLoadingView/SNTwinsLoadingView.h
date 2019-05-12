//
//  SNTwinsLoadingView.h
//  SNLoading
//
//  Created by WongHandy on 9/30/14.
//  Copyright (c) 2014 WongHandy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SNTwinsLoadingStatus) {
    SNTwinsLoadingStatusReleaseToReload,
    SNTwinsLoadingStatusPullToReload,
    SNTwinsLoadingStatusLoading,
    SNTwinsLoadingStatusNil,
    
    SNTwinsLoadingStatusUpdateTableView,  //用于更新TableViewOffset以及文案
    SNTwinsLoadingStatuStopAniamtion      //用于提前停止动画
};

@interface SNTwinsLoadingView : UIView
@property(nonatomic, assign)SNTwinsLoadingStatus status;

- (id)initWithFrame:(CGRect)frame andObservedScrollView:(UIScrollView *)scrollView;
- (CGFloat)minDistanceCanReleaseToReload;
- (void)setUpdateDate:(NSDate *)newDate;
- (void)setStatusLabel:(NSString *)tip;
- (void)stopAnimations;
- (void)removeObserver;
- (void)resetObservedScrollViewOriginalContentInsetTop:(CGFloat)insetTop;

@end
