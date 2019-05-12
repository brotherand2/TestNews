//
//  SNRollingTrainImageTextCell.m
//  sohunews
//
//  Created by HuangZhen on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingTrainImageTextCell.h"
#import "SNRollingTrainCellConst.h"
#import "NSString+Utilities.h"
#import "SNNewsAd+analytics.h"
#import "SNStatisticsInfoAdaptor.h"

@interface SNRollingTrainImageTextCell ()

@end

@implementation SNRollingTrainImageTextCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    [self buildImageView];
    [self buildBottomShadow];
    [self buildTitleLabel];
    [self buildVideoLabel];
    [self buildCategoryLabel];
    [self buildCommentLabel];
    [self buildPicCountLabel];
    [self buildMediaLabel];
    self.videoLabel.hidden = YES;
    self.commentLabel.hidden = YES;
    self.adLabel.hidden = YES;
    self.editorLabelBgView.hidden = YES;
    self.editorLabel.hidden = YES;
    self.picCountLabel.hidden = YES;
    self.mediaLabel.hidden = YES;
}

- (void)buildImageView {
    if (!self.cellImageView) {
        CGRect imageRect = CGRectMake(0, 0, self.width, self.height);
        self.cellImageView = [[SNCellImageView alloc] initWithFrame:imageRect];
        UIImage* defaultImage = [UIImage themeImageNamed:kThemeImgPlaceholder5];
        [self.cellImageView setDefaultImage:defaultImage];
        [self addSubview:self.cellImageView];
        self.cellImageView.layer.cornerRadius = kTrainCardCornerRadius;
    }
}

- (void)buildTitleLabel {
    if (!self.cellTitleLabel) {
        CGRect labelRect = CGRectMake(kLeftSpace, self.height - 30 - 28, self.width - 3*kLeftSpace,28);
        self.cellTitleLabel = [[UILabel alloc] initWithFrame:labelRect];
        self.cellTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.cellTitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.cellTitleLabel.font = [SNTrainCellHelper fullscreenFocusTitleFont];
        self.cellTitleLabel.textColor = SNUICOLOR(kThemeText12Color);
        [self addSubview:self.cellTitleLabel];
    }
}

- (void)buildVideoLabel {
    if (!self.videoLabel) {
        CGRect videoImageFrame = CGRectMake(0, 0, 36/2, 36/2);
        self.videoLabel = [[UIImageView alloc] initWithFrame:videoImageFrame];
        self.videoLabel.left = kLeftSpace;
        self.videoLabel.centerY = self.cellTitleLabel.centerY;
        UIImage *videoImage = [UIImage imageNamed:@"icohome_focus_videosmall_v5.png"];
        self.videoLabel.image = videoImage;
        [self addSubview:self.videoLabel];
    }
}

- (void)buildCategoryLabel {
    if (!self.editorLabel) {
        self.editorLabelBgView = [[UIView alloc] initWithFrame:CGRectMake(kLeftSpace, 0, 65, 15)];
        self.editorLabelBgView.backgroundColor = [SNTrainCellHelper sohuEditLabelBackgroundColor];
        self.editorLabelBgView.top = self.cellTitleLabel.bottom + 7;
        [self addSubview:self.editorLabelBgView];
        
        self.editorLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftSpace+4, 0, 65, 15)];
        self.editorLabel.top = self.cellTitleLabel.bottom + 8;
        self.editorLabel.textAlignment = NSTextAlignmentCenter;
        self.editorLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        self.editorLabel.textColor = [SNTrainCellHelper sohuEditLabelTextColor];
        self.editorLabel.text = @"搜狐编辑部";
        self.editorLabelBgView.alpha = [SNTrainCellHelper sohuEditLabelAlpha];
        [self.editorLabel sizeToFit];
        [self addSubview:self.editorLabel];
    }
    if (!self.adLabel) {
        self.adLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLeftSpace, 0, 65, 15)];
        self.adLabel.top = self.cellTitleLabel.bottom + 7;
        self.adLabel.textAlignment = NSTextAlignmentCenter;
        self.adLabel.font = [UIFont systemFontOfSize:kThemeFontSizeB];
        self.adLabel.textColor = SNUICOLOR(kThemeText12Color);
        self.adLabel.backgroundColor = [SNTrainCellHelper adTextBackgroundColor];
        [self addSubview:self.adLabel];
    }
}

