//
//  SNTransactionHistoryItem.h
//  sohunews
//
//  Created by H on 2016/12/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 {
 "id": 10000,  //订单号
 "amount": 1000, //金额
 "status": 0,    //状态 0=待支付,1=支付成功,2=支付失败
 "ctime": "今天 19:20" //时间
 },
 */
typedef enum : NSUInteger {
    SNTransactionTypeSuccessed,
    SNTransactionTypeFailed,
    SNTransactionTypeNormal,
} SNTransactionType;

@interface SNTransactionHistoryItem : NSObject

@property (nonatomic, assign) SNTransactionType transactionType;

@property (nonatomic, copy) NSString * title;

@property (nonatomic, copy) NSString * transactionId;

@property (nonatomic, copy) NSString * amount;

@property (nonatomic, copy) NSString * ctime;

@property (nonatomic, copy) NSString * retryTip;

+ (SNTransactionHistoryItem *)createWithDic:(NSDictionary *)dic;

@end
