//
//  SNUpgradeHelper.h
//  sohunews
//
//  Created by Dan Cong on 4/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SNUpgrade.h"

@interface SNUpgradeHelper : NSObject <SNUpgradeDelegate>
{
    SNUpgrade *_upgradeObj;
}

@property(nonatomic, weak) id delegate;

+ (SNUpgradeHelper *)sharedInstance;

- (void)checkUpgrade;

- (void)showUpgradeAlertWithMessage:(NSString *)message CancelButtonHandler:(void(^)())cancelHandle OtherButtonHandle:(void(^)())otherHandle;

@end

@protocol SNUpgradeHelperDelegate <NSObject>
- (void)didFinishUpgradeCheck:(BOOL)needAlertUpgradeMessage;
@end
