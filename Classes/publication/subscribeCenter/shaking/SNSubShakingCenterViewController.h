//
//  SNSubShakingCenterViewController.h
//  sohunews
//
//  Created by Diaochunmeng on 12-11-23.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNHeadSelectView.h"

#import "SNSubShakingCenter.h"
#import "SNSubscribeCenterService.h"
#import "SNShakingManager.h"
#import "SNLocationManager.h"

@class SNSubShakingImagesViewController;
@class SNSubShakingButtonViewController;
@class SNSubShakingAnimateViewController;

@interface SNSubShakingCenterViewController : SNBaseViewController<SNSubShakingCenterDelegate,SNShakingManagerDelegate,SNSubscribeCenterServiceDelegate,SNLocationManagerDelegate>
{
    BOOL _subFailure;
    BOOL _subRequestFailure;
    BOOL _defaultPush;
    SNSubShakingCenter* _shakingCenter;
    NSMutableArray* _networdSubArray;
    
    SNShakingManager* _shakingManager;
    SNSubShakingImagesViewController* _imagesViewController;
    SNSubShakingButtonViewController* _buttonViewController;
    SNSubShakingAnimateViewController* _animateViewController;
}

@property(nonatomic,strong) SNSubShakingCenter* _shakingCenter;
@property(nonatomic,strong) NSMutableArray* _networdSubArray;
@property(nonatomic,strong) SNShakingManager* _shakingManager;
@property(nonatomic,strong) SNSubShakingImagesViewController* _imagesViewController;
@property(nonatomic,strong) SNSubShakingButtonViewController* _buttonViewController;
@property(nonatomic,strong) SNSubShakingAnimateViewController* _animateViewController;

-(void)showSubinfoIfReady;
-(void)submitHangout:(id)sender;
-(void)submitSubnow:(id)sender;
//-(void)openPaperView:(NSString*)
@end
