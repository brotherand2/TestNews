//
//  SNSubscribeCenterService.h
//  sohunews
//
//  Created by wang yanchen on 12-11-20.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "SNSubscribeCenterDefines.h"
#import "SNSubscribeCenterCallbackDataSet.h"
#import "SNSubscribeCenterOperation.h"
#import "SNDatabase_SubscribeCenter.h"

/* SNSubscribeCenterService 单实例
 *
 * 在请求某项业务之前，添加一个观察者（不添加不会回调），在业务成功回调之后，无论成功与否，如果不需要继续发送该项业务的请求，要立刻移除观察者；
 * 比较保险的办法，在发起某项业务请求之前添加观察者，在回调之后里面移除；在下次发起业务的时候继续添加观察者和移除观察者，如此反复；
 * 或者，统一在viewWillAppear类似的地方添加观察者，在viewWillDisappear类似的地方移除观察者；
 * 
 */

@class SCSubscribeObject;
@class SCSubscribeAdObject;

@interface SNSubscribeCenterService : NSObject<TTURLRequestDelegate>

// ** 一些只读的属性 **
// 更多订阅 更新的数目
@property(weak, nonatomic, readonly) NSString *allSubNewCount;

#pragma mark -----------------我的订阅 my subscribe---------------------------------------------------

// 我的订阅
// 从本地数据库加载我的订阅 直接返回结果
- (NSArray *)loadMySubFromLocalDB;

// 4.3 获取本地数据库中 用户排序过的订阅内容 不包含摇一摇
- (NSArray *)loadSortedMySubFromLocalDB;

// v5.3.2获取本地数据库推荐订阅
- (NSArray *)loadRecomSubFromLocalDB;

// 从服务器获取我的订阅 通过delegate回调  告诉delegate数据状态
//- (SNSubscribeCenterOperation *)loadMySubFromServer;
- (void)loadMySubFromServer;
- (void)loadMySubFromServerWithPage:(NSInteger)page;

//从服务器获取推荐订阅
//- (SNSubscribeCenterOperation *)loadMoreRecomSubFromServerWithPageNo:(NSInteger)pageNo;
- (void)loadMoreRecomSubFromServerWithPageNo:(NSInteger)pageNo;

- (void)unreadClearSubId:(NSString *)subId;

// 4.3 同步用户订阅顺序
- (SNSubscribeCenterOperation *)synchronizeMySubOrderToServer:(NSArray *)mySubs; // mySubs -- array of SCSubscribeObject

#pragma mark -----------------刊物分类列表 type list---------------------------------------------------

// 刊物分类列表
// 从本地加载刊物分类列表
- (NSArray *)loadSubTypesFromLocalDB;

// 从服务器获取最新的刊物分类列表
- (SNSubscribeCenterOperation *)loadSubTypesFromServer;

#pragma mark -----------------分类下的刊物数据sub list--------------------------------------------------

// 分类列表里的刊物 只能通过这个接口来获取  
// 加载本地数据库刊物分类列表下的所有刊物
- (NSArray *)loadSubscribesFromLocalDBWithSubTypeId:(NSString *)typeId;

// 从服务器获取最新的刊物分类下的所有刊物 -- 第一次获取20条
- (SNSubscribeCenterOperation *)loadSubscribesFromServerWithSubTypeId:(NSString *)typeId;

// 从服务器获取更多刊物下的刊物 每次获取20条
- (SNSubscribeCenterOperation *)loadSubscribesFromServerWithSubTypeId:(NSString *)typeId pageNum:(NSInteger)pageNum;


#pragma mark ------------------订阅、退订 subscribe/change.go-------------------------------------------

// 订阅某个刊物
//- (SNSubscribeCenterOperation *)addMySubToServerBySubObject:(SCSubscribeObject *)subObj;
- (void)addMySubToServerBySubObject:(SCSubscribeObject *)subObj;
- (void)addMySubToServerBySubId:(NSString *)subId from:(int)from;

// 退订某个刊物
//- (SNSubscribeCenterOperation *)removeMySubToServerBySubObject:(SCSubscribeObject *)subObj;
- (void)removeMySubToServerBySubObject:(SCSubscribeObject *)subObj;
- (void)removeMySubToServerBySubId:(NSString *)subId from:(int)from;

// 批量订阅、退订某些刊物
- (SNSubscribeCenterOperation *)addAndRemoveMySubsToServerWithAddObjs:(NSArray *)addObjs removeObjs:(NSArray *)removeObjs;

//正文H5化订阅退订
- (void)h5NewsAddMySubscribe:(id)jsonData;
- (void)h5NewsRemoveMySubscribeSubId:(NSString *)subId;

#pragma mark ------------------推送 设置 mypush/change.go-----------------------------------------------

// 同步某个刊物的推送到服务器
//- (SNSubscribeCenterOperation *)synchronizeMySubPushToServerBySubObject:(SCSubscribeObject *)subObj;

// 批量同步多个刊物的推送设置到服务器
- (SNSubscribeCenterOperation *)synchronizeMySubsPushToServerBySubObjects:(NSArray *)subObjs;

#pragma mark ------------------订阅 推送 合并接口 mypush/subscribe/change.go-----------------------------

// 批量订阅刊物，并且在关注成功之后批量设置刊物推送开关 -- 分两步来做
- (SNSubscribeCenterOperation *)addMySubsToServer:(NSArray *)mySubs withPushOpen:(BOOL)bOpen;

#pragma mark ----------------精品列表 marrow list-------------------------------------------------------

// 从服务器获取最新的精品列表，包含精品列表的刊物列表和广告推广位
- (SNSubscribeCenterOperation *)loadSubHomeDataFromServer;

