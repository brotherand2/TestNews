//
//  SNTimelineVideoControlBar+FullScreen.m
//  sohunews
//
//  Created by handy wang on 11/22/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNTimelineVideoControlBar+FullScreen.h"
#import "SNTimelineSharedVideoPlayerView.h"

@implementation SNTimelineVideoControlBar_FullScreen

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.volumeBtn.hidden = YES;
        self.volumeBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.volumeBtn1 addTarget:self action:@selector(volumn1Action) forControlEvents:UIControlEventTouchUpInside];
        self.volumeBtn1.frame = self.volumeBtn.frame;
        [self.volumeBtn1 setBackgroundImage:[UIImage imageNamed:@"wsmv_volumn_mute.png"] forState:UIControlStateNormal];
        [self.volumeBtn1 setBackgroundImage:[UIImage imageNamed:@"wsmv_volumn.png"] forState:UIControlStateSelected];
        [self addSubview:self.volumeBtn1];

    }
    return self;
}

- (void)enableShare {
    self.shareBtn.hidden = NO;
    NSInteger volume = [[SNTimelineSharedVideoPlayerView sharedInstance] moviePlayer].volume;
    if (volume && volume == 1) {
        self.volumeBtn1.selected = YES;
    } else {
        self.volumeBtn1.selected = NO;
    }
}

- (void)volumn1Action {
    //设置监听器无效
    [[SNTimelineSharedVideoPlayerView sharedInstance] removePureModeTimer];
    [SNTimelineSharedVideoPlayerView sharedInstance].enterPureModeFinished = YES;
    
    self.volumeBtn1.selected = !self.volumeBtn1.selected;
    if (self.volumeBtn1.selected) {
        [[SNTimelineSharedVideoPlayerView sharedInstance] moviePlayer].volume = 1;
    } else {
        [[SNTimelineSharedVideoPlayerView sharedInstance] moviePlayer].volume = 0;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //0.4秒后添加监听器
        [[SNTimelineSharedVideoPlayerView sharedInstance] addPureModeTimerIfNeeded];
    });
}

@end
