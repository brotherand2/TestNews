//
//  SNAdDataCarrier.m
//  sohunews
//
//  Created by jojo on 13-12-9.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNAdDataCarrier.h"
#import "STADManagerForNews.h"
#import "SNADWebImageView.h"
#import "SNStatisticsManager.h"
#import "SNAdStatisticsManager.h"
#import "SNNewsAd+analytics.h"
#import "SNCacheManager.h"
#import "SHADManager.h"

@interface SNAdDataWrapperView : UIView {
    SNADWebImageView *_defaultImageView;
    UIView *_alphaMaskView;
    UILabel *_adLabel;
}

@property (nonatomic, strong) UIView *adView;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL shouldIgnoreNightMode;

- (void)setImagePath:(NSString *)imagePath;

@end

@protocol SNAdDataWrapperViewDelegate <NSObject>

@optional
- (void)adWrapperViewTapped:(SNAdDataWrapperView *)view;

@end

@implementation SNAdDataWrapperView
@synthesize adView = _adView;
@synthesize shouldIgnoreNightMode = _shouldIgnoreNightMode;

- (id)initAdView:(UIView *)adView adDelegate:(id)delegate {
    self = [super initWithFrame:adView.frame];
    if (self) {
        self.adView = adView;
        self.delegate = delegate;
        self.adView.userInteractionEnabled = NO;
        _defaultImageView = [[SNADWebImageView alloc] initWithFrame:self.bounds];
        [_defaultImageView setDefaultImage:[UIImage imageNamed:@"timeline_default.png"]];
        [self addSubview:_defaultImageView];
        
        if ([delegate isKindOfClass:[SNAdDataCarrier class]]) {
            SNAdDataCarrier *adDataCarrier = (SNAdDataCarrier *)delegate;
            //NSString *adText = [adDataCarrier.filter objectForKey:@"iconText"];
            NSString *adSpaceld = adDataCarrier.adSpaceId;
            if ([adSpaceld isEqualToString:@"12233"]) {
                _adLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 18)];
                _adLabel.top = 14 + kSystemBarHeight;
                _adLabel.right = kAppScreenWidth - 14;
                _adLabel.layer.borderColor = [UIColor colorWithRed:255.0/255.0
                                                             green:255.0/255.0
                                                              blue:255.0/255.0
                                                             alpha:0.4].CGColor;
                _adLabel.layer.borderWidth = [[SNDevice sharedInstance] isPlus] ? 1.0/3 : 1.0 / 2;
                _adLabel.layer.cornerRadius =[[SNDevice sharedInstance] isPlus] ? 2.0/3 : 2.0/2;
                _adLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0
                                                           green:0.0/255.0
                                                            blue:0.0/255.0
                                                           alpha:0.05];
                _adLabel.textAlignment = NSTextAlignmentCenter;
                _adLabel.font = [UIFont systemFontOfSize:kThemeFontSizeH];
                _adLabel.textColor = SNUICOLOR(kThemeText5Color);
                _adLabel.hidden = YES;
                [self addSubview:_adLabel];
            }
        }
        
        if (self.adView) {
            self.adView.frame = self.bounds;
            [self addSubview:self.adView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adViewTapped:)];
            [self addGestureRecognizer:tap];
            self.adView.hidden = YES;
        }
        
        _alphaMaskView = [[UIView alloc] initWithFrame:self.bounds];
        _alphaMaskView.backgroundColor = [UIColor blackColor];
        [self addSubview:_alphaMaskView];
        
        _alphaMaskView.alpha = 0;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.adView.frame = self.bounds;
    _defaultImageView.frame = self.bounds;
    _alphaMaskView.frame = self.bounds;
}

- (void)setImagePath:(NSString *)imagePath {
    if (imagePath.length > 0) {
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        if (image) {
            _defaultImageView.image = image;
        }
    }
}

- (void)loadImageUrl:(NSString *)url
           completed:(SNWebImageCompleteBlock)complete {
    if (url.length > 0) {
        [_defaultImageView loadUrlPath:url completed:^(UIImage *image,
                                                       NSError *error,
                                                       SDImageCacheType cacheType) {
            if (nil != complete) {
                complete(image, error, cacheType);
            }
        }];
    }
}

- (void)setImageUrl:(NSString *)imageUrl {
    if (imageUrl.length > 0) {
        [_defaultImageView loadUrlPath:imageUrl];
    }
}

- (void)setAdLabelText:(NSString *)iconText {
    CGSize titleSize = [iconText sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeA]];
    _adLabel.width = titleSize.width + 10;
    _adLabel.right = kAppScreenWidth - 14;
    _adLabel.text = iconText;
    _adLabel.hidden = NO;
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)adViewTapped:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(adWrapperViewTapped:)]) {
        [self.delegate adWrapperViewTapped:self];
    }
}

