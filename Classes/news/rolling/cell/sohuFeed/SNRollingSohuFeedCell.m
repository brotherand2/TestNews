//
//  SNRollingSohuFeedCell.m
//  sohunews
//
//  Created by wangyy on 2017/5/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingSohuFeedCell.h"
#import "NSAttributedString+Attributes.h"
#import "NSMutableAttributedString+Size.h"
#import "SNRollingNewsTitleCell.h"

@implementation SNRollingSohuFeedCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    return newsItem.cellHeight;
}

+ (CGFloat)feedLineSpace:(SNRollingNewsTableItem *)newsItem {
    BOOL isMultLineTitle = [SNRollingNewsTitleCell isMultiLineTitleWithItem:newsItem];
    return isMultLineTitle ? FEED_TITLE_LINE_SPACE * 7 : FEED_TITLE_LINE_SPACE * ([[SNDevice sharedInstance] isPlus] ? 8 : 4);
}

+ (void)calculateCellHeight:(SNRollingNewsTableItem *)item {
    [SNRollingNewsTitleCell calculateCellHeight:item];
    CGFloat lineSpace = (item.titleHeight == 0) ? 0 : [[self class] feedLineSpace:item] - 3;
    item.cellHeight = FEED_CONTENT_IMAGE_TOP + item.titleHeight + FEED_SPACEVALUE + COMMENT_BOTTOM + IMAGE_TOP - lineSpace;;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        //contenView
        CGRect rect = CGRectMake(0.0, 0.0, kAppScreenWidth, self.contentView.bounds.size.height);
        self.cellContentView = [[SNSohuFeedCellContentView alloc] initWithFrame:rect];
        self.cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.cellContentView];        
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        self.cellContentView.backgroundColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeBg2Color];
    } else {
        //5.9.3 wangchuanwen update
        self.cellContentView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    }
}

- (void)updateContentView {
    [super updateContentView];
    self.item.delegate = self;
    self.item.selector = @selector(openSohuFeed);
    [self updateNewsContent];
    [self setReadStyleByMemory];
}

- (void)updateNewsContent {
    self.cellContentView.titleWidth  = [SNRollingNewsTitleCell getTitleWidth];
    self.cellContentView.titleHeight = self.item.titleHeight;
    self.cellContentView.feedTitle   = self.item.news.title;
    self.cellContentView.titleAttStr = self.item.titleString;
    self.cellContentView.userName    = self.item.news.sohuFeed.userName;
    if (self.item.cellType == SNRollingNewsCellTypeSohuFeedPhotos) {
        self.cellContentView.cellType = SohuFeedPhotos;
    }
    
    if (self.item.cellType == SNRollingNewsCellTypeSohuFeedBigPic) {
        self.cellContentView.cellType = SohuFeedBigPic;
    }
    
    self.cellContentView.transferNum = self.item.news.sohuFeed.repostsCount;
    self.cellContentView.commentNum  = self.item.news.sohuFeed.commentCnt;
    self.cellContentView.recomTime   = self.item.news.recomTime;
    self.cellContentView.avatorUrl   = self.item.news.sohuFeed.avatarUrl;
    self.cellContentView.recomReasons = self.item.news.recomReasons;
}

- (void)setAlreadyReadStyle {
    //TODO:设置已读样式
    [self.cellContentView.titleAttStr setTextColor:SNUICOLOR(kThemeText3Color)];
    self.cellContentView.userNameColor = SNUICOLOR(kThemeText3Color);
}

- (void)setUnReadStyle {
    //TODO:设置未读样式
    //5.9.3 wangchuanwen update
    UIColor *color =SNUICOLOR(kThemeTextRIColor);
    [self.cellContentView.titleAttStr setTextColor:color];
    self.cellContentView.userNameColor = color;
}

- (void)setReadStyleByMemory {
    if (self.item.news.isRead) {
        [self setAlreadyReadStyle];
    } else {
        [self setUnReadStyle];
    }

    [self.cellContentView setNeedsDisplay];
}

- (void)updateTheme {
    [super updateTheme];
    //5.9.3 wangchuanwen update
    self.cellContentView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    [self setReadStyleByMemory];
}

- (void)reportADotGif{
    NSString *paramStr = @"_act=huyou&_tp=pv";
    if (self.item.news.recomReasons.length > 0 && [self.item.news.recomReasons isEqualToString:@"已关注"]) {
        paramStr = [paramStr stringByAppendingString:@"&type=1"];
    } else {
        paramStr = [paramStr stringByAppendingString:@"&type=1"];
    }
    
    paramStr = [paramStr stringByAppendingFormat:@"&recomInfo=%@", self.item.news.recomInfo];
    
    [SNNewsReport reportADotGif:paramStr];
}

- (void)openSohuFeed {
    if (self.item.news.sohuFeed.openFlag) {
        [SNUtility shouldUseSpreadAnimation:YES];
        [SNUtility openProtocolUrl:self.item.news.sohuFeed.openFlag];
        
        [self reportADotGif];
    }

    //设置数据库已读
    NSString *newsId = self.item.news.newsId;
    NSString *channel = self.item.news.channelId;
    if (channel != nil && newsId != nil) {
        [SNRollingNewsPublicManager saveReadNewsWithNewsId:newsId ChannelId:channel];
    }
    //内存已读
    self.item.news.isRead = YES;
    [self setReadStyleByMemory];
}

@end
