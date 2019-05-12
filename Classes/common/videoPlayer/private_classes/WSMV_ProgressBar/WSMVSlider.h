//
//  WSSlider.h
//  WeSee
//
//  Created by handy wang on 8/23/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewAdditions+WSMV.h"
#import "WSMVConst.h"

#define kWSSliserInnerBarMarginLeftAndRight (5.0f)

@interface WSMVSlider : UIView
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, assign, readonly) BOOL isHighlighted;
@property (nonatomic, assign) CGFloat minimumValue;
@property (nonatomic, assign) CGFloat maximumValue;
@property (nonatomic, assign) CGFloat progressValue;
@property (nonatomic, assign) CGFloat bufferValue;

@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIImageView *progressView;
@property (nonatomic, strong) UIImageView *bufferView;
@property (nonatomic, strong) UIButton *thumbButton;

- (void)updateSubviewsFrame;
- (void)assignProgressValue:(CGFloat)progressValue;
@end

@protocol WSSliderDelegate
- (void)didTouchDown:(WSMVSlider *)slider;
- (void)didTouchMove:(WSMVSlider *)slider;
- (void)didTouchUp:(WSMVSlider *)slider;
- (void)didTouchCancel:(WSMVSlider *)slider;
@end
