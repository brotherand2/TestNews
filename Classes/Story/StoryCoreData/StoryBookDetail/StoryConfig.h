//
//  StoryConfig.h
//  sohunews
//
//  Created by chuanwenwang on 2016/11/25.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


NS_ASSUME_NONNULL_BEGIN

@interface StoryConfig : NSManagedObject

+ (NSFetchRequest<StoryConfig *> *)fetchRequest;

@property (nonatomic) float chapterFont;
@property (nullable, nonatomic, copy) NSString *externString;

/*
 *   插入书籍配置
 */
+(void)insertStoryConfigWithDic:(nonnull NSDictionary*)configDic;

/*
 *   查询书籍配置
 */
+(NSArray *)fecthStoryConfig;

/*
 *   更新书籍配置
 */
+(void)updateStoryConfigWithDic:(nonnull NSDictionary*)configDic;

@end

NS_ASSUME_NONNULL_END
