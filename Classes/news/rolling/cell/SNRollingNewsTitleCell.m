//
//  SNRollingNewsTitleCell.m
//  sohunews
//
//  Created by lhp on 5/5/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingNewsTitleCell.h"
#import "SNCommonNewsController.h"
#import "SNCommonNewsDatasource.h"
#import "SNNewsAd+analytics.h"
#import "SNRollingNewsConst.h"
#import "UIFont+Theme.h"
#import "SNNewsExposureManager.h"
#import "SNUserManager.h"
#import "SNNewsReport.h"

@implementation SNRollingNewsTitleCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    return IMAGE_TOP * 2 + newsItem.titleHeight + COMMENT_BOTTOM;
}

+ (void)setTableviewCellTitleHeight:(SNRollingNewsTableItem *)item {
    BOOL isMultLine = [[self class] isMultiLineTitleWithItem:item];
    CGFloat titleHeight;
    CGFloat titleWidth = [[self class] getTitleWidth:item];
    UIFont *titleFont = [SNUtility getNewsTitleFont];
    float fontSize = [SNUtility getNewsTitleFontSize];
    if (isMultLine && item.titleString) {
        NSInteger lineCount = [SNRollingNewsTitleCell titleMaxLineCount:item];
        titleHeight = [item.titleString getHeightWithWidth:titleWidth maxLineCount:lineCount font:titleFont];
        NSInteger maxLineCount = [item.titleString getMaxLineCountWithWidth:titleWidth];
        item.titlelineCnt = MIN(maxLineCount, lineCount);
        if (maxLineCount > lineCount) {
            NSInteger index = [item.titleString getReplaceEndStringWithWidth:CGRectMake(0, 0, titleWidth, 40) fontSize:fontSize lineCnt:lineCount];
            if (index > 0) {
                [item.titleString replaceCharactersInRange:NSMakeRange(index, item.titleString.string.length - index) withString:@"..."];
            }
        }
    } else {
        //搜狐feed模版title为空，titleHeight=0
        if ([[self class] isSohuFeedItem:item] &&
            [item.news.title length] == 0) {
            item.titleHeight = 0;
        }
        
        titleHeight = fontSize + 2;
        if ([[SNDevice sharedInstance] isPlus]) {
            titleHeight += 7;
        }
    }
    item.titleHeight = titleHeight + ([item.news.title isContainsEmoji] ? 9 : 7);
}

+ (int)getTitleHeightWithItem:(SNRollingNewsTableItem *)item
                   isMultLine:(BOOL)isMultLine {
    return item.titleHeight - ([item.news.title isContainsEmoji] ? 9 : 7);
}

+ (void)setTableviewCellTitle:(SNRollingNewsTableItem *)item {
    BOOL isMultLine = [[self class] isMultiLineTitleWithItem:item];
    if (item.news.title && ![item.news.title isEqualToString:@""]) {
        @autoreleasepool {
            CTLineBreakMode breakMode = isMultLine?kCTLineBreakByWordWrapping:kCTLineBreakByTruncatingTail;
            NSMutableAttributedString *newsTitleString = [[NSMutableAttributedString alloc] initWithString:item.news.title];
            
            CGFloat lineSpace = 0.0f;
            lineSpace = ([[[UIDevice currentDevice] systemVersion] floatValue] == 9.1) ? -2 : 0;
            float iosVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
            lineSpace = (iosVersion > 8.0 && iosVersion <= 9.0) ? lineSpace + 2 : lineSpace;
            if ([item.news.title isContainsEmoji] && isMultLine) {
                lineSpace -= 3;
            }
            
            if (![SNDevice sharedInstance].isMoreThan320 && iosVersion > 9.0 && [SNUtility shownBigerFont]) {
                lineSpace -= 5;
            }
            
            UIFont *titleFont = [SNUtility getNewsTitleFont];
            [newsTitleString setNewsTitelParagraphStyleWithFont:titleFont lineBreakMode:breakMode lineSpace:lineSpace];
            item.titleString = newsTitleString;
        }
    }
}

