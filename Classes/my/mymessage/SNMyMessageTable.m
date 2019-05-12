//
//  SNMyMessageTable.m
//  sohunews
//
//  Created by jialei on 14-2-20.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNMyMessageTable.h"

@implementation SNMyMessageTable

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

- (void)dealloc
{
     //(_emptyView);
     //(_emptyViewBack);
}

- (void)showEmpty:(BOOL)show
{
    if (show)
    {
        if (!_emptyView)
        {
            
            UIImage *emptyImage = [UIImage imageNamed:@"tome_comment_empty.png"];
            _emptyView = [[UIImageView alloc] initWithImage:emptyImage];
            _emptyView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
            
            _emptyViewBack = [[UIView alloc] initWithFrame:self.bounds];
            _emptyViewBack.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kBackgroundColor]];
            [self addSubview:_emptyViewBack];
            [self addSubview:_emptyView];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap)];
            [self addGestureRecognizer:tap];
#pragma clang diagnostic pop
        }
    }
    else
    {
        if (_emptyView)
        {
            [_emptyView removeFromSuperview];
            [_emptyViewBack removeFromSuperview];
        }
    }
}

- (void)commentTableRefreshModel
{
    if (self.tableTapCallback) {
        self.tableTapCallback();
    }
}

@end
