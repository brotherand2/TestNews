//
//  AFPageControlCustom.m
//  AFCommon
//
//  Created by 阿凡树( http://blog.afantree.com ) on 13-2-24.
//  Copyright (c) 2013年 ManGang. All rights reserved.
//

#import "AFPageControl.h"

@implementation AFPageControl
- (void)setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];
    for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
        UIImageView* subview = [self imageViewForSubview:[self.subviews objectAtIndex:subviewIndex]];
        if (subview && [subview isKindOfClass:[UIImageView class]]) {
            if (subviewIndex == page){
                [subview setImage:[UIImage imageNamed:@"icohome_bigdot_v5.png"]];
            }else{
                [subview setImage:[UIImage imageNamed:@"icohome_smadot_v5.png"]];
            }
        }
    }
}

- (UIImageView *) imageViewForSubview: (UIView *) view
{
    CGSize size;
    size.height = 5;
    size.width = 5;
    [view setFrame:CGRectMake(view.frame.origin.x-3, view.frame.origin.y,
                                 size.width,size.height)];
    UIImageView * dot = nil;
    if ([view isKindOfClass: [UIView class]])
    {
        for (UIView* subview in view.subviews)
        {
            if ([subview isKindOfClass:[UIImageView class]])
            {
                dot = (UIImageView *)subview;
                break;
            }
        }
        if (dot == nil)
        {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
            [view addSubview:dot];
        }
    }
    else
    {
        dot = (UIImageView *) view;
    }
    
    return dot;
}

@end
