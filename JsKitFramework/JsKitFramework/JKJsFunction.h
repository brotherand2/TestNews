//
//  JKJsFunction.h
//  LiteSohuNews
//
//  Created by sevenshal on 16/1/18.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JsKitClient.h"

@interface JKJsFunction : NSObject

-(instancetype)initWithClient:(JsKitClient*)client funName:(id)aFunName;

-(id)apply:(id) firstParam,...;

-(id)applyWithArgCount:(NSInteger) argCount,...;

-(void)cancel;

@end