+ (void)calculateCellHeight:(SNRollingNewsTableItem *)item {
    //计算需要的显示Cell的字符串和高度
    [[self class] setTableviewCellTitle:item];
    [[self class] setTableviewCellTitleHeight:item];
}

+ (CGFloat)getTitleWidth {
    int titleWidth = kAppScreenWidth - 2 * CONTENT_LEFT;
    return titleWidth;
}

+ (BOOL)isMultiLineTitleWithItem:(SNRollingNewsTableItem *)item {
    CGFloat titleWidth = [[self class] getTitleWidth:item];
    UIFont *titleFont = [SNUtility getNewsTitleFont];
    if (item.news.title && ![item.news.title isEqualToString:@""]) {
        CGSize titleSize = [item.news.title sizeWithFont:titleFont];
        if (titleSize.width > titleWidth) {
            return YES;
        }
    }
    return NO;
}

+ (CGFloat)getTitleWidth:(SNRollingNewsTableItem *)item {
    if (item.cellType == SNRollingNewsCellTypeAdBanner || item.cellType == SNRollingNewsCellTypeAdPicture || item.cellType == SNRollingNewsCellTypeVideo || item.cellType == SNRollingNewsCellTypeAdPhotos || item.cellType == SNRollingNewsCellTypeAdMixpicDownload || item.cellType == SNRollingNewsCellTypeAdBigpicDownload || item.cellType == SNRollingNewsCellTypeAdMixpicPhone || item.cellType == SNRollingNewsCellTypeAdBigpicPhone) {
        CGSize titleSize = [@"广告标题限制十三个汉字宽度" textSizeWithFont:[SNUtility getNewsTitleFont]];
        return titleSize.width;
    }
    
    return [[self class] getTitleWidth];
}

+ (CGFloat)titleMaxLineCount:(SNRollingNewsTableItem *)item {
    //PGC小视频
    if ((item.cellType == SNRollingNewsCellTypeAutoVideoMidImageType)) {
        return 3;
    }
    
    //流内组图模版相关广告和视频广告标题修改为单行显示
    if (item.cellType == SNRollingNewsCellTypeAdMixpicDownload ||
        item.cellType == SNRollingNewsCellTypeAdMixpicPhone ||
        item.cellType == SNRollingNewsCellTypeAdPhotos ||
        item.cellType == SNRollingNewsCellTypeVideo ||
        item.cellType == SNRollingNewsCellTypeAdVideoDownload) {
        return 1;
    }
    
    //feed模版
    if ([item.news isSohuFeed]) {
        return 4;
    }
    
    //by 5.9.4 wangchuanwen modify
    //图文带下载广告
    if (item.cellType == SNRollingNewsCellTypeAdSmallpicDownload) {
        return 2;
    }
    
    //图文新闻，广告
    if ([SNCellContentView hasImageCellType:item.cellType hasImage:item.hasImage]) {
        return 3;
    }
    //modify end
    
    return 2;
}

+ (BOOL)isSohuFeedItem:(SNRollingNewsTableItem *)item {
    return [item.news.newsType isEqualToString:@"74"] ? YES : NO;
}

- (void)reportPopularizeStatExposureInfo {
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier {
	self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        //contenView
        CGRect rect = CGRectMake(0.0, 0.0, kAppScreenWidth, self.contentView.bounds.size.height);
        self.cellContentView = [[SNCellContentView alloc] initWithFrame:rect];
        self.cellContentView.newsType = NEWS_ITEM_TYPE_NORMAL;
        self.cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.cellContentView];
    }
    return self;
}

- (void)updateTitleColor {
    if (self.item.news.isRead) {
        [self setReadStyleByMemory];
    }
}

- (void)updateContentView {
    [super updateContentView];
    self.item.delegate = self;
    self.item.selector = @selector(openNews);
    [self updateNewsContent];
    [self setReadStyleByMemory];
}

