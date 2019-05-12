//
//  NSDictionaryExtend.m
//  sohunews
//
//  Created by yanchen wang on 12-5-28.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "NSDictionaryExtend.h"

@interface __NSStack : NSObject {
    NSMutableArray  *_stackArray;
}
/**
 * @desc judge whether the stack is empty
 *
 * @return TRUE if stack is empty, otherwise FALASE is returned
 */
- (BOOL) empty;
/**
 * @desc get top object in the stack
 *
 * @return nil if no object in the stack, otherwise an object
 * is returned, user should judge the return by this method
 */
- (id) top;
/**
 * @desc pop stack top object
 */
- (void) pop;
/**
 * @desc push an object to the stack
 */
- (void) push:(id)value;
@end

@implementation __NSStack
- (id) init {
    self = [super init];
    if (self) {
        _stackArray = [[NSMutableArray alloc] init];
    }
    return self;
}
/**
 * @desc judge whether the stack is empty
 *
 * @return TRUE if stack is empty, otherwise FALASE is returned
 */
- (BOOL) empty {
    return ((_stackArray == nil)||([_stackArray count] == 0));
}
/**
 * @desc get top object in the stack
 *
 * @return nil if no object in the stack, otherwise an object
 * is returned, user should judge the return by this method
 */
- (id) top {
    id value = nil;
    if (_stackArray&&[_stackArray count]) {
        value = [_stackArray lastObject];
    }
    return value;
}
/**
 * @desc pop stack top object
 */
- (void) pop {
    if (_stackArray&&[_stackArray count]) {
        [_stackArray removeLastObject];
    }
}
/**
 * @desc push an object to the stack
 */
- (void) push:(id)value {
    [_stackArray addObject:value];
}
- (void) dealloc {
    [_stackArray release];
    [super dealloc];
}
@end

@implementation NSDictionary(Sort)

- (NSComparisonResult)sortLocalChannelWithLetter:(NSDictionary *)element
{
    NSString *letter = [self objectForKey:@"initial"];
    NSString *comparLetter = [element objectForKey:@"initial"];
    
    if (letter && comparLetter) {
        NSComparisonResult result = [letter caseInsensitiveCompare:comparLetter];
        return result;
    }else {
        return NSOrderedDescending;
    }
}

@end


@implementation NSDictionary(Extend)

- (id)objectForKey:(NSString *)key defalutObj:(id)defaultObj {
    id obj = [self objectForKey:key];
    return obj ? obj : defaultObj;
}

- (id)objectForKey:(id)aKey ofClass:(Class)aClass defaultObj:(id)defaultObj {
    id obj = [self objectForKey:aKey];
    return (obj && [obj isKindOfClass:aClass]) ? obj : defaultObj;
}

- (int)intValueForKey:(NSString *)key defaultValue:(int)defaultValue {
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return [(NSString *)value intValue];
    }
    return (value && [value isKindOfClass:[NSNumber class]]) ? [value intValue] : defaultValue;
}

- (double)doubleValueForKey:(NSString *)key defaultValue:(double)defaultValue
{
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return [(NSString *)value doubleValue];
    }
    return (value && [value isKindOfClass:[NSNumber class]]) ? [value doubleValue] : defaultValue;
}

- (float)floatValueForKey:(NSString *)key defaultValue:(float)defaultValue {
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return [(NSString *)value floatValue];
    }
    return (value && [value isKindOfClass:[NSNumber class]]) ? [value floatValue] : defaultValue;
}
- (long)longValueForKey:(NSString *)key defaultValue:(long)defaultValue {
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return [(NSString *)value longLongValue];
    }
    return (value && [value isKindOfClass:[NSNumber class]]) ? [value longValue] : defaultValue;
}

- (long long)longlongValueForKey:(NSString *)key defaultValue:(long long)defaultValue {
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return [(NSString *)value longLongValue];
    }
    return (value && [value isKindOfClass:[NSNumber class]]) ? [value longLongValue] : defaultValue;
}

