//
//  StoryBookList.m
//  sohunews
//
//  Created by PZ on 16/11/2.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "StoryBookList.h"
#import "ChapterList.h"
#import "SHCoreDataHelper.h"
#import "SNStoryUtility.h"

@implementation StoryBookList

+ (NSFetchRequest<StoryBookList *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"StoryBookList"];
}

@dynamic author;
@dynamic bookDescription;
@dynamic bookId;
@dynamic bookImg;
@dynamic bookTitle;
@dynamic cid;
@dynamic isfinish;
@dynamic pid;
@dynamic readCount;
@dynamic status;
@dynamic type;
@dynamic wordCount;
@dynamic maxChapters;
@dynamic isAddBookSelf;
@dynamic hasReadPageNum;
@dynamic hasReadChapterIndex;
@dynamic hasReadChapterId;

+ (void)insertBookInfoWithDic:(nonnull NSDictionary *)bookDic
                       bookId:(nonnull NSString *)bookId {
    //数据库操作在主线程
    if (!bookDic || bookId.length <= 0) {
        return;
    } else {
        //获取上下文
        NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
        
        StoryBookList *curBookList = [StoryBookList fecthBookByBookIdByUsingCoreData:bookId];
        
        if (curBookList == nil) {//插入
            StoryBookList *bookList = [NSEntityDescription insertNewObjectForEntityForName:@"StoryBookList" inManagedObjectContext:context];
            bookList.author = [bookDic objectForKey:@"author"];
            bookList.bookDescription = [bookDic objectForKey:@"description"];
            bookList.bookId = bookId;
            bookList.bookImg = [bookDic objectForKey:@"img"];
            bookList.bookTitle = [bookDic objectForKey:@"title"];
            
            if ([[bookDic objectForKey:@"isfinish"]integerValue] == 1) {
                bookList.isfinish = YES;
            } else {
                bookList.isfinish = NO;
            }
            
            if ([[bookDic objectForKey:@"addBookSelf"] isEqualToString:@"1"]) {
                bookList.isAddBookSelf = YES;
            } else {
                bookList.isAddBookSelf = NO;
            }
            
            NSString *pid = [SNStoryUtility getPid];
            if (![SNStoryUtility isLogin]) {
                pid = [SNStoryUtility getP1];
            }
            
            bookList.pid = pid;
            
            bookList.readCount = [[bookDic objectForKey:@"readCount"] integerValue];
            bookList.type = [bookDic objectForKey:@"type"];
            bookList.wordCount = [[bookDic objectForKey:@"wordCount"] integerValue];
            bookList.maxChapters = [[bookDic objectForKey:@"maxChapters"]integerValue];
            
        } else {//更新
            [StoryBookList updateBookInfoByBook:curBookList bookDic:bookDic];
        }
        
        [[SHCoreDataHelper sharedInstance] saveContext];
    }
}

#pragma mark 第一次pid无数据，同步cid数据，反之，不行
+ (void)insertPidBookInfoByCidBookIfo:(StoryBookList *)cidBook
                       bookId:(nonnull NSString *)bookId {
    //数据库操作在主线程
    if (!cidBook || bookId.length <= 0) {
        return;
    } else {
        //获取上下文
        NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
        
        StoryBookList *bookList = [NSEntityDescription insertNewObjectForEntityForName:@"StoryBookList" inManagedObjectContext:context];
        bookList.author = cidBook.author;
        bookList.bookDescription = cidBook.bookDescription;
        bookList.bookId = bookId;
        bookList.bookImg = cidBook.bookImg;
        bookList.bookTitle = cidBook.bookTitle;
        bookList.isfinish = cidBook.isfinish;
        bookList.isAddBookSelf = cidBook.isAddBookSelf;
        
        NSString *pid = [SNStoryUtility getPid];
        bookList.pid = pid;
        
        bookList.readCount = cidBook.readCount;
        bookList.type = cidBook.type;
        bookList.wordCount = cidBook.wordCount;
        bookList.maxChapters = cidBook.maxChapters;
        
        [[SHCoreDataHelper sharedInstance] saveContext];
    }
}

+ (StoryBookList *)fecthBookByBookIdByUsingCoreData:(nonnull NSString *)bookId {
    //数据库操作在主线程
    if (bookId.length <= 0) {
        return nil;
    }
    
    NSString *pid = [SNStoryUtility getPid];
    if (![SNStoryUtility isLogin]) {
        pid = [SNStoryUtility getP1];
    }
    
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    // 1. 实例化查询请求
    NSFetchRequest *request = [StoryBookList fetchRequest];
    
    // 2. 设置谓词条件
    request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND pid = %@", bookId,pid];
    
    // 3. 由上下文查询数据
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    if (result && result.count > 0) {
        return [result firstObject];
    }
    return nil;
}

