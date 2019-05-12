//
//  SNTripletsLoadingView.h
//  SNLoading
//
//  Created by WongHandy on 10/11/14.
//  Copyright (c) 2014 WongHandy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SNTripletsLoadingStatus) {
    SNTripletsLoadingStatusStopped,
    SNTripletsLoadingStatusLoading,
    SNTripletsLoadingStatusNetworkNotReachable,
    SNTripletsLoadingStatusEmpty,
};

@interface SNTripletsLoadingView : UIView
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) SNTripletsLoadingStatus status;

- (void)layoutTriplets;
- (void)setColorVideoMode:(BOOL)isVideo;
- (void)setColorBackgroundClear;
- (void)setNotReachableIndicatorOffsetY:(CGFloat)offsetY;

- (void)showEmptyViewWithImage:(UIImage *)image withTitle:(NSString *)title;

@end

@protocol SNTripletsLoadingViewDelegate  <NSObject>
- (void)didRetry:(SNTripletsLoadingView *)tripletsLoadingView;
@end
