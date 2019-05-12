//
//  SNLiveCell.m
//  sohunews
//
//  Created by yanchen wang on 12-6-14.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SNLiveCell.h"
#import "UIColor+ColorUtils.h"
#import "CoreGraphicHelper.h"
#import <CoreText/CoreText.h>
#import "NSCellLayout.h"
#import "UIImage+Utility.h"
#import "SNLiveSubscribeService.h"

#import "SNSkinManager.h"

#define kRowHeight                  (130 / 2)
#define kGameTypeViewWidth          (58.0f)
#define kGameViewSepretorBlank      (14.0f)

static NSString * const kPubTypeName = @"独家";

#pragma mark - private subviews 
@interface GameSubView : UIView {
    LivingGameItem *_gameItem;
    int _viewType;
}

@property(nonatomic, strong)LivingGameItem *gameItem;
@property(nonatomic, assign)int viewType;

@end

@implementation GameSubView
@synthesize gameItem = _gameItem;
@synthesize viewType = _viewType;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //5.9.3 wangchuanwen update
        //self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
        self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    }
    return self;
}

- (void)dealloc {
}

@end

#pragma mark - GameTypeView
///////////////////////////////////////////////////////////////////////////////
// GameTypeView 显示比赛类型
#define kGameTypeViewTextViewHeight     (12.0f)
#define kGameTypeViewImageWidth         (55.0f / 2)
#define kGameTypeViewImageHeight        (27.0f / 2)
#define kGameTypeViewFontSize           (11.0f)
#define kGameTypeViewFontSizeBig        (15.0f)
#define kGameTypeViewTopBlankDefault    (39.0f / 2)
#define kGameTypeViewTopBlankHot        (34.0f / 2)
#define kGameTypeViewSpace              (4.0f)
typedef enum {
    GameTypeViewDefault,
    GameTypeViewHot
}GameTypeViewType;

@interface GameTypeView : GameSubView {
    UILabel *_typeCaption;
    UIImageView *_typeImageView;
}

@property(nonatomic, strong)UILabel *typeCaption;
@property(nonatomic, strong)UIImageView *typeImageView;

@end

@implementation GameTypeView
@synthesize typeCaption = _typeCaption;
@synthesize typeImageView = _typeImageView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _typeCaption = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, kGameTypeViewTextViewHeight)];
        _typeCaption.backgroundColor = [UIColor clearColor];
        _typeCaption.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_typeCaption];
        
        _typeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kGameTypeViewImageWidth, kGameTypeViewImageHeight)];
        [self addSubview:_typeImageView];
        
        //5.9.3 wangchuanwen update
        //self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
        self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];

}

- (void)updateTheme
{
    [self setNeedsDisplay];
    //5.9.3 wangchuanwen update
    //self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
}
- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    NSString *grayStrColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameSepretorColor];
    UIColor *grayColor = [UIColor colorFromString:grayStrColor];
    const CGFloat *gray = CGColorGetComponents(grayColor.CGColor);
	//add 1px gray stroke
	//CGFloat gray[4] = {224/255.0f, 224/255.0f, 224/255.0f, 1.0f};	
	CGContextSetLineWidth(c, 1.0f);
    CGContextSetStrokeColor(c, gray);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, self.width - 1.5, kGameViewSepretorBlank);
    CGContextAddLineToPoint(c, self.width - 1.5, self.height - kGameViewSepretorBlank);
    CGContextStrokePath(c);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _typeCaption.text = _gameItem.liveSubCat;
    _typeCaption.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameTypeTextColor]];
    _typeImageView.image = [UIImage imageNamed:@"live_hot.png"];
    
    if (_viewType == GameTypeViewDefault) {
        _typeImageView.hidden = YES;
        _typeCaption.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:kGameTypeViewFontSizeBig];
        _typeCaption.frame = CGRectMake(0, kGameTypeViewTopBlankDefault, self.width, kGameTypeViewFontSizeBig);
    }
    else if (_viewType == GameTypeViewHot) {
        _typeImageView.hidden = NO;
        
        _typeCaption.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:kGameTypeViewFontSize];
        _typeCaption.frame = CGRectMake(0, kGameTypeViewTopBlankHot, self.width, kGameTypeViewFontSize);
        
        _typeImageView.frame = CGRectMake((self.width - kGameTypeViewImageWidth) / 2, _typeCaption.frame.origin.y + _typeCaption.frame.size.height + kGameTypeViewSpace,
                                          kGameTypeViewImageWidth, kGameTypeViewImageHeight);
    }
}

@end
///////////////////////////////////////////////////////////////////////////////

#pragma mark - GameInfoView
///////////////////////////////////////////////////////////////////////////////
// GameInfoView 显示比赛队伍和比分信息 PS. 如果没有双方队名 显示title 队伍名称过长就缩(原来的分行策略启用)
#define kGameInfoTextFontSize           (15.0f)
#define kGameInfoTextFontSizeSmall      (13.0f)
#define kGameInfoSpace                  (5.0f)
typedef enum {
    GameInfoViewDefault,
    GameInfoViewVideo
}GameInfoViewType;

@interface GameInfoView : GameSubView {
    UILabel *_dotsLabel; // 显示中间的":"
    UILabel *_vsLabel; // "VS"
    UILabel *_hostLabel; // 主队名称
    UILabel *_hostTotalLabel; // 主队得分
    
    UILabel *_visitorLabel; // 客队名称
    UILabel *_visitorTotalLabel; // 客队得分
    
