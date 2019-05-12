//
//  SNRollingNewsPictureCell.m
//  sohunews
//
//  Created by lhp on 5/7/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingNewsPictureCell.h"
#import "SNNewsAd+analytics.h"

#define kPhotoImageRate                 (346.f / 694.f)
#define PictureCellItem_Height          (4)//调整cell间距

@implementation SNRollingNewsPictureCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    int imageWidth = kAppScreenWidth - 2 * CONTENT_LEFT;
    int imageHeight = imageWidth * kPhotoImageRate;
    //by 5.9.4 wangchuanwen modify
    //item间距调整 cellHeight
    int cellHeight = IMAGE_TOP + newsItem.titleHeight + 2 + imageHeight + COMMENT_BOTTOM + FEED_SPACEVALUE + PictureCellItem_Height;
    
    if ([SNDevice sharedInstance].isMoreThan320) {
        cellHeight += 1;
    }
    //modify end
    
    if ([newsItem.news.templateType isEqualToString:@"52"] || [newsItem.news.templateType isEqualToString:@"55"]) {
        cellHeight += 84 / 2;
    }
   
    newsItem.cellHeight = cellHeight;
    return cellHeight;
}

+ (BOOL)isMultiLineTitleWithItem:(SNRollingNewsTableItem *)item {
    //大图频道默认传NO
    return NO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        int imageWidth = kAppScreenWidth - 2*CONTENT_LEFT;
        int imageHeight = imageWidth * kPhotoImageRate;
        cellImageView.height = imageHeight;
        cellImageView = [[SNImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, CONTENT_IMAGE_TOP, imageWidth, imageHeight)];
        [self addSubview:cellImageView];
        
        [self initAdDownloadView];
    }
    return self;
}

- (void)initAdDownloadView {
    CGRect downloadViewRect = CGRectMake(CONTENT_LEFT, CONTENT_IMAGE_TOP +(kAppScreenWidth - 2 * CONTENT_LEFT) * kPhotoImageRate, kAppScreenWidth - 2 * CONTENT_LEFT, 42);
    if (!_adAppBackgroundView) {
        _adAppBackgroundView = [[UIView alloc] initWithFrame:downloadViewRect];
        //by 5.9.4 wangchuanwen modify
        //_adAppBackgroundView.backgroundColor = SNUICOLOR(kThemeBg2Color);
        _adAppBackgroundView.backgroundColor = SNUICOLOR(kRefreshBgColor);
        //modify end
        _adAppBackgroundView.hidden = YES;
        [self addSubview:_adAppBackgroundView];
    }
    
    if (!_adAppLabel) {
        _adAppLabel = [[UILabel alloc] initWithFrame:CGRectMake(CONTENT_LEFT, 0, _adAppBackgroundView.width - 136 / 2 - CONTENT_LEFT * 4, _adAppBackgroundView.height)];
        _adAppLabel.textColor = SNUICOLOR(kThemeText2Color);
        _adAppLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        _adAppLabel.hidden = YES;
        [_adAppBackgroundView addSubview:_adAppLabel];
    }
    
    if (!_adAppLineView) {
        _adAppLineView = [[UIView alloc] initWithFrame:CGRectMake(_adAppBackgroundView.width -CONTENT_LEFT * 2 - 136 / 2, (84 - 56) / 4, 0.5, 56 / 2)];
        _adAppLineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
        _adAppLineView.hidden = YES;
        [_adAppBackgroundView addSubview:_adAppLineView];
    }
    
    if (!_adAppDownloadButton) {
        _adAppDownloadButton = [[UIButton alloc] initWithFrame:CGRectMake(_adAppBackgroundView.width -CONTENT_LEFT - 136 / 2, (84 - 56) / 4, 136 / 2, 56 / 2)];
        _adAppDownloadButton.layer.cornerRadius = 2.0f;
        _adAppDownloadButton.layer.borderWidth = 0.5f;
        _adAppDownloadButton.layer.borderColor = SNUICOLOR(kThemeBlue1Color).CGColor;
        _adAppDownloadButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _adAppDownloadButton.titleLabel.font = [UIFont systemFontOfSize:28/2.0f];
        [_adAppDownloadButton setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
        [_adAppDownloadButton addTarget:self action:@selector(clickDownloadButton) forControlEvents:UIControlEventTouchUpInside];
        _adAppDownloadButton.hidden = YES;
        [_adAppBackgroundView addSubview:_adAppDownloadButton];
    }
}

- (void)clickDownloadButton {
    if ([self.item.news.templateType isEqualToString:@"52"]) {
        if (self.item.news.newsAd.appLink && self.item.news.newsAd.appLink.length > 0) {
            [self.item.news.newsAd reportAdClick:self.item.news];
            [SNUtility openProtocolUrl:self.item.news.newsAd.appLink];
        }
    } else if ([self.item.news.templateType isEqualToString:@"55"]) {
        if (self.item.news.newsAd.phone && self.item.news.newsAd.phone.length > 0) {
            [self.item.news.newsAd reportAdClickPhone:self.item.news];
            [self callPhoneStr:self.item.news.newsAd.phone];
        }
    }
}

- (void)callPhoneStr:(NSString *)phoneStr {
    NSString *str2 = [[UIDevice currentDevice] systemVersion];
    if ([str2 compare:@"10.2" options:NSNumericSearch] == NSOrderedDescending || [str2 compare:@"10.2" options:NSNumericSearch] == NSOrderedSame) {
        NSString* PhoneStr = [NSString stringWithFormat:@"telprompt://%@",phoneStr];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PhoneStr] options:@{} completionHandler:^(BOOL success) {
        }];
    } else {
        UIWebView * callWebview = [[UIWebView alloc] init];
        NSString *phone = [NSString stringWithFormat:@"tel:%@", phoneStr];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:phone]]];
        [[UIApplication sharedApplication].keyWindow addSubview:callWebview];
    }
}

