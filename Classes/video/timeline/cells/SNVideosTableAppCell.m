//
//  SNVideosTableAdCell.m
//  sohunews
//
//  Created by handy wang on 12/27/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNVideosTableAppCell.h"
#import "SNWebImageView.h"
#import "SNTimelineSharedVideoPlayerView.h"

@interface SNVideosTableAppCell()
@property (nonatomic, strong)UIImageView *bgImageView;
@property (nonatomic, strong)UIView *defaultView;
@property (nonatomic, strong)SNWebImageView *appImageView;
@property (nonatomic, strong)UITapGestureRecognizer *tapGesture;
@end

@implementation SNVideosTableAppCell

#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        //Bg imageview
        CGRect bgViewFrame = CGRectMake(kTimelineCellBgViewSideMargin,
                                        kTimelineVideoCellSubContentViewsTopMargin,
                                        320-2*kTimelineCellBgViewSideMargin,
                                        [[self class] height]-2*kTimelineVideoCellSubContentViewsTopMargin);
        _bgImageView = [[UIImageView alloc] initWithFrame:bgViewFrame];
        _bgImageView.image = [[UIImage imageNamed:@"timeline_videoplay_cellbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)];
        _bgImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_bgImageView];
        
        //Ad imageview
        _appImageView = [[SNWebImageView alloc] initWithFrame:CGRectMake(kTimelineVideoCellSubContentViewsSideMargin,
                                                                        kTimelineVideoCellSubContentViewsTopMargin+2,
                                                                        kTimelineContentViewWidth,
                                                                        kVideosAppContentHeight-4)];
        _appImageView.clipsToBounds = YES;
        _appImageView.alpha = themeImageAlphaValue();
        _appImageView.contentMode = UIViewContentModeScaleAspectFill;
        _appImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_appImageView];
        
        _defaultView = [[UIView alloc] initWithFrame:_appImageView.frame];
        _defaultView.backgroundColor = [UIColor colorFromString:@"#e5e5e5"];
        UIImageView *defaultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"photo_list_default2.png"]];
        defaultImageView.backgroundColor = [UIColor clearColor];
        [_defaultView addSubview:defaultImageView];
        defaultImageView.center = _defaultView.center;
        [self addSubview:_defaultView];
        
        //Tap gesture
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openIt)];
        [self addGestureRecognizer:_tapGesture];
        
        //Notifications
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleApplicationDidBecomeActive:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [SNNotificationManager addObserver:self
                                                 selector:@selector(handleVideosViewControllerWillAppearNotification:)
                                                     name:kVideosViewControllerWillAppearNotification
                                                   object:nil];
        [SNNotificationManager addObserver:self selector:@selector(updateTheme:) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
    
    self.tapGesture.delegate = nil;
}

#pragma mark - Override
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {}

+ (CGFloat)height {
    return kVideosAppCellHeight;
}

- (void)setObject:(SNVideoData *)object {
    [super setObject:object];
    [self refreshAppImage];
    
    // 出现一次  就发一个曝光统计
    SNAppAdActionType actionType = [SNUtility isWhiteListURL:[NSURL URLWithString:self.object.appURLSchemaOfAppWillBeOpen]] ? SNAppAdActionTypeOpen : SNAppAdActionTypeDownload;
    [self reportParamsWithTpString:@"show" actionType:actionType];
}

