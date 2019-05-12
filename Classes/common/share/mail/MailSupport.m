//
//  MailSupport.m
//  sohunews
//
//  Created by wangxiang on 3/29/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "MailSupport.h"

@implementation MailSupport

@synthesize _mailPostController;
@synthesize _viewController;
@synthesize _delegate;

- (id)initMail:(UIViewController*)controller{
    self = [super init];
    if (self) {
        self._viewController = controller; 
    }
    return self;
}

- (void)sendMailToTitle:(NSString*)title body:(NSString*)content html:(BOOL)isHtml{
    SNMailPostController *picker = [[SNMailPostController alloc] init];
    self._mailPostController = picker;
     picker = nil;
    if (_mailPostController) {
        [SNNotificationCenter showLoading:NSLocalizedString(@"Please wait",@"")];
        _mailPostController.mailComposeDelegate = self;
        [_mailPostController setSubject:title];
        [_mailPostController setMessageBody:content isHTML:isHtml];
        
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        [UIApplication sharedApplication].statusBarHidden = NO;
        
        if ([_viewController isKindOfClass:[SNSplashViewController class]]) {
            [_viewController presentViewController:_mailPostController animated:YES completion:nil];
        } else {
//            [[TTNavigator navigator].topViewController presentModalViewController:_mailPostController animated:YES];
            //present-style push
            [[TTNavigator navigator].topViewController.flipboardNavigationController presentModalViewController:_mailPostController needAnimated:YES];
        }
        [[SNSkinMaskWindow sharedInstance] hide];
    }
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {  
    if (_delegate) {
        [_delegate sendMailFinished:self WitResult:result error:error];
    }

    //present-style push
    [[TTNavigator navigator].topViewController.flipboardNavigationController dismissModalViewControllerWithAnimated:YES];
}

- (void)dealloc
{
    _mailPostController.mailComposeDelegate = nil;
     //(_mailPostController);
}
@end
