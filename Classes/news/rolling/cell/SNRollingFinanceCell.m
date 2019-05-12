//
//  SNRollingFinanceCell.m
//  sohunews
//
//  Created by lhp on 5/8/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingFinanceCell.h"

@interface SNFinanceMarkView : UIView {
    NSString *timeString;
    NSString *sponsorships;
}

@property (nonatomic, strong) NSString *timeString;
@property (nonatomic, strong) NSString *sponsorships;

@end

@implementation SNFinanceMarkView
@synthesize timeString;
@synthesize sponsorships;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self drawSponsorshipsWithRect:rect];
    [self drawTimeWithRect:rect];
}

- (void)drawSponsorshipsWithRect:(CGRect)rect {
    int sponsorships_x =  kAppScreenWidth - CONTENT_LEFT;
    UIColor *timeColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color];
    [timeColor set];
    
    if (self.sponsorships.length > 0) {
        float yPos = 85;
        CGSize textSize = [self.sponsorships sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
        int textWidth = MIN(textSize.width, 60);
        CGRect textRect = CGRectMake(sponsorships_x - textWidth, yPos, textWidth, kThemeFontSizeB+2);
        [self.sponsorships drawInRect:textRect
                             withFont:[UIFont systemFontOfSize:kThemeFontSizeB]
                        lineBreakMode:NSLineBreakByTruncatingTail
                            alignment:NSTextAlignmentLeft];
    }
}

- (void)drawTimeWithRect:(CGRect)rect {
    UIColor *timeColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText4Color];
    [timeColor set];
    
    int markText_x = CONTENT_LEFT;
    if (self.timeString.length > 0) {
        float yPos = 85;
        CGRect textRect = CGRectMake(markText_x, yPos, LABLETEXT_WIDTH, kThemeFontSizeB+2);
        [self.timeString drawInRect:textRect
                            withFont:[UIFont digitAndLetterFontOfSize:kThemeFontSizeB]
                       lineBreakMode:NSLineBreakByTruncatingTail
                           alignment:NSTextAlignmentLeft];
    }
}

@end

@interface SNFinanceLabel : UILabel
@end

@implementation SNFinanceLabel

- (id)initWithFrame:(CGRect)frame
               font:(UIFont *)font
          textColor:(UIColor *)textColor
      textAlignment:(NSTextAlignment)textAlignment {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.font = font;
        self.backgroundColor = [UIColor clearColor];
        self.textColor = textColor;
        self.textAlignment = textAlignment;
    }
    return self;
}

@end

@interface SNFinanceContentView : UIView {
    SNFinanceLabel *financeExponentLabel;               //财经指数
    SNFinanceLabel *financeNameLabel;                   //交易所名称
    SNFinanceLabel *financeValueLabel;                  //股票增长值
    SNFinanceLabel *financePercentLabel;                //股票涨幅百分比
    UIView *backGroundView;
    NSString *link;
    NSString *position;
    NSString *idString;
    NSMutableDictionary *parameters;
    SNCCPVPage page;
    UIButton *_remindButton;
}
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *position;
@property (nonatomic, strong) NSString *idString;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, assign) SNCCPVPage page;
@property (nonatomic, assign) BOOL hideNum;

@end

@implementation SNFinanceContentView
@synthesize link;
@synthesize position;
@synthesize idString;
@synthesize parameters;
@synthesize page;

- (id)initWithFrame:(CGRect)frame index:(NSInteger)index {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsFinanceBackgroundColor]];
        [self initFinanceLabels];
        
        UIButton *openLinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [openLinkButton setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [openLinkButton addTarget:self action:@selector(openLink:) forControlEvents:UIControlEventTouchUpInside];
        openLinkButton.tag = index;
        [self addSubview:openLinkButton];
        
        [SNNotificationManager addObserver:self selector:@selector(updateBubbleStatus) name:kUpdateBubbleStatusNotification object:nil];
    }
    return self;
}

