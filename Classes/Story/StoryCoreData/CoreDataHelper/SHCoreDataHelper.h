//
//  SHCoreDataHelper.h
//  CoreDataTest
//
//  Created by lijian on 16/9/22.
//  Copyright © 2016年 lijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define SHCoreDataHelper_DebugTest

#define SHCoreData_MigrationDir         (@"MigrationTemp")
#define SHCoreData_DBFileName           (@"SohuStory.sqlite")
#define SHCoreData_MOMD_NAME            (@"SohuStory")

typedef void(^initAttributeBlock)(NSManagedObject *obj);

@interface SHCoreDataHelper : NSObject
@property (readonly, strong) NSManagedObjectContext *objectContext;
@property (readonly, strong) NSPersistentStoreCoordinator *coordinator;

+ (SHCoreDataHelper *)sharedInstance;

+ (NSPersistentStoreCoordinator *)coordinator;
+ (NSManagedObjectContext *)objectContext;
//存
- (void)saveContext;

//增
- (NSManagedObject *)addEntityName:(NSString *)entityName initAttributeBlock:(initAttributeBlock)initAttributeBlock;

//删
- (void)deleteObject:(NSManagedObject *)object;

//改,这个没有给出方法，查询出的内容只要内容修改，调用saveContext即为“改”，内存是共享的

//查
- (NSArray *)executeFetchEntityName:(NSString *)entityName sortArrays:(NSArray *)sortArrays;
@end
