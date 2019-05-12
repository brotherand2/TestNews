//
//  MailSupport.h
//  sohunews
//
//  Created by wangxiang on 3/29/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNMailPostController.h"

@interface MailSupport : NSObject <MFMailComposeViewControllerDelegate>
@property (nonatomic,strong)SNMailPostController *_mailPostController;
@property (nonatomic,weak) UIViewController *_viewController;
@property (nonatomic,weak) id _delegate;
- (void)sendMailToTitle:(NSString*)title body:(NSString*)content html:(BOOL)isHtml;
- (id)initMail:(UIViewController*)controller;
@end

@protocol MailDelegate<NSObject>
- (void)sendMailFinished:(MailSupport*)mail WitResult:(MFMailComposeResult)result error:(NSError*)error;
@end
