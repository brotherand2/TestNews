//
//  WSMVLoadingMaskView.h
//  sohunews
//
//  Created by Gao Yongyue on 13-10-29.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSMVLoadingView;
@class SNTripletsLoadingView;

@interface WSMVLoadingMaskView : UIView

@property (nonatomic, assign) BOOL showUserGuide;
@property (nonatomic, strong) SNTripletsLoadingView *loadingView;
- (id)initWithFrame:(CGRect)frame showUserGuide:(BOOL)showUserGuide;

- (void)startLoadingViewAnimation;
- (void)stopLoadingViewAnimation;
- (void)reset;
@end
