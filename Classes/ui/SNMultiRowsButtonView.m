//
//  SNMultiRowsButtonView.m
//  sohunews
//
//  Created by guoyalun on 3/21/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNMultiRowsButtonView.h"
#import "UIColor+ColorUtils.h"
//#import <Three20/Three20+Additions.h>
#import "Three20+Additions.h"


#define BASE_TAG     (637)

@implementation SNMultiRowsButtonView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[[UIImage imageWithBundleName:@"round_corner_bg.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] drawInRect:rect];
    
    CGFloat lineHeight = CGRectGetHeight(rect)/rows;
    
    for (int i = 1; i<rows; i++) {
        [[[ UIImage imageWithBundleName:@"line_sep.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0] drawInRect:CGRectMake(1, i*lineHeight, self.bounds.size.width-2, 1)];
    }
}

- (void)setButtonTitles:(NSArray *)titles
{
    rows = titles.count;
    CGFloat lineHeight = CGRectGetHeight(self.bounds)/rows;
    
    [self removeAllSubviews];
    
    for (int i=0; i<rows; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, i*lineHeight, self.bounds.size.width, lineHeight)];
        btn.tag = BASE_TAG+i;
        btn.backgroundColor = [UIColor clearColor];
        UIImage *background = nil;
        if (i==0) {
            background = [UIImage imageWithBundleName:@"topCell.png"];
        } else if (i==MIN(titles.count, rows)-1) {
            background = [UIImage imageWithBundleName:@"bottomCell.png"];
        } else {
            background = [UIImage imageWithBundleName:@"middleCell.png"];
        }
        btn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 17, 0, 0);
        [btn setTitleColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kGroupPhotoTagNormalTextColor]] forState:UIControlStateNormal];
        [btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageWithBundleName:@"arrow.png"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageWithBundleName:@"arrow_hl.png"] forState:UIControlStateNormal];
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -7, 0, 0);
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, kAppScreenWidth-59, 0, 0);
        [btn setBackgroundImage:background forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(buttonTapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
    [self setNeedsDisplay];
}


- (void)buttonTapAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if ([_delegate respondsToSelector:@selector(tapButton:atIndex:)]) {
        [_delegate tapButton:sender atIndex:(btn.tag-BASE_TAG)];
    }
}

- (void)updateTheme
{
    [self setNeedsDisplay];
}

@end