- (void)setShouldIgnoreNightMode:(BOOL)shouldIgnoreNightMode {
    _shouldIgnoreNightMode = shouldIgnoreNightMode;
    _alphaMaskView.hidden = _shouldIgnoreNightMode ? YES : NO;
}

@end

#pragma mark -
@implementation SNAdDataCarrier
@synthesize dataState;
@synthesize delegate = _delegate;
@synthesize adView = _adView;
@synthesize adInfoDic = _adInfoDic;
@synthesize adSpaceId = _adSpaceId;
@synthesize refreshAdDataHandler = _refreshAdDataHandler;
@synthesize adWrapperView = _adWrapperView;
@synthesize adViewTapDelegate = _adViewTapDelegate;
@synthesize shouldIgnoreNightMode;
@synthesize adInfoObj = _adInfoObj;
@synthesize newsID = _newsID;

- (id)initWithAdSpaceId:(NSString *)adSpaceId {
    self = [super init];
    if (self) {
        self.adSpaceId = adSpaceId;
        _isReportStatistics = NO;
    }
    return self;
}

- (UIView *)refreshAdData:(BOOL)needRender {
    UIView *adView = nil;
    if (self.refreshAdDataHandler) {
        self.dataState = SNAdDataStatePending;
        adView = self.refreshAdDataHandler(self, needRender);
        if (adView) {
            self.adWrapperView = [[SNAdDataWrapperView alloc] initAdView:adView adDelegate:self];
            adView = self.adWrapperView;
        }
    }
    return adView;
}

- (UIView *)adWrapperView {
    if ([_adWrapperView isKindOfClass:[SNAdDataWrapperView class]]) {
        [(SNAdDataWrapperView *)_adWrapperView setShouldIgnoreNightMode:self.shouldIgnoreNightMode];
    }
    return _adWrapperView;
}

- (void)onlySetAdInfo:(NSDictionary *)adInfo {
    _adInfoDic = adInfo;
}

- (void)loadAdImageFromAdInfo:(void(^)(UIImage *image,
                                       NSError *error,
                                       SNAdDataCarrier *adCarrier))complete {
    if (_adWrapperView &&
        [_adWrapperView isKindOfClass:[SNAdDataWrapperView class]]) {
        SNAdDataWrapperView *v = (SNAdDataWrapperView *)_adWrapperView;
        NSString *url = [self adImageUrl];
        
        if (nil == url || url.length == 0) {
            complete(nil, nil, self);
            return;
        }
        
        SNAdDataCarrier *adDataCarrier = (SNAdDataCarrier *)v.delegate;
        NSString *adText = [adDataCarrier.filter objectForKey:@"iconText"];
        NSString *adSpaceld = adDataCarrier.adSpaceId;
        NSString *dsp_source = [adDataCarrier.adInfoDic objectForKey:@"dsp_source"];

        [v loadImageUrl:url completed:^(UIImage *image, NSError *error, SDImageCacheType cache){
            if (nil != complete) {
                complete(image, error, self);
                if ([adSpaceld isEqualToString:@"12233"] &&
                    ((adText && adText.length > 0) ||
                     (dsp_source && dsp_source.length > 0))) {
                    [v setAdLabelText:[NSString stringWithFormat:@"%@%@", dsp_source ? : @"", adText ? : @""]];
                }
            }
        }];
    } else {
        if (nil != complete) {
            complete(nil, nil, self);
        }
    }
}

- (void)setAdInfoDic:(NSDictionary *)adInfoDic {
    _adInfoDic = adInfoDic;
    if (_adWrapperView &&
        [_adWrapperView isKindOfClass:[SNAdDataWrapperView class]]) {
            [(SNAdDataWrapperView *)_adWrapperView setImageUrl:[self adImageUrl]];
    }
}

// 获取adInfoDic数据便利方法
- (NSString *)adId {
    if (_adId.length > 0) {
        return _adId;
    } else {
        return [self.adInfoDic stringValueForKey:@"adid" defaultValue:nil];
    }
}

- (NSString *)adClickUrl {
    return [self.adInfoDic stringValueForKey:@"click_url" defaultValue:nil];
}

- (NSString *)adShareText {
    return [self.adInfoDic stringValueForKey:@"share_txt" defaultValue:nil];
}

- (NSString *)adNonePicTitle {
    return [self.adInfoDic stringValueForKey:@"nopic_txt" defaultValue:nil];
}

- (NSString *)adTextLink {
    return [self.adInfoDic stringValueForKey:@"ad_txt_link" defaultValue:nil];
}

- (NSString *)adTitle {
    return [self.adInfoDic stringValueForKey:@"ad_txt" defaultValue:nil];
}

- (NSString *)adImageFilePath {
//    return [self adImageUrl];
    return [[TTURLCache sharedCache] cachePathForURL:[self adImageUrl]];
}

- (NSString *)adImageUrl {
    return [self.adInfoDic stringValueForKey:@"image_url" defaultValue:nil];
}

