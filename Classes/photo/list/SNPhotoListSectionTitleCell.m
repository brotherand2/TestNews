//
//  SNPhotoListSectionTitleCell.m
//  sohunews
//
//  Created by jialei on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNPhotoListSectionTitleCell.h"
#import "SNSeparateLabel.h"

@interface SNPhotoListSectionTitleCell()
{
    SNSeparateLabel *_sectionLabel;
}

@end

@implementation SNPhotoListSectionTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle     = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)dealloc
{
    TT_RELEASE_SAFELY(_sectionLabel);
    
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setObject:(NSString *)title
{
    if (!_sectionLabel)
    {
        float width = [UIScreen mainScreen].bounds.size.width;
        _sectionLabel = [[[SNSeparateLabel alloc]initWithFrame:CGRectMake(0, 0, width, kSeparateLabelHeight)]autorelease];
        [self addSubview:_sectionLabel];
    }
    _sectionLabel.title = title;
    
    [_sectionLabel setNeedsDisplay];
}

@end
