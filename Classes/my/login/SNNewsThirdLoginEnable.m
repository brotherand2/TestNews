//
//  SNNewsThirdLoginEnable.m
//  sohunews
//
//  Created by wang shun on 2017/5/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNNewsThirdLoginEnable.h"

@interface SNNewsThirdLoginEnable ()

@end

@implementation SNNewsThirdLoginEnable

-(instancetype)init{
    if (self = [super init]) {
        self.isLanding = NO;
    }
    return self;
}

+ (SNNewsThirdLoginEnable *)sharedInstance {
    static SNNewsThirdLoginEnable *_instance = nil;
    @synchronized(self) {
        if (nil == _instance) {
            _instance = [[SNNewsThirdLoginEnable alloc] init];
        }
    }
    return _instance;
}

@end
