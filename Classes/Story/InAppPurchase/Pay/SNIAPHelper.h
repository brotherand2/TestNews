//
//  SNIAPHelper.h
//  sohunews
//
//  Created by H on 2016/11/21.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void(^VerifyCompletedBlock)(BOOL successed, NSNumber * amount, NSData * receipt, NSString * errMsg);

typedef enum : NSUInteger {
    IAPErrorUnknown = 1000,                     //未知错误
    IAPErrorClientInvalid,                      //客户端不允许支付请求
    IAPErrorPaymentCancelled,                   //用户取消了支付请求
    IAPErrorPaymentInvalid,                     // purchase identifier was invalid, etc.
    IAPErrorPaymentNotAllowed,                  // this device is not allowed to make the payment
    IAPErrorStoreProductNotAvailable,           // Product is not available in the current storefront
    IAPErrorCloudServicePermissionDenied,       // user has not allowed access to cloud service information
    IAPErrorCloudServiceNetworkConnectionFailed,// the device could not connect to the nework
    IAPErrorVerifyServiceFailed,                // 服务器验证失败
    IAPErrorTransactionCreateFailed,            // 充值订单创建失败

} IAPErrorCode;

@protocol SNIAPHelperDelegate <NSObject>

- (void)iapSuccessed;

- (void)iapFailedWithErrorCode:(IAPErrorCode)errorCode;

@end

@interface SNIAPHelper : NSObject <SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (nonatomic, weak) id <SNIAPHelperDelegate> delegate;

/**
 通过订单号创建IAP对象，订单号代表本次交易的唯一标识

 @param transactionId 订单号
 @return SNIAPHelper
 */
- (instancetype)initWithTransactionId:(NSString *)transactionId;

/**
 调起Appstore支付

 @param productId 商品id
 @param quantity 商品数量
 */
- (void)buyProduct:(NSString *)productId quantity:(NSInteger)quantity;


/**
 服务端验证收据，外部暴露
 
 @param receipt 收据
 @param verifyCompleted 完成回调
 */
- (void)verifyReceipt:(NSData *)receipt completed:(VerifyCompletedBlock)verifyCompleted;

@end
