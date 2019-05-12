//
//  SNDatabase_CloudSave.h
//  sohunews
//
//  Created by Diaochunmeng on 12-12-28.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"
#import "SNMyFavourite.h"

@interface SNDatabase(CloudSave)

-(NSArray*)getMyCloudSaves;
-(SNCloudSave*)getMyCloudSave:(MYFAVOURITE_REFER)myFavouriteRefer contentLeveloneID:(NSString*)contentLeveloneID contentLeveltwoID:(NSString*)contentLeveltwoID;

-(BOOL)deleteMyCloudSaves;
-(BOOL)deleteMyCloudSave:(SNCloudSave*)myFavourite;

-(BOOL)saveMyCloudSave:(SNCloudSave*)myCloudSave;
-(BOOL)saveMyCloudSaveWithMyFav:(SNMyFavourite*)myFavourite;
@end