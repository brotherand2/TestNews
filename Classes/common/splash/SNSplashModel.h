//
//  SNSplashModel.h
//  sohunews
//
//  Created by ZhaoQing on 2017/10/26.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SCMobileAds/SCMobileAds.h>
#import "SNBrandView.h"

@interface SNSplashModel : NSObject <SCADSplashDelegate>

@property (nonatomic, strong) SCADSplash *scadSplash;
@property (nonatomic, strong) SNBrandView *customView;
@property (nonatomic, weak) id<SNSplashViewDelegate> delegate;
@property (nonatomic, assign) SNSplashViewRefer splashRefer;

- (id)initWithRefer:(SNSplashViewRefer)splashRefer delegate:(id<SNSplashViewDelegate>)delegate;
- (void)showSplashIsCountDown:(BOOL)animated;
- (void)updateSettingsWithConfig:(SNAppConfig *)config;
- (void)showSplashViewWhenActive;
- (void)exitSplash;
- (BOOL)isSplashVisible;

@end
