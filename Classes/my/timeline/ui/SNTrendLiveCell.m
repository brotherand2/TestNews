//
//  SNTrendLiveCell.m
//  sohunews
//
//  Created by jialei on 13-12-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTrendLiveCell.h"

@implementation SNTrendLiveCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
    [super setOriginView];
}

- (void)setOriginTitleAndFrom
{
    [super setOriginTitleAndFrom];
    
    CGFloat startX = CGRectGetMinX(_originalContentRect);
    CGFloat startY = CGRectGetMinY(_originalContentRect);
    CGFloat textWidth = kTLOriginalContentWidth - 2 * kTLOriginalContentTextSideMargin;
    
    //title
    UIFont *titleFont = [UIFont systemFontOfSize:kTLOriginalContentTitleFontSize];
    _originTitleLabel.frame = CGRectMake(kTLOriginalContentTextSideMargin + startX,
                                         kTLOriginalContentTitleTopMargin + startY,
                                         textWidth,
                                         self.timelineTrendObj.originContentObj.titleHeight);
    _originTitleLabel.text = self.timelineTrendObj.originContentObj.title;
    _originTitleLabel.font = titleFont;
    
    //from
    startY += self.timelineTrendObj.originContentObj.titleHeight + kTLOriginalContentFromTopMargin * 2;
    UIFont *fromFont = [UIFont systemFontOfSize:kTLOriginalContentFromFontSize];
    _originFromLabel.frame = CGRectMake(kTLOriginalContentTextSideMargin + startX,
                                        startY,
                                        textWidth,
                                        self.timelineTrendObj.originContentObj.fromHeight);
    _originFromLabel.text = self.timelineTrendObj.originContentObj.fromDisplayString;
    _originFromLabel.font = fromFont;
}

@end
