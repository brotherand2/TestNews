//
//  SNGlobal_ios7.h
//  sohunews
//
//  Created by Gao Yongyue on 13-8-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStatusbarAddWhenCalling ([UIApplication sharedApplication].statusBarFrame.size.height == 40.f ? 20.f : 0.f)

#define kAppScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kAppScreenHeight ([UIScreen mainScreen].bounds.size.height - kStatusbarAddWhenCalling)

#define kHeadSelectViewBottom (0.f)
#define kHeadSelectViewHeight (kHeaderHeightWithoutBottom)
#define kFullscreenHeadSelectViewHeight (0.f)

#define kToolbarViewTop (0.f)

#define kToolbarViewHeight (kToolbarHeightWithoutShadow)
#define kWebToolbarViewHeight (60)
#define kRecomFollowCatalogListViewWidth (((kAppScreenWidth > 375) ? 80 : 138/2))

#define kIPHONE_4_WIDTH            (320.f)
#define kIPHONE_4_HEIGHT           (480.f)

#define kIPHONE_5_WIDTH            (320.f)
#define kIPHONE_5_HEIGHT           (568.f)

#define kIPHONE_6_WIDTH            (375.f)
#define kIPHONE_6_HEIGHT           (667.f)

#define kIPHONE_6P_WIDTH           (414.f)
#define kIPHONE_6P_HEIGHT          (736.f)

#define kIPHONE_X_WIDTH           (375.f)
#define kIPHONE_X_HEIGHT          (812.f)