- (void)initFinanceLabels {
    backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 18, self.width, 18)];
    [self addSubview:backGroundView];
    
    financeExponentLabel = [[SNFinanceLabel alloc] initWithFrame:CGRectMake(5, 10, 110, 21) font:[UIFont systemFontOfSize:20.0f] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
    [self addSubview:financeExponentLabel];
    
    financeNameLabel = [[SNFinanceLabel alloc] initWithFrame:CGRectMake(5, self.height - 17, 120, 15) font:[UIFont systemFontOfSize:kThemeFontSizeB] textColor:[UIColor whiteColor] textAlignment:NSTextAlignmentLeft];
    [self addSubview:financeNameLabel];
    
    financeValueLabel = [[SNFinanceLabel alloc] initWithFrame:CGRectMake(5, financeExponentLabel.bottom + 3, 50, 14) font:[UIFont systemFontOfSize:kThemeFontSizeA] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
    [self addSubview:financeValueLabel];
    
    financePercentLabel = [[SNFinanceLabel alloc] initWithFrame:CGRectMake(5 + 50 + 5, financeExponentLabel.bottom + 3, 50, 14) font:[UIFont systemFontOfSize:kThemeFontSizeA] textColor:[UIColor blackColor] textAlignment:NSTextAlignmentLeft];
    [self addSubview:financePercentLabel];
    
    _remindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _remindButton.frame = CGRectMake(0, 0, 35.0/2, 35.0/2);
    [_remindButton setBackgroundImage:[UIImage imageNamed:@"ico_hongdian_v5.png"] forState:UIControlStateNormal];
    _remindButton.hidden = YES;
    [self addSubview:_remindButton];
}

- (void)updateFinanceContentWithExponent:(NSString *)exponentString
                              finaceName:(NSString *)nameString
                             finaceValue:(NSString *)valueString
                           finacePercent:(NSString *)percentString
                               fontColor:(UIColor *)color
                                    link:(NSString *)linkString {
    financeExponentLabel.text = exponentString;
    financeNameLabel.text = nameString;
    financeValueLabel.text = valueString;
    financePercentLabel.text = percentString;
    financeValueLabel.textColor = color;
    financePercentLabel.textColor = color;
    backGroundView.backgroundColor = color;
    self.link = linkString;
    _remindButton.hidden = YES;
    
    [self updateTheme];
}

- (void)updateFinanceEntryContentWithExponent:(NSString *)exponentString
                              finaceName:(NSString *)nameString
                                    fontColor:(UIColor *)color
                                    link:(NSString *)linkString
                               unreadMsgCount:(NSString *)unreadMsgCount {
    CGSize labelSize =[@"搜狐新闻" getTextSizeWithFontSize:kThemeFontSizeE];
    financeExponentLabel.frame = CGRectMake(5.0, 12.0, labelSize.width, labelSize.height);
    financeExponentLabel.text = exponentString;
    financeExponentLabel.textColor = SNUICOLOR(kThemeText1Color);
    financeExponentLabel.font = [UIFont systemFontOfSize:kThemeFontSizeE];
    financeNameLabel.text = nameString;
    financeValueLabel.text = nil;
    financePercentLabel.text = nil;
    financeValueLabel.textColor = color;
    financePercentLabel.textColor = color;
    backGroundView.backgroundColor = color;
    self.link = linkString;
    if (self.hideNum) {
        unreadMsgCount = nil;
    }
    if ([unreadMsgCount integerValue] > 0) {
        _remindButton.hidden = NO;
        _remindButton.center = financeExponentLabel.center;
        if (kAppScreenWidth == 320.0) {
            _remindButton.left = financeExponentLabel.right + 2.0;
        } else {
            _remindButton.left = financeExponentLabel.right + 9.0;
        }
        [_remindButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_remindButton.titleLabel setFont:[UIFont systemFontOfSize:kThemeFontSizeB]];
        if ([unreadMsgCount integerValue] > 99) {
            [_remindButton setTitle:@"..." forState:UIControlStateNormal];
        } else {
            [_remindButton setTitle:unreadMsgCount forState:UIControlStateNormal];
        }
    } else {
        _remindButton.hidden = YES;
    }
    
    [self updateTheme];
}


- (void)updateTheme {
    self.alpha = themeImageAlphaValue();
    self.backgroundColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kRollingNewsFinanceBackgroundColor]];
    financeExponentLabel.textColor = SNUICOLOR(kRollingNewsCellTitleUnreadColor);
    [_remindButton setBackgroundImage:[UIImage imageNamed:@"ico_hongdian_v5.png"] forState:UIControlStateNormal];
}

- (void)updateBubbleStatus {
    self.hideNum = YES;
    _remindButton.hidden = YES;
}