    UILabel *_defaultTitleLabel; // 默认只有title没有球队信息的赛事信息
    
    SNLabel *_gameInfoContentView;
}

@end

@implementation GameInfoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        /*
#if 0
        UIFont *font = [UIFont systemFontOfSize:kGameInfoTextFontSize];
        UIFont *fontScore = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:kGameInfoTextFontSize];
        CGSize textSize = [@":" sizeWithFont:font];
        CGFloat X = (frame.size.width - textSize.width) / 2;
        CGFloat Y = 0.0f;
        _dotsLabel = [[UILabel alloc] initWithFrame:CGRectMake(X, Y, textSize.width, frame.size.height)];
        _dotsLabel.textAlignment = UITextAlignmentCenter;
        _dotsLabel.backgroundColor = [UIColor clearColor];
        _dotsLabel.font = fontScore;
        _dotsLabel.text = @":";
        [self addSubview:_dotsLabel];
        
        textSize = [@"000" sizeWithFont:font];
        X =_dotsLabel.left - textSize.width;
        _hostTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(X, Y, textSize.width, frame.size.height)];
        _hostTotalLabel.textAlignment = UITextAlignmentCenter;
        _hostTotalLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _hostTotalLabel.backgroundColor = [UIColor clearColor];
        _hostTotalLabel.font = fontScore;
        [self addSubview:_hostTotalLabel];
        
        X = _dotsLabel.right;
        _visitorTotalLabel = [[UILabel alloc] initWithFrame:CGRectMake(X, Y, textSize.width, frame.size.height)];
        _visitorTotalLabel.textAlignment = UITextAlignmentCenter;
        _visitorTotalLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _visitorTotalLabel.backgroundColor = [UIColor clearColor];
        _visitorTotalLabel.font = fontScore;
        [self addSubview:_visitorTotalLabel];
        
        textSize = [@"VS" sizeWithFont:font];
        X = (frame.size.width - textSize.width) / 2;
        _vsLabel = [[UILabel alloc] initWithFrame:CGRectMake(X, Y, textSize.width, frame.size.height)];
        _vsLabel.textAlignment = UITextAlignmentCenter;
        _vsLabel.backgroundColor = [UIColor clearColor];
        _vsLabel.font = fontScore;
        _vsLabel.text = @"VS";
        [self addSubview:_vsLabel];
        
        _hostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, Y, _hostTotalLabel.left, frame.size.height)];
        _hostLabel.textAlignment = UITextAlignmentCenter;
        _hostLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _hostLabel.adjustsFontSizeToFitWidth = YES;
        _hostLabel.minimumFontSize = 10.0;
        _hostLabel.backgroundColor = [UIColor clearColor];
        _hostLabel.font = font;
        [self addSubview:_hostLabel];
        
        _visitorLabel = [[UILabel alloc] initWithFrame:CGRectMake(_visitorTotalLabel.right, Y, _hostLabel.width, frame.size.height)];
        _visitorLabel.textAlignment = UITextAlignmentCenter;
        _visitorLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _visitorLabel.adjustsFontSizeToFitWidth = YES;
        _visitorLabel.minimumFontSize = 10.0;
        _visitorLabel.backgroundColor = [UIColor clearColor];
        _visitorLabel.font = font;
        [self addSubview:_visitorLabel];
        
        _defaultTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _defaultTitleLabel.textAlignment = UITextAlignmentCenter;
        _defaultTitleLabel.backgroundColor = [UIColor clearColor];
        _defaultTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _defaultTitleLabel.font = font;
        [self addSubview:_defaultTitleLabel];
#endif
        */
        
        UIColor *scoreColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color]];
        //5.9.3 wangchuanwen update
        //UIColor *textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText2Color]];
        UIColor *textColor = SNUICOLOR(kThemeTextRIColor);
        _gameInfoContentView = [[SNLabel alloc] initWithFrame:CGRectZero];
        CGSize size = self.size;
        size.height += ([SNUtility shownBigerFont] && [SNDevice sharedInstance].isPlus) ? 15 : 8;//plus大字体显示...
        _gameInfoContentView.size = size;
        _gameInfoContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _gameInfoContentView.backgroundColor = [UIColor clearColor];
        _gameInfoContentView.breakMode = NSLineBreakByTruncatingTail;
        _gameInfoContentView.font = [SNUtility getNewsTitleFont];
        _gameInfoContentView.textColor = textColor;
        _gameInfoContentView.linkColor = scoreColor;
        _gameInfoContentView.disableLinkDetect = YES;
        [self addSubview:_gameInfoContentView];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (void)setGameItem:(LivingGameItem *)gameItem {
    [super setGameItem:gameItem];
    [self setNeedsDisplay];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSString *gameInfoText = nil;
    NSMutableAttributedString *gameAttriText = nil;
    UIFont *vsFont = [UIFont digitAndLetterFontOfSize:14];
    
    // layout subviews
    [_gameInfoContentView removeAllHighlightInfo];
    [_gameInfoContentView removeAllFontInfo];
    if ([_gameItem.liveType intValue] == 1) {
        
        if ([_gameItem.status intValue] >= 2) {
            gameInfoText = [NSString stringWithFormat:@"%@ %@:%@ %@",
                            _gameItem.hostName,
                            _gameItem.hostTotal,
                            _gameItem.visitorTotal,
                            _gameItem.visitorName];
            NSRange searchRange = NSMakeRange(_gameItem.hostName.length,
                                              gameInfoText.length - _gameItem.hostName.length - _gameItem.visitorName.length);
            NSRange hostScoreRange = [gameInfoText rangeOfString:_gameItem.hostTotal options:NSCaseInsensitiveSearch range:searchRange];
            NSRange visitScoreRange = [gameInfoText rangeOfString:_gameItem.visitorTotal options:NSBackwardsSearch range:searchRange];
            [_gameInfoContentView addHighlightText:_gameItem.hostTotal inRange:hostScoreRange];
            [_gameInfoContentView addHighlightText:_gameItem.visitorTotal inRange:visitScoreRange];
        }
        else {
            gameInfoText = [NSString stringWithFormat:@"%@ vs %@",
                            _gameItem.hostName,
                            _gameItem.visitorName];
            NSRange searchRange = NSMakeRange(_gameItem.hostName.length,
                                              gameInfoText.length - _gameItem.hostName.length - _gameItem.visitorName.length);
            NSRange vsRange = [gameInfoText rangeOfString:@"vs" options:NSCaseInsensitiveSearch range:searchRange];
            [_gameInfoContentView addHighlightText:@"vs" inRange:vsRange];
            [_gameInfoContentView addFont:vsFont inRange:vsRange];
        }
    }
    else if ([_gameItem.title length] > 0) {
        gameInfoText = _gameItem.title;
    }
    
    _gameInfoContentView.text = gameInfoText;
    
    // clean
    
    /*
#if 0
    // hide all views
    UIColor *scoreColor = [UIColor colorFromString:kLiveGameScoreTextColor];
    UIColor *textColor = [UIColor colorFromString:kLiveGameInfoTextColor];
    
    _dotsLabel.hidden = YES;
    _dotsLabel.textColor = textColor;
    _vsLabel.hidden = YES;
    _vsLabel.textColor = scoreColor;
    _hostLabel.hidden = YES;
    _hostLabel.textColor = textColor;
    _hostTotalLabel.hidden = YES;
    _hostTotalLabel.textColor = scoreColor;
    _visitorLabel.hidden = YES;
    _visitorLabel.textColor = textColor;
    _visitorTotalLabel.hidden = YES;
    _visitorTotalLabel.textColor = scoreColor;
    _defaultTitleLabel.hidden = YES;
    _defaultTitleLabel.textColor = textColor;
    
    // layout subviews
    
    if ([_tableItem.gameItem.liveType intValue] == 1) {
        _visitorLabel.hidden = NO;
        _visitorLabel.text = _tableItem.gameItem.visitorName;
        _hostLabel.hidden = NO;
        _hostLabel.text = _tableItem.gameItem.hostName;
        
        if ([_tableItem.gameItem.status intValue] >= 2) {
            _hostLabel.textAlignment = UITextAlignmentRight;
            _hostLabel.frame = CGRectMake(0, 0, _hostTotalLabel.left - kGameInfoSpace, self.height);
            _visitorLabel.textAlignment = UITextAlignmentLeft;
            _visitorLabel.frame = CGRectMake(_visitorTotalLabel.right + kGameInfoSpace, 0, _hostLabel.width, self.height);
            
            _hostTotalLabel.hidden = NO;
            _hostTotalLabel.text = [NSString stringWithFormat:@"%d", [_tableItem.gameItem.hostTotal intValue]];
            
            _visitorTotalLabel.hidden = NO;
            _visitorTotalLabel.text = [NSString stringWithFormat:@"%d", [_tableItem.gameItem.visitorTotal intValue]];
            
            _dotsLabel.hidden = NO;
        }
        else {
            _vsLabel.hidden = NO;
            _hostLabel.textAlignment = UITextAlignmentRight;
            _hostLabel.frame = CGRectMake(0, 0, _vsLabel.left - kGameInfoSpace, self.height);
            _visitorLabel.textAlignment = UITextAlignmentLeft;
            _visitorLabel.frame = CGRectMake(_vsLabel.right + kGameInfoSpace, 0, _hostLabel.width, self.height);
        }
    }
    else if ([_tableItem.gameItem.title length] > 0) {
        _defaultTitleLabel.hidden = NO;
        _defaultTitleLabel.text = _tableItem.gameItem.title;
    }
#endif
     */
}