- (void)buildCommentLabel {
    if (!self.commentLabel) {
        self.commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 15)];
        self.commentLabel.left = self.editorLabel.right + 8;
        self.commentLabel.top = self.editorLabel.top;
        self.commentLabel.font = [UIFont systemFontOfSize:11];
        self.commentLabel.textColor = SNUICOLOR(kThemeText12Color);
        [self addSubview:self.commentLabel];
    }
}

- (void)buildPicCountLabel {
    if (!self.picCountLabel) {
        self.picCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 15)];
        self.picCountLabel.left = self.commentLabel.right + 8;
        self.picCountLabel.top = self.commentLabel.top;
        self.picCountLabel.font = [UIFont systemFontOfSize:11];
        self.picCountLabel.textColor = SNUICOLOR(kThemeText12Color);
        [self addSubview:self.picCountLabel];
    }
}

- (void)buildMediaLabel {
    if (!self.mediaLabel) {
        self.mediaLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 15)];
        self.mediaLabel.left = self.picCountLabel.right + 8;
        self.mediaLabel.top = self.picCountLabel.top;
        self.mediaLabel.font = [UIFont systemFontOfSize:11];
        self.mediaLabel.textColor = SNUICOLOR(kThemeText12Color);
        [self addSubview:self.mediaLabel];
    }
}

- (void)buildBottomShadow {
    if (!self.bottomShadow) {
        self.bottomShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, kFocusBottomShadowHeight)];
        self.bottomShadow.bottom = self.height;
        [self addSubview:self.bottomShadow];
    }
    if (!self.maskShadow) {
        self.maskShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
        [self addSubview:self.maskShadow];
        self.maskShadow.layer.cornerRadius = kTrainCardCornerRadius;
    }
}

- (void)addBottomShadowMask:(SNTrainCellType)type {
    switch (type) {
        case SNTrainCellTypeFocus:
        {
            self.maskShadow.hidden = YES;
            self.bottomShadow.hidden = NO;
            UIColor * color = [SNTrainCellHelper focusGradientBackgroundColor];
            self.bottomShadow.backgroundColor = color;
            UIColor *color1 = [UIColor colorWithRed:color.red green:color.blue blue:color.blue alpha:[SNTrainCellHelper focusGradientBackgroundAlpha]];
            UIColor *color2 = [UIColor colorWithRed:color.red green:color.blue blue:color.blue alpha:1.0];
            
            NSArray *colors = [NSArray arrayWithObjects:(id)color1.CGColor, color2.CGColor, nil];
            NSArray *locations = [NSArray arrayWithObjects:@(0.0),@(1.0), nil];
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.colors = colors;
            gradientLayer.locations = locations;
            gradientLayer.frame = self.bottomShadow.bounds;
            gradientLayer.startPoint = CGPointMake(0, 0);
            gradientLayer.endPoint   = CGPointMake(0, 1);
            self.bottomShadow.layer.mask = gradientLayer;
            break;
        }
        case SNTrainCellTypeCards:
        {
            self.bottomShadow.hidden = YES;
            self.maskShadow.hidden = NO;
            self.maskShadow.image = [UIImage imageNamed:@"ico_traincard_mask.png"];
//            if (self.maskShadow.layer.mask) {
//                return;
//            }
//            UIColor * color = [UIColor blackColor];
//            self.maskShadow.backgroundColor = color;
//            UIColor *color1 = [UIColor colorWithRed:color.red green:color.blue blue:color.blue alpha:0.2];
//            UIColor *color2 = [UIColor colorWithRed:color.red green:color.blue blue:color.blue alpha:0.2];
//            UIColor *color3 = [UIColor colorWithRed:color.red green:color.blue blue:color.blue alpha:0.0];
//            UIColor *color4 = [UIColor colorWithRed:color.red green:color.blue blue:color.blue alpha:0.0];
//            UIColor *color5 = [UIColor colorWithRed:color.red green:color.blue blue:color.blue alpha:0.5];
//            UIColor *color6 = [UIColor colorWithRed:color.red green:color.blue blue:color.blue alpha:0.5];
//            NSArray *colors = [NSArray arrayWithObjects:(id)color1.CGColor, color2.CGColor, color3.CGColor,
//                               color4.CGColor, color5.CGColor, color6.CGColor, nil];
//            NSArray *locations = [NSArray arrayWithObjects:@(0.0),@(0.05),@(0.32),@(0.39),@(0.96),@(1.0), nil];
//            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//            gradientLayer.colors = colors;
//            gradientLayer.locations = locations;
//            gradientLayer.frame = self.maskShadow.bounds;
//            gradientLayer.startPoint = CGPointMake(0, 0);
//            gradientLayer.endPoint   = CGPointMake(0, 1);
//            self.maskShadow.layer.mask = gradientLayer;
            break;
        }
        default:
            break;
    }
}
#pragma mark --
#pragma mark -- 统计
- (void)reportNewsDidShow:(SNRollingNews *)news {
    if ([news.newsType isEqualToString:kNewsTypeAd]) {
        [news.newsAd reportAdOneDisplay:news];
    } else {
        [SNStatisticsInfoAdaptor cacheTimelineNewsShowBusinessStatisticsInfo:news];
    }
}

