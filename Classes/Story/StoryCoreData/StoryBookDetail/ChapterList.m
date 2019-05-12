//
//  ChapterList.m
//  sohunews
//
//  Created by sohu on 16/11/2.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "ChapterList.h"
#import "SHCoreDataHelper.h"
#import "StoryBookList.h"
#import "SNStoryRSA.h"
#import "SNStoryAesEncryptDecrypt.h"
#import "SNStoryUtility.h"

@implementation ChapterList

+ (NSFetchRequest<ChapterList *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ChapterList"];
}

@dynamic bookId;
@dynamic chapterId;
@dynamic chapterContent;
@dynamic chapterKey;
@dynamic chapterTitle;
@dynamic chapterWordCount;
@dynamic isfree;
@dynamic hasPaid;
@dynamic pid;
@dynamic price;
@dynamic oid;
@dynamic isDownload;

+(void)insertBookChapterListWithArray:(NSArray*)chapterArray bookId:(NSString*)bookId
{
    if (!chapterArray || bookId.length <= 0) {
        
        return;
    }
    else{
        
        NSArray *arry = [ChapterList fecthBookChapterListByBookId:bookId chapterId:0 ascending:YES];
        
        if (!arry || arry.count <= 0) {//插入
            
            [ChapterList insertWithChapterArray:chapterArray bookId:bookId];
        } else {//更新(作者更新了几个章节，如何处理，后期优化)
            SNDebugLog(@"gengxinChapterThenInsert");
            //更新章节
            [ChapterList updateBookChapterListByBookId:bookId chapterDic:@{@"chapters":chapterArray}];
        }
    }
}

