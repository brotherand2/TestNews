 //
//  SNRollingPhotoNewsTableCell.m
//  sohunews
//
//  Created by Cong Dan on 3/20/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNRollingPhotoNewsTableCell.h"
#import "SNDBManager.h"
#import "UIColor+ColorUtils.h"
#import "SNCellImageView.h"
#import "SNDevice.H"
#import "SNNewsAd+analytics.h"

#define kPhotoViewCount                 (3)

@implementation SNRollingPhotoNewsTableCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *aItem = object;
    return aItem.cellHeight;
}

+ (void)calculateCellHeight:(SNRollingNewsTableItem *)item {
    [super calculateCellHeight:item];

    CGFloat imageHeight = [self getImageHeight];
    CGFloat cellHeight = IMAGE_TOP + item.titleHeight + 9 + imageHeight + COMMENT_BOTTOM;
    
    if ([item.news.templateType isEqualToString:@"51"] || [item.news.templateType isEqualToString:@"54"]) {
        cellHeight += 40;
    }
    
    //by 5.9.4 wangchuanwen modify
    //有些是没有markText的，造成cell高度过高
    if ([item.news.newsType isEqualToString:kSNOuterLinkNewsType] && item.news.recomReasons.length <= 0 && item.getNewsTypeTextString.length <= 0 && item.getNewsTypeString.length <= 0 && item.news.sponsorshipsObject.title.length <= 0 && item.news.media.length <= 0  &&
        (item.news.commentNum.length <= 0 ||
         ![item hasComments])) {
        cellHeight -= 15;
    }
    //modify end
    
    item.cellHeight = cellHeight;
}

+ (BOOL)isMultiLineTitleWithItem:(SNRollingNewsTableItem *)item {
    //组图频道默认传YES
    return YES;
}

+ (CGFloat)getImageHeight {
    CGFloat distance = [[self class] getImageDistance];
    CGFloat imageWidth = (kAppScreenWidth - CONTENT_LEFT * 2 - distance * 2) / kPhotoViewCount;
    
    return imageWidth * 2/3;
}

+ (CGFloat)getImageWidth {
    return PHOTOSCELLIMAGE_WIDTH;
}

+ (CGFloat)getImageDistance {
    //by 5.9.4 wangchuanwen modify
    return PHOTOSCELLIMAGE_GAP;
    //modify end
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        imageViewArray = [[NSMutableArray alloc] init];
        _defaultImage = [UIImage themeImageNamed:kThemeImgPlaceholder3];
        [self initPhotoView];
        [self initAdDownloadView];
    }
    return self;
}

- (void)initPhotoView {
    CGFloat x = CONTENT_LEFT;
    CGFloat imageHeight = [self getCellImageHeight];
    CGFloat distance = [[self class] getImageDistance];
    CGFloat imageWidth = (kAppScreenWidth - CONTENT_LEFT * 2 - distance * 2) / kPhotoViewCount;
    
    for (int i = 0; i < kPhotoViewCount; i++) {
        CGRect imageViewRect = CGRectMake(x, CONTENT_IMAGE_TOP, imageWidth, imageHeight);
        SNCellImageView *photoImageView = [[SNCellImageView alloc] initWithFrame:imageViewRect];
        [photoImageView updateDefaultImage:_defaultImage];
        [imageViewArray addObject:photoImageView];
        [self addSubview:photoImageView];
        x += imageWidth + distance;
    }
}

- (void)initAdDownloadView {
    CGRect downloadViewRect = CGRectMake(CONTENT_LEFT, CONTENT_IMAGE_TOP +[[self class] getImageHeight] + 8 / 2, kAppScreenWidth - 2 * CONTENT_LEFT, 84 / 2);
    if (!_adAppBackgroundView) {
        _adAppBackgroundView = [[UIView alloc] initWithFrame:downloadViewRect];
        //by 5.9.4 wangchuanwen modify
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
    if ([self.item.news.templateType isEqualToString:@"51"]) {
        if (self.item.news.newsAd.appLink && self.item.news.newsAd.appLink.length > 0) {
            [self.item.news.newsAd reportAdClick:self.item.news];
            [SNUtility openProtocolUrl:self.item.news.newsAd.appLink];
        }
    } else if ([self.item.news.templateType isEqualToString:@"54"]) {
        if (self.item.news.newsAd.phone && self.item.news.newsAd.phone.length > 0) {
            [self.item.news.newsAd reportAdClickPhone:self.item.news];
            [self callPhoneStr:self.item.news.newsAd.phone];
        }
    }
}

- (void)callPhoneStr:(NSString *)phoneStr {
    NSString *str2 = [[UIDevice currentDevice] systemVersion];
    if ([str2 compare:@"10.2" options:NSNumericSearch] == NSOrderedDescending || [str2 compare:@"10.2" options:NSNumericSearch] == NSOrderedSame) {
        NSString *PhoneStr = [NSString stringWithFormat:@"telprompt://%@",phoneStr];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:PhoneStr] options:@{} completionHandler:^(BOOL success) {
        }];
    } else {
        UIWebView *callWebview = [[UIWebView alloc] init];
        NSString *phone = [NSString stringWithFormat:@"tel:%@", phoneStr];
        [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:phone]]];
        [[UIApplication sharedApplication].keyWindow addSubview:callWebview];
    }
}

