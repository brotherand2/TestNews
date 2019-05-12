//
//  SNSettingCellForSmallWindowVideoMode.m
//  sohunews
//
//  Created by 赵青 on 2016/10/21.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNSettingCellForSmallWindowVideoMode.h"
#import "SNConsts.h"


@implementation SNSettingCellForSmallWindowVideoMode

- (void)setCellData:(NSDictionary *)cellData {
    [super setCellData:cellData];
    NSString *switche = [[NSUserDefaults standardUserDefaults] objectForKey:kNewsMiniVideoModeKey];
    if (switche  && [switche isEqualToString:@"1"]) {
        _uiswitcher.on = NO;
    } else {
        _uiswitcher.on = YES;
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
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kNewsMiniVideoModeKey];

        [SNUtility sendSettingModeType:SNUserSettingMiniVideoMode mode:@"1"];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:kNewsMiniVideoModeKey];

        [SNUtility sendSettingModeType:SNUserSettingMiniVideoMode mode:@"0"];

    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
