//
//  SNAppConfigMPLink.m
//  sohunews
//
//  Created by yangln on 2017/4/19.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNAppConfigMPLink.h"
#import "SNAppConfigConst.h"

@implementation SNAppConfigMPLink

- (void)updateWithDict:(NSDictionary *)dict {
    self.mpLink = [dict stringValueForKey:kMPSubscribeUrl defaultValue:@""];
}

@end
