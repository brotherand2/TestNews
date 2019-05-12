//
//  SNChapterBag.m
//  sohunews
//
//  Created by HuangZhen on 16/03/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNChapterBag.h"

@implementation SNChapterBag

- (instancetype)init {
    if (self = [super init]) {
        _price = 0;
        _bag = [NSMutableArray array];
    }
    return self;
}

@end
