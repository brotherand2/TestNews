//
//  SNPhotoSlideshowRecommendView.m
//  sohunews
//
//  Created by Dan on 12/31/11.
//  Copyright (c) 2011 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoSlideshowRecommendView.h"
#import "SNDBManager.h"
#import "NSString+Utilities.h"
#import "SNWebImageView.h"
#import "UIControl+Blocks.h"

#define kRecommendIconWidth         228/2
#define kRecommendIconHeight        148/2

#define kRecommendLeftMarginWithNextArrow 26/2 
#define kRecommendIconLeftMargin    82/2
#define kRecommendIconMiddleMargin  22/2

#define kRecommendIconTopMargin     146/2
#define kRecommendTitleHeight       56/2
#define kRecommendTitleTopMargin    14/2
#define kRecommendTitleBottomMargin    40/2

#define kRecommendLabelTop          0
#define kRecommendLabelHeight       25
#define kRecommendLabelWidth        90
#define kRecommendLabelLeft         115

#define kRecommednCountLimit        6

#define kRecommendIconBorderWidth   1
#define kRecommendWidth             (TTApplicationFrame().size.height/2)

#define kJumpAnimationDuration      0.5

#import <QuartzCore/QuartzCore.h>


@implementation SNPhotoSlideshowRecommendView
@synthesize sdkAdRecommend = _sdkAdRecommend;

@synthesize moreRecommends, recommendDelegate = _recommendDelegate, hasNextGroup;

- (CGFloat)recommendIconLeftMargin
{
    return kRecommendLeftMarginWithNextArrow; // 不管有没有下一组图，布局都保持一致 modified by jojo on 2012-11-23
//    return ([_recommendDelegate photoHasNext] || self.isRecommendOfLastGroup) ? kRecommendLeftMarginWithNextArrow : kRecommendIconLeftMargin;
}

- (id)initWithRecommends:(NSArray *)recommends
                delegate:(id<SNPhotoSlideshowRecommendViewDelegate>)delegate
            hasNextGroup:(BOOL)ishasNextGroup
           adDataCarrier:(SNAdDataCarrier *)adDataCarrier
{
    if (self=[super initWithFrame:TTScreenBounds()]) {
        self.moreRecommends = recommends;
        _recommendDelegate = delegate;
        self.hasNextGroup = ishasNextGroup;
        self.sdkAdRecommend = adDataCarrier;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([self recommendIconLeftMargin], 
                                                                   kRecommendLabelTop + kSystemBarHeight,
                                                                   kRecommendLabelWidth, 
                                                                   kRecommendLabelHeight)];
        [self addSubview:label];
        [label release];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentLeft;
        label.text = NSLocalizedString(@"Recommend Photos", nil);
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15];
        
        _imageViews = [[NSMutableArray alloc] init];
        
        if (self.hasNextGroup) {
            _arrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 10/2 - 34/2 * 2, TTApplicationFrame().size.height/2, 34/2, 34/2)];
            _arrow.image = [[UIImage imageNamed:@"next_slideshow_arrow.png"] scaledImage];
            [self addSubview:_arrow];
            
            //jump
            CABasicAnimation *slideAnim = [CABasicAnimation animationWithKeyPath:@"position.x"];
            [slideAnim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            slideAnim.fromValue = [NSNumber numberWithFloat:self.width - 10/2 - 34/2];
            slideAnim.toValue = [NSNumber numberWithFloat:self.width - 10/2];
            
            slideAnim.repeatCount = HUGE_VALF;
            slideAnim.autoreverses = YES;
            slideAnim.duration = 1.0f;
            [_arrow.layer addAnimation:slideAnim forKey:@"slideAnim"];
        }
        
        UIButton *backButton = [[UIButton alloc] init];
        UIImage *backImage = [UIImage imageNamed:@"photo_slideshow_back.png"];
        [backButton setImage:backImage forState:UIControlStateNormal];
        [backButton addTarget:delegate action:@selector(closeSNGroupPicturesSlideshowContainerViewController) forControlEvents:UIControlEventTouchUpInside];
        [backButton setBackgroundColor:[UIColor clearColor]];
        
        backButton.frame =CGRectMake(0, kAppScreenHeight - backImage.size.height, backImage.size.width, backImage.size.height);
        [self addSubview:backButton];
        [backButton release];
	}
    
	return self;
}

