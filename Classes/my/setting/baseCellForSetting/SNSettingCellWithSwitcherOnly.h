//
//  SNMoreCellWithSwitcherOnly.h
//  sohunews
//
//  Created by wang yanchen on 13-3-4.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSettingBaseCell.h"
#import "SNMoreSwitcher.h"

@class SNMoreSwitcher;

@interface SNSettingCellWithSwitcherOnly : SNSettingBaseCell {
    
    SNMoreSwitcher *_switcher;
    UISwitch *_uiswitcher;
}

- (void)onSwitchChange;
@end
