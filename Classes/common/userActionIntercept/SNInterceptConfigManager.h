//
//  SNInterceptConfigManager.h
//  sohunews
//
//  Created by jojo on 13-12-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNUserinfo.h"
#import "SNInterceptConsts.h"

// keys
#define kUserActionInterceptInfoKeyGlobal                       (@"global")
#define kUserActionInterceptInfoKeySwitch                       (@"switch")

#define kUserActionInterceptInfoKeyActionList                   (@"actionList")
#define kUserActionInterCeptInfoKeyId                           (@"id")
#define kUserActionInterCeptInfoKeyActionType                   (@"actionType")
#define kUserActionInterCeptInfoKeyMessage                      (@"message")
#define kUserActionInterCeptInfoKeyActionLink                   (@"actionLink")

typedef enum {
    SNUserActionInterceptTypeDontIntercept = 0,     // 不做任何拦截动作
    SNUserActionInterceptTypeClientAction = 1,      // 客户端动作
    SNUserActionInterceptTypeOpenLink,              // 打开网页链接或二代协议
}SNUserActionInterceptType;

@interface SNInterceptConfigManager : NSObject

+ (SNInterceptConfigManager *)sharedManager;

// 初始化本地配置
+ (void)initConfig;
// 与服务端同步最新的配置
+ (void)refreshConfig;
+ (NSString *)configFilePath;

// 用户行为拦截功能 是否已经开启 默认情况、无数据时不开启
- (BOOL)isActionInterceptEnable;

// 每个埋点的地方 只要调用这一个方法就好了
- (SNUserActionInterceptType)handleActionInterceptActionId:(NSString *)actionId;

// 根据不同的返回类型进行不同的响应
- (SNUserActionInterceptType)userActionInterceptTypeWithActionId:(NSString *)actionId;

// 需要打开跳转连接的拦截
- (void)openActionLinkForActionId:(NSString *)actionId;

// 直接进行拦截后续操作
- (void)doClientActionForActionId:(NSString *)actionId;

@end
