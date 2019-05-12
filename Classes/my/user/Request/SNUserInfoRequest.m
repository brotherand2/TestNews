//
//  SNUserInfoRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/1/19.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUserInfoRequest.h"

@interface SNUserInfoRequest ()

@property (nonatomic, assign) BOOL isSelf;

@end

@implementation SNUserInfoRequest

- (instancetype)initWithDictionary:(NSDictionary *)dict andIsSelf:(BOOL)isSelf
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.needNetSafeParameters = YES;
        self.isSelf = isSelf;
    }
    return self;
}


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_requestUrl {
    return SNLinks_Path_Userinfo;
}

- (id)sn_parameters {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    
    if (self.isSelf) {
        [params setValuesForKeysWithDictionary:[[SNAnalytics sharedInstance] addConfigureLoginReferParams]];
    }
    [params setValue:kLoginTypeSohu forKey:@"logintype"];
    [params setValuesForKeysWithDictionary:[SNUtility paramsDictionaryForReadingCircle]];
    [self.parametersDict setValuesForKeysWithDictionary:params];
    return [super sn_parameters];
}

@end