+(void)insertWithChapterArray:(NSArray*)chapterArray bookId:(NSString*)bookId
{
    NSInteger count = chapterArray.count;
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    for (int i = 0; i < count; i++) {
        id chapter = chapterArray[i];
        SNDebugLog(@"insertWithChapterArray:%d/%ld",i,count);
        if ([chapter isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *chapterDic = (NSDictionary*)chapter;
            ChapterList *chapterList = [NSEntityDescription insertNewObjectForEntityForName:@"ChapterList" inManagedObjectContext:context];
            
            chapterList.bookId = bookId;
            chapterList.chapterId = [[chapterDic objectForKey:@"chapterId"]integerValue];
            chapterList.chapterTitle = [chapterDic objectForKey:@"title"];
            chapterList.chapterWordCount = [[chapterDic objectForKey:@"wordCount"]integerValue];
            chapterList.price = [[chapterDic objectForKey:@"price"]floatValue];
            chapterList.oid = [[chapterDic objectForKey:@"oid"]integerValue];
            chapterList.isDownload = NO;
            
            NSString *pid = [SNStoryUtility getPid];
            if (![SNStoryUtility isLogin]) {
                pid = [SNStoryUtility getP1];
            }
            
            chapterList.pid = pid;
            
            if ([[chapterDic objectForKey:@"isfree"]integerValue] == 1) {
                chapterList.isfree = YES;
            } else {
                chapterList.isfree = NO;
            }
            
            if ([[chapterDic objectForKey:@"hasPaid"]integerValue] == 1) {
                chapterList.hasPaid = YES;
            } else {
                chapterList.hasPaid = NO;
            }
            
        }
        
    }
    
    [[SHCoreDataHelper sharedInstance] saveContext];
}

#pragma mark 第一次pid无数据，同步cid数据，反之，不行
+(void)insertWithPidChapterByCidChapterWithChapterArray:(NSArray*)chapterArray bookId:(NSString*)bookId
{
    NSInteger count = chapterArray.count;
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    for (int i = 0; i < count; i++) {
        ChapterList * chapter = chapterArray[i];
        ChapterList *chapterList = [NSEntityDescription insertNewObjectForEntityForName:@"ChapterList" inManagedObjectContext:context];
        
        chapterList.bookId = bookId;
        chapterList.chapterId = chapter.chapterId;
        chapterList.chapterTitle = chapter.chapterTitle;
        chapterList.chapterWordCount = chapter.chapterWordCount;
        chapterList.price = chapter.price;
        chapterList.oid = chapter.oid;
        chapterList.isDownload = chapter.isDownload;
        
        NSString *pid = [SNStoryUtility getPid];
        chapterList.pid = pid;
        chapterList.isfree = chapter.isfree;
        chapterList.hasPaid = chapter.hasPaid;
        chapterList.chapterKey = chapter.chapterKey;
        chapterList.chapterContent = chapter.chapterContent;
        
    }
    
    [[SHCoreDataHelper sharedInstance] saveContext];
}

//更新章节
+(void)updateBookChapterListByBookId:(NSString *)bookId chapterDic:(NSDictionary*)chapterDic
{
    //要更新的章节
    NSArray *chapterArray = [chapterDic objectForKey:@"chapters"];
    //防止有更新的章节，例如章节增加
    NSMutableArray *tempChapterArray = [chapterArray mutableCopy];
    NSUInteger count = chapterArray.count;
    
    for (int i = 0; i < count; i++) {//遍历要更新的章节
        
        id content = [chapterArray objectAtIndex:i];
        
        if ([content isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *contentDic = (NSDictionary*)content;
            NSUInteger tempChapterId = [[contentDic objectForKey:@"chapterId"]integerValue];
            
            //查询要更新的章节
            NSArray *chapters = [[ChapterList fecthBookChapterListByBookId:bookId chapterId:tempChapterId ascending:YES]copy];
            if (chapters && chapters.count > 0) {//存在，删除
                ChapterList *chapter = [chapters firstObject];
                //更新一章删除一章
                [tempChapterArray removeObject:content];
                
                //更新章节
                chapter.bookId = bookId;
                chapter.chapterId = [[contentDic objectForKey:@"chapterId"]integerValue];
                chapter.chapterTitle = [contentDic objectForKey:@"title"];
                chapter.chapterWordCount = [[contentDic objectForKey:@"wordCount"]integerValue];
                chapter.price = [[contentDic objectForKey:@"price"]floatValue];
                chapter.oid = [[contentDic objectForKey:@"oid"]integerValue];
                
                if ([[contentDic objectForKey:@"isfree"]integerValue] == 1) {
                    chapter.isfree = YES;
                } else {
                    chapter.isfree = NO;
                }
                
                if ([[contentDic objectForKey:@"hasPaid"]integerValue] == 1) {
                    chapter.hasPaid = YES;
                } else {
                    chapter.hasPaid = NO;
                }
            }
        }
    }
    
    [[SHCoreDataHelper sharedInstance] saveContext];
    
    if (tempChapterArray.count > 0) {//有新增加的章节，插入
        [ChapterList insertWithChapterArray:tempChapterArray bookId:bookId];
    }
}

//更新购买章节
+(void)updateCartBookChapterListByBookId:(NSString *)bookId cartChapterArray:(NSArray*)cartChapterArray
{
    for (ChapterList *chapter in cartChapterArray) {
        
        NSUInteger tempChapterId = chapter.chapterId;
        //查询要更新的章节
        NSArray *chapters = [ChapterList fecthBookChapterListByBookId:bookId chapterId:tempChapterId ascending:YES];
        
        if (!chapters || chapters.count <= 0) {//第一次pid无数据，同步cid数据，反之，不行
            
            [ChapterList pidBookByCidBookWithBookId:bookId];
            chapters = [ChapterList fecthBookChapterListByBookId:bookId chapterId:tempChapterId ascending:YES];
        }
        
        if (chapters && chapters.count > 0) {//存在，删除
        
            ChapterList *updateChapter = [chapters firstObject];
            updateChapter.hasPaid = YES;
        }
    }
    [[SHCoreDataHelper sharedInstance] saveContext];
}

#pragma mark - 第一次pid无数据，同步cid数据，反之，不行
+(void)pidBookByCidBookWithBookId:(NSString *)bookId
{
    if ([SNStoryUtility isLogin]) {
        NSString *pid = [SNStoryUtility getPid];
        NSString *p1 = [SNStoryUtility getP1];
        
        NSArray *pidArray = [ChapterList fecthAccountBookChapterListByBookId:bookId chapterId:0 accountId:pid ascending:YES];
        NSArray *cidArray = [ChapterList fecthAccountBookChapterListByBookId:bookId chapterId:0 accountId:p1 ascending:YES];
        NSInteger cidArrayCount = cidArray.count;
        NSInteger pidArrayCount = pidArray.count;
        if (pidArray && pidArrayCount > 0) {//pid有数据，同步cid中有，pid中没有的数据
            
            if (pidArrayCount < cidArrayCount) {
                
                NSInteger length = cidArrayCount -pidArrayCount;
                NSInteger location = pidArrayCount;
                [ChapterList insertWithPidChapterByCidChapterWithChapterArray:[cidArray subarrayWithRange:NSMakeRange(location, length)] bookId:bookId];
            }
            
        } else {//pid无数据，同步cid数据
            
            [ChapterList insertWithPidChapterByCidChapterWithChapterArray:cidArray bookId:bookId];
        }
        
    }
}

#pragma mark - 更新章节内容
+(void)updateBookChapterListContentByBookId:(NSString *)bookId chapterDic:(NSDictionary *)chapterDic
{
    //更新书籍用
    NSArray *chapterArray = [chapterDic objectForKey:@"chapters"];
    NSUInteger count = chapterArray.count;
    for (int i = 0; i < count; i++) {//遍历要更新的章节
        
        id content = [chapterArray objectAtIndex:i];
        
        if ([content isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *contentDic = (NSDictionary*)content;
            NSString *contentStr = [contentDic objectForKey:@"content"];
            NSUInteger tempChapterId = [[contentDic objectForKey:@"chapterId"]integerValue];
            
            NSArray *chapters = [[ChapterList fecthBookChapterListByBookId:bookId chapterId:tempChapterId ascending:YES]copy];
            
            if (!chapters || chapters.count <= 0) {//第一次pid无数据，同步cid数据，反之，不行
                
                [ChapterList pidBookByCidBookWithBookId:bookId];
                chapters = [[ChapterList fecthBookChapterListByBookId:bookId chapterId:tempChapterId ascending:YES]copy];
            }
            
            if (chapters && chapters.count > 0) {
                
                ChapterList *chapter = [chapters firstObject];
                NSData *data = [SNStoryAesEncryptDecrypt encryptData:contentStr withKey:[chapterDic objectForKey:@"decryKey"]];
                NSString *dataStr = [data base64Encoding];
                
                chapter.chapterContent = dataStr;
                chapter.chapterKey = [chapterDic objectForKey:@"k"];
                
                if (chapter.isfree) {//免费章节下载，更新下载状态
                    chapter.isDownload = YES;
                } else {//付费章节才会发生购买行为
                    //付费章节购买过，更新付费状态及下载状态 逻辑有坑
                    if ([[contentDic objectForKey:@"hasPaid"]integerValue] == 1) {
                        
                        chapter.hasPaid = YES;
                        chapter.isDownload = YES;
                    } else {
                        chapter.hasPaid = NO;
                        chapter.isDownload = NO;
                    }
                }
                
            }
        }
    }
    
    [[SHCoreDataHelper sharedInstance] saveContext];
}

+ (NSArray *)fecthBookChapterListByBookId:(NSString *)bookId chapterId:(NSUInteger)chapterId ascending:(BOOL)ascending
{
    if (bookId.length <= 0) return nil;

    NSString *pid = [SNStoryUtility getPid];
    if (![SNStoryUtility isLogin]) {
        pid = [SNStoryUtility getP1];
    }

    NSFetchRequest *chapterFetchRequest = [ChapterList fetchRequest];
    if (chapterId > 0) {//查询某一章节
        chapterFetchRequest.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND chapterId = %i AND pid = %@",bookId,chapterId, pid];
    } else {//查询所有章节
        chapterFetchRequest.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND pid = %@",bookId,pid];
    }
    chapterFetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"chapterId" ascending:ascending]];
    // 3. 由上下文查询数据
    NSError *error;
    NSArray *result = [[SHCoreDataHelper sharedInstance].objectContext executeFetchRequest:chapterFetchRequest error:&error];
    return result;
}

#pragma mark 通过账户ID查询章节
+(NSArray *)fecthAccountBookChapterListByBookId:(NSString *)bookId chapterId:(NSUInteger)chapterId accountId:(NSString *)accountId ascending:(BOOL)ascending
{
    if (bookId.length <= 0) {
        return nil;
    }
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    // 1. 实例化查询请求
    NSFetchRequest *request = [ChapterList fetchRequest];
    
    //设置谓词条件
    if (chapterId > 0) {//查询某一章节
        request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND chapterId = %i AND pid = %@",bookId,chapterId, accountId];
    } else {//查询所有章节
        request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND pid = %@",bookId,accountId];
    }
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"chapterId" ascending:ascending];
    [request setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
    
    // 3. 由上下文查询数据
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    return result;
}

+(void)removeBookChapterListByBookId:(NSString *)bookId chapterId:(NSUInteger)chapterId
{
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    //实例化查询请求
    NSFetchRequest *request = [ChapterList fetchRequest];
    
    NSString *pid = [SNStoryUtility getPid];
    if (![SNStoryUtility isLogin]) {
        pid = [SNStoryUtility getP1];
    }
    
    //设置谓词条件
    if (chapterId > 0) {//删除某一章节
        request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND chapterId = %i AND pid = %@",bookId,chapterId,pid];
    } else {//删除所有章节
        request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND pid = %@",bookId,pid];
    }
    
    //由上下文查询数据
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    NSInteger resultCount = result.count;
    //输出结果
    for (int i = 0; i< resultCount; i++) {
        ChapterList *chapterList = result[i];
        // 删除一条记录
        [context deleteObject:chapterList];
    }
    
    //保存数据
    [[SHCoreDataHelper sharedInstance] saveContext];
}

@end
