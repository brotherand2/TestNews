//
//  SNSetingCellForReadingMode.m
//  sohunews
//
//  Created by 赵青 on 2016/12/13.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNSetingCellForReadingMode.h"

@implementation SNSetingCellForReadingMode

- (void)setCellData:(NSDictionary *)cellData {
    [super setCellData:cellData];
    
    NSString *picMode = [[NSUserDefaults standardUserDefaults] objectForKey:kNonePictureModeKey];
    NSString *text = @"畅读模式";
    if (picMode.integerValue == 2) {
        text = @"无图模式";
    } else if (picMode.integerValue == 1) {
        text = @"小图模式";
    }
    _indicateLabel.textColor = _titleLabel.textColor;
    _indicateLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    _indicateLabel.text = text;
}

@end
