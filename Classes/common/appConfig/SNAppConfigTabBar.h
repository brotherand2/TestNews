//
//  SNAppConfigTabBar.h
//  sohunews
//
//  Created by Scarlett on 16/8/5.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppConfigTabBar : NSObject

@property (nonatomic, strong)NSArray *tabBarTextArray;

- (void)updateWithDict:(NSDictionary *)dict;

@end
