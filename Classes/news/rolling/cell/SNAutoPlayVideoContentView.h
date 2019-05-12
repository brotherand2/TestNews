//
//  SNAutoPlayVideoContentView.h
//  sohunews
//
//  Created by cuiliangliang on 16/6/15.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNVideoObjects.h"
#import "WSMVVideoPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>

#define kMiddleVideoImageHeight (kMiddleVideoImageWidth * (9.0f / 16.0f))
#define kMiddleVideoImageWidth ((kAppScreenWidth > 375.0) ? (580.0 / 3) : ((kAppScreenWidth == 320.0) ? 292.0 / 2 : 332.0 / 2))

typedef enum {
    AutoPlayStyleBigImage = 0,//大图播放
    AutoPlayStyleMinImage = 1,//中图播放
} AutoPlayStyle;

@protocol SNAutoPlaySharedVideoPlayerDelegate
- (void)clickVideoPlay;
- (void)updateProgress;
- (void)stopToUpdateProgress;
- (void)videoDidFinishByPlaybackError;
- (void)videoToPlay;
@end

@interface SNAutoPlaySharedVideoPlayer: WSMVVideoPlayerView
@property (nonatomic, assign) NSInteger currentIndex;

#pragma mark - SharedInstance
+ (SNAutoPlaySharedVideoPlayer *)sharedInstance;
+ (void)forceStopVideo;
@end

@interface SNAutoPlayVideoContentView : UIView
@property (nonatomic, strong) SNVideoData *object;
@property (nonatomic, assign) BOOL isEditMode;
@property (nonatomic, assign) BOOL isClickPlay;
@property (nonatomic, assign) BOOL isToPlay;
@property (nonatomic, assign) BOOL isMinToPlay;

- (void)setPlayStyle:(AutoPlayStyle)style;

- (void)autoPlayVideo;
- (void)stopVideo;
- (void)resetPlayerViewFrame:(CGRect)frame;
- (void)updateTheme;
- (void)settingPlayButton;
- (void)showPlayTime;
- (void)setPosterImage;
- (void)toplayVideo:(UIButton *)sender;

//火车卡片cell中加蒙层
- (void)addMaskView:(UIView *)maskView;
- (void)layoutCountDownCenterY:(CGFloat)centerY;

@end
