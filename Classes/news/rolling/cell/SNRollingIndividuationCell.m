//
//  SNRollingIndividuationCell.m
//  sohunews
//
//  Created by lhp on 7/29/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingIndividuationCell.h"
#import "SNImageView.h"
#import "SNThemeManager.h"
#import "SNRollingNews.h"
#import "SNNovelEntranceView.h"
#import "SNNewsAd+analytics.h"
#import "UIFont+Theme.h"
#import "SNNovelUtilities.h"

#define kContentRateForOne                  (126.f / 584.f)
#define kContentRateForTwo                  (126.f / 292.f)
#define kContentRateForThree                (126.f / 196.f)
#define kContentRateForFour                 (126.f / 146.f)

#pragma mark -
#pragma mark SNContainerView
@interface SNContainerView : UIView
- (void)initSubViews;
- (void)updateWithArray:(NSArray *)infoArray;
- (void)reportPopularizeStatClickInfo:(NSString *)idString;

@property (nonatomic, weak) id delegate;

@end

@implementation SNContainerView

- (void)initSubViews {
}

- (void)updateWithArray:(NSArray *)infoArray {
}

- (void)updateTheme {
}

- (void)reportPopularizeStatClickInfo:(NSString *)idString {
    if (self.delegate && [self.delegate respondsToSelector:@selector(reportPopularizeStatClickInfo:)]) {
        [self.delegate reportPopularizeStatClickInfo:idString];
    }
}

@end


#pragma mark -
#pragma mark SNContentView

@interface SNContentView : UIView
@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) SNImageView *publicImageView;
@property (nonatomic, weak) id delegate;
@end


@implementation SNContentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initSubViews];
        
        UIButton *openLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [openLinkButton setFrame:CGRectMake(0, 0, self.width, self.height)];
        [openLinkButton addTarget:self action:@selector(openLink) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:openLinkButton];
    }
    return self;
}

