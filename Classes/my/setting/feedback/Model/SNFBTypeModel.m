//
//  SNFBTypeModel.m
//  sohunews
//
//  Created by 李腾 on 2016/10/11.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFBTypeModel.h"
#import "SNFBTypeListRequest.h"

@implementation SNFBTypeModel

+ (instancetype)fbTypeModelWithDict:(NSDictionary *)dict {
    SNFBTypeModel *obj = [[self alloc] init];
    obj.typeID = dict[@"_id"];
    obj.name = dict[@"description"];
    obj.icon = dict[@"icon"];

    return obj;
}

+ (void)requestFBTypeListWithFinishHandle:(void(^)(NSArray <SNFBTypeModel *> *typeList))finishHandle failure:(void(^)(NSError *error))failure {
    
    [[[SNFBTypeListRequest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSArray *typeList = responseObject[@"data"];
            NSMutableArray *arrM = [NSMutableArray array];
            [typeList enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [arrM addObject:[self fbTypeModelWithDict:obj]];
            }];
            finishHandle(arrM.copy);
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        failure(error);
    }];

}

@end
