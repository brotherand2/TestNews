//
//  SNVideoDetailHeadItemView.m
//  sohunews
//
//  Created by jojo on 13-9-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoDetailHeadItemView.h"
#import "UIColor+ColorUtils.h"

@implementation SNVideoDetailHeadItemView

- (id)initWithFrame:(CGRect)frame itemTitle:(NSString *)title delegate:(id)delegate {
    self = [super initWithFrame:frame itemTitle:title delegate:delegate];
    if (self) {
        [self setTextFont:(34 / 2)];
    }
    return self;
}

- (void)updateTheme {
    // 无论是否选中  都治显示一种颜色 
    _title.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kVideoDetialSectionHeaderTextColor]];
}

@end
