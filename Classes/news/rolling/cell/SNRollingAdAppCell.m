//
//  SNRollingAdAppCell.m
//  sohunews
//
//  Created by lhp on 3/31/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "SNRollingAdAppCell.h"
#import "SNImageView.h"
#import "SNNewsAd+analytics.h"
#import "UIFont+Theme.h"

#define kPublicImageViewWidth ([[SNDevice sharedInstance] isPlus] ? (117 / 3.f) : (78 / 2.f))
#define kDownloadImageViewWidth ([[SNDevice sharedInstance] isPlus] ? (120 / 3.f) : (60 / 2.f))
#define kImageViewTop  14
#define kCommonSpace ([[SNDevice sharedInstance] isPlus] ? (42 / 3.f) : (28 / 2.f))
#define kIS_6_PLUS ([UIScreen mainScreen].bounds.size.width > 750 / 2.f)

typedef void(^AdClickReportBlock)();

@interface SNRollingAdAppContent : UIView {
    SNImageView *iconImageView;
    UILabel  *appNameLabel;
    UIButton *downloadBtn;
    NSString *downloadLink;
    NSString *h5Link;
    UIImageView *lineImageView;
}

@property (nonatomic, strong) NSString *downloadLink;
@property (nonatomic, strong) NSString *h5Link;
@property (nonatomic, copy) AdClickReportBlock adBlock;

@end

@implementation SNRollingAdAppContent
@synthesize downloadLink;
@synthesize h5Link;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubviews];
        [self updateTheme];
    }
    return self;
}

- (void)initSubviews {
    iconImageView = [[SNImageView alloc] initWithFrame:CGRectMake(kCommonSpace, kImageViewTop, kPublicImageViewWidth, kPublicImageViewWidth)];
    iconImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:iconImageView];
    
    int contentHeight = self.frame.size.height;
    int titleLeft = kCommonSpace + kPublicImageViewWidth + kCommonSpace;
    float labelWidth = self.width - 5 * kCommonSpace - kPublicImageViewWidth - kDownloadImageViewWidth;
    float fontSize;
    if (kIS_6_PLUS) {
        fontSize = [UIFont fontSizeWithType:UIFontSizeTypeD];
    } else {
        fontSize = [UIFont fontSizeWithType:UIFontSizeTypeC];
    }
    appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft, 0, labelWidth, (fontSize + 5) * 2)];
    appNameLabel.numberOfLines = 2;
    appNameLabel.font = [UIFont systemFontOfSize:fontSize];
    appNameLabel.backgroundColor = [UIColor clearColor];
    appNameLabel.centerY = contentHeight / 2;
    [self addSubview:appNameLabel];
    
    UIButton *h5LinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    h5LinkButton.frame = CGRectMake(0, 0, self.width - kDownloadImageViewWidth - 2 * kCommonSpace, self.height);
    [h5LinkButton addTarget:self
                    action:@selector(openH5Link)
          forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:h5LinkButton];
    
    lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 2 * kCommonSpace - kDownloadImageViewWidth, kCommonSpace, 1, self.height - 2 * kCommonSpace)];
    lineImageView.image = [UIImage imageNamed:@"news_common_line.png"];
    [self addSubview:lineImageView];
    // 下载图标
    downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    downloadBtn.bounds = CGRectMake(0, 0, kDownloadImageViewWidth, kDownloadImageViewWidth);
    downloadBtn.right = self.width - kCommonSpace;
    downloadBtn.centerY = contentHeight / 2;
    [downloadBtn addTarget:self
                    action:@selector(loadDownApp)
          forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:downloadBtn];
    UIButton *downloadMaskBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadMaskBtn setFrame:CGRectMake(0, 0, kDownloadImageViewWidth + 2 * kCommonSpace, self.height)];
    downloadMaskBtn.right = self.width;
    downloadMaskBtn.centerY = contentHeight / 2;
    [downloadMaskBtn addTarget:self
                        action:@selector(loadDownApp)
              forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:downloadMaskBtn];
}

- (void)setAdReport:(AdClickReportBlock)block {
    if (block) {
        _adBlock = [block copy];
    }
}

- (void)updateContentWithIcon:(NSString *)icon
                         Name:(NSString *)name
                      appLink:(NSString *)appLink
                     httpLink:(NSString *)httpLink {
    self.downloadLink = appLink;
    self.h5Link = httpLink;
    if (name.length > 0) {
        @autoreleasepool {
            NSMutableAttributedString *attributedName = [[NSMutableAttributedString alloc] initWithString:name];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 4;//行距
            style.lineBreakMode = NSLineBreakByTruncatingTail;
            [attributedName addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedName.length)];
            appNameLabel.attributedText = attributedName;
        }
    }
    [iconImageView loadImageWithUrl:icon
                       defaultImage:[UIImage imageNamed:kThemeImgPlaceholder1]];
}

