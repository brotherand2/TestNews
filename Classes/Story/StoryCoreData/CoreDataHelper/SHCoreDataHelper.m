//
//  SHCoreDataHelper.m
//  CoreDataTest
//
//  Created by lijian on 16/9/22.
//  Copyright © 2016年 lijian. All rights reserved.
//
#define APP_PATH_DIRECTORY              (@"SohuStory")
#define APP_PATH_DOCUMENT               (NSString *)([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject])

#define APP_SHPATH_DOCUMENT             ([APP_PATH_DOCUMENT stringByAppendingPathComponent:APP_PATH_DIRECTORY])

#import "SHCoreDataHelper.h"

@interface SHCoreDataHelper() {
#ifdef SHCoreDataHelper_DebugTest
    NSTimeInterval _time1970;
#endif
}
@end

@implementation SHCoreDataHelper
+ (SHCoreDataHelper *)sharedInstance {
    static SHCoreDataHelper *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SHCoreDataHelper alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // Register context with the notification center
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(mergeChanges:)
                   name:NSManagedObjectContextDidSaveNotification
                 object:self.objectContext];
    }
    return self;
}

#pragma mark - Core Data stack
@synthesize objectContext = _objectContext;
@synthesize coordinator = _coordinator;

- (NSPersistentStoreCoordinator *)coordinator {
    @synchronized (self) {
        if (_coordinator != nil) {
            return _coordinator;
        }
        
        _coordinator = [SHCoreDataHelper coordinator];
        return _coordinator;
    }
}

+(NSPersistentStoreCoordinator *)coordinator
{
    //设置数据存储的名字，位置，存储方式和存储时机
    NSString *coreDataPath = [[NSBundle mainBundle] pathForResource:SHCoreData_MOMD_NAME ofType:@"momd"];
    NSManagedObjectModel *objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:coreDataPath]];
    if (nil == objectModel) {
        return nil;
    }
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:objectModel];
    
    //创建存储目录
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (NO == [fm fileExistsAtPath:APP_SHPATH_DOCUMENT
                       isDirectory:&isDirectory]) {
        //创建数据库存放目录
        [fm createDirectoryAtPath:APP_SHPATH_DOCUMENT withIntermediateDirectories:YES attributes:nil error:nil];
        //创建迁移目录
        [fm createDirectoryAtPath:[APP_SHPATH_DOCUMENT stringByAppendingPathComponent:SHCoreData_MigrationDir] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //关联数据库,创建数据库
    NSString *dbPath = [APP_SHPATH_DOCUMENT stringByAppendingPathComponent:SHCoreData_DBFileName];
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@(YES),
                              NSInferMappingModelAutomaticallyOption:@(YES)};
    NSError *error = nil;
    NSPersistentStore *store = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dbPath] options:options error:&error];
    
    //判断持久化存储对象是否为空，如果为空说明数据库创建失败
    if (nil == store) {
        SNDebugLog(@"错误信息：%@",error.localizedDescription); //打印报错信息
        return nil;
    }
    
    return coordinator;
}

+(NSManagedObjectContext *)objectContext
{
    //将上下文的持久化协调器指定到创建的属性中 （设置上下文对象的协调器）
    NSManagedObjectContext * objectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    if ([objectContext respondsToSelector:@selector(setPersistentStoreCoordinator:)]) {
        objectContext.persistentStoreCoordinator = [SHCoreDataHelper coordinator];
    }
    
    return objectContext;
}

- (NSManagedObjectContext *)objectContext {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_objectContext == nil) {
#ifdef SHCoreDataHelper_DebugTest
            _time1970 = [[NSDate date] timeIntervalSince1970];
#endif
            //将上下文的持久化协调器指定到创建的属性中 （设置上下文对象的协调器）
            _objectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            if ([_objectContext respondsToSelector:@selector(setPersistentStoreCoordinator:)]) {
                _objectContext.persistentStoreCoordinator = self.coordinator;
            }
        }
    }
    
    return _objectContext;
}

#pragma mark - Core Data Saving support
- (void)mergeChanges:(NSNotification *)notification {
    
}

- (void)saveContext {
    //在哪个线程创建, 在哪个线程使用
    NSManagedObjectContext *context = self.objectContext;
    
    [context performBlockAndWait:^{
        NSError *error = nil;
        if ([context hasChanges] && ![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            SNDebugLog(@"Unresolved error %@, %@", error, error.userInfo);
#if DEBUG
            abort();
#endif
        }
    }];
}

#pragma mark - 
- (NSManagedObject *)addEntityName:(NSString *)entityName
                initAttributeBlock:(initAttributeBlock)initAttributeBlock {
    if (nil == entityName) {
        return nil;
    }
    
    NSEntityDescription *description = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.objectContext];
    NSManagedObject *obj = [[NSClassFromString(entityName) alloc] initWithEntity:description insertIntoManagedObjectContext:self.objectContext];
    if (nil != obj) {
        initAttributeBlock(obj);
    }
    
    return obj;
}

- (void)deleteObject:(NSManagedObject *)object {
    [self.objectContext deleteObject:object];
}

- (NSArray *)executeFetchEntityName:(NSString *)entityName
                         sortArrays:(NSArray *)sortArrays {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    request.sortDescriptors = sortArrays;
    return [self.objectContext executeFetchRequest:request error:nil];
}

@end
