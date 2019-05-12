//
//  SNMoreCellWithTextOnly.m
//  sohunews
//
//  Created by wang yanchen on 13-3-4.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSettingCellWithTextOnly.h"

@implementation SNSettingCellWithTextOnly

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    
    if (self) {
        // Initialization code
        _indicateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, kMoreViewCellHeight)];
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
    _indicateLabel.textColor = self.textLabel.textColor;
    _indicateLabel.font = self.textLabel.font;
}

@end