- (void)reportADotGifShow:(SNRollingNews *)news {
    if (self.type == SNTrainCellTypeCards) {
        if (news.reportState == AdReportStateNo) {
            NSString *paramStr = [NSString stringWithFormat:@"_act=card_news&_tp=pv&channelid=%@&newsid=%@",news.channelId, news.newsId];
            [SNNewsReport reportADotGif:paramStr];
            news.reportState = AdReportStateLoad;
        }
    }
}

- (BOOL)isVideoNews {
    return [self.news.hasVideo isEqualToString:@"1"];
}

- (BOOL)hasAdIconText {
    return self.news.iconText.length > 0;
}

- (BOOL)hasComment {
    return self.news.commentNum.integerValue > 0 || self.news.tvPlayNum.integerValue > 0;
}

- (BOOL)hasVideoComment {
    return self.news.tvPlayNum.integerValue > 0;
}

- (BOOL)hasPicCount {
    return self.news.listPicsNumber.integerValue > 0;
}

- (BOOL)hasMediaLabel {
    return self.news.media.length > 0;
}

- (BOOL)isPGCNews:(SNRollingNews *)news {
    NSInteger templateType = news.templateType.integerValue;
    return templateType == 34 || templateType == 37;
}

- (void)updateTheme {
    [super updateTheme];
    [self layoutWithType:self.type];
}

- (void)cellFullDisplaying {
    [super cellFullDisplaying];
    [self reportNewsDidShow:self.news];
}

- (void)cellIsDisplaying {
    [super cellIsDisplaying];
    [self reportNewsDidShow:self.news];
}

- (void)cellDidEndDisplaying {
    [super cellDidEndDisplaying];
}

- (void)layoutWithType:(SNTrainCellType)cellType {
    switch (cellType) {
        case SNTrainCellTypeCards:
            [self layoutCardsContent];
            break;
        case SNTrainCellTypeFocus:
            [self layoutFocusContent];
            break;
        default:
            break;
    }
}

