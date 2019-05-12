//
//  SNSettingCellForNoVideoMode.m
//  sohunews
//
//  Created by Scarlett on 16/6/22.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNSettingCellForNoVideoMode.h"
#import "SNPreference.h"

@implementation SNSettingCellForNoVideoMode

- (void)setCellData:(NSDictionary *)cellData {
    [super setCellData:cellData];
    _uiswitcher.on = [SNUtility channelVideoSwitchStatus];
}

- (void)swither:(SNPushSwitcher *)switcher indexDidChanged:(int)newIndex {
    BOOL wifiMode = (newIndex == 1);
    [SNPreference sharedInstance].videoMode = wifiMode ? kPicModeWiFi : kPicModeAlways;
    NSString *modeStr = [NSString stringWithFormat:@"%d", wifiMode ? kPicModeWiFi : kPicModeAlways];
    [[NSUserDefaults standardUserDefaults] setObject:modeStr forKey:kNoneVideoModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([modeStr isEqualToString:[NSString stringWithFormat:@"%d", kPicModeWiFi]]) {

        [SNUtility sendSettingModeType:SNUserSettingVideoMode mode:@"1"];

    }
    else {

        [SNUtility sendSettingModeType:SNUserSettingVideoMode mode:@"0"];

    }
}

- (void)onSwitchChange
{
    BOOL wifiMode = (_uiswitcher.on == YES);
    [SNPreference sharedInstance].videoMode = wifiMode ? kPicModeWiFi : kPicModeAlways;
    NSString *modeStr = [NSString stringWithFormat:@"%d", wifiMode ? kPicModeWiFi : kPicModeAlways];
    [[NSUserDefaults standardUserDefaults] setObject:modeStr forKey:kNoneVideoModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([modeStr isEqualToString:[NSString stringWithFormat:@"%d", kPicModeWiFi]]) {

        [SNUtility sendSettingModeType:SNUserSettingVideoMode mode:@"1"];

    }
    else {

        [SNUtility sendSettingModeType:SNUserSettingVideoMode mode:@"0"];

    }
}


@end
