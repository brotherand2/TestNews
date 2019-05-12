//
//  SNVideosTableBaseCell.m
//  sohunews
//
//  Created by chenhong on 13-9-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideosTableBaseCell.h"

@implementation SNVideosTableBaseCell

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    }
    return self;
}

- (void)setObject:(SNVideoData *)object {
    if (_object != object) {
        _object = nil;
        _object = object;
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
    }
}

- (void)dealloc {
     //(_object);
     //(_cellSelectedBg);
}

#pragma mark - Override
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    [self showSelectedBg:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    
    [self showSelectedBg:selected];
}

- (void)showSelectedBg:(BOOL)show {
    if (show) {
        if (!_cellSelectedBg) {
            _cellSelectedBg = [[UIImageView alloc] init];
            [self insertSubview:_cellSelectedBg atIndex:0];
        }
        _cellSelectedBg.frame = self.bounds;
        _cellSelectedBg.image = [UIImage imageNamed:@"cell-press.png"];
        _cellSelectedBg.alpha = 1;
    } else {
        if (_cellSelectedBg.alpha > 0) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:TT_FAST_TRANSITION_DURATION];
            _cellSelectedBg.alpha = 0;
            [UIView commitAnimations];
        }
    }
}

#pragma mark - Public
+ (CGFloat)height {
    return 0;
}

- (void)playVideoIfNeeded {
}

- (void)playVideoIfNeededIn2G3G {
}

- (void)stopVideoPlayIfPlaying {
}

#pragma mark - About Theme
- (BOOL)needsUpdateTheme {
    BOOL themeChanged = ![_currentTheme isEqualToString:[[SNThemeManager sharedThemeManager] currentTheme]];
    
    if (themeChanged) {
        _currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
    }
    
    return themeChanged;
}

- (void)updateTheme {
    if (_cellSelectedBg) {
        _cellSelectedBg.image = [UIImage imageNamed:@"cell-press.png"];
    }
    self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
}

@end
