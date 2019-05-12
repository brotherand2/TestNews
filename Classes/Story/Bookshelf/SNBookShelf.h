//
//  SNBookShelf.h
//  sohunews
//
//  Created by H on 2016/11/22.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^addBookShelfDidFinished)(BOOL success);
typedef void(^removeBookShelfDidFinished)(BOOL success);
typedef void(^setHasReadDidFinished)(BOOL success);
typedef void(^setPushEnableDidFinished)(BOOL success);
typedef void(^getBooksDidFinished)(BOOL success,NSArray * books);

@interface SNBookShelf : NSObject

/**
 添加书架

 @param bookId 书籍id
 @param hasRead 是否已读（用于控制红点提醒）
 @param completedBlock 完成回调
 */
+ (void)addBookShelf:(NSString *)bookId hasRead:(BOOL)hasRead completed:(addBookShelfDidFinished)completedBlock;

/**
 删除书架
 
 @param bookId 书籍id
 @param completedBlock 完成回调
 */
+ (void)removeBookShelf:(NSString *)bookId completed:(removeBookShelfDidFinished)completedBlock;

/**
 设置已读标记

 @param bookId 书籍id
 */
+ (void)setBookHasRead:(NSString *)bookId complete:(setHasReadDidFinished)completedBlock;


/**
 获取书架的书籍

 @param page 页数 非必传
 @param count 数量 非必传
 */
+ (void)getBooks:(NSString *)page count:(NSString *)count complete:(getBooksDidFinished)completedBlock;

/**
 判断一本书是否在书架上 **取的是缓存，可能不准确**

 @param bookId 书的id
 @return YES 在书架上
 */
+ (BOOL)isOnBookshelf:(NSString *)bookId;

/**
 设置推送开关

 @param enable YES为允许推送
 @param bookId 书籍id
 */
+ (void)bookPushEnable:(BOOL)enable bookId:(NSString *)bookId complete:(setPushEnableDidFinished)completedBlock;

/**
 所有小说的推送开关

 @param enable YES 为书架所有的小说允许推送
 @param completedBlock 回调
 */
+ (void)bookAllPushEnable:(BOOL)enable complete:(setPushEnableDidFinished)completedBlock;

@end