- (void)updateTheme
{
    [self setNeedsDisplay];
    
    NSString *scoreColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeRed1Color];
    NSString *textColorStr = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText2Color];
    UIColor *scoreColor = [UIColor colorFromString:scoreColorStr];
    UIColor *textColor = [UIColor colorFromString:textColorStr];
    _gameInfoContentView.textColor = textColor;
    _gameInfoContentView.linkColor = scoreColor;
    
    //5.9.3 wangchuanwen update
    //self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
}

- (void)updateTitleFont{
    _gameInfoContentView.font = [SNUtility getNewsTitleFont];
    if (([SNUtility shownBigerFont] && [SNDevice sharedInstance].isPlus)) {
        _gameInfoContentView.height = 40;
    }
}

/*
#if 0
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // 采用label显示球队名称 比分等 信息 分行策略启用 
    return;

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *drawString = nil;
    UIFont *font = [UIFont systemFontOfSize:kGameInfoTextFontSize];
    UIFont *fontSmall = [UIFont systemFontOfSize:kGameInfoTextFontSizeSmall];
    UIColor *scoreColor = [UIColor colorFromString:kLiveGameScoreTextColor];
    UIColor *textColor = [UIColor colorFromString:kLiveGameInfoTextColor];
    
    if ([_tableItem.gameItem.status intValue] >= 2) {
        drawString = [NSString stringWithFormat:@"%@ %@ : %@ %@", _tableItem.gameItem.hostName, _tableItem.gameItem.hostTotal, _tableItem.gameItem.visitorTotal, _tableItem.gameItem.visitorName];
        CGSize textSize = [drawString sizeWithFont:font];
        if (textSize.width < self.width) {
            CGFloat X = (self.width - textSize.width) / 2;
            CGFloat Y = (self.height - textSize.height) / 2;
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, textColor.CGColor);
            CGSize drawSize = [_tableItem.gameItem.hostName sizeWithFont:font];
            drawSize = [_tableItem.gameItem.hostName drawInRect:CGRectMake(X, Y, drawSize.width, drawSize.height) withFont:font lineBreakMode:NSLineBreakByTruncatingTail alignment:UITextAlignmentLeft];
            X += drawSize.width;
            CGContextRestoreGState(ctx);
            
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, scoreColor.CGColor);
            NSString *score1 = [NSString stringWithFormat:@" %@ ", _tableItem.gameItem.hostTotal];
            drawSize = [score1 sizeWithFont:font];
            drawSize = [score1 drawInRect:CGRectMake(X, Y, drawSize.width, drawSize.height) withFont:font lineBreakMode:NSLineBreakByClipping alignment:UITextAlignmentCenter];
            X += drawSize.width;
            CGContextRestoreGState(ctx);
            
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, textColor.CGColor);
            NSString *dots = @":";
            drawSize = [dots sizeWithFont:font];
            drawSize = [dots drawInRect:CGRectMake(X, Y, drawSize.width, drawSize.height) withFont:font lineBreakMode:NSLineBreakByClipping alignment:UITextAlignmentCenter];
            X += drawSize.width;
            CGContextRestoreGState(ctx);
            
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, scoreColor.CGColor);
            NSString *score2 = [NSString stringWithFormat:@" %@ ", _tableItem.gameItem.visitorTotal];
            drawSize = [score2 sizeWithFont:font];
            drawSize = [score2 drawInRect:CGRectMake(X, Y, drawSize.width, drawSize.height) withFont:font lineBreakMode:NSLineBreakByClipping alignment:UITextAlignmentCenter];
            X += drawSize.width;
            CGContextRestoreGState(ctx);
            
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, textColor.CGColor);
            drawSize = [_tableItem.gameItem.visitorName sizeWithFont:font];
            drawSize = [_tableItem.gameItem.visitorName drawInRect:CGRectMake(X, Y, drawSize.width, drawSize.height) withFont:font lineBreakMode:NSLineBreakByClipping alignment:UITextAlignmentLeft];
            CGContextRestoreGState(ctx);
        }
        else {
            // 显示不全 分三行  要是还不全 那就打点
            CGSize drawSize = [_tableItem.gameItem.hostName sizeWithFont:fontSmall];
            CGFloat lineSpace = (self.height - 3 * drawSize.height) / 4;
            CGFloat Y = lineSpace;
            CGFloat X = 0.0;
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, textColor.CGColor);
            // line 1
            drawSize = [_tableItem.gameItem.hostName drawInRect:CGRectMake(0, Y, self.width, drawSize.height) withFont:fontSmall lineBreakMode:NSLineBreakByTruncatingTail alignment:UITextAlignmentCenter];
            Y += drawSize.height + lineSpace;
            CGContextRestoreGState(ctx);
            
            // line 2
            NSString *line2 = [NSString stringWithFormat:@"%@ : %@", _tableItem.gameItem.hostTotal, _tableItem.gameItem.visitorTotal];
            drawSize = [line2 sizeWithFont:fontSmall];
            X = (self.width - drawSize.width) / 2;
            
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, scoreColor.CGColor);
            NSString *score1 = [NSString stringWithFormat:@"%@ ", _tableItem.gameItem.hostTotal];
            drawSize = [score1 sizeWithFont:fontSmall];
            drawSize = [score1 drawInRect:CGRectMake(X, Y, drawSize.width, drawSize.height) withFont:fontSmall lineBreakMode:NSLineBreakByClipping alignment:UITextAlignmentCenter];
            X += drawSize.width;
            CGContextRestoreGState(ctx);
            
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, textColor.CGColor);
            NSString *dots = @":";
            drawSize = [dots sizeWithFont:fontSmall];
            drawSize = [dots drawInRect:CGRectMake(X, Y, drawSize.width, drawSize.height) withFont:fontSmall lineBreakMode:NSLineBreakByClipping alignment:UITextAlignmentCenter];
            X += drawSize.width;
            CGContextRestoreGState(ctx);
            
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, scoreColor.CGColor);
            NSString *score2 = [NSString stringWithFormat:@" %@ ", _tableItem.gameItem.visitorTotal];
            drawSize = [score2 sizeWithFont:fontSmall];
            drawSize = [score1 drawInRect:CGRectMake(X, Y, drawSize.width, drawSize.height) withFont:fontSmall lineBreakMode:NSLineBreakByClipping alignment:UITextAlignmentRight];
            CGContextRestoreGState(ctx);
            
            Y += drawSize.height + lineSpace;
            
            // line 3
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, textColor.CGColor);
            [_tableItem.gameItem.visitorName drawInRect:CGRectMake(0, Y, self.width, drawSize.height) withFont:fontSmall lineBreakMode:NSLineBreakByTruncatingTail alignment:UITextAlignmentCenter];
            CGContextRestoreGState(ctx);
        }
    }
    else {
        drawString = [NSString stringWithFormat:@"%@ vs %@", _tableItem.gameItem.hostName, _tableItem.gameItem.visitorName];
        CGSize textSize = [drawString sizeWithFont:font];
        if (textSize.width < self.width) {
            CGFloat X = (self.width - textSize.width) / 2;
            CGFloat Y = (self.height - textSize.height) / 2;
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, textColor.CGColor);
            CGSize drawSize = [_tableItem.gameItem.hostName sizeWithFont:font];
            drawSize = [_tableItem.gameItem.hostName drawInRect:CGRectMake(X, Y, drawSize.width, drawSize.height) withFont:font lineBreakMode:NSLineBreakByClipping alignment:UITextAlignmentLeft];
            X += drawSize.width;
            CGContextRestoreGState(ctx);
            
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, scoreColor.CGColor);
            NSString *vsStr = @" VS ";
            drawSize = [vsStr sizeWithFont:font];
            drawSize = [vsStr drawInRect:CGRectMake(X, Y, drawSize.width, drawSize.height) withFont:font lineBreakMode:NSLineBreakByClipping alignment:UITextAlignmentCenter];
            X += drawSize.width;
            CGContextRestoreGState(ctx);
            
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, textColor.CGColor);
            drawSize = [_tableItem.gameItem.visitorName sizeWithFont:font];
            drawSize = [_tableItem.gameItem.visitorName drawInRect:CGRectMake(X, Y, drawSize.width, drawSize.height) withFont:font lineBreakMode:NSLineBreakByClipping alignment:UITextAlignmentRight];
            CGContextRestoreGState(ctx);
        }
        else { // 分行显示            
            CGSize drawSize = [_tableItem.gameItem.hostName sizeWithFont:fontSmall];
            CGFloat lineSpace = (self.height - 3 * drawSize.height) / 4;
            CGFloat Y = lineSpace;
            
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, textColor.CGColor);
            // line 1
            drawSize = [_tableItem.gameItem.hostName drawInRect:CGRectMake(0, Y, self.width, drawSize.height) withFont:fontSmall lineBreakMode:NSLineBreakByTruncatingTail alignment:UITextAlignmentCenter];
            Y += drawSize.height + lineSpace;
            CGContextRestoreGState(ctx);
            
            // line 2
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, scoreColor.CGColor);
            NSString *vsStr = @"VS";
            drawSize = [vsStr drawInRect:CGRectMake(0, Y, self.width, drawSize.height) withFont:fontSmall lineBreakMode:NSLineBreakByTruncatingTail alignment:UITextAlignmentCenter];
            CGContextRestoreGState(ctx);
            Y += drawSize.height + lineSpace;
            
            // line 3
            CGContextSaveGState(ctx);
            CGContextSetFillColorWithColor(ctx, textColor.CGColor);
            [_tableItem.gameItem.visitorName drawInRect:CGRectMake(0, Y, self.width, drawSize.height) withFont:fontSmall lineBreakMode:NSLineBreakByTruncatingTail alignment:UITextAlignmentCenter];
            CGContextRestoreGState(ctx);
        }
    }
    
    [pool release];
}
#endif
 */

