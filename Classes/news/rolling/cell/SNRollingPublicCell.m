//
//  SNRollingPublicCell.m
//  sohunews
//
//  Created by lhp on 5/9/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingPublicCell.h"
#import "NSCellLayout.h"
#import "SNImageView.h"

@interface SNPublicContentView : UIView {
    SNCCPVPage page;
    SNImageView *publicImageView;
    UILabel *titleLabel;
    UILabel *abstractLabel;
    NSString *link;
    NSString *position;
    NSString *idString;
    NSMutableDictionary *parameters;
}
@property (nonatomic, assign) SNCCPVPage page;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *position;
@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSMutableDictionary *parameters;

@end

#define kPublicImageViewWidth 50
#define kAbstractFont   10.0f
#define kPage       @"page"

@implementation SNPublicContentView
@synthesize page;
@synthesize link;
@synthesize position;
@synthesize idString;
@synthesize parameters;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initSubViews];
        
        UIButton *openLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [openLinkButton setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [openLinkButton addTarget:self action:@selector(openLink) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:openLinkButton];
    }
    return self;
}

- (void)initSubViews {
    int titleLeft = CONTENT_LEFT + kPublicImageViewWidth + 10;
    int titleWidth = self.width - CONTENT_LEFT - kPublicImageViewWidth - 15;
    
    publicImageView = [[SNImageView alloc] initWithFrame:CGRectMake(CONTENT_LEFT, 0, kPublicImageViewWidth, kPublicImageViewWidth)];
    publicImageView.backgroundColor = [UIColor clearColor];
    publicImageView.alpha = themeImageAlphaValue();
    [self addSubview:publicImageView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft, 5, titleWidth, kThemeFontSizeD+2)];
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellTitleUnreadColor]];
    [self addSubview:titleLabel];
    
    abstractLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLeft, 25, titleWidth, 28)];
    abstractLabel.font = [UIFont systemFontOfSize:kAbstractFont];
    abstractLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellDetailTextUnreadColor]];
    abstractLabel.numberOfLines = 2;
    abstractLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:abstractLabel];
}

- (void)updateTheme {
    publicImageView.alpha = themeImageAlphaValue();
    [publicImageView updateDefaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder4]];
    titleLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellTitleUnreadColor]];
    abstractLabel.textColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsCellDetailTextUnreadColor]];
}

- (void)updatePublicContentWithTitle:(NSString *)title
                      abstractString:(NSString *)abstractString
                            imageUrl:(NSString *)imageUrl
                                link:(NSString *)linkString {
    titleLabel.text = title;
    abstractLabel.text = abstractString;
    self.link = linkString;
    [publicImageView loadImageWithUrl:imageUrl
                         defaultImage:[UIImage themeImageNamed:kThemeImgPlaceholder4]];
    [self updateTheme];
}

- (void)openLink {
    if (self.link.length > 0) {
        [SNUtility openProtocolUrl:self.link];
        
        if (self.position.length > 0) {
            [self.parameters setObject:self.position forKey:kPosition];
        }
        if (self.idString.length > 0) {
            [self.parameters setObject:self.idString forKey:kId];
        }
        //CC统计
        SNCCPVPage toPage = [SNUtility parseLinkPage:self.link];
        NSString *toLink = (toPage == sohu_http_web) ? [SNAPI rootScheme] : self.link;
        SNUserTrack *userTrack= [SNUserTrack trackWithPage:page link2:nil];
        SNUserTrack *toUserTrack = [SNUserTrack trackWithPage:toPage link2:toLink];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [toUserTrack toFormatString], f_template];
        if (self.parameters) {
            paramString = [parameters appendParamToUrlString:paramString];
        }
        [SNNewsReport reportADotGifWithTrack:paramString];
    }
}

@end


@interface SNRollingPublicCell () {
    SNPublicContentView *leftContentView;
    SNPublicContentView *rightContentView;
    UIImageView *lineImageView;
    BOOL isFristNews;
}
@end

#define kPublicContentViewWidth     160
#define kPublicContentViewHeight    50
#define kPublicContentViewTOP       7

@implementation SNRollingPublicCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    return PUBLIC_CELL_HEIGHT;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        [self initContentView];
        self.showSlectedBg = NO;
    }
    return self;
}

- (void)initContentView {
    int contentWidth = kAppScreenWidth / 2;
    CGRect leftContentRect = CGRectMake(0, kPublicContentViewTOP, contentWidth, kPublicContentViewHeight);
    CGRect rightContentRect = CGRectMake(contentWidth, kPublicContentViewTOP, contentWidth, kPublicContentViewHeight);
    leftContentView = [[SNPublicContentView alloc] initWithFrame:leftContentRect];
    [self addSubview:leftContentView];
    rightContentView = [[SNPublicContentView alloc] initWithFrame:rightContentRect];
    [self addSubview:rightContentView];
    
    lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(contentWidth, 6, 1, 48)];
    lineImageView.image = [UIImage imageNamed:@"news_common_line.png"];
    [self addSubview:lineImageView];
}

- (void)updateContentView {
    [super updateContentView];
    [self updatePublicContent];
}

- (void)updateTheme {
    [super updateTheme];
    [leftContentView updateTheme];
    [rightContentView updateTheme];
    lineImageView.image = [UIImage themeImageNamed:@"news_common_line.png"];
}

- (void)updatePublicContent {
    [leftContentView updatePublicContentWithTitle:self.item.news.leftLottery.title abstractString:self.item.news.leftLottery.description imageUrl:self.item.news.leftLottery.pic link:self.item.news.leftLottery.link];
    
    [rightContentView updatePublicContentWithTitle:self.item.news.rightLottery.title abstractString:self.item.news.rightLottery.description imageUrl:self.item.news.rightLottery.pic link:self.item.news.rightLottery.link];
    
    moreButton.hidden = YES;
    
    //CC统计数据
    SNCCPVPage page = [self.item getCurrentPage];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (self.item.news.templateType) {
        [parameters setObject:self.item.news.templateType forKey:kTemplateType];
    }
    if (self.item.news.channelId) {
        [parameters setObject:self.item.news.channelId forKey:kChannelId];
    }
    leftContentView.parameters = parameters;
    leftContentView.page = page;
    leftContentView.position = @"1";
    leftContentView.idString = self.item.news.leftLottery.idString;
    rightContentView.parameters = parameters;
    rightContentView.page = page;
    rightContentView.position = @"2";
    rightContentView.idString = self.item.news.rightLottery.idString;
    
    lineImageView.image = [UIImage themeImageNamed:@"news_common_line.png"];
}

@end
