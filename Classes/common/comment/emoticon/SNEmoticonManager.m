//
//  SNEmoticonManager.m
//  sohunews
//
//  Created by jialei on 14-5-4.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNEmoticonManager.h"
#import "SNCommentConfigs.h"

static SNEmoticonManager *__instance = nil;

@implementation SNEmoticonManager

+ (SNEmoticonManager *)sharedManager
{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        __instance = [[super allocWithZone:NULL] init];
    });
    return __instance;
}

#pragma mark - Singleton
+ (id)allocWithZone:(NSZone *)zone {
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)init {
    if (__instance) {
        return __instance;
    }
    if(self = [super init]) {
        self.emoticons = [[NSMutableArray alloc] init];
        self.emoticonDesKeys = [[NSMutableDictionary alloc] init];
        NSArray *newsEmoticons = [self emoticonObjectsFromPlist:@"newsEmoticons"];
        NSArray *liveEmoticons = [self emoticonObjectsFromPlist:@"liveEmoticons"];
        
        [self.emoticons addObjectsFromArray:newsEmoticons];
        [self.emoticons addObjectsFromArray:liveEmoticons];
        
        NSMutableDictionary *emoticonDict = [NSMutableDictionary dictionary];
        for (SNEmoticonObject *emoticon in self.emoticons)
        {
            
            NSRange range = [emoticon.chineseName rangeOfString:@"["];
            NSString *emoticonDes = nil;
            if (range.length > 0) {
                NSRange desRange = NSMakeRange(range.location + 1, emoticon.chineseName.length - 2);
                emoticonDes = [emoticon.chineseName substringWithRange:desRange];
            }
            if (emoticonDes.length > 0) {
                //            emoticon.description = emoticonDes;
                [emoticonDict setObject:emoticon forKey:emoticonDes];
            }
            else {
                [emoticonDict setObject:emoticon forKey:emoticon.chineseName];
            }
        }
        [self.emoticonDesKeys addEntriesFromDictionary:emoticonDict];
    }
    
    return self;
}

//- (id)retain {
//    return self;
//}
//
//- (oneway void)release {
//    // Do nothing
//}
//
//- (id)autorelease {
//    return self;
//}
//
//- (NSUInteger)retainCount {
//    return NSUIntegerMax;
//}

- (void)dealloc {
     //(_emoticons);
     //(_emoticonDesKeys);
    
}

#pragma getMethod
- (NSArray *)emoticonConfigsFromPlist:(NSString *)plistName
{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName
                                                                                                   ofType:@"plist"]];
    
    NSArray *plistConfigArray = [dic arrayValueForKey:@"emoticonConfig" defaultValue:nil];
    NSInteger count = [plistConfigArray count];
    NSMutableArray *configArray = [[NSMutableArray alloc] initWithCapacity:count];
    
    for (int i = 0; i < count; i++) {
        NSDictionary *configDic = plistConfigArray[i];
        
        if (configDic && [configDic isKindOfClass:[NSDictionary class]]) {
            SNEmoticonConfig *config = [[SNEmoticonConfig alloc] init];
            config.emoticonPlistName = [configDic stringValueForKey:@"plist" defaultValue:nil];
            config.emoticonClassName = [configDic stringValueForKey:@"class" defaultValue:nil];
            config.emoticonType = [configDic stringValueForKey:@"type" defaultValue:nil];
            
            [configArray addObject:config];
        }
    }
    return configArray;
}

- (NSArray *)emoticonObjectsFromPlist:(NSString *)plistName
{
    NSArray *array = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:plistName
                                                                                      ofType:@"plist"]];
    NSArray *emoticons = [SNEmoticonObject objectsWithJSONArray:array];
    
    return emoticons;
}

- (NSUInteger)emoticonsCount {
    return self.emoticons.count;
}

- (SNEmoticonObject *)emoticonAtIndex:(NSUInteger)index
{
    if (index < self.emoticonsCount) {
		return _emoticons[index];
	}
	return nil;
}

- (SNEmoticonObject *)emoticonForDes:(NSString *)description
{
    SNEmoticonObject *emoticon = [self.emoticonDesKeys objectForKey:description];
    return emoticon;
}

- (NSMutableString *)parseEmoticonFromText:(NSString *)text  emoticon:(NSMutableDictionary *)emoticonRangeDic
{
    if (text.length <= 0) {
        return [NSMutableString stringWithString:text];
    }
    
    //找出表情符号对应的名字
    NSArray *imageNames = [text itemsWithPattern:commentEmoticonPattern captureGroupIndex:1];
    NSArray *emoticonRanges = [text itemRangesWithPattern:commentEmoticonPattern];
    unichar attachmentCharacter = spaceHolderCharacter;
    NSString *spaceHolder = [NSString stringWithFormat:@"%@",[NSString stringWithCharacters:&attachmentCharacter length:1]];
//    NSArray *newRanges = [emoticonRanges offsetRangesInArrayBy:[spaceHolder length]];
    if (imageNames.count <= 0) {
        return [NSMutableString stringWithString:text];
    }
    
    NSMutableArray *realEmoticonRanges = [NSMutableArray array];
    int rangeIndex = 0;
    for (NSString *emoticonDes in imageNames) {
        SNEmoticonObject *emoticon = [self.emoticonDesKeys objectForKey:emoticonDes];
        if (emoticon) {
            [realEmoticonRanges addObject:emoticonRanges[rangeIndex]];
        }
        rangeIndex++;
    }
    
    NSMutableString *parsedText = [text replaceCharactersAtIndexes:realEmoticonRanges
                                                        withString:spaceHolder];
    
    rangeIndex = 0;
    for (NSString *emoticonDes in imageNames) {
        SNEmoticonObject *emoticon = [self.emoticonDesKeys objectForKey:emoticonDes];
        if (emoticon) {
            NSRange newRange = [realEmoticonRanges[rangeIndex] rangeValue];
            newRange.length = 1;
            [emoticonRangeDic setObject:emoticon forKey:[NSValue valueWithRange:newRange]];
            rangeIndex++;
        }
    }
    
    if (!parsedText) {
        parsedText = [NSMutableString stringWithString:text];
    }

    
    return parsedText;
}

@end
