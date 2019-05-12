//
//  SNAbstractView.m
//  sohunews
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNAbstractView.h"
#import "SNPhotoSlideshow.h"
#import "UIColor+ColorUtils.h"

@implementation SNAbstractView

@synthesize photo, lastOrigin;

-(void)createView:(CGRect)frame {
//    CALayer *bgLayer = [CALayer layer];
//    bgLayer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4].CGColor;
//    bgLayer.frame = CGRectMake(0, 0, CGRectGetWidth(frame),CGRectGetHeight(frame));
//    [self.layer addSublayer:bgLayer];
    
    UIButton *titleSectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleSectionBtn addTarget:self action:@selector(animationAbstractView) forControlEvents:UIControlEventTouchUpInside];
    titleSectionBtn.frame = CGRectMake(0, 0, CGRectGetWidth(frame), TITLE_SECTION_HEIGHT);
    titleSectionBtn.backgroundColor = [UIColor clearColor];
    titleSectionBtn.exclusiveTouch = YES;
    [self addSubview:titleSectionBtn];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_MARGIN, 
                                                           (TITLE_SECTION_HEIGHT - TITLE_LABEL_HEIGHT - 2)/2, 
                                                           CGRectGetWidth(frame)-5-INDEX_VIEW_WIDTH-5-CONTENT_MARGIN*2, 
                                                           TITLE_LABEL_HEIGHT + 2)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setFont:[UIFont systemFontOfSize:TITLE_LABEL_HEIGHT]];
    NSString *strColor = [[SNThemeManager sharedThemeManager] currentThemeValueForKey:kPhotoSliderAbstractTextColor];
    [titleLabel setTextColor:[[[UIColor alloc] initWithString:strColor] autorelease]];
    [titleSectionBtn addSubview:titleLabel];
    [titleLabel release];
    
    indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleSectionBtn.width - 10 - INDEX_VIEW_WIDTH,
                                                           (TITLE_SECTION_HEIGHT - 13)/2, 
                                                           INDEX_VIEW_WIDTH, 
                                                           INDEX_VIEW_HEIGHT)];
    [indexLabel setBackgroundColor:[UIColor clearColor]];
    [indexLabel setTextColor:[[[UIColor alloc] initWithString:strColor] autorelease]];
    [indexLabel setTextAlignment:UITextAlignmentRight];
    [indexLabel setFont:[UIFont systemFontOfSize:INDEX_VIEW_HEIGHT-1]];
    [titleSectionBtn addSubview:indexLabel];
    [indexLabel release];
    
//    NSString *name = [[SNThemeManager sharedThemeManager] themeFileName:@"arrow_photo.png"];
//    arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
//    arrowImageView.frame = CGRectMake(indexLabel.frame.origin.x + CGRectGetWidth(indexLabel.frame)+5, 
//                                      (TITLE_SECTION_HEIGHT-ARROW_IMAGE_H)/2, 
//                                      ARROW_IMAGE_W, 
//                                      ARROW_IMAGE_H);
//    [titleSectionBtn addSubview:arrowImageView];
//    arrowImageView.alpha = 0;
//    
//    if (![self isShown]) {
//        [arrowImageView.layer setTransform:CATransform3DMakeRotation(M_PI, 1.0f, 0.0f, 0.0f)];
//    }
//    
//    
//    [arrowImageView release];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 
                                                                titleSectionBtn.height - 5,
                                                                CGRectGetWidth(frame), 
                                                                CGRectGetHeight(frame) - titleSectionBtn.height)];
    scrollView.showsHorizontalScrollIndicator = NO;
	scrollView.showsVerticalScrollIndicator = YES;
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    scrollView.backgroundColor = [UIColor clearColor];
	scrollView.scrollsToTop = NO;
	[self addSubview:scrollView];
    [scrollView release];
    
    contentLabel = [[UILabel alloc] init];
    [contentLabel setLineBreakMode:UILineBreakModeTailTruncation];
    [contentLabel setFont:[UIFont systemFontOfSize:CONTENT_FONT_SIZE]];
    [contentLabel setBackgroundColor:[UIColor clearColor]];
    [contentLabel setTextColor:[[[UIColor alloc] initWithString:strColor] autorelease]];
    [scrollView addSubview:contentLabel];
    [contentLabel release];
}

