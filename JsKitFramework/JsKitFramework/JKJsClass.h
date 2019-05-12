//
//  JKJsClass.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/15.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKJsClass : NSObject

@property (nonatomic) Class clz;
@property (strong,nonatomic) NSString* scriptInit;
@property (strong,nonatomic) NSString* jsClassName;

-(instancetype)initWithClass:(Class)clz;

-(id)invokeMethod:(NSString*)methodName receiver:(id)receiver jsKitClient:(id)client params:(NSArray*)params;

@end
