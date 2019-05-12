//
//  SNChannelListCell.m
//  sohunews
//
//  Created by lhp on 4/1/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNChannelListCell.h"
#import "SNLabel.h"
#import "SNMoreActionSwitch.h"
#import "SNUserLocationManager.h"
#import "SNWaitingActivityView.h"
#import "SNUserManager.h"

#define kMoreActionIconSize   ([[SNDevice sharedInstance] isPlus]?(81/3):(24))
#define kMoreActionSwitcherWidth 38
#define kRefreshRightDistance 28.0/2

@interface SNChannelListCell () <SNMoreActionSwitchDelegate> {
    SNLabel *cityLabel;
    UIButton *_refreshBtn;
    SNMoreActionSwitch *_switcher;
    UIView *_switcherBackView;
    UIView *_lineView;
    SNWaitingActivityView *_activityView;
}

@end

@implementation SNChannelListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        BOOL isNight = [[SNThemeManager sharedThemeManager] isNightTheme];
        self.selectionStyle = isNight ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleGray;
        
        cityLabel = [[SNLabel alloc] initWithFrame:CGRectMake(kRefreshRightDistance, 10, 300, 25)];
        cityLabel.userInteractionEnabled = NO;
        cityLabel.backgroundColor = [UIColor clearColor];
        cityLabel.textColor = SNUICOLOR(kThemeText2Color);
        cityLabel.linkColor = RGBCOLOR(0xc8, 0, 0);
        cityLabel.disableLinkDetect = YES;
        cityLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        [self addSubview:cityLabel];
        
        UIImage *image = [UIImage imageNamed:@"icolocal_refresh_v5.png"];
        _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshBtn setImage:image forState:UIControlStateNormal];
        [_refreshBtn setImage:[UIImage imageNamed:@"icolocal_refreshpress_v5.png"] forState:UIControlStateHighlighted];
        _refreshBtn.frame = CGRectMake(0, 0, image.size.width + kRefreshRightDistance + 20, self.height);
        _refreshBtn.right = kAppScreenWidth - kRefreshRightDistance/2 - 10;
        [_refreshBtn addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
        
        _switcher = [[SNMoreActionSwitch alloc] initWithFrame:CGRectMake(0, 0, kMoreActionSwitcherWidth, kMoreActionIconSize)];
        _switcher.center = self.center;
        _switcher.backgroundColor = [UIColor clearColor];
        _switcher.delegate = self;
        if (![SNUtility isAllowUseLocation]) {
            _switcher.open = NO;
        }
        else {
            _switcher.open = [[SNUserDefaults objectForKey:kIntelligetnLocationSwitchKey] boolValue];
        }
        _switcherBackView = [[UIView alloc] initWithFrame:CGRectMake(kAppScreenWidth - 100, 0, 100, self.height)];
        _switcherBackView.backgroundColor = [UIColor clearColor];
        _switcher.right = _switcherBackView.width - kRefreshRightDistance - 20;
        [_switcherBackView addSubview:_switcher];
        
        if (kAppScreenWidth == 320.0) {
            _refreshBtn.right = kAppScreenWidth - kRefreshRightDistance/2 - 15;
            _switcher.right = _switcherBackView.width - kRefreshRightDistance - 25;
        }
        
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 0.5)];
        _lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
        _lineView.bottom = self.height-4;
        
        [SNNotificationManager addObserver:self selector:@selector(handleEnterForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)drawSeperateLine {
    [self addSubview:_lineView];
}

- (void)localChannelWithCity:(NSString *) cityName
{
    cityLabel.text = cityName;
    self.accessibilityLabel = cityName;
}

- (void)localChannelWithLocalCity:(NSString *) cityName {
    [self addSubview:_refreshBtn];
    cityLabel.text = cityName;
    if (![SNUtility isAllowUseLocation]) {
        cityLabel.text = kCurrentLocationFail;
        [SNUserDefaults removeObjectForKey:kLocationCityKey];
    }
}

- (void)localIntelligentSearchWithString:(NSString *)string {
    [self addSubview:_switcherBackView];
    cityLabel.text = string;
    [_switcher becomeFirstResponder];
}

- (void)localChannelWithCity:(NSString *)cityName keyWord:(NSString *) keyWord
{
    [cityLabel removeAllHighlightInfo];
    if (keyWord) {
        NSRange r1 = [cityName rangeOfString:keyWord options:NSCaseInsensitiveSearch];
        if (r1.location != NSNotFound && r1.length > 0) {
            [cityLabel addHighlightText:keyWord inRange:r1];
        }
    }
    cityLabel.text = cityName;
}

- (void)refreshAction:(id)sender {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if (![SNUtility isAllowUseLocation]) {
        cityLabel.text = kCurrentLocationFail;
        [self showToast];
        [SNUserDefaults removeObjectForKey:kLocationCityKey];
        return;
    }
    
    [SNNewsReport reportADotGif:@"_act=location&_tp=refresh"];
    if (!_activityView) {
        _activityView = [[SNWaitingActivityView alloc] init];
        [self addSubview:_activityView];
        _activityView.center = _refreshBtn.center;
    }
    [_activityView startAnimating];
    _activityView.hidden = NO;
    _refreshBtn.hidden = YES;
    cityLabel.text = kCurrentLocating;
    
    if ([SNUtility isAllowUseLocation]) {
        [SNUserLocationManager sharedInstance].isRefreshLocation = YES;
        [SNUserLocationManager sharedInstance].isRefreshChannelLocation = NO;
        [[SNUserLocationManager sharedInstance] updateLocation];
    }
    
    [SNUserLocationManager sharedInstance].refreshBlock = ^() {
        [self refreshWaiting];
    };
}

- (void)refreshWaiting {
    _activityView.hidden = YES;
    _refreshBtn.hidden = NO;
    [_activityView stopAnimating];
    if (![SNUtility isAllowUseLocation]) {
        cityLabel.text = kCurrentLocationFail;
    }
    else {
        if ([SNUserLocationManager sharedInstance].localResult != SNLocalChannelResultNone) {
            if ([SNUserLocationManager sharedInstance].localResult == SNLocalChannelResultLocalChannel || [SNUserLocationManager sharedInstance].localResult == SNLocalChannelResultCity)  {
                cityLabel.text = [NSString stringWithFormat:@"%@%@", kCurrentLocationCity, [SNUserDefaults objectForKey:kLocationCityKey]];
            }
            else {
                cityLabel.text = [NSString stringWithFormat:@"%@", [SNUserLocationManager sharedInstance].getResultString];
            }
        }
    }
}

#pragma mark SNMoreActionSwitchDelegate
- (void)moreActionSwitch:(SNMoreActionSwitch *)ationSwitch didChanged:(BOOL)open {
    if (![[SNUtility getApplicationDelegate] isNetworkReachable]) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"network error", @"") toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if (![SNUtility isAllowUseLocation]) {
        _switcher.open = !open;
        [self showToast];
        return;
    }
    
    [SNUserDefaults setObject:[NSNumber numberWithBool:open] forKey:kIntelligetnLocationSwitchKey];

    if (kAppScreenWidth == 320.0) {
        if (open) {
            cityLabel.text = kLightIntelligentSwitchOpen;
        }
        else {
            cityLabel.text = kLightIntelligentSwitchOpen;
        }
    }
    else {
        if (open) {
            cityLabel.text = kIntelligentSwitchOpen;
        }
        else {
            cityLabel.text = kIntelligentSwitchClose;
        }
    }
    _switcher.open = open;
    
    if (open) {
        [SNNewsReport reportADotGif:@"_act=location&_tp=on"];
    }
    else {
        [SNNewsReport reportADotGif:@"_act=location&_tp=off"];
    }
}

- (void)removeRefreshButton {
    [_refreshBtn removeFromSuperview];
    [_switcherBackView removeFromSuperview];
}

- (void)showToast {
    [[SNCenterToast shareInstance] showCenterToastWithTitle:kSettingSysytemLocation toUrl:nil mode:SNCenterToastModeWarning];
}

- (void)handleEnterForeground {
    if (![SNUtility isAllowUseLocation]) {
        _switcher.open = NO;
    }
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
}

@end
