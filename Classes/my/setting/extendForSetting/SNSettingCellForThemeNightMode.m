//
//  SNSettingCellForThemeNightMode.m
//  sohunews
//
//  Created by wangyy on 2017/2/6.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSettingCellForThemeNightMode.h"

@implementation SNSettingCellForThemeNightMode

- (void)setCellData:(NSDictionary *)cellData {
    [super setCellData:cellData];

    NSNumber *switchValue = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsThemeNightSwitch];
    if (switchValue  && switchValue.boolValue == NO) {
        _uiswitcher.on = NO;
    } else {
        //默认开启
        _uiswitcher.on = YES;
        
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
            //获取自动关闭夜间模式时间戳 (业务规定早上7点)
            NSDate *date = [SNUtility getSettingValidTime:7];
            [[NSUserDefaults standardUserDefaults] setObject:date forKey:kNewsThemeNightValidTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)onSwitchChange
{
    if (_uiswitcher.on == NO){
        [SNUtility sendSettingModeType:SNUserSettingThemeNight mode:@"0"];
    }
    else {
        [SNUtility sendSettingModeType:SNUserSettingThemeNight mode:@"1"];
        
        if ([[SNThemeManager sharedThemeManager] isNightTheme]) {
            //获取自动关闭夜间模式时间戳 (业务规定早上7点)
            NSDate *date = [SNUtility getSettingValidTime:7];
            [[NSUserDefaults standardUserDefaults] setObject:date forKey:kNewsThemeNightValidTime];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:_uiswitcher.on] forKey:kNewsThemeNightSwitch];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
