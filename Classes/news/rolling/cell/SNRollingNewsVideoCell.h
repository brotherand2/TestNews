//
//  SNRollingNewsVideoCell.h
//  sohunews
//
//  Created by cuiliangliang on 16/5/3.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRollingNewsPictureCell.h"
#import "SNVideoDetailModel.h"
#import <SVVideoForNews/SVVideoForNews.h>
#import "SNTimelineVideoCellContentView.h"

@interface SNRollingNewsVideoCell : SNRollingNewsTitleCell<SNTimelineVideoCellContentViewDelegate>
- (void)autoPlay;
- (void)stopPlay;
@end
