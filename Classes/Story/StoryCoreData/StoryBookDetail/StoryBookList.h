//
//  StoryBookList.h
//  sohunews
//
//  Created by sohu on 16/11/2.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

//#import "StoryBookList+CoreDataClass.h"

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChapterList;

NS_ASSUME_NONNULL_BEGIN

@interface StoryBookList : NSManagedObject

+ (NSFetchRequest<StoryBookList *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *author;         //作者
@property (nullable, nonatomic, copy) NSString *bookDescription;//书籍简介
@property (nullable, nonatomic, copy) NSString *bookId;         //书籍id
@property (nullable, nonatomic, copy) NSString *bookImg;        //书籍图片
@property (nullable, nonatomic, copy) NSString *bookTitle;      //书籍名称
@property (nullable, nonatomic, copy) NSString *cid;            //设备id
@property (nonatomic) BOOL isfinish;                            //是否完结
@property (nullable, nonatomic, copy) NSString *pid;            //账户id
@property (nonatomic) int64_t readCount;                        //已读多少章节
@property (nonatomic) int64_t status;                           //状态
@property (nullable, nonatomic, copy) NSString *type;           //书籍最多章节数
@property (nonatomic) int64_t maxChapters;                      //书籍类型
@property (nonatomic) int64_t wordCount;                        //书籍总字数
@property (nonatomic) BOOL isAddBookSelf;                       //是否加入书架
@property (nonatomic) int64_t hasReadPageNum;                   //读哪一页
@property (nonatomic) int64_t hasReadChapterIndex;              //已读章节
@property (nonatomic) int64_t hasReadChapterId;                 //已读章节id

/*
 *   插入书籍信息
 */
+ (void)insertBookInfoWithDic:(nonnull NSDictionary *)bookDic
                       bookId:(nonnull NSString *)bookId;

/*
 *   查询书籍信息
 */
+ (StoryBookList *)fecthBookByBookId:(nonnull NSString *)bookId;

/*
 *   通过数据库查询数据
 */
+ (StoryBookList *)fecthBookByBookIdByUsingCoreData:(nonnull NSString *)bookId;

/*
 *   更新书籍信息
 */
+ (void)updateBookInfoByBook:(nonnull StoryBookList *)book
                     bookDic:(nonnull NSDictionary *)bookDic;

/*
 *   更新书籍已读章节信息
 */
+ (void)updateBookInfoWithRecordingHasReadChapterByBookId:(nonnull NSString *)bookId bookDic:(nonnull NSDictionary *)bookDic;

/*
 *   删除某本书
 */
+ (void)removeBookInfoByBookId:(nonnull NSString *)bookId;

/*
 *   删除所有书
 */
+ (void)removeAllBooks;

@end

@interface StoryBookList (CoreDataGeneratedAccessors)
- (void)addBookShipObject:(ChapterList *)value;
- (void)removeBookShipObject:(ChapterList *)value;
- (void)addBookShip:(NSSet<ChapterList *> *)values;
- (void)removeBookShip:(NSSet<ChapterList *> *)values;
@end

NS_ASSUME_NONNULL_END