- (void)layoutFocusContent {
    //图片
    CGRect imageRect = CGRectMake(0, 0, self.width, self.height);
    self.cellImageView.frame = imageRect;
    self.cellImageView.layer.cornerRadius = 0;
    UIImage* defaultImage = [UIImage themeImageNamed:@"icohome_zwt_v5.png"];
    [self.cellImageView updateImageWithUrl:self.news.picUrl defaultImage:defaultImage showVideo:NO];
    [self.cellImageView updateTheme];
    
    //标题
    //视频新闻
    self.videoLabel.hidden = YES;
    self.cellTitleLabel.textColor = [SNTrainCellHelper newsTitleColor];
    self.cellTitleLabel.font = [SNTrainCellHelper fullscreenFocusTitleFont];
    [self layoutTitleLableText:SNTrainCellTypeFocus];
    self.cellTitleLabel.bottom = self.height - 30;
    
    self.editorLabel.textColor = [SNTrainCellHelper sohuEditLabelTextColor];
    self.editorLabelBgView.alpha = [SNTrainCellHelper sohuEditLabelAlpha];
    self.editorLabelBgView.backgroundColor = [SNTrainCellHelper sohuEditLabelBackgroundColor];
    //标题阴影
    self.bottomShadow.frame = CGRectMake(0, self.height - kFocusBottomShadowHeight, self.width, kFocusBottomShadowHeight);
    [self addBottomShadowMask:SNTrainCellTypeFocus];

    //广告标签
    if ([self hasAdIconText]) {
        self.adLabel.hidden = NO;
        self.editorLabelBgView.hidden = YES;
        self.editorLabel.hidden = YES;
        self.adLabel.textColor = [SNTrainCellHelper cardNewsTitleColor];
        self.adLabel.text = self.news.iconText;
        CGSize titleSize = [self.adLabel.text sizeWithFont:self.adLabel.font];
        self.adLabel.width = titleSize.width + 6;
        self.adLabel.backgroundColor = [SNTrainCellHelper adTextBackgroundColor];
    }else{
        self.adLabel.hidden = YES;
        self.editorLabelBgView.hidden = NO;
        self.editorLabel.hidden = NO;
        self.editorLabelBgView.backgroundColor = [SNTrainCellHelper sohuEditLabelBackgroundColor];
    }
    //评论
    if ([self hasComment]) {
        self.commentLabel.hidden = NO;
        self.commentLabel.text = [NSString stringWithFormat:@"%@评论",[NSString chineseStringWithInt:self.news.commentNum.intValue]];
        CGSize commentSize = [self.commentLabel.text sizeWithFont:self.commentLabel.font];
        self.commentLabel.textColor = [SNTrainCellHelper commentWordsColor];
        self.commentLabel.width = commentSize.width + 6;
        self.commentLabel.left = kLeftSpace + 65 + 8;
    }else{
        self.commentLabel.hidden = YES;
    }
}

