//
//  SNUserSettingRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/1/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseRequest.h"

typedef NS_ENUM(NSUInteger, SNUserSettingModeType) {
    SNUserSettingFontMode       = 0,   // 字体设置
    SNUserSettingImageMode      = 1,   // 用户图片模式
    SNUserSettingVideoMode,            // 视频播放模式
    SNUserSettingNewsPushMode,         // 用户新闻推送模式
    SNUserSettingNovelPushMode,        // 小说推送总开关
    SNUserSettingMediaPushMode,        // 媒体推送，订阅刊物推送总开关
    SNUserSettingDayMode,              // 日夜间模式
    SNUserSettingActionBarMode,        // 滑动隐藏操作栏    !!此项设置经服务端确认并没有对应接口
    SNUserSettingMiniVideoMode,        // 小窗视频
    SNUserSettingLocationMode,         // 本地地理位置
    SNUserSettingHousePropLocationMode,// 房产频道地理位置
    SNUserSettingThemeNight,            //用户智能夜间模式切换开关
    SNUserSettingGetMode              // 获取用户设置
    
};

@interface SNUserSettingRequest : SNBaseRequest <SNRequestProtocol>

- (instancetype)initWithUserSettingMode:(SNUserSettingModeType)userSettingModeType andModeString:(NSString *)modeString;

@end
