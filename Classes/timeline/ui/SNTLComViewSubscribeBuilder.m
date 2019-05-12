//
//  SNTLComViewSubscribeBuilder.m
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTLComViewSubscribeBuilder.h"
#import "UIColor+ColorUtils.h"

@implementation SNTLComViewSubscribeBuilder
@synthesize subId = _subId, subName = _subName, subIcon = _subIcon, subCountNum = _subCountNum;
@synthesize isSubed = _isSubed;

- (void)dealloc {
    TT_RELEASE_SAFELY(_subId);
    TT_RELEASE_SAFELY(_subName);
    TT_RELEASE_SAFELY(_subIcon);
    TT_RELEASE_SAFELY(_subCountNum);
    [super dealloc];
}

- (CGSize)suggestViewSize {
    return CGSizeMake(_suggestViewWidth, kTLViewSubViewHeight);
}

- (void)renderInRect:(CGRect)rect withContext:(CGContextRef)context {
    [super renderInRect:rect withContext:context];
    
    CGFloat startX = CGRectGetMinX(rect);
    CGFloat startY = CGRectGetMinY(rect);
    
    CGRect iconBgRect = CGRectMake(startX + kTLViewSideMargin,
                                   startY + kTLViewSubIconTopMargin,
                                   kTLViewSubIconSize,
                                   kTLViewSubIconSize);
    UIImage *iconBgImage = [UIImage imageNamed:@"subinfo_article_iconBg.png"];
    [iconBgImage drawInRect:iconBgRect];
    
    CGFloat titleWidth = rect.size.width - 2 * kTLViewSubTextLeftMargin;
    NSString *titleTextColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewTitleTextColor];
    [[UIColor colorFromString:titleTextColorStr] set];
    [self.subName textDrawAtPoint:CGPointMake(startX + kTLViewSubTextLeftMargin, startY + kTLViewSubNameTopMargin)
                         forWidth:titleWidth
                         withFont:[UIFont systemFontOfSize:kTLViewTitleFontSize]
                    lineBreakMode:UILineBreakModeTailTruncation
                        textColor:[UIColor colorFromString:titleTextColorStr]];
    
    NSString *countTextColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewFromTextColor];
    [[UIColor colorFromString:countTextColorStr] set];
    NSString *drawText = [NSString stringWithFormat:@"订阅人数 %@", self.subCountNum];
    [drawText textDrawAtPoint:CGPointMake(startX + kTLViewSubTextLeftMargin, startY + rect.size.height - kTLViewSubCountBottomMargin - kTLViewFromFontSize)
                     forWidth:titleWidth
                     withFont:[UIFont systemFontOfSize:kTLViewFromFontSize]
                lineBreakMode:UILineBreakModeTailTruncation
                    textColor:[UIColor colorFromString:countTextColorStr]];
}

- (UIButton *)actionButton {
    if (self.isSubed) return nil;
    
    UIImage *btnImage = [UIImage imageNamed:@"timeline_sub_btn.png"];
    UIImage *btnPressImage = [UIImage imageNamed:@"timeline_sub_btn_p.png"];
    UIButton *aBtn = [[UIButton alloc] initWithFrame:CGRectZero];
    aBtn.size = btnImage.size;
    [aBtn setImage:btnImage forState:UIControlStateNormal];
    [aBtn setImage:btnPressImage forState:UIControlStateHighlighted];
    return [aBtn autorelease];
}

- (UIView *)imageView {
    CGRect iconBgRect = CGRectMake(kTLViewSideMargin,
                                   kTLViewSubIconTopMargin,
                                   kTLViewSubIconSize,
                                   kTLViewSubIconSize);
    
    SNWebImageView *iconView = [[SNWebImageView alloc] initWithFrame:iconBgRect];
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    iconView.defaultImage = [UIImage imageNamed:@"timeline_default.png"];
    [iconView loadUrlPath:self.subIcon];
    return [iconView autorelease];
}

- (CGRect)imageViewFrameForRect:(CGRect)rect {
    return CGRectMake(kTLViewSideMargin + CGRectGetMinX(rect),
                      kTLViewSubIconTopMargin + CGRectGetMinY(rect),
                      kTLViewSubIconSize,
                      kTLViewSubIconSize);
}

- (NSString *)imageUrlPath {
    return self.subIcon;
}

@end
