//
//  SNBaseFavouriteObject.h
//  sohunews
//
//  Created by Gao Yongyue on 13-12-6.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNNewsContentFavourite.h"
#import "SNNewspaperFavourite.h"
#import "SNWeiboHotFavourite.h"
#import "SNGroupPicturesFavourite.h"
#import "SNGroupPicturesContentFavourite.h"
#import "SNVideoFavourite.h"
#import "SNMyFavourite.h"
#import "SNVideoMediaFavourite.h"


//为我的收藏页面使用，其他收藏地方不需要使用
@protocol SNMyFavouriteManagerDelegate <NSObject>

/*
 以下是删除收藏
 */
//以下两个是回调，是否真正成功
- (void)didDeleteFromMyFavouriteSuccessfully:(NSArray *)favourites;
- (void)didDeleteFromMyFavouriteFail;
//这个是删除的网络请求是否发出去了
- (void)sendDeleteFavouritesRequest:(BOOL)success;
//这个是同步本地数据和页面数据一致
- (void)syncMyFavourites:(NSArray *)favourites;

/*
 以下是从服务器获取云收藏数据
 */
- (void)fetchCloudFavouritesSuccessfully;
- (void)fetchCloudFavouritesFailed;
- (void)addToMyFavourite:(BOOL)success;
@end

@interface SNMyFavouriteManager : NSObject

//为我的收藏页面使用其它页面，严禁使用
@property (nonatomic, weak) id<SNMyFavouriteManagerDelegate> delegate;
@property (nonatomic, assign) BOOL isFromArticle;
@property (nonatomic, assign) BOOL isHandleFavorite; // 记录是否正在执行收藏或取消收藏
//返回单例
+ (instancetype)shareInstance;

- (BOOL)checkIfInMyFavouriteList:(SNBaseFavouriteObject *)baseFavourite;
- (void)addToMyFavouriteList:(SNBaseFavouriteObject *)baseFavourite;
- (void)deleteFromMyFavouriteList:(SNBaseFavouriteObject *)baseFavourite;
//删除多个,这个array里面的类型是myfavourite和cloudsave
- (void)deleteMultipleFromMyFavouriteList:(NSArray *)favourites;
- (void)addOrDeleteFavourite:(SNBaseFavouriteObject *)baseFavourite;
- (void)addOrDeleteFavourite:(SNBaseFavouriteObject *)baseFavourite corpusDict:(NSDictionary *)corpusDict;
- (void)addOrDeleteFavouriteFromSHH5Web:(SNBaseFavouriteObject *)baseFavourite corpusDict:(NSDictionary *)corpusDict;
//- (void)fetchMyFavouriteList;

@end

