//
//  SNRollingTrainCellConst.h
//  sohunews
//
//  Created by Huang Zhen on 2017/10/30.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#ifndef SNRollingTrainCellConst_h
#define SNRollingTrainCellConst_h

#import "SNTrainCellHelper.h"

#define kTrainCellImageScale    (2/3.f)
#define kTrainPGCVideoCellImageScale    (9/16.f)

#define kTrainCellImageHeight   (kAppScreenWidth * kTrainCellImageScale)
#define kCellWidth              (kAppScreenWidth)
#define kLeftSpace              (14.f)
#define kCardLeftSpace              (10.f)
#define kTwoEditNewsMaxHeight       (25.f)
#define kTwoEditNewsSpaceHeight     (10.f)
#define kTwoEditNewsSpaceTop        (13.f)
#define kTwoEditNewsWidth       (kCellWidth - kLeftSpace * 3)
#define kFocusBottomShadowHeight        (126/2.f)
#define kTrainCardCornerRadius              (4.f)

#define kSmallTrainCellWidth              ([SNTrainCellHelper trainCardWidth])
#define kSmallTrainCellHeight              (kSmallTrainCellWidth * kTrainCellImageScale)

#define kSmallTrainPGCCellWidth              (kSmallTrainCellHeight/kTrainPGCVideoCellImageScale)

#define kDefaultNavBarHeight         ([[SNDevice sharedInstance] isPhoneX] ? 88 : 64)

#endif /* SNRollingTrainCellConst_h */
