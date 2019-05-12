//
//  SNGalleryAdCell.m
//  SNNewGallery
//
//  Created by H.Ekko on 04/01/2017.
//  Copyright © 2017 Huang Zhen. All rights reserved.
//

#import "SNGalleryAdCell.h"
#import "UIImageView+WebCache.h"
#import "SNAdDataCarrier.h"
#import "SNDevice.h"
#import "SNGalleryConst.h"

@interface SNGalleryAdCell ()

@property (nonatomic, strong) UILabel * adLabel;

@property (nonatomic, strong) UIView * maskView;

@end

@implementation SNGalleryAdCell
#pragma mark - private

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self initContent];
    }
    return self;
}

- (void)initContent {
    CGRect rect = [UIScreen mainScreen].bounds;
    self.adImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kLeftOffset, 0, rect.size.width, rect.size.height)];
    [self addSubview:self.adImageView];
    
    self.adLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 18)];
    self.adLabel.top = 14 + kSystemBarHeight;
    self.adLabel.right = kAppScreenWidth - 14;
    self.adLabel.layer.borderColor = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.4].CGColor;
    self.adLabel.layer.borderWidth = [[SNDevice sharedInstance] isPlus] ? 1.0/3 : 1.0/2;
    self.adLabel.layer.cornerRadius =[[SNDevice sharedInstance] isPlus] ? 2.0/3 : 2.0/2;
    self.adLabel.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.05];
    self.adLabel.textAlignment = NSTextAlignmentCenter;
    self.adLabel.font = [UIFont systemFontOfSize:kThemeFontSizeH];
    self.adLabel.textColor = SNUICOLOR(kThemeText5Color);
    self.adLabel.alpha = 0.f;
    [self.adImageView addSubview:self.adLabel];
    BOOL night = [[SNThemeManager sharedThemeManager] isNightTheme];
    if (night) {
        self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        self.maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.adImageView addSubview:self.maskView];
    }

    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickEvent)];
    [self addGestureRecognizer:tap];
}

- (void)clickEvent {
    if (self.adCarrier.adClickUrl.length > 0) {
        if ([SNUtility openProtocolUrl:self.adCarrier.adClickUrl context:nil]) {
            [self.adCarrier reportForClickTrack];
        }
    }
}

/*
 {
 "ad_txt" = "12233\U5168\U76d1\U6d4b1080x1920.jpg";
 "click_url" = "http://clk.optaim.com/event.ng/Type=click&FlightID=201506&TargetID=sohu&Values=7a45466d,7b7b78bf,bf7c1fd7,08d33011&AdID=13891011";
 "image_url" = "http://images.sohu.com/bill/a2016/1110/ChAiOVgkFuqAbPaIAAGKiMV8CcM8171080x1920.jpg";
 }
 */
- (void)setAdCarrier:(SNAdDataCarrier *)adCarrier {
    _isLoadingImage = YES;
    if (adCarrier != _adCarrier) {
        _adCarrier = adCarrier;
    }
    if (_adCarrier.adImageUrl.length > 0) {
        [self.adImageView sd_setImageWithURL:[NSURL URLWithString:adCarrier.adImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                _isLoadingImage = NO;
            }
        }];
    }
    if (adCarrier) {
        NSString *adText = [adCarrier.filter objectForKey:@"iconText"];
        NSString *adSpaceld = adCarrier.adSpaceId;
        NSString *dsp_source = [adCarrier.adInfoDic objectForKey:@"dsp_source"];
        if ([adSpaceld isEqualToString:@"12233"] && ((adText && adText.length > 0) || (dsp_source && dsp_source.length > 0))) {
            _adLabel.alpha = 1.0f;
            _adLabel.text = [NSString stringWithFormat:@"%@%@", dsp_source ? : @"", adText ? : @""];
            CGSize titleSize = [_adLabel.text sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeH]];
            _adLabel.width = titleSize.width + 8;
            _adLabel.right = kAppScreenWidth - 14;
        }
    }

}

@end
