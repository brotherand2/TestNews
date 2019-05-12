//
//  SNEmoticonObject.h
//  sohunews
//
//  Created by jialei on 14-5-4.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const notificationEmoticonDelete       = @"deleteEmoticon";
static NSString *const notificationSmallEmoticonSelect  = @"selectSmallEmoticon";
static NSString *const notificationBigEmoticonSelect    = @"selectBigEmoticon";

static NSString *const commentEmoticonPattern = @"\\[(\\w+)\\]";

typedef NS_ENUM(NSUInteger, SNEmoticonType) {
    SNEmoticonStatic = 1,
    SNEmoticonDynamic = 2
};

@interface SNEmoticonConfig : NSObject

@property (nonatomic, strong)NSString *emoticonClassName;
@property (nonatomic, strong)NSString *emoticonPlistName;
@property (nonatomic, strong)NSString *emoticonType;

@end

@interface SNEmoticonObject : NSObject

@property (nonatomic, strong)NSString *chineseName;
@property (nonatomic, strong)NSString *englishName;
@property (nonatomic, strong)NSString *pngName;
@property (nonatomic, strong)NSString *description;
@property (nonatomic, assign)SNEmoticonType type;

+ (NSMutableArray *)objectsWithJSONArray:(NSArray *)array;
- (UIImage *)emoticonImage;

@end
