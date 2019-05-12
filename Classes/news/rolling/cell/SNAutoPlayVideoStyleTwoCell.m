//
//  SNAutoPlayVideoStyleTwoCell.m
//  sohunews
//
//  Created by cuiliangliang on 16/6/15.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNAutoPlayVideoStyleTwoCell.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNAutoPlayVideoContentView.h"
#import "SNShareConfigs.h"
#import "SNTimelineSharedVideoPlayerView.h"
#import "SNPickStatisticRequest.h"
#import "SNNewsShareManager.h"

@interface SNAutoPlayVideoStyleTwoCell () {
    SNVideoData *playerData;
    BOOL _isPlay;
}

@property (nonatomic, strong) SNActionMenuController *actionMenuController;
@property (nonatomic, strong) SNNewsShareManager *shareManager;
@property (nonatomic, strong) SNAutoPlayVideoContentView *autoPlayVideoContentView;

@end

@implementation SNAutoPlayVideoStyleTwoCell

+ (CGFloat)tableView:(UITableView *)tableView 
  rowHeightForObject:(id)object {
    CGFloat height = kMiddleVideoImageHeight;
    
    CGFloat offsetValue = 0;
    if ([SNUtility shownBigerFont] ||
        [SNUtility changePGCLayOut]) {
        offsetValue = 17;
    }
    return height + IMAGE_TOP * 2 + offsetValue;
}

+ (CGFloat)getTitleWidth {
    CGFloat width = kMiddleVideoImageWidth;
    CGFloat titleWidth = kAppScreenWidth - 2 * CONTENT_LEFT - width - CELL_IMAGE_TITLE_DISTANCE;
    return titleWidth;
}

+ (CGFloat)getAbstractWidth {
    CGFloat width = kMiddleVideoImageWidth;
    CGFloat titleWidth = kAppScreenWidth - 2 * CONTENT_LEFT - width - CELL_IMAGE_TITLE_DISTANCE;
    return titleWidth;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier {
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        //Imageview
        CGFloat width = (kAppScreenWidth - 14 * 2) / 2;
        CGFloat height = (CGFloat)((kAppScreenWidth - 14 * 2) * 212 / 656.0);
        CGRect imageViewRect = CGRectMake(CONTENT_LEFT, IMAGE_TOP, width, height);
        self.autoPlayVideoContentView = [[SNAutoPlayVideoContentView alloc] initWithFrame:imageViewRect];
        [self addSubview:self.autoPlayVideoContentView];
        _isPlay = NO;
        
        [SNNotificationManager addObserver:self selector:@selector(setCellRead:) name:kSNRollingNewViewCellReadNotification object:nil];
    }
    return self;
}

- (void)openNews {
    if (self.autoPlayVideoContentView.isToPlay) {
        self.autoPlayVideoContentView.isToPlay = NO;
        return;
    }
    self.autoPlayVideoContentView.isMinToPlay = YES;
    NSTimeInterval currentPlaybackTime = 0;
    SNAutoPlaySharedVideoPlayer *play = [SNAutoPlaySharedVideoPlayer sharedInstance];
    if (play.moviePlayer) {
        if ([play getMoviePlayer].currentPlayMedia && [[play getMoviePlayer].currentPlayMedia.vid isEqualToString:self.item.news.playVid] ) {
            currentPlaybackTime = [play getMoviePlayer].currentPlaybackTime*1000;
        }
        //更新图片
        [self.autoPlayVideoContentView stopVideo];
    }
    [SNUtility shouldAddAnimationOnSpread:NO];
    
    NSString *channeled = self.item.isRecommend ? @"1300030009" : @"1300030008";
    
    //lijian 20171021 去掉了sourcedata 里的 \"getad\":0 解决了pgc视频不能受配置有没有广告。
    NSString *url = nil;
    if (self.item.news.recomInfo != nil && [self.item.news.recomInfo length] > 0) {
        url = [NSString stringWithFormat:@"sohunewsvideosdk://sva://action.cmd?action=1.1&vid=%@&site=2&position=%f&more={\"sourcedata\":{\"channeled\":\"%@\",\"type\":2,\"newsId\":\"%@\",\"recomInfo\":\"%@\"}}", self.item.news.playVid,currentPlaybackTime, channeled, self.item.news.newsId, self.item.news.recomInfo];
    }
    else {
        url = [NSString stringWithFormat:@"sohunewsvideosdk://sva://action.cmd?action=1.1&vid=%@&site=2&position=%f&more={\"sourcedata\":{\"channeled\":\"%@\",\"type\":2,\"newsId\":\"%@\"}}", self.item.news.playVid,currentPlaybackTime, channeled, self.item.news.newsId];
    }
    [[ActionManager defaultManager] handleUrl:url];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:kChannelEditionNews forKey:kNewsFrom];
    if (self.item.isRecommend) {
        [dic setObject:kChannelRecomNews forKey:kNewsFrom];
    }

    if (self.item.type != NEWS_ITEM_TYPE_SUBSCRIBE_NEWS) {
        NSString *newsId = self.item.news.newsId;
        NSString *channel = self.item.news.channelId;
        if (channel != nil && newsId != nil) {
            [SNRollingNewsPublicManager saveReadNewsWithNewsId:newsId
                                                     ChannelId:channel];
        }
        self.item.news.isRead = YES;
        [self setReadStyleByMemory];
    }
     
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:@"pgc_video" forKey:@"_act"];
    [params setValue:@"clk" forKey:@"_tp"];
    [params setValue:self.item.news.playVid forKey:@"vid"];
    [params setValue:self.item.news.channelId forKey:@"channelId"];
    [params setValue:self.item.news.newsId forKey:@"newsId"];
    [params setValue:self.item.news.recomInfo ? : @"" forKey:@"recomInfo"];
    [params setValue:[SNUtility sharedUtility].currentChannelId forKey:@"channelid"];
    [[[SNPickStatisticRequest alloc] initWithDictionary:params andStatisticType:PickLinkDotGifTypeA] send:nil failure:nil];
    
    SNUserTrack *curPage = [SNUserTrack trackWithPage:video_sohuPGC link2:url];
    NSInteger fromPage = 5;
    if (self.item.isRecommend) {
        fromPage = 6;
    }
    SNUserTrack *fromPageTrack = [SNUserTrack trackWithPage:fromPage link2:nil];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [fromPageTrack toFormatString], f_open];
    [SNNewsReport reportADotGifWithTrack:paramString];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    //记录播放视频cell位置
    CGRect frame = self.frame;
    [SNRollingNewsPublicManager sharedInstance].playerMinTop = frame.origin.y;
}