- (void)initSubViews {
    _publicImageView = [[SNImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _publicImageView.backgroundColor = [UIColor clearColor];
    _publicImageView.ignorePictureMode = YES;
    _publicImageView.alpha = themeImageAlphaValue();
    [self addSubview:_publicImageView];
}

- (void)openLink {
    if (self.link.length > 0) {
        [SNUtility openProtocolUrl:self.link];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(reportPopularizeStatClickInfo:)]) {
        [self.delegate reportPopularizeStatClickInfo:self.idString];
    }
}

@end

#pragma mark -
#pragma mark SNContontViewForOne
@interface SNContontViewForOne : SNContainerView {
    SNContentView *contentView;
}
@end

@implementation SNContontViewForOne

- (void)initSubViews {
    int contentWidth = kAppScreenWidth - 2 * CONTENT_LEFT;
    int contentHeight = contentWidth * kContentRateForOne;
    CGRect contentRect = CGRectMake(0, 0, contentWidth,contentHeight);
    contentView = [[SNContentView alloc] initWithFrame:contentRect];
    contentView.delegate = self;
    [self addSubview:contentView];
}

- (void)updateWithArray:(NSArray *)infoArray {
    if ([infoArray count] > 0) {
        SNNewsIndividuationInfo *individuationInfo = [infoArray objectAtIndex:0];
        if (individuationInfo.pic.length > 0) {
            [contentView.publicImageView loadImageWithUrl:individuationInfo.pic
                                             defaultImage:[UIImage imageNamed:kThemeImgPlaceholder7]];
            
        }
        contentView.link = individuationInfo.link;
        contentView.idString = individuationInfo.idString;
    }
}

- (void)updateTheme {
    contentView.publicImageView.alpha = themeImageAlphaValue();
    [contentView.publicImageView updateDefaultImage:[UIImage imageNamed:kThemeImgPlaceholder7]];
}

@end


#pragma mark -
#pragma mark SNContontViewForTwo
@interface SNContontViewForTwo : SNContainerView
@property (nonatomic, strong) SNContentView *leftContentView;
@property (nonatomic, strong) SNContentView *rightContentView;
@end

@implementation SNContontViewForTwo

- (void)initSubViews {
    int contentWidth = (kAppScreenWidth - 2 * CONTENT_LEFT) / 2 +1;
    int contentHeight = contentWidth * kContentRateForTwo;
    CGRect leftContentRect = CGRectMake(0, 0, contentWidth, contentHeight);
    CGRect rightContentRect = CGRectMake(contentWidth, 0, contentWidth, contentHeight);
    
    _leftContentView = [[SNContentView alloc] initWithFrame:leftContentRect];
    _leftContentView.delegate = self;
    [self addSubview:_leftContentView];
    
    _rightContentView = [[SNContentView alloc] initWithFrame:rightContentRect];
    _rightContentView.delegate = self;
    [self addSubview:_rightContentView];
}

- (void)updateWithArray:(NSArray *)infoArray {
    for (int i = 0; i < 2; i++) {
        SNNewsIndividuationInfo *individuationInfo = [infoArray objectAtIndex:i];
        switch (i) {
            case 0: {
                [_leftContentView.publicImageView loadImageWithUrl:individuationInfo.pic defaultImage:[UIImage imageNamed:kThemeImgPlaceholder5]];
                _leftContentView.link = individuationInfo.link;
                _leftContentView.idString = individuationInfo.idString;
                break;
            }
            case 1: {
                [_rightContentView.publicImageView loadImageWithUrl:individuationInfo.pic defaultImage:[UIImage imageNamed:kThemeImgPlaceholder5]];
                _rightContentView.link = individuationInfo.link;
                _rightContentView.idString = individuationInfo.idString;
                break;
            }
            default:
                break;
        }
    }
}

- (void)updateTheme {
    _leftContentView.publicImageView.alpha = themeImageAlphaValue();
    _rightContentView.publicImageView.alpha = themeImageAlphaValue();
    [_leftContentView.publicImageView updateDefaultImage:[UIImage imageNamed:kThemeImgPlaceholder5]];
    [_rightContentView.publicImageView updateDefaultImage:[UIImage imageNamed:kThemeImgPlaceholder5]];
}

@end

#pragma mark -
#pragma mark SNContontViewForThree
@interface SNContontViewForThree : SNContainerView
@property (nonatomic, strong) NSMutableArray *contentViewArray;
@end

@implementation SNContontViewForThree

- (void)initSubViews {
    _contentViewArray = [[NSMutableArray alloc] init];
    int x = 0;
    int y = 0;
    int contentWidth = (kAppScreenWidth - 2 * CONTENT_LEFT) / 3 + 1;
    int contentHeight = contentWidth * kContentRateForThree;
    for (int i = 0; i < 3; i++) {
        SNContentView *contentView = [[SNContentView alloc] initWithFrame:CGRectMake(x, y, contentWidth, contentHeight)];
        contentView.delegate = self;
        [self addSubview:contentView];
        [_contentViewArray addObject:contentView];
        x += contentWidth;
    }
}

- (void)updateWithArray:(NSArray *)infoArray {
    for (int i = 0; i < [_contentViewArray count]; i++) {
        SNContentView *contentView = [_contentViewArray objectAtIndex:i];
        if (i < [infoArray count]) {
            SNNewsIndividuationInfo *individuationInfo = [infoArray objectAtIndex:i];
            [contentView.publicImageView loadImageWithUrl:individuationInfo.pic
                                             defaultImage:[UIImage imageNamed:kThemeImgPlaceholder3]];
            contentView.link = individuationInfo.link;
            contentView.idString = individuationInfo.idString;
        }
    }
}

- (void)updateTheme {
    for (int i = 0; i < [_contentViewArray count]; i++) {
        SNContentView *contentView = [_contentViewArray objectAtIndex:i];
        contentView.publicImageView.alpha = themeImageAlphaValue();
        [contentView.publicImageView updateDefaultImage:[UIImage imageNamed:kThemeImgPlaceholder3]];
    }
}

@end


#pragma mark -
#pragma mark SNContontViewForThree
@interface SNContontViewForFour : SNContainerView
@property (nonatomic, strong) NSMutableArray *contentViewArray;
@end

@implementation SNContontViewForFour

- (void)initSubViews {
    _contentViewArray = [[NSMutableArray alloc] init];
    int x = 0;
    int y = 0;
    int contentWidth = (kAppScreenWidth - 2 * CONTENT_LEFT) / 4 + 1;
    int contentHeight = contentWidth * kContentRateForFour;
    for (int i = 0; i < 4; i++) {
        SNContentView *contentView = [[SNContentView alloc] initWithFrame:CGRectMake(x, y, contentWidth, contentHeight)];
        contentView.delegate = self;
        [self addSubview:contentView];
        [_contentViewArray addObject:contentView];
        x += contentWidth;
    }
}

- (void)updateWithArray:(NSArray *)infoArray {
    for (int i = 0; i < [_contentViewArray count]; i++) {
        SNContentView *contentView = [_contentViewArray objectAtIndex:i];
        if (i < [infoArray count]) {
            SNNewsIndividuationInfo *individuationInfo = [infoArray objectAtIndex:i];
            [contentView.publicImageView loadImageWithUrl:individuationInfo.pic
                                             defaultImage:[UIImage imageNamed:kThemeImgPlaceholder4]];
            contentView.link = individuationInfo.link;
            contentView.idString = individuationInfo.idString;
        }
    }
}

- (void)updateTheme {
    for (int i = 0; i < [_contentViewArray count]; i++) {
        SNContentView *contentView = [_contentViewArray objectAtIndex:i];
        contentView.publicImageView.alpha = themeImageAlphaValue();
        [contentView.publicImageView updateDefaultImage:[UIImage imageNamed:kThemeImgPlaceholder4]];
    }
}

@end

#pragma mark -
#pragma mark SNRollingIndividuationCell

#define kNameViewTop (INDIVIDUATION_CELL_HEIGHT - 23)
#define kNameImageViewWidth     (18)
#define kNameImageViewHeight    (11)

@interface SNRollingIndividuationCell () {
    SNContainerView *contentView;
    UIView *nameContentView;
    SNImageView *nameImageView;
    UILabel *nameLabel;
}
@property (nonatomic, strong) SNNovelEntranceView *novelEntranceView;
@property (nonatomic, strong) UILabel *tip;
@end

@implementation SNRollingIndividuationCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *aItem = object;

    if ([aItem.news.title isEqualToString:[SNNovelUtilities shelfDataTitle]]) {
        return 100;
    }
    int cellHeight = INDIVIDUATION_CELL_HEIGHT;
    NSInteger count = aItem.news.individuation.individuationArray.count;
    if (count > 0) {
        int contentImageHeight = [SNRollingIndividuationCell getImageHeightWithCount:count];
        cellHeight = contentImageHeight + 34;
    }
    return cellHeight;
}

