//
//  SNSubCenterTopAdView.m
//  sohunews
//
//  Created by wang yanchen on 12-11-27.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNSubCenterTopAdView.h"
#import "SNSubscribeCenterService.h"
#import "UIColor+ColorUtils.h"
#import "CacheObjects.h"
#import "SNWebImageView.h"
#import "SNAdDataCarrier.h"
#import "SNNewsExposureManager.h"
#import "SNStatisticsManager.h"

#define kAdBtnSideMargin                    (20 / 2)
#define kAdBtnSpace                         (22 / 2)
#define kAdCarrierStartTag                  1000
#define kAdCmsStartTag                      2000

@class SNSubCenterAdViewBtn;
@protocol SNSubCenterAdViewBtnDelegate <NSObject>

@optional
- (void)adViewTapped:(SNSubCenterAdViewBtn *)btnView;

@end

@interface SNSubCenterAdViewBtn : SNWebImageView {
    SCSubscribeAdObject *_adObj;
    id _adViewDelegate;
}

@property(nonatomic, strong) SCSubscribeAdObject *adObj;

- (id)initWithDelegate:(id)adViewDelegate;

@end

@interface SNSubCenterTopAdView ()

@property (nonatomic, strong) NSMutableDictionary * originAdList;

@end

@implementation SNSubCenterAdViewBtn
@synthesize adObj = _adObj;

