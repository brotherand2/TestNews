//
//  SNKeyChainHelper.m
//  sohunews
//
//  Created by HuangZhen on 21/02/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNKeyChainHelper.h"
#import "SNIAPHelper.h"
#import "SNStoryUtility.h"

@implementation SNKeyChainHelper

+ (BOOL)saveReceipt:(NSData *)receipt forTransactionID:(NSString *)transactionId {
    if (!receipt || !transactionId) {
        return NO;
    }
    if (![SNStoryUtility isLogin]) {
        return NO;
    }
    UICKeyChainStore * keychain = [UICKeyChainStore keyChainStoreWithService:kSN_IAP_KEYCHAIN_SERVIVCE];
    NSError * error = nil;

    if (![keychain setData:receipt forKey:transactionId error:&error]) {
        SNDebugLog(@"keychain苹果支付收据存储失败，%@",error.localizedDescription);
        return NO;
    }
    return YES;
}

+ (BOOL)removeReceiptForTransactionID:(NSString *)transactionId {
    if (!transactionId) {
        return NO;
    }
    if (![SNStoryUtility isLogin]) {
        return NO;
    }
    UICKeyChainStore * keychain = [UICKeyChainStore keyChainStoreWithService:kSN_IAP_KEYCHAIN_SERVIVCE];
    NSError * error = nil;
    if (![keychain removeItemForKey:transactionId error:&error]) {
        SNDebugLog(@"keychain苹果支付收据删除失败，%@",error.localizedDescription);
        return NO;
    }
    return YES;
}

+ (void)verifyReceiptWithTransactionID:(NSString *)transactionId completed:(VerifyCompleted)completedBlock{
    if (![SNStoryUtility isLogin]) {
        completedBlock(NO,0,nil,@"请先登录");
        return;
    }
    UICKeyChainStore * keychain = [UICKeyChainStore keyChainStoreWithService:kSN_IAP_KEYCHAIN_SERVIVCE];
    NSData * receipt = [keychain dataForKey:transactionId];
    if (receipt) {
        SNIAPHelper * iap = [[SNIAPHelper alloc] initWithTransactionId:transactionId];
        [iap verifyReceipt:receipt
                 completed:^(BOOL successed, NSNumber *amount, NSData *receipt, NSString * errMsg) {
            if (successed) {
                [self removeReceiptForTransactionID:transactionId];
                completedBlock(YES,amount,receipt,errMsg);
            }else{
                completedBlock(NO,amount,receipt,errMsg);
            }
        }];
    }else{
        /// 有可能是transactionId与收据信息不匹配，所以没有找到收据（只生成了订单，但是用户并没有付款成功）
        /// 有可能用户重装APP，造成收据丢失(ios 10.3 Apple 存在钥匙串中的信息可能会随着App删除而丢失)
        completedBlock(NO,0,receipt,@"没有找到有效凭证");
    }
}

+ (void)verifyAllReceipts {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (![SNStoryUtility isLogin]) {
            return;
        }
        UICKeyChainStore * keychain = [UICKeyChainStore keyChainStoreWithService:kSN_IAP_KEYCHAIN_SERVIVCE];
        if (keychain.allKeys.count > 0) {
            NSString * key = keychain.allKeys[0];
            NSData * receipt = [keychain dataForKey:key];
            if (receipt) {
                SNIAPHelper * iap = [[SNIAPHelper alloc] initWithTransactionId:key];
                [iap verifyReceipt:receipt completed:^(BOOL successed, NSNumber *amount, NSData *receipt, NSString * errMsg) {
                    BOOL r = NO;
                    if (successed) {
                        r = [self removeReceiptForTransactionID:key];
                    }
                    //如果中途失败了就停止验证
                    if (r) {
                        [self verifyAllReceipts];
                    }
                }];
            }
        }
        
    });
    
}

@end