- (NSString *)stringValueForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    id value = [self objectForKey:key];
    if (value && [value isKindOfClass:[NSString class]]) {
        return value;
    }else if(value && [value isKindOfClass:[NSNumber class]]){
        return [value stringValue];
    }else{
        return defaultValue;
    }
}

- (NSArray *)arrayValueForKey:(NSString *)key defaultValue:(NSArray *)defaultValue {
    id value = [self objectForKey:key];
    return (value && [value isKindOfClass:[NSArray class]]) ? value : defaultValue;
}

- (NSDictionary *)dictionaryValueForKey:(NSString *)key defalutValue:(NSDictionary *)defaultValue {
    id value = [self objectForKey:key];
    return (value && [value isKindOfClass:[NSDictionary class]]) ? value : defaultValue;
}

- (void)setRect:(CGRect)rect forKey:(NSString *)key
{
    if (key)
    {
        CFDictionaryRef dictionaryRef = CGRectCreateDictionaryRepresentation(rect);
        if (dictionaryRef)
        {
            [self setValue:(NSDictionary *)dictionaryRef forKey:key];
            CFRelease(dictionaryRef);
        }
    }
}

- (CGRect)rectValueForKey:(NSString *)key
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
    if (key)
    {
        id object = [self valueForKey:key];
        if (object && [object isKindOfClass:[NSDictionary class]])
        {
            bool result = false;
            result = CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)object, &rect);
            if (!result)
            {
                rect = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
            }
        }
    }
    return rect;
}


- (NSArray*) toArray {
    NSMutableArray *entities = [[NSMutableArray alloc] initWithCapacity:[self count]];
    NSEnumerator *enumerator = [self objectEnumerator];
    id value;
    while ((value = [enumerator nextObject])) {
        /* code that acts on the dictionary‚Äôs values */
        [entities addObject:value];
    }
    return [entities autorelease];
}
- (NSString*) toXMLString {
    NSMutableString *xmlString = [[NSMutableString alloc] initWithString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"];
    __NSStack *stack = [[__NSStack alloc] init];
    NSArray  *keys = nil;
    NSString *key  = nil;
    NSObject *value    = nil;
    NSObject *subvalue = nil;
    [stack push:self];
    while (![stack empty]) {
        value = [stack top];
        [stack pop];
        if (value) {
            if ([value isKindOfClass:[NSString class]]) {
                [xmlString appendFormat:@"</%@>", value];
            }
            else if([value isKindOfClass:[NSDictionary class]]) {
                keys = [(NSDictionary*)value allKeys];
                for (key in keys) {
                    subvalue = [(NSDictionary*)value objectForKey:key];
                    if ([subvalue isKindOfClass:[NSDictionary class]]) {
                        [xmlString appendFormat:@"<%@>", key];
                        [stack push:key];
                        [stack push:subvalue];
                    }
                    else if([subvalue isKindOfClass:[NSString class]]) {
                        [xmlString appendFormat:@"<%@>%@</%@>", key, subvalue, key];
                    }
                }
            }
        }
    }
    [stack release];
    return [xmlString autorelease];
}

- (NSString *)toUrlString {
    return [self mutableUrlString];
}

- (NSMutableString *)mutableUrlString {
    NSMutableString *str = [NSMutableString stringWithCapacity:32];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]] && [key isEqualToString:kOpenProtocolOriginalLink2]) {
            return;
        }
        [str appendFormat:@"&%@=%@", key, obj];
    }];
    return str;
}

- (NSString *)appendParamToUrlString:(NSString *)url{
    if (url.length > 0 && [self count] > 0) {
        NSMutableString *aUrl = [NSMutableString stringWithString:url];
        NSDictionary *params = [SNUtility getParemsInfoWithLink:url];
        [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([key isKindOfClass:[NSString class]] && ![params objectForKey:key] && ![key isEqualToString:kOpenProtocolOriginalLink2]) {
                [aUrl appendFormat:@"&%@=%@", key, obj];
            }
        }];
        return aUrl;
    }
    return url;
}

- (NSString *)translateDictionaryToJsonString {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&parseError];
    
    if (nil == parseError && jsonData && jsonData.length > 0) {
        return [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    } else {
        return nil;
    }
}


@end
