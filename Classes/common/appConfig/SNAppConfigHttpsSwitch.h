//
//  SNAppConfigHttpsSwitch.h
//  sohunews
//
//  Created by Scarlett on 16/9/6.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppConfigHttpsSwitch : NSObject

@property (nonatomic, assign) BOOL httpsSwitchStatus;
@property (nonatomic, assign) BOOL httpsSwitchStatusAll;

- (void)updateWithDict:(NSDictionary *)dict;


@end
