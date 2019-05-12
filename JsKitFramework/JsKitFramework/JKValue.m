//
//  JKValue.m
//  JsKitFramework
//
//  Created by sevenshal on 16/7/25.
//  Copyright © 2016年 sohu. All rights reserved.
//

#import "JKValue.h"

@implementation JKValue

+(JKValue*) argEnd{
    static dispatch_once_t a;
    static JKValue* end;
    dispatch_once(&a, ^{
        end = [[JKValue alloc] init];
    });
    return end;
}

@end
