//
//  SNPageControl.m
//  sohunews
//
//  Created by Dan on 7/18/11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNPageControl.h"

// Tweak these or make them dynamic.
#define kDotDiameter 6.0
#define kDotSpacer (10.0 / 2) //8.0

@implementation SNPageControl

@synthesize dotColorCurrentPage;
@synthesize dotColorOtherPage;
@synthesize hidesForSinglePage;
@synthesize delegate;

- (NSInteger)currentPage
{
    return _currentPage;
}

- (void)setCurrentPage:(NSInteger)page
{
    _currentPage = MIN(MAX(0, page), _numberOfPages-1);
    [self setNeedsDisplay];
}

- (NSInteger)numberOfPages
{
    return _numberOfPages;
}

- (void)setNumberOfPages:(NSInteger)pages
{
    _numberOfPages = MAX(0, pages);
    _currentPage = MIN(MAX(0, _currentPage), _numberOfPages-1);
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame 
{
    if ((self = [super initWithFrame:frame])) 
    {
        // Default colors.
        self.backgroundColor = [UIColor clearColor];
        self.dotColorCurrentPage = [UIColor blackColor];
        self.dotColorOtherPage = [UIColor lightGrayColor];
    }
    return self;
}

- (void)setDotColorCurrentPage:(UIColor *)thedotColorCurrentPage
{
    dotColorCurrentPage = thedotColorCurrentPage;
    [self setNeedsDisplay];
}

- (void)setDotColorOtherPage:(UIColor *)thedotColorOtherPage
{
    dotColorOtherPage = thedotColorOtherPage;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect 
{
    if (hidesForSinglePage && 1 == _numberOfPages) {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();   
    CGContextSetAllowsAntialiasing(context, true);
    
    CGRect currentBounds = self.bounds;
    CGFloat x = 0;
    if (self.dotsAlignment == NSTextAlignmentLeft) {
        x = 0;
    }
    else if (self.dotsAlignment == NSTextAlignmentCenter) {
        x = (CGRectGetMaxX(currentBounds) + kDotSpacer - (kDotDiameter + kDotSpacer) * _numberOfPages)/2.0f;
    }
    else if (self.dotsAlignment == NSTextAlignmentRight) {
        x = CGRectGetMaxX(currentBounds)- kDotSpacer - (kDotDiameter + kDotSpacer) * _numberOfPages;
    }
    else {
        x = CGRectGetMaxX(currentBounds)- kDotSpacer - (kDotDiameter + kDotSpacer) * _numberOfPages;
    }
    
    CGFloat y = CGRectGetMidY(currentBounds)-kDotDiameter/2;
    for (int i=0; i<_numberOfPages; i++)
    {
        CGRect circleRect = CGRectMake(x, y, kDotDiameter, kDotDiameter);
        if (i == _currentPage)
        {
            CGContextSetFillColorWithColor(context, self.dotColorCurrentPage.CGColor);
        }
        else
        {
            CGContextSetFillColorWithColor(context, self.dotColorOtherPage.CGColor);
        }
        CGContextFillEllipseInRect(context, circleRect);        
        x +=  kDotDiameter + kDotSpacer;
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.delegate) return;
    
    CGPoint touchPoint = [[[event touchesForView:self] anyObject] locationInView:self];
    
    CGFloat dotSpanX = self.numberOfPages*(kDotDiameter + kDotSpacer);
    CGFloat dotSpanY = kDotDiameter + kDotSpacer;
    
    CGRect currentBounds = self.bounds;
    CGFloat x = touchPoint.x + dotSpanX/2 - CGRectGetMidX(currentBounds);
    CGFloat y = touchPoint.y + dotSpanY/2 - CGRectGetMidY(currentBounds);
    
    if ((x<0) || (x>dotSpanX) || (y<0) || (y>dotSpanY)) return;
    
    self.currentPage = floor(x/(kDotDiameter+kDotSpacer));
    if ([self.delegate respondsToSelector:@selector(pageControlPageDidChange:)])
    {
        [self.delegate pageControlPageDidChange:self];
    }
}

@end