- (void)openLink:(id)sender {
    if (self.link.length >0) {
        UIButton *button = (UIButton *)sender;
        if (button.tag == 2) {
            //智能报盘
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kClickIntelligentOfferKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [SNNotificationManager postNotificationName:kUpdateBubbleStatusNotification object:nil];
        }
        [SNUtility openProtocolUrl:self.link];
        
        if (self.position.length > 0) {
            [self.parameters setObject:self.position forKey:kPosition];
        }
        if (self.idString) {
            [self.parameters setObject:self.idString forKey:kId];
        }
        //CC统计
        SNCCPVPage toPage = [SNUtility parseLinkPage:self.link];
        NSString *toLink = (toPage == sohu_http_web) ? [SNAPI rootScheme] : self.link;
        SNUserTrack *userTrack= [SNUserTrack trackWithPage:page link2:nil];
        SNUserTrack *toUserTrack = [SNUserTrack trackWithPage:toPage link2:toLink];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [toUserTrack toFormatString], f_template];
        if (self.parameters) {
            paramString = [self.parameters appendParamToUrlString:paramString];
        }
        [SNNewsReport reportADotGifWithTrack:paramString];
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

@end

@interface SNRollingFinanceCell ()

@end

#define kFinanceContentViewHeight   (140 / 2)

@implementation SNRollingFinanceCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    return FINANCE_CELL_HEIGHT + 5;
}

+ (CGFloat)getTitleWidth {
    //财经不显示标题
    int titleWidth = 0;
    return titleWidth;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = NO;
        [self initFinanceContent];
    }
    return self;
}

- (void)initFinanceContent {
    markView = [[SNFinanceMarkView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, FINANCE_CELL_HEIGHT + 5)];
    [self addSubview:markView];
    
    int contentWidth = (kAppScreenWidth - 2*CONTENT_LEFT) / 3;
    CGRect leftContentRect = CGRectMake(CONTENT_LEFT, IMAGE_TOP, contentWidth, kFinanceContentViewHeight);
    CGRect rightContentRect = CGRectMake(CONTENT_LEFT+contentWidth+1, IMAGE_TOP, contentWidth, kFinanceContentViewHeight);
    CGRect financeEntryContentRect = CGRectMake(CONTENT_LEFT+contentWidth * 2 + 2, IMAGE_TOP, contentWidth, kFinanceContentViewHeight);
    
    leftContentView = [[SNFinanceContentView alloc] initWithFrame:leftContentRect index:0];
    [self addSubview:leftContentView];
    rightContentView = [[SNFinanceContentView alloc] initWithFrame:rightContentRect index:1];
    [self addSubview:rightContentView];
    financeEntryContentView = [[SNFinanceContentView alloc] initWithFrame:financeEntryContentRect index:2];
    [self addSubview:financeEntryContentView];
}

- (void)updateContentView {
    [super updateContentView];
    [self updateFinanceContentView];
}

- (void)updateTheme {
    [super updateTheme];
    [leftContentView updateTheme];
    [rightContentView updateTheme];
    [financeEntryContentView updateTheme];
    [markView setNeedsDisplay];
}

- (void)updateFinanceContentView {
    markView.timeString = self.item.news.time;
    markView.sponsorships = self.item.news.sponsorshipsObject.title;
    [markView setNeedsDisplay];
    
    UIColor *leftColor = [UIColor colorFromString:self.item.news.leftFinance.colour];
    UIColor *rightColor = [UIColor colorFromString:self.item.news.rightFinance.colour];
    UIColor *entryColor = [UIColor colorFromString:self.item.news.entryFinance.colour];
    [leftContentView updateFinanceContentWithExponent:self.item.news.leftFinance.price finaceName:self.item.news.leftFinance.name finaceValue:self.item.news.leftFinance.rate finacePercent:self.item.news.leftFinance.diff fontColor:leftColor link:self.item.news.leftFinance.link];
    
    [rightContentView updateFinanceContentWithExponent:self.item.news.rightFinance.price finaceName:self.item.news.rightFinance.name finaceValue:self.item.news.rightFinance.rate finacePercent:self.item.news.rightFinance.diff fontColor:rightColor link:self.item.news.rightFinance.link];
    
    [financeEntryContentView updateFinanceEntryContentWithExponent:self.item.news.entryFinance.shortTitle finaceName:self.item.news.entryFinance.name fontColor:entryColor link:self.item.news.entryFinance.link unreadMsgCount:self.item.news.financeUnreadMsg];
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
    leftContentView.idString = self.item.news.leftFinance.idString;
    leftContentView.alpha = themeImageAlphaValue();

    rightContentView.parameters = parameters;
    rightContentView.page = page;
    rightContentView.position = @"2";
    rightContentView.idString = self.item.news.rightFinance.idString;
    rightContentView.alpha = themeImageAlphaValue();
    
    financeEntryContentView.parameters = parameters;
    financeEntryContentView.page = page;
    financeEntryContentView.position = @"3";
    financeEntryContentView.idString = self.item.news.entryFinance.idString;
    financeEntryContentView.alpha = themeImageAlphaValue();

    moreButton.hidden = YES;
    [self setNeedsDisplay];
}

@end