+ (StoryBookList *)fecthBookByBookIdByUsingCoreDataForCidWithBookId:(nonnull NSString *)bookId {
    //数据库操作在主线程
    if (bookId.length <= 0) {
        return nil;
    }
    
    NSString *pid = [SNStoryUtility getP1];
    
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    // 1. 实例化查询请求
    NSFetchRequest *request = [StoryBookList fetchRequest];
    
    // 2. 设置谓词条件
    request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND pid = %@", bookId,pid];
    
    // 3. 由上下文查询数据
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    if (result && result.count > 0) {
        return [result firstObject];
    }
    return nil;
}

+ (StoryBookList *)fecthBookByBookId:(nonnull NSString *)bookId {
    return [StoryBookList fecthBookByBookIdByUsingCoreData:bookId];
}

+ (void)updateBookInfoByBook:(nonnull StoryBookList *)book
                     bookDic:(nonnull NSDictionary *)bookDic {
    book.author = [bookDic objectForKey:@"author"];
    book.bookDescription = [bookDic objectForKey:@"description"];
    book.bookId = [bookDic objectForKey:@"oid"];
    book.bookImg = [bookDic objectForKey:@"img"];
    book.bookTitle = [bookDic objectForKey:@"title"];
    if ([[bookDic objectForKey:@"isfinish"]integerValue] == 1) {
        book.isfinish = YES;
    } else {
        book.isfinish = NO;
    }
    
    if ([[bookDic objectForKey:@"addBookSelf"] isEqualToString:@"1"]) {
        book.isAddBookSelf = YES;
    } else {
        book.isfinish = NO;
    }
    book.readCount = [[bookDic objectForKey:@"readCount"]integerValue];
    book.type = [bookDic objectForKey:@"type"];
    book.wordCount = [[bookDic objectForKey:@"wordCount"]integerValue];
    book.maxChapters = [[bookDic objectForKey:@"maxChapters"]integerValue];
}

+ (void)updateBookInfoWithRecordingHasReadChapterByBookId:(NSString *)bookId bookDic:(NSDictionary *)bookDic {
    //数据需要在主线程操作
    StoryBookList *book = [StoryBookList fecthBookByBookIdByUsingCoreData:bookId];
    
    if (!book && ([SNStoryUtility isLogin])) {//第一次pid无数据，同步cid数据，反之，不行
        StoryBookList *cidBook = [StoryBookList fecthBookByBookIdByUsingCoreDataForCidWithBookId:bookId];
        [StoryBookList insertPidBookInfoByCidBookIfo:cidBook bookId:bookId];
        book = [StoryBookList fecthBookByBookIdByUsingCoreData:bookId];
    }
    
    book.hasReadPageNum = [[bookDic objectForKey:@"hasReadPageNum"]integerValue];
    book.hasReadChapterIndex = [[bookDic objectForKey:@"hasReadChapterIndex"]integerValue];
    book.hasReadChapterId = [[bookDic objectForKey:@"hasReadChapterId"]integerValue];
    
    //需要主线程保存
    [[SHCoreDataHelper sharedInstance] saveContext];
}

+ (void)removeBookInfoByBookId:(nonnull NSString *)bookId {
    if (!bookId) {
        return;
    }
    
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    //实例化查询请求
    NSFetchRequest *request = [StoryBookList fetchRequest];
    
    //设置谓词条件
    NSString *pid = [SNStoryUtility getPid];
    if (![SNStoryUtility isLogin]) {
        pid = [SNStoryUtility getP1];
    }
    request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND pid = %@", bookId,pid];
    
    //由上下文查询数据
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    if (result && result.count > 0) {
        NSInteger count = result.count;
        //输出结果
        for (int i = 0; i < count; i++) {
            StoryBookList *bookList = result[i];
            // 删除一条记录
            [context deleteObject:bookList];
        }
        
        //保存数据
        [[SHCoreDataHelper sharedInstance] saveContext];
    }
}

+ (void)removeAllBooks {
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    NSFetchRequest *fectchRequest = [StoryBookList fetchRequest];
    NSArray *array = [context executeFetchRequest:fectchRequest error:nil];
    
    if (array && array.count > 0) {
        NSInteger count = array.count;
        
        //输出结果
        for (int i = 0; i < count; i++) {
            StoryBookList *bookList = array[i];
            // 删除一条记录
            [context deleteObject:bookList];
        }
        
        //保存数据
        [[SHCoreDataHelper sharedInstance] saveContext];
    }
}

@end
