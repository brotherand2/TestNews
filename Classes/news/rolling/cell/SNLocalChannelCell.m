//
//  SNLocalChannelCell.m
//  sohunews
//
//  Created by lhp on 4/1/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNLocalChannelCell.h"

@interface SNLocalChannelCell () {
    UILabel *describeLabel;
}

@end

@implementation SNLocalChannelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    
    if (self) {        
        describeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, 150, 14)];
        describeLabel.numberOfLines = 1;
        describeLabel.userInteractionEnabled = NO;
        describeLabel.backgroundColor = [UIColor clearColor];
        describeLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellCommentColor]];
        describeLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:describeLabel];
    }
    return self;
}

- (void)localChannelWithCity:(NSString *)cityName describeInfo:describe {
    [self localChannelWithCity:cityName];
    describeLabel.text = describe;
    if (cityName) {
        CGSize nameSize = [cityName sizeWithFont:[UIFont systemFontOfSize:16.0f]];
        describeLabel.left = 20 + nameSize.width;
    }
}

@end
