//
//  SNMoreCellWithIndicatorAndText.m
//  sohunews
//
//  Created by wang yanchen on 13-3-4.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSettingCellWithIndicatorAndText.h"

@implementation SNSettingCellWithIndicatorAndText

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        _indicateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, kMoreViewCellHeight)];
        _indicateLabel.right = _indicatorView.left - 15;
        _indicateLabel.textAlignment = NSTextAlignmentRight;
        _indicateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_indicateLabel];
    }
    return self;
}

- (void)dealloc {
     //(_indicateLabel);
}

- (void)setCellData:(NSDictionary *)cellData {
    [super setCellData:cellData];
    _indicateLabel.textColor = _titleLabel.textColor;
    _indicateLabel.font = _titleLabel.font;
}

@end
