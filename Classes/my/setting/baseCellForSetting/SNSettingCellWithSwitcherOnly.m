//
//  SNMoreCellWithSwitcherOnly.m
//  sohunews
//
//  Created by wang yanchen on 13-3-4.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSettingCellWithSwitcherOnly.h"

@implementation SNSettingCellWithSwitcherOnly

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
     //(_switcher);
     //(_uiswitcher);
}

- (void)setCellData:(NSDictionary *)cellData {
    [super setCellData:cellData];
    if (_switcher) {
        [_switcher removeFromSuperview];
         //(_switcher);
    }
    if(_uiswitcher){
        [_uiswitcher removeFromSuperview];
         //(_uiswitcher);
    }
    
    CGRect frame = CGRectMake(kAppScreenWidth - 50 - 14,
                              (kMoreViewCellHeight - kPushSettingSwitcherHeight) / 2,
                              50,
                              kPushSettingSwitcherHeight);
    _uiswitcher = [[UISwitch alloc] initWithFrame:frame];
    if([[SNThemeManager sharedThemeManager] isNightTheme])
        _uiswitcher.alpha = 0.6;
    [_uiswitcher addTarget:self action:@selector(onSwitchChange) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_uiswitcher];

    
}

- (void)onSwitchChange
{
    
}
@end
