//
//  SNPushSettingController.m
//  sohunews
//
//  Created by 李 雪 on 11-6-30.
//  update by sampanli
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import "SNPushSettingController.h"
#import "SNPushSettingDataSource.h"
#import "SNPushSettingDelegate.h"
#import "SNPushSettingModel.h"
#import "SNDBManager.h"
#import "SNPushSettingTableItem.h"
#import "SNDBManager.h"
#import "UIColor+ColorUtils.h"
#import "SNPushSettingSectionInfo.h"
#import "SNThemeManager.h"
#import "SNConsts.h"



#define  OFF   @"全关"
#define  ON    @"全开"

@implementation SNPushSettingController
@synthesize strONorOFF = _strONorOFF;

- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
    if (self = [super initWithNavigatorURL:URL query:query]) {
		self.tableViewStyle = UITableViewStyleGrouped;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (SNCCPVPage)currentPage {
    return more_setting_push;
}


- (void)createModel{
    [SNPushSettingModel instance].controller = self;
    SNPushSettingDataSource *dataSource = [[SNPushSettingDataSource alloc] init];
    self.dataSource = dataSource;
    dataSource.pushViewController=self;
}

- (id/*<TTTableViewDelegate>*/)createDelegate {
    SNPushSettingDelegate *delegate = [[SNPushSettingDelegate alloc] initWithController:self];
	delegate.model = [SNPushSettingModel instance];
	return delegate;
}

-(void)changePushSettingWith:(SNPushSettingItem*)settingItem switchCtl:(SNPushSwitcher*)switcher
{
    [SNPushSettingModel instance].isSucessfull = YES;
    
	PushSettingChangeItem *changeItem	= [[PushSettingChangeItem alloc] init];
    changeItem.settingItem=settingItem;
	if (switcher.currentIndex==1) {
		changeItem.nPushStatus	= 1;
        settingItem.pubPush=@"1";
    } else {
		changeItem.nPushStatus	= 0;
        settingItem.pubPush=@"0";
    }
    if ([switcher isKindOfClass:[SNPushSwitcher class]]) {
        changeItem.switcher	= switcher;
    }
    
    [SNPushSettingModel instance].isAllOperation = NO;
    [[SNPushSettingModel instance] changePushSetting:YES data:[NSArray arrayWithObject:changeItem]];
}

- (void)loadView {
    [super loadView];

    //5.9.3 wangchuanwen update
    //换成abTest背景色 5.9.3 by wangchuanwen
    //UIColor *color = SNUICOLOR(kBackgroundColor);
    //self.tableView.backgroundColor = color;
    //self.view.backgroundColor = color;
    
    [self customerTableBg];
    UIColor *color = SNUICOLOR(kThemeBgRIColor);
    self.tableView.backgroundColor = color;
    self.view.backgroundColor = color;
    
    self.tableView.frame = CGRectMake(0, kHeadSelectViewBottom, kAppScreenHeight, kAppScreenHeight-kToolbarHeight-kHeaderTotalHeight);
    UIColor *grayColor = [UIColor colorFromString:[[SNThemeManager sharedThemeManager] currentThemeValueForKey:kTableCellSeparatorColor1]];
    [self.tableView setSeparatorColor:grayColor];
    if(SYSTEM_VERSION_LESS_THAN(@"7.0"))
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0, kToolbarHeightWithoutShadow, 0);
        self.tableView.contentOffset = CGPointMake(0, -kHeaderHeightWithoutBottom);
    }
    
    [self addHeaderView];
    [self addToolbar];
    
    [self.headerView setSections:[NSArray arrayWithObject:NSLocalizedString(@"Push setting",@"")]];
    CGSize titleSize = [NSLocalizedString(@"Push setting",@"") sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeE]];
    [self.headerView setBottomLineForHeaderView:CGRectMake(7, self.headerView.height-2, titleSize.width+6, 2)];
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        //iOS>=8.0
        [SNUtility showSettingPushHalfFloatView:YES isFromSetting:YES];
    }
    else {
        //iOS<8.0
        [SNUtility showSettingPushHalfFloatView:NO isFromSetting:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    self.tableView.contentInset = UIEdgeInsetsMake(10 + kHeaderHeightWithoutBottom, 0, kToolbarHeightWithoutShadow, 0);
//    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(10 + kHeadSelectViewBottom, 0, 0, 0);
//    self.tableView.contentOffset = CGPointMake(0, -20 - kHeaderHeightWithoutBottom);
//    self.tableView.frame = CGRectMake(0, kHeadSelectViewBottom, kAppScreenWidth, kAppScreenHeight - kHeadSelectViewBottom - kToolbarViewTop);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self reportPVAnalyzeWithCurrentNavigationController:self.flipboardNavigationController];
}

@end
