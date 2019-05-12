//
//  SNAppstoreRateHelper.m
//  sohunews
//
//  Created by Dan Cong on 4/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNAppstoreRateHelper.h"
#import "SNNewAlertView.h"
#import <StoreKit/StoreKit.h>

#define kRateRemindTimes    3
#define kRateRemindInterval 3600

@implementation SNAppstoreRateHelper

+ (SNAppstoreRateHelper *)sharedInstance {
    static SNAppstoreRateHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNAppstoreRateHelper alloc] init];
    });
    
    return _sharedInstance;
}

- (void)showRateDialogIfNeeded
{
    NSInteger iScoresTimes = [SNUserDefaults integerForKey:KSCORES_TIMES];
    if (iScoresTimes !=3) {
        [self showRateDialog];
    }
}

- (void)showRateDialog {

    if ([SKStoreReviewController respondsToSelector:@selector(requestReview)]) {
#if !DEBUG_MODE
        [SKStoreReviewController requestReview];
#endif
    } else {
        SNNewAlertView *alert = [[SNNewAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"RateText", @"") cancelButtonTitle:NSLocalizedString(@"RateLater", @"") otherButtonTitle:NSLocalizedString(@"RateNow", @"")];
        [alert show];
        [alert actionWithBlocksCancelButtonHandler:^{
            [SNUserDefaults setInteger:kRateRemindTimes forKey:KSCORES_TIMES];
        } otherButtonHandler:^{
            [SNUserDefaults setInteger:kRateRemindTimes forKey:KSCORES_TIMES];
            NSString *strUrl = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=436957087&action=write-review";
            NSURL *url = [NSURL URLWithString:strUrl];
            [[UIApplication sharedApplication] openURL:url];
        }];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([[alertView title] isEqualToString:NSLocalizedString(@"RateTitle", @"")]) {
        switch (buttonIndex) {
            case 1: // Rate Now
            {
                [SNUserDefaults setInteger:kRateRemindTimes forKey:KSCORES_TIMES];
                NSString *strUrl = @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=436957087";
                NSURL *url = [NSURL URLWithString:strUrl];
                [[UIApplication sharedApplication] openURL:url];
            }
                break;
            case 2: // Rate Later
                ;
                break;
            default: // Never Rate
            {
                [SNUserDefaults setInteger:kRateRemindTimes forKey:KSCORES_TIMES];
            }
                break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([[alertView title] isEqualToString:NSLocalizedString(@"RateTitle", @"")]) {
        self.rateAlertView = nil;
    }
}


@end
