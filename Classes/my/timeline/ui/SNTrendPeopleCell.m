//
//  SNTrendPeopleCell.m
//  sohunews
//
//  Created by jialei on 13-12-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTrendPeopleCell.h"
#import "SNTimelineAttentionListVew.h"

@interface SNTrendPeopleCell()
{
    SNTimelineAttentionListVew *_attentionList;
}

@end

@implementation SNTrendPeopleCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setOriginView
{
    if (!_attentionList) {
        _attentionList = [[SNTimelineAttentionListVew alloc] initWithFrame:_originalContentRect];
        _attentionList.backgroundColor = [UIColor clearColor];
        [self addSubview:_attentionList];
    }
    _attentionList.frame = _originalContentRect;
    _attentionList.attListData = self.timelineTrendObj.originContentObj.attUserArray;
}


@end
