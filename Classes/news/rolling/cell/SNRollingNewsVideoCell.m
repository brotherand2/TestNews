//
//  SNRollingNewsVideoCell.m
//  sohunews
//
//  Created by cuiliangliang on 16/5/3.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsVideoCell.h"
#import "SNVideoAdContext.h"
#import "SNRollingNewsTitleCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "WSMVLoadingView.h"
#import "SNNewsAd+analytics.h"
#import "WSMVVideoPlayerView.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNNotificationManager.h"
#import "UIFont+Theme.h"
#import "SNUserManager.h"
#import "SNAutoPlayVideoContentView.h"
#import "SNActionMenuController.h"
#import "SNShareConfigs.h"
#import "SNNewsShareManager.h"

@interface SNRollingNewsVideoCell ()<SNCellMoreViewFullactionDelegate, SNCellMoreViewShareDelegate> {
    SNAutoPlayVideoContentView *autoPlayCellContentView;
    
    SNVideoData *playerData;
    SNNewsVideoInfo *video;
    BOOL _isPlay;
}
@property (nonatomic, strong) SNActionMenuController *actionMenuController;
@property (nonatomic, strong) SNNewsShareManager *shareManager;
@end

@implementation SNRollingNewsVideoCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object; 
    BOOL isMultLineTitle = [self isMultiLineTitleWithItem:newsItem];
    int titleHeight = [self getTitleHeightWithItem:newsItem
                                        isMultLine:isMultLineTitle];
    //by 5.9.4 wangchuanwen modify
    //item间距调整 cellHeight
    return VIDEO_CELL_PLAYERHEIGHT + titleHeight + kMoreButtonHeight + FEED_SPACEVALUE + 7;
    //modify end
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        CGRect cellContentViewFrame = CGRectMake(CONTENT_LEFT,
                                                 CONTENT_IMAGE_TOP,
                                                 FOCUS_IMAGE_WIDTH,
                                                 VIDEO_CELL_PLAYERHEIGHT);
        autoPlayCellContentView = [[SNAutoPlayVideoContentView alloc] initWithFrame:cellContentViewFrame];
        [self addSubview:autoPlayCellContentView];

        self.showSlectedBg = YES;
        _isPlay = NO;
        
        [SNNotificationManager addObserver:self selector:@selector(setCellRead:) name:kSNRollingNewViewCellReadNotification object:nil];
    }
    return self;
}
- (void)updateTheme {
    [super updateTheme];
    [self setNeedsDisplay];
    [autoPlayCellContentView updateTheme];
}

- (void)updateContentView {
    [super updateContentView];

    self.item.delegate = self;
    self.item.selector = @selector(didSelect);
    self.item.news.media = self.item.news.sourceName;
    [self updateNewsContent];
    [self setReadStyleByMemory];

    SNAutoPlaySharedVideoPlayer *player = [SNAutoPlaySharedVideoPlayer sharedInstance];
    if (![[player getMoviePlayer].currentPlayMedia.vid isEqualToString:self.item.news.playVid]) {
        //如果Cell复用视频还继续播放，停止播放
        player.poster.image = [UIImage themeImageNamed:@"zhan4_bg_pgchalf.png"];
        [self stopPlay];
    }
    
    if (nil == playerData) {
        playerData = [[SNVideoData alloc] init];
    }
    if (self.item.news.picUrl &&
        ![self.item.news.picUrl isKindOfClass:[NSNull class]]) {
        playerData.poster = self.item.news.picUrl;
        playerData.poster_4_3 = self.item.news.picUrl;
    }
    playerData.vid = self.item.news.playVid;
    playerData.newsId = self.item.news.newsId;
    playerData.videoUrl = [[SNVideoUrl alloc] init];
    playerData.isNewsVideo = YES;
    playerData.isRecommend = self.item.isRecommend;
    playerData.templateType = kNewsTypeRollingBigVideo;
    playerData.recomInfo = self.item.news.recomInfo;
    playerData.voidLink = self.item.news.link;
    if (self.item.news.tvPlayTime) {
        playerData.duration = [self.item.news.tvPlayTime integerValue];
    }
    if(self.item.news.channelId){//@qz reportSite.go接口需要 因此加
        playerData.channelId = [NSString stringWithFormat:@"%@",self.item.news.channelId];
    }
    if(self.item.news.newsType){//@qz reportSite.go接口需要 因此加
        playerData.newsType = [NSString stringWithFormat:@"%@",self.item.news.newsType];
    }
    SNVideoSiteInfo *siteinfo = [[SNVideoSiteInfo alloc] init];
    siteinfo.site2 = [NSString stringWithFormat:@"%d", self.item.news.siteValue];
    if (nil == siteinfo.site2 || siteinfo.site2.length <= 0) {
        siteinfo.site2 = @"2";
    }
    siteinfo.playById = @"1";
    siteinfo.siteId = self.item.news.playVid;
    siteinfo.playAd = @"0";
    playerData.siteInfo = siteinfo;
    
    [autoPlayCellContentView setObject:playerData];
    [autoPlayCellContentView setPlayStyle:AutoPlayStyleBigImage];
    BOOL isMultLineTitle = [[self class] isMultiLineTitleWithItem:self.item];
    int titleHeight = [[self class] getTitleHeightWithItem:self.item isMultLine:isMultLineTitle];
    if ([SNUtility shownBigerFont]) {
        titleHeight += 2;
    }
    
    [autoPlayCellContentView resetPlayerViewFrame:CGRectMake(CONTENT_LEFT, titleHeight + 17, FOCUS_IMAGE_WIDTH, VIDEO_CELL_PLAYERHEIGHT)];
}

