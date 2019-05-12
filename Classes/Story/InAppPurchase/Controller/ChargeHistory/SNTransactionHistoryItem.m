//
//  SNTransactionHistoryItem.m
//  sohunews
//
//  Created by H on 2016/12/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNTransactionHistoryItem.h"
/*
 @property (nonatomic, assign) SNTransactionType transactionType;
 
 @property (nonatomic, copy) NSString * title;
 
 @property (nonatomic, copy) NSString * transactionId;
 
 @property (nonatomic, copy) NSString * amount;
 
 @property (nonatomic, copy) NSString * ctime;
 
 @property (nonatomic, copy) NSString * retryTip;

 */
@implementation SNTransactionHistoryItem
/*
 {
 "id": 10001,
 "amount": 1000, //金额
 "status": 0,    //状态 //状态 0=待支付,1=支付成功,2=支付失败
 "ctime": "今天 19:20" //时间
 },
 */
+ (SNTransactionHistoryItem *)createWithDic:(NSDictionary *)dic {
    if (dic) {
        SNTransactionHistoryItem * item = [[SNTransactionHistoryItem alloc] init];
        item.transactionId = [dic stringValueForKey:@"id" defaultValue:@""];
        item.amount = [dic stringValueForKey:@"amount" defaultValue:@""];
        item.ctime = [dic stringValueForKey:@"ctime" defaultValue:@""];
        item.retryTip = @"点击重试，重试不会再次扣费";
        NSNumber * status = dic[@"status"];
        switch (status.integerValue) {
            case 0:
            {
                item.transactionType = SNTransactionTypeFailed;
                break;
            }
            case 1:
            {
                item.transactionType = SNTransactionTypeSuccessed;
                break;
            }
            case 2:
            {
                item.transactionType = SNTransactionTypeFailed;
                break;
            }
            default:
                item.transactionType = SNTransactionTypeFailed;
                break;
        }
        return item;
    }
    return nil;
}
@end
