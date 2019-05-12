//
//  JKJsClass.m
//  JsKitFramework
//
//  Created by sevenshal on 15/10/15.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <objc/runtime.h>

#import "JKJsClass.h"
#import "JKJsMethod.h"

@implementation JKJsClass{
    NSMutableDictionary<NSString*,JKJsMethod*>* jsMethods;
}

-(instancetype)initWithClass:(Class)__clz{
    if (self=[super init]) {
        _clz = __clz;
        _jsClassName = NSStringFromClass(_clz);
        jsMethods = [[NSMutableDictionary alloc] init];
        [self initJavascript];
    }
    return self;
}

-(void)initJavascript{
    NSMutableString* mutableString = [[NSMutableString alloc] initWithCapacity:128];
    [mutableString appendString:@"var ts=jsKit.create();"];
    [self appendMethods:mutableString];
    _scriptInit = [mutableString stringByAppendingFormat:@"var %@=ts;",_jsClassName];
    
}

//private int appendMethods(String ojbName, StringBuffer stringBuffer) {
//    JsKitInterface methodAnnotation;
//    int count = 0;
//    for (Method method : clz.getMethods()) {
//        methodAnnotation = method.getAnnotation(JsKitInterface.class);
//        if (methodAnnotation != null) {
//            MethodInfo methodInfo = new MethodInfo(method, methodAnnotation);
//            methodMap.put(method.getName(), methodInfo);
//            stringBuffer.append("jsKit.addMethod(").append(ojbName).append(",'").append(method.getName()).append("');");
//            count++;
//        }
//    }
//    return count;
//}

-(int)appendMethods:(NSMutableString*)buffer{
    unsigned int allMethodsCount;
    int jsMethodCount = 0;
    Method * methods = class_copyMethodList(_clz, &allMethodsCount);
    for (int i=0; i<allMethodsCount; i++) {
        JKJsMethod* jsMethod = [JKJsMethod jsMethod:methods[i] forClass:self];
        if (jsMethod) {
            [jsMethods setObject:jsMethod forKey:jsMethod.jsMethodName];
            [buffer appendString:@"jsKit.addMethod"];
            if (jsMethod.supportCallbackFun) {
                [buffer appendString:@"WithCallback"];
            }
            [buffer appendString:@"(ts,'"];
            [buffer appendString:jsMethod.jsMethodName];
            [buffer appendString:@"');"];
            jsMethodCount++;
        }
//        NSString* methodName = NSStringFromSelector(method_getName(*methods));
//        NSTextCheckingResult* result = [regex firstMatchInString:methodName options:0 range:NSMakeRange(0, methodName.length)];
//        if (result) {
//            JKJsMethod* jsMethod = [[JKJsMethod alloc] initWithMethod:*methods];
//            jsMethod.jsMethodName = [methodName substringWithRange:[result rangeAtIndex:1]];
//            [jsMethods setObject:jsMethod forKey:jsMethod.jsMethodName];
//            [buffer appendFormat:@"jsKit.addMethod(ts,'%@');",jsMethod.jsMethodName];
//            jsMethodCount++;
//        }
    }
    free(methods);
    methods = nil;
    
    return jsMethodCount;
}

-(id)invokeMethod:(NSString*)methodName receiver:(id)receiver jsKitClient:(id)client params:(NSArray*)params{
    return [[jsMethods objectForKey:methodName] invokeMethod:receiver jsKitClient:client params:params];
}

@end
