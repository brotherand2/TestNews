//
//  SNTableSelectStyleCell.m
//  sohunews
//
//  Created by Cong Dan on 4/4/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTableSelectStyleCell.h"

@implementation SNTableSelectStyleCell

- (void)showSelectedBg:(BOOL)show
{
    if (show) {
        if (!_cellSelectedBg) {
            _cellSelectedBg = [[UIImageView alloc] init];
            
            [self insertSubview:_cellSelectedBg atIndex:0];
        }
        _cellSelectedBg.frame = self.bounds;
        _cellSelectedBg.image = [UIImage imageNamed:@"cell-press.png"];
        _cellSelectedBg.alpha = 1; 
    } else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay:TT_FAST_TRANSITION_DURATION];
        _cellSelectedBg.alpha = 0;
        [UIView commitAnimations];
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

-(void)updateTheme {
    if (_cellSelectedBg) {
        _cellSelectedBg.image = [UIImage imageNamed:@"cell-press.png"];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    [self showSelectedBg:highlighted];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    [self showSelectedBg:selected];
}

- (void)dealloc
{
     //(_cellSelectedBg);
    
}



@end
