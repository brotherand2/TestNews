//
//  SNFollowCell.h
//  sohunews
//
//  Created by weibin cheng on 14-3-6.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRecommendUserCell.h"
#import "SNBubbleTipView.h"


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface SNFollowCell : SNRecommendUserCell
{
    NSString* __weak _pid;
    UIImageView* _arrow;
    SNUserinfoEx* _userinfo;
    SNBubbleTipView* _bubbleView;
}

@property(nonatomic,weak)NSString* pid;
@property(nonatomic,strong)SNUserinfoEx* userinfo;
@property(nonatomic,strong)UIImageView* arrow;
@property(nonatomic,strong)NSString* followPid;

-(void)hideFollowedLabel;
-(void)showFollowedLabel;
-(void)initArrayIfNeeded;
-(void)reuseWithUser2:(SNUserinfoEx*) newUser cellIndexPath:(NSIndexPath*)indexPath;
-(void)reuseWithUser2_addFriend:(SNUserinfoEx*) newUser cellIndexPath:(NSIndexPath *)indexPath;
@end
