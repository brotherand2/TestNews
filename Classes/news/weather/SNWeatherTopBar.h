//
//  SNWeatherTopBar.h
//  sohunews
//
//  Created by yanchen wang on 12-7-18.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDevice.h"

#define kTopBarHeight       ([[SNDevice sharedInstance] isPlus]?(146.0 / 3.0):(44.0))          

@interface SNWeatherTopBar : UIView {
    NSString *_title;
    UILabel *_titleView;
    UIButton *_titleButton;
    UIImageView *_arrowView;
    
    UIImageView *_backgroundView;
}
@property(nonatomic, readonly)UIButton *titleButton;
@property(nonatomic, copy)NSString *title;

// public method
- (void)setBackgroundImage:(UIImage *)image;

@end
