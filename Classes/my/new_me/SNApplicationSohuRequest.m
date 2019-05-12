//
//  SNApplicationSohuRequest.m
//  sohunews
//
//  Created by TengLi on 2017/6/2.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNApplicationSohuRequest.h"


@implementation SNApplicationSohuRequest

+ (void)checkReloadApplicationSohuWithHandler:(void(^)(BOOL needReload,NSDictionary *data))handler {
    
    [[[self alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *jsonDict = (NSDictionary *)responseObject;
            NSInteger statusCode = [[jsonDict stringValueForKey:@"statusCode" defaultValue:@""] integerValue];
            if (31000000 == statusCode) {
                NSDictionary *dataDict = [jsonDict dictionaryValueForKey:@"data" defalutValue:nil];
                if (dataDict && [dataDict isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *fileData = [NSDictionary dictionaryWithContentsOfFile:SN_ApplicationSohuPath];
                    if (![fileData isEqualToDictionary:dataDict]) { // 与本地所存的比较,判断是否有变化
                        [dataDict writeToFile:SN_ApplicationSohuPath atomically:YES];
                        if (handler) {
                            handler(YES, dataDict);
                        }
                    } else {
                        if (handler) {
                            handler(NO, dataDict);
                        }
                    }
                }
            }
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        if (handler) {
            handler(NO,nil);
        }
    }];
}


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Subcribe_GetTabs;
}

- (id)sn_parameters {
    [self.parametersDict setValue:[SNAPI productId] forKey:@"productId"];
    return [super sn_parameters];
}
@end
