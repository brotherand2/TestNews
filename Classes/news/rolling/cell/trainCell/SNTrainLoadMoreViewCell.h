//
//  SNTrainLoadMoreViewCell.h
//  sohunews
//
//  Created by Huang Zhen on 2017/11/3.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingTrainCollectionBaseCell.h"

@interface SNTrainLoadMoreViewCell : SNRollingTrainCollectionBaseCell

@property (nonatomic, assign, readonly) BOOL isAnimating;

- (void)startLoading;
- (void)stopLoading;
- (void)allFinishedLoad;
- (void)resetSizeWithPgc:(BOOL)isPGC;

@end
