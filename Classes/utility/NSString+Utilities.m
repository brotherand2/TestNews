//
//  NSString+Utilities.m
//  sohunews
//
//  Created by sohunews on 13-8-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "NSString+Utilities.h"
#import "RegexKitLite.h"
#import <CommonCrypto/CommonDigest.h>

#define spacePlaceHolderChar (@" ")

@implementation NSString(Utilities)


- (CGSize)getTextSizeWithFontSize:(CGFloat)fontSize {
    return [self textSizeWithFont:[UIFont systemFontOfSize:fontSize]];
}

// iOS7 计算text的CGSize

- (CGSize) textSizeWithFont:(UIFont *) font {
    
    CGSize textSize = CGSizeZero;

    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)) {
        textSize = [self sizeWithFont:font];
    }else {
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              font, NSFontAttributeName,nil];
        textSize = [self sizeWithAttributes:attributesDictionary];
    }
    return textSize;
}


- (CGSize) textSizeWithFont:(UIFont *) font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize textSize = CGSizeZero;
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)) {
        textSize = [self sizeWithFont:font
                    constrainedToSize:size
                        lineBreakMode:lineBreakMode];
    }else {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineBreakMode = lineBreakMode;
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              font, NSFontAttributeName,
                                              paragraphStyle,NSParagraphStyleAttributeName,nil];
        [paragraphStyle release];
        
        CGRect frame = [self boundingRectWithSize:CGSizeMake(size.width, size.height)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:attributesDictionary
                                          context:nil];
        textSize = CGSizeMake(ceilf(frame.size.width), ceilf(frame.size.height));
        
    }
    return textSize;
}

// iOS7  drawInRect

- (void) textDrawInRect:(CGRect)rect
               withFont:(UIFont *)font
          lineBreakMode:(NSLineBreakMode)lineBreakMode
              alignment:(NSTextAlignment) alignment
              textColor:(UIColor *) color {
    
    if (!lineBreakMode) {
        lineBreakMode = NSLineBreakByWordWrapping;
    }
    if (!alignment) {
        alignment = NSTextAlignmentLeft;
    }
    if (!color) {
        color = [UIColor blackColor];
    }
    
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)) {
        [color set];
        [self drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:alignment];
    }else {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = alignment;
        paragraphStyle.lineBreakMode = lineBreakMode;
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              font, NSFontAttributeName,
                                              color,NSForegroundColorAttributeName,
                                              paragraphStyle,NSParagraphStyleAttributeName,nil];
        [paragraphStyle release];
        [self drawInRect:rect withAttributes:attributesDictionary];
    }
}


- (void) textDrawAtPoint:(CGPoint)point
                forWidth:(CGFloat)width
                withFont:(UIFont *)font
           lineBreakMode:(NSLineBreakMode)lineBreakMode
               textColor:(UIColor *) color {
    
    if (!lineBreakMode) {
        lineBreakMode = NSLineBreakByWordWrapping;
    }
    if (!color) {
        color = [UIColor blackColor];
    }
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)) {
        [self drawAtPoint:point forWidth:width withFont:font lineBreakMode:lineBreakMode];
        
    }else {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = lineBreakMode;
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              font, NSFontAttributeName,
                                              color,NSForegroundColorAttributeName,
                                              paragraphStyle,NSParagraphStyleAttributeName,nil];
        [paragraphStyle release];
        [self drawAtPoint:point withAttributes:attributesDictionary];
    }
}

- (void) textDrawAtPoint:(CGPoint)point withFont:(UIFont *)font textColor:(UIColor *) color {
    
    if (!color) {
        color = [UIColor blackColor];
    }
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)) {
        [self drawAtPoint:point withFont:font];
    }else {
        [self textDrawAtPoint:point
                     forWidth:0
                     withFont:font
                lineBreakMode:NSLineBreakByWordWrapping
                    textColor:color];
    }
}

