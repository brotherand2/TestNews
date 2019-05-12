//
//  SNUserAccountService.h
//  sohunews
//
//  Created by weibin cheng on 13-9-10.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNASIRequest.h"
#import "SNShareManager.h"

typedef enum
{
    SNUserAccountTypeLogin,
    SNUserAccountTypeLogout,
    SnUserAccountTypeRegister,
    
}SNUserAccountType;

@protocol SNUserAccountDelegate <NSObject>
-(void)notifyUserAccountServerFailure:(NSInteger)aType withMsg:(NSString*)aMsg;
-(void)notifyUserAccountNetworkFailure:(NSInteger)aType  withError:(NSError*)aError;
-(void)notifyUserLogoutSuccess;
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol SNUserAccountRegisterDelegate <NSObject>
@optional
-(void)notifyRegisterSuccess;
-(void)notifyRegisterFailure:(NSInteger)aStatus msg:(NSString*)aMsg;
-(void)notifyRegisterRequeestFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error;
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol SNUserAccountLoginDelegate <NSObject>
@optional
//Register
-(void)notifyLoginSuccess;
-(void)notifyLoginFailure:(NSInteger)aStatus msg:(NSString*)aMsg;
-(void)notifyLoginRequeestFailure:(TTURLRequest*)request didFailLoadWithError:(NSError*)error;
@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol SNUserAccountOpenLoginUrlDelegate <NSObject>
@optional
//Get user info
-(void)notifyOpenLoginUrSuccess:aUrl domain:(NSString*)aDomain;
-(void)notifyOpenLoginUrFailure:(NSInteger)aStatus msg:(NSString*)aMsg;
-(void)notifyOpenLoginUrDidFailLoadWithError:(NSError*)error;
@end


@interface SNUserAccountService: NSObject<ASIHTTPRequestDelegate, TTURLRequestDelegate, SNShareManagerDelegate>

@property (nonatomic, strong) SNASIRequest* logoutRequest;
@property (nonatomic, weak) id<SNUserAccountDelegate> userDelegate;

@property (nonatomic,weak) id<SNUserAccountLoginDelegate> loginDelegate;
@property (nonatomic,weak) id<SNUserAccountRegisterDelegate> registerDelegate;
@property (nonatomic,weak) id<SNUserAccountOpenLoginUrlDelegate> openLoginUrlDelegate;

@property (nonatomic,strong) SNURLRequest* loginUrlRequest;
@property (nonatomic,strong) TTURLRequest* loginHttpsRequest;
@property (nonatomic,strong) TTURLRequest* registerHttpsRequest;
@property (nonatomic,strong) SNURLRequest* openLoginRequest;
@property (nonatomic,strong) SNURLRequest* tokenRequest;

-(BOOL)requestLogout;

-(BOOL)loginHttpsRequest:(NSString*)aUsername password:(NSString*)aPassword;

-(BOOL)registerHttpsRequest:(NSString*)aUsername password:(NSString*)aPassword;

-(BOOL)checkTokenRequest;

-(BOOL)openLoginLinkRequest:(NSString*)aType loginFrom:(NSString *)loginFrom;

-(BOOL)openLoginRequest:(NSString*)aUrl domain:(NSString*)aDomain;

-(void)clearRequestAndDelegate;
@end
