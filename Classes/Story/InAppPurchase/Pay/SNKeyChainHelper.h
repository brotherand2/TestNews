//
//  SNKeyChainHelper.h
//  sohunews
//
//  Created by HuangZhen on 21/02/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UICKeyChainStore.h"

#define kSN_IAP_KEYCHAIN_SERVIVCE   [SNStoryUtility getPid]

typedef void(^VerifyCompleted)(BOOL successed, NSNumber * amount, NSData * receipt, NSString * errMsg);

/**
 此类为Apple充值的漏单恢复验证策略
 用于书币充值后的收据存储，仅仅用于小说模块，其他模块如果需要请重新创建helper类
 */
@interface SNKeyChainHelper : NSObject

/**
 存储支付收据

 @param receipt AppleServer 返回的支付收据
 @param transactionId APPServer 生成的支付订单
 @return YES = Successed
 */
+ (BOOL)saveReceipt:(NSData *)receipt forTransactionID:(NSString *)transactionId;

/**
 删除支付收据（仅当APPServer验证通过，发放金币之后方可调用）

 @param transactionId APPServer 生成的支付订单
 @return YES = Successed
 */
+ (BOOL)removeReceiptForTransactionID:(NSString *)transactionId;

/**
 验证本地存储的凭证（单个）
 用于用户手动重试
 @param transactionId 交易id
 */
+ (void)verifyReceiptWithTransactionID:(NSString *)transactionId completed:(VerifyCompleted)completedBlock;

/**
 验证本地存储的所有凭证，失败则继续保留，成功的则丢弃
 可以在开机等恰当的时机进行调用
 */
+ (void)verifyAllReceipts;

@end
