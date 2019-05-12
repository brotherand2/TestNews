//
//  SNSpecialNewsTableCell.h
//  sohunews
//
//  Created by handy wang on 7/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTableSelectStyleCell.h"
#import "SNLabel.h"
#import "SNWebImageView.h"
#import "SNSpecialNewsCellBackView.h"

@interface SNSpecialNewsTableCell : SNTableSelectStyleCell {

    SNLabel *_abstractLabel;
    SNWebImageView *_iconImageView;
    
    UIImageView *_mask;
    UIImageView *_videoMaskView;
    UIImageView *_voteMaskView;
    BOOL isNewItem;
}

@property(nonatomic, strong, readonly)SNLabel *abstractLabel;
@property(nonatomic, strong, readonly)SNWebImageView *iconImageView;
@property(nonatomic, strong, readonly)UIImageView *mask;
@property(nonatomic, readonly) UIImageView *videoMaskView;
@property(nonatomic, readonly) UIImageView *voteMaskView;
@property(nonatomic, strong) SNSpecialNewsCellBackView *backView;

- (void)setAlreadyReadStyle;

- (void)setUnReadStyle;

- (void)setReadStyleByMemory;

- (void)updateTheme;

@end