@end
///////////////////////////////////////////////////////////////////////////////

#pragma mark - GameDateTimeView
///////////////////////////////////////////////////////////////////////////////
// GameDateTimeView 显示比赛日期时间或者比赛状态：已结束、直播中
#define kGameDateTimeViewIconWidth          (59.0 / 2)
#define kGameDateTimeViewIconHeight         (54.0 / 2)
#define kGameDateTimeViewDateWidth          (30.0)

#define kGameDateTimeViewFontDefault        (13.0f)
#define kGameDateTimeViewFontTime           (28.0f / 2)
#define kGameDateTimeViewFontDate           (14.0f / 2)

#define kGameDateTimeViewSpace              (7.0f / 2)

#define kGameDateTimeViewDateX              (56.0f / 2)
#define kGameDateTimeViewDateY              (38.0f / 2)
// 1-预告 2-直播中 3-直播结束
typedef enum {
    GameDateTimeViewDefault = 1,
    GameDateTimeViewLiving = 2,
    GameDateTimeViewFinished = 3
}GameDateTimeViewType;

@interface GameDateTimeView : GameSubView {
    UIButton *_maskButton;
    UILabel *_dateLabel;
    UILabel *_timeLabel;
    UILabel *_infoLabel;
    
    UIImageView *_iconImage;
    UIImageView *_statusIcon;
}