- (void)openH5Link {
    if (self.h5Link.length > 0) {
        [SNUtility openProtocolUrl:self.h5Link];
        if (_adBlock) {
            _adBlock();
        }
    }
}

- (void)loadDownApp {
    if (self.downloadLink.length > 0) {
        [SNUtility openProtocolUrl:self.downloadLink];
        if (_adBlock) {
            _adBlock();
        }
    }
}

- (void)updateTheme {
    iconImageView.alpha = themeImageAlphaValue();
    appNameLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText1Color];
    self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg2Color];
    [iconImageView updateDefaultImage:[UIImage imageNamed:kThemeImgPlaceholder1]];
    [downloadBtn setImage:[UIImage imageNamed:@"icohome_download_v5.png"]
                 forState:UIControlStateNormal];
    [downloadBtn setImage:[UIImage imageNamed:@"icohome_downloadpress_v5.png"]
                 forState:UIControlStateHighlighted];
    lineImageView.image = [UIImage themeImageNamed:@"news_common_line.png"];
}

@end

@interface SNRollingAdAppCell() {
    SNRollingAdAppContent *appContentView;
}

@end

static CGFloat rowCellHeight = 0.0f;

@implementation SNRollingAdAppCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    if (rowCellHeight == 0.0) {
        rowCellHeight = roundf([[self class] getCellHeight]);
    }
    return rowCellHeight;
}

+ (int)getCellHeight {
    int imageHeight = 220 / 2;
    UIDevicePlatform plat = [[SNDevice sharedInstance] devicePlat];
    switch (plat) {
        case UIDevice6PlusiPhone:
            imageHeight = 351 / 3;
            break;
        case UIDevice6iPhone:
            imageHeight = 234 / 2;
            break;
        case UIDevice7PlusiPhone:
        case UIDevice8PlusiPhone:
            imageHeight = 351 / 3;
            break;
        case UIDevice7iPhone:
        case UIDevice8iPhone:
            imageHeight = 234 / 2;
            break;
        default:
            break;
    }
    return imageHeight;
}

+ (int)getImageHeight {
    int imageHeight = 120 / 2;
    UIDevicePlatform plat = [[SNDevice sharedInstance] devicePlat];
    switch (plat) {
        case UIDevice6PlusiPhone:
            imageHeight = 201 / 3;
            break;
        case UIDevice6iPhone:
            imageHeight = 134 / 2;
            break;
        case UIDevice7PlusiPhone:
        case UIDevice8PlusiPhone:
            imageHeight = 201 / 3;
            break;
        case UIDevice7iPhone:
        case UIDevice8iPhone:
            imageHeight = 134 / 2;
            break;
        default:
            break;
    }
    return imageHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = NO;
        [self initContentView];
    }
    return self;
}

- (void)initContentView {
    int contentHeight = [[self class] getImageHeight];
    CGRect contentRect = CGRectMake(CONTENT_LEFT, 15,
                                    kAppScreenWidth - 2 * CONTENT_LEFT,
                                    contentHeight);
    appContentView = [[SNRollingAdAppContent alloc] initWithFrame:contentRect];
    __weak SNRollingAdAppCell *blockSelf = self;
    [appContentView setAdReport:^{
        [blockSelf reportAdClick];
    }];
    [self addSubview:appContentView];
    
    UIButton *iconTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [iconTextBtn setFrame:CGRectMake(0, 0, 40, 30)];
    iconTextBtn.backgroundColor = [UIColor clearColor];
    iconTextBtn.top = appContentView.bottom;
    iconTextBtn.right = appContentView.right;
    [iconTextBtn addTarget:self
                    action:@selector(openH5LandUrl)
          forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:iconTextBtn];
}

- (void)openH5LandUrl {
    if (self.item.news.newsAd.h5Link.length > 0) {
        if (appContentView.adBlock) {
            appContentView.adBlock();
        }
        [SNUtility openProtocolUrl:self.item.news.newsAd.h5Link];
    }
}

- (void)updateContentView {
    [super updateContentView];
    [appContentView updateContentWithIcon:self.item.news.newsAd.picUrl
                                     Name:self.item.news.newsAd.title
                                  appLink:self.item.news.newsAd.appLink
                                 httpLink:self.item.news.newsAd.h5Link];
}

- (void)updateTheme {
    [super updateTheme];
    [appContentView updateTheme];
}

- (void)reportAdClick {
    [self.item.news.newsAd reportAdClick:self.item.news];
}

@end
