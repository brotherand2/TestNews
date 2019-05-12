//
//  SNNewsBindSuccess.m
//  sohunews
//
//  Created by wang shun on 2017/4/17.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsBindSuccess.h"

@interface SNNewsBindSuccess ()

@property (nonatomic,weak) UIViewController* topViewController;

@end

@implementation SNNewsBindSuccess

-(instancetype)initWithParams:(NSDictionary*)params{
    if (self = [super init]) {
        
    }
    return self;
}


- (void)bindSucessed:(NSDictionary*)dic{
    SNDebugLog(@"bindSucessed:%@",dic);
    if (self.topViewController) {
        if ([TTNavigator navigator].topViewController.flipboardNavigationController) {
            [[TTNavigator navigator].topViewController.flipboardNavigationController popToViewController:self.topViewController animated:YES completion:^{
                
                if (self.bindSuccess) {
                    self.bindSuccess(dic);
                }
                
                [self postBindSuccessNotification];
            }];
        }
    }
    else{
        if([TTNavigator navigator].topViewController.flipboardNavigationController){
            [[TTNavigator navigator].topViewController.flipboardNavigationController popViewControllerAnimated:YES completion:^{
                
                if (self.bindSuccess) {
                    self.bindSuccess(dic);
                }
                
                [self postBindSuccessNotification];
            }];
        }
    }
}

- (void)getCurrentTopViewController{
    UIViewController* vc = [TTNavigator navigator].topViewController;
    self.topViewController = vc;
}


- (void)postBindSuccessNotification{
    
}

@end