- (void)autoPlay {
    SNAutoPlaySharedVideoPlayer *autoPlayerView = [SNAutoPlaySharedVideoPlayer sharedInstance];
    SNTimelineSharedVideoPlayerView *timelinePlayerView = [SNTimelineSharedVideoPlayerView sharedInstance];
    if (autoPlayerView.moviePlayer) {
        _isPlay = YES;
        if ([timelinePlayerView getMoviePlayer].playbackState == SHMoviePlayStatePlaying) {
            [SNTimelineSharedVideoPlayerView forceStop];
        }
        [autoPlayCellContentView autoPlayVideo];
    }
}

- (void)stopPlay {
    SNAutoPlaySharedVideoPlayer *play = [SNAutoPlaySharedVideoPlayer sharedInstance];
    if (_isPlay || [play getMoviePlayer].playbackState == SHMoviePlayStatePlaying) {
        _isPlay = NO;
        [SNAutoPlaySharedVideoPlayer forceStopVideo];
    }
}

- (void)moreAction {
    [super moreAction];
    if (self.moreView) {
        self.moreView.shareActionDelegate = self;
    }
}

- (void)setCellRead:(NSNotification *)notification{
    SNAutoPlayVideoContentView  *object= [notification object];
    if (object != autoPlayCellContentView) {
        return;
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
    
    //由于视频使用Gesture会影响UITableView的SetHighlight事件, 手动调用
    [self setHighlighted:NO animated:YES];
}

- (void)didSelect {
    
    if ([autoPlayCellContentView respondsToSelector:@selector(clickVideoPlay)]) {
        [autoPlayCellContentView performSelector:@selector(clickVideoPlay)];
    } else if ([autoPlayCellContentView respondsToSelector:@selector(toplayVideo:)]) {
        [autoPlayCellContentView toplayVideo:nil];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //记录播放视频cell位置
    CGRect frame = self.frame;
    [SNRollingNewsPublicManager sharedInstance].playerBigTop = frame.origin.y;
}

- (void)share {
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    
    NSString *vid = self.item.news.playVid;
    self.actionMenuController.shareSubType = ShareSubTypeQuoteCard;
    self.actionMenuController.isVideoShare = NO;
    self.actionMenuController.shareToLogin = ^(id objc) {
    };
    
//#if 1 //wangshun share test
    NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
    if (vid.length > 0) {
        [mDic setObject:vid forKey:@"vid"];
        [mDic setObject:[NSString stringWithFormat:@"vid=%@", vid] forKey:@"referString"];
    }
    NSString *protocol = [NSString stringWithFormat:@"%@vid=%@&from=channel&channelId=%@&templateType=%@",kProtocolVideoV2, vid, self.item.news.channelId, self.item.news.templateType];
    [mDic setObject:protocol forKey:@"url"];
    [mDic setObject:@"videotab" forKey:@"contentType"];
    
    SNTimelineOriginContentObject *obj = [[SNTimelineOriginContentObject alloc] init];
    obj.subId = @"video";
    obj.referId = vid;
    obj.link = protocol;
    obj.type = SNTimelineOriginContentTypeTextAndPics;
    obj.sourceType = SNShareSourceTypeVedioTab;
    if (obj) {
        [mDic setObject:obj forKey:kShareInfoKeyShareRead];
    }
    [mDic setObject:@"video" forKey:@"shareLogType"];
    [mDic setObject:@"141" forKey:@"sourceType"];
    
    //NEWSCLIENT-20841    V5.9.6_1018_分享：流内pgc视频分享到第三方数据有误 wangshun
    [mDic setObject:@"2" forKey:@"site"];
    
    [self callShare:mDic];
}

- (void)callShare:(NSDictionary *)paramsDic {
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

- (void)openNews {
    
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kSNRollingNewViewCellReadNotification object:nil];
}

@end
