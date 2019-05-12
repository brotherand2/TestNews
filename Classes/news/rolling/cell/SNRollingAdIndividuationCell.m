//
//  SNRollingIndividuationCell.m
//  sohunews
//
//  Created by lhp on 7/29/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingAdIndividuationCell.h"
#import "SNImageView.h"
#import "SNThemeManager.h"
#import "SNRollingNews.h"
#import "SNNewsAd+analytics.h"
#import "UIFont+Theme.h"

#pragma mark -
#pragma mark SNContentView

@interface SNAdContentView : UIView
@property (nonatomic, strong) SNRollingNews *news;
@property (nonatomic, strong) SNImageView *publicImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, weak) id delegate;
@end


@implementation SNAdContentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initSubViews];
        
        UIButton *openLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [openLinkButton setFrame:CGRectMake(0, 0, 75, 60)];
        openLinkButton.centerX = self.width / 2;
        openLinkButton.centerY = self.height / 2;
        [openLinkButton addTarget:self action:@selector(openLink) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:openLinkButton];
    }
    return self;
}

- (void)initSubViews {
    _publicImageView = [[SNImageView alloc] initWithFrame:CGRectMake(0, 15, 32, 32)];
    _publicImageView.centerX = self.width / 2;
    _publicImageView.backgroundColor = [UIColor clearColor];
    _publicImageView.ignorePictureMode = YES;
    _publicImageView.alpha = themeImageAlphaValue();
    [self addSubview:_publicImageView];
    
    //添加个TitleLabel
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _publicImageView.height + _publicImageView.origin.y + 7, self.width, kThemeFontSizeC + 2)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = SNUICOLOR(kThemeTextRIColor);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    [self addSubview:_titleLabel];
}

- (void)openLink {
    if (self.news.link.length > 0) {
        [SNUtility openProtocolUrl:self.news.link context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:AdvertisementWebViewType], kUniversalWebViewType, nil]];
        //点击上报
        [self.news.newsAd reportAdClick:self.news];
    }
}

@end

#pragma mark -
#pragma mark SNContainerView
@interface SNAdContainerView : UIView
- (void)initSubViews;
- (void)updateWithArray:(NSArray *)infoArray;

@property (nonatomic, strong) NSMutableArray *contentViewArray;
@property (nonatomic, weak) id delegate;
@end

@implementation SNAdContainerView

- (void)initSubViews {
    _contentViewArray = [[NSMutableArray alloc] init];
}

- (void)updateWithArray:(NSArray *)infoArray {
    for (int i = 0; i < [infoArray count]; i++) {
        SNRollingNews *news = [infoArray objectAtIndex:i];
        if (i < [_contentViewArray count]) {
            SNAdContentView *contentView = [_contentViewArray objectAtIndex:i];
            contentView.news = news;
            [contentView.publicImageView loadImageWithUrl:news.picUrl
                                             defaultImage:[UIImage imageNamed:kThemeImgPlaceholder4]];
            contentView.titleLabel.text = news.title;
        }
    }
}

- (void)updateTheme {
    for (int i = 0; i < [_contentViewArray count]; i++) {
        SNAdContentView *contentView = [_contentViewArray objectAtIndex:i];
        contentView.publicImageView.alpha = themeImageAlphaValue();
        contentView.titleLabel.textColor = SNUICOLOR(kThemeTextRIColor);
    }
}

@end

#pragma mark -
#pragma mark SNContontViewForOne
@interface SNAdContontViewForOne : SNAdContainerView {
    SNAdContentView *contentView;
}
@end

@implementation SNAdContontViewForOne

- (void)initSubViews {
    [super initSubViews];
    int contentWidth = kAppScreenWidth;
    int contentHeight = self.height;
    CGRect contentRect = CGRectMake(0, 0, contentWidth, contentHeight);
    contentView = [[SNAdContentView alloc] initWithFrame:contentRect];
    contentView.delegate = self;
    [self.contentViewArray addObject:contentView];
    [self addSubview:contentView];
}

@end

#pragma mark -
#pragma mark SNContontViewForTwo
@interface SNAdContontViewForTwo : SNAdContainerView
@end