- (void)updateNewsContent {
    [super updateNewsContent];
    [self updateImage];
    [self updateAdDownloadView];
    [self downloadUpdataTheme];
}

- (void)updateImage {
    [cellImageView loadImageWithUrl:self.item.news.picUrl defaultImage:[UIImage imageNamed:@"defaultImageBg.png"]];
    cellImageView.alpha = themeImageAlphaValue();
    //by 5.9.4 wangchuanwen modify
    cellImageView.top = self.item.titleHeight + 9;
    //modify end
    _adAppBackgroundView.top = cellImageView.bottom;
}

- (void)updateTheme {
    [super updateTheme];
    cellImageView.alpha = themeImageAlphaValue();
    [cellImageView updateDefaultImage:[UIImage themeImageNamed:@"defaultImageBg.png"]];
    
    [self downloadUpdataTheme];
}

- (void)downloadUpdataTheme {
    if ([self.item.news.templateType isEqualToString:@"52"] || [self.item.news.templateType isEqualToString:@"55"]) {
        //by 5.9.4 wangchuanwen modify
        _adAppBackgroundView.backgroundColor = SNUICOLOR(kRefreshBgColor);
        //modify end
        _adAppLabel.textColor = SNUICOLOR(kThemeText2Color);
        _adAppLineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
        _adAppDownloadButton.layer.borderColor = SNUICOLOR(kThemeBlue1Color).CGColor;
        [_adAppDownloadButton setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
    }
}

- (void)updateAdDownloadView {
    if ([self.item.news.templateType isEqualToString:@"52"]) {
        _adAppBackgroundView.hidden = NO;
        _adAppLabel.text = self.item.news.newsAd.advertiser;
        [_adAppDownloadButton setTitle:@"立即下载" forState:UIControlStateNormal];
        _adAppLabel.hidden = NO;
        _adAppLineView.hidden = NO;
        _adAppDownloadButton.hidden = NO;
    } else if ([self.item.news.templateType isEqualToString:@"55"]) {
        _adAppBackgroundView.hidden = NO;
        _adAppLabel.text = self.item.news.newsAd.advertiser;
        [_adAppDownloadButton setTitle:@"拨打电话" forState:UIControlStateNormal];
        _adAppLabel.hidden = NO;
        _adAppLineView.hidden = NO;
        _adAppDownloadButton.hidden = NO;
    } else {
        _adAppBackgroundView.hidden = YES;
        _adAppLabel.hidden = YES;
        _adAppLineView.hidden = YES;
        _adAppDownloadButton.hidden = YES;
    }
}

@end
