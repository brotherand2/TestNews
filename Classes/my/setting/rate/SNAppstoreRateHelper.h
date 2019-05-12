//
//  SNAppstoreRateHelper.h
//  sohunews
//
//  Created by Dan Cong on 4/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppstoreRateHelper : NSObject <UIAlertViewDelegate>

@property (nonatomic, strong) UIAlertView *rateAlertView;

+ (SNAppstoreRateHelper *)sharedInstance;

- (void)showRateDialogIfNeeded;

@end
