//
//  SNSSOWrapper.m
//  sohunews
//
//  Created by wang yanchen on 13-2-20.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNSSOWrapper.h"

@implementation SNSSOWrapper

@synthesize delegate = _delegate;
@synthesize appId = _appId;

@synthesize accessToken = _accessToken;
@synthesize refreshToken = _refreshToken;
@synthesize userId = _userId;
@synthesize userName = _userName;
@synthesize expiration = _expiration;
@synthesize expirationDate = _expirationDate;

@synthesize lastError = _lastError;
@synthesize lastErrorMessage = _lastErrorMessage;

- (void)dealloc {
    _delegate = nil;
    
     //(_appId);
     //(_accessToken);
     //(_refreshToken);
     //(_userId);
     //(_userName);
     //(_expirationDate);
     //(_lastError);
     //(_lastErrorMessage);
    
}

- (void)login {
    // do nothing
}

- (BOOL)handleOpenUrl:(NSURL *)url {
    return NO;
}

- (void)handleApplicationDidBecomeActive {
    // do nothing
}

@end
