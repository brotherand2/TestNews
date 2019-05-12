//
//  JKJsClassManager.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/15.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKJsClass.h"

@interface JKJsClassManager : NSObject

+(JKJsClassManager*)manager;

-(JKJsClass*) getJsClass:(Class)clz;


@end
