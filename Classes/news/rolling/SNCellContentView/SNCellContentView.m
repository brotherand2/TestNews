//
//  SNCellContentView.m
//  sohunews
//
//  Created by sampan li on 13-1-9.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNCellContentView.h"
#import "NSMutableAttributedString+Size.h"
#import "NSCellLayout.h"
#import "NSAttributedString+Attributes.h"
#import "UIFont+Theme.h"

#define MARKTEXT_GAP          14.0

@implementation SNCellContentView
@synthesize abstractAttStr=_abstractAttStr;
@synthesize titleAttStr = _titleAttStr;
@synthesize markTextColor=_markTextColor;
@synthesize title=_title,abstract=_abstract,time=_time;
@synthesize commentNum=_commentNum,videoMark=_videoMark,voteMark=_voteMark;
@synthesize newsType=_newsType,picCount=_picCount;
@synthesize titleWidth=_titleWidth,abstractWidth=_abstractWidth;
@synthesize titleLineCnt=_titleLineCnt;
@synthesize titleHeight = _titleHeight;
@synthesize abstractHeight = _abstractHeight;
@synthesize newsId = _newsId;
@synthesize isRecommend = _isRecommend;
@synthesize hasImage = _hasImage;
@synthesize hasComments = _hasComments;
@synthesize recommendIconUrl = _recommendIconUrl;
@synthesize isSearch = _isSearch;
@synthesize recomType = _recomType;
@synthesize liveStatus = _liveStatus;
@synthesize local = _local;
@synthesize isAppCell = _isAppCell;
@synthesize isFromSub = _isFromSub;
@synthesize cellType = _cellType;
@synthesize playTime = _playTime;
@synthesize isMySubscribe = _isMySubscribe;
@synthesize subscribeCount = _subscribeCount;
@synthesize updatedSubscribe = _updatedSubscribe;
@synthesize isFlash = _isFlash;
@synthesize sponsorships = _sponsorships;
@synthesize newsTypeString = _newsTypeString;
@synthesize hasMoreButton = _hasMoreButton;
@synthesize tvPlayNum = _tvPlayNum;
@synthesize playVid = _playVid;
@synthesize sourceName = _sourceName;
@synthesize recomReasons, recomTime;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
        self.isAccessibilityElement = NO;
    }
    return self;
}

- (NSString *)getCommentsCount
{
    NSString *commentString = @"";
    if (_commentNum.length >0) {
        if ([_commentNum intValue] > 1000000) {
            commentString = [NSString stringWithFormat:@"%.0f万",[_commentNum intValue]/10000.0f];
        } else if ([_commentNum intValue] > 10000) {
            commentString = [NSString stringWithFormat:@"%.1f万",[_commentNum intValue]/10000.0f];
            commentString = [commentString stringByReplacingOccurrencesOfString:@".0" withString:@""];
        }else {
            commentString = _commentNum;
            commentString = [commentString isEqualToString:@"0"] ? @"" : commentString;
        }
    }
    if (_newsType == NEWS_ITEM_TYPE_LIVE) {
        return commentString;
    }
    return [commentString stringByAppendingString:@"评"];
}

- (void)setTitleAttStr:(NSMutableAttributedString *)titleAttStr {
    _titleAttStr = titleAttStr;
}

- (NSString *)gettvPlayNum
{
    NSString *tvnumString = @"";
    if (_tvPlayNum.length >0) {
        if ([_tvPlayNum intValue] > 1000000) {
            tvnumString = [NSString stringWithFormat:@"%.0f万",[_tvPlayNum intValue]/10000.0f];
        } else if ([_tvPlayNum intValue] > 10000) {
            tvnumString = [NSString stringWithFormat:@"%.1f万",[_tvPlayNum intValue]/10000.0f];
            tvnumString = [tvnumString stringByReplacingOccurrencesOfString:@".0" withString:@""];
        }else {
            tvnumString = _tvPlayNum;
            tvnumString = [tvnumString isEqualToString:@"0"] ? @"" : tvnumString;
        }
    }
    return tvnumString;
}


- (UIColor *)getNewsTypeColor
{
    UIColor *newsTypeColor = _markTextColor;
    if (_newsTypeString.length > 0) {
        if ([_newsTypeString isEqualToString:@"独家"]) {
            newsTypeColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color];
        }
    }
    
    if (_isFlash && !_isFinance) {
        newsTypeColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeRed1Color];
    }
    return newsTypeColor;
}

//判断是否为图文模版
- (BOOL)hasImageCellType
{
    return [[self class] hasImageCellType:self.cellType hasImage:self.hasImage];
}

- (BOOL)isLink2VideoBigMode {
    return self.cellType == SNRollingNewsCellTypeVideo;
}

- (void)setAbstract:(NSString *)abstract
{
    if (_abstract!=abstract) {
        _abstract = abstract;
        [self makeAbasractAttStr];
    }
}

- (void)makeAbasractAttStr
{
    NSMutableAttributedString *attributeStr = nil;
    if ((_abstract.length>0)) {
        attributeStr = [NSCellLayout getAttributedString:_abstract];
    }
    self.abstractAttStr=attributeStr;
}

