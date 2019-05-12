//
//  SNUserAccountService.m
//  sohunews
//
//  Created by weibin cheng on 13-9-10.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNUserAccountService.h"
#import "SNCheckTokenRequest.h"
#import "SNUserinfo.h"
#import "SNUserManager.h"
#import "SNURLJSONResponse.h"
#import "SNURLDataResponse.h"
#import "SNDBManager.h"
#import "SNStatusBarMessageCenter.h"
#import "SNEncryptManager.h"
#import "TBXML.h"
#import "NSDictionaryExtend.h"
#import "SNAnalytics.h"
#import "SNUserUtility.h"
#import "SNMySDK.h"
#import "SNLogoutRequest.h"
#import "SNOpenLoginLinkRequest.h"
#import "SNStoryUtility.h"
#import "SNCloudSaveService.h"

#define kOpenLogin       (@"kopenlogin")
#define kGetOpenUrl      (@"kgetopenurl")
#define kLoginHttps      (@"kloginHttps")
#define kRegisterHttps   (@"kregisterHttps")
#define kCheckToken      (@"kcheckToken")

@implementation SNUserAccountService
@synthesize logoutRequest = _logoutRequest;
@synthesize userDelegate = _userDelegate;
@synthesize loginDelegate = _loginDelegate;
@synthesize registerDelegate = _registerDelegate;
@synthesize openLoginUrlDelegate = _openLoginUrlDelegate;
@synthesize openLoginRequest = _openLoginRequest;
@synthesize loginUrlRequest = _loginUrlRequest;
@synthesize loginHttpsRequest = _loginHttpsRequest;
@synthesize registerHttpsRequest = _registerHttpsRequest;
@synthesize tokenRequest = _tokenRequest;

-(void)dealloc
{
    // clear SNShareManager delegate
    //[[SNShareManager defaultManager] setDelegate:nil];
    
    [self clearRequestAndDelegate];
}

#pragma -mark Public
-(void)clearRequestAndDelegate
{
    if(_logoutRequest)
    {
        [_logoutRequest clearDelegatesAndCancel];
         //(_logoutRequest);
    }
    self.userDelegate = nil;
    if(_openLoginRequest)
    {
        [_openLoginRequest cancel];
         //(_openLoginRequest);
    }
    self.openLoginRequest = nil;
    if(_openLoginUrlDelegate)
    {
        [_loginUrlRequest cancel];
         //(_loginUrlRequest);
    }
    self.openLoginUrlDelegate = nil;
    if(_loginHttpsRequest)
    {
        [_loginHttpsRequest cancel];
         //(_loginHttpsRequest);
    }
    self.loginDelegate = nil;
    if(_registerHttpsRequest)
    {
        [_registerHttpsRequest cancel];
         //(_registerHttpsRequest);
    }
    self.registerDelegate = nil;
    if(_tokenRequest)
    {
        [_tokenRequest cancel];
         //(_tokenRequest);
    }
}


