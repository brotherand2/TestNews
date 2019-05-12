//
//  WSMVVideoControlBar.h
//  WeSee
//
//  Created by handy on 8/15/13.
//  Copyright (c) 2013 handy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMVVideoProgressBar.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewAdditions+WSMV.h"
@class WSMVVideoPlayerView;

#define kProgressBarPaddingLeftToPlayBtn_NonFullScreen                  (5.0f)
#define kDownloadBtnPaddingRightToFullScreenBtn_NonFullScreen           (4/2.0f)
#define kProgressBarPaddingRightToDownloadBtn_NonFullScreen             (5.0f)

#define kActionBtnWidth_NonFullScrenn                                   (72.0f/2.0f)
#define kActionBtnWidth_FullScreen                                      (72.0f/2.0f)
#define kActionBtnHeight_FullScreen                                     (60.0f/2.0f)

typedef enum {
    WSMVVideoPlayerPlayBtnStatus_Stop,
    WSMVVideoPlayerPlayBtnStatus_Playing,
    WSMVVideoPlayerPlayBtnStatus_Pause
} WSMVVideoPlayerPlayBtnStatus;

@interface WSMVVideoControlBar : UIImageView//只有一处设置了self.image 可以直接继承UIView的
@property (nonatomic, weak)id delegate;
@property (nonatomic, strong)UIButton *playBtn;
@property (nonatomic, strong)UIButton *downloadBtn;
@property (nonatomic, strong)UIButton *fullscreenBtn;
@property (nonatomic, assign)WSMVVideoPlayerPlayBtnStatus   playBtnStatus;
@property (nonatomic, strong)WSMVVideoProgressBar           *progressBar;
@property (nonatomic, strong)UILabel                        *siteNameLabel;

- (void)setPlayBtnStatus:(WSMVVideoPlayerPlayBtnStatus)playBtnStatus;
- (void)enableDownload;
- (void)disableDownload;
- (void)forbidDownload;
- (void)notForbidDownload;
@end

@protocol WSMVVideoControlBarDelegate
- (void)didTapDownloadBtn;
- (void)didTapShareBtn;
- (void)didTapNextVideoBtn;
- (void)didTapPreviousVideoBtn;
- (void)didTapPlayBtnInControlBarToPlay;
- (void)didTapPlayBtnInControlBarToPause;
- (void)toFullScreen;
- (void)exitFullScreen;
- (void)showVolumnBarMask;
- (void)hideVolumnBarMask;
@end
