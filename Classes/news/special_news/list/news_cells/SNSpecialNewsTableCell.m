//
//  SNSpecialNewsTableCell.m
//  sohunews
//
//  Created by handy wang on 7/5/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNConsts.h"
#import "SNSpecialNewsTableCell.h"
#import "UIColor+ColorUtils.h"
#import "SNSpecialNewsTableItem.h"
#import "SNSpecialHeadlineNewsTableItem.h"
#import "SNDBManager.h"
#import "SNDatabase_SpecialNewsList.h"
#import "SNThemeManager.h"
#import "SNCommonNewsController.h"
#import "SNCommonNewsDatasource.h"
#import "UIFontAdditions.h"
#import "NSCellLayout.h"
#import "NSAttributedString+Attributes.h"
#import "SNSpecialNewsCellBackView.h"

#define iconTopPadding                               ([[SNDevice sharedInstance] isPlus]?(18/3):(20/2))
#define horizontalPadding                           (20/2)
#define textWidth                                   (620/2)
#define subtitleHeight                              (ABSTRACT_LINEHEIGHT * 2)
#define VIDEOPLAY_SIZE  20

@interface SNSpecialNewsTableCell()

@property(nonatomic, strong, readwrite)SNLabel *abstractLabel;
@property(nonatomic, strong, readwrite)SNWebImageView *iconImageView;
@property(nonatomic, strong, readwrite)UIImageView *mask;

@end


@implementation SNSpecialNewsTableCell

@synthesize abstractLabel = _abstractLabel;
@synthesize iconImageView = _iconImageView;
@synthesize mask = _mask;
@synthesize videoMaskView = _videoMaskView;
@synthesize voteMaskView = _voteMaskView;
@synthesize backView = _backView;

#pragma mark - Lifecycle methods


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    }
    return self;
}
#pragma mark - Public methods implementation

- (void)setAlreadyReadStyle {
    self.textLabel.textColor = SNUICOLOR(kRollingNewsCellTitleReadColor);
    self.abstractLabel.textColor = SNUICOLOR(kRollingNewsCellDetailTextReadColor);
}

- (void)setUnReadStyle {
    self.textLabel.textColor = SNUICOLOR(kRollingNewsCellTitleUnreadColor);
    _abstractLabel.textColor = SNUICOLOR(kRollingNewsCellDetailTextUnreadColor);
}

- (void)setReadStyleByMemory {
    SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
    BOOL isRead = [[SNDBManager currentDataBase] checkSpecialNewsReadOrNotByTermId:snItem.news.termId newsId:snItem.news.newsId];
    snItem.news.isRead = isRead ? @"1" : @"0";
    if ([kSNSpecialNewsIsRead_YES isEqualToString:snItem.news.isRead]) {
        [self setAlreadyReadStyle];
    } else {
        [self setUnReadStyle];
    }
    [self setNeedsDisplay];
}

- (void)updateTheme {
    [super updateTheme];
    self.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg3Color];
    [_backView setNeedsDisplay];
    
    if (_iconImageView) {
        _iconImageView.alpha = themeImageAlphaValue();
        
        _iconImageView.defaultImage = [UIImage imageNamed:@"rolling_default_image.png"];
        [self.iconImageView unsetImage];
        SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
        self.iconImageView.urlPath = snItem.imageURL;
        
        _videoMaskView.alpha = themeImageAlphaValue();
        _videoMaskView.image = [UIImage themeImageNamed:@"icohome_videosmall_v5.png"];
        _voteMaskView.image = [UIImage themeImageNamed:@"news_vote_icon.png"];
    }
}

#pragma mark - Override methods implementation

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
	return DEFAULT_CELL_HEITHT + 6;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
    
//    if ([self isMemberOfClass:[SNSpecialNewsTableCell class]]) {
//        [self drawTitleAndAbstract];
//    }
    
	[UIView drawCellSeperateLine:rect];
}

- (SNLabel *)abstractLabel {
    if (!_abstractLabel) {
        _abstractLabel = [[SNLabel alloc] initWithFrame:CGRectMake(iconTopPadding, self.textLabel.bottom + 10/2, textWidth - 20/2, subtitleHeight)];
        _abstractLabel.font = [UIFont systemFontOfSize:12];
        [_abstractLabel setLineHeight:ABSTRACT_LINEHEIGHT];
        [self addSubview:_abstractLabel];
    }
    return _abstractLabel;
}

- (SNSpecialNewsCellBackView *)backView
{
    if (!_backView) {
        _backView = [[SNSpecialNewsCellBackView alloc] init];
        _backView.frame = CGRectMake(0, 0, kAppScreenWidth, DEFAULT_CELL_HEITHT + 6);
        [self addSubview:_backView];
    }
    
    SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
    _backView.item = snItem;
    
    return _backView;
}

