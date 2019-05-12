//
//  SNChannelScrollTab.m
//  sohunews
//
//  Created by Cong Dan on 4/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNChannelScrollTab.h"
#import "SNDynamicPreferences.h"
#import "SNCheckManager.h"
#import "SNTrainCellHelper.h"

@interface SNChannelScrollTab (){
    BOOL _fullScreenMode;
}

@end

@implementation SNChannelScrollTab

@synthesize tabItem = _tabItem;

- (id)initWithItem:(SNChannelScrollTabItem *)tabItem
            tabBar:(SNChannelScrollTabBar *)tabBar {
    self = [super init];
    if (self) { 
        self.tabItem = tabItem;
        self.backgroundColor = [UIColor clearColor];
        
        NSString *normalColorString = [[SNDynamicPreferences sharedInstance] getDynmicColor:kThemeTextUpdateColor type:SNTopFontColorDefaultType];
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
        self.titleLabel.textColor = [UIColor colorFromString:normalColorString];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.text = self.tabItem.title;
        [self addSubview:self.titleLabel];
        self.maskTitleLabel = [[UILabel alloc] init];
        self.maskTitleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
        self.maskTitleLabel.textColor = [SNTrainCellHelper newsTitleColor];
        self.maskTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.maskTitleLabel.backgroundColor = [UIColor clearColor];
        self.maskTitleLabel.text = self.tabItem.title;
        [self addSubview:self.maskTitleLabel];
        self.maskTitleLabel.alpha = 0;
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kLoadFinishDynamicPreferencesNotification object:nil];
    }
    return self;
}

- (CGSize)titleSize {
    if (self.titleLabel.text) {
        return [self.titleLabel.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    } else {
        return CGSizeZero;
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (void)setScale:(CGFloat)scale {
    CGFloat ratio = MAX(0, scale);
    ratio = MIN(1, ratio);
    _scale = ratio;
    self.transform = CGAffineTransformMakeScale(1.0 + 0.06 * _scale,
                                                1.0 + 0.06 * _scale);
    NSString *normalColorString = [[SNDynamicPreferences sharedInstance] getDynmicColor:kThemeTextUpdateColor type:SNTopFontColorDefaultType];
    NSString *selectedColorString = [[SNDynamicPreferences sharedInstance] getDynmicColor:kThemeRed1Color type:SNTopFontColorSelectedType];
    UIColor *normalColor = [UIColor colorFromString:normalColorString];
    UIColor *selectedColor = [UIColor colorFromString:selectedColorString];
    if (_fullScreenMode && [self.tabItem.channelId isEqualToString:@"1"]) {
        selectedColor = normalColor;
    }
    CGFloat newScale = 0.2;
    if ([SNCheckManager checkDynamicPreferences] && [[SNThemeManager sharedThemeManager] isNightTheme]) {
        newScale = 0.4;
    }
    if (_scale < newScale) {
        self.titleLabel.textColor = normalColor;
    }
    else if (_scale > 0.8) {
        self.titleLabel.textColor = selectedColor;
    }
    else {
        self.titleLabel.textColor = [UIColor mixColor1:selectedColor color2:normalColor ratio:_scale];
    }
}

- (void)setTabItem:(SNChannelScrollTabItem *)tabItem {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (tabItem != _tabItem) {
        [_tabItem performSelector:NSSelectorFromString(@"setTabBar:") withObject:nil];
        _tabItem = tabItem;
        [_tabItem performSelector:NSSelectorFromString(@"setTabBar:") withObject:self];
        if ([_tabItem.channelId isEqualToString:@"1"]) {
            if ([_tabItem.title isEqualToString:@"首页"]) {
                _tabItem.title = @"要闻";
            }
        }
        self.titleLabel.text = _tabItem.title;
        self.maskTitleLabel.text = self.titleLabel.text;
    }
#pragma clang diagnostic pop
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    NSString *normalColorString = [[SNDynamicPreferences sharedInstance] getDynmicColor:kThemeTextUpdateColor type:SNTopFontColorDefaultType];
    NSString *selectedColorString = [[SNDynamicPreferences sharedInstance] getDynmicColor:kThemeRed1Color type:SNTopFontColorSelectedType];
    UIColor *normalColor = [UIColor colorFromString:normalColorString];
    UIColor *selectedColor = [UIColor colorFromString:selectedColorString];

    if (selected) {
        if (self.size.width > 0) {
            self.transform = CGAffineTransformMakeScale(1.06, 1.06);
        }
        self.titleLabel.textColor = selectedColor;
    } else {
        self.transform = CGAffineTransformIdentity;
        self.titleLabel.textColor = normalColor;
    }
    self.maskTitleLabel.textColor = [SNTrainCellHelper newsTitleColor];
}

- (void)updateTheme {
    if (self.selected) {
        self.selected = YES;
    }
    else {
        self.selected = NO;
    }
}

- (void)changeFullscreenMode:(BOOL)fullscreenMode {
    _fullScreenMode = fullscreenMode;
    if (_fullScreenMode) {
        self.titleLabel.alpha = 0;
        self.maskTitleLabel.alpha = 1;
    }else{
        self.titleLabel.alpha = 1;
        self.maskTitleLabel.alpha = 0;
        [self updateTheme];
    }
}

- (void)changeFullscreenModeWithRatio:(CGFloat)ratio {
    ratio = MAX(0, ratio);
    ratio = MIN(1, ratio);
    self.titleLabel.alpha = ratio;
    self.maskTitleLabel.alpha = 1 - ratio;
}

@end
