//
//  JKWebAppManager.h
//  JsKitFramework
//
//  Created by sevenshal on 15/10/14.
//  Copyright © 2015年 sohu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JKWebApp.h"

#import "JKUpgradeManager.h"

@interface JKWebAppManager : NSObject

@property(strong,nonatomic,readonly)NSString* rootPath;

@property(strong,nonatomic,readonly)NSString* buildResoucePath;

@property(strong,nonatomic,readonly) JKUpgradeManager* upgradeManager;

+(JKWebAppManager*)manager;

-(BOOL)isBuildInWebAppWithUrl:(NSURL*)url;

-(JKWebApp*)getWebAppWithUrl:(NSURL*)url relativePath:(NSString**)outRelatviePath;

-(JKWebApp*)getWebAppWithName:(NSString*)name;

-(NSString*)getNameByUrl:(NSURL*)url relativePath:(NSString**)outRelatviePath;

-(NSArray*)getAllWebAppNames;

@end
