//
//  SN12233Decoder.m
//  sohunews
//
//  Created by Xiang Wei Jia on 3/17/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNAd12233Controller.h"
#import "SNAdImageTemplate.h"
#import "SNAdData.h"

#import "SNReportAdData.h"
#import "SNADReport.h"

@interface SNAd12233Controller()

@end

@implementation SNAd12233Controller

- (void)loadView
{
    self.view = [[NSBundle mainBundle] loadNibNamed:@"SNAdImageTemplate" owner:self options:nil][0];
}

- (SNAdImageTemplate *)template
{
    return (SNAdImageTemplate *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SNReportAdData *adData = [SNADReport reportData:self.reportId];
    if (!adData) {
        [adData addExposureFrom:6];
    }
}

- (void)updateAdView
{
    [self updateImage:self.template.adImage
                  url:self.adData.imageUrl
             complete:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
        [self.delegate adAllLoaded:self];
    }];
}

- (CGSize)adps
{
    UIDevicePlatform t = [[UIDevice currentDevice] platformTypeForSohuNews];
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    if (UIDevice6PlusiPhone == t || UIDevice7PlusiPhone == t || UIDevice8PlusiPhone == t)
    {
        return CGSizeMake(size.width * 3, size.height * 3);
    }
    else
    {
        return CGSizeMake(size.width * 2, size.height * 2);
    }
}

- (void)reportExposure
{
    [super reportExposure];
}

@end
