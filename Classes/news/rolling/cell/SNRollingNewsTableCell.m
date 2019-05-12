//
//  SNRollingNewsTableCell.m
//  sohunews
//
//  Created by Dan on 2/10/12.
//  Updated by sampanli 1/20/12
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNRollingNewsTableCell.h"
#import "SNRollingNewsTableItem.h"
#import "SNDBManager.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+ColorUtils.h"
#import "SNThemeManager.h"
#import "UIImageView+WebCache.h"

#import "SNCommonNewsController.h"
#import "SNCommonNewsDatasource.h"
#import "SDImageCache.h"
#import "SNThirdPartRequestManager.h"
#import "SNNewsAd+analytics.h"

static CGFloat rowCellHeight = 0.0f;

@implementation SNRollingNewsTableCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *aItem = object;
    return aItem.cellHeight;
}

+ (void)calculateCellHeight:(SNRollingNewsTableItem *)item {
    [super calculateCellHeight:item];

    CGFloat cellHight = (item.type == NEWS_ITEM_TYPE_AD) ? CELL_IMAGE_HEIGHT_AD : CELL_IMAGE_HEIGHT;
    rowCellHeight = roundf(cellHight + (2 * IMAGE_TOP));
    
    CGFloat offsetValue = 0;
    if ([item.news.templateType isEqualToString:@"53"]) {
        rowCellHeight += 49;
    } else {
        //by 5.9.4 wangchuanwen modify
        if (item.titlelineCnt > 2) {
            //图文模版，当标题高度接近图片高度，调整cell高度
            if ([SNUtility shownBigerFont]) {
                offsetValue = 25;
                
                //千帆特殊处理
                if ([item.news.templateType isEqualToString:@"39"]) {
                    offsetValue = 18;
                }
            } else {
                offsetValue = ([SNDevice sharedInstance].isMoreThan320 ? 18 : 18);
            }
        }
        //modify end
    }
    
    item.cellHeight = rowCellHeight + offsetValue;
}

+ (CGFloat)getTitleWidth {
    //有图片时标题宽度不同
    int titleWidth = kAppScreenWidth - 2 * CONTENT_LEFT - CELL_IMAGE_WIDTH - CELL_IMAGE_TITLE_DISTANCE;
    return titleWidth;
}

+ (CGFloat)getAbstractWidth {
    //有图片时摘要宽度不同
    int titleWidth = kAppScreenWidth - 2 * CONTENT_LEFT - CELL_IMAGE_WIDTH - CELL_IMAGE_TITLE_DISTANCE;
    return titleWidth;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        //imageview
        CGFloat cellHight = (self.item.type == NEWS_ITEM_TYPE_AD) ? CELL_IMAGE_HEIGHT_AD : CELL_IMAGE_HEIGHT;
        CGRect imageViewRect = CGRectMake(CONTENT_LEFT, IMAGE_TOP,
                                          CELL_IMAGE_WIDTH, cellHight);
        self.cellImageView = [[SNCellImageView alloc] initWithFrame:imageViewRect];
        [self.cellImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder3]];
        [self addSubview:self.cellImageView];

        if (!self.cellImageView) {
            //imageview
            CGRect imageViewRect = CGRectMake(CONTENT_LEFT, IMAGE_TOP, CELL_IMAGE_WIDTH, CELL_IMAGE_HEIGHT);
            self.cellImageView = [[SNCellImageView alloc] initWithFrame:imageViewRect];
            [self.cellImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder3]];
            [self addSubview:self.cellImageView];
        }
    
        [self initAdDownloadView];
    }
    return self;
}