-(BOOL) isShown {
    return self.frame.origin.y == ABSTRACT_VIEW_EXPAND_ORIGIN_Y;
}

-(void)saveAbstractStatus {
    BOOL isExpand = self.frame.origin.y == ABSTRACT_VIEW_EXPAND_ORIGIN_Y;
    [[NSUserDefaults standardUserDefaults] setBool:isExpand forKey:kAbstractStatusKey];
    SNDebugLog(@"kAbstractStatusKey %d", isExpand);
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)animationStoped {
    isMoving = NO;
    lastOrigin = self.frame.origin;
    [self saveAbstractStatus];
}

-(void)animationAbstractView {
    if (isMoving || YES) {
        return;
    }
    isMoving = YES;
    [UIView beginAnimations:@"animationAbstractView" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationStoped)];
	[UIView setAnimationDuration:0.3];
    if ([self isShown]) {
        self.origin = CGPointMake(0, ABSTRACT_VIEW_ORIGIN_Y);
        //[arrowImageView setTransform:CGAffineTransformIdentity];
        [arrowImageView.layer setTransform:CATransform3DMakeRotation(M_PI, 1.0f, 0.0f, 0.0f)];
    } else {
        self.origin = CGPointMake(0, ABSTRACT_VIEW_EXPAND_ORIGIN_Y);
        //[arrowImageView setTransform:CGAffineTransformMakeRotation(M_PI)];
        [arrowImageView.layer setTransform:CATransform3DTranslate(CATransform3DIdentity,0,0,0)];
    }
	[UIView commitAnimations];
}

- (id)init
{
    BOOL isExpand = [[NSUserDefaults standardUserDefaults] boolForKey:kAbstractStatusKey];
    isExpand = YES;
    
    CGRect frame = CGRectMake(0, isExpand ? ABSTRACT_VIEW_EXPAND_ORIGIN_Y : ABSTRACT_VIEW_ORIGIN_Y, TTScreenBounds().size.width, ABSTRACT_VIEW_HEIGHT);
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self createView:frame];
        lastOrigin = frame.origin;
    }
    return self;
}

-(void)setPhoto:(SNPhoto *)aPhoto {
    if (!aPhoto || photo == aPhoto) {
        return;
    }
    
    if (photo) {
        TT_RELEASE_SAFELY(photo);
    }
    photo = [aPhoto retain];
    
    titleLabel.text = self.photo.caption;
    SNPhotoSlideshow *photoSource = (SNPhotoSlideshow *)self.photo.photoSource;
    int index = self.photo.index+1;
//    if ([photoSource hasPrevMoreRecommends] || [photoSource hasLastPhotoOfPrevGroup]) {
//        index = self.photo.index;
//    }
    indexLabel.text = [NSString stringWithFormat:@"%d/%d", index, photoSource.photos.count];
    indexLabel.bottom = titleLabel.bottom - 2;
    
    contentLabel.text = [SNUtility stringTrimming:self.photo.info];
    if ([contentLabel.text length] > 0) {
        CGSize maximumSize = CGSizeMake(scrollView.frame.size.width-20, CGFLOAT_MAX);
        CGSize changeSize = [contentLabel.text sizeWithFont:[UIFont systemFontOfSize:CONTENT_FONT_SIZE]
                                          constrainedToSize:maximumSize 
                                              lineBreakMode:UILineBreakModeTailTruncation];
        contentLabel.frame = CGRectMake(10, 0, changeSize.width, changeSize.height);
        
        CGSize textSize = [contentLabel.text sizeWithFont:[UIFont systemFontOfSize:CONTENT_FONT_SIZE]];
        int lines = ((int)changeSize.height%(int)textSize.height == 0) ? changeSize.height/textSize.height : changeSize.height/textSize.height+1;
        [contentLabel setNumberOfLines:lines];
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, changeSize.height);
    }
    else {
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, 0);
    }
    
    scrollView.scrollsToTop = NO;
    [scrollView setContentOffset:CGPointZero animated:NO];
    if (scrollView.contentSize.height > scrollView.height) {
        [scrollView flashScrollIndicators];
    }
//    arrowImageView.alpha = 1;
    
}

-(void)dealloc {
    TT_RELEASE_SAFELY(photo);
    [super dealloc];
}

@end