@implementation SNAdContontViewForTwo

- (void)initSubViews {
    [super initSubViews];
    int x = 0;
    int y = 0;
    int contentWidth = kAppScreenWidth / 2;
    int contentHeight = self.height;
    for (int i = 0; i < 2; i++) {
        SNAdContentView *contentView = [[SNAdContentView alloc] initWithFrame:CGRectMake(x, y, contentWidth, contentHeight)];
        contentView.delegate = self;
        [self addSubview:contentView];
        [self.contentViewArray addObject:contentView];
        x += contentWidth;
    }
}

@end

#pragma mark -
#pragma mark SNContontViewForThree
@interface SNAdContontViewForThree : SNAdContainerView

@end

@implementation SNAdContontViewForThree

- (void)initSubViews {
    [super initSubViews];
    int x = 0;
    int y = 0;
    int contentWidth = kAppScreenWidth / 3;
    int contentHeight = self.height;
    for (int i = 0; i < 3; i++) {
        SNAdContentView *contentView = [[SNAdContentView alloc] initWithFrame:CGRectMake(x, y, contentWidth, contentHeight)];
        contentView.delegate = self;
        [self addSubview:contentView];
        [self.contentViewArray addObject:contentView];
        x += contentWidth;
    }
}

@end

#pragma mark -
#pragma mark SNContontViewForThree
@interface SNAdContontViewForFour : SNAdContainerView
@property (nonatomic, strong) NSMutableArray *contentViewArray;
@end

@implementation SNAdContontViewForFour

- (void)initSubViews {
    [super initSubViews];
    int x = 0;
    int y = 0;
    int contentWidth = kAppScreenWidth / 4;
    int contentHeight = self.height;
    for (int i = 0; i < 4; i++) {
        SNAdContentView *contentView = [[SNAdContentView alloc] initWithFrame:CGRectMake(x, y, contentWidth, contentHeight)];
        contentView.delegate = self;
        [self addSubview:contentView];
        [self.contentViewArray addObject:contentView];
        x += contentWidth;
    }
}

@end

#pragma mark -
#pragma mark SNRollingIndividuationCell

#define SNRollingAdIndividuationCellHeight (30 / 2 + 38 / 2 + 62 / 2 + 14 / 2 + kThemeFontSizeC + 2)

@interface SNRollingAdIndividuationCell () {
    SNAdContainerView *_contentView;
}

@end

@implementation SNRollingAdIndividuationCell

+ (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object {
    //根据设计图纸计算高度
    return SNRollingAdIndividuationCellHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = NO;
    }
    return self;
}

- (void)setObject:(id)object {
    if (object == nil) {
        return;
    }
    if (self.item != object) {
        self.item = object;
        [self initContentView];
    }
}

- (void)updateTheme {
    [super updateTheme];
    [_contentView updateTheme];
}

- (void)initContentView {
    SNRollingNewsTableItem *curItem = self.item;
    NSArray *curAdData = [NSArray arrayWithArray:curItem.news.topAdNews];
    NSInteger cnt = curAdData.count;
    if (_contentView &&
        _contentView.contentViewArray.count != curAdData.count) {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    if (_contentView == nil) {
        CGRect contentRect = CGRectMake(0, 0, kAppScreenWidth, SNRollingAdIndividuationCellHeight);
        switch (cnt) {
            case 1:
                _contentView = [[SNAdContontViewForOne alloc] initWithFrame:contentRect];
                break;
            case 2:
                _contentView = [[SNAdContontViewForTwo alloc] initWithFrame:contentRect];
                break;
            case 3:
                _contentView = [[SNAdContontViewForThree alloc] initWithFrame:contentRect];
                break;
            case 4:
                _contentView = [[SNAdContontViewForFour alloc] initWithFrame:contentRect];
                break;
            default:
                _contentView = [[SNAdContontViewForOne alloc] initWithFrame:contentRect];
                break;
        }
        [_contentView initSubViews];
        _contentView.delegate = self;
        [self addSubview:_contentView];
    }
    
    [_contentView updateWithArray:curAdData];
}

@end
