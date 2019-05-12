//
//  SNSSOWrapper.h
//  sohunews
//
//  Created by wang yanchen on 13-2-20.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSSOWrapper : NSObject {
    id __weak _delegate;
    
    NSString *_appId; 
    
    NSString *_accessToken;
    NSString *_refreshToken;
    
    NSString *_userName;
    NSString *_userId;
    
    unsigned int _expiration;
    NSDate *_expirationDate;
    
    NSError *_lastError;
    NSString *_lastErrorMessage;
}

@property(nonatomic, weak) id delegate;

// 本地区分是哪个微博的id appId这个名字起的不好
@property(nonatomic, copy) NSString *appId;

// 以下各个属性，可能根据各个不同sso sdk  有所不同， 视具体情况而定；
@property(nonatomic, copy) NSString *accessToken;
@property(nonatomic, copy) NSString *refreshToken;
@property(nonatomic, copy) NSString *userName;
@property(nonatomic, copy) NSString *userId; // 唯一区别用户的id 

/* 访问Token的过期时间戳 */
@property(nonatomic, assign) unsigned int expiration;
@property(nonatomic, strong) NSDate *expirationDate;

// 错误信息
@property(nonatomic, strong) NSError *lastError;
@property(nonatomic, copy) NSString *lastErrorMessage;

// 最主要的一个方法，通过sso 登录
- (void)login;

- (BOOL)handleOpenUrl:(NSURL *)url;

- (void)handleApplicationDidBecomeActive;

@end

@protocol SNSSOWrapperDelegate <NSObject>

@optional

- (void)ssoDidLogin:(SNSSOWrapper *)wrapper;
- (void)ssoDidCancelLogin:(SNSSOWrapper *)wrapper;
- (void)ssoDidFailLogin:(SNSSOWrapper *)wrapper;

@end