- (NSString*)getVoiceOverText
{
    NSString *text = _title;
    if (_commentNum.length > 0) {
        if(_newsType == NEWS_ITEM_TYPE_LIVE) {
            if ([_commentNum intValue] > 10000) {
                text = [text stringByAppendingFormat:@",%.1f人参与", [_commentNum intValue]/10000.0f];
            } else {
                text = [text stringByAppendingFormat:@",%@人参与", _commentNum];
            }
        } else {
            text= [text stringByAppendingFormat:@",%@个评论",_commentNum];
        }
    }
    if (_picCount>0) {
        text= [text stringByAppendingFormat:@",%d个图片",_picCount];
    }
    
    if (_newsType == NEWS_ITEM_TYPE_SPECIAL_NEWS) {
        NSString *typeStr = NSLocalizedString(@"SpecialNews", nil);
        text= [text stringByAppendingFormat:@",%@", typeStr];
    }else if(_newsType == NEWS_ITEM_TYPE_LIVE) {
        NSString *typeStr = NSLocalizedString(@"LiveNews", nil);
        text= [text stringByAppendingFormat:@",%@", typeStr];
    }else if(_newsType == NEWS_ITEM_TYPE_WEIBO) {
        NSString *typeStr = NSLocalizedString(@"Weiwen", nil);
        text= [text stringByAppendingFormat:@",%@", typeStr];
    }else if(_newsType == NEWS_ITEM_TYPE_NEWSPAPER) {
        NSString *typeStr = NSLocalizedString(@"Newspaper", nil);
        text= [text stringByAppendingFormat:@",%@", typeStr];
    }
    
    if (_cellType == SNRollingNewsCellTypeMySubscribe) {
        text= [text stringByAppendingFormat:@",%@个订阅更新",_commentNum];
    }
    return text;
}

#pragma mark -
#pragma mark Draw

- (void)drawTitleAndAbstract
{
    if (!self.titleAttStr) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGAffineTransform flip = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, self.frame.size.height);
    CGContextConcatCTM(context, flip);
    
    int titleLeft = CONTENT_LEFT;
    CGFloat titleTop = IMAGE_TOP ;
    
    switch (self.cellType) {
        case SNRollingNewsCellTypeDefault:
        case SNRollingNewsCellTypeMySubscribe:
        case SNRollingNewsCellTypeSohuLive:
        {
            titleLeft = TITLE_LEFT ;
            titleTop += [self getTitleTopValue];
        }
            break;
        case SNRollingNewsCellTypeAutoVideoMidImageType:
        {
            titleLeft = (CONTENT_LEFT + kMiddleVideoImageWidth + CELL_IMAGE_TITLE_DISTANCE);
            titleTop += [self getTitleTopValue];
        }
            break;
        //by 5.9.4 wangchuanwen modify
        //item间距调整 标题
        case SNRollingNewsCellTypePhotos://
        case SNRollingNewsCellTypeAdPicture://
        case SNRollingNewsCellTypeAdBigpicDownload://
        case SNRollingNewsCellTypeAdBigpicPhone:
        case SNRollingNewsCellTypeNewsVideo://
        case SNRollingNewsCellTypeAdVideoDownload://
        case SNRollingNewsCellTypeVideo://lijian 2015.1.1 增加视频广告的标题
        case SNRollingNewsCellTypeMatch:
        case SNRollingNewsCellTypeAdPhotos:
        case SNRollingNewsCellTypeAdMixpicDownload:
        case SNRollingNewsCellTypeAdMixpicPhone:
        case SNRollingNewsCellTypeAdBanner:
            titleTop = PHOTOS_SPACEVALUE;
            break;
        //modify end
        case SNRollingNewsCellTypeRedPacket:
        case SNRollingNewsCellTypeCoupons:
        {
            titleTop = FEED_SPACEVALUE;
        }
            break;
        case SNRollingNewsCellTypeAdDefault:
        case SNRollingNewsCellTypeAdSmallpicDownload:
        {
            titleLeft = _hasImage ? TITLE_LEFT : CONTENT_LEFT;
            titleTop += [self getTitleTopValue];
        }
            break;
        case SNRollingNewsCellTypeBook:
        {
            titleLeft = CONTENT_LEFT + CELL_BOOK_IMAGE_WIDTH + CELL_IMAGE_TITLE_DISTANCE;
        }
            break;
        default:
            break;
    }
    
    if ([self titleAlignmentCenter]) {
        //字体标题居中显示
        float lineTop = [SNUtility shownBigerFont]?4:7;
        titleTop = (self.height - self.titleHeight)/2 +  (_titleLineCnt == 1 ? 8 : lineTop);
        CGRect titleRect = CGRectMake(titleLeft,titleTop, self.titleWidth, self.titleHeight);
        
        [UIView drawTextWithString:self.titleAttStr
                          textRect:titleRect
                           context:context];
    }
    else
    {

        titleTop += [SNDevice sharedInstance].isMoreThan320 ? 0 : 1;
        CGRect titleRect = CGRectMake(titleLeft,titleTop, self.titleWidth, self.titleHeight);
        
        [UIView drawTextWithString:self.titleAttStr
                          textRect:titleRect
                        viewHeight:self.height
                           context:context];
    }
  
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect
{    
    //标题、摘要
    [self drawTitleAndAbstract];
    
    //标记
    [self drawAllMarks];
}

