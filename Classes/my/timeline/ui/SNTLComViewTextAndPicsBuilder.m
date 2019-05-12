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
     //(_title);
     //(_abstract);
     //(_imageUrl);
     //(_imagePath);
     //(_fromString);
     //(_typeString);
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

        [[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewTitleTextColor]] set];
        CGRect titleRect = CGRectMake(startX + kTLViewTextLeftMargin,
                                      startY + kTLViewTitleTopMargin,
                                      rect.size.width - kTLViewTextLeftMargin - kTLViewSideMargin,
                                      2 * kTLViewTitleFontSize + 25);
        [self.title drawInRect:titleRect
                      withFont:[UIFont systemFontOfSize:kTLViewTitleFontSize]
                 lineBreakMode:NSLineBreakByTruncatingTail];
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
        [[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewFromTextColor]] set];

        //ios7 使用drawRect绘制限制宽高的文本
        CGRect textRect = CGRectMake(startX + kTLViewTextLeftMargin,
                                     startY + rect.size.height - kTLViewFromBottomMargin - kTLViewFromFontSize,
                                     rect.size.width - kTLViewTextLeftMargin - kTLViewSideMargin,
                                     [UIFont systemFontOfSize:kTLViewFromFontSize].lineHeight);
        [fromTextToDraw textDrawInRect:textRect
                              withFont:[UIFont systemFontOfSize:kTLViewFromFontSize]
                         lineBreakMode:NSLineBreakByTruncatingTail
                             alignment:NSTextAlignmentLeft
                             textColor:[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTLViewFromTextColor]]];
    }
}

- (UIView *)imageView {
    CGRect iconBgRect = CGRectMake(kTLViewSideMargin,
                                   kTLViewImageTopMarigin,
                                   kTLViewImageWidth,
                                   kTLViewImageHeight);
    CGRect iconDefaultRect = CGRectMake(kTLViewSideMargin +(kTLViewImageWidth - kTLViewImageHeight)/2.f,
                                   kTLViewImageTopMarigin,
                                   kTLViewImageHeight,
                                   kTLViewImageHeight);
    
    SNWebImageView *iconView = [[SNWebImageView alloc] initWithFrame:iconBgRect];
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    iconView.layer.cornerRadius = 2;
    iconView.clipsToBounds = YES;

    UIImage *image = nil;
    if (self.imagePath.length > 0) {
         image = [UIImage imageWithContentsOfFile:self.imagePath];
        iconView.frame = iconDefaultRect;
    }
    if (!image) {
        image = [UIImage imageNamed:self.imagePath];
        iconView.frame = iconDefaultRect;
    }
    iconView.defaultImage = image ? image : [UIImage imageNamed:@"news_default_image.png"];
    if (!image) {
        [iconView loadUrlPath:self.imageUrl];
    }

    //频道预览分享使用sohu icon
    if (_isChannelPreview) {
        iconView.defaultImage = [UIImage imageNamed:@"iOS_114_normal.png"];
        iconView.frame = iconDefaultRect;
    }
    iconView.alpha = [[SNThemeManager sharedThemeManager] isNightTheme] ? 0.7 : 1.0;
    return iconView;
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
        
        UIImage *iconImage = [UIImage imageNamed:@"icohome_videosmall_v5.png"];
        UIImageView *iconImageVIew = [[UIImageView alloc] initWithImage:iconImage];
        iconImageVIew.right = CGRectGetMaxX(iconBgRect) - 2;
        iconImageVIew.bottom = CGRectGetMaxY(iconBgRect) - 2;
        return iconImageVIew;
    }
    return nil;
}

@end
