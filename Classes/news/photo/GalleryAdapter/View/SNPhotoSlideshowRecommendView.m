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
#import "SNBusinessStatisticsManager.h"
#import "SNVideoAdContext.h"

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
#import "SNPhotoSlideCell.h"

@interface SNPhotoSlideshowRecommendView ()

@end


@implementation SNPhotoSlideshowRecommendView

@synthesize moreRecommends, recommendDelegate = _recommendDelegate, hasNextGroup;

- (NSMutableDictionary *)privateMemoryCache{
    static NSMutableDictionary * privateCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        privateCache = [[NSMutableDictionary alloc] init];
    });
    return privateCache;
}

- (CGFloat)recommendIconLeftMargin
{
    return kRecommendLeftMarginWithNextArrow; // 不管有没有下一组图，布局都保持一致 modified by jojo on 2012-11-23
//    return ([_recommendDelegate photoHasNext] || self.isRecommendOfLastGroup) ? kRecommendLeftMarginWithNextArrow : kRecommendIconLeftMargin;
}

- (id)initWithRecommends:(NSArray *)recommends
                delegate:(id<SNPhotoSlideshowRecommendViewDelegate>)delegate
            hasNextGroup:(BOOL)ishasNextGroup
           adDataCarrier:(SNAdDataCarrier *)ad12238
                 ad13371:(SNAdDataCarrier *)ad13371
{
    if (self=[super initWithFrame:TTScreenBounds()]) {
        self.moreRecommends = recommends;
        _recommendDelegate = delegate;
        self.hasNextGroup = ishasNextGroup;
        self.ad12238 = ad12238;
        self.ad13371 = ad13371;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([self recommendIconLeftMargin], 
                                                                   kRecommendLabelTop + kSystemBarHeight,
                                                                   kRecommendLabelWidth, 
                                                                   kRecommendLabelHeight)];
        [self addSubview:label];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = NSLocalizedString(@"Recommend Photos", nil);
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15];
        _imageViews = [[NSMutableArray alloc] init];
        
        if (self.hasNextGroup) {
            _arrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 10/2 - 34/2 * 2, TTApplicationFrame().size.height/2, 34/2, 34/2)];
            _arrow.image = [UIImage imageNamed:@"next_slideshow_arrow.png"];
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
        [backButton addTarget:delegate action:@selector(closeGalleryBroswer) forControlEvents:UIControlEventTouchUpInside];

        [backButton setBackgroundColor:[UIColor clearColor]];
        
        backButton.frame =CGRectMake(0, kAppScreenHeight - backImage.size.height, backImage.size.width, backImage.size.height);
//        [self addSubview:backButton];
	}
    
	return self;
}

- (int)recommendCount
{
    return [UIScreen mainScreen].bounds.size.height > 480 ? 8 : 6;
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

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1);
    
    CGFloat left = 0;
    CGFloat top = kRecommendLabelTop + kSystemBarHeight;
    
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

- (CGRect)getRecommendRect:(NSInteger)index
{
    CGFloat width = kRecommendIconWidth;
    CGFloat height = kRecommendIconHeight;
    UIDevicePlatform t = [[UIDevice currentDevice] platformTypeForSohuNews];
    if (t == UIDevice6iPhone || t == UIDevice6PlusiPhone || t == UIDevice7iPhone || t == UIDevice7PlusiPhone || t == UIDevice8iPhone || t == UIDevice8PlusiPhone ||t == UIDeviceiPhoneX)
    {
        CGFloat w_rate = kRecommendIconWidth / 320.0;
        CGFloat h_rate = kRecommendIconHeight / 480.0;
        width = w_rate * kAppScreenWidth;
        height = h_rate * (kAppScreenHeight - kRecommendIconTopMargin - 44);
    }
    
    CGFloat top = index / 2 * (height + kRecommendTitleHeight + [self recommendTitleTopMargin] + [self recommendTitleBottomMargin]) + kRecommendIconTopMargin - 33;
    
    CGFloat left = index % 2 * (width + kRecommendIconMiddleMargin) + [self recommendIconLeftMargin] - 2 * kRecommendIconBorderWidth;
    
    if (t == UIDevice6iPhone || t == UIDevice6PlusiPhone || t == UIDevice7iPhone || t == UIDevice7PlusiPhone || t == UIDevice8iPhone || t == UIDevice8PlusiPhone ||t == UIDeviceiPhoneX)
    {
        left += 10;
    }

    return CGRectMake(left, top + kSystemBarHeight, width, height + [self recommendTitleTopMargin] +  kRecommendTitleHeight+2);
}

