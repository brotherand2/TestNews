//
//  NSObject+MethodExchange.h
//  sohunews
//
//  Created by guoyalun on 1/22/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#define EXCHANGE_METHOD(a,b) [[self class]exchangeMethod:@selector(a) withNewMethod:@selector(b)]

@interface NSObject (MethodExchange)
+(void)exchangeMethod:(SEL)origSel withNewMethod:(SEL)newSel;
+(void)replaceMethod:(SEL)origSel withNewMethod:(SEL)newSel;

@end