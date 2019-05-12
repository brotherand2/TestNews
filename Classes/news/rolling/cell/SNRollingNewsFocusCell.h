//
//  SNRollingNewsFocusCell.h
//  sohunews
//
//  Created by lhp on 11/22/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNCellImageView.h"
#import "SNRollingBaseCell.h"

#define kFocusImageRate                 (316.f/640.f)

@interface SNRollingNewsFocusCell : SNRollingBaseCell {
    SNCellImageView *focusImageView;
    UIImageView *titleMarkView;
    UILabel *titleLabel;
    UILabel *adTitleLabel;
    UIImageView *videoIcon;
    UIImageView *adIcon;
    UIImageView *topMarkView;
}

- (void)updateTheme;

@end
