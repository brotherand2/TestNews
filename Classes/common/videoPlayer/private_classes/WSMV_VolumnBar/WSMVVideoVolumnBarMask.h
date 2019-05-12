//
//  WSMVVideoVolumnBarMask.h
//  WeSee
//
//  Created by handy on 9/14/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMVVideoVolumnBar.h"

@protocol WSMVVideoVolumnBarMaskDelegate
- (void)hideVolumnBarMask;
@end

@interface WSMVVideoVolumnBarMask : UIView
@property (nonatomic, weak)id                 delegate;
@property (nonatomic, strong)WSMVVideoVolumnBar *volumnBar;
@property (nonatomic, assign)CGRect             volumnBtnFrame;

- (id)initWithFrame:(CGRect)frame volumnBarFrame:(CGRect)volumnBarFrame volumnBtnFrame:(CGRect)volumnBtnFrame;
@end