- (void)updateCellContentView {
    [self.cellContentView setNeedsDisplay];
}

- (void)updateNewsContent {
    BOOL hasImage = [self.item hasImage];
    
    self.cellContentView.titleWidth = [[self class] getTitleWidth:item];
    self.cellContentView.titleHeight = self.item.titleHeight;
    self.cellContentView.title = self.item.text;
    self.cellContentView.titleAttStr = self.item.titleString;
    self.cellContentView.commentNum = self.item.news.commentNum;
    self.cellContentView.videoMark  = [self.item hasVideo];
    self.cellContentView.voteMark = [self.item hasVote];
    self.cellContentView.picCount = self.item.news.listPicsNumber.intValue;

    self.cellContentView.titleLineCnt = item.titlelineCnt;
    self.cellContentView.newsId = self.item.news.newsId;
    self.cellContentView.isRecommend = self.item.isRecommend;
    self.cellContentView.hasImage = hasImage;
    self.cellContentView.media = self.item.news.media;
    self.cellContentView.time = self.item.news.updateTime;
    self.cellContentView.isSearch = self.item.isSearchNews;
    self.cellContentView.recomType = self.item.news.recomType;
    self.cellContentView.liveStatus = self.item.news.liveStatus;
    self.cellContentView.local = self.item.news.local;
    self.cellContentView.hasComments = [self.item hasComments];
    self.cellContentView.isFromSub = self.item.news.fromSub;
    self.cellContentView.cellType = self.item.cellType;
    self.cellContentView.playTime = self.item.news.playTime;
    self.cellContentView.newsType = self.item.type;
    self.cellContentView.isFlash = [self.item isFlashNews];
    self.cellContentView.isFinance = [self.item.news.newsId isEqualToString:@"20"];
    self.cellContentView.sponsorships = self.item.news.sponsorshipsObject.title;
    self.cellContentView.newsTypeString = [self.item getNewsTypeString];
    self.cellContentView.newsTypeTextString = [self.item getNewsTypeTextString];
    self.cellContentView.hasMoreButton = ![self.item hiddenMoreButton];
    self.cellContentView.hasDetailLink = self.item.news.link.length > 0 ? YES : NO;
    self.cellContentView.tvPlayNum = self.item.news.tvPlayNum;
    self.cellContentView.playVid = self.item.news.playVid;
    self.cellContentView.sourceName = self.item.news.sourceName;
    self.cellContentView.advertiser = self.item.news.newsAd.advertiser;///? : @"我是一个广告来源";
    
    self.cellContentView.bookAuthor = self.item.news.novelAuthor;
    self.cellContentView.bookType = self.item.news.novelCategory;
    
    self.cellContentView.recomReasons = self.item.news.recomReasons;
    self.cellContentView.recomTime = self.item.news.recomTime;
    if (!item.isSearchNews) {
        self.item.news.isRead = [self checkNewsRead];
    }
    
    [self setArticleRecommendBackgroundColor];
    self.accessibilityLabel = [self.cellContentView getVoiceOverText];
}

