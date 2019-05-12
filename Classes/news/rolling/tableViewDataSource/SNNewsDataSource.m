//
//  SNNewsDataSource.m
//  sohunews
//
//  Created by chenhong on 14-3-6.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNNewsDataSource.h"
#import "SNRollingNewsTableController.h"

@implementation SNNewsDataSource

- (void)dealloc {
    
    self.controller = nil;
}

- (BOOL)isModelEmpty {
    return (self.items == nil || self.items.count == 0);
}

@end
