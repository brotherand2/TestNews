//
//  SNSubCenterBaseCell.m
//  sohunews
//
//  Created by Chen Hong on 13-1-9.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterBaseCell.h"


@implementation SNSubCenterBaseCell
@synthesize object=_object;

- (void)dealloc
{
     //(_cellSelectedBg);
     //(_object);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setObject:(id)object {
    if (object != _object) {
        _object = object;
    }
}

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
        if (_cellSelectedBg.alpha > 0) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:TT_FAST_TRANSITION_DURATION];
            _cellSelectedBg.alpha = 0;
            [UIView commitAnimations];
        }
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

@end
