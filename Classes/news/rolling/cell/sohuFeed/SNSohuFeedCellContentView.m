//
//  SNSohuFeedCellContentView.m
//  sohunews
//
//  Created by wangyy on 2017/5/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSohuFeedCellContentView.h"
#import "NSCellLayout.h"
#import "UIFont+Theme.h"
#import "SNImageView.h"

#define MarkTextGap                  14

@interface SNSohuFeedCellContentView () {
    float markText_x;
}

@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, strong) SNImageView *headImage;

@end

@implementation SNSohuFeedCellContentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
        self.isAccessibilityElement = NO;
        
        _headImage = [[SNImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, IMAGE_TOP, FEED_HEADIMAGE_HIGHT, FEED_HEADIMAGE_HIGHT)];
        _headImage.contentMode = UIViewContentModeScaleAspectFill;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_headImage.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:_headImage.bounds.size];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
        //设置大小
        maskLayer.frame = _headImage.bounds;
        //设置图形样子
        maskLayer.path = maskPath.CGPath;
        _headImage.layer.mask = maskLayer;
        
        [self addSubview:_headImage];
        
        _defaultImage = [UIImage imageNamed:@"feedBack_defaultIcon_v5.png"];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    [self drawSohuFeedHeaderInfo];
    [self drawAllMark];
}

- (void)drawSohuFeedHeaderInfo {
    //头像
    [self drawAvatorImage];
    
    //title
    [self drawfeedTitle];
    
    //昵称
    [self drawUserName];
}

- (void)drawAvatorImage {
    [self.headImage loadBySystemRequest:self.avatorUrl defaultImage:_defaultImage];
    self.headImage.alpha = themeImageAlphaValue();
}

- (void)drawUserName {
    if (_userName != nil && _userName.length != 0) {
        UIFont *nameFont = [SNUtility getFeedUserNameFont];
        float nameHeight = [SNUtility getNewsTitleFontSize] + 1;
        
        CGFloat left = self.headImage.right + FEED_SPACEVALUE;
        CGFloat top = self.headImage.top + (self.headImage.height - nameHeight) / 2;
        CGFloat maxWidth = self.titleWidth - FEED_SPACEVALUE - FEED_HEADIMAGE_HIGHT;
        CGSize nameSize = [_userName sizeWithFont:nameFont];
        CGFloat width = MIN(maxWidth, nameSize.width);
        
        [self.userNameColor set];
        CGRect timeRect = CGRectMake(left, top, width, nameHeight);
        [_userName drawInRect:timeRect withFont:nameFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    }
}

- (void)drawfeedTitle {
    if (!self.titleAttStr) {
        return;
    }
    CGFloat titleTop = self.headImage.bottom + FEED_SPACEVALUE - FEED_TITLE_LINE_SPACE - 1;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGAffineTransform flip = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, self.frame.size.height);
    CGContextConcatCTM(context, flip);
    
 
    CGRect titleRect = CGRectMake(CONTENT_LEFT,titleTop, self.titleWidth, self.titleHeight);
    
    [UIView drawTextWithString:self.titleAttStr
                      textRect:titleRect
                    viewHeight:self.height
                       context:context];
    
    CGContextRestoreGState(context);
}

- (void)drawAllMark {
    markText_x = CONTENT_LEFT;
    //by 5.9.4 wangchuanwen modify
    //item间距调整 drawAllMark
    CGFloat markText_y = self.height - 25;
    //modify end
    
    [self drawRecommendReasonsWithPoint:CGPointMake(markText_x, markText_y)];
    
    UIColor *markTextColor = SNUICOLOR(kThemeTextRI1Color);
    [markTextColor set];
    
    [self drawTransfersWithPoint:CGPointMake(markText_x, markText_y)];
    [self drawCommentsWithPoint:CGPointMake(markText_x, markText_y)];
    [self drawRecommendTimeWithPoint:CGPointMake(markText_x, markText_y)];
}

