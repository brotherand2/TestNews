//
//  SNNewsLoginSuccess.m
//  sohunews
//
//  Created by wang shun on 2017/4/13.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsLoginSuccess.h"
#import "SNNewsLoginManager.h"

#import "SNNewsLoginHalfViewController.h"

#import <JsKitFramework/JKNotificationCenter.h>
#import "SNSLib.h"
#import "SNAdvertiseManager.h"
#import "SNUserManager.h"
#import "SNUserUtility.h"
static SNNewsLoginSuccess* _instance = nil;
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

//此方法目的 仅作为 去pop动画
- (void)halfLoginSucessed:(NSDictionary*)dic WithAnimation:(id)sender{
    
    if (sender && [sender isKindOfClass:[SNNewsLoginHalfViewController class]]) {
        SNNewsLoginHalfViewController* half_vc = (SNNewsLoginHalfViewController*)sender;
       
        __weak SNNewsLoginSuccess* weakSelf = self;
        [half_vc closeHalfView:^(NSDictionary *info) {
            NSMutableDictionary* d = [NSMutableDictionary dictionaryWithDictionary:dic];
            [d setObject:@"0" forKey:@"animation"];
            [weakSelf loginSucessed:d];
        }];
    }
    else{
        SNNavigationController* navi = [TTNavigator navigator].topViewController.flipboardNavigationController;
        NSInteger n = navi.childViewControllers.count;
        UIViewController* vc = [navi.childViewControllers objectAtIndex:n-2];
        
        if (vc && [vc isKindOfClass:[SNNewsLoginHalfViewController class]]) {
             SNNewsLoginHalfViewController* half_vc = (SNNewsLoginHalfViewController*)vc;
            __weak SNNewsLoginSuccess* weakSelf = self;
            [half_vc closeHalfView:^(NSDictionary *info) {
                NSMutableDictionary* d = [NSMutableDictionary dictionaryWithDictionary:dic];
                [d setObject:@"0" forKey:@"animation"];
                [weakSelf loginSucessed:d];
            }];
        }
        else{
            UIViewController* vc = [navi.childViewControllers objectAtIndex:n-3];
            if (vc && [vc isKindOfClass:[SNNewsLoginHalfViewController class]]) {
                SNNewsLoginHalfViewController* half_vc = (SNNewsLoginHalfViewController*)vc;
                __weak SNNewsLoginSuccess* weakSelf = self;
                [half_vc closeHalfView:^(NSDictionary *info) {
                    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [d setObject:@"0" forKey:@"animation"];
                    [weakSelf loginSucessed:d];
                }];
            }
        }
    }
}

//此方法目的 仅作为 去pop动画
- (void)halfLoginCancel:(NSDictionary*)dic WithAnimation:(id)sender{
    
    if ([sender isKindOfClass:[SNNewsLoginHalfViewController class]]) {
        SNNewsLoginHalfViewController* half_vc = (SNNewsLoginHalfViewController*)sender;
        
        __weak SNNewsLoginSuccess* weakSelf = self;
        [half_vc closeHalfView:^(NSDictionary *info) {
            NSMutableDictionary* d = [NSMutableDictionary dictionaryWithDictionary:dic];
            [d setObject:@"0" forKey:@"animation"];
            [weakSelf loginCancel:d];
        }];
    }
    else{
        SNNavigationController* navi = [TTNavigator navigator].topViewController.flipboardNavigationController;
        NSInteger n = navi.childViewControllers.count;
        UIViewController* vc = [navi.childViewControllers objectAtIndex:n-2];
        
        if (vc && [vc isKindOfClass:[SNNewsLoginHalfViewController class]]) {
            SNNewsLoginHalfViewController* half_vc = (SNNewsLoginHalfViewController*)vc;
            __weak SNNewsLoginSuccess* weakSelf = self;
            [half_vc closeHalfView:^(NSDictionary *info) {
                NSMutableDictionary* d = [NSMutableDictionary dictionaryWithDictionary:dic];
                [d setObject:@"0" forKey:@"animation"];
                [weakSelf loginCancel:d];
            }];
        }
        else{
            UIViewController* vc = [navi.childViewControllers objectAtIndex:n-3];
            if (vc && [vc isKindOfClass:[SNNewsLoginHalfViewController class]]) {
                SNNewsLoginHalfViewController* half_vc = (SNNewsLoginHalfViewController*)vc;
                __weak SNNewsLoginSuccess* weakSelf = self;
                [half_vc closeHalfView:^(NSDictionary *info) {
                    NSMutableDictionary* d = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [d setObject:@"0" forKey:@"animation"];
                    [weakSelf loginCancel:d];
                }];
            }
        }
    }
}

