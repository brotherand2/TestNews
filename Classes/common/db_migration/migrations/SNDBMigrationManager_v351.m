//
//  SNDBMigrationManager_v351.m
//  sohunews
//
//  Created by jojo on 13-8-1.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNDBMigrationManager_v351.h"

@implementation FmdbMigration(v351)

- (void)migrateUpTo3_5_1_0 {
    // 订阅中心 增加needLogin列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_NEED_LOGIN columnType:@"Varchar"] forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
}

- (void)migrateUpTo3_5_1_1 {
    // 订阅中心 增加 canOffline列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_CAN_OFFLINE columnType:@"Varchar"] forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
}

- (void)migrateUpTo3_5_1_2 {
    //新闻列表  增加 icontypeday、icontypenight、recomiconday、recomiconnight列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ICONTYPEDAY columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_ICONTYPENIGHT columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_RECOMICONDAY columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_ROLLINGNEWSLIST_RECOMICONNIGHT columnType:@"Varchar"] forTableName:TB_ROLLINGNEWSLIST];
}

- (void)migrateUpTo3_5_1_3 {
    //尾热议评论增加评论界面
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_WEIBOHOT_Comment_GENDER columnType:@"integer"] forTableName:TB_WEIBOHOT_Comment];
}

- (void)migrateUpTo3_5_1_4 {
    // 订阅中心 增加userInfo列
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_SUB_CENTER_ALL_SUB_USERINFO columnType:@"Varchar"] forTableName:TB_SUB_CENTER_ALL_SUBSCRIBE];
}

- (void)migrateUpTo3_5_1_5 {
    // 正文 组图新闻 增加column updateTime
        FmdbMigrationColumn *clm = [FmdbMigrationColumn columnWithColumnName:@"updateTime" columnType:@"Varchar"];
        [self addColumn:clm forTableName:TB_NEWSARTICLE];
        [self addColumn:clm forTableName:TB_GALLERY];
}

@end
