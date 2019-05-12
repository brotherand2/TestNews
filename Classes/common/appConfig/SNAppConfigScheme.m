//
//  SNAppConfigScheme.m
//  sohunews
//
//  Created by yangln on 2016/10/18.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNAppConfigScheme.h"
#import "SNAppConfigConst.h"

@implementation SNAppConfigScheme

- (void)updateWithDict:(NSDictionary *)dict {
    self.appSchemeList = [dict arrayValueForKey:kAppSchemeList defaultValue:nil];
}

@end