- (SNWebImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[SNWebImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.defaultImage = [UIImage imageNamed:@"rolling_default_image.png"];
        _iconImageView.clipsToBounds = YES;
        [self addSubview:_iconImageView];
    }
    return _iconImageView;
}

- (UIImageView *)videoMaskView {
    if (!_videoMaskView) {
        _videoMaskView = [[UIImageView alloc] init];
        _videoMaskView.contentMode = UIViewContentModeCenter;
        _videoMaskView.image = [UIImage themeImageNamed:@"icohome_videosmall_v5.png"];
        [self addSubview:_videoMaskView];
    }
    return _videoMaskView;
}

- (UIImageView*)voteMaskView {
    if (!_voteMaskView) {
        _voteMaskView = [[UIImageView alloc] init];
        _voteMaskView.contentMode = UIViewContentModeCenter;
        _voteMaskView.image = [UIImage themeImageNamed:@"news_vote_icon.png"];
        [self addSubview:_voteMaskView];
    }
    return _voteMaskView;
}

- (void)setObject:(id)object {
    isNewItem = _item != object;
	if (isNewItem) {
        _item = object;
        
        if (_item) {
            SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
            SNDebugLog(SN_String("INFO: %@--%@, item is %@"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), [snItem description]);
            
            snItem.delegate = self;
            snItem.selector = @selector(openNews);
            
            if (snItem.text.length) {
                //self.textLabel.text = snItem.text;
            }
            if (snItem.subtitle.length) {
                self.detailTextLabel.text = nil;
            }
            
            [self.iconImageView unsetImage];
            self.iconImageView.urlPath = snItem.imageURL;
            self.iconImageView.hidden = !(snItem.imageURL.length > 0);
            self.videoMaskView.hidden = ![[snItem.news hasVideo] isEqualToString:@"1"];
            self.voteMaskView.hidden = ![[snItem.news newsType] isEqualToString:kSNVoteNewsType];
            
            [self setNeedsDisplay];
        }
	}
}

-(void)drawTitleAndAbstract
{
    SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
    BOOL hasImage = snItem.imageURL.length >0?YES:NO;
    BOOL isMultiTitle = NO;

    UIFont *titleFont = [UIFont systemFontOfSize:kThemeFontSizeD];
    UIFont *abstractFont = [UIFont systemFontOfSize:ROLLINGNEWS_ABSTRACT_FONT];
    NSString *title = snItem.text?snItem.text:@"";
    NSString *subtitle = snItem.subtitle?snItem.subtitle:@"";
    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:title];
    NSMutableAttributedString *abstractString = [[NSMutableAttributedString alloc] initWithString:subtitle];
    [titleString setNewsTitelParagraphStyleWithFont:titleFont lineBreakMode:kCTLineBreakByWordWrapping];
    [abstractString setNewsTitelParagraphStyleWithFont:abstractFont lineBreakMode:kCTLineBreakByTruncatingTail];
    int titleWidth = [NSCellLayout titleTextWidthHasPic:hasImage ifHasTypeIcon:NO targetWidth:TTApplicationFrame().size.width];
    int abstractWidth = [NSCellLayout abstractTextWidthHasPic:hasImage targetWidth:TTApplicationFrame().size.width];
    int titleHeight = [titleString getHeightWithWidth:titleWidth maxHeight:9999];
    NSInteger maxLineCount = [titleString getMaxLineCountWithWidth:titleWidth];
    if (maxLineCount > 2) {
        NSInteger index = [titleString getReplaceEndStringWithWidth:CGRectMake(0, 0, titleWidth, 40) fontSize:kThemeFontSizeD];
        if (index >0) {
            [titleString replaceCharactersInRange:NSMakeRange(index, titleString.string.length - index ) withString:@"..."];
        }
        [titleString setNewsTitelParagraphStyleWithFont:titleFont lineBreakMode:kCTLineBreakByTruncatingTail];
    }
    
    int imageWidth = hasImage?CELL_IMAGE_WIDTH:0;
    titleWidth = TTApplicationFrame().size.width - 2*CONTENT_LEFT - imageWidth - 6;
    
    //判断是否为2行标题
    CGSize titleSize = [title sizeWithFont:titleFont];
    if (titleSize.width > titleWidth) {
        isMultiTitle = YES;
    }
    
    //字体颜色
    NSString *titleColorString = nil;
    NSString *abstractColorString = nil;
    if ([kSNSpecialNewsIsRead_YES isEqualToString:snItem.news.isRead]) {
        titleColorString = [NSString stringWithFormat:@"%@",kRollingNewsCellTitleReadColor];
        abstractColorString = [NSString stringWithFormat:@"%@",kRollingNewsCellDetailTextReadColor];
    } else {
        titleColorString = [NSString stringWithFormat:@"%@",kRollingNewsCellTitleUnreadColor];
        abstractColorString = [NSString stringWithFormat:@"%@",kRollingNewsCellDetailTextUnreadColor];
    }
    [titleString setTextColor:SNUICOLOR(titleColorString)];
    [abstractString setTextColor:SNUICOLOR(abstractColorString)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGAffineTransform flip = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, self.frame.size.height);
    CGContextConcatCTM(context, flip);
    
    CGRect titleRect = CGRectMake(CONTENT_LEFT + CELL_IMAGE_WIDTH +6,DEFAULT_CELL_HEITHT + 6 - iconTopPadding -titleHeight, titleWidth, titleHeight);
    CGRect abstractRect = CGRectZero;
    if (!isMultiTitle && snItem.subtitle.length) {
        abstractRect = CGRectMake(CONTENT_LEFT + CELL_IMAGE_WIDTH +6, DEFAULT_CELL_HEITHT + 6 - iconTopPadding -kThemeFontSizeD - ROLLINGNEWS_ABSTRACT_FONT - 13,abstractWidth, ROLLINGNEWS_ABSTRACT_FONT+3);
        [UIView drawTextWithString:abstractString textRect:abstractRect context:context];
    }
    [UIView drawTextWithString:titleString textRect:titleRect context:context];
    CGContextRestoreGState(context);
}

