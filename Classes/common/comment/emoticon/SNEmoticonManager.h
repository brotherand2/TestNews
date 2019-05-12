//
//  SNEmoticonManager.h
//  sohunews
//
//  Created by jialei on 14-5-4.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNEmoticonObject.h"

static NSString *const spacePlaceHolder =  @" ";
enum {
    spaceHolderCharacter = 0xfffc
};

@protocol SNEmoticonScrollViewDelegate <NSObject>

/**
 * 	返回用户选择的表情模型.
 *
 * 	@param emoticon 用户选择的表情模型.
 */
- (void)emoticonDidSelect:(SNEmoticonObject *)emoticon;
- (void)emoticonDidDelete;

@optional
- (void)emoticonTabSelect:(SNEmoticonType)type;

@end

@class SNEmoticonObject;
@interface SNEmoticonManager : NSObject

@property (nonatomic, strong) NSMutableArray *emoticons;               //表情数据结构数组
@property (nonatomic, assign) NSUInteger emoticonsCount;
@property (nonatomic, strong) NSMutableDictionary *emoticonDesKeys;     //表情描述索引

+ (SNEmoticonManager *)sharedManager;
- (SNEmoticonObject *)emoticonAtIndex:(NSUInteger)index;
- (SNEmoticonObject *)emoticonForDes:(NSString *)description;

//返回表情range和表情图对应字典
- (NSMutableString *)parseEmoticonFromText:(NSString *)text  emoticon:(NSMutableDictionary *)emoticonRangeDic;
- (NSArray *)emoticonObjectsFromPlist:(NSString *)plistName;

@end
