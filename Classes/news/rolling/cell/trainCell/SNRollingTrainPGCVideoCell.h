//
//  SNRollingTrainPGCVideoCell.h
//  sohunews
//
//  Created by HuangZhen on 2017/11/8.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingTrainImageTextCell.h"
#import "SNAutoPlayVideoContentView.h"

@interface SNRollingTrainPGCVideoCell : SNRollingTrainImageTextCell {
    SNAutoPlayVideoContentView *_autoPlayCellContentView;
    SNVideoData *_playerData;
}

@property (nonatomic, assign) BOOL isPlaying;

- (void)autoPlay;
- (void)stopPlay;

- (void)hideCoverInfoWithDelay:(int)delayTime;
- (void)resetCoverInfo;

@end
