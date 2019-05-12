//
//  SNRollingTrainCollectionBaseCell.m
//  sohunews
//
//  Created by HuangZhen on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingTrainCollectionBaseCell.h"

@implementation SNRollingTrainCollectionBaseCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [SNNotificationManager addObserver:self selector:@selector(themeChanged:) name:kThemeDidChangeNotification object:nil];
        self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    }
    return self;
}

- (void)setItem:(SNRollingNews *)item {
    if (self.news != item) {
        self.news = item;
        [self updateTheme];
    }
}

- (void)themeChanged:(NSNotification *)notify {
    [self updateTheme];
}

- (void)updateTheme {
    self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
}

- (void)cellIsDisplaying {
    
}
- (void)cellFullDisplaying {
    
}
- (void)cellDidEndDisplaying {
    
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end
