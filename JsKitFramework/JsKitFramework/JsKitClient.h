//
//  JsKitClient.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/15.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JsKitStorageManager.h"

#import "JKJsKitCoreApi.h"

@class JsKitClient;

@interface JsKitClient : NSObject<UIWebViewDelegate>

@property (weak,nonatomic,readonly) UIWebView* webView;

@property (assign,nonatomic) BOOL jsKitInited;

@property (weak,nonatomic)id<UIWebViewDelegate> delegate;

@property (strong,nonatomic) NSMutableDictionary *callbackBlockDic;

@property (strong,nonatomic,readonly)JKJsKitCoreApi* coreApi;

-(instancetype)initWithWebView:(UIWebView*)webView;

+(void)globelInit;

/**
 * 添加一个native对象给所有的JsKitClient管理的WebView中js调用.
 * 只有在JsKitClient初始化前添加的才会被生效.
 * target的所有-(id)jsInterface:(JsKitClient)开头的方法都会注册给js.
 */
+(void)addGlobelJavascriptInterface:(id)target forName:(NSString*)name;

/**
 * 存储一个用户数据.
 */
-(void)setUserData:(id)value forKey:(id)key;

/**
 * 存储一个用户数据，value不会被引用计数.
 */
-(void)setNoRetainUserData:(id)value forKey:(id)key;

/**
 * 获取一个用户数据.
 */
-(id)getUserData:(id)key;

/**
 * 获取一个没有被引用计数的用户数据.
 */
-(id)getNoRetainUserData:(id)key;

/**
 * 删除一个给所有WebView调用的native对象.
 */
-(void)removeGlobelJavascriptInterface:(NSString*)name;

/**
 * 添加一个native对象给当前的JsKitClient管理的WebView中js调用.
 * target的所有-(id)jsInterface:(JsKitClient)开头的方法都会注册给js
 */
-(void)addJavascriptInterface:(id)target forName:(NSString*)name;

/**
 * 删除一个给当前JsKitClient中的Js调用的natvie对象.
 */
-(void)removeJavascriptInterface:(NSString*)name;

/**
 * 执行一个js脚本，并拿到返回结果.<br/>
 * 采用NSString format参数.<br/>
 * 调用示例：[client evaluatingJavaScriptWithFormat:@"jsObjName.jsFunctionName('%s',%d)",@"hello",YES];将执行脚本：javascript:jsObjName.jsFunctionName('hello',1);<br/>
 * 返回结果支持 NSNumber,NSString,NSArray,NSDictionary对于js的Number/Boolean,String,Array,Object<br/>
 */
-(id)evaluatingJavaScriptWithFormat:(NSString *)jsFormat, ...;

/**
 * 执行一个javascript函数，不同于evalautingJavaScriptWithFormat，这个方法只能执行一个js的function，而不是任意的js脚本.<br/>
 * 调用示例：[jsKitClien evaluatingJavaScriptFunction:@"jsObjName.jsFunctionName",@(111),@(YES),[JKValue argEnd]];将执行脚本：javascript:jsObjName.jsFunctionName(111,1);<br/>
 * @param functionName js的函数名<br/>
 * @args 参数.智能传id类型的对象，数值@(1),boolean @(YES), nil。最后一个必须是[JKValue argEnd].<br/>
 * 返回结果同 evaluatingJavaScriptWithFormat
 */
-(id)evaluatingJavaScriptFunction:(NSString*)functionName, ...;

-(id)evaluatingJavaScriptFunction:(NSString*)functionName argsCount:(NSUInteger)count, ...;

-(id)evaluatingJavaScriptFunction:(NSString*)functionName arguments:(NSArray*)arguments;

+(NSData*)callNative:(NSURLRequest*) request;

+(NSData *)jskitResponseOfRequest:(NSURLRequest*)request outMimeType:(NSString**)pMimeType policy:(NSURLCacheStoragePolicy*)policy;

-(NSString*)getInitScript;

-(void)reload;

@end
