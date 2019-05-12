//
//  SNSelfCenterViewController.h
//  sohunews
//
//  Created by yangln on 14-9-23.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNSelfCenterBaseViewController.h"
#import "SNStarGuideService.h"

#define kUserCenterUnloginNameTag 1000
#define kUserCenterUnloginTextTag 1001
#define kUserCenterArrowViewTag 1002

#define kSelfCenterOfflineMediaTag 1003
#define kSelfCenterOfflineVideoTag 1004
#define kSelfCenterCollectionTag 1005
#define kSelfCenterMessageTag 1006
#define kSelfCenterActivityTag 1007
#define kSelfCenterApplicationTag 1008
#define kSelfCenterSettingTag 1009

#define kMyCenterVerticalLineTag 1020
#define kMyCenterHorizonLineTag 1030

#define kTableHeaderBackgroundImageTag 2000

#define kSNSelfCenterTableViewCellHeight 43.0
#define kSNSelfCenterTableViewSearchCellHeight 60.0

#define kSNSelfCenterTableViewHeaderHeight ([UIImage imageNamed:@"bgpersonal_bg_v5.png"].size.height + (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 20.f : 0.f))
#define kSNSelfCenterUnloginHeadImageOriginY (24 + (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ? 20.f : 0.f))
#define kSNSelfCenterUnloginHeadImageOriginX 14

@interface SNSelfCenterViewController : SNSelfCenterBaseViewController <SNStarGuideServiceDelegate>

@end