- (void)createAd:(NSInteger)index adData:(SNAdDataCarrier *)adData
{
    CGRect frame = [self getRecommendRect:index];
    
    SNPhotoSlideCell *cell = [[SNPhotoSlideCell alloc] initWithFrame:frame];
    
    SNWebImageView *imgView = [[SNWebImageView alloc] initWithFrame: CGRectMake(1, 1, cell.adView.frame.size.width - 2, cell.adView.frame.size.height - 2)];
    imgView.showFade = NO;
    [cell.adView addSubview:imgView];
    
    if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually)
    {
        [imgView loadUrlPath:[adData.adImageUrl trim]];
    }
    else
    {
        UIImage* image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[adData.adImageUrl trim]];
        if (image) {
            imgView.image = image;
        } else {
            imgView.image = [UIImage imageNamed:@"timeline_click_default.png"];
        }
    }

//    [cell.adView addSubview:adData.adWrapperView];
    
    [adData.adWrapperView setUserInteractionEnabled:NO];//会和tap手势冲突，所以设置为NO
    cell.adTitle.text = [adData adTitle];
    CGSize titleSize = [@"限制七中文宽度" textSizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    cell.adTitle.width = titleSize.width;
    cell.adTitle.numberOfLines = 1;

    NSString *iconText = [adData.filter objectForKey:@"iconText"];
    NSString *dsp_source = [adData.adInfoDic objectForKey:@"dsp_source"];
    if ((iconText && iconText.length > 0) || (dsp_source && dsp_source.length > 0)) {
        cell.adLabel.hidden = NO;
        cell.adLabel.text = [NSString stringWithFormat:@"%@%@", dsp_source ? : @"", iconText ? : @""];
        CGSize titleSize = [cell.adLabel.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeA]];
        cell.adLabel.width = titleSize.width + 8;
        cell.adLabel.right = cell.adView.frame.size.width-1;
    }
    
    cell.userData = adData;
    
    cell.clickBLock = ^(SNPhotoSlideCell *cell)
    {
        [self adViewDidTap:(SNAdDataCarrier *)cell.userData];
    };
    
    [self addSubview:cell];
}

- (void)createRecommend:(RecommendGallery *)recommend index:(NSInteger)index
{
    SNPhotoSlideCell *cell = [[SNPhotoSlideCell alloc] initWithFrame:[self getRecommendRect:index]];
    
    cell.adTitle.text = recommend.title;
    cell.userData = recommend;
    
    cell.clickBLock = ^(SNPhotoSlideCell *clickedCell) {
        [self tapRecommendImage:clickedCell];
    };
    
    SNWebImageView *imgView = [[SNWebImageView alloc] initWithFrame: CGRectMake(0, 0, cell.adView.frame.size.width, cell.adView.frame.size.height)];
    imgView.showFade = NO;
    [cell.adView addSubview:imgView];
    
    if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually)
    {
        UIImage* image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[recommend.iconUrl trim]];
        if (image) {
            imgView.image = image;
        }else{
            imgView.defaultImage = [UIImage imageNamed:@"timeline_default.png"];
//            [imgView loadUrlPath:[recommend.iconUrl trim]];
            [imgView setUrlPath:[recommend.iconUrl trim]];
        }
    }
    else
    {
        UIImage* image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[recommend.iconUrl trim]];
        if (image) {
            imgView.image = image;
        } else {
            imgView.image = [UIImage imageNamed:@"timeline_click_default.png"];
        }
    }
    
    [self addSubview:cell];
}

- (void)tapRecommendImage:(SNPhotoSlideCell *)cell
{
    if (nil == cell) {
        return ;
    }
    
    RecommendGallery *recommend = (RecommendGallery *)cell.userData;
    
    if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually)
    {
        for (SNWebImageView *img in _imageViews)
        {
            [img sd_cancelCurrentImageLoad];
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
            SNWebImageView *imgView = cell.adView.subviews.firstObject;
            imgView.showFade = NO;
            imgView.defaultImage = [UIImage imageNamed:@"timeline_click_default.png"];
            [imgView loadUrlPath:[recommend.iconUrl trim]];
        }
    }
}

