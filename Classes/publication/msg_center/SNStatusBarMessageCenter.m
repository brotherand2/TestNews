//
//  SNMsgCenter.m
//  sohunews
//
//  Created by handy wang on 6/28/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNStatusBarMessageCenter.h"
#import "SNMessageStatusBar.h"

@interface SNStatusBarMessageCenter () {
    SNMessageStatusBar *_statusBar;
}

@end

@implementation SNStatusBarMessageCenter

#pragma mark - Life cycle

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (SNMessageStatusBar *)statusBar {
    if (_statusBar == nil) {
        _statusBar = [[SNMessageStatusBar alloc] initWithFrame:CGRectZero];
    }
    return _statusBar;
}


#pragma mark - Public methods implementation

+ (SNStatusBarMessageCenter *)sharedInstance {
    static SNStatusBarMessageCenter *_sharedInstance = nil;
    @synchronized(self) {
        if (!_sharedInstance) {
            _sharedInstance = [[SNStatusBarMessageCenter alloc] init];
        }
    }
    return _sharedInstance;
}

- (void)postNormalMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        SNMessageStatusBar *statusBar = [self statusBar];
        if ([statusBar respondsToSelector:@selector(postNormalMessage:)]) {
            [statusBar postNormalMessage:message];
        }
    });
}

- (void)postImmediateMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        SNMessageStatusBar *statusBar = [self statusBar];
        if ([statusBar respondsToSelector:@selector(postImmediateMessage:)]) {
            [statusBar postImmediateMessage:message];
        }
    });
}

- (void)postImmediateMessage:(NSString *)message canTap:(BOOL)canTap {
    dispatch_async(dispatch_get_main_queue(), ^{
        SNMessageStatusBar *statusBar = [self statusBar];
        if ([statusBar respondsToSelector:@selector(postImmediateMessage:canTap:)]) {
            [statusBar postImmediateMessage:message canTap:canTap];
        }
    });
}

- (void)hideMessageDalay:(NSTimeInterval)seconds {
    dispatch_async(dispatch_get_main_queue(), ^{
        SNMessageStatusBar *statusBar = [self statusBar];
        if ([statusBar respondsToSelector:@selector(hideMessageDalay:)]) {
            [statusBar hideMessageDalay:seconds];
        }
    });
}

- (void)hideMessageImmediately {
    dispatch_async(dispatch_get_main_queue(), ^{
        SNMessageStatusBar *statusBar = [self statusBar];
        if ([statusBar respondsToSelector:@selector(hideMessageImmediately)]) {
            [statusBar hideMessageImmediately];
        }
    });
}

- (void)setAlpha:(CGFloat)alpha {
    dispatch_async(dispatch_get_main_queue(), ^{
        SNMessageStatusBar *statusBar = [self statusBar];
        if ([statusBar respondsToSelector:@selector(setAlpha:)]) {
            [statusBar setAlpha:alpha];
        }
    });
}

@end
