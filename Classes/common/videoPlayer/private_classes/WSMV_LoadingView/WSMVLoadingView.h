//
//  WSMVLoadingView.h
//  sohunewsipad
//
//  Created by guoyalun on 12/11/12.
//  Copyright (c) 2012 sohu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface WSMVLoadingView : UIView {
    UIImageView   *indicatorView;
}

- (id)initWithSuperView:(UIView *)superView;
- (void)startAnimation;
- (void)stopAnimation;

@end