//
//  SmsSupport.h
//  HelloWorld
//
//  Created by 李 雪 on 11-5-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SNSmsPostController.h"

@protocol SmsDelegate;
@interface SmsSupport : NSObject <SNSmsPostControllerDelegate>{
	id<SmsDelegate> _delegate;
}

@property(nonatomic,assign) id<SmsDelegate> delegate;

+ (BOOL)canCurrentDeviceSendSms;
- (void)sendSmsTo:(NSArray*)recipients body:(NSString*)body delegate:(id<SmsDelegate>)delegate;


@end

typedef enum
{
	SMSSEND_SUCCEED,
	SMSSEND_CANCELED,
	SMSSEND_FAILED,
	SMSSEND_UNKOWN
}SmsSendResult;

@protocol SmsDelegate<NSObject>
@optional
- (void)showSms:(SmsSupport*)sms withSNSmsPostController:(SNSmsPostController*)controller;
- (void)sendSmsFinished:(SmsSupport*)sms WitResult:(SmsSendResult)result;
@end

