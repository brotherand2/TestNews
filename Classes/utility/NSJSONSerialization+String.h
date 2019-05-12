//
//  NSJSONSerialization+String.h
//  sohunews
//
//  Created by lhp on 2/3/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSJSONSerialization (String)

+ (id)JSONObjectWithString:(NSString *)jsonString options:(NSJSONReadingOptions)opt error:(NSError **)error;

+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;

@end
