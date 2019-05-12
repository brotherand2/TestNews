//
//  SNTrendArticleView.m
//  sohunews
//
//  Created by jialei on 13-12-12.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTrendArticleView.h"

@implementation SNTrendArticleView

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
//    UILabel *cmtNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(x,
//                                                                     CGRectGetMaxY(_originalContentRect) +
//                                                                     kTLShareInfoVIewOriginalTimeMargin,
//                                                                     size.width, size.height)];
//    [cmtNumLabel setText:cmtNum];
//    [cmtNumLabel setTextColor:SNUICOLOR(kFloorCommentDateColor)];
//    [cmtNumLabel setFont:[UIFont systemFontOfSize:kTLShareInfoViewTimeFontSize]];
//    [cmtNumLabel setBackgroundColor:[UIColor clearColor]];
//    
//    [self addSubview:cmtNumLabel];
//    [cmtNumLabel release];
    [self setCommentNum];
}

- (void)setCommentsView
{
}

@end
