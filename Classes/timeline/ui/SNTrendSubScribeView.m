//
//  SNTrendSubScribeView.m
//  sohunews
//
//  Created by jialei on 13-12-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTrendSubScribeView.h"

@implementation SNTrendSubScribeView

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

- (void)setApprovalButton
{
}

//写评论
- (void)setCommentButton
{
//    NSString *cmtNum = [NSString stringWithFormat:@"共有%d条评论", self.timelineTrendObj.commentNum];
//    CGSize size = [cmtNum sizeWithFont:[UIFont systemFontOfSize:kTLShareInfoViewTimeFontSize]];
//    CGFloat x = self.width - kTLOriginalContentTitleTopMargin - size.width;
//    self.cmtNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(x,
//                                                                 CGRectGetMaxY(_originalContentRect) + kTLShareInfoVIewOriginalTimeMargin,
//                                                                 size.width, size.height)];
//    [self.cmtNumLabel setText:cmtNum];
//    [self.cmtNumLabel setTextColor:SNUICOLOR(kFloorCommentDateColor)];
//    [self.cmtNumLabel setFont:[UIFont systemFontOfSize:kTLShareInfoViewTimeFontSize]];
//    [self.cmtNumLabel setBackgroundColor:[UIColor clearColor]];
//    
//    [self addSubview:self.cmtNumLabel];
    [self setCommentNum];
}

- (void)setCommentsView
{
}

- (void)dealloc
{
    [super dealloc];
}
@end
