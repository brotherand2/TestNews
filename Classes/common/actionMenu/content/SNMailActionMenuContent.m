//
//  SNMailActionMenuContent.m
//  sohunews
//
//  Created by Dan Cong on 12/10/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNMailActionMenuContent.h"
#import "SNStatusBarMessageCenter.h"


@interface SNMailActionMenuContent()
{
    MailSupport *_mail;
}

@end

@implementation SNMailActionMenuContent

- (void)share
{
    NSString *shareComment = [self.shareContentDic stringValueForKey:kShareInfoKeyComment defaultValue:nil];
    if (shareComment.length > 0) {
        self.content = [NSString stringWithFormat:@"%@  %@", shareComment, self.content];
    }

    [[self shareMail] sendMailToTitle:self.title body:self.content html:YES];
    
    self.shareTarget = ShareTargetMail;
    [self log];
}

- (MailSupport*)shareMail{
    if (!_mail) {
        _mail = [[MailSupport alloc] initMail:(UIViewController*)self.delegate];
        _mail._delegate = self;
    }
    return _mail;
}


#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate
- (void)sendMailFinished:(MailSupport*)mail WitResult:(MFMailComposeResult)result error:(NSError*)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            [[SNSkinMaskWindow sharedInstance] show];
            break;
        case MFMailComposeResultSaved:
            [[SNSkinMaskWindow sharedInstance] show];
            break;
        case MFMailComposeResultSent:
            [[SNSkinMaskWindow sharedInstance] show];
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"邮件发送成功" toUrl:nil mode:SNCenterToastModeSuccess];
            break;
        case MFMailComposeResultFailed: {
            [[SNCenterToast shareInstance] showCenterToastWithTitle:@"邮件发送失败" toUrl:nil mode:SNCenterToastModeWarning];
            break;
        }
        default:
            break;
    }
    
    if ([self.delegate isKindOfClass:[SNSplashViewController class]]){
        [self.delegate dismissModalViewControllerAnimated:YES];
    }
}

- (void)dealloc
{
    _mail._delegate = nil;
    _mail._viewController = nil;
     //(_mail);
    
}

@end
