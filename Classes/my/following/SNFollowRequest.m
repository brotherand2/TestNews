//
//  SNFollowRequest.m
//  sohunews
//
//  Created by 李腾 on 2017/2/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNFollowRequest.h"

@interface SNFollowRequest ()
@property (nonatomic, copy) NSString *pid;
@property (nonatomic, assign) BOOL isFollowing;
@end

@implementation SNFollowRequest
- (instancetype)initWithDict:(NSDictionary *)dict pid:(NSString *)pid andIsFollowing:(BOOL)isFollowing
{
    self = [super initWithDictionary:dict];
    if (self) {
        self.pid = pid;
        self.isFollowing = isFollowing;

    }
    return self;
}


#pragma mark - SNRequestProtocol

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

- (NSString *)sn_customUrl {
    NSString *str = nil;
    if (self.isFollowing) {
        str = @"following";
    } else {
        str = @"followed";
    }
    return [NSString stringWithFormat:SNLinks_Path_UserFollow,str,self.pid];
}

- (id)sn_parameters {
    [self.parametersDict setValuesForKeysWithDictionary:[SNUtility paramsDictionaryForReadingCircle]];
    return [super sn_parameters];
}
@end
