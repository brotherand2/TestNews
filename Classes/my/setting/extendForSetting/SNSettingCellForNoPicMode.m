//
//  SNMoreCellForNoPicMode.m
//  sohunews
//
//  Created by wang yanchen on 13-3-4.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSettingCellForNoPicMode.h"
#import "SNPreference.h"
//#import "JsKitFramework.h"
#import <JsKitFramework/JsKitFramework.h>

@implementation SNSettingCellForNoPicMode

- (void)setCellData:(NSDictionary *)cellData {
    [super setCellData:cellData];
    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        _switcher.accessLabelStr = NSLocalizedString(@"contentMoreNoPic", nil);
        NSString *picMode = [[NSUserDefaults standardUserDefaults] objectForKey:kNonePictureModeKey];
        
        int curIndex = [picMode intValue] == kPicModeAlways ? 0 : 1;
        [_switcher setCurrentIndex:curIndex animated:NO];
    }
    else
    {
        NSString *picMode = [[NSUserDefaults standardUserDefaults] objectForKey:kNonePictureModeKey];
        int on = [picMode intValue] == kPicModeAlways ? NO : YES;
        _uiswitcher.on = on;
    }
}

- (void)swither:(SNPushSwitcher *)switcher indexDidChanged:(int)newIndex {
    BOOL wifiMode = (newIndex == 1);
    [SNPreference sharedInstance].pictureMode = wifiMode ? kPicModeWiFi : kPicModeAlways;
    NSString *modeStr = [NSString stringWithFormat:@"%d", wifiMode ? kPicModeWiFi : kPicModeAlways];
    [[NSUserDefaults standardUserDefaults] setObject:modeStr forKey:kNonePictureModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    [jsKitStorage setItem:[NSNumber numberWithInteger:modeStr.integerValue == 0 ? 0 : 1] forKey:@"settings_imageMode"];
    
    if ([modeStr isEqualToString:[NSString stringWithFormat:@"%d", kPicModeWiFi]]) {

        [SNUtility sendSettingModeType:SNUserSettingImageMode mode:@"1"];

    }
    else {

        [SNUtility sendSettingModeType:SNUserSettingImageMode mode:@"0"];

    }
}

- (void)onSwitchChange
{
    BOOL wifiMode = (_uiswitcher.on == YES);
    [SNPreference sharedInstance].pictureMode = wifiMode ? kPicModeWiFi : kPicModeAlways;
    NSString *modeStr = [NSString stringWithFormat:@"%d", wifiMode ? kPicModeWiFi : kPicModeAlways];
    [[NSUserDefaults standardUserDefaults] setObject:modeStr forKey:kNonePictureModeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    [jsKitStorage setItem:[NSNumber numberWithInteger:modeStr.integerValue == 0 ? 0 : 1] forKey:@"settings_imageMode"];

    if ([modeStr isEqualToString:[NSString stringWithFormat:@"%d", kPicModeWiFi]]) {

        [SNUtility sendSettingModeType:SNUserSettingImageMode mode:@"1"];
    }
    else {

        [SNUtility sendSettingModeType:SNUserSettingImageMode mode:@"0"];

    }
}

@end
