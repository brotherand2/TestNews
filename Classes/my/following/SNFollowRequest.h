//
//  SNFollowRequest.h
//  sohunews
//
//  Created by 李腾 on 2017/2/15.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@interface SNFollowRequest : SNDefaultParamsRequest
- (instancetype)initWithDict:(NSDictionary *)dict pid:(NSString *)pid andIsFollowing:(BOOL)isFollowing;
@end
