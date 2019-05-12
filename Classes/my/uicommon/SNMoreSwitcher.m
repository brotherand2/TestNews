//
//  SNMoreSwitcher.m
//  sohunews
//
//  Created by wang yanchen on 12-12-29.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNMoreSwitcher.h"
#import "AFNetworkReachabilityManager.h"

@implementation SNMoreSwitcher
@synthesize accessLabelStr = _accessLabelStr;

- (void)dealloc {
    self.delegate = nil;
    [SNNotificationManager removeObserver:self];
     //(_accessLabelStr);
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.enabel = YES;
        UIImage *image = [UIImage themeImageNamed:@"switch_handler_off.png"];
        _handlerView.image = image;
        
        UIImage *maskImage = [UIImage themeImageNamed:@"switch_background.png"];
        _maskView.image = maskImage;
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];

    }
    return self;
}

- (void)updateTheme {
    UIImage *offImage = [UIImage themeImageNamed:@"subcenter_switcher_handler_off.png"];
    UIImage *bgSliderImage = [UIImage themeImageNamed:@"subcenter_switcher_slider.png"];
    UIImage *maskImage = [UIImage themeImageNamed:@"content_more_switch_background.png"];
    
    _handlerView.image = offImage;
    _bgSliderView.image = bgSliderImage;
    _maskView.image = maskImage;
    
}

- (void)switchAnimationDidStop:(BOOL)isEvent {
    if (_currentIndex == 0) {
        _handlerView.image = [UIImage themeImageNamed:@"switch_handler_off.png"];
    }
    else {
        _handlerView.image = [UIImage themeImageNamed:@"switch_handler_on.png"];
    }
    
    if (_lastIndex!=_currentIndex) {
        _lastIndex=_currentIndex;
        if (isEvent) {
            if ([_delegate respondsToSelector:@selector(swither:indexDidChanged:)]) {
                [_delegate swither:self indexDidChanged:_currentIndex];
            }
        }
    }
}

- (void)setCurrentIndex:(int)index animated:(BOOL)animated inEvent:(BOOL)isInEvent {
    
    //wangchuanwen 小说修改 无网络不可点击
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    if (reachabilityManager.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"暂时无法连接网络" toUrl:nil mode:SNCenterToastModeError];
        return;
    }
    
    if (self.enabel) {
        [super setCurrentIndex:index animated:animated inEvent:isInEvent];
        
        if (self.accessLabelStr.length > 0) {
            [self setAccessibilityLabel:[NSString stringWithFormat:@"%@开关 当前状态：%@",
                                         self.accessLabelStr,
                                         _currentIndex == 0 ? @"关闭" : @"打开"]];
        }
    }
}

@end