- (id)initWithDelegate:(id)adViewDelegate {
    self = [super init];
    if (self) {
        _adViewDelegate = adViewDelegate;
//        self.defaultImage = [UIImage themeImageNamed:@"defaulticon.png"];
        self.userInteractionEnabled = YES;
//        self.layer.cornerRadius = 5.0;
        self.clipsToBounds = YES;
        
        if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
            self.alpha = 0.5;
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapped {
    if ([_adViewDelegate respondsToSelector:@selector(adViewTapped:)]) {
        [_adViewDelegate adViewTapped:self];
    }
}

- (void)setAdObj:(SCSubscribeAdObject *)adObj {
    if (_adObj != adObj) {
         //(_adObj);
        _adObj = adObj;
    }
    
    if (_adObj) {
        NSString *info = [NSString stringWithFormat:@"关注中心推广栏目：%@", _adObj.refText];
        [self setIsAccessibilityElement:YES];
        [self setAccessibilityLabel:info];
    }
    
    if ([_adObj.adImage length] > 0) {
        [self loadUrlPath:_adObj.adImage];
    }
}

- (void)dealloc {
    _adViewDelegate = nil;
     //(_adObj);
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation SNSubCenterTopAdView
@synthesize adListArray = _adListArray;
@synthesize adDataCarriers = _adDataCarriers;

- (void)initAdViews {
    //订阅广场广告改为每屏显示一个
    NSInteger pageNum = _adListArray.count;
    int index = 0;
    for (id adItem in _adListArray) {
        if ([adItem isKindOfClass:[SCSubscribeAdObject class]]) {
            SCSubscribeAdObject *subscribeAdObj = (SCSubscribeAdObject *)adItem;
            SNSubCenterAdViewBtn *btnView = [[SNSubCenterAdViewBtn alloc] initWithDelegate:self];
            btnView.frame = CGRectMake(index, 0,
                                       kAppScreenWidth, kSNSubCenterTopAdView_Height);
//            btnView.alpha = themeImageAlphaValue();
            if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
                btnView.alpha = 0.5;
            }
            btnView.tag = kAdCmsStartTag + index;
            [_scrollView addSubview:btnView];
            btnView.adObj = subscribeAdObj;
            
            if (index == 0) {
                [self reportPopularizeDisplay:subscribeAdObj];
            }
            index++;
        }
    }
    
    if (pageNum > 0) {
        _scrollView.contentSize = CGSizeMake(self.width * pageNum, self.height);
        _pageControl.numberOfPages = pageNum;
        _pageNum = pageNum;
    }
}

//曝光统计
- (void)recordExposureAd
{
    NSMutableDictionary *exposureDic = [NSMutableDictionary dictionary];
    NSInteger adCount = (_pageControl.currentPage + 1) * 2;
    NSInteger beginIndex = _pageControl.currentPage * 2;
    
    if (_adListArray.count > 0) {
        if (adCount <= _adListArray.count) {
            for (NSInteger i = beginIndex; i < adCount; i++) {
                SCSubscribeAdObject *adObject = [_adListArray objectAtIndex:i];
                NSString *link = adObject.refLink;
                if (link.length > 0) {
                    link = [link stringByAppendingString:@"&exposureFrom=5"];
                    if (adObject.ID > 0) {
                        [exposureDic setObject:link forKey:[NSString stringWithFormat:@"%ld",(long)adObject.ID]];
                    }
                }
            }
        }
    }
    
    if (_adDataCarriers.count > 0) {
        if (adCount <= _adDataCarriers.count) {
            for (NSInteger i = beginIndex; i < adCount; i++) {
                SNAdDataCarrier *adCarrier = [_adDataCarriers objectAtIndex:i];
                NSString *link = [adCarrier adClickUrl];
                if (link.length > 0) {
                    link = [link stringByAppendingString:@"&exposureFrom=5"];
                    if (adCarrier.adSpaceId.length > 0) {
                        [exposureDic setObject:link forKey:[NSString stringWithFormat:@"%@",adCarrier.adSpaceId]];
                    }
                }
            }
        }
    }
    
    [[SNNewsExposureManager sharedInstance] exposureNewsInfoWithDic:exposureDic];
}

- (void)appendDataCarrierView:(SNAdDataCarrier *)adDataCarrier {
    //订阅广场广告改为每屏显示一个
    adDataCarrier.adViewTapDelegate = self;
    UIView *adView = adDataCarrier.adWrapperView;
    adView.frame = CGRectMake(kAppScreenWidth * _pageNum, 0,
                              kAppScreenWidth, kSNSubCenterTopAdView_Height);
//    adView.clipsToBounds = YES;
//    adView.layer.cornerRadius = 5.0;
    adView.tag = kAdCarrierStartTag + _pageNum;
    [_scrollView addSubview:adView];
    
    if (_pageNum == 0) {
        [adDataCarrier reportForDisplayTrack];
    }
    
    if (_pageNum > 0) {
        _scrollView.contentSize = CGSizeMake(self.width * (_pageNum + 1), self.height);
        _pageControl.numberOfPages = _pageNum + 1;
    }
    _pageNum++;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
//        _scrollView.alpha = themeImageAlphaValue();
        if ([[[SNThemeManager sharedThemeManager] currentTheme] isEqualToString:kThemeNight]) {
            _scrollView.alpha = 0.5;
        }
        [self addSubview:_scrollView];
        
        _pageControl = [[SNPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 14,
                                                                        self.width, 10)];
        _pageControl.dotColorCurrentPage = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubCenterDetailAdDotSelectColor]];
        _pageControl.dotColorOtherPage = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kSubCenterDetailAdDotOtherColor]];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.dotsAlignment = NSTextAlignmentCenter;
        _pageControl.alpha = themeImageAlphaValue();
        [self addSubview:_pageControl];
        
        UIImage *sepLineImage = [UIImage themeImageNamed:@"subcenter_allsub_ad_sep_line.png"];
        _bottomSepLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, sepLineImage.size.height)];
        _bottomSepLine.contentMode = UIViewContentModeScaleToFill;
        _bottomSepLine.image = sepLineImage;
        [self addSubview:_bottomSepLine];
        
        _pageNum = 0;
        self.adDataCarriers = [NSMutableArray array];
    }
    return self;
}

- (void)setAdListArray:(NSArray *)adListArray {
    if (!adListArray) {
        return;
    }
    
    if (_adListArray != adListArray) {
         //(_adListArray);
        _adListArray = adListArray;
    }
    
    [self initAdViews];
    [self recordExposureAd];
    self.alpha = themeImageAlphaValue();
}

- (void)appendAdDataCarriers:(SNAdDataCarrier *)adDataCarrier  {
    if (![_adDataCarriers containsObject:adDataCarrier]) {
        [_adDataCarriers addObject:adDataCarrier];
    }
//    if (!self.originAdList) {
//        self.originAdList = [NSMutableDictionary dictionary];
//    }
//    [self.originAdList setObject:adDataCarrier forKey:adDataCarrier.adSpaceId];
//    
//    if (self.originAdList.count == 4) {
//        NSArray * adlist = [self sortAdWithAdList:self.originAdList];
//        for (SNAdDataCarrier * adCarrier in adlist) {
//            [self appendDataCarrierView:adCarrier];
//        }
//    }else {
        [self appendDataCarrierView:adDataCarrier];
//    }
}

