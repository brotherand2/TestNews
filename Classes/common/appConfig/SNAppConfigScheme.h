//
//  SNAppConfigScheme.h
//  sohunews
//
//  Created by yangln on 2016/10/18.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppConfigScheme : NSObject

@property (nonatomic, strong) NSArray *appSchemeList;//服务端下发第三方app scheme列表

- (void)updateWithDict:(NSDictionary *)dict;

@end
