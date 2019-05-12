//
//  SNUserCenterViewController.h
//  sohunews
//
//  Created by weibin cheng on 13-12-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBaseUserCenterViewController.h"
#import "SNFollowUserService.h"
#import "SNUserAccountService.h"
#import "SNTimelineTrendCell.h"


@interface SNUserCenterViewController : SNBaseUserCenterViewController<SNUserAccountDelegate,SNFollowUserServiceDelegate, UIActionSheetDelegate, SNTLTrendActionDelegate>
{
    
}

//删除动态后更新table
- (void)timelineCellDelete:(NSDictionary *)dic;

@end
