//
//  SNTwinsMoreView.h
//  SNLoading
//
//  Created by WongHandy on 10/21/14.
//  Copyright (c) 2014 WongHandy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCircleRadius                               (3.0f)
#define kCircleDiameter                             (2 * kCircleRadius)
#define kCircleVPadding                             (2.0f)
#define kTopCircleMarginTopToAnimationView          (5.0f)
#define kBottomCircleMarginBottomToAnimationView    kTopCircleMarginTopToAnimationView
#define kAnimationViewHeight  (kTopCircleMarginTopToAnimationView+kBottomCircleMarginBottomToAnimationView + 2 * kCircleDiameter + kCircleVPadding)

#define kStatusLabelHeight                          (14.0f)

typedef NS_ENUM(NSInteger, SNTwinsMoreStatus) {
    SNTwinsMoreStatusStop,
    SNTwinsMoreStatusLoading
};

@interface SNTwinsMoreView : UIView
@property (nonatomic, assign) SNTwinsMoreStatus status;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIView *animationView;
@end
