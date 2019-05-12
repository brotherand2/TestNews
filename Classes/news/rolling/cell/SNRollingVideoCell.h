//
//  SNRollingVideoCell.h
//  sohunews
//
//  Created by lhp on 5/7/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRollingNewsPictureCell.h"
#import "SNVideoDetailModel.h"
#import <SVVideoForNews/SVVideoForNews.h>

#import "SNTimelineVideoCellContentView.h"

/*****************************显示视频新闻的Cell********************************
 
         1、标题最多显示一行
         2、标题多于一行结尾显示"..."
         3、不显示摘要
****************************************************************************/

@interface SNRollingVideoCell : SNRollingNewsTitleCell<SNTimelineVideoCellContentViewDelegate>

@property (nonatomic, strong) SNNewsVideoInfo *video;

- (void)autoPlay;
@end
