//
//  JKRequestManager.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/23.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <netinet/in.h>
#import "AFNetworking.h"

@interface JKRequestManager : NSObject

+(JKRequestManager*_Nonnull)manager;

-(void)getUpgradeInfo:(NSString* _Nonnull)deviceId sdkVer:(NSInteger)sdkVer hostAppName:(NSString* _Nonnull)hostAppName hostVer:(id _Nonnull)hostVer pluginInfos:(NSArray*_Nonnull)infos success:(void (^_Nullable)(id _Nonnull data))success
              failure:(void (^_Nullable)(NSError  * _Nonnull error))failure;

@end
