//
//  SNRollingPageViewCell.h
//  sohunews
//
//  Created by wangyy on 16/1/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRollingBaseCell.h"
#import "SMPageControl.h"

@interface SNRollingPageViewCell : SNRollingBaseCell<UIScrollViewDelegate>
#define kPageViewCellFocusImageRate                 (360.f/750.f)
#define kCellWidth                      kAppScreenWidth
#define kCellHeight                     kAppScreenWidth * kPageViewCellFocusImageRate
#define kFocusImageHeight               kAppScreenWidth * kPageViewCellFocusImageRate

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) SMPageControl *pageControl;

@property (nonatomic, assign) int currentImageIndex;
@property (nonatomic, strong) NSMutableArray *rollingPageArray;
@property (nonatomic, strong) NSMutableArray *pageImageViews;

@property (nonatomic, strong) UILabel *newsTitle;
@property (nonatomic, strong) UIImageView *videoIcon;
@property (nonatomic, strong) UIImageView *adIcon;
@property (nonatomic, strong) UILabel *adTitle;
@property (nonatomic, strong) UIImageView *titleMarkView;

- (void)updateImage;

- (void)addTimer;
- (void)removeTimer;

@end
