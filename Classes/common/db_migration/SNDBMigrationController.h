//
//  SNDBMigrationController.h
//  sohunews
//
//  Created by handy wang on 8/29/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//
/**
 使用数据库迁移框架时要遵循以下原则：
 
 1）从此以后对于数据库的变更都不要修改数据库文件
 目前在bundle里面有两个数据库文件：一个是原来的数据文件Sohunews.sqlite；为了防止某些同学还是会情不自知禁的修改这个文件我另外放了另一个数据库文件SohuNews_dont_touch_me_3.1.2.sqlite；
 即以后数据迁移是不依赖Sohunews.sqlite，而是依赖SohuNews_dont_touch_me_3.1.2.sqlite，SohuNews_dont_touch_me_3.1.2.sqlite就是一个3.1.2以后程序的原始库，SohuNews_dont_touch_me_3.1.2.sqlite这个文件是决对不能改的（dont_touch_me）；
 
 
 2）如果要改数据库结构，怎么做？
 
 2.1）在XCode的项目目录结构中找到db_migration下的SNDBMigrationManager以及migrations组下的SNDBMigrationManager_313
 
 2.2）每要对数据库做一次更改，就直接在SNDBMigrationManager的_versions数组里加一个版本号
 如原来是：
 _versions = [[NSArray alloc] initWithObjects: kMinSqliteVersionOfSupportingDBMigration,//for app version 3.1.2 @"3_1_3_1",//for app version 3.1.3 nil];
 加一个新版本号后是：
 _versions = [[NSArray alloc] initWithObjects: kMinSqliteVersionOfSupportingDBMigration,//for app version 3.1.2 @"3_1_3_1",@"3_1_3_2",//for
 app version 3.1.3 nil];
 新加的版本号决对不能以“.”分隔，看2.3）就知道为什么了。
 
 2.3）在SNDBMigrationManager_313这个Category里加一个方法以及其实现，命名规则是：前缀“migrateUpTo”，紧接后面的就是2.2）步骤里加的版本号，所以应该在SNDBMigrationManager_313.h和SNDBMigrationManager_313.m文件里加一个方法，名字叫 “- (void)migrateUpTo3_1_3_2”
 
 2.4）在(void)migrateUpTo3_1_3_2方法实现里面，就可以进行要做的数据库变更，可以是数据库结构的，也可以是数据的：增表、删表、加字段、删字段、改字段、重命名表，数据的增删改查；因为这里对数据库的修改采用了FMDB Migration Manager这个框架，所以大家必须采用这个框来进行操作，可以参考SNOCUnitTests分组下的db_migration分组下的SNDBMigrationManager_migrationtest.m文件，这里面的测试用例包含所有的数据库结构操作；另外，我还扩展了一个"- (BOOL)extuteSQL:(NSString *)sql"方法，这样方便会SQL语法的同学来更改数据库，只需要migrateUpTo3_1_3_2方法里面[self extuteSQL:@"……."];(慎用)就可以调用了。
 
 2.5）大家已经注意到SNDBMigrationManager_313文件是一个Category，从名字可以看出这个文件包含了3.1.3这个程序大版本所有的数据库小版本变更，所以只是为了让代码做的事更明确，也是一个建议；这个类的命名没有规则；所以建议大家，3.1.3程序的数据库变更代码写到SNDBMigrationManager_313里，以后其它程序版本的数据库变更代码写到其它Category文件里，只要方法的命名规则以及在_versions数组中添加版本号规则遵守好就行；
 综上，变更数据库时，你只需要关心：_versions数组和Catergory文件对应该新版本号方法的实现就行；
 
 3）3.1.3版本引入了OCUnit，所以在以后的开发中有需要写单元测试的同学可以在SNOCUnitTest分组下写自己的单元测试用例；目前，db_migration分组里是和数据库迁移相关的；
 运行单元测试时，需要把target换到SNOCUnitTests再cmd+U执行代码；
 
 如有问题再直接问我。
 */

#import <Foundation/Foundation.h>
#import "SNDBMigrationManager.h"

@interface SNDBMigrationController : NSObject<SNDBMigrationManagerDelegate,SNActionSheetDelegate> {

    int retryCountWhenMigrateFail;

}

+ (SNDBMigrationController *)sharedInstance;

- (void)migrate;

@end