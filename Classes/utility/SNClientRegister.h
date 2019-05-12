//
//  SNClientRegister.h
//  sohunews
//
//  Created by Dan Cong on 4/4/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNCloudSaveService.h"
@class SNBaseRequest;
typedef void(^SNRegisterClientAnywaySuccessCallback)(SNBaseRequest *request);
typedef void(^SNRegisterClientAnywayFailCallback)(SNBaseRequest *request, NSError *error);

//负责向服务器注册可跟踪当前设备的uid,sid,s_cookie的工具类
//p1是uid的base64加密值，叫p1是为了混淆变量的安全目的，其实后来也没有p2过....⊙﹏⊙b汗
@interface SNClientRegister : NSObject

@property (nonatomic, strong) NSString *deviceToken;                 //APN推送分配到的token
@property (nonatomic, assign) BOOL deviceTokenChanged;
@property (nonatomic, copy) NSString *s_cookie;                    //标示当前设备基础信息组合cookie
@property (nonatomic, copy) NSString *uid;                         //用户id，其实是没有登录功能时期设备的一个游客身份的注册id，用于追踪设备，不同于用户登录后的passport id
@property (nonatomic, copy) NSString *sid;                         //适配id，服务器分配，一般用于区别iphone，ipad，retina屏幕
@property (nonatomic, assign, readonly) BOOL isRegisted;            //设备是否在服务器上注册游客成功
@property (nonatomic, assign, readonly) BOOL isDeviceModelAdapted;  //是否适配到了sid
@property (nonatomic, assign, readonly) BOOL isRegistedInKeychain;  //是否将注册信息存储到了钥匙串

+ (SNClientRegister *)sharedInstance;

// 没有p1则调用一次注册接口
- (void)ensureRegister;

- (void)updateClientInfoToServer;

- (void)setupCookie;

- (void)reset;

- (void)registerClientAnyway;
- (void)registerClientAnywaySuccess:(SNRegisterClientAnywaySuccessCallback)success fail:(SNRegisterClientAnywayFailCallback)fail;

@end