- (void)updateNewsContent {
    [super updateNewsContent];
    [self updateGroupImages];
    [self updateAdDownloadView];
}

- (void)updateGroupImages {
    for (int i = 0; i < kPhotoViewCount; i++) {
        SNCellImageView *photoImageView = [imageViewArray objectAtIndex:i];
        if (i < [self.item getGroupImagesCount]) {
            photoImageView.hidden = NO;
            photoImageView.top = self.item.titleHeight + 6;
            NSString *imageUrl = nil;
            if ([self.item.news.templateType isEqualToString:@"41"] || [self.item.news.templateType isEqualToString:@"51"] || [self.item.news.templateType isEqualToString:@"54"]) {
                imageUrl = [self.item.news.newsAd.picUrls objectAtIndex:i];
            } else {
                imageUrl = [self.item.news.picUrls objectAtIndex:i];
            }
            [photoImageView updateImageWithUrl:imageUrl
                                 defaultImage:[UIImage imageNamed:kThemeImgPlaceholder3]
                                    showVideo:NO];
            [photoImageView updateTheme];
            [self downloadUpdataTheme];
        } else {
            //组图新闻没有图片时，显示展位符 wyy
            [photoImageView updateImageWithUrl:nil
                                  defaultImage:[UIImage imageNamed:kThemeImgPlaceholder3]
                                     showVideo:NO];
        }
    }
    
     if ([self.item.news.templateType isEqualToString:@"51"] || [self.item.news.templateType isEqualToString:@"54"]) {
         _adAppBackgroundView.top = self.item.titleHeight + 6 + [self getCellImageHeight];
     }
}

- (void)updateTheme {
    [super updateTheme];
    CGFloat heightValue = [self getCellImageHeight];
    for (int i = 0; i < kPhotoViewCount; i++) {
        SNCellImageView *photoImageView = [imageViewArray objectAtIndex:i];
        [photoImageView updateTheme];
        photoImageView.frame = CGRectMake(photoImageView.origin.x, photoImageView.origin.y, photoImageView.size.width, heightValue);

        [photoImageView updateDefaultImage:[UIImage imageNamed:kThemeImgPlaceholder3]];
    }
    [self downloadUpdataTheme];
}

- (void)updateContentView{
    [super updateContentView];
    CGFloat heightValue = [self getCellImageHeight];
    for (int i = 0; i < kPhotoViewCount; i++) {
        SNCellImageView *photoImageView = [imageViewArray objectAtIndex:i];
        [photoImageView updateTheme];
        photoImageView.frame = CGRectMake(photoImageView.origin.x, photoImageView.origin.y, photoImageView.size.width, heightValue);
    }
}

- (void)downloadUpdataTheme {
    if ([self.item.news.templateType isEqualToString:@"51"] || [self.item.news.templateType isEqualToString:@"54"]) {
        //by 5.9.4 wangchuanwen modify
        _adAppBackgroundView.backgroundColor = SNUICOLOR(kRefreshBgColor);
        //modify end
        _adAppLabel.textColor = SNUICOLOR(kThemeText2Color);
        _adAppLineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
        _adAppDownloadButton.layer.borderColor = SNUICOLOR(kThemeBlue1Color).CGColor;
        [_adAppDownloadButton setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
    }
}

- (void)updateImage {
    [self updateGroupImages];
}

- (void)updateAdDownloadView {
    if ([self.item.news.templateType isEqualToString:@"51"]) {
        _adAppBackgroundView.hidden = NO;
        _adAppLabel.text = self.item.news.newsAd.advertiser;
        [_adAppDownloadButton setTitle:@"立即下载" forState:UIControlStateNormal];
        _adAppLabel.hidden = NO;
        _adAppLineView.hidden = NO;
        _adAppDownloadButton.hidden = NO;
    } else if ([self.item.news.templateType isEqualToString:@"54"]) {
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

- (CGFloat)getCellImageHeight {
    return [[self class] getImageHeight];
}

@end
