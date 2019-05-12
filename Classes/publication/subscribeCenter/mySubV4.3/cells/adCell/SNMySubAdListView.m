//
//  SNMySubAdListView.m
//  sohunews
//
//  Created by jojo on 14-5-15.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNMySubAdListView.h"
#import "SNStatisticsManager.h"
#import "SNSubscribeCenterService.h"

@interface SNMySubAdListView ()

@property (nonatomic, strong) SNWebImageView *imageView;

@end

@implementation SNMySubAdListView
@synthesize adObj = _adObj;
@synthesize imageView = _imageView;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 3;
        self.clipsToBounds = YES;
        
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
     //(_adObj);
     //(_imageView);
    [SNNotificationManager removeObserver:self];
}

- (void)setAdObj:(SCSubscribeAdObject *)adObj {
    if (_adObj != adObj) {
         //(_adObj);
        _adObj = adObj;
        
        [self.imageView setUrlPath:_adObj.adImage];
    }
}

- (SNWebImageView *)imageView {
    if (!_imageView) {
        _imageView = [[SNWebImageView alloc] initWithFrame:self.bounds];
        _imageView.userInteractionEnabled = YES;
        _imageView.defaultImage = [UIImage themeImageNamed:@"defaultImageBg.png"];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageClicked:)];
        [_imageView addGestureRecognizer:tap];
         //(tap);
    }
    return _imageView;
}

#pragma mark - actions
- (void)onImageClicked:(id)sender {
    [SNSubscribeCenterService handleAdOpenRequest:self.adObj];
    //订阅推广位点击统计
    [self reportPopularizeClick];
}

- (void)reportPopularizeDisplay
{
    SNStatExposureInfo *info = [[SNStatExposureInfo alloc] init];
    [self updateInfoWithData:info];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}

- (void)reportPopularizeClick
{
    SNStatClickInfo *info = [[SNStatClickInfo alloc] init];
    [self updateInfoWithData:info];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}

- (void)updateInfoWithData:(SNStatInfo *)info
{
    if (self.adObj.adId.length > 0) {
        info.adIDArray = @[self.adObj.adId];
    }
    
//    info.adIDArray = appAdIDArray;
    info.objLabel = SNStatInfoUseTypeOutTimelinePopularize;
    info.objType = kObjTypeOfRecommendPosionInMySubBanner;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
//    info.objFromId = [[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif];
}

- (void)updateTheme {
    _imageView.defaultImage = [UIImage themeImageNamed:@"defaultImageBg.png"];
}

@end
