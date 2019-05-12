//
//  SNNewsPPLoginHeader.h
//  sohunews
//
//  Created by wang shun on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNNewsPPLoginHeader : NSObject

+ (NSMutableDictionary*)getPPBaseParams;

+ (NSMutableDictionary *)getPPHeader;

+ (NSString*)getSig:(NSDictionary*)dic;
+ (NSString*)getUA;

+ (NSString*)getLongitude;
+ (NSString*)getLatitude;

+ (NSString*)getMac;
+ (float)getIOSVersion;
+ (NSString*)getIPAddress;

@end
