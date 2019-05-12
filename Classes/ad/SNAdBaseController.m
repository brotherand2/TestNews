//
//  SNAdBase.m
//  sohunews
//
//  Created by Xiang Wei Jia on 2/26/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNAdBaseController.h"
#import "SNAdTemplateFactory.h"
#import "SNAdData.h"
#import "SNStatisticsManager.h"
#import "SNAdStatisticsManager.h"
#import "SNADReport.h"

@interface SNAdBaseController()

@end

@implementation SNAdBaseController

-(instancetype) initWithSpaceId:(NSString *)spaceId delegate:(id<SNAdDelegate>)delegate filter:(NSDictionary *)filter
{
    self = [super init];
    
    if (nil != self)
    {
        self.delegate = delegate;
        
        _spaceId = spaceId;
        _adData = [[SNAdData alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _adView = (SNAdView *)self.view;
    
    // 点击事件
    [_adView setClickBlock:^(SNAdView *adView, UIView *clickdView)
     {
         // 上报
         [self reportClick];
         
         // 通知外部
         if (nil != _delegate && [_delegate respondsToSelector:@selector(adClick:control:)])
         {
             [_delegate adClick:self control:clickdView];
         }
     }];
    
    // 不感兴趣
    [_adView setUninterestingBlock:^(SNAdView *adView)
     {
         // 上报
         [self reportUninteresting];
         
         // 通知外部
         if (nil != _delegate && [_delegate respondsToSelector:@selector(uninteresting:)])
         {
             [_delegate uninteresting:self];
         }
     }];
    
    // 曝光
    [_adView setExposureBlock:^(SNAdView *adView)
     {
         [self exposure];
     }];
}

- (void)updateAdView
{
    // 数据在adData里
    [NSException raise:@"子类必须实现updateAdView接口" format:@"%@ 子类没有实现updateAdView接口", [self description]];
}

- (void)updateImage:(UIImageView *)imageView url:(NSString *)url complete:(void(^)(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL))complete
{
    if (nil != url && url.length > 0)
    {
        [imageView sd_setImageWithURL:[NSURL URLWithString:url]
                                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             if (nil != error && _maxDownloadRetry > _downloadRetry)
             {
                 // 下载失败，重试
                 _downloadRetry++;
                 
                 [self updateImage:imageView url:url complete:complete];
                 
                 return ;
             }
             
             if (nil != self.delegate
                 && [self.delegate respondsToSelector:@selector(adImageLoaded:url:error:)])
             {
                 [self.delegate adImageLoaded:self url:imageURL.absoluteString error:nil != error];
             }
             
             if (nil != complete)
             {
                 complete(image, error, cacheType, imageURL);    
             }
         }];
    }
}

- (CGSize)adps
{
    [NSException raise:@"子类必须实现adps接口" format:@"%@ 子类没有实现adps接口", [self description]];
    
    return CGSizeZero;
}

- (void)exposure
{
    [self reportExposure];
}

- (void)empty
{
    if (nil != _delegate && [_delegate respondsToSelector:@selector(emptyAD:)])
    {
        [_delegate emptyAD:self];
    }
}

-(void) reportEmpty
{
    [SNADReport reportEmpty:_reportId];
}

-(void) reportLoad
{
    [SNADReport reportLoad:_reportId];
}

-(void) reportExposure
{
    [SNADReport reportExposure:_reportId];
}

-(void) reportUninteresting
{
    [SNADReport reportUninteresting:_reportId];
}

-(void) reportClick
{
    [SNADReport reportClick:_reportId];
}

@end
