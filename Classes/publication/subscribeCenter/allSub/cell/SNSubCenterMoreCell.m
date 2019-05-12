//
//  SNSubCenterMoreCell.m
//  sohunews
//
//  Created by wang yanchen on 12-11-27.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterMoreCell.h"
#import "UIColor+ColorUtils.h"

@implementation SNSubCenterMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _actView = [[SNWaitingActivityView alloc] init];
        _actView.left = 20;
        [_actView startAnimating];
        //[self addSubview:_actView];
        
        _moreAnimationView = [[SNTwinsMoreView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, TT_ROW_HEIGHT * 1.5)];
        [self addSubview:_moreAnimationView];
        _moreAnimationView.status = SNTwinsMoreStatusLoading;
        
        _promtLabel = [[UILabel alloc] initWithFrame:CGRectMake(_actView.right + 20, 0, 220, 30)];
        _promtLabel.backgroundColor = [UIColor clearColor];
        _promtLabel.font = [UIFont systemFontOfSize:15];
//        _promtLabel.text = NSLocalizedString(@"DragToLoadMore", nil);
        _promtLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubCenterAllSubPersonCountTextColor]];
        _promtLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_promtLabel];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    _moreAnimationView.status = SNTwinsMoreStatusStop;
    [_moreAnimationView removeFromSuperview];
    // //(_actView);
     //(_moreAnimationView);
     //(_promtLabel);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //NSInteger length = [_promtLabel.text sizeWithFont:[_promtLabel font]].width;
    _promtLabel.width = 98;
    _promtLabel.textAlignment = NSTextAlignmentCenter;
    _promtLabel.centerY = CGRectGetHeight(self.bounds)/2;
    _moreAnimationView.centerX = CGRectGetWidth(self.bounds)/2;
    
    /*
    if (_actView.isAnimating) {
        _promtLabel.centerX = CGRectGetWidth(self.bounds)/2 + 10;
        _actView.center = CGPointMake(_promtLabel.left - 20, _promtLabel.centerY);
    } else {
        _promtLabel.centerX = CGRectGetWidth(self.bounds)/2;
    }
    */
}

- (void)showLoading:(BOOL)bShow {
    _moreAnimationView.status = bShow ? SNTwinsMoreStatusLoading : SNTwinsMoreStatusStop;
    _moreAnimationView.hidden = !bShow;
    _promtLabel.text = bShow ? @"" : NSLocalizedString(@"DragToLoadMore", nil);
}

- (void)updateTheme {
    //UIActivityIndicatorViewStyle actStyle = [[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight] ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray;
    //_actView.activityIndicatorViewStyle = actStyle;
    
    NSString *textColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubCenterAllSubPersonCountTextColor];
    _promtLabel.textColor = [UIColor colorFromString:textColor];
    
    [_actView updateTheme];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    
}

@end
