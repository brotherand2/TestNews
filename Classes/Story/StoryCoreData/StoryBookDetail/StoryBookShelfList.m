//
//  StoryBookShelfList.m
//  
//
//  Created by chuanwenwang on 2017/4/19.
//
//

#import "StoryBookShelfList.h"
#import "SHCoreDataHelper.h"
#import "SNStoryUtility.h"

@implementation StoryBookShelfList

+ (NSFetchRequest<StoryBookShelfList *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"StoryBookShelfList"];
}

@dynamic bookId;
@dynamic pid;
@dynamic cid;
@dynamic remind;

+(void)insertBookShelfListWithArray:(NSArray *)bookShelfArray
{
    if (!bookShelfArray || bookShelfArray.count <= 0) {
        
        return;
    }
    else{
        
        NSArray *array = [StoryBookShelfList fecthBooks];
        
        if (!array || array.count <= 0) {//插入
            
            [StoryBookShelfList insertWithBookShelfArray:bookShelfArray];
        } else {//更新(作者更新了几个章节，如何处理，后期优化)
            
            //删除书架书籍，并插入新数据
            //[StoryBookShelfList updateBookShelfListByArray:bookShelfArray];
            if (bookShelfArray.count < 2) {
                NSDictionary *dic = [bookShelfArray firstObject];
                [StoryBookShelfList removeBookShelfListByBookId:[dic stringValueForKey:@"bookId" defaultValue:@""]];
            } else {
                [StoryBookShelfList removeBooks];
            }
            [StoryBookShelfList insertWithBookShelfArray:bookShelfArray];
        }
    }
}

+(void)insertWithBookShelfArray:(NSArray*)bookShelfArray
{
    NSInteger count = bookShelfArray.count;
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    for (int i = 0; i < count; i++) {
        
        NSDictionary *bookDic = bookShelfArray[i];
        StoryBookShelfList *bookList = [NSEntityDescription insertNewObjectForEntityForName:@"StoryBookShelfList" inManagedObjectContext:context];
        bookList.bookId = [bookDic stringValueForKey:@"bookId" defaultValue:@""];
        bookList.remind = [bookDic intValueForKey:@"remind" defaultValue:0];
        NSString *pid = [SNStoryUtility getPid];
        
        if (![SNStoryUtility isLogin]) {
            bookList.cid = [SNStoryUtility getP1];
        }
        else
        {
            bookList.pid = pid;
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
        StoryBookShelfList *chapterList = [NSEntityDescription insertNewObjectForEntityForName:@"StoryBookShelfList" inManagedObjectContext:context];
        
        chapterList.bookId = bookId;
        
    }
    
    [[SHCoreDataHelper sharedInstance] saveContext];
}

#pragma mark - 第一次pid无数据，同步cid数据，反之，不行
+(void)pidBookByCidBookWithBookId:(NSString *)bookId
{
}

+(StoryBookShelfList *)fecthBookShelfListByBookId:(NSString *)bookId
{
    if (bookId.length <= 0) {
        return nil;
    }
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    // 1. 实例化查询请求
    NSFetchRequest *request = [StoryBookShelfList fetchRequest];
    
    //设置谓词条件
    NSString *pid = [SNStoryUtility getPid];
    if (![SNStoryUtility isLogin]) {
        request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND cid = %@",bookId,[SNStoryUtility getP1]];
    }
    else
    {
        request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND pid = %@",bookId,pid];
    }
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"bookId" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
    
    // 3. 由上下文查询数据
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    if (result.count > 0) {
        StoryBookShelfList *bookSelf = [result firstObject];
        return bookSelf;
    }
    return nil;
}

+(NSArray *)fecthBooks
{
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    // 1. 实例化查询请求
    NSFetchRequest *request = [StoryBookShelfList fetchRequest];
    
    //设置谓词条件
    NSString *pid = [SNStoryUtility getPid];
    if (![SNStoryUtility isLogin]) {
        request.predicate = [NSPredicate predicateWithFormat:@"cid = %@",[SNStoryUtility getP1]];
    }
    else
    {
        request.predicate = [NSPredicate predicateWithFormat:@"pid = %@",pid];
    }
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]initWithKey:@"bookId" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sort, nil]];
    
    // 3. 由上下文查询数据
    NSError *error;
    NSArray *result = [context executeFetchRequest:request error:&error];
    return result;
}

+(void)removeBookShelfListByBookId:(NSString *)bookId
{
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    //实例化查询请求
    NSFetchRequest *request = [StoryBookShelfList fetchRequest];
    
    //设置谓词条件
    NSString *pid = [SNStoryUtility getPid];
    if (![SNStoryUtility isLogin]) {
        request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND cid = %@",bookId,[SNStoryUtility getP1]];
    }
    else
    {
        request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND pid = %@",bookId,pid];
    }
    
    //由上下文查询数据
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    NSInteger resultCount = result.count;
    //输出结果
    for (int i = 0; i< resultCount; i++) {
        StoryBookShelfList *bookShelf = result[i];
        // 删除一条记录
        [context deleteObject:bookShelf];
    }
    
    //保存数据
    [[SHCoreDataHelper sharedInstance] saveContext];
}

+(void)removeBooks
{
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    
    //实例化查询请求
    NSFetchRequest *request = [StoryBookShelfList fetchRequest];
    
    //设置谓词条件
    NSString *pid = [SNStoryUtility getPid];
    if (![SNStoryUtility isLogin]) {
        request.predicate = [NSPredicate predicateWithFormat:@"cid = %@",[SNStoryUtility getP1]];
    }
    else
    {
        request.predicate = [NSPredicate predicateWithFormat:@"pid = %@",pid];
    }
    
    //由上下文查询数据
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    NSInteger resultCount = result.count;
    //输出结果
    for (int i = 0; i< resultCount; i++) {
        StoryBookShelfList *bookShelf = result[i];
        // 删除一条记录
        [context deleteObject:bookShelf];
    }
    
    //保存数据
    [[SHCoreDataHelper sharedInstance] saveContext];
}
@end
