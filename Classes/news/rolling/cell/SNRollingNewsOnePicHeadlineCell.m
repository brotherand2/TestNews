//
//  SNRollingNewsOnePicHeadlineCell.m
//  sohunews
//
//  Created by wang yanchen on 13-1-15.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNConsts.h"

#import "SNRollingNewsOnePicHeadlineCell.h"
#import "SNRollingNews.h"
#import "UIColor+ColorUtils.h"
#import "SNRollingNewsTableItem.h"
#import "SNCommonNewsController.h"
#import "SNCommonNewsDatasource.h"
#import "NSCellLayout.h"
#import "UITableViewCell+ConfigureCell.h"

#define kCellTopInset                   (8)
#define kImageTopMargin                 ((18 / 2) + kCellTopInset)
#define kImageSideMargin                (20 / 2)

#define kTitleSideMargin                ((20 + 12) / 2)
#define kTitleBottomMargin              (10 / 2)
#define kTitleFontSize                  (32 / 2)

#define kVideoIconWidth                 (22 / 2)
#define kVideoIconLeftMargin            (20 / 2)
#define kVideoIconRightMargin           (10 / 2)
#define kVideoIconBottomMargin          (12 / 2)

#define kFocusImageRate                 (316.f / 640.f)

static CGFloat rowCellHeight = 0.0f;

@implementation SNRollingNewsOnePicHeadlineCell
@synthesize item = _item;
@synthesize currentTheme = _currentTheme;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    if (rowCellHeight == 0.0f) {
        rowCellHeight = roundf(kAppScreenWidth * kFocusImageRate + 7);
    }
    return rowCellHeight;
}

+ (CGFloat)cellHeight {
    if (rowCellHeight == 0.0f) {
        rowCellHeight = roundf(kAppScreenWidth * kFocusImageRate + 7);
    }
    return rowCellHeight;
} 

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
        self.contentView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
        [self initSubViews];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
}

- (BOOL)needsUpdateTheme {
    BOOL themeChanged = ![_currentTheme isEqualToString:[[SNThemeManager sharedThemeManager] currentTheme]];
    if (themeChanged) {
        self.currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
    }
    return themeChanged;
}

- (void)layoutSubviews {
    if ([self needsUpdateTheme]) {
        [self updateTheme];
    }
}

- (void)drawRect:(CGRect)rect {
    if (self.item.newsMode) {
        //分隔线
        [UIView drawCellSeperateLine:rect];
    }
}

- (void)setObject:(id)object {
    if (!object) {
        return;
    }
    
    BOOL isUpdate = [self needsUpdateTheme];
    if (self.item != object || isUpdate) {
        self.item = object;
        [self updateNews];
        
        int headlineViewTop = self.item.newsMode ? 9 : kImageTopMargin;
        _headlineView.top = headlineViewTop;
        _videoIcon.bottom = _headlineView.bottom - 3;
        [self setNeedsDisplay];
    }
    self.currentTheme = [[SNThemeManager sharedThemeManager] currentTheme];
}

- (void)updateNews {
    UIImage *defaultImage = [UIImage themeImageNamed:@"defaultImageBg.png"];
    NSString *imageUrl = [self headlinePicUrl];
    BOOL showVideo = [self headlineHasVideo];
    [_headlineView updateImageWithUrl1:imageUrl defaultImage:defaultImage showVideo:NO];
    _titleLabel.text = [self headlineTitle];
    _videoIcon.hidden = showVideo ? NO:YES;
    _titleLabel.left = showVideo ? CONTENT_LEFT + VIDEO_ICON_WIDTH + 7: CONTENT_LEFT;
}

- (void)initSubViews {
    [self initImageView];
    [self initTitleLabel];
    [self updateTheme];
}

- (void)initImageView {
    if (!_headlineView) {
        int focusImageHeight = kAppScreenWidth * kFocusImageRate;
        _headlineView = [[SNCellImageView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, focusImageHeight)];
        [_headlineView setDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder5]];
        [self addSubview:_headlineView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openNews:)];
        [_headlineView addGestureRecognizer:tap];
    }
}

