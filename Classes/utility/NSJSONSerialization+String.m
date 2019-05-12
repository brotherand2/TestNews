//
//  NSJSONSerialization+String.m
//  sohunews
//
//  Created by lhp on 2/3/15.
//  Copyright (c) 2015 Sohu.com. All rights reserved.
//

#import "NSJSONSerialization+String.h"

@implementation NSJSONSerialization (String)


+ (id)JSONObjectWithString:(NSString *)jsonString options:(NSJSONReadingOptions)opt error:(NSError **)error
{
    id jsonObject = nil;
    if (jsonString.length > 0) {
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                     options:opt
                                                       error:error];
    }
    
    return jsonObject;
}

+ (NSString *)stringWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error
{
    NSString *jsonString = nil;
    if (obj && [self isValidJSONObject:obj]) {
        NSData *jsonData = [self dataWithJSONObject:obj options:opt error:error];
        if (jsonData) {
            jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
        }
    }
    return jsonString;
}

@end