- (void)setArticleRecommendBackgroundColor {
    if (item.expressFrom == NewsFromArticleRecommend) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.cellContentView.backgroundColor = [UIColor clearColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    //by 5.9.4 wangchuanwen modify
    if (highlighted) {
        self.cellContentView.backgroundColor = SNUICOLOR(kThemeBg2Color);
    } else {
        self.cellContentView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
        [self setArticleRecommendBackgroundColor];
    }
    //modify end
}

- (BOOL)checkNewsRead {
    BOOL newsReaded = NO;
    NSString *newsId = self.item.news.newsId;
    NSString *channel = self.item.news.channelId;
    if(channel!=nil && newsId!=nil) {
        newsReaded = [SNRollingNewsPublicManager isReadNewsWithNewsId:newsId ChannelId:channel];
    }
    return newsReaded;
}

- (void)setNewsReadStyleByMemory {
    if (!item.isSearchNews) {
        self.item.news.isRead = [self checkNewsRead];
    }

    [self setReadStyleByMemory];
}

- (void)setReadStyleByMemory {
    currentReadStatus = CELL_READ_STYLE_NONE;
    if (self.item.news.isRead) {
        if (currentReadStatus != CELL_READ_STYLE_READ) {
            [self setAlreadyReadStyle];
        }
    } else {
        if (currentReadStatus != CELL_READ_STYLE_UNREAD) {
            [self setUnReadStyle];
        }
    }
    //5.9.3 wangchuanwen update
    self.cellContentView.markTextColor = SNUICOLOR(kThemeTextRI1Color);

    //搜索结果高亮显示关键字
    if (item.isSearchNews && item.keyWord) {
        NSRange titleRange = [self.cellContentView.titleAttStr.string rangeOfString:item.keyWord options:NSCaseInsensitiveSearch];
        if (titleRange.location != NSNotFound && titleRange.length > 0) {
            [self.cellContentView.titleAttStr setTextColor:RGBCOLOR(0xc8, 0, 0) range:titleRange];
        }
    }
    
    [self.cellContentView setNeedsDisplay];
}

- (void)setAlreadyReadStyle {
    //TODO:设置已读样式
    currentReadStatus = CELL_READ_STYLE_READ;
    [self.cellContentView.titleAttStr setTextColor:[[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color]];
}

- (void)setUnReadStyle {
    //TODO:设置未读样式
    currentReadStatus = CELL_READ_STYLE_UNREAD;
    //5.9.3 wangchuanwen update
    UIColor *color = SNUICOLOR(kThemeTextRIColor);
    [self.cellContentView.titleAttStr setTextColor:color];
}

- (void)updateTheme {
    [super updateTheme];
    //5.9.3 wangchuanwen update
    self.cellContentView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    self.cellContentView.markTextColor = SNUICOLOR(kThemeTextRI1Color);
    [self setReadStyleByMemory];
}

- (void)openNews {
    [SNUtility shouldUseSpreadAnimation:YES];
    
    if (item.cellType == SNRollingNewsCellTypeAppAd) {
        return;
    }
    
    NSTimeInterval nowclickTime = [[NSDate date] timeIntervalSince1970];
    if (nowclickTime - _lastClickTime > 0 &&
        nowclickTime - _lastClickTime < 0.5 &&
        [SNUtility isProtocolV2:[item.news.link URLDecodedString]]) {
        return;
    }
    _lastClickTime = nowclickTime;
    
    [item.controller cacheCellIndexPath:self];

#pragma mark huangjing 跳转到我的
    if (self.item.type == NEWS_ITEM_TYPE_SUBSCRIBE_NEWS) {
        //不知道为什么item.news.subId 没有取到 所以这里从链接里截出来
        NSString * subId = [[item.news.link componentsSeparatedByString:@"subId="] lastObject];
        subId = [[subId componentsSeparatedByString:@"&"] firstObject];
        if (subId.length > 0) {
            NSMutableDictionary * referInfo = [NSMutableDictionary dictionary];

            [referInfo setObject:self.item.news.newsId?:@"0" forKey:kReferValue];
            [referInfo setObject:@"Newsid" forKey:kReferType];
            [referInfo setObject:[NSNumber numberWithInt:SNProfileRefer_Subscribe_MeMedia] forKey:kRefer];
            [SNUtility openProtocolUrl:[NSString stringWithFormat:@"subHome://subId=%@",subId] context:referInfo];
        }
        
        return;
        
    }
#pragma mark huangjing 跳转到我的
    if (item.isSearchNews) {
        if (item.news.link.length > 0) {  //搜索新闻跳转
            NSMutableDictionary *context = [NSMutableDictionary dictionaryWithObjectsAndKeys:kReferFromSearch, kReferFrom, [NSNumber numberWithInt:REFER_SEARCH], kRefer, nil];
            if (item.news.updateTime) {
                [context setObject:item.news.updateTime forKey:kUpdateTime];
            }
            
            [SNUtility openProtocolUrl:item.news.link context:context];
        }
    } else {
        if (item.news.newsType != nil &&
            [SNCommonNewsController supportContinuation:item.news.newsType]) {
            
            if (nil != item.news.link
                && item.news.link.length > 0
                && [item.news.link hasPrefix:kProtocolChannel]) {
                [SNUtility openProtocolUrl:item.news.link];
            } else if (nil != item.news.link
                     && item.news.link.length > 0
                     && [item.news.link hasPrefix:kProtocolSpecial]) {//专题
                NSMutableDictionary *query = [NSMutableDictionary dictionaryWithCapacity:0];
                [query setObject:item.news.title forKey:kTitle];
                [query setObject:item.news.link forKey:kLink];
                [query setObject:item.news.picUrl forKey:kPhoto];
                [query setObject:[NSNumber numberWithInteger:SpecialWebViewType] forKey:kUniversalWebViewType];
                [query setObject:item.news.newsId forKey:kTermId];
                [SNUtility openUniversalWebView:query];
            } else {
                NSMutableDictionary *dic = [item.dataSource getContentDictionary:item.news] ;
                NSMutableDictionary *query = [NSMutableDictionary dictionary];
                if (dic.count > 0) {
                    if (item.expressFrom == NewsFromRecommend) {
                        [dic setObject:kChannelRecomNews forKey:kNewsFrom];
                    } else if (item.expressFrom == NewsFromChannel){
                        [dic setObject:kChannelEditionNews forKey:kNewsFrom];
                    }
                    
                    [query setValuesForKeysWithDictionary:dic];
                    
                    NSMutableDictionary *cNews = [[query objectForKey:kContinuityNews] mutableCopy];
                    if (cNews.count > 0) {
                        if ([self.item hasVideo]) {//视频新闻
                            if (self.item.news.isRecomNews) {
                                //打开 下接刷新即时新闻列表中推荐的视频新闻
                                [cNews setValue:@(SNRollingNewsVideoPosition_RecommVideoNews) forKey:kRollingNewsVideoPosition];
                            } else {
                                //打开 即时新闻列表中普通的视频新闻
                                [cNews setValue:@(SNRollingNewsVideoPosition_NormalVideoNews) forKey:kRollingNewsVideoPosition];
                            }
                        }
                        if (!([item.news.recomReasons isEqualToString:@"0"] || item.news.recomReasons.length == 0)) {
                            [cNews setValue:item.news.recomReasons forKey:kRecomReasons];
                        }
                        if (!([item.news.recomTime isEqualToString:@"0"] || item.news.recomTime.length == 0)) {
                            [cNews setValue:item.news.recomTime forKey:kRecomTime];
                        }
                        
                        [query setValue:cNews forKey:kContinuityNews];
                    }
                }
                [query setValue:[NSNumber numberWithBool:YES] forKey:kClickOpenNews];
                [query setValue:item.news.recomInfo forKey:kRecomInfo];
                
                TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://commonNewsController"] applyAnimated:YES] applyQuery:query];
                [[TTNavigator navigator] openURLAction:urlAction];
            }
        } else if(item.news.link.length > 0) {
            if ([item.news.link startWith:kProtocolVideo]) {//二代协议视频: video://
                NSMutableDictionary *query = [NSMutableDictionary dictionary];
                //判断此视频是否已离线，已离线则把视频对象进行离线播放
                SNVideoData *offlinePlayVideo = [self getDownloadVideoIfNeededWithLink2:item.news.link];
                if (!!offlinePlayVideo) {
                    query[kDataKey_TimelineVideo] = offlinePlayVideo;
                }
                //给视频subId
                [query setObject:item.news.subId forKey:kSubId];
                [query setObject:kChannelEditionNews forKey:kNewsFrom];
                
                if (self.item.news.isRecomNews) {//打开 下接刷新即时新闻列表中推荐的二代协议视频
                    query[kRollingNewsVideoPosition] = @(SNRollingNewsVideoPosition_RecommVideoLink2);
                    [SNUtility openProtocolUrl:item.news.link context:query];
                } else {//打开 即时新闻列表中普通的二代协议视频
                    query[kRollingNewsVideoPosition] = @(SNRollingNewsVideoPosition_NormalVideoLink2);
                    [SNUtility openProtocolUrl:item.news.link context:query];
                }
            } else {
                //直播加PV 加newsfrom字段  wyy
                if (self.item.type == NEWS_ITEM_TYPE_LIVE) {
                    NSMutableDictionary *query = [NSMutableDictionary dictionary];
                    NSString * currentChannelId = self.item.news.channelId;
                    [query setObject:currentChannelId forKey:kCurrentChannelId];
                    [query setObject:kChannelEditionNews forKey:kNewsFrom];
                    [SNUtility openProtocolUrl:item.news.link context:query];
                } else if (self.item.type == NEWS_ITEM_TYPE_AD) {
                    NSString *link = item.news.link;

                    //link = [NSString stringWithFormat:@"%@predownload:http://images.sohu.com/bill/a2017/0704/ChAiOVlbbOuAY8tpAAJxSpVwBo49210x0.zip",link];
                    if (item.news.newsAd.predownload && item.news.newsAd.predownload.length > 0) {
                        link = [link stringByAppendingString:[NSString stringWithFormat:@"%@%@",[SNUtility fullScreenADServerFlagString],item.news.newsAd.predownload]];
                        [SNUtility openProtocolUrl:link context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:FullScreenADWebViewType], kUniversalWebViewType, nil]];
                    } else {
                         [SNUtility openProtocolUrl:link context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:AdvertisementWebViewType], kUniversalWebViewType, nil]];
                    }
                } else if (self.item.cellType == SNRollingNewsCellTypeBookBanner) {
                    
                    NSString *linkStr = item.news.link;
                    NSString *titleStr = [item.news.title URLEncodedString];
                    NSRange range = [linkStr rangeOfString:@"?"];
                    
                    if (range.location != NSNotFound) {
                        if ((range.length + range.length) < linkStr.length) {
                            linkStr = [NSString stringWithFormat:@"%@&title=%@",item.news.link,titleStr];
                        } else {
                            linkStr = [NSString stringWithFormat:@"%@title=%@",item.news.link,titleStr];
                        }
                    } else {
                        linkStr = [NSString stringWithFormat:@"%@?title=%@",item.news.link,titleStr];
                    }
                    
                    [SNUtility openProtocolUrl:linkStr context:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:TimeFreeWebViewType], kUniversalWebViewType, nil]];
                } else {
                    if ([item.news.link hasPrefix:@"channel://"]) {
                        //频道跳转曝光统计
                        [self reportADotGif:item.news.link];
                    }
                    [SNUtility openProtocolUrl:item.news.link];
                    [self reportWebNews];
                }
            }
        }
    }
    
    
    if (self.item.type != NEWS_ITEM_TYPE_SUBSCRIBE_NEWS) {
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
    
    // 广告点击曝光
    if (self.item.type == NEWS_ITEM_TYPE_AD) {
        [self.item.news.newsAd reportAdClick:self.item.news];
    }
    
    //全网新闻点击统计
    if (item.isSearchNews && item.type == NEWS_TIEM_TYPE_OTHER_NEWS) {
        //CC统计
        SNUserTrack *userTrack= [SNUserTrack trackWithPage:search link2:nil];
        SNUserTrack *toUserTrak = [SNUserTrack trackWithPage:sohu_http_web link2:nil];
        NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [userTrack toFormatString], [toUserTrak toFormatString], f_search_getallinter];
        [SNNewsReport reportADotGifWithTrack:paramString];
    }
    
}