+ (int)getImageHeightWithCount:(NSInteger)imageCount {
    int contentImageWidth = (kAppScreenWidth - 2 * CONTENT_LEFT) / imageCount;
    int contentImageHeight;
    switch (imageCount) {
        case 1:
            contentImageHeight = contentImageWidth * kContentRateForOne;
            break;
        case 2:
            contentImageHeight = contentImageWidth * kContentRateForTwo;
            break;
        case 3:
            contentImageHeight = contentImageWidth * kContentRateForThree;
            break;
        case 4:
            contentImageHeight = contentImageWidth * kContentRateForFour;
            break;
        default:
            contentImageHeight = 60;
            break;
    }
    return contentImageHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = NO;
        [self initNameInfoView];
    }
    return self;
}

- (void)setObject:(id)object {
    NSInteger oldCnt = self.item.news.individuation.individuationArray.count;
    [super setObject:object];
    if ([self.item.news.title isEqualToString:[SNNovelUtilities shelfDataTitle]]) {
        if(!object) return;
        
        if (nameContentView) {
            nameContentView.hidden = YES;
        }
        if (contentView) {
            contentView.hidden = YES;
        }
        if (moreButton) {
            moreButton.hidden = YES;
        }
        
        if (!self.novelEntranceView) {
            self.novelEntranceView = [[SNNovelEntranceView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 80)];
            [self.contentView addSubview:_novelEntranceView];
        }
        if (!self.tip) {
            self.tip = [[UILabel alloc] initWithFrame:CGRectMake(0, _novelEntranceView.frame.size.height, 50, 20)];
            _tip.text = @"推荐";
            _tip.font = [UIFont systemFontOfSize:kThemeFontSizeC];
            _tip.textAlignment = NSTextAlignmentCenter;
            _tip.textColor = SNUICOLOR(kThemeText5Color);
            _tip.backgroundColor = SNUICOLOR(kThemeRed1Color);
            [self.contentView addSubview:_tip];
        }
        [self.contentView bringSubviewToFront:_novelEntranceView];
        [self.contentView bringSubviewToFront:_tip];
        _novelEntranceView.hidden = NO;
        _tip.hidden = NO;
        return;
    } else {
        if (_novelEntranceView) {
            _novelEntranceView.hidden = YES;
        }
        if (_tip) {
            _tip.hidden = YES;
        }
        if (nameContentView) {
            nameContentView.hidden = NO;
        }
        if (contentView) {
            contentView.hidden = NO;
        }
    }
    NSInteger cnt = self.item.news.individuation.individuationArray.count;
    if (oldCnt != cnt) {
        [contentView removeFromSuperview];
        if (cnt > 0) {
            [self initContentView];
        }
    } else {
        [contentView updateWithArray:self.item.news.individuation.individuationArray];
    }
    [self updateNameInfo];
}

