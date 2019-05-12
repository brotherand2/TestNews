//
//  SNMsgCenter.h
//  sohunews
//
//  Created by handy wang on 6/28/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNStatusBarMessageCenter : NSObject {
}

+ (SNStatusBarMessageCenter *)sharedInstance;

- (void)postNormalMessage:(NSString *)message;

- (void)postImmediateMessage:(NSString *)message;

- (void)postImmediateMessage:(NSString *)message canTap:(BOOL)canTap;

- (void)hideMessageDalay:(NSTimeInterval)seconds;

- (void)hideMessageImmediately;

- (void)setAlpha:(CGFloat)alpha;

@end