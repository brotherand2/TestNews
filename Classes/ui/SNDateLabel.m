//
//  SNDateLabel.m
//  sohunews
//
//  Created by 郭亚伦 on 9/26/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDateLabel.h"
#import "UIColor+ColorUtils.h"
@implementation SNDateLabel
@synthesize dateString = _dateString;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    NSString *day = @"";
    NSString *month = @"";
    NSString *year = @"";

    @try {
        day = [_dateString substringFromIndex:8];
        month = [_dateString substringWithRange:NSMakeRange(5, 2)];
        month = [month stringByAppendingString:@"月"];
        year = [_dateString substringToIndex:4];
    }
    @catch (NSException *exception) {
        SNDebugLog(@"error: SNDateLabel (drawRect:) _dateString:%@ %@", _dateString, exception);
        day = @"";
        month = @"";
        year = @"";
    }
    @finally {
    }

    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGContextSetLineWidth(context, 5);
    
    [[UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kLogoDateColor]] set];

    [day drawInRect:CGRectMake(15, 9, 43, 30)
           withFont:[UIFont fontWithName:kDigitAndLetterFontFimalyName size:35]
      lineBreakMode:NSLineBreakByTruncatingTail
          alignment:NSTextAlignmentRight];
    
    CGContextSetLineWidth(context, 1);

    [month drawInRect:CGRectMake(50, 15, 40, 15)
             withFont:[UIFont fontWithName:kDigitAndLetterFontFimalyName size:13]
        lineBreakMode:NSLineBreakByTruncatingTail
            alignment:NSTextAlignmentRight];
    
    [year drawInRect:CGRectMake(50, 30, 40, 15)
            withFont:[UIFont fontWithName:kDigitAndLetterFontFimalyName size:13]
       lineBreakMode:NSLineBreakByTruncatingTail
           alignment:NSTextAlignmentRight];
    
    CGContextSetTextDrawingMode(context, kCGTextStroke);

}

- (void)setDateString:(NSString *)dateString
{
    if (_dateString != dateString) {
        _dateString = dateString;
        [self setNeedsDisplay];
    }
}


- (void)dealloc
{
    self.dateString = nil;
}

@end
