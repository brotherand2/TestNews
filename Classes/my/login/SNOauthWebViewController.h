//
//  SNOauthWebViewController.h
//  sohunews
//
//  Created by Diaochunmeng on 12-11-22.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//


#import "SNWebController.h"
#import "SNUserAccountService.h"


@interface SNOauthWebViewController : SNWebController <SNUserAccountLoginDelegate>
{
    NSString* _loadurl;
    NSString* _cookieName;
    NSString* _cookieValue;
    NSString* _lastUrl;
    NSString* _domain;
    SNUserAccountService* _userInfoModel;
    
    //下一步需要触发的操作回调，如果为空表示默认操作，即进入用户中心
    BOOL _needPop;
    id __weak _delegate;
    NSString* _method;
    BOOL _isLoginType;
}

@property(nonatomic,strong)NSString* _loadurl;
@property(nonatomic,strong)NSString* _cookieName;
@property(nonatomic,strong)NSString* _cookieValue;
@property(nonatomic,strong)NSString* _lastUrl;
@property(nonatomic,strong)NSString* _domain;
@property(nonatomic,strong)SNUserAccountService* _userInfoModel;

@property(nonatomic,assign) BOOL _needPop;
@property(nonatomic,weak) id _delegate;
@property(nonatomic,strong) NSString* _method;

@property (nonatomic, assign) BOOL isModal;
@property (nonatomic, assign) BOOL isRegisterProtocol;

@end