- (int)recommendCount
{
    switch ((int)TTApplicationFrame().size.height) {
        case 548:
            return 8;
        case 568:
            return 8;
        case 460:
            return kRecommednCountLimit;
    }
    
    return kRecommednCountLimit;
}

- (int)recommendTitleTopMargin
{
    switch ((int)TTApplicationFrame().size.height) {
        case 548:
            return 8;
        case 568:
            return 8;
        case 460:
            return kRecommendTitleTopMargin;
    }
    
    return kRecommendTitleTopMargin;
}

- (int)recommendTitleBottomMargin
{
    switch ((int)TTApplicationFrame().size.height) {
        case 548:
            return kRecommendTitleTopMargin;
        case 568:
            return kRecommendTitleTopMargin;
        case 460:
            return kRecommendTitleBottomMargin;
    }
    
    return kRecommendTitleBottomMargin;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //画直线
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1);
    
    CGFloat left = [self recommendIconLeftMargin] - 2 * kRecommendIconBorderWidth;
    CGFloat top = kRecommendLabelTop + kSystemBarHeight;
    left = 0;

//    CGContextMoveToPoint(context, left, top);
//    CGContextAddLineToPoint(context, left + kRecommendWidth, top);
    
    CGContextMoveToPoint(context, left, top + kRecommendLabelHeight + 7);
    left += 71 / 2;
    CGContextAddLineToPoint(context, left, top + kRecommendLabelHeight + 7);
    left += 30 / 4;
    CGContextAddLineToPoint(context, left, top + kRecommendLabelHeight);
    left += 30 / 4;
    CGContextAddLineToPoint(context, left, top + kRecommendLabelHeight + 7);
    
    CGContextAddLineToPoint(context, self.width, top + kRecommendLabelHeight + 7);
    
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    CGContextStrokePath(context);

}

