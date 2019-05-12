//
//  JsKitStorageManager.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/19.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JsKitStorage.h"

@interface JsKitStorageManager : NSObject

+(JsKitStorageManager*)manager;

-(JsKitStorage*) storageForWebApp:(NSString*)webAppName;

@end