- (void)initAdDownloadView {
    CGFloat topValue = self.cellImageView.bottom + 7;
    CGRect downloadViewRect = CGRectMake(CONTENT_LEFT, topValue, kAppScreenWidth - 2 * CONTENT_LEFT, 42);
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
        _adAppLineView = [[UIView alloc] initWithFrame:CGRectMake(_adAppBackgroundView.width - CONTENT_LEFT * 2 - 136 / 2, (84 - 56) / 4, 0.5, 56 / 2)];
        _adAppLineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
        _adAppLineView.hidden = YES;
        [_adAppBackgroundView addSubview:_adAppLineView];
    }
    
    if (!_adAppDownloadButton) {
        _adAppDownloadButton = [[UIButton alloc] initWithFrame:CGRectMake(_adAppBackgroundView.width - CONTENT_LEFT - 136 / 2, (84 - 56) / 4, 136 / 2, 56 / 2)];
        _adAppDownloadButton.layer.cornerRadius = 2.0f;
        _adAppDownloadButton.layer.borderWidth = 0.5f;
        _adAppDownloadButton.layer.borderColor = SNUICOLOR(kThemeBlue1Color).CGColor;
        [_adAppDownloadButton setTitle:@"立即下载" forState:UIControlStateNormal];
        _adAppDownloadButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _adAppDownloadButton.titleLabel.font = [UIFont systemFontOfSize:28 / 2.0f];
        [_adAppDownloadButton setTitleColor:SNUICOLOR(kThemeBlue1Color)
                                   forState:UIControlStateNormal];
        [_adAppDownloadButton addTarget:self action:@selector(clickDownloadButton) forControlEvents:UIControlEventTouchUpInside];
        _adAppDownloadButton.hidden = YES;
        [_adAppBackgroundView addSubview:_adAppDownloadButton];
    }
}

- (void)clickDownloadButton {
    if (self.item.news.newsAd.appLink && self.item.news.newsAd.appLink.length > 0) {
        [self.item.news.newsAd reportAdClick:self.item.news];
        [SNUtility openProtocolUrl:self.item.news.newsAd.appLink];
    }
}

- (void)updateNewsContent {
    [super updateNewsContent];
    [self updateImage];
    [self updateMorebtnAndDownloadView];
    [self downloadUpdataTheme];
}

- (void)updateTheme {
    [super updateTheme];
    [self.cellImageView updateTheme];
    [self.cellImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder3]];
    [self downloadUpdataTheme];
}

- (void)updateImage {
    if (self.item.cellType != SNRollingNewsCellTypeBook) {
        //广告尺寸360X234 比率1.538 CELL_IMAGE_HEIGHT_AD + 0.1保证尺寸宽高比1.538，否则有图片裁边问题
        CGFloat cellHight = (self.item.type == NEWS_ITEM_TYPE_AD) ? CELL_IMAGE_HEIGHT_AD + 0.1 : CELL_IMAGE_HEIGHT;
        CGFloat topValue = IMAGE_TOP;
        if (self.item.titlelineCnt > 2) {
            
            if ([SNUtility shownBigerFont]) {
                topValue += [SNDevice sharedInstance].isPlus ? 5 : 4;
            }
        }
        CGRect imageViewRect = CGRectMake(CONTENT_LEFT, topValue, CELL_IMAGE_WIDTH, cellHight);
        self.cellImageView.frame = imageViewRect;
        if ([self.item hasVideo]) {
            [self.cellImageView layOutVideoImageView];
        }
        
        _adAppBackgroundView.top = self.cellImageView.bottom + 7;
    }
    
    self.cellImageView.hidden = [self.item hasImage] ? NO : YES;
    [self.cellImageView updateImageWithUrl:self.item.news.picUrl
                              defaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder3]
                                 showVideo:[self.item hasVideo]];
    
    [self.cellImageView showDefaultVideoIcon:[self.item hasVideo]];
    
    [self.cellImageView updateTheme];
}

- (void)downloadUpdataTheme {
    if ([self.item.news.templateType isEqualToString:@"53"]) {
        //by 5.9.4 wangchuanwen modify
        _adAppBackgroundView.backgroundColor = SNUICOLOR(kRefreshBgColor);
        //modify end
        _adAppLabel.textColor = SNUICOLOR(kThemeText2Color);
        _adAppLineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
        _adAppDownloadButton.layer.borderColor = SNUICOLOR(kThemeBlue1Color).CGColor;
        [_adAppDownloadButton setTitleColor:SNUICOLOR(kThemeBlue1Color) forState:UIControlStateNormal];
    }
}

- (void)updateMorebtnAndDownloadView {
    if ([self.item.news.templateType isEqualToString:@"53"]) {
        _adAppBackgroundView.hidden = NO;
        _adAppLabel.text = self.item.news.newsAd.advertiser;
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
