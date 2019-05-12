//
//  WSMVVideoTitleView.h
//  WeSee
//
//  Created by handy wang on 9/6/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSMVVideoTitleViewDelegate
- (BOOL)isFullScreen;
- (void *)didTapRecommendBtn;
@end

@interface WSMVVideoTitleView : UIImageView
@property (nonatomic, weak)id         delegate;
@property (nonatomic, strong)UILabel    *headlineLabel;
@property (nonatomic, strong)UILabel    *subtitleLabel;
@property (nonatomic, strong)UIButton   *recommendBtn;

- (id)initWithFrame:(CGRect)frame delegate:(id)delegateParam;
- (void)updateViewsInFullScreenMode;
- (void)updateViewsInNonScreenMode;
- (void)updateHeadline:(NSString *)headline subtitle:(NSString *)subtitle;
@end
