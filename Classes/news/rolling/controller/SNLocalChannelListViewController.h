//
//  SNLocalChanelListViewController.h
//  sohunews
//
//  Created by lhp on 3/26/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRefreshTableViewController.h"
#import "SNHeadSelectView.h"
#import "SNLocalChannelService.h"
#import "SNNormalSearchView.h"

#define kShowIndexBackgroundWidth 130.0 / 2
#define kShowIndexBackgroundHeight 80.0 / 2
#define kShowIndexBackgroundTop ((kAppScreenWidth > 375.0) ? (245.0 - kShowIndexBackgroundHeight) : ((kAppScreenWidth == 320.0) ? ((kAppScreenHeight == 460.0) ? (115.0 - kShowIndexBackgroundHeight) : (160.0 - kShowIndexBackgroundHeight)) : (210.0 - kShowIndexBackgroundHeight)))
#define kShowIndexTime 0.4
#define kEmptyImageTopDistance ((kAppScreenWidth > 375.0) ? 273.0 / 3 : 168.0 /  2)
#define kEmptyImageBottomDistance ((kAppScreenWidth > 375.0) ? 53.0 / 3 : 42.0 / 2)

@interface SNLocalChannelListViewController : SNRefreshTableViewController <SNLocalChannelServicerDelegate, UITextFieldDelegate> {
    SNHeadSelectView *titleView;
    SNNormalSearchView *_searchView;
    SNLocalChannelService *localChannelService;
    BOOL searchMode;
    NSString *titleString;
    UIImageView *_indexImageView;
    UILabel *_indexTitleLable;
    UIImageView *_emptyImageView;
    UILabel *_emptyTextLabel;
}

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, copy) NSString *channelId;

@end