@property(nonatomic, weak) id delegate;

- (void)addSubscribeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents) event;

@end

@implementation GameDateTimeView
@synthesize delegate = _delegate;

// deprecated
//- (NSString *)gameDateString {
//    NSString *dateStr = @"";
//    if (_tableItem && _tableItem.gameItem) {
//        NSArray *strParts = [_tableItem.gameItem.liveTime componentsSeparatedByString:@" "];
//        if (strParts.count <= 1) {
//            return dateStr;
//        }
//        
//        NSString *liveDate = [strParts objectAtIndex:0];
//        NSArray *dateParts = [liveDate componentsSeparatedByString:@"-"];
//        if (dateParts.count == 3) {
//            dateStr = [NSString stringWithFormat:@"%@/%@", [dateParts objectAtIndex:1], [dateParts objectAtIndex:2]];
//        }
//        
//    }
//    return dateStr;
//}

// deprecated
//- (NSString *)gameTimeString {
//    NSString *timeStr = @"";
//    if (_tableItem && _tableItem.gameItem) {
//        NSArray *strParts = [_tableItem.gameItem.liveTime componentsSeparatedByString:@" "];
//        if (strParts.count <= 1) {
//            return timeStr;
//        }
//        
//        timeStr = [strParts lastObject];
//    }
//    return timeStr;
//}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //5.9.3 wangchuanwen update
        //self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
        self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
        self.userInteractionEnabled = YES; // default is YES
        
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _infoLabel.backgroundColor = [UIColor clearColor];
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _infoLabel.font = [UIFont systemFontOfSize:kGameDateTimeViewFontDefault];
        [self addSubview:_infoLabel];
        
        _statusIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_tagc.png"]];
        _statusIcon.centerX = self.width/2;
        _statusIcon.bottom = self.bottom - 10;
        [self addSubview:_statusIcon];

        // icon image
