//
//  SmsSupport.m
//  HelloWorld
//
//  Created by 李 雪 on 11-5-30.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SmsSupport.h"
#import "SNNotificationCenter.h"

@interface SmsSupport(private)
-(void)presentSmsPostController:(SNSmsPostController*)controller;
@end


@implementation SmsSupport

@synthesize delegate = _delegate;

- (void)sendSmsTo:(NSArray*)recipients body:(NSString*)body delegate:(id<SmsDelegate>)delegate;
{
	Class messageClass = NSClassFromString(@"MFMessageComposeViewController");
	if (messageClass == nil) 
	{
		[SNNotificationCenter showMessage:NSLocalizedString(@"iOS ver too old",@"")];
		
		if ([self.delegate respondsToSelector:@selector(sendSmsFinished:WitResult:)]) 
		{
			[self.delegate sendSmsFinished:self WitResult:SMSSEND_UNKOWN];
		}
	}
	else 
	{
		if(![messageClass canSendText])
		{
			[SNNotificationCenter showMessage:NSLocalizedString(@"Sms not support",@"")];
			
			if ([self.delegate respondsToSelector:@selector(sendSmsFinished:WitResult:)]) 
			{
				[self.delegate sendSmsFinished:self WitResult:SMSSEND_UNKOWN];
			}
		}
		else 
		{
			self.delegate	= delegate;
			SNSmsPostController *picker = [[SNSmsPostController alloc] init];
            picker.messageComposeDelegate	= self;
			picker.recipients	= recipients;
			picker.body	= [body stringByAppendingString:@" "];
            
			if (self.delegate) {
				[SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
				[self performSelector:@selector(presentSmsPostController:) withObject:picker afterDelay:0.1];
			}
		}
	}
}

+ (BOOL)canCurrentDeviceSendSms
{
	Class messageClass	= NSClassFromString(@"MFMessageComposeViewController");
	if (messageClass == nil) 
	{
		return NO;
	}
	
	return [messageClass canSendText];
}

-(void)presentSmsPostController:(SNSmsPostController*)controller
{
	if (controller == nil) {
		return;
	}
	if (self.delegate && [self.delegate respondsToSelector:@selector(showSms:withSNSmsPostController:)]) {
        [self.delegate showSms:self withSNSmsPostController:controller];
    }
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
    if	(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")) {
        [[UINavigationBar appearance] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    }
}

#pragma mark -
#pragma mark SNSmsPostControllerDelegate

-(void)SmsPostControllerDidAppear
{
	[SNNotificationCenter hideLoading];
    [[SNSkinMaskWindow sharedInstance] hide];
}

- (void)messageComposeViewController:(MFMessageComposeViewController*)controller 
				   didFinishWithResult:(MessageComposeResult)result
{
	SmsSendResult smsSendResult	= SMSSEND_UNKOWN;
	switch(result)
	{
		case MessageComposeResultCancelled:
			smsSendResult	= SMSSEND_CANCELED;
            [[SNSkinMaskWindow sharedInstance] show];
			break;
		case MessageComposeResultSent:
			smsSendResult	= SMSSEND_SUCCEED;
            [[SNSkinMaskWindow sharedInstance] show];
			break;
		case MessageComposeResultFailed:
			smsSendResult	= SMSSEND_FAILED;
			break;
		default:
			break;
	}

	[controller dismissViewControllerAnimated:YES completion:nil];
	[controller release];
	
	if ([self.delegate respondsToSelector:@selector(sendSmsFinished:WitResult:)]) 
	{
		//[self.delegate performSelector:@selector(sendSmsFinished:WitResult:) withObject:self withObject:(id)smsSendResult];
		[self.delegate sendSmsFinished:self WitResult:smsSendResult];
		
	}
}

@end
