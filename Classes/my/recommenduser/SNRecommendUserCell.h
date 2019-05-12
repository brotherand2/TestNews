//
//  SNRecommendUserCell.h
//  sohunews
//
//  Created by lhp on 6/26/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNHeadIconView.h"
#import "SNNameButton.h"
#import "SNRecommendUser.h"
#import "SNCellConsts.h"
#import "SNFollowUserService.h"
#import "SNBadgeView.h"
#import "SNWaitingActivityView.h"

@interface SNRecommendUserCell : UITableViewCell<SNFollowUserServiceDelegate, SNBadgeViewDelegate>{
    
    SNHeadIconView *_userImageView;
    SNNameButton *_userNameButton;
    UILabel *_contentLabel;
    SNRecommendUser *__weak _recommendUser;
    UIButton *_followButton;
    SNWaitingActivityView *_loadingActivity;
    UILabel *_followedLabel;
    NSIndexPath *_cellIndexPath;
    SNFollowUserService *_followService;
    BOOL _canOpenUserInfo;
    SNBadgeView* _badgeView;
}
@property(nonatomic,weak) SNRecommendUser *recommendUser;
@property(nonatomic,strong) NSIndexPath *cellIndexPath;
@property(nonatomic,assign) BOOL canOpenUserInfo;

- (void)reuseWithUser:(SNRecommendUser *) newUser cellIndexPath:(NSIndexPath *)indexPath;;

@end
