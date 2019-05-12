//
//  SNVideoChannelManageView.m
//  sohunews
//
//  Created by jojo on 14-1-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNVideoChannelManageView.h"

@interface SNVideoChannelManageView () {
    UIButton *_manageButton;
}

@end

@implementation SNVideoChannelManageView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *btnImage = [UIImage imageNamed:@"icochannelfloat_setting_v5.png"];
        UIImage *pressImage = [UIImage imageNamed:@"icochannelfloat_settingpress_v5.png"];
        _manageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,
                                                                   btnImage.size.width,
                                                                   btnImage.size.height)];
        [_manageButton setImage:btnImage forState:UIControlStateNormal];
        [_manageButton setImage:pressImage forState:UIControlStateHighlighted];
        _manageButton.backgroundColor = [UIColor clearColor];
        _manageButton.centerY = CGRectGetMidY(self.bounds);
        _manageButton.right = self.width - 7;
        [_manageButton addTarget:self
                          action:@selector(onManageBtnClicked:)
                forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_manageButton];
        
        self.titleLabel.centerX = CGRectGetMidX(self.bounds) - 10;
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
     //(_manageButton);
    [SNNotificationManager removeObserver:self];
}

// overrides
- (void)showEditMode:(BOOL)show {
    [super showEditMode:show];
    
    if (show) {
        [UIView animateWithDuration:kSNChannelManageViewMovingAnimationDuration animations:^{
            _manageButton.alpha = 0;
            self.titleLabel.centerX = CGRectGetMidX(self.bounds);
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        [UIView animateWithDuration:kSNChannelManageViewMovingAnimationDuration animations:^{
            _manageButton.alpha = 1;
            self.titleLabel.centerX = CGRectGetMidX(self.bounds) - 10;
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - actions

- (void)onManageBtnClicked:(id)sender {
    [SNNotificationManager postNotificationName:kSNVideoChannelManageViewDidSelectManageNotify
                                                        object:nil
                                                      userInfo:nil];
}

- (void)updateTheme {
    UIImage *btnImage = [UIImage imageNamed:@"icochannelfloat_setting_v5.png"];
    UIImage *pressImage = [UIImage imageNamed:@"icochannelfloat_settingpress_v5.png"];
    [_manageButton setImage:btnImage forState:UIControlStateNormal];
    [_manageButton setImage:pressImage forState:UIControlStateHighlighted];
    if (self.isSelected) {
        self.titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color];
    }
    else {
        self.titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color];
    }
}

@end