- (void)loadImageWithAdDataCarrier:(SNAdDataCarrier *)adDataCarrier
{
    self.sdkAdRecommend = adDataCarrier;
    int i = 0;
    for (RecommendGallery *recommend in self.moreRecommends)
    {
        if (i > [self recommendCount] - 1)
        {
            break;
        }
        
        SNWebImageView *imgView = (SNWebImageView *)[self viewWithTag:[recommend.newsId intValue]];
        if (nil == imgView)
        {
            CGFloat top = i / 2 * (kRecommendIconHeight + kRecommendTitleHeight + [self recommendTitleTopMargin] + [self recommendTitleBottomMargin]) + kRecommendIconTopMargin - 33;
            CGFloat left = i % 2 * (kRecommendIconWidth + kRecommendIconMiddleMargin) + [self recommendIconLeftMargin] - 2 * kRecommendIconBorderWidth;
            
            imgView = [[SNWebImageView alloc] initWithFrame: CGRectMake(left, top + kSystemBarHeight, kRecommendIconWidth, kRecommendIconHeight)];
            imgView.layer.borderWidth = kRecommendIconBorderWidth;
            imgView.layer.borderColor = [UIColor whiteColor].CGColor;
            imgView.backgroundColor = [UIColor grayColor];
            imgView.contentMode = UIViewContentModeScaleToFill;
            imgView.clipsToBounds = YES;
            if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually)
            {
                [imgView loadUrlPath:[recommend.iconUrl trim]];
            }
            else
            {
                UIImage* image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[recommend.iconUrl trim]];
                if (image) {
                    imgView.image = image;
                } else {
                    imgView.image = [[UIImage imageNamed:@"photo_recommend_click_default.png"] scaledImage];
                }
            }
            [self addSubview:imgView];
            [_imageViews addObject:imgView];

            [imgView release];
            
            imgView.tag = [recommend.newsId intValue];
            
            BOOL isSdkAdView = NO;
            imgView.hidden = NO;
            
            // 最后一格广告 需要特殊处理一下
            if (i == [self recommendCount] - 1 && self.sdkAdRecommend.dataState == SNAdDataStateReady)
            {
                self.sdkAdRecommend.adWrapperView.frame = imgView.frame;
                [self.sdkAdRecommend.adWrapperView removeFromSuperview];
                if (!self.sdkAdRecommend.adWrapperView.superview) {
                    self.sdkAdRecommend.adWrapperView.layer.borderWidth = kRecommendIconBorderWidth;
                    self.sdkAdRecommend.adWrapperView.layer.borderColor = [UIColor whiteColor].CGColor;
                    self.sdkAdRecommend.adWrapperView.backgroundColor = [UIColor grayColor];
                    [self insertSubview:self.sdkAdRecommend.adWrapperView aboveSubview:imgView];
                    self.sdkAdRecommend.adViewTapDelegate = self;
                }
                
                isSdkAdView = YES;
                imgView.hidden = YES;
            }
            
            UIControl *control = [[UIControl alloc] initWithFrame:imgView.frame];
            control.backgroundColor = [UIColor clearColor];
            __block typeof(&*self) blockSelf = self;
            if (i == [self recommendCount] - 1 && self.sdkAdRecommend.dataState == SNAdDataStateReady)
            {
                [control addActionBlock:^(UIControl *control) {
                     [blockSelf adViewDidTap:self.sdkAdRecommend];
                } forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [control addActionBlock:^(UIControl *control) {
                    if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually)
                    {
                        for (SNWebImageView *img in _imageViews)
                        {
                            [img cancelCurrentImageLoad];
                        }
                        
                        if ([_recommendDelegate respondsToSelector:@selector(photoDidRecommendAtNewsId:)])
                        {
                            [_recommendDelegate photoDidRecommendAtNewsId:recommend.newsId];
                        }
                    }
                    else
                    {
                        UIImage* image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[recommend.iconUrl trim]];
                        if (image)
                        {
                            if ([_recommendDelegate respondsToSelector:@selector(photoDidRecommendAtNewsId:)])
                            {
                                [_recommendDelegate photoDidRecommendAtNewsId:recommend.newsId];
                            }
                        }
                        else
                        {
                            [imgView loadUrlPath:[recommend.iconUrl trim]];
                        }
                    }

                } forControlEvents:UIControlEventTouchUpInside];
            }
            [self addSubview:control];
            
            //title
            top = CGRectGetMaxY(imgView.frame) + [self recommendTitleTopMargin];
            
            UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(left, top, kRecommendIconWidth, kRecommendTitleHeight+2)];
            title.textAlignment = UITextAlignmentLeft;
            title.text = isSdkAdView ? [self.sdkAdRecommend adTitle] : recommend.title;
            title.font = [UIFont systemFontOfSize:13];
            title.textColor = [UIColor whiteColor];
            title.backgroundColor = [UIColor clearColor];
            title.numberOfLines = 2;
            [self addSubview:title];
            [title release];

        }
        
        i++;
    }
}

#pragma mark - 
#pragma mark -  SNDatabaseRequestDelegate
- (void)dealloc
{
    _recommendDelegate = nil;
    TT_RELEASE_SAFELY(_arrow);
    TT_RELEASE_SAFELY(moreRecommends);
    TT_RELEASE_SAFELY(_imageViews);
    
    self.sdkAdRecommend.adViewTapDelegate = nil;
    TT_RELEASE_SAFELY(_sdkAdRecommend);
    
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showStatus:(NSString*)text {
    //do nothing, don't show
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showProgress:(CGFloat)progress {
    //do nothing, don't show
}

#pragma mark - SNAdDataCarrier tap action

- (void)adViewDidTap:(SNAdDataCarrier *)carrier {
    NSString *clickUrl = [carrier adClickUrl];
    if (clickUrl.length > 0) {
        [SNUtility openProtocolUrl:clickUrl context:nil];
    }
    [carrier reportForClickTrack];
}

@end