- (void)layoutSubviews {
    
    [self.backView setNeedsDisplay];
    
    _iconImageView.frame = CGRectMake(CONTENT_LEFT, iconTopPadding-1, CELL_IMAGE_WIDTH, CELL_IMAGE_HEIGHT);
    self.videoMaskView.frame = CGRectMake(_iconImageView.right-VIDEOPLAY_SIZE-3,
                                          _iconImageView.bottom-VIDEOPLAY_SIZE-3,
                                          VIDEOPLAY_SIZE, VIDEOPLAY_SIZE);//_iconImageView.frame;
    [self bringSubviewToFront:_videoMaskView];
    
    SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
    int voteLeft = snItem.imageURL.length > 0 ? CONTENT_LEFT + CELL_IMAGE_WIDTH + 6 : CONTENT_LEFT;
    CGRect voteMaskRect = CGRectMake(voteLeft, _iconImageView.bottom - _voteMaskView.image.size.height,
                                     _voteMaskView.image.size.width, _voteMaskView.image.size.height);
    
    self.voteMaskView.frame = voteMaskRect;
    
    self.abstractLabel.left = CONTENT_LEFT;
    self.abstractLabel.width = 400/2;
    self.abstractLabel.top = self.textLabel.bottom + 16/2;
    self.abstractLabel.font = [UIFont systemFontOfSize:26/2];
    [self.abstractLabel setLineHeight:ABSTRACT_LINEHEIGHT];
    
    if ([self needsUpdateTheme]) {
        [self updateTheme];
    }
    
    [self setReadStyleByMemory];
}

#pragma mark - Private methods implementation

- (void)openNews {
    SNSpecialNewsTableItem *snItem = (SNSpecialNewsTableItem *)_item;
        if ([kSNTextNewsType isEqualToString:snItem.news.newsType]) {
        return;
    }
    
    snItem.news.isRead = kSNSpecialNewsIsRead_YES;
    NSDictionary *_dicData = [NSDictionary dictionaryWithObject:kSNSpecialNewsIsRead_YES forKey:@"isRead"];
    [[SNDBManager currentDataBase] updateSpecialNewsListByTermId:snItem.termId newsId:snItem.news.newsId withValuePairs:_dicData];
    [self setNeedsDisplay];
    [self.backView setNeedsDisplay];

    if(snItem.news.newsType!=nil && [SNCommonNewsController supportContinuationInSpecial:snItem.news.newsType])
    {
        NSMutableDictionary* dic = [snItem.dataSource getSpecialContentDictionary:snItem.news];
        TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:urlAction];
    }
    else if(snItem.news.link.length > 0
            /* && [kSNOuterLinkNewsType isEqualToString:snItem.news.newsType] ||
             [kSNLiveNewsType isEqualToString:snItem.news.newsType] ||
             [kSNSpecialNewsType isEqualToString:snItem.news.newsType] ||
             [kSNNewsPaperNewsType isEqualToString:snItem.news.newsType] */)
    {
        [SNUtility openProtocolUrl:snItem.news.link];
    }
}

@end
