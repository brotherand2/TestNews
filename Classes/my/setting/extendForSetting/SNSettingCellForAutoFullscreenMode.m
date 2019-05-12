//
//  SNMoreCellForAutoFullscreenMode.m
//  sohunews
//
//  Created by wang yanchen on 13-3-4.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSettingCellForAutoFullscreenMode.h"
#import "SNPreference.h"

@implementation SNSettingCellForAutoFullscreenMode

- (void)setCellData:(NSDictionary *)cellData {
    [super setCellData:cellData];
    
    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        _switcher.accessLabelStr = @"新闻正文自动全屏";
        int curIndex = [SNPreference sharedInstance].autoFullscreenMode ? 1 : 0;
        [_switcher setCurrentIndex:curIndex animated:NO];
    }
    else
    {
        BOOL on = [SNPreference sharedInstance].autoFullscreenMode ? YES : NO;
        _uiswitcher.on = on;
    }
}

- (void)swither:(SNPushSwitcher *)switcher indexDidChanged:(int)newIndex {
    BOOL autoScreenMode = (newIndex == 1);
    if ([SNPreference sharedInstance].autoFullscreenMode != autoScreenMode) {
        [SNPreference sharedInstance].autoFullscreenMode = autoScreenMode;
        [[NSUserDefaults standardUserDefaults] setObject:(autoScreenMode ? @"1" : @"0") forKey:kAutoFullscreenModeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)onSwitchChange
{
    BOOL autoScreenMode = (_uiswitcher.on == YES);
    if ([SNPreference sharedInstance].autoFullscreenMode != autoScreenMode) {
        [SNPreference sharedInstance].autoFullscreenMode = autoScreenMode;
        [[NSUserDefaults standardUserDefaults] setObject:(autoScreenMode ? @"1" : @"0") forKey:kAutoFullscreenModeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    [SNUtility sendSettingModeType:SNUserSettingActionBarMode mode:(autoScreenMode ? @"1" : @"0")];
}
@end