//已关注
- (void)drawRecommendReasonsWithPoint:(CGPoint)point {
    if (self.recomReasons.length == 0 || ![self.recomReasons isEqualToString:@"已关注"]) {
        return;
    }
    
    //by 5.9.4 wangchuanwen modify
    CGFloat fontSize = kThemeFontSizeB;
    CGSize reasonSize = [self.recomReasons sizeWithFont:[UIFont systemFontOfSize:fontSize]];
    CGRect reasonRect = CGRectMake(point.x + 1.9, point.y, reasonSize.width, fontSize);
    
    CGFloat height = [UIFont fontSizeWithType:UIFontSizeTypeB];
    CGRect drawRect = CGRectMake(point.x, point.y + 1, reasonSize.width + 3.0, height);
    
    UIColor *color = SNUICOLOR(kThemeRed1Color);
    [color set];
    
    [self.recomReasons drawInRect:reasonRect withFont:[UIFont systemFontOfSize:fontSize] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
    markText_x += drawRect.size.width + MarkTextGap;
    //modify end
}

//转发数
- (void)drawTransfersWithPoint:(CGPoint)point {
    if (_transferNum == 0) {
        return;
    }
    
    NSString *transferStr = [NSString stringWithFormat:@"%@转发", [self getCountString:_transferNum]];
    float fontSize = [UIFont fontSizeWithType:UIFontSizeTypeB];
    UIFont *transferFont = [UIFont systemFontOfSize:kThemeFontSizeB];
    CGSize transferSize = [transferStr sizeWithFont:transferFont];
    
    CGRect textRect = CGRectMake(point.x, point.y, transferSize.width, fontSize + 1);
    [transferStr drawInRect:textRect
                   withFont:transferFont
              lineBreakMode:NSLineBreakByTruncatingTail
                  alignment:NSTextAlignmentLeft];
    
    //by 5.9.4 wangchuanwen modify
    markText_x += transferSize.width + MarkTextGap;
    //modify end
}

//评论数
- (void)drawCommentsWithPoint:(CGPoint)point {
    if (_commentNum == 0) {
        return;
    }
    
    NSString *commentStr = [NSString stringWithFormat:@"%@评论", [self getCountString:_commentNum]];
    float fontSize = [UIFont fontSizeWithType:UIFontSizeTypeB];
    UIFont *commentFont = [UIFont systemFontOfSize:kThemeFontSizeB];
    CGSize commentSize = [commentStr sizeWithFont:commentFont];
    
    CGRect textRect = CGRectMake(point.x, point.y, commentSize.width, fontSize + 1);
    [commentStr drawInRect:textRect
                   withFont:commentFont
              lineBreakMode:NSLineBreakByTruncatingTail
                  alignment:NSTextAlignmentLeft];
    //by 5.9.4 wangchuanwen modify
    markText_x += commentSize.width + MarkTextGap;
    //modify end
}

- (NSString *)getCountString:(int)count {
    NSString *countStr = nil;
    if (count > 1000000) {
        countStr = [NSString stringWithFormat:@"%.0f万",count/10000.0f];
    } else if (count > 10000) {
        countStr = [NSString stringWithFormat:@"%.1f万",count/10000.0f];
        countStr = [countStr stringByReplacingOccurrencesOfString:@".0" withString:@""];
    } else {
        countStr = [NSString stringWithFormat:@"%d", count];
        countStr = [countStr isEqualToString:@"0"] ? @"" : countStr;
    }
    return countStr;
}

- (void)drawRecommendTimeWithPoint:(CGPoint)point {
    if (!self.recomTime || [self.recomTime isEqualToString:@"0"] || self.recomTime.length == 0) {
        return;
    }
    
    NSString *timeSting = [self getRecomTimeStye:self.recomTime];
    CGSize timeSize = [timeSting sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
    float fontSize = [UIFont fontSizeWithType:UIFontSizeTypeB];
    CGRect timeRect = CGRectMake(point.x, point.y, timeSize.width, fontSize+1);
    [timeSting drawInRect:timeRect withFont:[UIFont systemFontOfSize:kThemeFontSizeB] lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentLeft];
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

@end
