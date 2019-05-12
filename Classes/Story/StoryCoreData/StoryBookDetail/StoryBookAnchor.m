//
//  StoryBookAnchor.m
//  
//
//  Created by wangchuanwen on 2017/6/15.
//
//

#import "StoryBookAnchor.h"
#import "SHCoreDataHelper.h"
#import "SNStoryUtility.h"

@implementation StoryBookAnchor

+ (NSFetchRequest<StoryBookAnchor *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"StoryBookAnchor"];
}

@dynamic bookId;
@dynamic chapter;
@dynamic pageNO;
@dynamic externStr;
@dynamic cid;
@dynamic pid;

+(void)insertBookAnchorWithBookAnchorArry:(NSArray *)bookAnchorArry
{
    NSArray *anchorArry = [StoryBookAnchor fetchAllBookAnchor];
    if (anchorArry && anchorArry.count > 0) {
        [StoryBookAnchor updateBookAnchorWithBookAnchorArry:bookAnchorArry];
    } else {
        [StoryBookAnchor insertBookAnchorWithAnchorArry:bookAnchorArry];
    }
}

+(void)insertBookAnchorWithAnchorArry:(NSArray *)anchorArry
{
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    for (NSDictionary *dic in anchorArry) {
        StoryBookAnchor *anchor = [NSEntityDescription insertNewObjectForEntityForName:@"StoryBookAnchor" inManagedObjectContext:context];
        anchor.bookId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"bookId"]];
        anchor.pageNO = [[dic objectForKey:@"pageNO"]integerValue];
        anchor.chapter = [[dic objectForKey:@"chapter"]integerValue];
        NSString *pid = [SNStoryUtility getPid];
        
        if (![SNStoryUtility isLogin]) {
            anchor.cid = [SNStoryUtility getP1];
        }
        else
        {
            anchor.pid = pid;
        }
    }
    
    [[SHCoreDataHelper sharedInstance] saveContext];
}

+(void)updateBookAnchorWithBookAnchorArry:(NSArray *)bookAnchorArry
{
    //获取上下文
    NSMutableArray *anchorArry = [bookAnchorArry mutableCopy];
    
    for (NSDictionary *dic in bookAnchorArry) {
        
        StoryBookAnchor *anchor = [StoryBookAnchor fetchBookAnchorWithBookId:[dic objectForKey:@"bookId"]];
        if (anchor) {
            
            anchor.pageNO = [[dic objectForKey:@"pageNO"]integerValue];
            [anchorArry removeObject:dic];
        }
    }
    [[SHCoreDataHelper sharedInstance]saveContext];
    
    if (anchorArry. count > 0) {
        [StoryBookAnchor insertBookAnchorWithAnchorArry:anchorArry];
    }
    
}

+(StoryBookAnchor *)fetchBookAnchorWithBookId:(NSString *)bookId
{
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    NSFetchRequest *request = [StoryBookAnchor fetchRequest];
    
    //设置谓词条件
    NSString *pid = [SNStoryUtility getPid];
    if (![SNStoryUtility isLogin]) {
        request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND cid = %@",bookId,[SNStoryUtility getP1]];
    }
    else
    {
        request.predicate = [NSPredicate predicateWithFormat:@"bookId = %@ AND pid = %@",bookId,pid];
    }
    
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    if (result && result.count > 0) {
        StoryBookAnchor *anchor = [result firstObject];
        return anchor;
    } else {
        return nil;
    }
}

+(NSArray *)fetchAllBookAnchor
{
    //获取上下文
    NSManagedObjectContext *context = [SHCoreDataHelper sharedInstance].objectContext;
    NSFetchRequest *request = [StoryBookAnchor fetchRequest];
    
    //设置谓词条件
    NSString *pid = [SNStoryUtility getPid];
    if (![SNStoryUtility isLogin]) {
        request.predicate = [NSPredicate predicateWithFormat:@"cid = %@",[SNStoryUtility getP1]];
    }
    else
    {
        request.predicate = [NSPredicate predicateWithFormat:@"pid = %@",pid];
    }
    
    NSArray *result = [context executeFetchRequest:request error:nil];
    
    if (result && result.count > 0) {
        return result;
    } else {
        return nil;
    }
}
@end
