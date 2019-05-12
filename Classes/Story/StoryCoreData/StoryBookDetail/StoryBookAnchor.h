//
//  StoryBookAnchor.h
//  
//
//  Created by wangchuanwen on 2017/6/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface StoryBookAnchor : NSManagedObject

+ (NSFetchRequest<StoryBookAnchor *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *bookId;
@property (nonatomic) int32_t chapter;
@property (nonatomic) int32_t pageNO;
@property (nullable, nonatomic, copy) NSString *externStr;
@property (nullable, nonatomic, copy) NSString *cid;            //设备id
@property (nullable, nonatomic, copy) NSString *pid;            //账户id

//插入书籍锚点
+(void)insertBookAnchorWithBookAnchorArry:(NSArray *)bookAnchorArry;
//更新书籍锚点
+(void)updateBookAnchorWithBookAnchorArry:(NSArray *)bookAnchorArry;
//+(void)updateBookAnchorWithBookAnchorArry:(NSArray *)bookAnchorArry oldBookAnchorArry:(NSArray *)oldBookAnchorArry;
//查询某本书籍锚点
+(StoryBookAnchor *)fetchBookAnchorWithBookId:(NSString *)bookId;
//查询所有书籍锚点
+(NSArray*)fetchAllBookAnchor;
@end

NS_ASSUME_NONNULL_END

