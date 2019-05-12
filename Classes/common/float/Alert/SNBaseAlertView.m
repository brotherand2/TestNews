//
//  SNBaseAlertView.m
//  sohunews
//
//  Created by TengLi on 2017/6/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNBaseAlertView.h"
#import "SNAlertStackManager.h"

@implementation SNBaseAlertView

- (instancetype)initWithAlertViewData:(id)content
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)showAlertView {
    
    /// 将当前是否有弹窗存在置为 YES
    [SNAlertStackManager sharedAlertStackManager].isShowing = YES;
}

- (void)dismissAlertView {
    
      /// 将当前弹窗从弹窗队列种移除
    [[SNAlertStackManager sharedAlertStackManager] removeAlertViewFromAlertStack:self];
    /// 将当前是否有弹窗存在置为NO
    [SNAlertStackManager sharedAlertStackManager].isShowing = NO;
    
    /// 1s 后触发下一个弹窗
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[SNAlertStackManager sharedAlertStackManager] checkoutInStackAlertView];
    });
}

@end