- (void)updateTheme {
    [super updateTheme];
    [contentView updateTheme];
    nameLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    contentView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsContentBackgroundColor]];
    nameImageView.alpha = themeImageAlphaValue();
    
    if (_novelEntranceView) {
        [_novelEntranceView updateTheme];
        _tip.textColor = SNUICOLOR(kThemeText5Color);
        _tip.backgroundColor = SNUICOLOR(kThemeRed1Color);
    }
}

- (void)initContentView {
    NSInteger cnt = self.item.news.individuation.individuationArray.count;
    int contentHeight = [SNRollingIndividuationCell getImageHeightWithCount:cnt];
    CGRect contentRect = CGRectMake(CONTENT_LEFT, 7, kAppScreenWidth - 2 * CONTENT_LEFT, contentHeight);
    switch (cnt) {
        case 1:
            contentView = [[SNContontViewForOne alloc] initWithFrame:contentRect];
            break;
        case 2:
            contentView = [[SNContontViewForTwo alloc] initWithFrame:contentRect];
            break;
        case 3:
            contentView = [[SNContontViewForThree alloc] initWithFrame:contentRect];
            break;
        case 4:
            contentView = [[SNContontViewForFour alloc] initWithFrame:contentRect];
            break;
        default:
            contentView = [[SNContontViewForOne alloc] initWithFrame:contentRect];
            break;
    }
    [contentView initSubViews];
    contentView.delegate = self;
    contentView.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsContentBackgroundColor]];
    [self addSubview:contentView];
    
    [contentView updateWithArray:self.item.news.individuation.individuationArray];
}

- (void)initNameInfoView {
    nameContentView = [[UIView alloc] initWithFrame:CGRectMake(CONTENT_LEFT,kNameViewTop, 100, 20)];
    nameContentView.backgroundColor = [UIColor clearColor];
    [self addSubview:nameContentView];
    
    nameImageView = [[SNImageView alloc] initWithFrame:CGRectMake(0,4, kNameImageViewWidth, kNameImageViewHeight)];
    nameImageView.backgroundColor = [UIColor clearColor];
    nameImageView.hidden = YES;
    [nameContentView addSubview:nameImageView];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 100, 12)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textAlignment = NSTextAlignmentRight;
    nameLabel.font = [UIFont systemFontOfSizeType:UIFontSizeTypeB];
    nameLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    nameLabel.hidden = YES;
    [nameContentView addSubview:nameLabel];
    
    UIButton *openLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [openLinkButton setFrame:CGRectMake(0, 0, 100, 20)];
    [openLinkButton addTarget:self action:@selector(openLink) forControlEvents:UIControlEventTouchUpInside];
    [nameContentView addSubview:openLinkButton];
}

