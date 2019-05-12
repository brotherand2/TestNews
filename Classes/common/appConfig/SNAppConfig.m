//
//  SNAppConfig.m
//  sohunews
//
//  Created by handy wang on 5/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNAppConfig.h"
#import "SNAppConfigConst.h"

@implementation SNAppConfig

@synthesize appInterestOpen;
@synthesize sogouButtonShow;
@synthesize pullNewsTips;
@synthesize localChannelUpdateShow;
@synthesize floatingLayer = _floatingLayer;
@synthesize redPacketSwitch = _redPacketSwitch;
@synthesize redPacketSlideNum = _redPacketSlideNum;

- (id)init {
    self = [super init];
    if (self) {
        _isGuideInterestShow = YES; //默认为开启状态
        self.videoAdConfig = [[SNAppConfigVideoAd alloc] init];
        self.activity = [[SNAppConfigActivity alloc] init];
        self.popupActivity = [[SNPopupActivity alloc] init];//弹窗活动相关控制
        self.voiceCloud = [[SNAppConfigVoiceCloud alloc] init];//听新闻相关控制
        _redoRegisterClient = NO;
        self.requestMonitorConditions = [[SNAppConfigRequestMonitorConditions alloc] init];//网络请求监控的抽样条件
        self.festivalIcon = [[SNAppConfigFestivalIcon alloc] init];
        _reshowSplashInterval = MAXFLOAT;
        self.floatingLayer = [[SNAppConfigFloatingLayer alloc] init];
        self.cameraConfig = [[SNCameraConfig alloc] init];
        self.appConfigTabbar = [[SNAppConfigTabBar alloc] init];

        self.appConfigTimeControl = [[SNAppConfigTimeControl alloc] init];
        self.appConfigHttpsSwitch = [[SNAppConfigHttpsSwitch alloc] init];
        self.appConfigScheme = [[SNAppConfigScheme alloc] init];
        self.appconfigH5RedPacket = [[SNAppConfigH5RedPacket alloc] init];
        self.appConfigMPLink = [[SNAppConfigMPLink alloc] init];
        self.appNewsSettingConfig = [[SNNewsSettingConfig alloc] init];

        self.ppLoginOpen = @"0";//默认 关 2017.11.14确认 wangshun

    }
    return self;
}

- (void)dealloc {
    _isGuideInterestShow = NO;
}

- (NSString *)description {
    NSString *isGuideInterestShow = [NSString stringWithFormat:@"%d", _isGuideInterestShow];
    NSString *redoRegisterClient = [NSString stringWithFormat:@"%d", _redoRegisterClient];
    
    NSDictionary *desc = @{keyIsGuideInterestShow:(isGuideInterestShow ?: @""),
                           kVideoAdConfigGroup:_videoAdConfig,
                           kPopupActivity:_popupActivity,
                           kRedoRegisterClient:(redoRegisterClient ?: @""),
                           kRequestMonitorConditions:_requestMonitorConditions
                           };
    
    return [desc description];
}

@end