#pragma mark - Private
- (void)openIt {
    [SNTimelineSharedVideoPlayerView fakeStop];
    [SNTimelineSharedVideoPlayerView forceStop];
    
    // video banner 点击cc统计
    SNUserTrack *curPage = [SNUserTrack trackWithPage:video_banner link2:nil];
    SNUserTrack *toPage = [SNUserTrack trackWithPage:video_apps link2:self.object.appIdOfAppWillBeOpen];
    NSString *paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage toFormatString], [toPage toFormatString], f_open];
    [SNNewsReport reportADotGifWithTrack:paramString];
    
    
    // 是否是http网页连接(自定义的wap页与App下载无关)
    if([SNAPI isWebURL:self.object.appURLSchemaOfAppWillBeOpen]){
        [SNUtility openProtocolUrl:self.object.appURLSchemaOfAppWillBeOpen];
        SNDebugLog(@"Open http link from url schema.");
        [self reportAppClickAnalyticsWithActionType:SNAppAdActionTypeOpen];
        return;
    }
    
    // 非http 非app url scheme的可能会打开的二代协议(客户端自己支持的二代协议协议)
    if (self.object.appURLSchemaOfAppWillBeOpen
        && ![SNUtility isWhiteListURL:[NSURL URLWithString:self.object.appURLSchemaOfAppWillBeOpen]]
        && [SNUtility openProtocolUrl:self.object.appURLSchemaOfAppWillBeOpen context:@{@"onlySohuLink": @(1)}]) {
        SNDebugLog(@"Open link2 from url schema.");
        [self reportAppClickAnalyticsWithActionType:SNAppAdActionTypeOpen];
        return;
    }
    
    // 某个app的url scheme
    // 如果安装了某个app 直接打开（打开已安装的App）
    if (self.object.appURLSchemaOfAppWillBeOpen
        && [SNUtility isWhiteListURL:[NSURL URLWithString:self.object.appURLSchemaOfAppWillBeOpen]]) {
        SNDebugLog(@"Open app from url schema.");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.object.appURLSchemaOfAppWillBeOpen]];
        [self reportAppClickAnalyticsWithActionType:SNAppAdActionTypeOpen];
    }
    // 没有的话 打开appstore(6.0系统以上打开内置AppStore、6.0系统以下打开外置AppStore)
    else {
        // 6.0系统以上 可以在app内直接打开appstore 否则 跳转下载网页
        if (![[SNUtility getApplicationDelegate] canOpenInnerAppStoreWithAppId:self.object.appIdOfAppWillBeOpen]) {
            SNDebugLog(@"Open appstore app from app download link.");
            
            //6.0系统以下打开外置AppStore
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.object.appDownloadLink]];
        }
        [self reportAppClickAnalyticsWithActionType:SNAppAdActionTypeDownload];
    }
    
    // 统计cc
    SNUserTrack *curPage1 = [SNUserTrack trackWithPage:tab_video link2:nil];
    paramString = [NSString stringWithFormat:kAnalyticsUrlCC, [curPage1 toFormatString], [toPage toFormatString], f_open];
    [SNNewsReport reportADotGifWithTrack:paramString];
}

- (NSString *)bannerURLPath {
    return (self.object.appURLSchemaOfAppWillBeOpen && [SNUtility isWhiteListURL:[NSURL URLWithString:self.object.appURLSchemaOfAppWillBeOpen]]) ? self.object.bannerImgURLOfOpenApp : self.object.bannerImgURLOfDownloadApp;
}

- (void)handleApplicationDidBecomeActive:(NSNotification *)notification {
    [self refreshAppImage];
}

- (void)handleVideosViewControllerWillAppearNotification:(NSNotification *)notification {
    [self refreshAppImage];
}

- (void)updateTheme:(NSNotification *)notification {
    _bgImageView.image = [[UIImage imageNamed:@"timeline_videoplay_cellbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(16, 16, 16, 16)];
    self.appImageView.alpha = themeImageAlphaValue();
}

- (void)refreshAppImage {
    NSString *bannerURLPath = [self bannerURLPath];
    SNDebugLog(@"BannerURLPath is %@", bannerURLPath);
    [_appImageView loadUrlPath:bannerURLPath completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        _appImageView.contentMode = UIViewContentModeScaleAspectFill;
        _defaultView.hidden = YES;
    }];
}

#pragma mark - 统计

- (void)reportAppClickAnalyticsWithActionType:(SNAppAdActionType)actionType {
    [self reportParamsWithTpString:@"click" actionType:actionType];
}

//换量app 曝光 点击统计
- (void)reportParamsWithTpString:(NSString *)string actionType:(SNAppAdActionType)actionType {
    NSString *reportString = [NSString stringWithFormat:@"_act=app&tp=%@%_refer=40", string];
    if (actionType == SNAppAdActionTypeDownload) {
        reportString = [reportString stringByAppendingString:@"&todo=download"];
    }
    else if (actionType == SNAppAdActionTypeOpen) {
        reportString = [reportString stringByAppendingString:@"&todo=open"];
    }
    
    [SNNewsReport reportADotGifWithTrack:reportString];
}

@end
