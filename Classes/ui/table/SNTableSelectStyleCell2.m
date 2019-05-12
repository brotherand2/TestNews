//
//  SNTableSelectStyleCell2.m
//  sohunews
//
//  Created by Cong Dan on 4/4/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTableSelectStyleCell2.h"

@implementation SNTableSelectStyleCell2

@synthesize showSlectedBg;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        showSlectedBg = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //self.textLabel.frame = CGRectZero;
        self.detailTextLabel.frame = CGRectZero;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        //5.9.3 wangchuanwen update
        //self.contentView.backgroundColor = SNUICOLOR(kThemeBg3Color);
        self.contentView.backgroundColor =  SNUICOLOR(kThemeBgRIColor);
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:KABTestChangeAppStyleNotification object:nil];
    }
    return self;
}

- (void)showSelectedBg:(BOOL)show
{
    if (show) {
        self.contentView.backgroundColor = SNUICOLOR(kThemeBg2Color);
    } else {
        //5.9.3 wangchuanwen update
        //self.contentView.backgroundColor = SNUICOLOR(kThemeBg3Color);
        self.contentView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    }
}

- (BOOL)needsUpdateTheme
{
    BOOL themeChanged = ![_currentTheme isEqualToString:[[SNThemeManager sharedThemeManager] currentTheme]];
    if (themeChanged) {
        _currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
    }
    return themeChanged;
}

- (void)updateTheme
{
    //5.9.3 wangchuanwen update
    //self.contentView.backgroundColor = SNUICOLOR(kThemeBg3Color);
    self.contentView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (!showSlectedBg) {
        return;
    }
    
    BOOL lastHighted = self.isHighlighted;
    [super setHighlighted:highlighted animated:animated];
    if (lastHighted!= highlighted) {
        [self showSelectedBg:highlighted];
    }
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
}
@end
