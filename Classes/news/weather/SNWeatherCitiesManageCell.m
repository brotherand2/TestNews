//
//  SNWeatherCitiesManageCell.m
//  sohunews
//
//  Created by yanchen wang on 12-7-19.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNWeatherCitiesManageCell.h"
#import "UIColor+ColorUtils.h"

@implementation SNWeatherCitiesManageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing: editing animated: YES];

    if (editing) {
        for (UIView * view in self.subviews) {
            if ([NSStringFromClass([view class]) rangeOfString:@"Reorder"].location != NSNotFound) {
                for (UIView * subview in view.subviews) {
                    if ([subview isKindOfClass: [UIImageView class]]) {
                        ((UIImageView *)subview).image = [UIImage imageNamed: @"channel_sort_icon.png"];
                    }
                }
            }
        }
    }
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {   //给ios7 beta3 适配
        self.contentView.left = 40;
        self.contentView.width = self.width - 40 - 44;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //<--- modified by yanchen on 2012-10-09 for bug #16699 
    if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
        self.alpha = 0.6;
    }
    else {
        self.alpha = 1.0;
    }
    //---> modified by yanchen on 2012-10-09 for bug #16699
    self.textLabel.left = 15;
    self.textLabel.backgroundColor = [UIColor clearColor];

    self.textLabel.textColor= [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoTagNormalTextColor]];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {  //给ios7 beta3 适配
        self.contentView.left = 40;
        self.contentView.width = self.width - 40 - 44;
        for (UIView * view in self.subviews) {
            if ([NSStringFromClass([view class]) rangeOfString:@"Reorder"].location != NSNotFound) {
                view.left = self.width - 44;
                view.height = self.height;
            }
        }
    }
}

@end