- (BOOL)isValidEmail {
	if ([self length] == 0) {
		return NO;
	}
	
	NSString *emailRegEx		= @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	BOOL bIsValidEmail	= [self isMatchedByRegex:emailRegEx];
	return bIsValidEmail;
}

- (BOOL)isValidPhoneNumber {
	if ([self length] == 0) {
		return NO;
	}
	
	NSString *phoneNumberRegEx		= @"((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$)";
	BOOL bIsValidPhoneNumber		= [self isMatchedByRegex:phoneNumberRegEx];
	return bIsValidPhoneNumber;
}

- (BOOL)startWith:(NSString *)s1 {
    if (!s1 || [@"" isEqualToString:s1] || !self || [@"" isEqualToString:self]) {
        return NO;
    }
    if ([self isEqualToString:s1]) {
        return YES;
    }
    NSRange _range = [self rangeOfString:s1];
    return (_range.location == 0 && _range.length > 0);
}

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


- (NSString *)trim {
	//clear symbole in token string
	//chh 201307: 会把开头结尾有用的符号，如>，$等去掉
    //NSString *urlString = [self stringByTrimmingCharactersInSet:[NSCharacterSet symbolCharacterSet]];
	//clear space in token string
	NSString *str = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	return str;
}

- (NSString *)stringFromMD5 {
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    unsigned int strlength = (int)strlen(value);
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlength, outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [outputString autorelease];
}

- (int)convertStringToLength {//判断中英混合的的字符串长度,中文2，英文1
    int strLength = 0;
    char *p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0 ; i < [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strLength++;
        }
        else {
            p++;
        }
        
    }
    return strLength;
}

#pragma mark - 获取文件大小
+ (NSInteger)getFileSize:(NSString*)filePath {
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:filePath]) {
        NSDictionary *attributes = [filemanager attributesOfItemAtPath:filePath error:nil];
        NSNumber *theFileSize;
        if ((theFileSize = [attributes objectForKey:NSFileSize]))
            return [theFileSize intValue];
        else
            return -1;
    } else {
        return -1;
    }
}

- (NSDictionary *)translateJsonStringToDictionary {
    if (nil == self) {
        return nil;
    }
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    return dic;
}

#pragma mark - 日期转换相关

- (NSString *)getDateFormate {
    NSString *dateFormateString = nil;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self doubleValue]];
    //下面这行代码存在内存泄漏
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    NSInteger recordYear = [comps year];
    NSInteger recordMonth = [comps month];
    NSInteger recordDay = [comps day];
    
    comps = [calendar components:unitFlags fromDate:[NSDate date]];
    NSInteger currentYear = [comps year];
    NSInteger currentMonth = [comps month];
    NSInteger currentDay = [comps day];
    
    if (recordDay != currentDay || recordMonth != currentMonth || recordYear != currentYear ) {
        dateFormateString = [NSDate stringFromDate:date withFormat:@"yyyy/MM/dd HH:mm"];
    }
    else {
        dateFormateString = [NSDate stringFromDate:date withFormat:@"HH:mm"];
    }
    
    [calendar release];
    return dateFormateString;
}

+ (NSDate *)getDateFromSecond:(NSString *)secondString {
    NSDate *nowDate = [NSDate date];
    NSTimeInterval timeInterval = [nowDate timeIntervalSince1970];
    
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:([secondString integerValue] + timeInterval)];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:confromTimesp];
    NSDate *localeDate = [confromTimesp  dateByAddingTimeInterval: interval];
    return localeDate;
}

- (BOOL)containsString:(NSString *)subString
{
    return [self rangeOfString:subString].location != NSNotFound;
}