- (void)updateContentView {
    self.item.news.media = self.item.news.sourceName;
    [super updateContentView];
    [self updateImage];

    if (nil == playerData) {
        playerData = [[SNVideoData alloc] init];
    }
    if (self.item.news.picUrl &&
        ![self.item.news.picUrl isKindOfClass:[NSNull class]]) {
        playerData.poster = self.item.news.picUrl;
        playerData.poster_4_3 = self.item.news.picUrl;
    }
    playerData.vid = self.item.news.playVid;
    playerData.videoUrl = [[SNVideoUrl alloc] init];
    playerData.isNewsVideo = YES;
    playerData.templateType = kNewsTypeRollingMiddleVideo;
    if (self.item.news.tvPlayTime) {
        playerData.duration = [self.item.news.tvPlayTime integerValue];
    }
    SNVideoSiteInfo *siteinfo = [[SNVideoSiteInfo alloc] init];
    siteinfo.site2 = [NSString stringWithFormat:@"%d", self.item.news.siteValue];
    if (nil == siteinfo.site2 ||
        siteinfo.site2.length <= 0) {
        siteinfo.site2 = @"2";
    }
    siteinfo.playById = @"1";
    siteinfo.siteId = self.item.news.playVid;
    siteinfo.playAd = @"0";
    playerData.siteInfo = siteinfo;
    playerData.isRecommend = self.item.isRecommend;
    playerData.recomInfo = self.item.news.recomInfo;
    
    //如果Cell复用视频还继续播放，停止播放
    SNAutoPlaySharedVideoPlayer *player = [SNAutoPlaySharedVideoPlayer sharedInstance];
    if (![[player getMoviePlayer].currentPlayMedia.vid isEqualToString:self.item.news.playVid]) {
        player.poster.image = [UIImage themeImageNamed:@"zhan4_bg_pgchalf.png"];
        [self stopPlay];
    }
    
    [self.autoPlayVideoContentView setObject:playerData];
    [self.autoPlayVideoContentView setPlayStyle:AutoPlayStyleMinImage];
    CGRect imageViewRect = CGRectMake(CONTENT_LEFT, IMAGE_TOP,
                                      kMiddleVideoImageWidth,
                                      kMiddleVideoImageHeight);
    [self.autoPlayVideoContentView resetPlayerViewFrame:imageViewRect];
}

