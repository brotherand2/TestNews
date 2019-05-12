//
//  SNSettingCellForScreenShotFeedBack.m
//  sohunews
//
//  Created by 李腾 on 2016/10/22.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNSettingCellForScreenShotFeedBack.h"
#import "SNPreference.h"

@implementation SNSettingCellForScreenShotFeedBack
- (void)setCellData:(NSDictionary *)cellData {
    [super setCellData:cellData];
    NSInteger fbWwitch = [[NSUserDefaults standardUserDefaults] integerForKey:kScreenShotSwitch];
    if (fbWwitch == 0 || fbWwitch == 1) {
        
        _uiswitcher.on = YES;
    } else {
        _uiswitcher.on = NO;
    }
}

- (void)swither:(SNPushSwitcher *)switcher indexDidChanged:(int)newIndex {
    if (newIndex == 0) {
    }
    else {
        
    }
}

- (void)onSwitchChange
{
    if (_uiswitcher.on == NO)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:kScreenShotSwitch];

    }
    else {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:kScreenShotSwitch];
    }
}

@end
