//
//  SNPhotoSlideCell.h
//  sohunews
//
//  Created by wangyy on 15/5/9.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNPhotoSlideCell : UIView

@property (nonatomic, strong)UIView *adView;
@property (nonatomic, strong)UILabel *adTitle;
@property (nonatomic, strong)UILabel *adLabel;

@property (nonatomic, strong) NSObject *userData;

@property (nonatomic, copy) void(^clickBLock)(SNPhotoSlideCell *);

@end