- (void)autoPlay {
    SNAutoPlaySharedVideoPlayer *play = [SNAutoPlaySharedVideoPlayer sharedInstance];
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    if (/*[player getMoviePlayer].playbackState != SHMoviePlayStatePlaying &&*/
        play.moviePlayer) {
        //自动播放, 清除TimeLine
        if ([player getMoviePlayer].playbackState == SHMoviePlayStatePlaying) {
            [SNTimelineSharedVideoPlayerView forceStop];
        }
        _isPlay = YES;
        [self.autoPlayVideoContentView autoPlayVideo];
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

- (void)updateTheme {
    [super updateTheme];
    [self setNeedsDisplay];
    [self.autoPlayVideoContentView updateTheme];
}

- (void)share {
    if (nil == self.actionMenuController) {
        self.actionMenuController = [[SNActionMenuController alloc] init];
    }
    NSString *vid =self.item.news.playVid;
    self.actionMenuController.shareSubType = ShareSubTypeQuoteCard;
    self.actionMenuController.isVideoShare = NO;
    
    self.actionMenuController.shareToLogin = ^(id objc) {
    };
    
#if 1 //wangshun share test
    NSMutableDictionary* mDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    if (vid.length > 0) {
        [mDic setObject:vid forKey:@"vid"];
        [mDic setObject:[NSString stringWithFormat:@"vid=%@",vid] forKey:SNNewsShare_ShareOn_referString];
    }
    NSString *protocol = [NSString stringWithFormat:@"%@vid=%@&from=channel&channelId=%@&templateType=%@",kProtocolVideoV2, vid, self.item.news.channelId, self.item.news.templateType];
    
//    SNTimelineOriginContentObject *oobj = [[SNTimelineOriginContentObject alloc] init];
//    oobj.subId = @"video";
//    oobj.referId = vid;
//    oobj.link = protocol;
//    oobj.type = SNTimelineOriginContentTypeTextAndPics;
//    oobj.sourceType = SNShareSourceTypeVedioTab;
//    if (oobj) {
//        [mDic setObject:oobj forKey:kShareInfoKeyShareRead];
//    }
    
    [mDic setObject:protocol forKey:SNNewsShare_Url];
    [mDic setObject:@"videotab" forKey:SNNewsShare_ShareOn_contentType];
    NSString *sourceType = [NSString stringWithFormat:@"%d",SNShareSourceTypeVedioTab];
    [mDic setObject:sourceType forKey:SNNewsShare_V4Upload_sourceType];
    [mDic setObject:@"video" forKey:SNNewsShare_LOG_type];
    [self callShare:mDic];
    return;
#endif
    
    NSMutableDictionary *dicShareInfo = [NSMutableDictionary dictionary];
    if (vid.length > 0) {
        [dicShareInfo setObject:vid forKey:@"vid"];
        [dicShareInfo setObject:[NSString stringWithFormat:@"vid=%@",vid] forKey:@"referString"];
    }
    NSString *protocolUrl = [NSString stringWithFormat:@"%@vid=%@&from=channel&channelId=%@&templateType=%@",kProtocolVideoV2, vid, self.item.news.channelId, self.item.news.templateType];
    
    SNTimelineOriginContentObject *shareRead = [[SNTimelineOriginContentObject alloc] init];
    shareRead.subId = @"video";
    shareRead.referId = vid;
    shareRead.link = protocolUrl;
    shareRead.type = SNTimelineOriginContentTypeTextAndPics;
    shareRead.sourceType = SNShareSourceTypeVedioTab;
    if (shareRead) {
        [dicShareInfo setObject:shareRead forKey:kShareInfoKeyShareRead];
    }
    self.actionMenuController.contextDic = dicShareInfo;
    [self.actionMenuController.contextDic setObject:protocolUrl forKey:@"url"];
    [self.actionMenuController.contextDic setObject:@"videotab" forKey:@"contentType"];
    self.actionMenuController.shareLogType = @"video";
    self.actionMenuController.disableLikeBtn = NO;
    self.actionMenuController.isLiked = NO;
    self.actionMenuController.sourceType = 141;
    [self.actionMenuController showActionMenu];

}

- (void)callShare:(NSDictionary *)paramsDic {
    if (self.shareManager) {
        self.shareManager = nil;
    }
    self.shareManager = [SNNewsShareManager loadShareData:paramsDic Delegate:self];
}

- (void)setCellRead:(NSNotification *)notification{
    SNAutoPlayVideoContentView  *object= [notification object];
    if (object != self.autoPlayVideoContentView) {
        return;
    }
    //设置数据库已读
    NSString *newsId = self.item.news.newsId;
    NSString *channel = self.item.news.channelId;
    if(channel!=nil && newsId!=nil){
        [SNRollingNewsPublicManager saveReadNewsWithNewsId:newsId ChannelId:channel];
    }
    //内存已读
    self.item.news.isRead = YES;
    [self setReadStyleByMemory];
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self name:kSNRollingNewViewCellReadNotification object:nil];
}

@end
