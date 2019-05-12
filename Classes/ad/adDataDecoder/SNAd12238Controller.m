//
//  SN12238Decoder.m
//  sohunews
//
//  Created by Xiang Wei Jia on 3/17/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNAd12238Controller.h"
#import "SNAd12238Template.h"
#import "SNAdData.h"

#define ControllerWidth 114
#define ControllerHeight 78

@interface SNAd12238Controller()

@end

@implementation SNAd12238Controller

- (void)loadView
{
    self.view = [[NSBundle mainBundle] loadNibNamed:@"SNAd12238Template" owner:self options:nil][0];
}

- (SNAd12238Template *)template
{
    return (SNAd12238Template *)self.view;
}

- (void)updateAdView
{
    if (nil != self.adData.imageUrl && self.adData.imageUrl.length > 0)
    {
        [self.template.adImage sd_setImageWithURL:[NSURL URLWithString:self.adData.imageUrl]];
    }
    
    self.template.adText.text = self.adData.title;
}

- (CGSize)adps
{
    UIDevicePlatform t = [[UIDevice currentDevice] platformTypeForSohuNews];
    
    if (UIDevice6PlusiPhone == t || UIDevice7PlusiPhone == t || UIDevice8PlusiPhone == t)
    {
        return CGSizeMake(ControllerWidth * 3, ControllerHeight * 3);
    }
    else
    {
        return CGSizeMake(ControllerWidth * 2, ControllerHeight * 2);
    }
}

- (void)reportExposure
{
    // 图片下载成功了才能调曝光上报
    [super reportExposure];
}

@end