//        _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kGameDateTimeViewIconWidth, kGameDateTimeViewIconHeight)];
        _iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_subscribed.png"]];
        //_iconImage.backgroundColor = [UIColor clearColor];
        //_iconImage.contentMode = UIViewContentModeScaleToFill;
        //_iconImage.centerY = CGRectGetMidY(self.bounds);
        _iconImage.bottom = self.bottom - 28/2;
        _iconImage.right = self.width - 0.5;
        [self addSubview:_iconImage];
        
        // date label
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(kGameDateTimeViewDateX, kGameDateTimeViewDateY, 
                                                               frame.size.width - kGameDateTimeViewDateX, kGameDateTimeViewFontDate + 2.0)];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textAlignment = NSTextAlignmentLeft;
        _dateLabel.font = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:kGameDateTimeViewFontDate];
        _dateLabel.bottom = CGRectGetMidY(self.bounds);
        [self addSubview:_dateLabel];
        
        // time label
        UIFont *timeFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:kGameDateTimeViewFontTime];
        if (!timeFont) {
            timeFont = [UIFont fontWithName:kDigitAndLetterFontFimalyName size:kGameDateTimeViewFontTime];
        }
        CGFloat Y = _dateLabel.frame.origin.y + _dateLabel.frame.size.height + kGameDateTimeViewSpace;
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, Y, frame.size.width, kGameDateTimeViewFontTime)];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = timeFont;
        [self addSubview:_timeLabel];
        
        
        // add mask button at last
        _maskButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _maskButton.backgroundColor = [UIColor clearColor];
        _maskButton.alpha = 0;
        _maskButton.isAccessibilityElement = NO;
        [self addSubview:_maskButton];
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateSubscribeIconByNotification:) name:kLiveSubscribeChangedNotification object:nil];
    }
    return self;
}

- (void)updateTheme
{
    [self setNeedsDisplay];
    [self setNeedsLayout];
    
    //5.9.3 wangchuanwen update
    //self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    UIColor *grayColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLiveGameSepretorColor]];
    const CGFloat *gray = CGColorGetComponents(grayColor.CGColor);
	//add 1px gray stroke
	//CGFloat gray[4] = {224/255.0f, 224/255.0f, 224/255.0f, 1.0f};
    float lineW = [UIScreen mainScreen].scale==2.0f ? 0.5f : 1.0f;
	CGContextSetLineWidth(c, lineW);
    CGContextSetStrokeColor(c, gray);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, 1.5, kGameViewSepretorBlank);
    CGContextAddLineToPoint(c, 1.5, self.height - kGameViewSepretorBlank);
    CGContextStrokePath(c);
    CGContextRestoreGState(c);
}

- (void)layoutSubviews {
    [super layoutSubviews];

    UIColor *timeColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText2Color]];
    
    // hide all views    
    _maskButton.hidden = YES;
    _dateLabel.hidden = YES;
    //_timeLabel.hidden = YES;
    _iconImage.hidden = YES;
    _infoLabel.hidden = YES;
    //_statusIcon.hidden = YES;

    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[_gameItem.liveTime longLongValue] / 1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = TTCurrentLocale();
    formatter.dateFormat = @"MM/dd";
    
    _dateLabel.hidden = NO; // 显示比赛日期
    _dateLabel.text = [formatter stringFromDate:date];
    _dateLabel.textColor = timeColor;
    _dateLabel.backgroundColor = [UIColor clearColor];
    
    formatter.dateFormat = @"HH:mm";
    _timeLabel.text = [formatter stringFromDate:date];
    _timeLabel.textColor = timeColor;
    _timeLabel.backgroundColor = [UIColor clearColor];
    
    
    if (_viewType == GameDateTimeViewDefault) {
        _iconImage.hidden = NO; // 显示预定icon 不通的icon
        _maskButton.hidden = NO; // 可以预定
        
        [self setSubscribeIcon];
        
        _statusIcon.image = [UIImage imageNamed:@"live_tagc.png"];
        
        _statusIcon.bottom = self.height - 10;//55
        _timeLabel.bottom = _statusIcon.top - 2;
        _dateLabel.bottom = _timeLabel.top - 1;
    }
    else {
        if (_viewType == GameDateTimeViewLiving) {
            _statusIcon.image = [UIImage imageNamed:@"live_tagb.png"];

            BOOL isToday = [date isToday];

            if (isToday) {
                // 不显示日期
                _dateLabel.hidden = YES;
                _statusIcon.bottom = self.height - 34/2;
                _timeLabel.bottom = _statusIcon.top - 2;
            } else {
                // 显示日期
                _dateLabel.hidden = NO;
                _statusIcon.bottom = self.height - 10;
                _timeLabel.bottom = _statusIcon.top - 2;
                _dateLabel.bottom = _timeLabel.top - 1;
            }
        } else {
            _dateLabel.hidden = NO;
            _statusIcon.image = [UIImage imageNamed:@"live_tagd.png"];
            _statusIcon.bottom = self.height - 10;
            _timeLabel.bottom = _statusIcon.top - 2;
            _dateLabel.bottom = _timeLabel.top - 1;
        }
    }
}

