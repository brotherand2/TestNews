//
//  NSString+Utilities.h
//  sohunews
//
//  Created by sohunews on 13-8-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Utilities)

- (CGSize)getTextSizeWithFontSize:(CGFloat)fontSize;

- (CGSize) textSizeWithFont:(UIFont *) font;

- (CGSize) textSizeWithFont:(UIFont *) font
          constrainedToSize:(CGSize) size
              lineBreakMode:(NSLineBreakMode) lineBreakMode;


- (void) textDrawInRect:(CGRect) rect
               withFont:(UIFont *) font
          lineBreakMode:(NSLineBreakMode) lineBreakMode
              alignment:(NSTextAlignment) alignment
              textColor:(UIColor *) color;

- (void) textDrawAtPoint:(CGPoint) point
                forWidth:(CGFloat) width
                withFont:(UIFont *) font
           lineBreakMode:(NSLineBreakMode) lineBreakMode
               textColor:(UIColor *) color;

- (void) textDrawAtPoint:(CGPoint) point
                withFont:(UIFont *) font
               textColor:(UIColor *) color;

- (BOOL)isValidEmail;
- (BOOL)isValidPhoneNumber;

- (BOOL)startWith:(NSString *)s1;
- (BOOL)endWith:(NSString *)s1;
- (NSString *)trim;
- (NSString *)stringFromMD5;
- (int)convertStringToLength;                            // 计算中英混合字符串长度
+ (NSInteger)getFileSize:(NSString*)filePath;            // 获取指定路径下文件的大小
- (NSDictionary *)translateJsonStringToDictionary;       // JSON 转为字典
- (NSString *)getDateFormate;                            // 根据字符串获取到对应日期格式字符串
+ (NSDate *)getDateFromSecond:(NSString *)secondString;  // 从秒数字符串获取到对应日期
- (BOOL)isContainChineseCharacter;                       // 判断是否含有中文字符
- (BOOL)isContainsEmoji;                                 // 判断是否含有emoji表情
- (BOOL)containsString:(NSString *)subString;
+ (NSString*)stringWithUUID;
+ (NSString *)spacePlaceHolder:(NSInteger)length;
- (NSMutableString *)replaceCharactersAtIndexes:(NSMutableArray *)indexes withString:(NSString *)aString;

- (NSMutableDictionary *)toParametersDictionary;

//返回字符串中符合pattern的ranges数组
- (NSArray *)itemRangesWithPattern:(NSString *)pattern;
//返回字符串中符合pattern的子串
- (NSArray *)itemsWithPattern:(NSString *)pattern captureGroupIndex:(NSUInteger)index;
//替换字符串中的pattern为空格
- (NSString *)replaceSubStringWithSpace:(NSString *)pattern;

+ (NSDictionary *)getURLParas:(NSString *)URL;

+ (NSString *)writeToFileWithName:(NSString *)fileName;

///数字转换为个十百千万
+ (NSString *)chineseStringWithInt:(int)number;

@end

@interface NSString(Sort)

- (NSComparisonResult)sortNewsSectionTitleWithArray:(NSString *)elementString;

@end

@interface NSString (SNURLEncodingAdditions)
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;
@end
