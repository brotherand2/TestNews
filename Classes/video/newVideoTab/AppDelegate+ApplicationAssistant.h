//
//  AppDelegate+ApplicationAssistant.h
//  iPhoneVideo
//
//  Created by FengHongen on 15/6/10.
//  Copyright (c) 2015年 SOHU. All rights reserved.
//

#import "SVApplicationAssistant.h"
#import "SNLoginRegisterViewController.h"
#import "SNNewsShareManager.h"
@interface sohunewsAppDelegate (ApplicationAssistant) <SVApplicationAssistantProtocol>

@property (nonatomic, copy)   ShareBlock shareBlock;
@property (nonatomic, copy)   LoginCallback loginCallback;
@property (nonatomic, copy)   ShareCompletionBlock shareCompletionBlock;
@property (nonatomic, strong) SNLoginRegisterViewController *registerViewController;
@property (nonatomic, strong) SNActionMenuController *actionMenuController;
@property (nonatomic, strong) SNNewsShareManager *shareManager;

// 视频举报
- (void)pushVideoReportWithParams:(NSDictionary *)params;
/**
 *  无图模式
 *
 *  @return YES 无图， NO 有图
 */
- (BOOL)getNonePictureMode;
@end
