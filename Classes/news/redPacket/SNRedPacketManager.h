//
//  SNRedPacketManager.h
//  sohunews
//
//  Created by wangyy on 16/3/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRedPacketItem.h"

@interface SNRedPacketManager : NSObject

@property (nonatomic, strong) SNRedPacketItem *redPacketItem;
@property (nonatomic, assign) BOOL showRedPacketTheme;    //是否显示红包特定皮肤(服务端控制总开关）
@property (nonatomic, assign) BOOL pullRedPacket;         //首页下拉出现红包
@property (nonatomic, assign) BOOL redPacketShowing; //当前显示红包，push信息屏蔽
@property (nonatomic, assign) BOOL isRedPacketPassWd; //有红包口令
@property (nonatomic, assign) BOOL joinActivity;        //土豪不参加
@property (nonatomic, assign) BOOL isInArticleShowRedPacket;//正文页显示的红包按钮

+ (SNRedPacketManager *)sharedInstance;
+ (void)showRedPacketActivityInfo;//显示活动详情
- (BOOL)showRedPacketActivityTheme; //显示活动皮肤
+ (BOOL)isRedPacketViewShow ;
+ (void)showRedPacketActivityInfo:(NSString *)packId isRedPacket:(BOOL)isRedPacket;

- (void)dealPasteboard;
- (BOOL)isValidRedPacket;

+ (void)setRedPacketTips:(NSString *)title;         //setting.go控制“一大波红包来袭”
+ (NSString *)getRedPacketTips;                     //获取setting.go返回红包提示语

- (BOOL)showRedPacketanimated;//是否显示红包动画

/**
 *  获取红包原始密钥Key = expireTime|version|随机串
 *
 *  @return 密钥
 */
- (NSString *)getKey;

/**
 *  获取通过AES算法加密的密钥
 *
 *  @return AES密钥
 */
- (NSString *)getRealKey;

/**
 *  获取通过AES算法加密的密钥数据
 *
 *  @return 数据
 */
- (NSString *)getEncryptData;

/**
 *  获取密钥的版本
 *
 *  @return 版本号
 */
- (NSString *)getKeyVersion;

/**
 *  获取Key时间戳
 *
 *  @return 时间戳
 */
- (NSString *)getKeyTime;

/**
 *  获取通过AES加密后的密钥
 *
 *  @param key 原始密钥
 *
 *  @return 加密密钥
 */
- (NSString *)aesEncryptWithKey:(NSString *)key;

/**
 *  获取通过AES加密的数据
 *
 *  @param data 加密数据
 *
 *  @return
 */
- (NSString *)aesEncryptWithData:(NSString *)data;

/**
 *  请求密钥
 */
- (void)requestRedPacketKey;

+ (void)postRedPacketNotificationName:(BOOL)show;

@end