- (void)layoutCardsContent {
    //图片
    CGRect imageRect = CGRectMake(0, 0, self.width, self.height);
    self.cellImageView.frame = imageRect;
    self.cellImageView.layer.cornerRadius = kTrainCardCornerRadius;
    UIImage* defaultImage = [UIImage themeImageNamed:@"icohome_cardzwt_v5.png"];
    [self.cellImageView updateImageWithUrl:self.news.picUrl defaultImage:defaultImage showVideo:NO];
    [self.cellImageView updateTheme];
    //标题
    //视频新闻
    self.videoLabel.hidden = YES;
    self.cellTitleLabel.textColor = [SNTrainCellHelper cardNewsTitleColor];
    self.cellTitleLabel.font = [SNTrainCellHelper trainCardNewsTitleFont];
    self.cellTitleLabel.frame = CGRectMake(kCardLeftSpace, self.height - 60, self.width-2*kCardLeftSpace, 30);

    [self layoutTitleLableText:SNTrainCellTypeCards];
    
    self.cellTitleLabel.bottom = self.height - 26;
    //标题阴影
    [self addBottomShadowMask:SNTrainCellTypeCards];
    
    //评论
    CGFloat offset = kCardLeftSpace;
    if ([self hasComment]) {
        self.commentLabel.hidden = NO;
        if ([self hasVideoComment]) {
            self.commentLabel.text = [NSString stringWithFormat:@"%@播放",[NSString chineseStringWithInt:self.news.tvPlayNum.intValue]];
        }else{
            self.commentLabel.text = [NSString stringWithFormat:@"%@评论",[NSString chineseStringWithInt:self.news.commentNum.intValue]];
        }
        
        self.commentLabel.alpha = .8f;
        CGSize commentSize = [self.commentLabel.text sizeWithFont:self.commentLabel.font];
        self.commentLabel.textColor = [SNTrainCellHelper cardNewsTitleColor];
        self.commentLabel.width = commentSize.width + 6;
        self.commentLabel.left = kCardLeftSpace;
        offset += (self.commentLabel.width + kCardLeftSpace);
    }else{
        self.commentLabel.hidden = YES;
    }
    //组图
    if ([self hasPicCount]) {
        self.picCountLabel.hidden = NO;
        self.picCountLabel.alpha = .8f;
        self.picCountLabel.text = [NSString stringWithFormat:@"%@图",self.news.listPicsNumber];
        CGSize picSize = [self.picCountLabel.text sizeWithFont:self.picCountLabel.font];
        self.picCountLabel.textColor = [SNTrainCellHelper cardNewsTitleColor];
        self.picCountLabel.width = picSize.width + 6;
        self.picCountLabel.left = offset;
        offset += (self.picCountLabel.width + kCardLeftSpace);
    }else{
        self.picCountLabel.hidden = YES;
    }
    //媒体标签
    if ([self hasMediaLabel]) {
        self.mediaLabel.hidden = NO;
        self.mediaLabel.alpha = .8f;
        self.mediaLabel.text = [NSString stringWithFormat:@"%@",self.news.media];
        CGSize picSize = [self.mediaLabel.text sizeWithFont:self.mediaLabel.font];
        self.mediaLabel.textColor = [SNTrainCellHelper cardNewsTitleColor];
        self.mediaLabel.width = picSize.width + 6;
        self.mediaLabel.left = offset;
        offset = self.mediaLabel.right + kCardLeftSpace;
    }else{
        self.mediaLabel.hidden = YES;
    }
    //广告标签
    self.editorLabelBgView.hidden = YES;
    self.editorLabel.hidden = YES;
    if ([self hasAdIconText]) {
        self.commentLabel.hidden = YES;
        self.mediaLabel.hidden = YES;
        self.picCountLabel.hidden = YES;
        self.adLabel.hidden = NO;
        self.adLabel.backgroundColor = [UIColor clearColor];
        self.adLabel.textColor = [SNTrainCellHelper cardNewsTitleColor];
        self.adLabel.alpha = .8f;
        self.adLabel.text = self.news.iconText;
        CGSize titleSize = [self.adLabel.text sizeWithFont:self.adLabel.font];
        self.adLabel.width = titleSize.width + 6;
        self.adLabel.left = kCardLeftSpace;
    }else{
        self.adLabel.hidden = YES;
    }
    if (![self hasComment] &&
        ![self hasPicCount] &&
        ![self hasMediaLabel] &&
        ![self hasAdIconText] &&
        ![self isPGCNews:self.news]) {
        self.cellTitleLabel.bottom = self.commentLabel.bottom;
    }
}

- (void)layoutTitleLableText:(SNTrainCellType)cellType {
    BOOL isVideoNews = [self isVideoNews];
    if (cellType == SNTrainCellTypeFocus) {
        self.cellTitleLabel.width = self.width - 3*kLeftSpace;
    }else{
        self.cellTitleLabel.width = self.width - 2*kLeftSpace;
    }
    NSMutableAttributedString * attText = [[NSMutableAttributedString alloc] initWithString:@""];
    if (isVideoNews) {
        CGFloat imgOffset = [SNTrainCellHelper videoImgOffsetInTitle];
        if (cellType == SNTrainCellTypeFocus) {
            imgOffset = -2;
        }
        NSTextAttachment *attch = [NSTextAttachment new];
        attch.image = [UIImage imageNamed:@"icohome_focus_videosmall_v5.png"];
        attch.bounds = CGRectMake(0, imgOffset, 36/2, 36/2);
        NSAttributedString *videoImgStr = [NSAttributedString attributedStringWithAttachment:attch];
        NSMutableAttributedString * attNewsTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",self.news.title]];
        [attText appendAttributedString:videoImgStr];
        [attText appendAttributedString:attNewsTitle];
    }else{
        NSMutableAttributedString * attriNewsTitle = [[NSMutableAttributedString alloc] initWithString:self.news.title];
        [attText appendAttributedString:attriNewsTitle];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if ([self isPGCNews:self.news] || cellType == SNTrainCellTypeFocus) {
        self.cellTitleLabel.numberOfLines = 1;
    }else{
        self.cellTitleLabel.numberOfLines = 2;
        [paragraphStyle setLineSpacing:2.5f];
    }
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [attText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [attText length])];
    self.cellTitleLabel.attributedText = attText;
    CGSize titleSize = [self.cellTitleLabel sizeThatFits:CGSizeMake(self.cellTitleLabel.width, MAXFLOAT)];
    self.cellTitleLabel.height = titleSize.height;
}