- (BOOL)isContainChineseCharacter {
    for (int i = 0; i < [self length]; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *subString = [self substringWithRange:range];
        const char *cString = [subString UTF8String];
        if (strlen(cString) == 3) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isContainsEmoji {
    __block BOOL returnValue = NO;
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    return returnValue;
}

+ (NSString*)stringWithUUID
{
    // Create a new UUID
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    
    // Get the string representation of the UUID
    NSString *newUUID = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [newUUID autorelease];
}

+ (NSString *)spacePlaceHolder:(NSInteger)length
{
    NSMutableString *space = [[NSMutableString alloc] initWithCapacity:length];
    int i = 0;
    while (i < length) {
        [space appendString:spacePlaceHolderChar];
        i++;
    }
    return [space autorelease];
}

- (NSMutableDictionary *)toParametersDictionary {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
	for (NSString *parameterString in [self componentsSeparatedByString:@"&"]) {
		NSArray *parameter = [parameterString componentsSeparatedByString:@"="];
		if ([parameter count] == 2) {
			[parameters setObject:[parameter objectAtIndex:1] forKey:[parameter objectAtIndex:0]];
		}
	}
    return parameters;
}

- (NSArray *)itemRangesWithPattern:(NSString *)pattern
{
    if (!pattern) {
        return nil;
    }
    
    NSError *error = nil;
    NSRegularExpression *regExp = [[[NSRegularExpression alloc] initWithPattern:pattern
                                                                       options:NSRegularExpressionCaseInsensitive
                                                                         error:&error] autorelease];
    
    // 查找匹配的字符串
    NSArray *result = [regExp matchesInString:self
                                      options:NSMatchingReportCompletion
                                        range:NSMakeRange(0, [self length])];
    
    if (error) {
        SNDebugLog(@"ERROR: %@", result);
        return nil;
    }
    
    NSUInteger count = [result count];
    // 没有查找到结果，返回空数组
    if (0 == count) {
        return [NSArray array];
    }
    
    // 将返回数组中的 NSTextCheckingResult 的实例的 range 取出生成新的 range 数组
    NSMutableArray *ranges = [[[NSMutableArray alloc] initWithCapacity:count] autorelease];
    for(NSInteger i = 0; i < count; i++)
    {
        @autoreleasepool {
            NSRange aRange = [[result objectAtIndex:i] range];
            [ranges addObject:[NSValue valueWithRange:aRange]];
        }
    }
    return ranges;
}

- (NSArray *)itemsWithPattern:(NSString *)pattern captureGroupIndex:(NSUInteger)index
{
    if ( !pattern ) {
        return nil;
    }
    
    NSError *error = nil;
    NSRegularExpression *regx = [[[NSRegularExpression alloc] initWithPattern:pattern
                                                                     options:NSRegularExpressionCaseInsensitive error:&error] autorelease];
    if (error)
    {
        SNDebugLog(@"Error for create regular expression:\nString: %@\nPattern %@\nError: %@\n",self, pattern, error);
    }
    else
    {
        NSMutableArray *results = [[[NSMutableArray alloc] init] autorelease];
        NSRange searchRange = NSMakeRange(0, [self length]);
        [regx enumerateMatchesInString:self
                               options:0
                                 range:searchRange
                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                
                                NSRange groupRange =  [result rangeAtIndex:index];
                                if (groupRange.length + groupRange.location <= self.length) {
                                    NSString *match = [self substringWithRange:groupRange];
                                    [results addObject:match];
                                }
                            }];
        return results;
    }
    return nil;
}

- (NSMutableString *)replaceCharactersAtIndexes:(NSMutableArray *)indexes withString:(NSString *)aString
{
    if (!indexes || !aString) {
        return nil;
    }
    
    NSUInteger offset = 0;
    NSMutableString *raw = [[self mutableCopy] autorelease];
    
    NSInteger prevLength = 0;
    for(NSInteger i = 0; i < [indexes count]; i++)
    {
        @autoreleasepool {
            NSRange range = [[indexes objectAtIndex:i] rangeValue];
            prevLength = range.length;
            
            range.location -= offset;
            [indexes replaceObjectAtIndex:i withObject:[NSValue valueWithRange:range]];
            [raw replaceCharactersInRange:range withString:aString];
            offset = offset + prevLength - [aString length];
        }
    }
    
    return raw;
}

- (NSString *)replaceSubStringWithSpace:(NSString *)pattern
{
    if (!pattern) {
        return self;
    }
    
    NSUInteger offset = 0;
    NSMutableString *raw = [[self mutableCopy] autorelease];
    
    NSArray *itemIndexes = [self itemRangesWithPattern:pattern];
    if (itemIndexes.count <= 0) {
        return self;
    }
    
    NSInteger prevLength = 0;
    for(NSInteger i = 0; i < [itemIndexes count]; i++)
    {
        @autoreleasepool {
            NSRange range = [[itemIndexes objectAtIndex:i] rangeValue];
            prevLength = range.length;
            
            NSString *space = [NSString spacePlaceHolder:range.length];
            
            range.location -= offset;
            [raw replaceCharactersInRange:range withString:space];
            offset = offset + prevLength - [space length];
        }
    }
    
    return raw;
}

+ (NSDictionary *)getURLParas:(NSString *)URL {
    NSArray *lastURLString = [URL componentsSeparatedByString:@"//"];
    if (lastURLString.count == 0) {
        return nil;
    }
    //取得URL"?"之后的数据
    NSString *query = [lastURLString lastObject];
    //取得URL"&"之间的数据
    NSArray *queryElements = [query componentsSeparatedByString:@"&"];
    if (queryElements.count == 0) {
        return nil;
    }
    
    NSMutableDictionary *dic = [[[NSMutableDictionary alloc] init] autorelease];
    for (NSString *element in queryElements) {
        NSArray *keyVal = [element componentsSeparatedByString:@"="];
        if (keyVal.count > 0) {
            NSString *key = [keyVal objectAtIndex:0];
            NSString *value = (keyVal.count == 2) ? [keyVal lastObject] : nil;
            [dic setValue:value forKey:key];
        }
    }
    return dic;
}

+ (NSString *)writeToFileWithName:(NSString *)fileName {
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [documents stringByAppendingPathComponent:fileName];
}

+ (NSString *)chineseStringWithInt:(int)number {
    NSString *countStr = nil;
    number = abs(number);
    if (number >= 100000000) {
        countStr = [NSString stringWithFormat:@"%.1f亿",number/100000000.0f];
        countStr = [countStr stringByReplacingOccurrencesOfString:@".0" withString:@""];
    }
    else if (number >= 10000) {
        countStr = [NSString stringWithFormat:@"%.1f万",number/10000.0f];
        countStr = [countStr stringByReplacingOccurrencesOfString:@".0" withString:@""];
    }else {
        countStr = [NSString stringWithFormat:@"%d", number];
        countStr = [countStr isEqualToString:@"0"] ? @"" : countStr;
    }
    return countStr;
}

@end

@implementation NSString(Sort)

//排序分组新闻标题
- (NSComparisonResult)sortNewsSectionTitleWithArray:(NSString *)elementString {
    
    NSDate *compareDate = [NSDate dateFromString:elementString];
    NSDate *date = [NSDate dateFromString:self];
    if (!compareDate || !date) {
        return NSOrderedAscending;
    }
    
    NSTimeInterval compareTimeInterval = [compareDate timeIntervalSince1970];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    if (compareTimeInterval <= timeInterval)
    {
        return NSOrderedAscending;
    }
    else
    {
        return NSOrderedDescending;
    }
}

@end

@implementation NSString (SNURLEncodingAdditions)
- (NSString *)URLEncodedString {
	NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8);
	return [result autorelease];
}

- (NSString*)URLDecodedString {
	NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8);
    NSString *resultWithoutPlus = [result stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    [result autorelease];
    return resultWithoutPlus;
}
@end
