//
//  SNVideoChannelHotCategorySectionHeadView.m
//  sohunews
//
//  Created by jojo on 13-10-8.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoChannelHotCategorySectionHeadView.h"
#import "UIColor+ColorUtils.h"
#import "SNChannelManageContants.h"

#define kSectionHeadViewSideMargin              (20 / 2)
#define kSectionHeadViewTitleFont               (20 / 2)
#define kSectionHeadViewTitleLeftMargin         (40 / 2)

@interface SNVideoChannelHotCategorySectionHeadView ()

@property (nonatomic, copy) NSString *title;

- (id)initWithTitle:(NSString *)title;

@end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface _SNVideoSectionHeadViewCenterTitle : SNVideoChannelHotCategorySectionHeadView {
    UILabel *_titleLabel;
}

@end

@implementation _SNVideoSectionHeadViewCenterTitle

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_titleLabel) {
        UIColor *textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDragRefreshUpdateTimeColor]];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSectionHeadViewSideMargin, 0, self.width - 2 * kSectionHeadViewSideMargin, self.height)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = textColor;
        _titleLabel.font = [UIFont systemFontOfSize:kSectionHeadViewTitleFont];
        [self addSubview:_titleLabel];
    }
    
    _titleLabel.frame = CGRectMake(kSectionHeadViewSideMargin, 0, self.width - 2 * kSectionHeadViewSideMargin, self.height);
    _titleLabel.text = self.title;
}

- (void)dealloc {
     //(_titleLabel);
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface _SNVideoSectionHeadViewTitleWithLine : SNVideoChannelHotCategorySectionHeadView {
    UILabel *_titleLabel;
}

@end

@implementation _SNVideoSectionHeadViewTitleWithLine

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_titleLabel) {
        UIColor *textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kDragRefreshUpdateTimeColor]];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSectionHeadViewTitleLeftMargin, 0, self.width - 2 * kSectionHeadViewTitleLeftMargin, kSectionHeadViewTitleFont + 1)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textColor = textColor;
        _titleLabel.font = [UIFont systemFontOfSize:kSectionHeadViewTitleFont];
        [self addSubview:_titleLabel];
    }
    
    _titleLabel.frame = CGRectMake(kSectionHeadViewTitleLeftMargin, 0, self.width - 2 * kSectionHeadViewTitleLeftMargin, kSectionHeadViewTitleFont + 1);
    _titleLabel.centerY = CGRectGetMidY(self.bounds);
    _titleLabel.text = self.title;
    [_titleLabel sizeToFit];
    
    // redraw sep line
    [self setNeedsDisplay];
}

- (void)dealloc {
     //(_titleLabel);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    NSString *grayStrColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor1];
    UIColor *grayColor = [UIColor colorFromString:grayStrColor];
    CGFloat centerY = self.height / 2;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, kSectionHeadViewSideMargin, centerY);
    CGPathAddLineToPoint(path, NULL, _titleLabel.left - 2, centerY);
    
    CGPathMoveToPoint(path, NULL, _titleLabel.right + 2, centerY);
    CGPathAddLineToPoint(path, NULL, self.width - kSectionHeadViewSideMargin, centerY);
    
    CGContextAddPath(ctx, path);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, grayColor.CGColor);
    CGContextStrokePath(ctx);
    
    TT_RELEASE_CF_SAFELY(path);
    CGContextRestoreGState(ctx);
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SNVideoChannelHotCategorySectionHeadView
@synthesize title = _title;

+ (SNVideoChannelHotCategorySectionHeadView *)headViewWithTitle:(NSString *)title headType:(SNVideoSectionHeadType)headType {
    if (headType == SNVideoSectionHeadTypeCenterTitleWithOutLine) {
        return [[_SNVideoSectionHeadViewCenterTitle alloc] initWithTitle:title];
    }
    else if (headType == SNVideoSectionHeadTypeLeadingTitleWithLine) {
        return [[_SNVideoSectionHeadViewTitleWithLine alloc] initWithTitle:title];
    }
    return nil;
}

- (id)initWithTitle:(NSString *)title {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.title = title;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
     //(_title);
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SNVideoChannelHotCategorySectionHeadViewV2
@synthesize title = _title;
@synthesize infoString = _infoString;
@synthesize titleLabel = _titleLabel;
@synthesize infoLabel = _infoLabel;

+ (SNVideoChannelHotCategorySectionHeadViewV2 *)headViewWithTitle:(NSString *)title infoString:(NSString *)infoStr {
    SNVideoChannelHotCategorySectionHeadViewV2 *aHeadView = nil;
    aHeadView = [[SNVideoChannelHotCategorySectionHeadViewV2 alloc] initWithFrame:CGRectZero];
    aHeadView.backgroundColor = [UIColor clearColor];
    aHeadView.title = title;
    aHeadView.infoString = infoStr;
    return aHeadView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.left = 20;
    self.titleLabel.text = self.title;
    self.titleLabel.width = [self.title sizeWithFont:self.titleLabel.font].width;
    
    self.infoLabel.left = self.titleLabel.right + 15;
    self.infoLabel.text = self.infoString;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kChannelSectionViewTextColor]];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.font = [UIFont systemFontOfSize:10];
        _infoLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kChannelSectionViewInfoTextColor]];
        [self addSubview:_infoLabel];
    }
    return _infoLabel;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    
    rect = CGRectMake(10, 0, self.width - 2 * 10, self.height);
    [[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kChannelSectionViewBgColor]] setFill];
    CGContextFillRect(ctx, rect);
    
    CGContextRestoreGState(ctx);
}

- (void)dealloc {
     //(_title);
     //(_infoString);
     //(_titleLabel);
     //(_infoLabel);
}

@end
