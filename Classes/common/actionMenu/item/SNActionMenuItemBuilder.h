//
//  SNActionMenuItemBuilder.h
//  sohunews
//
//  Created by Dan Cong on 3/27/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNActionMenuItemBuilder : NSObject

//通过SNActionMenuOptions按位或的方式创建ActionMenuItem
+ (NSArray *)buildActionMenuItemsWithOptions:(SNActionMenuOptions)options;

@end
