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

- (void)didMoveToSuperview
{
    SNDebugLog(@"superview class %@", NSStringFromClass(self.superview.class));
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
    [self setCommentNum];
}

- (void)setCommentsView
{
}

- (void)updateTheme {
    [super updateTheme];
}


@end
