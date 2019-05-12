//
//  StoryConfig.m
//  sohunews
//
//  Created by chuanwenwang on 2016/11/25.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "StoryConfig.h"
#import "SHCoreDataHelper.h"

@implementation StoryConfig

+ (NSFetchRequest<StoryConfig *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"StoryConfig"];
}

@dynamic chapterFont;
@dynamic externString;

+(void)insertStoryConfigWithDic:(nonnull NSDictionary*)configDic
{
    if (!configDic || configDic.count <= 0) {
        
        return;
    }
    else{
        
        //获取上下文
        NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
        
        NSArray *arry = [StoryConfig fecthStoryConfig];
        
        if (!arry || arry.count <= 0) {//插入
            
            StoryConfig *storyConfig = [NSEntityDescription insertNewObjectForEntityForName:@"StoryConfig" inManagedObjectContext:context];
            storyConfig.chapterFont = [[configDic objectForKey:@"chapterFont"]floatValue];
            storyConfig.externString = [configDic objectForKey:@"externString"];
            
        } else {//更新
            
            [StoryConfig updateStoryConfigWithDic:configDic];
        }
        
        [[SHCoreDataHelper sharedInstance] saveContext];
    }
}

+(NSArray *)fecthStoryConfig
{
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    // 1. 实例化查询请求
    NSFetchRequest *request = [StoryConfig fetchRequest];
    // 2. 由上下文查询数据
    NSArray *result = [context executeFetchRequest:request error:nil];
    return result;
}

+(void)updateStoryConfigWithDic:(nonnull NSDictionary*)configDic
{
    if (!configDic || configDic.count <= 0) {
        
        return;
    }
    
    //获取上下文
    NSArray *arry = [StoryConfig fecthStoryConfig];
    
    if (!arry || arry.count <= 0) {//插入
        return;
    }
    
    for (StoryConfig *config in arry) {
        
        config.chapterFont = [[configDic objectForKey:@"chapterFont"]floatValue];
        config.externString = [configDic objectForKey:@"externString"];
    }
    
    [[SHCoreDataHelper sharedInstance] saveContext];
}

@end
