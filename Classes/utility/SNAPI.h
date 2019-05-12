//
//  SNAPI.h
//  sohunews
//
//  Created by Dan Cong on 5/13/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  "SNAppUsageStatData.h"
#import "SNAppConfigManager.h"

@interface SNAPI : NSObject

+ (BOOL)testModeEnabled;

+ (BOOL)isHttpsUrl:(NSString *)url;
+ (NSRange)rangeOfUrl:(NSString *)url;
+ (BOOL)isItunes:(NSString *)url;
+ (BOOL)isWebURL:(NSString *)url;
+ (NSString *)rootSchemeUrl:(NSString *)url;
+ (NSString *)rootScheme;

+ (NSString *)baseUrlWithDomain:(NSString *)domain;
+ (NSString *)domain:(NSString *)domain url:(NSString *)url;
+ (NSString *)rootUrl:(NSString *)url;
+ (NSString *)circleRootUrl:(NSString *)url;
+ (NSString *)liveRootUrl:(NSString *)url;
+ (NSString *)productId;
+ (NSString *)encodedBundleID;

+ (NSString *)starDotGifParamString;
+ (NSString *)aDotGifUrlWithParameters:(NSString *)parameters;
+ (NSString *)cDotGifUrlPrefixWithParameters:(NSString *)parameters;
+ (NSString *)nDotGifUrlPrefixWithParameters:(NSString *)parameters;
+ (NSString *)usrDotGifUrlWithStatData:(SNAppUsageStatData *)statData;
+ (NSString *)reqstatDotGifWithParamers:(NSString *)parameters;

@end