- (void)initTitleLabel {
    if (!_titleMarkView) {
        _titleMarkView = [[UIImageView alloc] initWithImage:[UIImage themeImageNamed:@"news_headline_titlemark.png"]];
        _titleMarkView.frame = CGRectMake(0, _headlineView.height - 42, kAppScreenWidth, 42); // v5.2.0 old FOCUS_IMAGE_HEIGHT -42
        [_headlineView addSubview:_titleMarkView];
    }
    
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, _headlineView.bottom - kTitleBottomMargin - kThemeFontSizeD - 1, FOCUS_IMAGE_WIDTH, kThemeFontSizeD + 1)];
        _titleLabel.bottom = _headlineView.height - 13;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
        [_headlineView addSubview:_titleLabel];
    }
    
    if (!_videoIcon) {
        UIImage *videoImage = [UIImage imageNamed:@"icohome_focus_videosmall_v5.png"];
        _videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, _headlineView.bottom - VIDEO_ICON_WIDTH - 11, VIDEO_ICON_WIDTH, VIDEO_ICON_WIDTH)];
        _videoIcon.image = videoImage;
        _videoIcon.hidden = YES;
        [self addSubview:_videoIcon];
    }
}

- (void)updateTheme {
    [self needsUpdateTheme];
    self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    self.contentView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    [_headlineView updateTheme];
    
    UIImage *defaultImage = [UIImage themeImageNamed:kThemeImgPlaceholder5];
    NSString *imageUrl = [self headlinePicUrl];
    [_headlineView updateImageWithUrl:imageUrl defaultImage:defaultImage showVideo:NO];
    _videoIcon.image = [UIImage themeImageNamed:@"icohome_focus_videosmall_v5.png"];
    _headlineView.alpha = themeImageAlphaValue();
    [self setNeedsDisplay];
}

- (void)openNews:(UITapGestureRecognizer *)tap {
    [_item.controller cacheCellIndexPath:self];
    
    if (_item.news.newsType != nil &&
        [SNCommonNewsController supportContinuation:_item.news.newsType]) {
        NSMutableDictionary *dic = nil;
        if (_item.news && _item.dataSource) {
           dic  = [_item.dataSource getContentDictionary:_item.news];
        }
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:urlAction];
    } else if(_item.news.link.length > 0) {
        [SNUtility openProtocolUrl:_item.news.link];
    }
    
    //设置数据库已读
    NSString *newsId = self.item.news.newsId;
    NSString *channel = self.item.news.channelId;
    if (channel != nil && newsId != nil)
        [SNRollingNewsPublicManager saveReadNewsWithNewsId:newsId ChannelId:channel];
    //内存已读
    self.item.news.isRead = YES;
}

#pragma mark ---------- methods to override for subclass
- (NSString *)headlinePicUrl {
    if (_item.headlines.count > 0) {
        SNRollingNews *news = [self.item.headlines objectAtIndex:0];
        NSString *imageUrl = nil;
        if ([news.picUrls count]) {
            imageUrl = [news.picUrls objectAtIndex:0];
        }
        if (!imageUrl) {
            imageUrl = news.picUrl;
        }
        if (!imageUrl) {
            imageUrl = self.item.news.picUrl;
        }
        return imageUrl;
    } else {
        NSString *imageUrl = nil;
        if ([self.item.news.picUrls count]) {
            imageUrl = [self.item.news.picUrls objectAtIndex:0];
        }
        if (!imageUrl) {
            imageUrl = self.item.news.picUrl;
        }
        return imageUrl;
    }
    return nil;
}

- (NSString *)headlineTitle {
    if (_item.headlines.count > 0) {
        SNRollingNews *news = [self.item.headlines objectAtIndex:0];
        return news.title;
    }
    return nil;
}

- (BOOL)headlineHasVideo {
    if (_item.headlines.count > 0) {
        SNRollingNews *news = [self.item.headlines objectAtIndex:0];
        return [news.hasVideo isEqualToString:@"1"];
    }
    return NO;
}

@end