- (void)setSubscribeIcon {
    BOOL bSubscribed = [[SNLiveSubscribeService sharedInstance] hasLiveGameSubscribed:_gameItem.liveId];
    
    if (bSubscribed) {
        _iconImage.image = [UIImage imageNamed:@"live_subscribed.png"];
    }
    else {
        _iconImage.image = [UIImage imageNamed:@"live_unsubscribed.png"];
    }
}

- (void)updateSubscribeIconByNotification:(NSNotification *)notification {
    if (_viewType == GameDateTimeViewDefault) {
        NSString *liveId = [notification.userInfo objectForKey:@"liveId"];
        if ([self.gameItem.liveId isEqualToString:liveId]) {
            [self setSubscribeIcon];
        }
    }
}

- (void)addSubscribeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)event {
    if (_maskButton) {
        _maskButton.alpha = 1;
        [_maskButton addTarget:target action:action forControlEvents:event];
    }
}

- (void)setGameItem:(LivingGameItem *)gameItem {
    [super setGameItem:gameItem];
    // 比赛状态 1-预告 2-直播中 3-直播结束
    self.viewType = [_gameItem.status intValue];
    [self setNeedsLayout];
}

@end

///////////////////////////////////////////////////////////////////////////////
@implementation SNLiveCellContentView
@synthesize gameItem = _gameItem;
//@synthesize cellDelegate = _cellDelegate;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [UIColor clearColor];
        //5.9.3 wangchuanwen update
        //self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
        self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (void)setGameItem:(LivingGameItem *)gameItem {
    if (_gameItem != gameItem) {
        _gameItem = gameItem;
        if (_gameItem) {
            [self updateTheme];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];// game info view
    if (!_gameInfoView) {
        _gameInfoView = [[GameInfoView alloc] initWithFrame:CGRectMake(10, 33, kAppScreenWidth - 2 * 10 - kGameTypeViewWidth, 25)];
        [self addSubview:_gameInfoView];
    }
    _gameInfoView.gameItem = _gameItem;
    [_gameInfoView setNeedsLayout];
    
    // game date time view
    if (!_gameDateTimeView) {
        _gameDateTimeView = [[GameDateTimeView alloc] initWithFrame:CGRectMake(self.width - kGameTypeViewWidth, 0, kGameTypeViewWidth, kRowHeight)];
        _gameDateTimeView.delegate = self;
        [self addSubview:_gameDateTimeView];
    }
    _gameDateTimeView.gameItem = _gameItem;
    [_gameDateTimeView setNeedsLayout];
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);

    UIColor *textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kThemeText2Color]];
    
    CGFloat yPos = 32 / 2, xPos = 10;
    
    // 类型
    NSString *catStr = _gameItem.liveSubCat;
    if (_gameItem.liveCat.length && _gameItem.liveSubCat.length && ![_gameItem.liveCat isEqualToString:_gameItem.liveSubCat]) {
        catStr = [NSString stringWithFormat:@"%@ %@", _gameItem.liveCat, _gameItem.liveSubCat];
    }
    
    if (catStr.length > 0) {
        UIFont *catFont = [UIFont systemFontOfSize:11];
        CGSize textSize = [catStr sizeWithFont:catFont];
        
        CGRect textRect = CGRectMake(xPos, yPos, textSize.width, 15);
        
        [textColor set];
        
        [catStr drawInRect:textRect withFont:catFont lineBreakMode:NSLineBreakByTruncatingTail];
        
        xPos += textRect.size.width;
    }

    //NSString *typeText = @"热门";
    BOOL hasHot = NO;
    xPos += 8 / 2;
    //yPos += 2;
    
    // 如果子分类 没有  标签 左对齐 
    if (catStr.length <= 1) xPos = 10;
    
    // 如果有热门 先draw热门
    if (_gameItem.isHot.length > 0 && [_gameItem.isHot intValue] == 1) {
        //typeText = @"热门";
        hasHot = YES;
    }
    
    // 判断“独家” 优先级最高
    if (_gameItem.pubType.integerValue == 1) {
        UIFont *typeFont = [UIFont systemFontOfSize:11];
        
        CGRect typeIconRect = CGRectMake(xPos, yPos, 54 / 2, 15);
        
        //[CoreGraphicHelper drawRoundedMask:typeIconRect color:[UIColor redColor]];
        
        [[SNSkinManager color:SkinRed] set];
        [kPubTypeName drawInRect:typeIconRect withFont:typeFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft]; // UILineBreakModeTailTruncation

    } else if (hasHot) {
        UIImage *image = [UIImage imageNamed:@"live_hoticon.png"];
        [image drawInRect:CGRectMake(xPos, yPos, image.size.width, 15) contentMode:UIViewContentModeCenter];
//        UIFont *typeFont = [UIFont systemFontOfSize:18 / 2];
//        
//        CGRect typeIconRect = CGRectMake(xPos, yPos, 54 / 2, 26 / 2);
//        
//        [CoreGraphicHelper drawRoundedMask:typeIconRect color:typeBgColor];
//        
//        typeIconRect.origin.y += 1;
//        
//        [typeTextColor set];
//        [typeText drawInRect:typeIconRect withFont:typeFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
    } else {
        if (_gameItem.mediaType > 0) {
            BOOL bMedia = NO;
            if (_gameItem.mediaType == 1 || _gameItem.mediaType == 3) {
                //            typeText = @"视频";
                bMedia = YES;
            }
            else if (_gameItem.mediaType == 2) {
                //            typeText = @"音频";
                bMedia = YES;
            }
            if (bMedia) {
                UIImage *image = [UIImage imageNamed:@"live_videoicon.png"];
                [image drawInRect:CGRectMake(xPos, yPos+1.5, image.size.width, image.size.height) contentMode:UIViewContentModeCenter];
            }
        }
    }
    
    CGContextRestoreGState(c);
}