// 从服务器-分页-获取最新的精品列表 - 每页20条数据
- (SNSubscribeCenterOperation *)loadSubHomeMoreDataFromServerWithPageNo:(NSInteger)pageNo;

#pragma mark -----------------刊物排行列表 rank list-----------------------------------------------------

// 从本地加载排行刊物
// @deprecated
- (NSArray *)loadSubRankListFromDB;

// 从服务器获取最新的排行刊物
- (SNSubscribeCenterOperation *)loadSubRankListFromServer;

// 从服务器获取更多排行的刊物
- (SNSubscribeCenterOperation *)loadSubMoreRankListFromServer:(NSInteger)pageNo;

#pragma mark -----------------添加刊物评论 subComment.go ------------------------------------------------
// subId		订阅Id
// author		评论人
// starGrade	评论星级
// content      评论正文内容
- (SNSubscribeCenterOperation *)postSubComment:(NSString *)content author:(NSString *)author starGrade:(float)grade subId:(NSString *)subId;

#pragma mark -----------------刊物 信息 评论信息----------------------------------------------------------
// 根据subId获取刊物详细数据  根据topic更新数据库
- (SNSubscribeCenterOperation *)dealSubInfoFromServerBySubId:(NSString *)subId operationTopic:(NSString *)topic;

// 根据subId获取刊物详细数据 包括刊物信息和评论  
- (SNSubscribeCenterOperation *)loadSubDetailFromServerBySubId:(NSString *)subId;

// 根据subId获取刊物详细数据  不包括评论信息 -- 注意：这个接口不返回评论总数 暂时还不会回调 待完善
- (SNSubscribeCenterOperation *)loadSubInfoFromServerBySubId:(NSString *)subId;

// 根据subId获取刊物评论列表 默认每页返回20条数据 
- (SNSubscribeCenterOperation *)loadSubCommentListFromServerBySubId:(NSString *)subId pageNo:(int)pageNo;

// 根据subId 获取刊物的二维码信息 
- (SNSubscribeCenterOperation *)loadSubQRInfoFromServerBySubId:(NSString *)subId;

#pragma mark -----------------刊物信息页 刊物推荐---------------------------------------------------------

// 从服务器获取4条随机刊物推荐数据 通过回调返回
- (SNSubscribeCenterOperation *)loadSubRecommendFromServer;

#pragma mark -----------------推广位数据 ad list---------------------------------------------------------

// 从本地加载ad list
- (NSArray *)loadAdListFromLocalDBForType:(SNSubCenterAdListType)type;

#pragma mark ------------------添加、移除 观察者 回调相关 很重要--------------------------------------------

// 添加后台listener
- (BOOL)addBackgroundOperation:(SNSubscribeCenterOperation *)operation;

// 移除后台listener
- (BOOL)removeBackgroundOperation:(SNSubscribeCenterOperation *)operation;

// 跟NSNotificationCenter一样  需要的时候 添加观察者  不需要的时候及时移除  否则，就不多说什么了
- (BOOL)addListener:(id)listener;
- (BOOL)removeListener:(id)listener;

- (BOOL)addListener:(id)listener forOperation:(SCServiceOperationType)operation;
- (BOOL)removeListener:(id)listener forOperation:(SCServiceOperationType)operation;

#pragma mark -----------------public methods------------------------------------------------------------

// 取消所有请求
- (void)cancelAllRequest;

+ (SNSubscribeCenterService *)defaultService;

@end

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - SNSubscribeCenterService (Utility)

@interface SNSubscribeCenterService (Utility)

+ (BOOL)handleAdOpenRequest:(SCSubscribeAdObject *)adObj;

+ (BOOL)shouldReloadMySub;
+ (void)saveMySubRefreshDate;
+ (NSDate *)getMySubLastRefreshDate;
+ (void)clearMySubRefreshDate;

+ (void)clearAllSubRefreshCachedData;
+ (BOOL)shouldReloadTypeList;

+ (BOOL)shouldReloadHomeData;
+ (void)saveHomeDataRefreshDate;

+ (BOOL)shouldReloadSubItemsForType:(NSString *)typeId;
+ (void)saveSubItemsDateForType:(NSString *)typeId;

// 新刊物提醒

// 是否在我的订阅页面显示悬浮的更多订阅cell
// 这个是与版本相关的，如果是新版本第一次进入我的订阅，默认会显示；
// 如果有新的推荐刊物，会显示；
+ (BOOL)shouldDisplayFloatingCell;

// 如果传入参数为NO（设置没有显示过悬浮cell），会捎带把之前版本的标志位清理掉
+ (void)setDisplayedFloatingCell:(BOOL)bShowed;

// 是否有新刊物的mark
+ (BOOL)hasNewSubscribe;

+ (void)setHasNewSubscrbe:(BOOL)bHasNew;

// 新增一个便利方法 查看某个刊物是否订阅  或者某个插件是否开启(实际也是订阅)
+ (BOOL)isSubscribeOrPluginEnable:(NSString *)subId;

// 订阅、评论等操作是否需要登录 3.5.1
+ (BOOL)shouldLoginForSubscribeWithSubId:(NSString *)subId;
+ (BOOL)shouldLoginForSubscribeWithObj:(SCSubscribeObject *)subObj;

// 3.5.1 根据subId获取对应的自媒体作者信息
+ (NSArray *)subAuthorInfoListBySubId:(NSString *)subId;

@end

////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -----------SNSubscribeCenterServiceDelegate------------------------------------------------

@protocol SNSubscribeCenterServiceDelegate <NSObject>

@optional
// 统一的数据回调
- (void)didFinishLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet;
- (void)didFailLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet;
- (void)didCancelLoadDataWithDataSet:(SNSubscribeCenterCallbackDataSet *)dataSet;

@end
