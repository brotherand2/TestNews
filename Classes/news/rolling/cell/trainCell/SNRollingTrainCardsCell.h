//
//  SNRollingTrainCardsCell.h
//  sohunews
//
//  Created by Huang Zhen on 2017/11/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingBaseCell.h"

@interface SNRollingTrainCardsCell : SNRollingBaseCell

// 火车卡片中当前视频cell是否完全可见
- (BOOL)isVideoCellVisible;

//火车卡片中是否有视频正在播放
- (BOOL)isVideoCellPlaying;

//开始播放视频 
- (void)autoPlayVideo;

//停止播放视频
- (void)stopVideo;

@end
