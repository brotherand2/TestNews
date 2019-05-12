//
//  SNCloudSaveService.h
//  sohunews
//
//  Created by weibin cheng on 14-3-3.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNCloudGetRequest.h"

@class SNUserinfoEx;
@class SNMyFavourite;
@class SNCloudSave;

@protocol SNCloudSaveDelegate <NSObject>
@optional
//Save user info
-(void)notifyCloudSaveSuccess:(SNBaseRequest*)request responseObject:(id)responseObject userInfo:(id)userInfo;
-(void)notifyCloudSaveFailure:(SNBaseRequest*)request userInfo:(id)userInfo stutas:(NSInteger)aStatus msg:(NSString*)aMsg;
-(void)notifyCloudSaveFailure:(SNBaseRequest*)request userInfo:(id)userInfo didFailLoadWithError:(NSError*)error;

//Get user info
-(void)notifyCloudGetSuccess;
-(void)notifyCloudGetFailure:(NSInteger)aStatus msg:(NSString*)aMsg;
-(void)notifyCloudGetFailure:(SNBaseRequest*)request didFailLoadWithError:(NSError*)error;
@end

@interface SNCloudSaveService : NSObject

@property(nonatomic,weak)id<SNCloudSaveDelegate> cloudSaveDelegate;
@property (nonatomic, assign) BOOL isGetFavouriteList;

//Cloud save favoutite
-(BOOL)cloudGetRequest:(SNCloudGetType)cloudGetType;
-(NSString*)contentFromFav:(SNMyFavourite*)aFav;
-(NSString*)contentFromCloudSave:(SNCloudSave*)aCloudSave;
-(BOOL)cloudDelFavouriteArray:(NSArray*)aFavArray;
-(BOOL)cloudSaveFavouriteArray:(NSArray*)aFavArray;
-(BOOL)cloudSaveFavouriteArray:(NSArray*)aFavArray corpusDict:(NSDictionary *)corpusDict;

+ (void)corpusDataCloudSync:(void(^)())completion; // 收藏数据同步
+ (BOOL)checkServerSynced; // 检查是否触发了服务端同步
+ (void)deleteAllLocalCorpusData;// 删除所有本地收藏数据
+ (void)triggerCorpusSynCompletion:(void(^)(BOOL success))completion; // 触发服务端同步
+ (void)synCloudFavoriteData; // 获取最新收藏数据
//Cloud save channel
//-(BOOL)cloudSaveChannelArray:(NSInteger)aType array:(NSArray*)aChannelArray;

//Parser Cloud Get
-(void)handleFavouriteItems:(NSArray*)cloudFav;
-(void)handleChannelItems:(id)aRootData;
-(void)handleCategoryItems:(id)aRootData;
@end
