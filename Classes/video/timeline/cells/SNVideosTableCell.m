//
//  SNVideosTableCell.m
//  sohunews
//
//  Created by chenhong on 13-9-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideosTableCell.h"
#import "SNWebImageView.h"
#import "UIColor+ColorUtils.h"
#import "SNTimelineVideoCellContentView.h"
#import "SNTimelineSharedVideoPlayerView.h"

#define kVideosCellScale          .7f
#define kSmallScalePadding        6.f

@interface SNVideosTableCell()
@property (nonatomic, strong)SNTimelineVideoCellContentView *cellContentView;
@end

@implementation SNVideosTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //Cell content view
        CGRect cellContentViewFrame = CGRectMake(0, 0, kAppScreenWidth, [[self class] height]);
        self.cellContentView = [[SNTimelineVideoCellContentView alloc] initWithFrame:cellContentViewFrame];
        self.cellContentView.delegate = self;
        [self addSubview:self.cellContentView];
        
        //Screen rotation observer
        [self beginMonitorDeviceOrientationChange];
    }
    return self;
}

- (void)dealloc {
    self.cellContentView.delegate = nil;
    [self endMonitorDeviceOrientationChange];
    
}

- (void)setObject:(SNVideoData *)object {
    [super setObject:object];
    [self.cellContentView setObject:object];
    
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    player.frame = CGRectMake(kTimelineVideoCellSubContentViewsSideMargin,
                                                        kTimelineVideoCellSubContentViewsTopMargin,
                                                        kTimelineContentViewWidth,
                                                        kPlayerViewHeight);
    player.moviePlayer.view.frame = player.bounds;
    player.loadingMaskView.loadingView.center = player.posterPlayBtn.center;
    player.controlBarFullScreen.previousVideoBtn.enabled = YES;
    player.controlBarFullScreen.nextVideoBtn.enabled = YES;
}

- (void)updateFullscreenBtn {
    [self.cellContentView updateFullscreenBtn];
}

- (void)updateDownloadBtn {
    [self.cellContentView updateDownloadBtn];
}

+ (CGFloat)height {
    return kTimelineVideoCellHeight;
}

#pragma mark - Override
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    //空实现，为了不让cell有按下效果
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //空实现，为了不让cell有按下效果
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        if ([self.videosTableViewController respondsToSelector:@selector(didEndDisplayingCell:)]) {
            [self.videosTableViewController didEndDisplayingCell:self];
        }
    }
}

#pragma mark - Public
- (void)playVideoIfNeeded {
    SNTimelineSharedVideoPlayerView *player = [SNTimelineSharedVideoPlayerView sharedInstance];
    player.frame = CGRectMake(kTimelineVideoCellSubContentViewsSideMargin,
                              kTimelineVideoCellSubContentViewsTopMargin,
                              kTimelineContentViewWidth,
                              kPlayerViewHeight);
    player.moviePlayer.view.frame = player.bounds;
    player.loadingMaskView.loadingView.center = player.posterPlayBtn.center;
    player.controlBarFullScreen.previousVideoBtn.enabled = YES;
    player.controlBarFullScreen.nextVideoBtn.enabled = YES;
    [self.cellContentView playVideoIfNeeded];
}

- (void)playVideoIfNeededIn2G3G {
    [self.cellContentView playVideoIfNeededIn2G3G];
}

- (void)stopVideoPlayIfPlaying {
    [self.cellContentView stopVideoPlayIfPlaying];
}

#pragma mark - Private
#pragma mark - Rotation
- (void)beginMonitorDeviceOrientationChange {
    UIDevice *device = [UIDevice currentDevice]; //Get the device object
    [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
    [SNNotificationManager addObserver:self//Add self as an observer
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:device];
}

- (void)endMonitorDeviceOrientationChange {
    UIDevice *device = [UIDevice currentDevice];
    [SNNotificationManager removeObserver:self name:UIDeviceOrientationDidChangeNotification object:device];
    [device endGeneratingDeviceOrientationNotifications];
}

- (void)orientationChanged:(NSNotification *)notification {
    //是否要响应旋转
    BOOL canRespondRotate = YES;
    if ([self.delegate respondsToSelector:@selector(canRespondRotate)]) {
        canRespondRotate = [self.delegate canRespondRotate];
    }
    if (!canRespondRotate) {
        return;
    }
    
    //如果播放器所在cell不是当前cell，那么当前cell不感知转屏
    SNTimelineSharedVideoPlayerView *playerView = [SNTimelineSharedVideoPlayerView sharedInstance];
    if (![playerView.playingVideoModel.sPlayID isEqualToString:self.object.vid]) {
        SNDebugLog(@"Neednt rotate, player view not in current cell.");
        return;
    }
    
    //---
    id obj = notification.object;
    if ([obj isKindOfClass:[UIDevice class]]) {
        UIDeviceOrientation o = [(UIDevice *)obj orientation];
        switch (o) {
            case UIDeviceOrientationPortrait: {
                NSLogError(@"##################Vertically, home button bottom");
                break;
            }
            case UIDeviceOrientationPortraitUpsideDown: {
                NSLogError(@"##################Vertically, home button top");
                break;
            }
            case UIDeviceOrientationLandscapeLeft: {
                NSLogError(@"##################Horizontally, home button right");
                break;
            }
            case UIDeviceOrientationLandscapeRight: {
                NSLogError(@"##################Horizontally, home button left");
                break;
            }
            default:
                break;
        }
        
        //没有播放则不能自动全屏
        BOOL isStopped = !([SNTimelineSharedVideoPlayerView sharedInstance].playingVideoModel);
        if (isStopped) {
            SNDebugLog(@"Neednt rotate, player view is stopped.");
            return;
        }

        //已转为横屏：
        if ((o == UIDeviceOrientationLandscapeLeft || o == UIDeviceOrientationLandscapeRight)
            && ![self.cellContentView isFullScreen]
            && ([self.cellContentView isPlaying] || [self.cellContentView isPaused] || [self.cellContentView isLoading])) {
            [self.cellContentView videoToFullScreen];
        }

        //已转为竖屏：如果当前是全屏，则变为竖屏时则自动恢复到非全屏
        if ((o == UIDeviceOrientationPortrait || o == UIDeviceOrientationPortraitUpsideDown)
            && [self.cellContentView isFullScreen]) {
            [self.cellContentView videoExitFullScreen];
        }
    }
}

#pragma mark - 2G3G提示
- (void)alert2G3GIfNeededByStyle:(WSMV2G3GAlertStyle)style forPlayerView:(WSMVVideoPlayerView *)playerView {
    if ([self.delegate respondsToSelector:@selector(alert2G3GIfNeededByStyle:forPlayerView:)]) {
        [self.delegate alert2G3GIfNeededByStyle:style forPlayerView:playerView];
    }
}

#pragma mark - SNTimelineVideoCellContentViewDelegate
- (void)toVideoDetailPage:(SNVideoData *)videoItem {
    if ([self.delegate respondsToSelector:@selector(toVideoDetailPage:)]) {
        [self.delegate toVideoDetailPage:videoItem];
    }
}

- (BOOL)isTableViewControllerLoading {
    BOOL isLoading = NO;
    if ([self.delegate respondsToSelector:@selector(isTableViewControllerLoading)]) {
        isLoading = [self.delegate isTableViewControllerLoading];
    }
    return isLoading;
}

- (BOOL)isVideoTimelineVisiable {
    if ([self.delegate respondsToSelector:@selector(isVideoTimelineVisiable)]) {
        return [self.delegate isVideoTimelineVisiable];
    } else {
        return YES;
    }
}

@end;
