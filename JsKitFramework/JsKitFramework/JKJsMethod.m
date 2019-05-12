//
//  JKJsMethod.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/16.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import "JKJsMethod.h"
#import "JsKitClient.h"
#import "JKJsClass.h"
#import "JKJsFunction.h"

@implementation JKJsMethod{
    NSInvocation* invocation;
    SEL sel;
    NSMethodSignature* methodSignature;
    NSUInteger methodArgsCount;
    NSUInteger methodReturnLen;
    Method method;
}

@synthesize jsMethodName;

-(instancetype)initWithClass:(JKJsClass*)clz supportCallbackFun:(BOOL)__supportCallbackFun method:(Method)__method jsMethodName:(NSString*)_jsMethodName sel:(SEL)_sel{
    if (self=[super init]) {
        jsMethodName = _jsMethodName;
        _supportCallbackFun = __supportCallbackFun;
        method = __method;
        sel = _sel;
        methodSignature = [clz.clz instanceMethodSignatureForSelector:sel];
        methodArgsCount = [methodSignature numberOfArguments]-3;
        methodReturnLen = [methodSignature methodReturnLength];
        invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    }
    return self;
}

+(JKJsMethod*)jsMethod:(Method)__method forClass:(JKJsClass*)jsClz{
//        method = _method;
//        nativeSelector = method_getName(_method);
    
    static NSRegularExpression *regex = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        regex= [NSRegularExpression regularExpressionWithPattern:@"^jsInterface(WithCallback)?[:_]([^:_]+)" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    SEL methodSel = method_getName(__method);
    NSString* methodName = NSStringFromSelector(methodSel);
    NSTextCheckingResult* result = [regex firstMatchInString:methodName options:0 range:NSMakeRange(0, methodName.length)];
    if (result) {
        BOOL supportJsFun = [result rangeAtIndex:1].length>0;
        NSString* jsMethodName = [methodName substringWithRange:[result rangeAtIndex:2]];
        return [[JKJsMethod alloc] initWithClass:jsClz supportCallbackFun:supportJsFun method:__method jsMethodName:jsMethodName sel:methodSel];
    }
    return nil;
}

-(id)invokeMethod:(id)receiver jsKitClient:(id)client params:(NSArray*)params{
//    [invocation setArgument:(nonnull void *) atIndex:params];
//    [receiver performSelector:(SEL) withObject:(id) withObject:(id)];
    [invocation setTarget:receiver];
    [invocation setSelector:sel];
    [invocation setArgument:(&client) atIndex:2];
    NSUInteger i=0,c=MIN(methodArgsCount, [params count]);
    void* args[c];
    for (;i<c;i++) {
        id param = [params objectAtIndex:i];
        if (_supportCallbackFun && param && [param isKindOfClass:[NSString class]] && [param hasPrefix:@"_jsKitFunCallback_"]) {
            param = [[JKJsFunction alloc] initWithClient:client funName:param];
        }
        args[i] = (__bridge_retained void *)(param);
        [invocation setArgument:&args[i] atIndex:i+3];
    }
    void* nilP = nil;
    for(;i<methodArgsCount;i++){
        [invocation setArgument:&nilP atIndex:i+3];
    }
    [invocation invoke];
    for (i=0; i<c; i++) {
        CFBridgingRelease(args[i]);
    }
    if (methodReturnLen==sizeof(void*)) {
        void* result;
        [invocation getReturnValue:&result];
        return (__bridge id)(result);
    }
    return nil;
//    return [receiver performSelector:nativeSelector withObject:client withObject:params];
}

@end
