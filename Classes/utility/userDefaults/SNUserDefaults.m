//
//  SNUserDefaults.m
//  sohunews
//
//  Created by yangln on 2017/9/12.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNUserDefaults.h"

typedef NS_ENUM(NSInteger, SaveDataType) {
    ObjectSaveDataType,
    ValueSaveDataType,
    StringSaveDataType,
    BoolSaveDataType,
    IntergerSaveDataType,
    FloatSaveDataType,
    DoubleSaveDataType
};

@implementation SNUserDefaults

+ (void)setObject:(nullable id)value forKey:(nullable NSString *)key {
    [self setSaveDataWithKey:key value:value dataType:ObjectSaveDataType];
}

+ (nullable id)objectForKey:(nullable NSString *)key {
    return [self getSaveDataWithKey:key dataType:ObjectSaveDataType];
}

+ (void)setValue:(nullable id)value forKey:(nullable NSString *)key {
    [self setSaveDataWithKey:key value:value dataType:ValueSaveDataType];
}

+ (nullable id)valueForKey:(nullable NSString *)key {
    return [self getSaveDataWithKey:key dataType:ValueSaveDataType];
}

+ (NSString *)stringForKey:(nullable NSString *)key {
    return [self getSaveDataWithKey:key dataType:StringSaveDataType];
}

+ (void)setBool:(BOOL)value forKey:(nullable NSString *)key {
    [self setSaveDataWithKey:key value:[NSNumber numberWithBool:value] dataType:BoolSaveDataType];
}

+ (BOOL)boolForKey:(nullable NSString *)key {
    return [[self getSaveDataWithKey:key dataType:BoolSaveDataType] boolValue];
}

+ (void)setInteger:(NSInteger)value forKey:(nullable NSString *)key {
    [self setSaveDataWithKey:key value:[NSString stringWithFormat:@"%d", value] dataType:IntergerSaveDataType];
}

+ (NSInteger)integerForKey:(nullable NSString *)key {
    return [[self getSaveDataWithKey:key dataType:IntergerSaveDataType] integerValue];
}

+ (void)setFloat:(float)value forKey:(nullable NSString *)key {
    [self setSaveDataWithKey:key value:[NSString stringWithFormat:@"%f", value] dataType:FloatSaveDataType];
}

+ (float)floatForKey:(nullable NSString *)key {
    return [[self getSaveDataWithKey:key dataType:FloatSaveDataType] floatValue];
}

+ (void)setDouble:(double)value forKey:(nullable NSString *)key {
    [self setSaveDataWithKey:key value:[NSString stringWithFormat:@"%f", value] dataType:DoubleSaveDataType];
}

+ (double)doubleForKey:(nullable NSString *)key {
    return [[self getSaveDataWithKey:key dataType:DoubleSaveDataType] doubleValue];
}

+ (void)setSaveDataWithKey:(NSString *)key value:(id)value dataType:(SaveDataType)dataType {
    if (key.length == 0) {
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    switch (dataType) {
        case ObjectSaveDataType:
            [userDefaults setObject:value forKey:key];
            break;
        case ValueSaveDataType:
            [userDefaults setValue:value forKey:key];
            break;
        case BoolSaveDataType:
            [userDefaults setBool:[value boolValue] forKey:key];
            break;
        case IntergerSaveDataType:
            [userDefaults setInteger:[value integerValue] forKey:key];
            break;
        case FloatSaveDataType:
            [userDefaults setFloat:[value floatValue] forKey:key];
            break;
        case DoubleSaveDataType:
            [userDefaults setDouble:[value doubleValue] forKey:key];
            break;
        
        default:
            break;
    }
    [userDefaults synchronize];
}

+ (id)getSaveDataWithKey:(NSString *)key dataType:(SaveDataType)dataType {
    if (key.length == 0) {
        return nil;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    id savedData = nil;
    switch (dataType) {
        case ObjectSaveDataType:
            savedData = [userDefaults objectForKey:key];
            break;
        case ValueSaveDataType:
            savedData = [userDefaults valueForKey:key];
            break;
        case StringSaveDataType:
            savedData = [userDefaults stringForKey:key];
            break;
        case BoolSaveDataType:
            savedData = [NSNumber numberWithBool:[userDefaults boolForKey:key]];
            break;
        case IntergerSaveDataType:
            savedData = [NSNumber numberWithInteger:[userDefaults integerForKey:key]];
            break;
        case FloatSaveDataType:
            savedData = [NSNumber numberWithFloat:[userDefaults floatForKey:key]];
            break;
        case DoubleSaveDataType:
            savedData = [NSNumber numberWithDouble:[userDefaults doubleForKey:key]];
            break;
            
        default:
            break;
    }
    return savedData;
}

+ (void)removeObjectForKey:(nullable NSString *)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:key];
    [userDefaults synchronize];
}

@end
