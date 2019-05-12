//
//  SNDatabase_WeiboHotItem.h
//  sohunews
//
//  Created by wang yanchen on 12-12-24.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase(WeiboHotItem)

// add
- (BOOL)addAWeiboHotItem:(WeiboHotItem *)weiboItem updateIfExist:(BOOL)bUpdateIfExist;
- (BOOL)setWeiboHotItems:(NSArray *)weiboItems;
- (BOOL)setWeiboHotItems:(NSArray *)weiboItems withPageNo:(int)pageNo;

// delete
- (BOOL)clearAllWeiboHotItems;

// update   和- (BOOL)addAWeiboHotItem:(WeiboHotItem *)weiboItem updateIfExist:(BOOL)bUpdateIfExist; 功能一致
- (BOOL)updateAWeiboHotItem:(WeiboHotItem *)weiboItem addIfNotExist:(BOOL)bAddIfNotExist;

// query
- (WeiboHotItem *)getAWeiboHotItemByWeiboId:(NSString *)weiboId;
- (NSArray *)getAllWeiboHotItem;
- (NSArray *)getWeiboHotItemsByPageNo:(int)pageNo;


@end