-(BOOL)requestLogout {
    
    if(![SNUserinfoEx isLogin]) return NO;
    
    [[[SNLogoutRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        NSInteger status = [responseObject intValueForKey:@"status" defaultValue:0];
        NSString* msg = [responseObject stringValueForKey:@"msg" defaultValue:@""];
        if(status == 0) {
            [SNUtility deleteAllCookies]; // 退出登录后清掉所有cookie
            
            // 退出后重新同步收藏(cid下的收藏)
            [SNCloudSaveService synCloudFavoriteData];
            
            // 重置‘我的订阅’列表刷新时间
            //[SNSubscribeCenterService clearMySubRefreshDate];
            // 重置“订阅中心”所有缓存的刷新时间
            //[SNSubscribeCenterService clearAllSubRefreshCachedData];
#pragma mark - huangjing  //我的SDK调用退出逻辑添加
            [SNSLib  loginOutWith:@{@"loginOut":@"1"}];
            [[SNMySDK sharedInstance] logout];
#pragma mark - end
            [SNUserUtility handleUserLogout];
            if(_userDelegate && [_userDelegate respondsToSelector:@selector(notifyUserLogoutSuccess)])
                [_userDelegate notifyUserLogoutSuccess];
            
        } else {
#pragma mark - huangjing //我的SDK调用退出逻辑添加
            [SNSLib loginOutWith:@{@"loginOut":@"0"}];
#pragma mark - end
            if(_userDelegate && [_userDelegate respondsToSelector:@selector(notifyUserAccountServerFailure:withMsg:)])
                [_userDelegate notifyUserAccountServerFailure:SNUserAccountTypeLogout withMsg:msg];
            
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        [SNSLib loginOutWith:@{@"loginOut":@"0"}];//my sdk 退出失败
        if(_userDelegate && [_userDelegate respondsToSelector:@selector(notifyUserAccountNetworkFailure:withError:)])
            [_userDelegate notifyUserAccountNetworkFailure:SNUserAccountTypeLogout withError:error];
    }];
    return YES;
}

-(NSString*)generateSigForLoginHttps:(NSString*)aUsername gid:(NSString*)aGid
{
    //userid+appid+gid+key的md5
    NSMutableString* string = [NSMutableString stringWithCapacity:0];
    [string appendString:aUsername];
    [string appendString:kPassportAppId];
    [string appendString:aGid];
    [string appendString:kPassportSignKey];
    return [string md5Hash];
}

-(NSMutableDictionary*)generateDicForLoginHttps:aUsername password:(NSString*)aPassword
{
    NSMutableDictionary* dictionray = [NSMutableDictionary dictionaryWithCapacity:0];
    [dictionray setObject:kPassportAppId forKey:@"appid"];
    [dictionray setObject:[SNUserManager getGid] forKey:@"gid"];
    [dictionray setObject:[self generateSigForLoginHttps:aUsername gid:[dictionray objectForKey:@"gid"]] forKey:@"sig"];
    [dictionray setObject:aUsername forKey:@"userid"];
    [dictionray setObject:[aPassword md5Hash] forKey:@"password"];
    return dictionray;
}
-(BOOL)loginHttpsRequest:(NSString*)aUsername password:(NSString*)aPassword
{
    if(aUsername==nil || aPassword==nil)
        return NO;
    if(self.loginHttpsRequest!=nil && self.loginHttpsRequest.isLoading)
        return NO;
	
    NSDictionary* params = [self generateDicForLoginHttps:aUsername password:aPassword];
    NSDictionary* parmasex = [NSDictionary dictionaryWithObjectsAndKeys:params, @"info",nil];
    
    NSMutableData* xmlData = [NSMutableData data];
    NSString* xmlString = [parmasex toXMLString];
    [xmlData appendData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *requestURLString = kUrlHttpsLogin;
    requestURLString = [SNUtility addNetSafeParametersForURL:requestURLString];//追加网安监控参数
	if(!_loginHttpsRequest)
    {
		_loginHttpsRequest = [TTURLRequest requestWithURL:requestURLString delegate:self];
		_loginHttpsRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
	}
    else
    {
		_loginHttpsRequest.urlPath = requestURLString;
	}
    
    //Saving
    
    //https
    [_loginHttpsRequest setValue:@"text/plain; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [_loginHttpsRequest setHttpBody:xmlData];
    [_loginHttpsRequest setHttpMethod:@"POST"];
	
    _loginHttpsRequest.userInfo = [TTUserInfo topic:kLoginHttps strongRef:aUsername weakRef:nil];
	_loginHttpsRequest.response = [[SNURLDataResponse alloc] init];
	[_loginHttpsRequest send];
    return YES;
}

-(NSString*)generateSigForRegisterHttps:(NSString*)aUsername gid:(NSString*)aGid
{
    //userid+appid+gid+key的md5
    NSMutableString* string = [NSMutableString stringWithCapacity:0];
    [string appendString:aUsername];
    [string appendString:kPassportAppId];
    [string appendString:aGid];
    [string appendString:kPassportSignKey];
    return [string md5Hash];
}

-(NSMutableDictionary*)generateDicForRegisterHttps:aUsername password:(NSString*)aPassword
{
    NSString* userNameAll = [NSString stringWithFormat:@"%@@sohu.com", aUsername];
    NSMutableDictionary* dictionray = [NSMutableDictionary dictionaryWithCapacity:0];
    [dictionray setObject:kPassportAppId forKey:@"appid"];
    [dictionray setObject:[SNUserManager getGid] forKey:@"gid"];
    [dictionray setObject:[self generateSigForRegisterHttps:userNameAll gid:[dictionray objectForKey:@"gid"]] forKey:@"sig"];
    [dictionray setObject:userNameAll forKey:@"userid"];
    [dictionray setObject:aPassword forKey:@"password"];
    [dictionray setObject:@"1" forKey:@"uniqname_force"];
    return dictionray;
}
//返回错误码: 0成功，1参数错误，2验证码错误，3非法userid，4userid已经存在，6创建用户失败 7.手机已经被绑定（wap专用） 8 非法用户名uniqname 9 用户名uniquename已存在 10 调用超限（一个appid5分钟调用超过了700次）11 不能注册vip.sohu.com的账号
-(BOOL)registerHttpsRequest:(NSString*)aUsername password:(NSString*)aPassword
{
    if(aUsername==nil || aPassword==nil)
        return NO;
    if(self.registerHttpsRequest!=nil && self.registerHttpsRequest.isLoading)
        return NO;
    
    NSMutableDictionary* params = [self generateDicForRegisterHttps:aUsername password:aPassword];
    NSDictionary* parmasex = [NSDictionary dictionaryWithObjectsAndKeys:params, @"register",nil];
    
    NSMutableData* xmlData = [NSMutableData data];
    NSString* xmlString = [parmasex toXMLString];
    [xmlData appendData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    
	if(!_registerHttpsRequest)
    {
		_registerHttpsRequest = [TTURLRequest requestWithURL:kUrlHttpsRegister delegate:self];
		_registerHttpsRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
	}
    else
    {
		_registerHttpsRequest.urlPath = kUrlHttpsRegister;
	}
    
    //Saving
    NSString* username = [NSString stringWithFormat:@"%@@sohu.com", aUsername];
    
    //https
    [_registerHttpsRequest setValue:@"text/plain; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [_registerHttpsRequest setHttpBody:xmlData];
    [_registerHttpsRequest setHttpMethod:@"POST"];
	
    _registerHttpsRequest.userInfo = [TTUserInfo topic:kRegisterHttps strongRef:username weakRef:nil];
	_registerHttpsRequest.response = [[SNURLDataResponse alloc] init];
	[_registerHttpsRequest send];
    return YES;
}

-(void)doKickout
{
    //过期
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kUserExpire];
    //if(_usrinfo._headImageUrl!=nil) [[NSUserDefaults standardUserDefaults] setObject:_usrinfo._headImageUrl forKey:@"SNUserExpireHeadUrl"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [SNNotificationManager postNotificationName:kUserDidLogoutNotification object:nil];
    [SNUserinfoEx clearUserinfoFromUserDefaults];
    [[SNDBManager currentDataBase] deleteMyFavouriteAll];
}


//- (BOOL)checkTokenRequest {
//    SNDebugLog(@"userinfo");
//    SNUserinfoEx* userInfo = [SNUserinfoEx userinfoEx];
//    if(userInfo!=nil) {
//        SNDebugLog(@"userInfo.token:%@",userInfo.token);
//        SNDebugLog(@"userInfo.getUsername:%@",userInfo.getUsername);
//        if(!userInfo.token || ![userInfo getUsername]) {
//            [self doKickout];
//        }
//        else{
//            [[[SNCheckTokenRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
//                
//                //http://10.10.26.127:8080/doc/smc-api/index.html#api-usercenter-chkTk
//                //wangshun 2017.3.20 修改逻辑
//                if([responseObject isKindOfClass:[NSDictionary class]]) {
//                    NSNumber* statusCode = [responseObject objectForKey:@"statusCode"];
//                    NSNumber* checkResult = [responseObject objectForKey:@"checkResult"];
//                    
//                    if(statusCode!=nil && [statusCode intValue] == 10000000) {
//                        if (checkResult.integerValue ==0) {
//                            [self doKickout];//两个字段同事判断是否登出 wangshun
//                        }
//                    }
//                }
////                //3.5 刷新分享列表
////                [SNShareManager startWork];
//                
//            } failure:^(SNBaseRequest *request, NSError *error) {
//                //多半是因为网络原因验证失败,不做操作
//                //3.5 刷新分享列表
////                [SNShareManager startWork];
//            }];
//            return YES;
//        }
//    }
//    //by default
//    return NO;
//}

-(BOOL)openLoginLinkRequest:(NSString*)aType loginFrom:(NSString *)loginFrom
{
    if(aType==nil)
        return NO;
    
    NSString* appId = [SNShareList appIdByAppName:aType];
    if(appId!=nil)
    {
        BOOL support = [[SNShareManager defaultManager] loginByAppId:appId loginType:SNShareManagerAuthLoginTypeLogin delegate:self loginFrom:loginFrom];
        if(support)
        {
            return NO;
        }
    }
    
//    NSString* urlFull = [NSString stringWithFormat:SNLinks_Path_Login_OpenLoginLink, aType];
//    urlFull = [NSString stringWithFormat:@"%@&version=1.0", urlFull];
//    
//	if(!_loginUrlRequest)
//    {
//		_loginUrlRequest = [SNURLRequest requestWithURL:urlFull delegate:self];
//		_loginUrlRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
//	}
//    else
//    {
//		_loginUrlRequest.urlPath = urlFull;
//	}
//	
//    _loginUrlRequest.userInfo = [TTUserInfo topic:kGetOpenUrl strongRef:aType weakRef:nil];
//	_loginUrlRequest.response = [[SNURLJSONResponse alloc] init];
//	[_loginUrlRequest send];
    
//    ?loginType=%@
    [[[SNOpenLoginLinkRequest alloc] initWithDictionary:@{@"loginType":aType}] send:^(SNBaseRequest *request, id rootData) {
        if ([rootData isKindOfClass:[NSDictionary class]]) {
            NSString* domain = aType;
            NSString* loginLink = [rootData objectForKey:@"loginLink"];
            NSString* status = [rootData objectForKey:@"status"];
            NSString* msg = [rootData objectForKey:@"msg"];
            
            if(status!=nil && [status isEqualToString:@"0"] && loginLink!=nil && [loginLink length]>0) {
                if ([_openLoginUrlDelegate respondsToSelector:@selector(notifyOpenLoginUrSuccess:domain:)])
                    [_openLoginUrlDelegate notifyOpenLoginUrSuccess:loginLink domain:domain];
                
                NSString* urlWithP1 = [SNUtility addParamP1ToURL:loginLink];
                if([urlWithP1 length]>0) {
                    NSDictionary* dic;
                    BOOL isLoginType = NO;
                    if (loginLink.length > 0) {
                        isLoginType = YES;
                    }
                    dic = [NSDictionary dictionaryWithObjectsAndKeys:urlWithP1, @"url", domain, @"domain", [NSNumber numberWithBool:isLoginType], @"isLoginType", nil];
                    
                    TTURLAction* urlAction = [[TTURLAction actionWithURLPath:@"tt://oauthWebView"] applyQuery:dic];
                    urlAction.animated = YES;
                    [[TTNavigator navigator] openURLAction:urlAction];
                }
            } else {
                if ([_openLoginUrlDelegate respondsToSelector:@selector(notifyOpenLoginUrFailure:msg:)])
                    [_openLoginUrlDelegate notifyOpenLoginUrFailure:[status intValue] msg:msg];
            }
        } else {
            if ([_openLoginUrlDelegate respondsToSelector:@selector(notifyOpenLoginUrFailure:msg:)])
                [_openLoginUrlDelegate notifyOpenLoginUrFailure:0 msg:NSLocalizedString(@"network error", nil)];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        if([_openLoginUrlDelegate respondsToSelector:@selector(notifyOpenLoginUrDidFailLoadWithError:)])
            [_openLoginUrlDelegate notifyOpenLoginUrDidFailLoadWithError:error];
    }];
    
    return YES;
}

//----------------------------------------------------------------------------------------------
//------------------------------------- 开放平台登录 ----------------------------------------------
//----------------------------------------------------------------------------------------------

-(BOOL)openLoginRequest:(NSString*)aUrl domain:(NSString*)aDomain
{
    if(aUrl==nil && [aUrl length]>0)
        return NO;
    if(self.openLoginRequest!=nil && self.openLoginRequest.isLoading)
        return NO;
    
	if(!_openLoginRequest)
    {
		_openLoginRequest = [SNURLRequest requestWithURL:aUrl delegate:self];
		_openLoginRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
	}
    else
    {
		_openLoginRequest.urlPath = aUrl;
	}
	
    _openLoginRequest.userInfo = [TTUserInfo topic:kOpenLogin strongRef:aDomain weakRef:nil];
	_openLoginRequest.response = [[SNURLJSONResponse alloc] init];
	[_openLoginRequest send];
    return YES;
}

#pragma -mark Private
-(void)parseLogoutData:(NSString*)data
{
    NSDictionary* root = [NSJSONSerialization JSONObjectWithString:data
                                                           options:NSJSONReadingMutableLeaves
                                                             error:NULL];
    NSInteger status = [root intValueForKey:@"status" defaultValue:0];
    NSString* msg = [root stringValueForKey:@"msg" defaultValue:@""];
    if(status == 0)
    {
        // 重置‘我的订阅’列表刷新时间
        //[SNSubscribeCenterService clearMySubRefreshDate];
        // 重置“订阅中心”所有缓存的刷新时间
        //[SNSubscribeCenterService clearAllSubRefreshCachedData];
        [SNUserUtility handleUserLogout];
        if(_userDelegate && [_userDelegate respondsToSelector:@selector(notifyUserLogoutSuccess)])
            [_userDelegate notifyUserLogoutSuccess];
        
#pragma mark - huangjing  //我的SDK调用退出逻辑添加
        [SNSLib  loginOutWith:@{@"loginOut":@"1"}];
        [[SNMySDK sharedInstance] logout];
#pragma mark - end
    }
    else
    {
        if(_userDelegate && [_userDelegate respondsToSelector:@selector(notifyUserAccountServerFailure:withMsg:)])
            [_userDelegate notifyUserAccountServerFailure:SNUserAccountTypeLogout withMsg:msg];
        
#pragma mark - huangjing //我的SDK调用退出逻辑添加
        [SNSLib loginOutWith:@{@"loginOut":@"0"}];
#pragma mark - end
    }
}

/* 失败时返回模板
 <?xml version="1.0" encoding="GBK"?>
 <result>
 <status>1</status>
 <errmsg>错误的userid:dcm002%40sohu.com</errmsg>
 </result>

 成功时返回模板
 <?xml version="1.0" encoding="GBK"?>
 <result>
 <uid>03489f0edb4e47ds</uid>
 <token>30e77629f2b7a475da1879cd1bb1fd96</token>
 <status>0</status>
 <userid>cmstest101@sohu.com</userid>
 <uuid>03489f0edb4e47ds</uuid>
 <uniqname>³É¶¼³Ô»õ</uniqname>
 </result>
 */
-(void)parseHttpsLoginRequest:(TTURLRequest*)request
{
    //wangshun sohu login
    SNURLDataResponse* data = (SNURLDataResponse*)request.response;
    //TTUserInfo* userInfo = request.userInfo;
    //NSString* userId     = userInfo.strongRef;
    TBXML *tbxml = [TBXML tbxmlWithXMLData:data.data];
    TBXMLElement* root = tbxml.rootXMLElement;
    if(root!=nil)
    {
        //目前这些参数已给
        NSString* status    = [TBXML textForElement:[TBXML childElementNamed:@"status" parentElement:root]];
        NSString* token     = [TBXML textForElement:[TBXML childElementNamed:@"token" parentElement:root]];
        
        //NSString* uid     = [TBXML textForElement:[TBXML childElementNamed:@"uid" parentElement:root]];
        NSString* userId    = [TBXML textForElement:[TBXML childElementNamed:@"userid" parentElement:root]];
        NSString* cookie    = [data.responceHeader objectForKey:@"set-Cookie"];
        NSString* nick     = [TBXML textForElement:[TBXML childElementNamed:@"uniqname" parentElement:root]];
        if(status!=nil && [status intValue] == 0 && token!=nil)
        {
            SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
            userinfo.userName = userId;
            userinfo.token = token;
            userinfo.cookieName = kSetCookie;
            userinfo.cookieValue = cookie;
            userinfo.nickName = nick;
            [userinfo saveUserinfoToUserDefault];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:kUserCenterLoginAppId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if([_loginDelegate respondsToSelector:@selector(notifyLoginSuccess)])
                [_loginDelegate notifyLoginSuccess];
            
        }
        else
        {
            NSString* msg = @"登录失败";
            switch ([status intValue])
            {
                case 1:
                    msg = @"请输入正确的用户名或密码";
                    break;
                case 3:
                    msg = @"用户名或密码不正确";
                default:
                    break;
            }
            if([_loginDelegate respondsToSelector:@selector(notifyLoginFailure:msg:)])
                [_loginDelegate notifyLoginFailure:[status intValue] msg:msg];
        }
    }
    else
    {
        if([_loginDelegate respondsToSelector:@selector(notifyLoginFailure:msg:)])
            [_loginDelegate notifyLoginFailure:0 msg:NSLocalizedString(@"network error", nil)];
    }
}


/*成功时返回模板
 <?xml version="1.0" encoding="GBK"?>
 <result>
 <uid>5d5002c8f3184d6s</uid>
 <token>39d7a6ef54aeafdfddba25f599c78223</token>
 <status>0</status>
 <uuid>5d5002c8f3184d6s</uuid>
 <uniqname>ËÑºüÍøÓÑ81896216</uniqname>
 </result>
 */
-(void)parseHttpsRegisterRequest:(TTURLRequest*)request
{
    SNURLDataResponse* data = (SNURLDataResponse*)request.response;
    TBXML *tbxml = [TBXML tbxmlWithXMLData:data.data];
    TBXMLElement* root = tbxml.rootXMLElement;
    TTUserInfo* userInfo = request.userInfo;
    NSString* userId     = userInfo.strongRef;
    if(root!=nil)
    {
        //目前这些参数已给
        NSString* status = [TBXML textForElement:[TBXML childElementNamed:@"status" parentElement:root]];
        NSString* token     = [TBXML textForElement:[TBXML childElementNamed:@"token" parentElement:root]];
        SNDebugLog(@"register http token: %@", token);
        
        //目前这些参数未给
//        NSString* uid     = [TBXML textForElement:[TBXML childElementNamed:@"uid" parentElement:root]];
        NSString* cookie    = [data.responceHeader objectForKey:@"set-Cookie"];
        NSString* nick     = [TBXML textForElement:[TBXML childElementNamed:@"uniqname" parentElement:root]];
        
        if(status!=nil && [status intValue]==0 && token!=nil)
        {
            SNUserinfoEx* userinfo = [SNUserinfoEx userinfoEx];
            userinfo.userName = userId;
            userinfo.token = token;
            userinfo.cookieName = kSetCookie;
            userinfo.cookieValue = cookie;
            userinfo.nickName = nick;
            [userinfo saveUserinfoToUserDefault];
            
            [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:kUserCenterLoginAppId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if(_registerDelegate && [_registerDelegate respondsToSelector:@selector(notifyRegisterSuccess)])
                [_registerDelegate notifyRegisterSuccess];
        }
        else
        {
            NSString* msg = @"注册失败";
            switch ([status intValue])
            {
                case 3:
                    msg = @"用户名不符合规则!";
                    break;
                case 4:
                    msg = @"用户名已存在!";
                    break;
                case 8:
                    msg = @"用户名不符合规则!";
                    break;
                case 9:
                    msg = @"用户名已存在!";
                    break;
                default:
                    break;
            }
            if([_registerDelegate respondsToSelector:@selector(notifyRegisterFailure:msg:)])
                [_registerDelegate notifyRegisterFailure:[status intValue] msg:msg];
        }
    }
    else
    {
        if([_registerDelegate respondsToSelector:@selector(notifyRegisterFailure:msg:)])
            [_registerDelegate notifyRegisterFailure:0 msg:NSLocalizedString(@"network error", nil)];
    }
}

-(void)parseTokenRequest:(TTURLRequest*)request
{
    SNURLJSONResponse* dataRes = (SNURLJSONResponse*)request.response;
    id rootData = dataRes.rootObject;
    SNDebugLog(@"login json data : %@", rootData);
    if([rootData isKindOfClass:[NSDictionary class]])
    {
        NSString* status = [rootData objectForKey:@"status"];
        if(status!=nil && [status intValue] == 0)
        {
        }
        else
        {
            
            [self doKickout];
        }
    }
    //3.5 刷新分享列表
    [SNShareManager startWork];
}

-(void)parseOpenLoginRequest:(TTURLRequest*)request
{
    SNURLJSONResponse* dataRes = (SNURLJSONResponse*)request.response;
    id rootData = dataRes.rootObject;
    SNDebugLog(@"login json data : %@", rootData);
    if([rootData isKindOfClass:[NSDictionary class]])
    {
        NSString* status = [rootData objectForKey:@"status"];
        NSString* msg = [rootData objectForKey:@"msg"];
        
        NSString* userId = [rootData objectForKey:@"userId"];
        NSString* nick = ([rootData objectForKey:@"nickName"]!=nil ? [rootData objectForKey:@"nickName"] : [rootData objectForKey:@"nick"]);
        NSString* pid = [rootData stringValueForKey:@"pid" defaultValue:nil];
        
        if(status!=nil && [status intValue] == 0)
        {
            NSDictionary* dictionary = [SNEncryptManager dictionaryFromQuery:request.urlPath usingEncoding:NSASCIIStringEncoding];
            SNUserinfoEx* curUser = [SNUserinfoEx userinfoEx];
            curUser.userName = userId;
            curUser.nickName = nick;
            curUser.pid = pid;
            curUser.token = [dictionary objectForKey:@"token"];
            NSDictionary* newUserinfo = [rootData objectForKey:@"newUserInfo"];
            if(newUserinfo != nil && [newUserinfo isKindOfClass:[NSDictionary class]])
            {
                [curUser parseUserinfoFromDictionary:newUserinfo];
            }
            
            //3.5.1扩展cookie
            SNURLJSONResponse* data = (SNURLJSONResponse*)request.response;
            NSString* setCookie   = [data.responceHeader objectForKey:@"set-Cookie"];
            if(setCookie.length > 0)
            {
                if(curUser.cookieValue )
                {
                    if([curUser.cookieValue rangeOfString:setCookie options:NSCaseInsensitiveSearch].location==NSNotFound)
                    {
                        curUser.cookieValue = [NSString stringWithFormat:@"%@; %@", curUser.cookieValue, setCookie];
                    }
                }
                else
                {
                    curUser.cookieValue = setCookie;
                    curUser.cookieName = kSetCookie;
                }
            }
            
            [curUser saveUserinfoToUserDefault];
            
            
            TTUserInfo* userInfo = request.userInfo;
            NSString *appName = userInfo.strongRef;
            if (appName && [appName isKindOfClass:[NSString class]]) {
                NSString *appId = [SNShareList appIdByAppName:appName];
                if ([appId length] > 0) {
                    [[NSUserDefaults standardUserDefaults] setObject:appId forKey:kUserCenterLoginAppId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else {
                    [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:kUserCenterLoginAppId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            [SNUserUtility handleUserLogin];
            if(_loginDelegate && [_loginDelegate respondsToSelector:@selector(notifyLoginSuccess)])
                [_loginDelegate notifyLoginSuccess];
        }
        else
        {
            if([_loginDelegate respondsToSelector:@selector(notifyLoginFailure:msg:)])
                [_loginDelegate notifyLoginFailure:[status intValue] msg:msg];
        }
    }
    else
    {
        if([_loginDelegate respondsToSelector:@selector(notifyLoginFailure:msg:)])
            [_loginDelegate notifyLoginFailure:0 msg:NSLocalizedString(@"network error", nil)];
    }
}

-(void)parseLoginUrlRequest:(TTURLRequest*)request
{
    SNURLJSONResponse* dataRes = (SNURLJSONResponse*)request.response;
    TTUserInfo* userInfo = request.userInfo;
    id rootData = dataRes.rootObject;
    SNDebugLog(@"get open url json data : %@", rootData);
    if ([rootData isKindOfClass:[NSDictionary class]])
    {
        NSString* domain = userInfo.strongRef;
        NSString* loginLink = [rootData objectForKey:@"loginLink"];
        NSString* status = [rootData objectForKey:@"status"];
        NSString* msg = [rootData objectForKey:@"msg"];
        
        if(status!=nil && [status isEqualToString:@"0"] && loginLink!=nil && [loginLink length]>0)
        {
            if([_openLoginUrlDelegate respondsToSelector:@selector(notifyOpenLoginUrSuccess:domain:)])
                [_openLoginUrlDelegate notifyOpenLoginUrSuccess:loginLink domain:domain];
            
            NSString* urlWithP1 = [SNUtility addParamP1ToURL:loginLink];
            if([urlWithP1 length]>0)
            {
                NSDictionary* dic;
                BOOL isLoginType = NO;
                if (loginLink.length > 0) {
                    isLoginType = YES;
                }
                dic = [NSDictionary dictionaryWithObjectsAndKeys:urlWithP1, @"url", domain, @"domain", [NSNumber numberWithBool:isLoginType], @"isLoginType", nil];
                
                TTURLAction* urlAction = [[TTURLAction actionWithURLPath:@"tt://oauthWebView"] applyQuery:dic];
                urlAction.animated = YES;
                [[TTNavigator navigator] openURLAction:urlAction];
            }
        }
        else
        {
            if([_openLoginUrlDelegate respondsToSelector:@selector(notifyOpenLoginUrFailure:msg:)])
                [_openLoginUrlDelegate notifyOpenLoginUrFailure:[status intValue] msg:msg];
        }
    }
    else
    {
        if([_openLoginUrlDelegate respondsToSelector:@selector(notifyOpenLoginUrFailure:msg:)])
            [_openLoginUrlDelegate notifyOpenLoginUrFailure:0 msg:NSLocalizedString(@"network error", nil)];
    }
}
#pragma -mark ASIHTTPRequestDelegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSString* response = request.responseString;
    if(request == _logoutRequest)
    {
        [self parseLogoutData:response];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    if(request == _logoutRequest)
    {
        [SNSLib loginOutWith:@{@"loginOut":@"0"}];//my sdk 退出失败
        if(_userDelegate && [_userDelegate respondsToSelector:@selector(notifyUserAccountNetworkFailure:withError:)])
            [_userDelegate notifyUserAccountNetworkFailure:SNUserAccountTypeLogout withError:request.error];
    }
}

-(void)shareManager:(SNShareManager *)manager wantToShowAuthView:(UIViewController *)authNaviController
{
}

//新浪微博登陆成功
- (void)shareManagerDidAuthAndLoginSuccess:(SNShareManager *)manager
{
    [SNShareManager defaultManager].delegate = nil;
    if([_loginDelegate respondsToSelector:@selector(notifyLoginSuccess)])
        [_loginDelegate notifyLoginSuccess];
}

-(void)shareManager:(SNShareManager*)manager didAuthFailedWithError:(NSError*) error
{
    [SNShareManager defaultManager].delegate = nil;
    if([_loginDelegate respondsToSelector:@selector(notifyLoginFailure:msg:)])
        [_loginDelegate notifyLoginFailure:[error code] msg:@"授权失败"];
}
#pragma -mark TTUrlRequestDelegate
-(void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    TTUserInfo* userInfo = request.userInfo;
    if([userInfo.topic isEqual:kLoginHttps])
    {
        if([_loginDelegate respondsToSelector:@selector(notifyLoginRequeestFailure:didFailLoadWithError:)])
            [_loginDelegate notifyLoginRequeestFailure:request didFailLoadWithError:error];
    }
    else if([userInfo.topic isEqual:kRegisterHttps])
    {
        if([_registerDelegate respondsToSelector:@selector(notifyRegisterRequeestFailure:didFailLoadWithError:)])
            [_registerDelegate notifyRegisterRequeestFailure:request didFailLoadWithError:error];
    }
    else if([userInfo.topic isEqual:kOpenLogin])
    {
        if([_loginDelegate respondsToSelector:@selector(notifyLoginRequeestFailure:didFailLoadWithError:)])
            [_loginDelegate notifyLoginRequeestFailure:request didFailLoadWithError:error];
    }
    else if([userInfo.topic isEqual:kCheckToken])
    {
        //多半是因为网络原因验证失败,不做操作
        //3.5 刷新分享列表
        [SNShareManager startWork];
    }
    else if([userInfo.topic isEqual:kGetOpenUrl])
    {
        if([_openLoginUrlDelegate respondsToSelector:@selector(notifyOpenLoginUrDidFailLoadWithError:)])
            [_openLoginUrlDelegate notifyOpenLoginUrDidFailLoadWithError:error];
    }
}

-(void)requestDidFinishLoad:(TTURLRequest*)request
{
    TTUserInfo* userInfo = request.userInfo;
    
    if([userInfo.topic isEqual:kLoginHttps])
    {
        [self parseHttpsLoginRequest:request];
    }
    else if([userInfo.topic isEqual:kRegisterHttps])
    {
        [self parseHttpsRegisterRequest:request];
    }
    else if([userInfo.topic isEqual:kOpenLogin])
    {
        [self parseOpenLoginRequest:request];
    }
    else if([userInfo.topic isEqual:kCheckToken])
    {
        [self parseTokenRequest:request];
    }
    else if([userInfo.topic isEqualToString:kGetOpenUrl])
    {
        [self parseLoginUrlRequest:request];
    }
    
}
@end
