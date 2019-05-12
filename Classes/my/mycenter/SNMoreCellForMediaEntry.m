//
//  SNMoreCellForMediaEntry.m
//  sohunews
//
//  Created by weibin cheng on 13-8-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNMoreCellForMediaEntry.h"

@implementation SNMoreCellForMediaEntry
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.textLabel.hidden = YES;
        _titleLabel.hidden = YES;
        UIImage* image = [UIImage themeImageNamed:@"userinfo_media_icon.png"];
        UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(10, (60-image.size.height)/2, image.size.width, image.size.height);
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 2;
        [self.contentView addSubview:imageView];
        
        
        _indicatorView.top = _indicatorView.top+10;
        _indicateLabel.frame = CGRectMake(22+image.size.width, 0, _indicateLabel.width, 60);
        _indicateLabel.textAlignment = NSTextAlignmentLeft;
        _bgImageView.frame = CGRectMake(0, 0, self.contentView.width, self.contentView.height);
    }
    return self;
}

- (void)setCellData:(NSDictionary *)cellData
{
    [super setCellData:cellData];
    _indicateLabel.text = [_cellData stringValueForKey:kMoreViewCellDicKeyTitle
                                          defaultValue:@""];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _bgImageView.frame = CGRectMake(0, 0, self.contentView.width, self.contentView.height);
}
@end
