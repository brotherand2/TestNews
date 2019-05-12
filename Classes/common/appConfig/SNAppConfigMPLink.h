//
//  SNAppConfigMPLink.h
//  sohunews
//
//  Created by yangln on 2017/4/19.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNDefaultParamsRequest.h"

@interface SNAppConfigMPLink : SNDefaultParamsRequest

@property (nonatomic, strong) NSString *mpLink;

- (void)updateWithDict:(NSDictionary *)dict;

@end