- (void)openLink {
    if (self.item.news.individuation.nameInfo.link.length > 0) {
        [SNUtility openProtocolUrl:self.item.news.individuation.nameInfo.link];
        [self reportPopularizeStatClickInfo:self.item.news.individuation.nameInfo.idString];
    }
}

- (void)updateNameInfo {
    nameContentView.right = [self.item hiddenMoreButton] ? kAppScreenWidth - CONTENT_LEFT : kAppScreenWidth - 40;
    if ([self.item.news.title isEqualToString:[SNNovelUtilities shelfDataTitle]]) {
        nameContentView.right = kAppScreenWidth - CONTENT_LEFT;
    }
    if (self.item.news.individuation.nameInfo.pic.length > 0) {
        nameImageView.hidden = NO;
        nameImageView.alpha = themeImageAlphaValue();
        nameLabel.hidden = YES;
        [nameImageView sd_setImageWithURL:[NSURL URLWithString:self.item.news.individuation.nameInfo.pic]
                      placeholderImage:nil
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                float scale = image.size.width / image.size.height;
                nameImageView.width =  kNameImageViewHeight*scale;
                nameImageView.right = 100;
            }
        }];
    } else {
        nameImageView.hidden = YES;
        nameLabel.hidden = NO;
        nameLabel.text = self.item.news.individuation.nameInfo.desc;
    }
    nameContentView.top = contentView.bottom +3;
}

/**
 * 上传搜狐新闻投放的个性化模版的曝光数据
 *
 *  @return 搜狐新闻投放的多app换量广告的曝光数据
 */
- (void)reportPopularizeStatExposureInfo {
    //当前频道id和统计模版id不一致返回
    if (![self.item.news.channelId isEqualToString:[[SNVideoAdContext sharedInstance] getObjFromIdForCDotGif]]) {
        return;
    }
    
    if (self.item.news.hasStatistics) {
        return;
    }
    
    SNStatExposureInfo *info = [[SNStatExposureInfo alloc] init];
    [self updateInfoWithData:info];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
    self.item.news.hasStatistics = YES;
}

- (void)reportPopularizeStatClickInfo:(NSString *)idString {
    SNStatClickInfo *info = [[SNStatClickInfo alloc] init];
    if (idString.length > 0) {
        info.adIDArray = @[idString];
    }
    info.objLabel = SNStatInfoUseTypeTimelinePopularize;
    info.token = item.news.token;
    info.objType = item.news.templateType;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
    info.objFromId = item.news.channelId;
    info.itemspaceid = item.news.newsAd.itemSpaceId;
    info.monitorkey = item.news.newsAd.monitorkey;
    info.gbcode = item.news.newsAd.gbcode;
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}

- (void)reportPopularizeStatUninterestInfo {
    SNStatUninterestedInfo *info = [[SNStatUninterestedInfo alloc] init];
    [self updateInfoWithData:info];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}

- (void)updateInfoWithData:(SNStatInfo *)info {
    NSMutableArray *appAdIDArray = [NSMutableArray array];
    for (SNNewsIndividuationNameInfo *indivInfo in item.news.individuation.individuationArray) {
        NSString *adID = indivInfo.idString;
        if (adID.length > 0) {
            [appAdIDArray addObject:adID];
        }
    }
    info.adIDArray = appAdIDArray;
    info.objLabel = SNStatInfoUseTypeTimelinePopularize;
    info.token = item.news.token;
    info.objType = item.news.templateType;
    info.objFrom = [[SNVideoAdContext sharedInstance] getObjFromForCDotGif];
    info.objFromId = item.news.channelId;
    info.itemspaceid = item.news.newsAd.itemSpaceId;
    info.monitorkey = item.news.newsAd.monitorkey;
    info.gbcode = item.news.newsAd.gbcode;
}

@end