- (void)updateTheme {
    [self setNeedsDisplay];
    [self setNeedsLayout];
//    [_gameInfoView setNeedsDisplay];
//    [_gameDateTimeView setNeedsDisplay];
    
    //5.9.3 wangchuanwen update
    //self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
}

- (void)addTarget:(id)target selector:(SEL)selector {
    if (!_gameDateTimeView) {
        _gameDateTimeView = [[GameDateTimeView alloc] initWithFrame:CGRectMake(self.width - kGameTypeViewWidth, 0, kGameTypeViewWidth, kRowHeight)];
        [self addSubview:_gameDateTimeView];
    }
    [_gameDateTimeView addSubscribeTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateTitleFont{
    [_gameInfoView updateTitleFont];
}

@end


#pragma mark - SNLiveCell

@implementation SNLiveCell
@synthesize livingGameItem = _livingGameItem;

- (void)dealloc {
    [SNNotificationManager removeObserver:self];

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        //5.9.3 wangchuanwen update
        //self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
        self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    [UIView drawCellSeperateLine:rect];
}

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	return kRowHeight;
}

+ (CGFloat)cellHeight {
    return kRowHeight;
}

- (void)setObject:(id)object {
    if (self.livingGameItem != object) {
        self.livingGameItem = object;
        self.livingGameItem.selector = @selector(openLive);
        self.livingGameItem.delegate = self;
    }
    
    if (!_liveContentView) {
        _liveContentView = [[SNLiveCellContentView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, self.height)];
        _liveContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_liveContentView addTarget:self selector:@selector(subscribe)];
        [self addSubview:_liveContentView];
    }
    _liveContentView.gameItem = _livingGameItem.gameItem;
    [_liveContentView updateTitleFont];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)openLive {
    [SNUtility shouldUseSpreadAnimation:YES];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    
    [userInfo setObject:_livingGameItem.gameItem forKey:kLiveGameItem];
    [userInfo setObject:kChannelEditionNews forKey:kNewsFrom];
    [userInfo setObject:[SNUtility getCurrentChannelId] forKey:kCurrentChannelId];
    TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://live"] applyAnimated:YES] applyQuery:userInfo];
    [[TTNavigator navigator] openURLAction:urlAction];
}

- (void)subscribe {
    
    BOOL bSubscribed = [[SNLiveSubscribeService sharedInstance] hasLiveGameSubscribed:_livingGameItem.gameItem.liveId];
    
    if (bSubscribed) {
        [self unsubscribeWithLiveItem:_livingGameItem.gameItem];
    } else {
        [self subscribeWithLiveItem:_livingGameItem.gameItem];
    }
    [_liveContentView setNeedsLayout];
}

- (void)subscribeWithLiveItem:(LivingGameItem *)liveItem {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    
    if (!liveItem || !liveItem.liveId) {
        return;
    }
    
    BOOL ret = [[SNLiveSubscribeService sharedInstance] subscribeWithLiveGame:liveItem];
    if (ret) {
        NSMutableDictionary * infoDic =[NSMutableDictionary dictionary];
        [infoDic setObject:liveItem.liveId forKey:@"liveId"];
    
        [SNNewsReport reportADotGif:[NSString stringWithFormat:@"_act=live&_tp=alert&liveId=%@&channelId=%@", liveItem.liveId, [SNUtility getCurrentChannelId]]];
    }
}

- (void)unsubscribeWithLiveItem:(LivingGameItem *)liveItem {
    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
    
    if (!liveItem) {
        return;
    }
    
    BOOL ret = [[SNLiveSubscribeService sharedInstance] unsubscribeLiveGame:liveItem.liveId];
    if (ret) {
//        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"已取消直播提醒" toUrl:nil mode:SNCenterToastModeSuccess];
    } else {
//        [[SNCenterToast shareInstance] showCenterToastWithTitle:@"取消直播提醒失败" toUrl:nil mode:SNCenterToastModeWarning];
    }
}

- (void)updateTheme {
    [super updateTheme];
    //5.9.3 wangchuanwen update
    //self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    self.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    [_liveContentView updateTheme];
    [self setNeedsDisplay];
}

@end