- (void)loadImageWithAdDataCarrier:(SNAdDataCarrier *)adDataCarrier ad13371:(SNAdDataCarrier *)ad13371
{
    // 删除所有老的，重新创建，以免字体重叠
    for (NSInteger i = self.subviews.count; i >= 0; i--) {
        UIView *view = [self.subviews lastObject];
        
        if (nil != view && [view isKindOfClass:[SNPhotoSlideCell class]]) {
            [view removeFromSuperview];
        }
    }
    if (adDataCarrier && adDataCarrier.dataState == SNAdDataStateReady) {
        self.ad12238 = adDataCarrier;
    }else if(adDataCarrier.dataState == SNAdDataStatePending){
    }
    
    if (ad13371 && ad13371.dataState == SNAdDataStateReady) {
        self.ad13371 = ad13371;
    }else if(ad13371.dataState == SNAdDataStatePending){

    }
    
    NSMutableArray *adArray = [[NSMutableArray alloc] init];

    if (nil != self.ad13371 && self.ad13371.dataState == SNAdDataStateReady)
    {
        [adArray addObject:self.ad13371];
    }
    
    if (nil != self.ad12238 && self.ad12238.dataState == SNAdDataStateReady)
    {
        [adArray addObject:self.ad12238];
    }

    // 实际数量
    NSInteger recommendDisplayCount = MIN(self.moreRecommends.count, [self recommendCount]);
    for (NSInteger i = 0; i < recommendDisplayCount; i++)
    {
        
        if (i == recommendDisplayCount - 2) {// ad 12716
            if (self.ad13371) {
                [self createAd:i adData:self.ad13371];
            }else {
                [self createRecommend:self.moreRecommends[i] index:i];
            }
        }
        
        if (i == recommendDisplayCount - 1) {
            if (self.ad12238) {
                [self createAd:i adData:self.ad12238];
            }else {
                [self createRecommend:self.moreRecommends[i] index:i];
            }
        }
        
        if (i < recommendDisplayCount - 2)
        {
            [self createRecommend:self.moreRecommends[i] index:i];
        }
//        else
//        {
//            [self createAd:i adData:adArray[adArray.count - (recommendDisplayCount - i)]];
//        }

    }
}

#pragma mark - 
#pragma mark -  SNDatabaseRequestDelegate
- (void)dealloc
{
    _recommendDelegate = nil;
   
    self.ad12238.adViewTapDelegate = nil;
    _ad12238.delegate = nil;

    _ad13371.delegate = nil;
    self.ad13371.adViewTapDelegate = nil;
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showStatus:(NSString*)text {
    //do nothing, don't show
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showProgress:(CGFloat)progress {
    //do nothing, don't show
}

#pragma mark - statistics
- (void)reportBusinessStatisticsInfo
{
    NSMutableArray *appAdIDArray = [NSMutableArray array];
    for (RecommendGallery *recommend in self.moreRecommends) {
        [appAdIDArray addObject:recommend.newsId];
    }
    
    SNBusinessStatInfo *statInfo = [[SNBusinessStatInfo alloc] init];
    statInfo.statType = SNStatisticsEventTypeShow;
    statInfo.objIDArray = appAdIDArray;
    statInfo.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForExpsGif];
    statInfo.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];
    statInfo.objType = SNBusinessStatisticsObjTypeGalleryRecommend;
    [[SNBusinessStatisticsManager shareInstance] updateStatisticsInfo:statInfo];
    
}
- (void)reportAdDisplay {
    [self.ad12238 reportForDisplayTrack];
    [self.ad13371 reportForDisplayTrack];
}
#pragma mark - SNAdDataCarrier tap action

- (void)adViewDidTap:(SNAdDataCarrier *)carrier {
    NSString *clickUrl = [carrier adClickUrl];
    if (clickUrl.length > 0) {
        if ([SNUtility openProtocolUrl:clickUrl context:nil]) {
            carrier.newsID = self.newsId;
            [carrier reportForClickTrack];
        }
    }
}

@end
