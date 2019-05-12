//
//  SNRollingNewsAdBannerCell.m
//  sohunews
//
//  Created by lhp on 5/15/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingNewsAdBannerCell.h"

#define kBannerImageRate                 (108.f / 694.f)

@implementation SNRollingNewsAdBannerCell

+ (CGFloat)getCellHeight {
    int imageWidth = kAppScreenWidth - 2 * CONTENT_LEFT;
    int imageHeight = imageWidth * kBannerImageRate;
    return IMAGE_TOP * 2 + imageHeight + COMMENT_BOTTOM;
}

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    newsItem.cellHeight = roundf([self getCellHeight]) + newsItem.titleHeight;
    return newsItem.cellHeight;
}

+ (BOOL)isMultiLineTitleWithItem:(SNRollingNewsTableItem *)item {
    //广告频道默认传NO
    return NO;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        int imageWidth = kAppScreenWidth - 2*CONTENT_LEFT;
        int imageHeight = imageWidth * kBannerImageRate;
        cellImageView.height = imageHeight;
    }
    return self;
}

- (void)updateImage {
    cellImageView.alpha = themeImageAlphaValue();
    [cellImageView loadImageWithUrl:self.item.news.picUrl
                       defaultImage:[UIImage imageNamed:kThemeImgPlaceholder9]];
    cellImageView.top = self.item.titleHeight+8;
}

- (void)updateTheme {
    [super updateTheme];
    cellImageView.alpha = themeImageAlphaValue();
    [cellImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder9]];
}

@end