- (void)transitionWithRatio:(CGFloat)ratio {
    [self buildPicCountLabel];
    [self buildMediaLabel];
    //imageview
    self.cellImageView.frame = self.bounds;
    self.cellImageView.layer.cornerRadius = kTrainCardCornerRadius;
    //搜狐编辑部
    CGFloat edit_t_top = kCardLeftSpace;
    CGFloat edit_t_left = kLeftSpace+kCardLeftSpace+7;
    CGFloat edit_top = self.cellTitleLabel.bottom + 8;
    self.editorLabel.top = edit_top - (edit_top - edit_t_top)*ratio;
    
    UIFont *edit_font = [UIFont systemFontOfSize:kThemeFontSizeB];
    UIFont *edit_t_font = [SNTrainCellHelper trainCardCellEditLabelFont];
    CGFloat editfontSize = edit_font.pointSize + (edit_t_font.pointSize - edit_font.pointSize)*ratio;
    UIFont * editfont = nil;
    if (ratio > 0.5) {
        editfont = [UIFont fontWithName:@"Helvetica-Bold" size:editfontSize];
    }else{
        editfont = [UIFont systemFontOfSize:editfontSize];
    }
    self.editorLabel.font = editfont;
    [self.editorLabel sizeToFit];
    
    UIColor * edit_color = [SNTrainCellHelper sohuEditLabelTextColor];
    UIColor * edit_t_Color = [SNTrainCellHelper trainCellEditorLabelTitleColor];
    UIColor * edit_finalColor = [UIColor mixColor1:edit_t_Color color2:edit_color ratio:ratio];
    self.editorLabel.textColor = edit_finalColor;
    
    CGFloat bg_ratio = MIN(1, 4*ratio);
    CGFloat bg_width = 65 - (65 - kLeftSpace)*bg_ratio;
    UIColor * bg_color = [SNTrainCellHelper sohuEditLabelBackgroundColor];
    UIColor * bg_t_Color = SNUICOLOR(kThemeYellow1Color);
    UIColor * bg_finalColor = [UIColor mixColor1:bg_t_Color color2:bg_color ratio:bg_ratio];
    self.editorLabel.left = kLeftSpace + 4 + (edit_t_left - kLeftSpace - 4)*bg_ratio;
    
    self.editorLabelBgView.layer.cornerRadius = kTrainCardCornerRadius * bg_ratio;
    self.editorLabelBgView.width = bg_width;
    self.editorLabelBgView.backgroundColor = bg_finalColor;
    self.editorLabelBgView.top = self.editorLabel.top;
    self.editorLabelBgView.left = kLeftSpace - (kLeftSpace - kCardLeftSpace) * bg_ratio;
//    CGRect logoRect = CGRectMake(kLeftSpace+kCardLeftSpace, kLeftSpace+kCardLeftSpace, kLeftSpace, kLeftSpace);
    if (!self.editorLogo) {
        CGRect logoRect = CGRectMake(2*kLeftSpace, 2* kLeftSpace, kLeftSpace, kLeftSpace);
        self.editorLogo = [[UIImageView alloc] initWithFrame:logoRect];
        self.editorLogo.backgroundColor = [UIColor clearColor];
        [self addSubview:self.editorLogo];
        self.editorLogo.image = [UIImage imageNamed:@"icohome_sohubjb_v5.png"];
        self.editorLogo.alpha = 0.f;
    }
    self.editorLogo.left = self.editorLabelBgView.left;
    self.editorLogo.centerY = self.editorLabelBgView.centerY;

    if (bg_ratio == 1) {
        CGFloat alphaRatio = MIN(1, 4*ratio-1);
        self.editorLabelBgView.alpha = 1-alphaRatio;
        self.editorLogo.alpha = alphaRatio;
        if ([self hasAdIconText]) {
            self.editorLabel.alpha = alphaRatio;
            self.editorLabel.hidden = NO;
        }
    }
    //阴影
    if (self.maskShadow.hidden) {
        [self addBottomShadowMask:SNTrainCellTypeCards];
        self.maskShadow.hidden = NO;
        self.bottomShadow.hidden = NO;
    }
    CGFloat bottomShadowHeight = kFocusBottomShadowHeight/kTrainCellImageHeight * self.height;
    self.bottomShadow.frame = CGRectMake(0, self.height - bottomShadowHeight, self.width, bottomShadowHeight);
    self.bottomShadow.layer.cornerRadius = kTrainCardCornerRadius;
    self.bottomShadow.alpha = 1 - ratio;
    self.maskShadow.alpha = 2*ratio;
    self.maskShadow.frame = self.bounds;
    
    //titleLabel
    UIFont *bigFont = [SNTrainCellHelper fullscreenFocusTitleFont];
    UIFont *smallFont = [SNTrainCellHelper fullscreenEditNewsTitleFont];
    CGFloat fontSize = bigFont.pointSize - (bigFont.pointSize - smallFont.pointSize)*ratio;
    UIFont * font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
    self.cellTitleLabel.font = font;
    self.cellTitleLabel.textColor = [SNTrainCellHelper cardNewsTitleColor];
    if (ratio > 0.5) {
        [self layoutTitleLableText:SNTrainCellTypeCards];
    }else{
        [self layoutTitleLableText:SNTrainCellTypeFocus];
    }
    //titleframe
    CGFloat bigLeft = kImageLeftMargin;
    CGFloat bigBottom = self.height - 30;
    CGFloat smallLeft = bigLeft - (bigLeft - kCardLeftSpace)*ratio;
    CGFloat smallBottom = bigBottom + 4*ratio;
    self.cellTitleLabel.bottom = smallBottom;
    self.cellTitleLabel.left = smallLeft;

    CGFloat commentLeft = kLeftSpace + 65 + 8;
    CGFloat t_commentLeft = commentLeft - (commentLeft - kCardLeftSpace)*ratio;
    CGFloat commentBottom = self.cellTitleLabel.bottom + 4 + self.commentLabel.height + 4*(1-ratio);
    
    self.commentLabel.bottom = commentBottom;
    self.picCountLabel.bottom = commentBottom;
    self.mediaLabel.bottom = commentBottom;
    self.adLabel.bottom = commentBottom;
    //评论
    CGFloat offset = kCardLeftSpace;
    if ([self hasComment]) {
        self.commentLabel.hidden = NO;
        self.commentLabel.alpha = .8f;
        self.commentLabel.text = [NSString stringWithFormat:@"%@评论",[NSString chineseStringWithInt:self.news.commentNum.intValue]];
        CGSize commentSize = [self.commentLabel.text sizeWithFont:self.commentLabel.font];
        self.commentLabel.width = commentSize.width + 6;
        self.commentLabel.left = t_commentLeft;
        offset += (self.commentLabel.width + kCardLeftSpace);
        UIColor * color = [SNTrainCellHelper commentWordsColor];
        UIColor * normalColor = [SNTrainCellHelper cardNewsTitleColor];
        UIColor * finalColor = [UIColor mixColor1:normalColor color2:color ratio:ratio];
        self.commentLabel.textColor = finalColor;
    }
    
    //组图
    if ([self hasPicCount]) {
        self.picCountLabel.hidden = NO;
        self.picCountLabel.alpha = .8f * ratio;
        self.picCountLabel.text = [NSString stringWithFormat:@"%@图",self.news.listPicsNumber];
        CGSize picSize = [self.picCountLabel.text sizeWithFont:self.picCountLabel.font];
        self.picCountLabel.textColor = [SNTrainCellHelper cardNewsTitleColor];
        self.picCountLabel.width = picSize.width + 6;
        self.picCountLabel.left = offset;
        offset += (self.picCountLabel.width + kCardLeftSpace);
    }
    //媒体标签
    if ([self hasMediaLabel]) {
        self.mediaLabel.hidden = NO;
        self.mediaLabel.alpha = .8f * ratio;
        self.mediaLabel.text = [NSString stringWithFormat:@"%@",self.news.media];
        CGSize picSize = [self.mediaLabel.text sizeWithFont:self.mediaLabel.font];
        self.mediaLabel.textColor = [SNTrainCellHelper cardNewsTitleColor];
        self.mediaLabel.width = picSize.width + 6;
        self.mediaLabel.left = offset;
        offset = self.mediaLabel.right + kCardLeftSpace;
    }else{
        self.mediaLabel.hidden = YES;
    }
    //广告标签
    if ([self hasAdIconText]) {
        self.commentLabel.hidden = YES;
        self.mediaLabel.hidden = YES;
        self.picCountLabel.hidden = YES;
        self.adLabel.hidden = NO;
        UIColor * adColor = [SNTrainCellHelper adTextBackgroundColor];
        self.adLabel.backgroundColor = [UIColor colorWithRed:adColor.red
                                                       green:adColor.green
                                                        blue:adColor.blue
                                                       alpha:(1-3*ratio)];
        self.adLabel.alpha = 1 - .2f*ratio;
        self.adLabel.text = self.news.iconText;
        CGSize titleSize = [self.adLabel.text sizeWithFont:self.adLabel.font];
        self.adLabel.width = titleSize.width + 6;
        self.adLabel.left = smallLeft;
    }
}

