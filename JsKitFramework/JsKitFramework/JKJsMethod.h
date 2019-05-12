//
//  JKJsMethod.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/16.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <objc/runtime.h>

@class JKJsClass;

@interface JKJsMethod : NSObject

@property (assign,nonatomic,readonly) BOOL supportCallbackFun;

@property (strong,nonatomic,readonly) NSString* jsMethodName;

+(JKJsMethod*)jsMethod:(Method)__method forClass:(JKJsClass*)jsClz;

-(id)invokeMethod:(id)receiver jsKitClient:(id)client params:(NSArray*)params;

@end
