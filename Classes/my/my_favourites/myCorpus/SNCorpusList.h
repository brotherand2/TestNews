//
//  SNCorpusList.h
//  sohunews
//
//  Created by Valar__Morghulis on 2017/4/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNCorpusList : NSObject

/**
 保存收藏夹列表到本地

 @param corpusListArray 收藏夹列表
 */
+ (void)saveCorpusListWithCorpusListArray:(NSArray *)corpusListArray;

/**
 获取收藏夹列表

 @param handler 回调
 */
+ (void)getCorpusListWithHandler:(void(^)(NSArray *corpusList))handler;

/**
 重新保存最新的收藏夹列表到本地
 */
+ (void)resaveCorpusList;

/**
 从网络获取收藏列表

 @param success 获取成功的回调
 @param failure 失败的回调
 */
+ (void)loadCorpusListFromServerWithSuccessHandler:(void(^)(NSArray *corpusList))success failure:(void(^)())failure;

/**
 删除本地收藏夹列表
 */
+ (void)deleteLocalCorpusList;
@end
