//
//  UIMenuController+Observe.m
//  sohunews
//
//  Created by jojo on 13-9-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "UIMenuController+Observe.h"
#import "AOPAspect.h"
#import <objc/runtime.h>
#import "SNNotificationManager.h"

#define kMeanControllerKey  @"kMeanControllerKey"

@implementation UIMenuController (Observe)

+ (void)load {
    executeAfterSelector(self, @selector(setMenuItems:), ^(NSInvocation *invocation) {
        [SNNotificationManager removeObserver:[UIMenuController sharedMenuController]
                                                        name:kUIMenuControllerHideMenuNotification
                                                      object:nil];
        
        [SNNotificationManager addObserver:[UIMenuController sharedMenuController]
                                                 selector:@selector(handleHideNotification:)
                                                     name:kUIMenuControllerHideMenuNotification
                                                   object:nil];
    });
}

- (void)handleHideNotification:(id)sender {
    [self setMenuVisible:NO animated:YES];
}

- (NSString *)getMenuControllerKey
{
    return objc_getAssociatedObject(self, kMeanControllerKey);
}

- (void)setMenuControllerKeyWithString:(NSString *) keyString
{
    objc_setAssociatedObject(self, kMeanControllerKey, keyString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
