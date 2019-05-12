//
//  SNDatabase_MyFavourite.h
//  sohunews
//
//  Created by handy wang on 8/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"
#import "SNMyFavourite.h"

//3.3.1引入新的字段userid
//平时的收藏都是没有这个字段的，表示这些收藏还在本地，处于没有人认领的状态，第一个登录的账号将拥有这些收藏；
//而一旦这个字段里有内容，则表示这个收藏是这个用户准备删除的！

@interface SNDatabase(MyFavourite)

- (BOOL)saveMyFavourite:(SNMyFavourite *)myFavourite;

- (BOOL)deleteMyFavourite:(SNMyFavourite *)myFavourite;
- (BOOL)deleteMyFavouriteEx:(SNCloudSave *)myCloudSave;

- (BOOL)deleteMyFavourites:(NSArray *)myFavourites;

- (NSArray *)getMyFavourites;
- (NSArray *)getToDeleteFav:(NSString*)aUserid;

- (SNMyFavourite *)getMyFavourite:(MYFAVOURITE_REFER)myFavouriteRefer 
                contentLeveloneID:(NSString *)contentLeveloneID contentLeveltwoID:(NSString *)contentLeveltwoID;
- (BOOL)updateMyFavourite:(NSInteger)ID hasRead:(BOOL)isRead;

-(BOOL)deleteMyFavouriteAll;

@end