//
//  SNMoreCellForCacheClear.m
//  sohunews
//
//  Created by wang yanchen on 13-3-4.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSettingCellForCacheClear.h"

@implementation SNSettingCellForCacheClear

- (void)setCellData:(NSDictionary *)cellData {
    [super setCellData:cellData];
    
    NSString *text = [[NSUserDefaults standardUserDefaults] objectForKey:kCacheSize];//_moreController.strCacheSize;
    
    _indicateLabel.textColor = _titleLabel.textColor;
    _indicateLabel.font = [UIFont digitAndLetterFontOfSize:kThemeFontSizeC];
    _indicateLabel.text = text;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _indicateLabel.right = self.contentView.width - 20;
}

@end

