//
//  SNTLComViewTextAndPicsBuilder.m
//  sohunews
//
//  Created by jojo on 13-6-21.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNTLComViewTextAndPicsBuilder.h"
#import "UIColor+ColorUtils.h"

@implementation SNTLComViewTextAndPicsBuilder
@synthesize title = _title;
@synthesize abstract = _abstract;
@synthesize imageUrl = _imageUrl;
@synthesize imagePath = _imagePath;
@synthesize fromString = _fromString;
@synthesize typeString = _typeString;
@synthesize hasVideo = _hasVideo;

- (void)dealloc {
    TT_RELEASE_SAFELY(_title);
    TT_RELEASE_SAFELY(_abstract);
    TT_RELEASE_SAFELY(_imageUrl);
    TT_RELEASE_SAFELY(_imagePath);
    TT_RELEASE_SAFELY(_fromString);
    TT_RELEASE_SAFELY(_typeString);
    [super dealloc];
}

- (CGSize)suggestViewSize {
    return CGSizeMake(_suggestViewWidth, kTLViewViewMaxHeight);
}

- (void)renderInRect:(CGRect)rect withContext:(CGContextRef)context {
    [super renderInRect:rect withContext:context];
    
    CGFloat startX = CGRectGetMinX(rect);
    CGFloat startY = CGRectGetMinY(rect);
    
    // draw title
    if (self.title.length > 0) {
        NSString *titleTextColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewTitleTextColor];
        [[UIColor colorFromString:titleTextColorStr] set];
        CGRect titleRect = CGRectMake(startX + kTLViewTextLeftMargin,
                                      startY + kTLViewTitleTopMargin,
                                      rect.size.width - kTLViewTextLeftMargin - kTLViewSideMargin,
                                      2 * kTLViewTitleFontSize + 5);
        [self.title drawInRect:titleRect
                      withFont:[UIFont systemFontOfSize:kTLViewTitleFontSize]
                 lineBreakMode:UILineBreakModeTailTruncation];
    }
    
    // draw from type
    NSString *fromTextToDraw = nil;
    if (self.useType == kSNTLComViewUseForShareOuter) {
        fromTextToDraw = self.abstract;
    } else if (self.useType == kSNTLComViewUseForShareCircle) {
        if (self.fromString.length > 0) {
            fromTextToDraw = [self.fromString stringByAppendingFormat:@"  %@", self.typeString.length > 0 ? self.typeString : @""];
        }
        else {
            fromTextToDraw = self.typeString;
        }
    }
    
    if (fromTextToDraw.length > 0) {
        NSString *fromTextColorString = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewFromTextColor];
        [[UIColor colorFromString:fromTextColorString] set];

        //ios7 使用drawRect绘制限制宽高的文本
        CGRect textRect = CGRectMake(startX + kTLViewTextLeftMargin,
                                     startY + rect.size.height - kTLViewFromBottomMargin - kTLViewFromFontSize,
                                     rect.size.width - kTLViewTextLeftMargin - kTLViewSideMargin,
                                     [UIFont systemFontOfSize:kTLViewFromFontSize].lineHeight);
        [fromTextToDraw textDrawInRect:textRect
                              withFont:[UIFont systemFontOfSize:kTLViewFromFontSize]
                         lineBreakMode:UILineBreakModeTailTruncation
                             alignment:NSTextAlignmentLeft
                             textColor:[UIColor colorFromString:fromTextColorString]];
    }
}

- (UIView *)imageView {
    CGRect iconBgRect = CGRectMake(kTLViewSideMargin,
                                   kTLViewImageTopMarigin,
                                   kTLViewImageWidth,
                                   kTLViewImageHeight);
    
    SNWebImageView *iconView = [[SNWebImageView alloc] initWithFrame:iconBgRect];
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    iconView.layer.cornerRadius = 2;
    iconView.clipsToBounds = YES;

    UIImage *image = nil;
    if (self.imagePath.length > 0) {
         image = [UIImage imageWithContentsOfFile:self.imagePath];
    }
    iconView.defaultImage = image ? image : [UIImage imageNamed:@"timeline_default.png"];
    if (!image) {
        [iconView loadUrlPath:self.imageUrl];
    }

    return [iconView autorelease];
}

- (CGRect)imageViewFrameForRect:(CGRect)rect {
    return CGRectMake(kTLViewSideMargin + CGRectGetMinX(rect),
                      kTLViewImageTopMarigin + CGRectGetMinY(rect),
                      kTLViewImageWidth,
                      kTLViewImageHeight);
}

- (NSString *)imageUrlPath {
    return self.imageUrl;
}

- (UIView *)videoIconView {
    if (self.hasVideo) {
        CGRect iconBgRect = CGRectMake(kTLViewSideMargin,
                                       kTLViewImageTopMarigin,
                                       kTLViewImageWidth,
                                       kTLViewImageHeight);
        
        UIImage *iconImage = [UIImage imageNamed:@"news_video.png"];
        UIImageView *iconImageVIew = [[UIImageView alloc] initWithImage:iconImage];
        iconImageVIew.right = CGRectGetMaxX(iconBgRect) - 2;
        iconImageVIew.bottom = CGRectGetMaxY(iconBgRect) - 2;
        return [iconImageVIew autorelease];
    }
    return nil;
}

@end