- (UIImage *)adImage {
    //取出来不是image,所以暂时还是用TT吧
    UIImage *adImage = nil;
    NSString *filePath = [self adImageFilePath];
    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        adImage = [UIImage imageWithContentsOfFile:filePath];
    }
    
    return adImage;

}

- (SNStatInfoUseType)getReportObjLabel:(BOOL)isEmpty
                       defaultObjLabel:(SNStatInfoUseType)d {
    return [SNNewsAd getObjLebel:self.fromPush
                         spaceId:self.adSpaceId
                    defaultLabel:d empty:isEmpty];
}

- (void)reportForClickTrack {
    if ([[self.filter stringValueForKey:@"original" defaultValue:@"0"] isEqualToString:@"1"]) {
        [[SHADManager sharedManager] reportForAdClickTrackingWithItemSpaceID:self.adSpaceId];
    } else {
        SNStatClickInfo *info = [[SNStatClickInfo alloc] init];
        info.objLabel = [self getReportObjLabel:NO
                                defaultObjLabel:SNStatInfoUseTypeOutTimelineAd];
        [self updateInfoWithData:info];
        [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
        
        info.objLabel = SNStatInfoUseTypeOutTimelineAd;
        
        [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
    }
}

- (void)reportForDisplayTrack {
    if ([[self.filter stringValueForKey:@"original" defaultValue:@"0"] isEqualToString:@"1"]) {
        [[SHADManager sharedManager] reportForAdImpTrackingWithItemSpaceID:self.adSpaceId];
    } else {
        //曝光统计虑重
        if (self.isReportStatistics) {
            return;
        }
        self.isReportStatistics = YES;
        
        SNStatExposureInfo *info = [[SNStatExposureInfo alloc] init];
        info.objLabel = [self getReportObjLabel:NO defaultObjLabel:SNStatInfoUseTypeOutTimelineAd];
        [self updateInfoWithData:info];
        [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
        
        info.objLabel = SNStatInfoUseTypeOutTimelineAd;
        [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
    }
}

- (void)reportForLoadTrack {
    SNStatLoadInfo *info = [[SNStatLoadInfo alloc] init];
    
    info.objLabel = [self getReportObjLabel:NO defaultObjLabel:SNStatInfoUseTypeOutTimelineAd];
    [self updateInfoWithData:info];
    
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    
    info.objLabel = SNStatInfoUseTypeOutTimelineAd;
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
}

- (void)reportForEmptyTrack {
    SNStatEmptyInfo *info = [[SNStatEmptyInfo alloc] init];
    info.objLabel = [self getReportObjLabel:YES defaultObjLabel:SNStatInfoUseTypeEmptyOutTimelineAd];
    [self updateInfoWithData:info];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    
    info.objLabel = SNStatInfoUseTypeEmptyOutTimelineAd;
    [[SNAdStatisticsManager shareInstance] uploadAdSDKParamEvent:info];
}

- (void)updateInfoWithData:(SNStatInfo *)info {
    if (self.adId.length > 0) {
        info.adIDArray = @[self.adId];
    }
    info.objType = self.adSpaceId;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
    if (![info.objFrom isEqualToString:@"subscribe"]) {
        info.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];
    }
    NSString * currentNewsChn = [[SNVideoAdContext sharedInstance] getCurrentChannelID];
    info.appChannelId = self.appChannel;
    if ([[SNUtility getCurrentChannelId] isEqualToString:@"1"]) {
        info.newsChannelId = [SNUtility getCurrentChannelId];
    } else {
        info.newsChannelId = currentNewsChn;
    }
    
    info.adView = self.adView;
    info.gbcode = self.gbcode;
    info.roomId = self.roomId;
    info.newsId = self.newsID;
    info.subId = self.subId;
    info.newsType = self.newsType;
    info.blockId = self.blockId;
    
    if (nil != _newsCate) {
        info.newsCate = self.newsCate;
    }

    [info.requestFilter addEntriesFromDictionary:self.filter];
    
    if (nil != _newsID) {
        [info.requestFilter setObject:_newsID forKey:@"newsid"];
    }
    
    if (info.itemspaceid.length == 0) {
        info.itemspaceid = self.adSpaceId;
    }
    
    if (self.fromPush) {
        info.loadMoreCount = @"0";
    }
}

- (void)setAdDataHandler:(UIView *(^)(id dataCarrier, BOOL needRender))refreshAdDataHandler {
    self.refreshAdDataHandler = refreshAdDataHandler;
}

- (void)dealloc {
    self.delegate = nil;
    self.adViewTapDelegate = nil;
}

#pragma mark - SNAdDataWrapperViewDelegate
- (void)adWrapperViewTapped:(SNAdDataWrapperView *)sender {
    if (self.adViewTapDelegate &&
        [self.adViewTapDelegate respondsToSelector:@selector(adViewDidTap:)]) {
        [self.adViewTapDelegate adViewDidTap:self];
    }
}

@end