- (void)drawTypeIconWithText:(NSString*)text textColor:(UIColor*)textColor rect:(CGRect)rect backgroundColor:(UIColor*)backColor
{
    //背景色块
    [CoreGraphicHelper drawRoundedMask:rect color:backColor];
    [textColor set];
    rect.origin.y+=1;
    [text drawInRect:rect withFont:[UIFont systemFontOfSize:8] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
}

//视频播放人数
- (void)drawTvPlayNumWithPoint:(CGPoint) commentPoint
{
    if (_tvPlayNum) {
        CGRect iconRect = CGRectMake(commentPoint.x, commentPoint.y+1, ICON_WIDTH, ICON_HEIGHT);
        UIImage *iconImage =[UIImage themeImageNamed:@"icohome_videoviews_v5.png"];
        if (self.newsType == NEWS_ITEM_TYPE_NEWS_VIDEO) {
            iconImage =[UIImage themeImageNamed:@"video_play_num.png"];
        }
        [iconImage drawInRect:iconRect blendMode:kCGBlendModeNormal alpha:1.0];
        markText_x += ICON_WIDTH;
        
        if (_tvPlayNum.length > 0) {
            @autoreleasepool {
                NSString *tvnumText = [self gettvPlayNum];
                float fontSize = [UIFont fontSizeWithType:UIFontSizeTypeB];
                UIFont *font = [UIFont systemFontOfSize:kThemeFontSizeB];
                CGSize tvnumSize = [tvnumText sizeWithFont:font];
                CGFloat offsetX = 5;
                if ([[SNDevice sharedInstance] isPlus]) {
                    offsetX = 18 / 3;
                }
                CGRect textRect = CGRectMake(commentPoint.x+ICON_WIDTH+offsetX, commentPoint.y, tvnumSize.width, fontSize+1);
                [tvnumText drawInRect:textRect
                             withFont:font
                        lineBreakMode:NSLineBreakByTruncatingTail
                            alignment:NSTextAlignmentLeft];
                
                if (tvnumText.length > 0) {
                    markText_x += tvnumSize.width +6;
                }
            }
        }
        
        markText_x += 14;
    }
}

//评论数
- (void)drawCommentsWithPoint:(CGPoint) commentPoint
{
    if (_hasComments) {
        if (_commentNum.length > 0) {
            @autoreleasepool {
                NSString *commentText = [self getCommentsCount];
                float fontSize = [UIFont fontSizeWithType:UIFontSizeTypeB];
                UIFont *commentFont = [UIFont systemFontOfSize:kThemeFontSizeB];
                CGSize commentSize = [commentText sizeWithFont:commentFont];

                CGRect textRect = CGRectMake(commentPoint.x, commentPoint.y, commentSize.width, fontSize+1);
                [commentText drawInRect:textRect
                               withFont:commentFont
                          lineBreakMode:NSLineBreakByTruncatingTail
                              alignment:NSTextAlignmentLeft];
                
                if (commentText.length > 0) {
                    //by 5.9.4 wangchuanwen modify
                    //markText_x += commentSize.width +6;
                    markText_x += commentSize.width + MARKTEXT_GAP;
                    //modify end
                }
            }
        }
    }
}

//推荐理由
- (void)drawRecommendReasonsWithPoint:(CGPoint)point {
    if (self.recomReasons.length == 0) {
        return;
    }
    
    CGFloat offsetY = [[SNDevice sharedInstance] isPlus] ? 1.5 : 1;
   
    CGFloat fontSize = kThemeFontSizeA;
    CGSize reasonSize = [self.recomReasons sizeWithFont:[UIFont systemFontOfSize:fontSize]];
    CGRect reasonRect = CGRectMake(point.x + 1.9, point.y+offsetY, reasonSize.width, fontSize);
    
    CGFloat height = [UIFont fontSizeWithType:UIFontSizeTypeB];
    CGRect drawRect = CGRectMake(point.x, point.y + 1, reasonSize.width + 3.0, height);
    
    if ([self.recomReasons isEqualToString:@"要闻"] || [self.recomReasons isEqualToString:@"快讯"]) {
        CGFloat x1 = point.x, y1 = point.y + 1;
        CGFloat x2 = point.x + reasonSize.width + 3, y2 = point.y + height + 1;
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIColor *lineColor = SNUICOLOR(kThemeRed2Color);
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
        //by 5.9.4 wangchuanwen modify
        /*CGContextMoveToPoint(context, x1, y1+10);
        CGContextAddArcToPoint(context, x1, y1, x2, y1, 2);
        CGContextAddArcToPoint(context, x2, y1, x2, y2, 2);
        CGContextAddArcToPoint(context, x2, y2, x1, y2, 2);
        CGContextAddArcToPoint(context, x1, y2, x1, y1, 2);
        CGContextSetFillColorWithColor(context, lineColor.CGColor);
        CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
         */
        
        CGContextMoveToPoint(context, x1, y1+10);
        CGContextAddArcToPoint(context, x1, y1, x2, y1, 0);
        CGContextAddArcToPoint(context, x2, y1, x2, y2, 0);
        CGContextAddArcToPoint(context, x2, y2, x1, y2, 0);
        CGContextAddArcToPoint(context, x1, y2, x1, y1, 0);
        CGContextSetFillColorWithColor(context, lineColor.CGColor);
        CGContextDrawPath(context, kCGPathFill); //根据坐标绘制路径
        //by modify end
        CGContextClosePath(context);
        
        UIColor *color = SNUICOLOR(kThemeText11Color);
        [color set];
    }
    else{
        
        //by 5.9.4 wangchuanwen modify
        /*CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 0.3);
        UIColor *lineColor = SNUICOLOR(kThemeRed1Color);
        CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:drawRect cornerRadius:2.0];
        CGContextAddPath(context, bezierPath.CGPath);
        CGContextStrokePath(context);*/
        
        fontSize = kThemeFontSizeB;
        CGSize reasonSize = [self.recomReasons sizeWithFont:[UIFont systemFontOfSize:fontSize]];
        reasonRect = CGRectMake(point.x + 0.9, point.y, reasonSize.width, fontSize);
        drawRect = CGRectMake(point.x, point.y + 1, reasonSize.width + 3.0, height);
        //by modify end
        UIColor *color = SNUICOLOR(kThemeRed1Color);
        [color set];
    }
    
    [self.recomReasons drawInRect:reasonRect withFont:[UIFont systemFontOfSize:fontSize] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    
    //by 5.9.4 wangchuanwen modify
    //markText_x += drawRect.size.width + 7.0;
    markText_x += drawRect.size.width + MARKTEXT_GAP;
    //modify end
}

//推荐时间
- (void)drawRecommendTimeWithPoint:(CGPoint)point {
    if (!self.recomTime || [self.recomTime isEqualToString:@"0"] || self.recomTime.length == 0) {
        return;
    }
    
    NSString *timeSting = [self getRecomTimeStye:self.recomTime];
    CGSize timeSize = [timeSting sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
    float fontSize = [UIFont fontSizeWithType:UIFontSizeTypeB];
    CGRect timeRect = CGRectMake(point.x, point.y, timeSize.width, fontSize+1);
    [timeSting drawInRect:timeRect withFont:[UIFont systemFontOfSize:kThemeFontSizeB] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    //markText_x += mediaWidth + 7;
    //markText_x += timeSize.width + 7.0;
    markText_x += timeSize.width + MARKTEXT_GAP;
    //modify end
    self.mediaPointY = 0;
}

- (NSString *)getRecomTimeStye:(NSString *)time {
    NSString *timeStyle = nil;
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970] * 1000;
    int interval = (timeInterval - [time longLongValue]) / (1000 * 60);
    if (interval < 1) {
        timeStyle = @"刚刚";
    }
    else if (interval < 60) {
        timeStyle = [NSString stringWithFormat:@"%d分钟前",interval];
        
    }
    else if (interval < 60 * 24) {
        timeStyle = [NSString stringWithFormat:@"%d小时前",interval / 60];
    }
    else {
        timeStyle = [NSString stringWithFormat:@"%d天前",interval / (60 * 24)];
    }
    
    return timeStyle;
}

//直播状态
- (void)drawLiveStatusWithPoint:(CGPoint) livePoint
{
    @autoreleasepool {
        NSString *liveNumString = [self getCommentsCount];
        liveNumString = [liveNumString isEqualToString:@""] ? @"0" : liveNumString;
        NSString *liveString = [NSString stringWithFormat:@"%@人参与",liveNumString];
        //参与人数或直播开始时间
        if (liveString.length > 0) {
            UIFont *font = [UIFont systemFontOfSize:kThemeFontSizeB];
            CGSize liveSize = [liveString sizeWithFont:font];
            CGRect textRect = CGRectMake(livePoint.x, livePoint.y, liveSize.width+2.0, kThemeFontSizeB+2);
            [liveString drawInRect:textRect
                          withFont:font
                     lineBreakMode:NSLineBreakByTruncatingTail
                         alignment:NSTextAlignmentLeft];
        }
    }
}

//图片数
- (void)drawPicCountWithPoint:(CGPoint) picPoint
{
    if (_picCount > 0) {
        float xPos = picPoint.x;
        float fontSize = kThemeFontSizeB;
        UIFont *picFont = [UIFont systemFontOfSize:kThemeFontSizeB];
        NSString *picCountString = [NSString stringWithFormat:@"%d图",_picCount];
        CGSize textSize = [picCountString sizeWithFont:picFont];
        CGRect textRect = CGRectMake(xPos, picPoint.y, textSize.width, fontSize+1);
        [picCountString drawInRect:textRect
                          withFont:picFont
                     lineBreakMode:NSLineBreakByTruncatingTail
                         alignment:NSTextAlignmentLeft];
        //by 5.9.4 wangchuanwen modify
        //markText_x += textSize.width + 5.0;
        markText_x += textSize.width + MARKTEXT_GAP;
        //modify end

    }
}

//投票
- (void)drawVoteWithPoint:(CGPoint) votePoint
{
    CGRect rect = CGRectMake(votePoint.x, votePoint.y, 15, ICON_HEIGHT);
    UIImage *iconImage = [UIImage themeImageNamed:@"news_vote_icon.png"];
    [iconImage drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    
    markText_x += 15 + 14;
}

//小说类型
- (void)drawBookTypeWithPoint:(CGPoint) bookTypePoint {
    
    UIFont *bookTypeFont = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    CGSize textSize = [_bookType sizeWithFont:bookTypeFont];
    
    //wangchuanwen modify
    //思路：iPhoneX字体变化，造成显示不全，按照产品最多显示字数的最大宽度算
    //int maxWidth = MIN(60, textSize.width);
    int maxWidth = 60;
    CGRect textRect = CGRectMake(bookTypePoint.x - maxWidth, bookTypePoint.y + 3, maxWidth, kThemeFontSizeB+2);

    //[_bookType drawInRect:textRect withFont:bookTypeFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    [_bookType drawInRect:textRect
                 withFont:bookTypeFont
            lineBreakMode:NSLineBreakByTruncatingTail
                alignment:NSTextAlignmentRight];
    //modify end
    
    sponsorships_x -= maxWidth + 7;

}

//小说作者
- (void)drawBookAuthorWithPoint:(CGPoint) authorPoint{
    //去掉作者图片
    //CGRect iconRect = CGRectMake(authorPoint.x, authorPoint.y+5, ICON_WIDTH, ICON_HEIGHT);
    CGRect iconRect = CGRectMake(authorPoint.x, authorPoint.y+5, 0, 0);
    //UIImage *iconImage =[UIImage themeImageNamed:@"icofiction_me_v5.png"];
    //[iconImage drawInRect:iconRect blendMode:kCGBlendModeNormal alpha:1.0];
    //markText_x += ICON_WIDTH;
    
//    if (_commentNum.length > 0) {
        @autoreleasepool {
            NSString *authorText = _bookAuthor;
            float fontSize = [UIFont fontSizeWithType:UIFontSizeTypeB];
            CGSize authorSize = [authorText sizeWithFont:[UIFont digitAndLetterFontOfSize:fontSize]];
            CGFloat offsetX = 5;
            if ([[SNDevice sharedInstance] isPlus]) {
                offsetX = 18 / 3;
            }
            CGRect textRect = CGRectMake(authorPoint.x+offsetX, iconRect.origin.y - 1.2, authorSize.width, fontSize+1);
            [authorText drawInRect:textRect
                           withFont:[UIFont digitAndLetterFontOfSize:fontSize]
                      lineBreakMode:NSLineBreakByTruncatingTail
                          alignment:NSTextAlignmentLeft];
            
            if (authorText.length > 0) {
                markText_x += authorSize.width +6;
            }
        }
//    }
    
    markText_x += 14;

}

//媒体
- (void)drawMediaWithPoint:(CGPoint) mediaPoint
{
//    NSInteger maxWidth = ([[SNDevice sharedInstance] isPlus] || [[SNDevice sharedInstance] isPhone6]) ? 100 : 70;
//    if (_cellType == SNRollingNewsCellTypePhotos) {
//        maxWidth = ([[SNDevice sharedInstance] isPlus] || [[SNDevice sharedInstance] isPhone6]) ? 150 : 120;
//    }
//    CGSize recomSize = [self.recomReasons sizeWithFont:mediaFont];
//    CGFloat xValue = sponsorships_x;
//    if (kAppScreenWidth == 320) {
//        xValue -= 70.0;
//    }
////    if (mediaPoint.x+textSize.width >= sponsorships_x) {
////        maxWidth = 100 - recomSize.width;
////    }
//    
//    int mediaWidth = mediaPoint.x+textSize.width >= xValue ? maxWidth : textSize.width;
//    if (maxWidth != 0) {
//        mediaWidth = MIN(maxWidth, textSize.width);
//    }
//    if (mediaWidth > maxWidth) {
//        if (![self.recomTime isEqualToString:@"0"] && self.recomTime.length != 0) {
//            NSString *timeSting = [self getRecomTimeStye:self.recomTime];
//            CGSize timeSize = [timeSting sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
//            mediaWidth -= (timeSize.width + recomSize.width);
//        }
//    }
    UIFont *mediaFont = [UIFont systemFontOfSize:kThemeFontSizeB];
    CGSize textSize = [_media sizeWithFont:mediaFont];
    CGFloat maxWidth = sponsorships_x - mediaPoint.x;
    
    if (_hasComments) {
        CGSize commentSize = [[self getCommentsCount] sizeWithFont:mediaFont];
        maxWidth -= commentSize.width + 5;
    }
    
    if (![self.recomTime isEqualToString:@"0"] && self.recomTime.length != 0) {
        NSString *timeSting = [self getRecomTimeStye:self.recomTime];
        CGSize timeSize = [timeSting sizeWithFont:mediaFont];
        maxWidth -= timeSize.width + 5;
    }
    
    if (_picCount > 0) {
        NSString *picCountString = [NSString stringWithFormat:@"%d图",_picCount];
        CGSize textSize = [picCountString sizeWithFont:mediaFont];
        maxWidth -= textSize.width + 5;
    }
    
    CGFloat mediaWidth = MIN(maxWidth, textSize.width);
    float fontSize = [UIFont fontSizeWithType:UIFontSizeTypeB];
    CGRect textRect = CGRectMake(mediaPoint.x,mediaPoint.y,mediaWidth,fontSize+1);
    [_media drawInRect:textRect
              withFont:mediaFont
         lineBreakMode:NSLineBreakByTruncatingTail
             alignment:NSTextAlignmentLeft];
    
    //by 5.9.4 wangchuanwen modify
    //markText_x += mediaWidth + 10.0;
    markText_x += mediaWidth + MARKTEXT_GAP;
    //modify
    self.mediaPointY = mediaPoint.y;
}

//媒体
- (void)drawVideoMediaWithPoint:(CGPoint) mediaPoint
{
    UIFont *mediaFont = [UIFont systemFontOfSize:kThemeFontSizeB];
    CGSize textSize = [_media sizeWithFont:mediaFont];
    float pointx = mediaPoint.x;

    CGFloat tempWidth = kAppScreenWidth - pointx - kMoreButtonWidth - CONTENT_LEFT;
    CGFloat mediaWidth = MIN(textSize.width, tempWidth);
//    if (self.cellType == SNRollingNewsCellTypeNewsVideo) {
//        mediaWidth = MIN(textSize.width, 110);
//    }
    
    CGRect textRect = CGRectMake(pointx,mediaPoint.y,mediaWidth,kThemeFontSizeB+2);
    [_media drawInRect:textRect
              withFont:mediaFont
         lineBreakMode:NSLineBreakByTruncatingTail
             alignment:NSTextAlignmentLeft];
    //by 5.9.4 wangchuanwen modify
    //markText_x += mediaWidth + 7;
    markText_x += mediaWidth + MARKTEXT_GAP;
    //modify end
}


//本地
- (void)drawLocalWithPoint:(CGPoint) localPoint
{
    /*
     UIImage *locationImage = [UIImage imageNamed:@"icohome_Localsmall_v5.png"];
    CGRect locationRect = CGRectMake(localPoint.x-5, localPoint.y+2, ICON_WIDTH, ICON_HEIGHT);
    [locationImage drawInRect:locationRect blendMode:kCGBlendModeNormal alpha:1.0];
     */
    
    UIFont *localFont = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    CGSize textSize = [_local sizeWithFont:localFont];
    CGRect textRect = CGRectMake(localPoint.x + 5.0, localPoint.y, textSize.width, kThemeFontSizeB+2);
    [self.local drawInRect:textRect
                  withFont:localFont
             lineBreakMode:NSLineBreakByTruncatingTail
                 alignment:NSTextAlignmentLeft];
    
    markText_x += + textSize.width + 14.0;
}

//视频详情
- (void)drawVideoDetailWithPoint:(CGPoint) detailsPoint
{
    float fontSize = [UIFont fontSizeWithType:UIFontSizeTypeB];
    CGRect textRect = CGRectMake(detailsPoint.x, detailsPoint.y, 50, fontSize+1);
    [@"查看详情" drawInRect:textRect
                  withFont:[UIFont systemFontOfSizeType:UIFontSizeTypeB]
             lineBreakMode:NSLineBreakByTruncatingTail
                 alignment:NSTextAlignmentLeft];
}

///广告来源
- (void)drawAdvertiserWithPoint:(CGPoint) advertiserPoint
{
    if (_advertiser.length > 0) {
        float fontSize = [UIFont fontSizeWithType:UIFontSizeTypeB];
        CGSize textSize = [@"限制来源八汉字长" textSizeWithFont:[UIFont systemFontOfSizeType:UIFontSizeTypeB]];
        CGRect textRect = CGRectMake(advertiserPoint.x, advertiserPoint.y, textSize.width, fontSize+1);
        [_advertiser drawInRect:textRect
                       withFont:[UIFont systemFontOfSizeType:UIFontSizeTypeB]
                  lineBreakMode:NSLineBreakByTruncatingTail
                      alignment:NSTextAlignmentLeft];
    }
}

//时间
- (void)drawTimeWithPoint:(CGPoint) timePoint
{
    NSString *timeString = [NSDate relativelyDate:_time];
    UIFont *timeFont = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    CGSize textSize = [timeString sizeWithFont:timeFont];
    float timeWidth = timePoint.x+textSize.width >= sponsorships_x?50:textSize.width;
    CGRect textRect = CGRectMake(timePoint.x, timePoint.y, timeWidth, LABLETEXT_HEIGHT);
    [timeString drawInRect:textRect
                  withFont:[UIFont systemFontOfSizeType:UIFontSizeTypeB]
             lineBreakMode:NSLineBreakByTruncatingTail
                 alignment:NSTextAlignmentLeft];
}

- (void)drawNewsTypeWithPoint:(CGPoint) textPoint
{
    if (self.recomReasons.length > 0) {
        if (self.newsTypeTextString.length == 0) {
            return;
        }
        else {
            _newsTypeString = self.newsTypeTextString;
        }
    }
    
    if (_newsTypeString.length > 0) {
        UIFont *font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
        CGSize textSize = [_newsTypeString sizeWithFont:font];
        CGRect textRect = CGRectMake(textPoint.x - textSize.width, textPoint.y, textSize.width, kThemeFontSizeB+2);
        [_newsTypeString drawInRect:textRect
                           withFont:font
                      lineBreakMode:NSLineBreakByTruncatingTail
                          alignment:NSTextAlignmentLeft];
        //by 5.9.4 wangchuanwen modify
        //sponsorships_x -= textSize.width + 7;
        sponsorships_x -= textSize.width + MARKTEXT_GAP;
        //modify end
    }
}

- (void)drawSponsorshipsWithPoint:(CGPoint) textPoint
{
    if (_sponsorships.length > 0) {
        UIFont *font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
        CGSize textSize = [_sponsorships sizeWithFont:font];
        int maxWidth = MIN(60, textSize.width);
        CGRect textRect = CGRectMake(textPoint.x - maxWidth, textPoint.y, maxWidth, kThemeFontSizeB+2);
        [_sponsorships drawInRect:textRect
                         withFont:font
                    lineBreakMode:NSLineBreakByTruncatingTail
                        alignment:NSTextAlignmentLeft];
        
        //by 5.9.4 wangchuanwen modify
        //sponsorships_x -= maxWidth + 7;
        sponsorships_x -= maxWidth + MARKTEXT_GAP;
        //modify end
    }
}

- (void)drawCellTypeBookMark:(CGFloat)markText_y{
    markText_x = (CONTENT_LEFT + CELL_BOOK_IMAGE_WIDTH + CELL_IMAGE_TITLE_DISTANCE);
    //如果是小说 显示作者
    if (_bookAuthor) {
        [self drawBookAuthorWithPoint:CGPointMake(markText_x, markText_y)];
    }
    if (_bookType) {
        [self drawBookTypeWithPoint:CGPointMake(sponsorships_x, markText_y)];
    }
}

- (void)drawAllMarks
{
    markText_x = CONTENT_LEFT;
    sponsorships_x = kAppScreenWidth - CONTENT_LEFT;
    CGFloat markText_y = self.height - IMAGE_TOP - COMMENT_BOTTOM;
    BOOL isMoreThan320 = [SNDevice sharedInstance].isMoreThan320;
  
    if ([self hasImageCellType]) {
        //by 5.9.4 wangchuanwen modify
        //markText_x = [SNUtility shownBigerFont] ? CONTENT_LEFT : TITLE_LEFT;
        BOOL isBigerFont = [SNUtility shownBigerFont];
        BOOL isMoreTwoLines = _titleLineCnt > 2;
        if (!isBigerFont) {
            
            if (isMoreTwoLines) {
                markText_y = self.height - IMAGE_TOP - COMMENT_BOTTOM - (isMoreThan320?-1:-2);
            } else {
                markText_y = self.height - IMAGE_TOP - COMMENT_BOTTOM + (isMoreThan320?1:2);
            }
        }else{
            
            if (!isMoreTwoLines) {
                markText_y = self.height - IMAGE_TOP - COMMENT_BOTTOM + (isMoreThan320?1:2);
            }else{
                markText_y += [SNUtility shownBigerFont] ? 1 : 0;
            }
        }
        //图文模版，特大字体或当标题高度接近图片高度，标记与图片左边对齐
        BOOL isChangX = isMoreTwoLines;
        markText_x = isChangX ? CONTENT_LEFT : TITLE_LEFT;
        //modify end
    }else{
        
        markText_y += [SNUtility shownBigerFont] ? 2 : 0;
    }
  
    UIColor *newsTypeColor = [self getNewsTypeColor];
    if (newsTypeColor) {
        [newsTypeColor set];
    }
    
    if (_hasMoreButton) {
        sponsorships_x -= 11 + 14;
    }
    
    //小说样式处理
    if (_cellType == SNRollingNewsCellTypeBook){
        [self drawCellTypeBookMark:markText_y - 3];
        return;
    }
    
    switch (self.cellType) {
        case SNRollingNewsCellTypeTitle:
        case SNRollingNewsCellTypeAbstrac:
            markText_y = [self getMarkYValue];
            break;
        //by 5.9.4 wangchuanwen modify
        //item间距调整 mark标题
        case SNRollingNewsCellTypePhotos:
        case SNRollingNewsCellTypeAdPhotos:
            markText_y = self.height - CONTENT_BOTTOM - 10;
            break;
        case SNRollingNewsCellTypeAdMixpicDownload:
        case SNRollingNewsCellTypeAdMixpicPhone://和组图下载模版UI一致
            markText_y = self.height - CONTENT_BOTTOM - 9;
            break;
        case SNRollingNewsCellTypeAdPicture:
        case SNRollingNewsCellTypeAdBigpicDownload:
        case SNRollingNewsCellTypeAdBigpicPhone://和大图下载模版UI一致
            markText_y = self.height - (isMoreThan320?25:24);
            break;
        case SNRollingNewsCellTypeNewsVideo:
            markText_y = self.height - ((self.titleLineCnt > 1)?26:25);
            break;
        case SNRollingNewsCellTypeAdBanner:
            markText_y = self.height - 25;
            break;
        case SNRollingNewsCellTypeMatch:
        case SNRollingNewsCellTypeAdVideoDownload:
        case SNRollingNewsCellTypeVideo://lijian 2015.1.1 增加视频广告的标题
            markText_y = self.height - 26;
            break;
        //modify end
        case SNRollingNewsCellTypeRedPacket:
        case SNRollingNewsCellTypeCoupons:
            markText_y += 3;
            break;
        default:
            break;
    }

    
    //CGFloat offsetY = (_cellType == SNRollingNewsCellTypeAdSmallpicDownload) ? ([SNUtility shownBigerFont] ? 49 : 49) : 0;
    CGFloat offsetY = (_cellType == SNRollingNewsCellTypeAdSmallpicDownload) ? 49 : 0;
    //推荐理由
    [self drawRecommendReasonsWithPoint:CGPointMake(markText_x, markText_y - offsetY)];
    //新闻类型
    [self drawNewsTypeWithPoint:CGPointMake(sponsorships_x, markText_y - offsetY)];
    //冠名
    [self drawSponsorshipsWithPoint:CGPointMake(sponsorships_x, markText_y - offsetY)];
    
    [_markTextColor set];
    
    //快讯时间
    if (_isFlash) {
        [self drawTimeWithPoint:CGPointMake(markText_x, markText_y)];
        return;
    }
    
    //视频广告详情  && //广告来源
    if (_cellType == SNRollingNewsCellTypeVideo && _hasDetailLink) {
        [self drawVideoDetailWithPoint:CGPointMake(markText_x, markText_y)];
        [self drawAdvertiserWithPoint:CGPointMake(markText_x + 44 + 14, markText_y)];
    }
    else{
        //广告来源
        if (_cellType != SNRollingNewsCellTypeAdSmallpicDownload && _cellType != SNRollingNewsCellTypeAdMixpicDownload && _cellType != SNRollingNewsCellTypeAdBigpicDownload && _cellType != SNRollingNewsCellTypeAdMixpicPhone && _cellType != SNRollingNewsCellTypeAdBigpicPhone && _cellType != SNRollingNewsCellTypeAdVideoDownload) {
            [self drawAdvertiserWithPoint:CGPointMake(markText_x, markText_y - offsetY)];
        }
    }
    
    //投票
    if (_voteMark && !_isSearch) {
        //[self drawVoteWithPoint:CGPointMake(markText_x, markText_y)];
    }
    
    //媒体来源
    if ((_media.length > 0 || _local.length > 0) && (_newsType != NEWS_ITEM_TYPE_NEWS_VIDEO)) {
        //视频大屏模式时不要显示来源
        if ([self isLink2VideoBigMode]) {
            _media = nil;
        }
    
        [self drawMediaWithPoint:CGPointMake(markText_x, markText_y)];
    }
    
    //时间
    if (_time.length >0) {
        BOOL drawTime = _isSearch ? YES : NO;
        switch (_newsType) {
            case NEWS_ITEM_TYPE_SUBSCRIBE_NEWS:
                drawTime = YES;
                break;
            default:
                break;
        }
        if (drawTime) {
            [self drawTimeWithPoint:CGPointMake(markText_x, markText_y)];
        }
    }
    
    //评论
    switch (_newsType) {
        case NEWS_ITEM_TYPE_NEWSPAPER:
            break;
        case NEWS_ITEM_TYPE_LIVE: {
            [self drawLiveStatusWithPoint:CGPointMake(markText_x, markText_y)];
            return;
        }
        case NEWS_ITEM_TYPE_NEWS_VIDEO: {
            if (self.cellType == SNRollingNewsCellTypeAutoVideoMidImageType && ![SNUtility shownBigerFont] && ![SNUtility changePGCLayOut]) {
                markText_x = (CONTENT_LEFT + kMiddleVideoImageWidth + CELL_IMAGE_TITLE_DISTANCE);
            }
            [self drawTvPlayNumWithPoint:CGPointMake(markText_x, markText_y)];
            
            //媒体来源
            if (_media.length > 0 || _local.length > 0) {
                //视频大屏模式时不要显示来源
                if ([self isLink2VideoBigMode]) {
                    _media = nil;
                }
                if (self.cellType == SNRollingNewsCellTypeAutoVideoMidImageType) {
                    [self drawVideoMediaWithPoint:CGPointMake(markText_x, markText_y)];
                }else if (self.cellType == SNRollingNewsCellTypeNewsVideo) {
                    [self drawVideoMediaWithPoint:CGPointMake(markText_x, markText_y)];
                }else {
                    [self drawMediaWithPoint:CGPointMake(markText_x, markText_y - 4)];
                }
            }

            return;
        }
            
        case NEWS_ITEM_TYPE_NEWS_BOOK:
        {
            break;
        }
            
        default: {
            if (_hasImage) {
                if (_cellType == SNRollingNewsCellTypePhotos) {
                    [self drawCommentsWithPoint:CGPointMake(markText_x, markText_y)];
                    [self drawPicCountWithPoint:CGPointMake(markText_x, markText_y)];
                } else {
                    CGFloat pointY = markText_y;
                    if (kAppScreenWidth == 320.0) {
                        pointY = markText_y - 0.5;
                    }
                    [self drawCommentsWithPoint:CGPointMake(markText_x, pointY)];
                }
            } else {
                [self drawCommentsWithPoint:CGPointMake(markText_x, markText_y)];
            }
            break;
        }
    }
    
    [self drawRecommendTimeWithPoint:CGPointMake(markText_x, markText_y)];
}

- (CGFloat)getMarkYValue{
    return self.height - ICON_HEIGHT - IMAGE_TOP;
}

#pragma mark -

- (BOOL)titleAlignmentCenter{
    
    if (self.cellType == SNRollingNewsCellTypeAdSmallpicDownload) {
        return NO;
    }
    
    //by 5.9.4 wangchuanwen modify
    //图文特大字体不在居中显示，只有三行才可以
    if ( _titleLineCnt > 2 && ([self hasImageCellType] || self.cellType == SNRollingNewsCellTypeAutoVideoMidImageType || self.cellType == SNRollingNewsCellTypeSohuLive)) {
        return YES;
    }
    //modify end
    
    if ((self.cellType == SNRollingNewsCellTypeAutoVideoMidImageType) && [SNUtility changePGCLayOut]) {
        return YES;
    }
   
    return NO;
}

- (CGFloat)getTitleTopValue{
    
    float topValue = 0.0;
    
    BOOL isPGCMiddle = _cellType == SNRollingNewsCellTypeAutoVideoMidImageType;
    return isPGCMiddle ? [self PGCMidImageTitleTop] : [self ImageCellTypeTitleTop];
}

- (CGFloat)getPhotoNewsTitleTopValue{
    int fontSize = [SNUtility getNewsFontSizeIndex];
    float topValue = 0.0;
    if ([[SNDevice sharedInstance] isPlus]) {
        switch (fontSize) {
            case 2:
                topValue =2.0;
                break;
            case 3:
                topValue =5.0;
                break;
            case 4:
                topValue =7.0;
                break;
                
            default:
                break;
        }
        
    }
    else{
        switch (fontSize) {
            case 2:
                topValue =1.0;
                break;
            case 3:
                topValue =3.0;
                break;
            case 4:
                topValue =4.0;
                break;
                
            default:
                break;
        }
    }
    return topValue;
}

- (CGFloat)ImageCellTypeTitleTop{
    CGFloat offsetValue = 0;
    
    if ([self hasImageCellType]) {
        int fontSize = [SNUtility getNewsFontSizeIndex];
        switch (fontSize) {
            case 2:
            {
                offsetValue = -2;
            }
                break;

            case 3:
            {
                offsetValue = -2;
            }
                break;
                
            case 4:
            {
                offsetValue = -4;
            }
                break;
                    
            default:
                break;
        }
        
        if (fontSize == 5 && (self.titleLineCnt <= 2)) {
            offsetValue = [SNDevice sharedInstance].isMoreThan320?(-6):(-4);
        }
    }
    
    return offsetValue;
}
    
- (CGFloat)PGCMidImageTitleTop{
    int fontSize = [SNUtility getNewsFontSizeIndex];
    
    CGFloat offsetValue = 0;
    if ([SNUtility changePGCLayOut]) {
        switch (fontSize) {
            case 3:
            {
                offsetValue = (_titleLineCnt == 3) ? ([SNDevice sharedInstance].isPhone5 ? 5 : 13) : (_titleLineCnt == 2) ? 23 : 35;
                }
                break;
            case 4:
            {
                offsetValue = (_titleLineCnt == 3) ? ([SNDevice sharedInstance].isPhone5 ? 1 : 10)  : (_titleLineCnt == 2) ? 20 : 33;
            }
                break;
                
            case 5:
            {
                offsetValue = (_titleLineCnt == 3) ? ([SNDevice sharedInstance].isPhone5 ? 5.5 : 6) : (_titleLineCnt == 2) ? 15 : 32;
            }
                break;
                    
            default:
                break;
        }
    }
    else
    {
        switch (fontSize) {
            case 4:
            {
                if (_titleLineCnt == 3) {
                    offsetValue -= 4;
                }
            }
                break;
                    
            case 5:
            {
                //特大字号需要居中显示
                if (_titleLineCnt == 3) {
                    offsetValue = [SNDevice sharedInstance].isPlus ? 7 : 0;
                }
                else{
                    if (_titleLineCnt == 2) {
                        offsetValue = [SNDevice sharedInstance].isPlus ? 28 : 18;
                    }
                    else{
                        offsetValue = [SNDevice sharedInstance].isPlus ? 43 : 33;
                    }
                }
            }
                break;
                    
            default:
                break;
        }
    }
    
    return offsetValue;
}

//判断是否为图文模版
+ (BOOL)hasImageCellType:(SNRollingNewsCellType) cellType hasImage:(BOOL)hasImage
{
    BOOL hasImageCell = NO;
    switch (cellType) {
        case SNRollingNewsCellTypeDefault:
        case SNRollingNewsCellTypeMySubscribe:
            hasImageCell = YES;
            break;
        case SNRollingNewsCellTypeAdDefault:
        case SNRollingNewsCellTypeAdSmallpicDownload:
            hasImageCell = hasImage;
            break;
        default:
            break;
    }
    return hasImageCell;
}

@end
