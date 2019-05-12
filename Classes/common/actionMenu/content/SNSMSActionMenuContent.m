//
//  SNSMSActionMenuContent.m
//  sohunews
//
//  Created by Dan Cong on 3/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNSMSActionMenuContent.h"
#import "SNStatusBarMessageCenter.h"


@interface SNSMSActionMenuContent()
{
    SmsSupport *_sms;
}

@end

@implementation SNSMSActionMenuContent

- (void)share
{
    if ([SmsSupport canCurrentDeviceSendSms]) {
        NSString *shareComment = [self.shareContentDic stringValueForKey:kShareInfoKeyComment defaultValue:nil];
        if (shareComment.length > 0) {
            self.content = [NSString stringWithFormat:@"%@  %@", shareComment, self.content];
        }
        [[self shareSms] sendSmsTo:nil body:self.content delegate:self];
    }
    
    self.shareTarget = ShareTargetSMS;
    [self log];
}


- (SmsSupport *)shareSms{
    if (!_sms) {
        _sms = [[SmsSupport alloc] init];
    }
    return _sms;
}


#pragma mark -
#pragma mark Sms Delegate
- (void)showSms:(SmsSupport*)sms withSNSmsPostController:(SNSmsPostController*)controller{
    if ([self.delegate isKindOfClass:[SNSplashViewController class]]) {
        [(UIViewController *)self.delegate presentViewController:controller animated:YES completion:nil];
    } else {
        [[TTNavigator navigator].topViewController presentViewController:controller animated:YES completion:nil];
    }
}

- (void)sendSmsFinished:(SmsSupport*)sms WitResult:(SmsSendResult)result{
	switch (result) {
		case SMSSEND_SUCCEED:
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"SMSSendSucceed", @"SMSSendSucceed") toUrl:nil mode:SNCenterToastModeSuccess];
			break;
		case SMSSEND_CANCELED:
			break;
		case SMSSEND_FAILED:
            [[SNCenterToast shareInstance] showCenterToastWithTitle:NSLocalizedString(@"SMSSendFailed", @"SMS Send Failed") toUrl:nil mode:SNCenterToastModeWarning];
			break;
		default:
			break;
	}
    
    if ([self.delegate isKindOfClass:[SNSplashViewController class]]){
        [self.delegate dismissModalViewControllerAnimated:YES];
    }
}

- (void)dealloc
{
    _sms.delegate = nil;
     //(_sms);
    
}

@end
