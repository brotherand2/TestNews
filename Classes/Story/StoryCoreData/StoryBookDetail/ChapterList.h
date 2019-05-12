//
//  ChapterList.h
//  sohunews
//
//  Created by sohu on 16/11/2.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChapterList : NSManagedObject

+ (NSFetchRequest<ChapterList *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *bookId;//书籍id
@property (nonatomic) int64_t chapterId;//章节id
@property (nullable, nonatomic, copy) NSString *chapterContent;//章节内容，加密过的
@property (nullable, nonatomic, copy) NSString *chapterKey;//解密key
@property (nullable, nonatomic, copy) NSString *chapterTitle;//章节标题
@property (nullable, nonatomic, copy) NSString *pid; 
@property (nonatomic) int64_t chapterWordCount;//章节字数
@property (nonatomic) BOOL isfree;//章节是否免费
@property (nonatomic) float price;//章节价格
@property (nonatomic) BOOL hasPaid;//章节是否购买过
@property (nonatomic) int64_t oid;//章节新闻id
@property (nonatomic) BOOL isDownload;//是否下载

//插入章节
+(void)insertBookChapterListWithArray:(NSArray*)chapterArray bookId:(NSString*)bookId;
//查询章节
+(NSArray *)fecthBookChapterListByBookId:(NSString *)bookId chapterId:(NSUInteger)chapterId ascending:(BOOL)ascending;
//更新章节
+(void)updateBookChapterListByBookId:(NSString *)bookId chapterDic:(NSDictionary*)chapterDic;
//更新购买章节
+(void)updateCartBookChapterListByBookId:(NSString *)bookId cartChapterArray:(NSArray*)cartChapterArray;
//更新章节内容
+(void)updateBookChapterListContentByBookId:(NSString *)bookId chapterDic:(NSDictionary*)chapterDic;
//第一次pid无数据，同步cid数据，反之，不行
+(void)pidBookByCidBookWithBookId:(NSString *)bookId;
//删除章节
+(void)removeBookChapterListByBookId:(NSString*)bookId chapterId:(NSUInteger)chapterId;

@end

NS_ASSUME_NONNULL_END
