//
//  StoryBookShelfList.h
//  
//
//  Created by chuanwenwang on 2017/4/19.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface StoryBookShelfList : NSManagedObject

+ (NSFetchRequest<StoryBookShelfList *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *bookId;
@property (nullable, nonatomic, copy) NSString *pid;
@property (nullable, nonatomic, copy) NSString *cid;
@property (nonatomic) int16_t remind;

//插入章节
+(void)insertBookShelfListWithArray:(NSArray*)bookShelfArray;
//查询书架
+(StoryBookShelfList *)fecthBookShelfListByBookId:(NSString *)bookId;
//更新书架
+(void)updateBookShelfListByArray:(NSArray*)bookShelfArray;
//第一次pid无数据，同步cid数据，反之，不行
+(void)pidBookByCidBookWithArray:(NSArray*)bookShelfArray;
//删除书架书籍
+(void)removeBookShelfListByBookId:(NSString*)bookId;

@end

NS_ASSUME_NONNULL_END

