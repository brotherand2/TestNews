//
//  SNSmsPostController.h
//  sohunews
//
//  Created by 李 雪 on 11-8-10.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//
#import <MessageUI/MessageUI.h>
@protocol SNSmsPostControllerDelegate;
@interface SNSmsPostController : MFMessageComposeViewController {
}

@end

@protocol SNSmsPostControllerDelegate<MFMessageComposeViewControllerDelegate>
@optional
-(void)SmsPostControllerDidAppear;
@end


