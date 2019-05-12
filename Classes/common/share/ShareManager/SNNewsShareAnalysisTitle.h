//
//  SNNewsShareAnalysisTitle.h
//  sohunews
//
//  Created by wang shun on 2017/5/16.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsShareAnalysisTitle : NSObject

+ (NSDictionary*)getIsAppClassData:(NSString*)iconTitle WithData:(NSDictionary*)data;

+ (NSString*)returnWebUrl:(NSString*)webUrl WithOption:(SNActionMenuOption)option;

@end