- (void)loginSucessed:(NSDictionary*)dic{
    SNDebugLog(@"loginSuccess:%@",dic);
    
    UIViewController *viewController = [SNSLib forLoginSuccessToPush];
    if (nil != viewController) {
        [[TTNavigator navigator].topViewController.flipboardNavigationController pushViewController:viewController animated:YES];
        
        [self postLoginSuccessNotification];
        
        if (self.loginSuccess) {
            self.loginSuccess(@{@"success":@"1"});
        }

        return;
    }
    
    if (self.topViewController) {
        SNNavigationController* navi = [TTNavigator navigator].topViewController.flipboardNavigationController;
        if (navi) {
            
            if ([[navi.childViewControllers lastObject] isEqual:self.topViewController]) {//仅为容错方法，一般不会出现
                //(当pop登录时 当前登录页面已经被pop 外部写了pop方法) 异常情况
                [self postLoginSuccessNotification];
                
                if (self.loginSuccess) {
                    self.loginSuccess(@{@"success":@"1"});
                }
            }
            else{
                BOOL animation = YES;
                NSString* b = [dic objectForKey:@"animation"];
                if ([b isEqualToString:@"0"]) {
                    animation = NO;
                }
                
                [self postLoginSuccessNotification];
            
                [[TTNavigator navigator].topViewController.flipboardNavigationController popToViewController:self.topViewController animated:animation completion:^{
                    
                    if (self.loginSuccess) {
                        self.loginSuccess(@{@"success":@"1"});
                    }
                }];
        }
    }
    else{
        SNNavigationController* navi = [TTNavigator navigator].topViewController.flipboardNavigationController;
        if (navi) {
            
            if ([[navi.childViewControllers lastObject] isEqual:self.topViewController]) {
                if (self.loginSuccess) {
                    self.loginSuccess(@{@"success":@"1"});
                }
                
                [self postLoginSuccessNotification];
            }
            else{
                    BOOL animation = YES;
                    NSString* b = [dic objectForKey:@"animation"];
                    if ([b isEqualToString:@"0"]) {
                        animation = NO;
                    }

                    [self postLoginSuccessNotification];
                
                    [[TTNavigator navigator].topViewController.flipboardNavigationController popViewControllerAnimated:animation completion:^{
                        
                        if (self.loginSuccess) {
                            self.loginSuccess(@{@"success":@"1"});
                        }
                    }];
                }
            }
        }
    }
}

-(void)loginCancel:(NSDictionary *)dic{
    if (self.topViewController) {
        SNNavigationController* navi = [TTNavigator navigator].topViewController.flipboardNavigationController;
        if (navi) {
            
            if ([[navi.childViewControllers lastObject] isEqual:self.topViewController]) {
                if (self.loginCancel) {
                    self.loginCancel(@{@"success":@"0"});
                }
                
            }
            else{
                BOOL animation = YES;
                NSString* b = [dic objectForKey:@"animation"];
                if ([b isEqualToString:@"0"]) {
                    animation = NO;
                }
                
                [[TTNavigator navigator].topViewController.flipboardNavigationController popToViewController:self.topViewController animated:animation completion:^{
                    
                    if (self.loginCancel) {
                        self.loginCancel(@{@"success":@"0"});
                    }
                    
                }];
            }
        }
    }
    else{
        SNNavigationController* navi = [TTNavigator navigator].topViewController.flipboardNavigationController;
        if (navi) {
            
            if ([[navi.childViewControllers lastObject] isEqual:self.topViewController]) {
                if (self.loginCancel) {
                    self.loginCancel(@{@"success":@"0"});
                }
            }
            else{
                BOOL animation = YES;
                NSString* b = [dic objectForKey:@"animation"];
                if ([b isEqualToString:@"0"]) {
                    animation = NO;
                }
                
                [[TTNavigator navigator].topViewController.flipboardNavigationController popViewControllerAnimated:animation completion:^{
                    
                    if (self.loginCancel) {
                        self.loginCancel(@{@"success":@"0"});
                    }
                    
                }];
            }
        }
    }
}

- (void)getCurrentTopViewController{
    UIViewController* vc = [TTNavigator navigator].topViewController;
    
    if (vc && [NSStringFromClass([vc class]) isEqualToString:@"SNCommentEditorViewController"]) {
        SNNavigationController* navi =  [TTNavigator navigator].topViewController.flipboardNavigationController;
        NSInteger n = navi.childViewControllers.count;
        if (navi.childViewControllers.count>2) {
            vc = [navi.childViewControllers objectAtIndex:n-2]?:nil;
        }
    }
    
    self.topViewController = vc;
    self.current_topViewController = vc;
}

- (void)postLoginSuccessNotification{
    
    [[SNAdvertiseManager sharedManager] sendPassportIdForLoginSuccessed:[SNUserManager getPid]];
    
    [[JKNotificationCenter defaultCenter] dispatchNotification:@"com.sohu.newssdk.action.setting.loginChanged" withObject:nil];
    
    //
    [SNUserUtility handleUserLogin];
}


+ (instancetype)sharedInstanceParams:(NSDictionary*)dic{
    
    SNNewsLoginSuccess* success = [[SNNewsLoginSuccess alloc] initWithParams:dic];
    return success;
    
//    if (_instance != nil) {
//        _instance = nil;
//    }
//    _instance = [[SNNewsLoginSuccess alloc] initWithParams:dic];
//
//    return _instance;
}


@end
