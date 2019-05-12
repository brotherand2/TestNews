//
//  SNDBMigrationManager_313.m
//  sohunews
//
//  Created by handy wang on 8/31/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDBMigrationManager_313.h"
#import "CacheDefines.h"

@implementation FmdbMigration(v313)

- (void)migrateUpTo3_1_3_1 {
    
    SNDebugLog(@"INFO: %@--%@, Excuting migration selector [%@] ......", NSStringFromClass(self.class), NSStringFromSelector(_cmd), NSStringFromSelector(_cmd));
    
    //修改tbCategory表，加了三个字段；
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_POSITION columnType:@"TEXT"] forTableName:TB_CATEGORY];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_TOP columnType:@"TEXT"] forTableName:TB_CATEGORY];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_TOPTIME columnType:@"TEXT"] forTableName:TB_CATEGORY];
    
    
    //修改tbNewsChannel表，加了三个字段；
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNELPOSITION columnType:@"TEXT"] forTableName:TB_NEWSCHANNEL];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNELTOP columnType:@"TEXT"] forTableName:TB_NEWSCHANNEL];
    
    [self addColumn:[FmdbMigrationColumn columnWithColumnName:TB_NEWSCHANNEL_CHANNELTOPTIME columnType:@"TEXT"] forTableName:TB_NEWSCHANNEL];
    
}

- (void)migrateUpTo3_1_3_2 {
    
    SNDebugLog(@"INFO: %@--%@, Excuting migration selector [%@] ......", NSStringFromClass(self.class), NSStringFromSelector(_cmd), NSStringFromSelector(_cmd));
    

    //给表tbNewsArticle、tbNewsImage、tbGallery、tbRecommendGallery、tbPhoto、tbRollingNewsList、tbGroupPhoto、tbGroupPhotoUrl分别加一个creatAt字段
    
    //tbNewsArticle
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_NEWSARTICLE, TB_CREATEAT_COLUMN]];
    
    //tbNewsImage
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_NEWSIMAGE, TB_CREATEAT_COLUMN]];

    //tbGallery
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_GALLERY, TB_CREATEAT_COLUMN]];
    
    //tbRecommendGallery
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_RECOMMENDGALLERY, TB_CREATEAT_COLUMN]];
    
    //tbPhoto
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_PHOTO, TB_CREATEAT_COLUMN]];
    
    //tbRollingNewsList
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_ROLLINGNEWSLIST, TB_CREATEAT_COLUMN]];
    
    //tbGroupPhoto
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_GROUPPHOTO, TB_CREATEAT_COLUMN]];
    
    //tbGroupPhotoUrl
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_GROUPPHOTOURL, TB_CREATEAT_COLUMN]];

}

- (void)migrateUpTo3_1_3_3 {
    
    //tbNewsComment  添加digNum字段
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_NEWSCOMMENT, TB_NEWSCOMMENT_DIGNUM]];
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_NEWSCOMMENT, TB_NEWSCOMMENT_HADDING]];
    
    [self executeSQL:[NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ INTEGER", TB_COMMENTJSON, TB_COMMENTJSON_HADDING]];
    
}


@end
