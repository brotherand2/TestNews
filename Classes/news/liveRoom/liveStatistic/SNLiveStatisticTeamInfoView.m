//
//  SNLiveStatisticTeamInfoView.m
//  sohunews
//
//  Created by wang yanchen on 13-4-26.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNLiveStatisticTeamInfoView.h"
#import "UIColor+ColorUtils.h"
#import "NSAttributedString+Attributes.h"
#import "SNLiveRoomConsts.h"

#define kSideMargin             (20 / 2)
#define kTitleTopMargin         (30 / 2)
#define kTitleFont              (40 / 2)
#define kTableTopMargin         (104 / 2)
#define kLeftTitleColumnWidth   (160 / 2)
#define kRowHeight              (58 / 2)

#define kTeamInfoViewHeight     (292 / 2)

#define kLeftTopTitleFont       (24 / 2)
#define kColumnTitleFont        (26 / 2)
#define kScoreFont              (22 / 2)

@interface SNLiveStatisticScoreBoard : UIView
@property(nonatomic, strong) SNLiveStatisticModel *liveModel;
@end

@implementation SNLiveStatisticScoreBoard
@synthesize liveModel = _liveModel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setLiveModel:(SNLiveStatisticModel *)liveModel {
     //(_liveModel);
    _liveModel = liveModel;
    
    // reset frame and superview`s content size
    self.width = _liveModel.hostTeamScores.count * (([[UIScreen mainScreen] applicationFrame].size.width - 2 * kSideMargin - kLeftTitleColumnWidth) / 5);
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollview = (UIScrollView *)self.superview;
        [scrollview setContentSize:CGSizeMake(self.width, self.height)];
    }
    
    [self setNeedsDisplay];
}

- (void)dealloc {
     //(_liveModel);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat startX = 0, startY = 0;
    CGFloat columnWidth = 0;
    NSString *drawText = nil;
    CGRect drawTextRect = CGRectZero;
    NSInteger columnNum = MAX(_liveModel.hostTeamScores.count, _liveModel.visitTeamScores.count);
    if (columnNum > 0) {
        columnWidth = self.width / columnNum;
    }
    
    // draw column title
    [[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveStatisticTextColor]] set];
    
    for (NSString *columnStr in _liveModel.columnsTitleForTeam) {
        drawText = columnStr;
        drawTextRect = CGRectMake(startX,
                                  startY,
                                  columnWidth,
                                  kRowHeight);
        
        drawTextVerticalCenter(drawTextRect,
                               drawText,
                               [UIFont systemFontOfSize:kColumnTitleFont],
                               NSLineBreakByTruncatingTail,
                               NSTextAlignmentCenter);
        
        startX += columnWidth;
    }
    
    // draw score
    startX = 0;
    startY += kRowHeight;
    
    for (NSString *scoreStr in _liveModel.hostTeamScores) {
        drawText = scoreStr;
        drawTextRect = CGRectMake(startX,
                                  startY,
                                  columnWidth,
                                  kRowHeight);
        
        drawTextVerticalCenter(drawTextRect,
                               drawText,
                               [UIFont digitAndLetterFontOfSize:kScoreFont],
                               NSLineBreakByTruncatingTail,
                               NSTextAlignmentCenter);
        
        startX += columnWidth;
    }
    
    startX = 0;
    startY += kRowHeight;
    
    for (NSString *scoreStr in _liveModel.visitTeamScores) {
        drawText = scoreStr;
        drawTextRect = CGRectMake(startX,
                                  startY,
                                  columnWidth,
                                  kRowHeight);
        
        drawTextVerticalCenter(drawTextRect,
                               drawText,
                               [UIFont digitAndLetterFontOfSize:kScoreFont],
                               NSLineBreakByTruncatingTail,
                               NSTextAlignmentCenter);
        
        startX += columnWidth;
    }
    
    // draw lines
    
    startX = 0;
    startY = kRowHeight * 2;
    
    CGFloat lineWidth = [[UIScreen mainScreen] scale] == 2 ? 0.5 : 1;
    CGContextSetLineWidth(context, lineWidth);
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, startX, startY);
    CGPathAddLineToPoint(path, NULL, self.width, startY);
    
    startX = columnWidth;
    startY = 0;
    
    for (int i = 0; i < columnNum; ++i) {
        CGPathMoveToPoint(path, NULL, startX, startY);
        CGPathAddLineToPoint(path, NULL, startX, startY + 3 * kRowHeight);
        
        startX += columnWidth;
    }
    
    CGContextSetStrokeColorWithColor(context, [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveStatisticLineColor]].CGColor);
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    CFRelease(path);
}

