//
//  SNMsgerStatusBar.h
//  sohunews
//
//  Created by handy wang on 6/28/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNNormalMessageStatusBarLabel.h"
#import "SNImmediateMessageStatusBarLabel.h"

@interface SNMessageStatusBar : UIWindow {
    UIView *_backgroundView;
	SNNormalMessageStatusBarLabel *_normalMessageLabel;
    SNImmediateMessageStatusBarLabel *_immediateMessageLabel;
    NSMutableArray *_messageQueue;
    
    BOOL _canTap;
}
- (void)postNormalMessage:(NSString *)message;

- (void)postImmediateMessage:(NSString *)message;

- (void)postImmediateMessage:(NSString *)message canTap:(BOOL)canTap;

- (void)hideMessageDalay:(NSTimeInterval)seconds;

- (void)hideMessageImmediately;

@end