//
//  SNNewsLoginSuccess.m
//  sohunews
//
//  Created by wang shun on 2017/4/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsLoginSuccess.h"
#import "SNNewsLoginManager.h"

#import <JsKitFramework/JKNotificationCenter.h>
#import "SNSLib.h"
#import "SNAdvertiseManager.h"
#import "SNUserManager.h"
#import "SNUserUtility.h"

@interface SNNewsLoginSuccess ()

@property (nonatomic,weak) UIViewController* topViewController;

@end

@implementation SNNewsLoginSuccess

- (instancetype)initWithParams:(NSDictionary *)params{
    if (self = [super init]) {
        self.open_params = params;
        [self getCurrentTopViewController];
    }
    return self;
}

- (void)loginSucessed:(NSDictionary*)dic{
    SNDebugLog(@"loginSuccess:%@",dic);
    
    UIViewController *viewController = [SNSLib forLoginSuccessToPush];
    if (nil != viewController) {
        [[TTNavigator navigator].topViewController.flipboardNavigationController pushViewController:viewController animated:YES];
        return;
    }
    
    if (self.topViewController) {
        if ([TTNavigator navigator].topViewController.flipboardNavigationController) {
            [[TTNavigator navigator].topViewController.flipboardNavigationController popToViewController:self.topViewController animated:YES completion:^{
                
                if (self.loginSuccess) {
                    self.loginSuccess(dic);
                }
                
                [self postLoginSuccessNotification];
                
            }];
        }
    }
    else{
        if([TTNavigator navigator].topViewController.flipboardNavigationController){
            [[TTNavigator navigator].topViewController.flipboardNavigationController popViewControllerAnimated:YES completion:^{
                
                if (self.loginSuccess) {
                    self.loginSuccess(dic);
                }
                
                [self postLoginSuccessNotification];
                
            }];
        }
    }
}

- (void)getCurrentTopViewController{
    UIViewController* vc = [TTNavigator navigator].topViewController;
    self.topViewController = vc;
}

- (void)postLoginSuccessNotification{
    
    [[SNAdvertiseManager sharedManager] sendPassportIdForLoginSuccessed:[SNUserManager getPid]];
    
    [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.setting.loginChanged" withObject:nil];
    
    //
    [SNUserUtility handleUserLogin];
}


@end
