//
//  NSString+DBMigration.m
//  sohunews
//
//  Created by handy wang on 2/18/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "NSString+DBMigration.h"

@implementation NSString(DBMigration)

- (BOOL)endWith:(NSString *)s1 {
    if (!s1 || [@"" isEqualToString:s1] || !self || [@"" isEqualToString:self]) {
        return NO;
    }
    if ([self isEqualToString:s1]) {
        return YES;
    }
    NSRange _range = [self rangeOfString:s1];
    return (_range.location == (self.length-s1.length) && _range.length > 0);
}

@end