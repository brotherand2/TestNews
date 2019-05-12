//
//  SNReasonsForUninterestedFormater.m
//  sohunews
//
//  Created by 赵青 on 2016/12/7.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNReasonsForUninterestedFormater.h"
#import "SNReasonsForUninterestedRequest.h"
#import "SNUninterestedItem.h"

@implementation SNReasonsForUninterestedFormater

+ (void)requestUninterestedDataWithDic:(NSDictionary *)dic
                            Completion:(void(^)(NSError *error, id data))completion {
    SNReasonsForUninterestedRequest *request = [[SNReasonsForUninterestedRequest alloc] initWithDictionary:dic];
    [request send:^(SNBaseRequest *request, id responseObject) {
        NSString *status = [responseObject stringValueForKey:@"status"
                                                defaultValue:nil];
        if (status && [status isEqualToString:@"C00000"]) {
            SNUninterestedItem *uninterestedItem = [[SNUninterestedItem alloc] init];
            uninterestedItem.count = [NSString stringWithFormat:@"%@", [responseObject objectForKey:@"count"]].integerValue;
            if (uninterestedItem.count > 0) {
                NSArray *reasons = [responseObject objectForKey:@"data"];
                NSMutableArray *reasonArr = [NSMutableArray array];
                for (NSDictionary *dict in reasons) {
                    SNReasonItem *reasonItem = [[SNReasonItem alloc] init];
                    reasonItem.pos = [NSString stringWithFormat:@"%@",[dict objectForKey:@"pos"]];
                    reasonItem.rid = [dict stringValueForKey:@"rid" defaultValue:@""];
                    reasonItem.rname = [dict stringValueForKey:@"rname" defaultValue:@""];
                    [reasonArr addObject:reasonItem];
                }
                uninterestedItem.reasonData = reasonArr;
            }
            uninterestedItem.token = [responseObject stringValueForKey:@"token" defaultValue:@""];
            completion(nil, uninterestedItem);
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        completion(error, nil);
    }];
}

+ (void)requestUninterestedReportWithDic:(NSDictionary *)dic
                              Completion:(void(^)(NSError *error, id data))completion {
    SNReasonsForUninterestedReportRequest *request = [[SNReasonsForUninterestedReportRequest alloc] initWithDictionary:dic];
    [request send:^(SNBaseRequest *request, id responseObject) {
        completion(nil, responseObject);
    } failure:^(SNBaseRequest *request, NSError *error) {
        completion(error, nil);
    }];
}

@end

