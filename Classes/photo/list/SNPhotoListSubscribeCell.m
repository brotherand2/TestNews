//
//  SNPhotoListSubscribeCell.m
//  sohunews
//
//  Created by jialei on 13-8-28.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNPhotoListSubscribeCell.h"
#import "SNSubInfoView.h"

@interface SNPhotoListSubscribeCell()
{
    SNSubInfoView *_subInfoView;
}

@end

@implementation SNPhotoListSubscribeCell

+ (float)heightForSubscribeCell
{
    return kViewHeight_Article + 10;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setObject:(SCSubscribeObject *)subObj
{
    self.selectionStyle     = UITableViewCellSelectionStyleNone;
    
    if (!_subInfoView)
    {
        _subInfoView = [[SNSubInfoView alloc] initWithSubInfoViewType:SNSubInfoViewTypeArticle];
        _subInfoView.refer = REFER_PHOTOLISTNEWS;
        _subInfoView.left = 4;
        
        [self addSubview:_subInfoView];
    }
    
    _subInfoView.subObj = subObj;
    [self setNeedsDisplay];
}

@end
