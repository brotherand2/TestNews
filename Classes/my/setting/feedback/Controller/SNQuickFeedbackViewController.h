//
//  SNQuickFeedbackViewController.h
//  sohunews
//
//  Created by 李腾 on 2016/10/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//



@protocol QuickFeedbackViewControllerDelegate <NSObject>

@optional
- (void)SendFeedBackSuccessWithDict:(NSDictionary *)dict;

@end

@interface SNQuickFeedbackViewController : SNBaseViewController

@property (nonatomic, weak) id<QuickFeedbackViewControllerDelegate> delegate;

@end
