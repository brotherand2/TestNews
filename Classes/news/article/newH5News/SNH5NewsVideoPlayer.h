//
//  SNH5NewsVideoPlayer.h
//  sohunews
//
//  Created by 赵青 on 2016/10/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "WSMVVideoPlayerView.h"

@interface SNH5NewsVideoPlayer : WSMVVideoPlayerView
{
    UIButton *_closeButton;
    UIButton *_fullscreenBtn;
    
    NSMutableArray *touchPoints;
    BOOL _isSmallVideo;
    
    UIButton *_playButton;
}

@property (nonatomic, assign)BOOL isBecomingSmall;//正文页视频在下面，向下滑动出小窗，点击状态栏回顶时.记录下收回动画还没完成，又执行了小窗动画
@property (nonatomic, assign)BOOL isAnimation;//为了正文页滑动隐藏操作栏和小窗动画不同时进行记录下动画是否正在进行，记录正在隐藏操作栏
@property (nonatomic, assign)BOOL isBecomingMini; //记录在隐藏操作栏时同时小窗，延迟执行小窗，等隐藏操作栏完了以后再调小窗
@property (nonatomic, assign)BOOL isBeingChange; //正在进行小窗变化
@property (nonatomic, assign)BOOL isShowNavView;  //记录操作栏是否滑动隐藏了

- (void)setSmallVideoAnimation;
- (void)setSmallVideoAnimation:(BOOL)animation;
- (void)closeView:(BOOL)ispause animation:(BOOL)animation;
- (void)showWillPlayNextVideoToastWithVideo:(SNVideoData *)video;
@end