- (NSMutableArray *)sortAdWithAdList:(NSDictionary *)list{
    NSMutableArray * adArray = [NSMutableArray array];
    if (list[@"12228"]) {
        [adArray addObject:list[@"12228"]];
    }
    if (list[@"12229"]) {
        [adArray addObject:list[@"12229"]];
    }
    if (list[@"12230"]) {
        [adArray addObject:list[@"12230"]];
    }
    if (list[@"12231"]) {
        [adArray addObject:list[@"12231"]];
    }
    return adArray;
}

- (void)reportAdExporeData
{
    NSInteger currentIndex = _pageControl.currentPage;
    if (self.adDataCarriers.count > 0 && currentIndex <= self.adDataCarriers.count) {
        SNAdDataCarrier *adDataCarrier = [self.adDataCarriers objectAtIndex:currentIndex];
        [adDataCarrier reportForDisplayTrack];
    }
    else if(self.adListArray && currentIndex <= self.adListArray.count) {
        SCSubscribeAdObject *subscribeAdObj = [self.adListArray objectAtIndex:currentIndex];
        [self reportPopularizeDisplay:subscribeAdObj];
    }
}

- (void)dealloc {
     //(_adListArray);
     //(_scrollView);
     //(_bottomSepLine);
}

#pragma mark - UIScrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int pageIndex = scrollView.contentOffset.x / scrollView.width;
    _pageControl.currentPage = pageIndex;
    //订阅顶部位置统计
    [self recordExposureAd];
    //订阅广告位展示统计
    [self reportAdExporeData];
}

#pragma mark - SNSubCenterAdViewBtnDelegate
- (void)adViewTapped:(SNSubCenterAdViewBtn *)btnView {
    SCSubscribeAdObject *adObj = btnView.adObj;
    [SNSubscribeCenterService handleAdOpenRequest:adObj];
}

#pragma mark - SNAdDataCarrierActionDelegate
- (void)adViewDidTap:(SNAdDataCarrier *)carrier {
    NSString *clickUrl = [carrier adClickUrl];
    if (clickUrl) {
        [SNUtility openProtocolUrl:clickUrl context:nil];
    }
//    [carrier reportForClickTrack];
}

#pragma mark - Statistics
- (void)reportPopularizeDisplay:(SCSubscribeAdObject *)subscribeAdObj {
    
    if (subscribeAdObj.isReportStatistics) {
        return;
    }
    subscribeAdObj.isReportStatistics = YES;
    
    SNStatExposureInfo *info = [[SNStatExposureInfo alloc] init];
    [self updateInfoWithData:info subAdObj:subscribeAdObj];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    
    info = nil;
}

- (void)reportPopularizeClick:(SCSubscribeAdObject *)subscribeAdObj {
    SNStatClickInfo *info = [[SNStatClickInfo alloc] init];
    [self updateInfoWithData:info subAdObj:subscribeAdObj];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    
    info = nil;
}

- (void)reportPopularizeLoad:(SCSubscribeAdObject *)subscribeAdObj {
    SNStatLoadInfo *info = [[SNStatLoadInfo alloc] init];
    [self updateInfoWithData:info subAdObj:subscribeAdObj];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    
    info = nil;
}

- (void)updateInfoWithData:(SNStatInfo *)info subAdObj:(SCSubscribeAdObject *)subscribeAdObj
{
    if (subscribeAdObj.adId.length > 0) {
        info.adIDArray = @[subscribeAdObj.adId];
    }
    info.objType = kObjTypeOfRecommendPosionInMySubBanner;
    info.objLabel = SNStatInfoUseTypeOutTimelinePopularize;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
    if (![info.objFrom isEqualToString:@"subscribe"]) {
        info.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];
    }
}

- (void)updateTheme {
    int index;
    for (index = 0; index < _pageNum; index++) {
        SNSubCenterAdViewBtn *btnView = (SNSubCenterAdViewBtn *)[self viewWithTag:kAdCmsStartTag + index];
        btnView.alpha = themeImageAlphaValue();
    }
    for (index = 0; index <_pageNum; index++) {
        UIView *adView = [self viewWithTag:kAdCarrierStartTag + index];
        adView.alpha = themeImageAlphaValue();
    }
    _scrollView.alpha = themeImageAlphaValue();
    _pageControl.alpha = themeImageAlphaValue();
}

@end