- (SNVideoData *)getDownloadVideoIfNeededWithLink2:(NSString *)link2 {
    NSString *vid = [[SNUtility parseLinkParams:link2] stringValueForKey:@"vid" defaultValue:nil];
    SNVideoDataDownload *downloadVideo = [[SNDBManager currentDataBase] queryDownloadVideoByVID:vid];
    SNVideoData *offlinePlayVideo = [[SNDBManager currentDataBase] getOfflinePlayVideoByVid:vid];
    NSString *localVideoRelativePath = downloadVideo.localRelativePath;
    if (localVideoRelativePath.length > 0) {
        NSString *localVideoAbsolutePath = [[SNVideoDownloadConfig rootDir] stringByAppendingPathComponent:localVideoRelativePath];
        offlinePlayVideo.sources = [NSMutableArray arrayWithObject:localVideoAbsolutePath];
    }
    return offlinePlayVideo;
}

- (void)reportADotGif:(NSString *)link {
    NSString *prefix = @"channel://";
    NSString *urlStr = [link substringFromIndex:prefix.length];
    NSArray *substrings = [urlStr componentsSeparatedByString:@"&"];
    
    NSString *toChannelId = @"";
    NSString *position = @"0";
    for (int x = 0; x < substrings.count; x++) {
        NSString *strPart = [substrings objectAtIndex:x];
        NSArray *partItem = [strPart componentsSeparatedByString:@"="];
        if (partItem.count>=2) {
            NSString *name = [partItem objectAtIndex:0];
            NSString *value = [partItem objectAtIndex:1];
            if (name&&value) {
                if ([name isEqualToString:@"channelId"]) {
                    toChannelId = value;
                } else if ([name isEqualToString:@"position"]) {
                    position = value;
                }
            }
        }
    }

    NSString *page = [item.news.link stringByReplacingOccurrencesOfString:@"&" withString:@"|"];
    NSString *paramStr = [NSString stringWithFormat:@"_act=channel2channel&_tp=pv&position=%@&channelid=%@&tochannelid=%@&track=1&page=1_%@",position, item.news.channelId, toChannelId,[page URLEncodedString]];
    [SNNewsReport reportADotGif:paramStr];
}