@end

@implementation SNLiveStatisticTeamInfoView
@synthesize liveModel = _liveModel;

- (id)initWithFrame:(CGRect)frame
{
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    frame.size.width = appFrame.size.width;
    frame.size.height = kTeamInfoViewHeight;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIColor *scoreColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameScoreTextColor]];
        UIColor *textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameInfoTextColor]];
        
        _titleLabel = [[SNLabel alloc] initWithFrame:CGRectMake(kSideMargin,
                                                                          kTitleTopMargin,
                                                                          self.width - 2 * kSideMargin,
                                                                          kTitleFont + 10)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = textColor;
        _titleLabel.linkColor = scoreColor;
        _titleLabel.disableLinkDetect = YES;
        _titleLabel.font = [UIFont systemFontOfSize:kTitleFont];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.breakMode = NSLineBreakByTruncatingTail;
        [self addSubview:_titleLabel];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
     //(_liveModel);
     //(_titleLabel);
     //(_scoreBoard);
     //(_rightScrollView);
     //(_rightShadowView);
}

- (void)setLiveModel:(SNLiveStatisticModel *)liveModel {
    if (_liveModel != liveModel) {
         //(_liveModel);
        _liveModel = liveModel;
        
        NSString *titleStr = [NSString stringWithFormat:@"%@ %@ : %@ %@",
                              _liveModel.hostTeamName,
                              _liveModel.hostTeamScore,
                              _liveModel.visitTeamScore,
                              _liveModel.visitTeamName];
  
        NSRange searchRange = NSMakeRange(_liveModel.hostTeamName.length,
                                          titleStr.length - _liveModel.hostTeamName.length - _liveModel.visitTeamName.length);
        
        NSRange hostScoreRange = [titleStr rangeOfString:_liveModel.hostTeamScore options:NSCaseInsensitiveSearch range:searchRange];
        NSRange visitScoreRange = [titleStr rangeOfString:_liveModel.visitTeamScore options:NSBackwardsSearch range:searchRange];
        
        [_titleLabel removeAllHighlightInfo];
        [_titleLabel addHighlightText:_liveModel.hostTeamScore inRange:hostScoreRange];
        [_titleLabel addHighlightText:_liveModel.visitTeamScore inRange:visitScoreRange];
        _titleLabel.text = titleStr;
    }
    
    if (!_rightScrollView) {
        _rightScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kSideMargin + kLeftTitleColumnWidth,
                                                                          kTableTopMargin,
                                                                          self.width - 2 * kSideMargin - kLeftTitleColumnWidth,
                                                                          kRowHeight * 3)];
        _rightScrollView.bounces = NO;
        _rightScrollView.showsHorizontalScrollIndicator = NO;
        _rightScrollView.delegate = self;
        [self addSubview:_rightScrollView];
    }
    
    if (!_scoreBoard) {
        _scoreBoard = [[SNLiveStatisticScoreBoard alloc] initWithFrame:CGRectMake(0, 0, _rightScrollView.width, _rightScrollView.height)];
        [_rightScrollView addSubview:_scoreBoard];
    }
    
    _scoreBoard.liveModel = _liveModel;
    
    NSInteger columnNum = MAX(_liveModel.hostTeamScores.count, _liveModel.visitTeamScores.count);
    // 四节比赛 + 1节加时  + 总分  
    if (columnNum > 5) {
        UIImage *shadowImage = [UIImage imageNamed:@"live_statistic_left_mask.png"];
        _rightShadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, shadowImage.size.width, _rightScrollView.height)];
        _rightShadowView.right = _rightScrollView.right;
        _rightShadowView.top = _rightScrollView.top;
        _rightShadowView.image = [shadowImage stretchableImageWithLeftCapWidth:0 topCapHeight:10];
        [self addSubview:_rightShadowView];
    }
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (_liveModel) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        // draw bg
        CGContextSaveGState(context);
        
        CGContextSetFillColorWithColor(context, [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveStatisticColumnColor]].CGColor);
        CGRect columnArea = CGRectMake(kSideMargin,
                                       kTableTopMargin,
                                       self.width - 2 * kSideMargin,
                                       kRowHeight);
        CGContextFillRect(context, columnArea);
        CGContextRestoreGState(context);
        
        // draw text
        CGContextSaveGState(context);
        
        NSString *drawText = nil;
        CGRect drawTextRect = CGRectZero;
        CGFloat startX = kSideMargin;
        CGFloat startY = kTableTopMargin;
        [[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveStatisticTextColor]] set];
        
        // 时间
        drawTextRect = CGRectMake(startX + kLeftTitleColumnWidth / 2,
                                  startY,
                                  kLeftTitleColumnWidth / 2,
                                  kRowHeight / 2);
        drawText = @"时间";
        drawTextRect.origin.y += 2;
        drawTextVerticalCenter(drawTextRect,
                               drawText,
                               [UIFont systemFontOfSize:kLeftTopTitleFont],
                               NSLineBreakByTruncatingTail,
                               NSTextAlignmentCenter);
        
        // 球队
        drawTextRect = CGRectMake(startX,
                                  startY + kRowHeight / 2,
                                  kLeftTitleColumnWidth / 2,
                                  kRowHeight / 2);
        drawText = @"球队";
        drawTextVerticalCenter(drawTextRect,
                               drawText,
                               [UIFont systemFontOfSize:kLeftTopTitleFont],
                               NSLineBreakByTruncatingTail,
                               NSTextAlignmentCenter);
        startY += kRowHeight;
        
        drawText = _liveModel.hostTeamName.length > 0 ? _liveModel.hostTeamName : @"主队";
        drawTextRect = CGRectMake(startX,
                                  startY,
                                  kLeftTitleColumnWidth,
                                  kRowHeight);
        
        drawTextVerticalCenter(drawTextRect,
                               drawText,
                               [UIFont systemFontOfSize:kColumnTitleFont],
                               NSLineBreakByTruncatingTail,
                               NSTextAlignmentCenter);
        
        startY += kRowHeight;
        
        drawText = _liveModel.visitTeamName.length > 0 ? _liveModel.visitTeamName : @"客队";
        drawTextRect = CGRectMake(startX,
                                  startY,
                                  kLeftTitleColumnWidth,
                                  kRowHeight);
        
        drawTextVerticalCenter(drawTextRect,
                               drawText,
                               [UIFont systemFontOfSize:kColumnTitleFont],
                               NSLineBreakByTruncatingTail,
                               NSTextAlignmentCenter);
        
        CGContextRestoreGState(context);
        
        // draw table
        startY = kTableTopMargin;
        
        CGFloat lineWidth = [[UIScreen mainScreen] scale] == 2 ? 0.5 : 1;
        CGContextSetLineWidth(context, lineWidth);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, startX + kLeftTitleColumnWidth, startY + kRowHeight);
        CGPathAddLineToPoint(path, NULL, startX, startY);
        CGPathAddLineToPoint(path, NULL, startX + kLeftTitleColumnWidth, startY);
        CGPathAddLineToPoint(path, NULL, startX + kLeftTitleColumnWidth, startY + 3 * kRowHeight);
        CGPathAddLineToPoint(path, NULL, startX, startY + 3 * kRowHeight);
        CGPathAddLineToPoint(path, NULL, startX, startY);
        
        CGPathMoveToPoint(path, NULL, startX, startY + 2 * kRowHeight);
        CGPathAddLineToPoint(path, NULL, startX + kLeftTitleColumnWidth, startY + 2 * kRowHeight);
        
        CGPathMoveToPoint(path, NULL, startX + kLeftTitleColumnWidth, startY);
        CGPathAddLineToPoint(path, NULL, self.width - kSideMargin, startY);
        CGPathAddLineToPoint(path, NULL, self.width - kSideMargin, startY + 3 * kRowHeight);
        CGPathAddLineToPoint(path, NULL, startX + kLeftTitleColumnWidth, startY + 3 * kRowHeight);
        
        CGContextSetStrokeColorWithColor(context, [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveStatisticLineColor]].CGColor);
        CGContextAddPath(context, path);
        CGContextStrokePath(context);
        CFRelease(path);
    }
}

#pragma mark tableview datasource & delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _rightShadowView.hidden = (scrollView.contentOffset.x + scrollView.width == scrollView.contentSize.width);
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////

void drawTextVerticalCenter(CGRect rect, NSString *text, UIFont *font, UILineBreakMode lineBreak, UITextAlignment alignment) {
    CGRect realDrawReack = CGRectMake(rect.origin.x,
                                      rect.origin.y + (rect.size.height - [font lineHeight]) / 2,
                                      rect.size.width,
                                      font.lineHeight);
    
    [text drawInRect:realDrawReack
            withFont:font
       lineBreakMode:lineBreak
           alignment:alignment];
}

