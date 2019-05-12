//
//  JKUpgradeManager.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/23.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JKWebAppManager;

@interface JKUpgradeManager : NSObject

-(instancetype)initWithWebAppManager:(JKWebAppManager*)manager;

-(void)checkUpgradeAtPointTime;

-(void)checkUpgradeNow;

@end