- (void)reportWebNews {
    //外链新闻
    if ([item.news.newsType isEqualToString:@"8"]) {
        SNRollingNews *news = item.news;
        
        NSString *pageString = [NSString stringWithFormat:@"%d_news://newsId=%@!!from=channel!!channelId=%@!!isHasSponsorships=%@!!position=%@!!page=%@!!CDN_URL=%@!!templateType=%@!!newsType=%@", sohu_http_web, news.newsId, news.channelId, news.isHasSponsorships, news.position, news.morePageNum, nil, news.templateType, news.newsType];
        
        SNUserTrack *userTrak = [SNUserTrack trackWithPage:sohu_http_web link2:nil];
        NSString *track = [userTrak toFormatString];
        NSString *newsFrom = [news.channelId isEqualToString:@"13557"] ? @"6" : @"5";
        
        NSString *reportString = [NSString stringWithFormat:@"_act=pv&page=%@&track=%@&newsfrom=%@", pageString, track, newsFrom];
        
        [SNNewsReport reportADotGif:reportString];
    }
}

- (CGFloat)getMoreImageTopValue {
    int fontSize = [SNUtility getNewsFontSizeIndex];
    float topValue = 0.0;
    if ([[SNDevice sharedInstance] isPlus]) {
        switch (fontSize) {
            case 2:
                topValue = -11.0;
                break;
            case 3:
                topValue = -5.0;
                break;
            case 4:
                topValue = -5.0;
                break;
                
            default:
                break;
        }
        
    } else {
        switch (fontSize) {
            case 2:
                topValue = 0.0;
                break;
            case 3:
                topValue = 2.0;
                break;
            case 4:
                topValue = 4.0;
                break;
            default:
                break;
        }
    }
    return topValue;
}

@end