- (void)zoomWithRatio:(CGFloat)ratio {
    //图片
    CGRect imageRect = CGRectMake(0, 0, self.width, self.height);
    self.cellImageView.frame = imageRect;
    self.maskShadow.frame = imageRect;
    self.layer.cornerRadius = kTrainCardCornerRadius;

    //标题
//    self.cellTitleLabel.left = kCardLeftSpace;
//    self.cellTitleLabel.width = self.width - _cellTitleLabel.left - kCardLeftSpace;
//    self.cellTitleLabel.width = kSmallTrainCellWidth - 2*kCardLeftSpace;
//    CGSize titleSize = [self.cellTitleLabel sizeThatFits:CGSizeMake(self.cellTitleLabel.width, MAXFLOAT)];
//    self.cellTitleLabel.height = titleSize.height;
//    self.cellTitleLabel.bottom = self.height - 26;
    
    //titleLabel
    UIFont *bigFont = [SNTrainCellHelper fullscreenFocusTitleFont];
    UIFont *smallFont = [SNTrainCellHelper fullscreenEditNewsTitleFont];
    CGFloat fontSize = bigFont.pointSize - (bigFont.pointSize - smallFont.pointSize)*ratio;
    UIFont * font = [UIFont fontWithName:@"Helvetica-Bold" size:fontSize];
    self.cellTitleLabel.font = font;
    self.cellTitleLabel.textColor = [SNTrainCellHelper cardNewsTitleColor];
    if (ratio > 0.5) {
        [self layoutTitleLableText:SNTrainCellTypeCards];
    }else{
        [self layoutTitleLableText:SNTrainCellTypeFocus];
    }
    //titleframe
    CGFloat bigLeft = kImageLeftMargin;
    CGFloat bigBottom = self.height - 30;
    CGFloat smallLeft = bigLeft - (bigLeft - kCardLeftSpace)*ratio;
    CGFloat smallBottom = bigBottom + 4*ratio;
    self.cellTitleLabel.bottom = smallBottom;
    self.cellTitleLabel.left = smallLeft;

    
    self.commentLabel.top =  self.cellTitleLabel.bottom + 4;
    self.picCountLabel.top = self.commentLabel.top;
    self.mediaLabel.top = self.commentLabel.top;
    self.adLabel.top = self.commentLabel.top;
    //标题阴影
    [self addBottomShadowMask:SNTrainCellTypeCards];
    self.maskShadow.frame = self.bounds;
}

@end
