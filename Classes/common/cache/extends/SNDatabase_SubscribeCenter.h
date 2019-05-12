//
//  SNDatabase_SubscribeCenter.h
//  sohunews
//
//  Created by wang yanchen on 12-11-19.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"

// 4.3版本在我的订阅也增加了多个推广位，增加一个类型SNSubCenterAdListType 来区分老的订阅中心的adlist
typedef enum {
    SNSubCenterAdListTypeMySub, // 我的订阅 推广位
    SNSubCenterAdListTypeSubCenter, // 订阅中心 推广位s
}SNSubCenterAdListType;

@interface SNDatabase(SubscribeCenter)

/*
  移植自handy 之前写的 homeV3_CacheMgr_SubscribeHomePO 接口功能尽量保持一样的风格 
 */

#pragma mark - Public methods implementation

// ****************************************************************************************************************************************
// ***************************** add ******************************************************************************************************

// 批量保存订阅数据到数据库，如果数据库已存在则覆盖
- (BOOL)addSubscribeCenterSubscribeObjects:(NSArray*)mySubscribeObjectArray;

// 批量保存订阅数据到数据库
- (BOOL)addSubscribeCenterSubscribeObjects:(NSArray*)mySubscribeObjectArray updateIfExist:(BOOL)bUpdateIfExist;

// 单个保存订阅数据到数据库，如果数据库已存在则覆盖
- (BOOL)addASubscribeCenterSubscribeObject:(SCSubscribeObject *)mySubscribeObject;

// 单个保存订阅数据到数据库
- (BOOL)addASubscribeCenterSubscribeObject:(SCSubscribeObject *)mySubscribeObject updateIfExist:(BOOL)bUpdateIfExist;

// 保存我的订阅到数据库 (先delete all再insert的事务操作)
- (BOOL)addSubscribeCenterMySubscribes:(NSArray *)mySubscribePOArray;

// 保存推荐订阅到数据库(先delete all再insert)
- (BOOL)addSubscribeCenterRecomSubscribes:(NSArray *)recomSubscribePOArray;

// 保存更多推荐订阅到数据库
- (BOOL)addSubscribeCenterMoreRecomSubscribes:(NSArray *)recomSubscribePOArray;

// 保存所有订阅数据到数据库（先delete all再insert的事务操作）
- (BOOL)addSubscribeCenterAllSubscribes:(NSArray *)allSubscribePOArray;

// **************************** and *******************************************************************************************************
// ****************************************************************************************************************************************


// ****************************************************************************************************************************************
// *************************** delete *****************************************************************************************************

// 根据subid删除订阅(这里不需要删除数据，只需要将isSubscribed标志为0)
- (BOOL)deleteSubscribeCenterSubscribeObjectBySubId:(NSString *)subId;

// 删除不在所有订阅中的我订阅。出现刊物在“所有订阅列表”中没有但在“我的订阅”中有的现象的原因是：某刊物已被订阅，但是这个刊物某一天被下架了。
- (BOOL)deleteSubscribeCenterSubscribeObjectsInAllArray:(NSArray *)objsToDelete;

// 根据subid删除订阅(数据库删除)
- (BOOL)deleteSubscribeCenterSubscribeObjectFromDatabaseBySubId:(NSString *)subId;
// *************************** delete *****************************************************************************************************
// ****************************************************************************************************************************************


// ****************************************************************************************************************************************
// ************************** update ******************************************************************************************************

// 更新单个订阅
- (BOOL)updateSubscribeCenterSubscribeObject:(SCSubscribeObject *)subObj addIfNotExist:(BOOL)bAddIfNotExist;

// 更新单个SubHome订阅，如果不存在不要添加到数据库
- (BOOL)updateSubscribeCenterSubscribeObjectBySubId:(NSString*)subId withValuePairs:(NSDictionary*)valuePairs;

// 更新单个SubHome订阅，如果不存在并可以根据参数决定要不要添加到数据库
- (BOOL)updateSubscribeCenterSubscribeObjectBySubId:(NSString*)subId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist;

// 更新单个SubHome订阅，如果不存在不要添加到数据库
- (BOOL)updateSubscribeCenterSubscribeObjectByPubId:(NSString*)pubId withValuePairs:(NSDictionary*)valuePairs;

// 更新单个SubHome订阅，如果不存在并可以根据参数决定要不要添加到数据库
- (BOOL)updateSubscribeCenterSubscribeObjectByPubId:(NSString*)pubId withValuePairs:(NSDictionary*)valuePairs addIfNotExist:(BOOL)bAddIfNotExist;

// ************************** update ******************************************************************************************************
// ****************************************************************************************************************************************


// ****************************************************************************************************************************************
// ************************** query *******************************************************************************************************

// 获取我的订阅数据
- (NSArray *)getSubscribeCenterMySubscribeArray;
- (NSArray *)getSubArrayWithoutYouMayLike;
- (NSArray *)getSubArrayWithoutExpressOrYouMayLike;
- (NSArray *)getSubSortedArrayWithoutExpressOrYouMayLike;
- (NSArray *)getRecomSubArray;
- (BOOL)getExpressPushState;
- (NSInteger)getSubArrayCount;
- (NSArray *)getSubArrayWithExpress;

// 获取全部可下载的订阅刊物
- (NSArray *)getSubArrayCanOffline;

// 获取在下载设置里设置的打算要下载的我的订阅
- (NSArray *)getSubscribeCenterSelectedMySubList;

// 获取未下载的且在下载设置里勾选的“我的订阅”数据集合
- (NSArray *)getSubscribeCenterSelectedUndownloadedMySubList;

// 获取未下载的“我的订阅”数据集合
- (NSArray *)getSubscribeCenterUndownloadedMySubList;

// add in 3.4 for 离线下载 筛除以订阅里的频道信息,因为频道里数据是无法通过zip包的方式来下载的
- (NSMutableArray *)filterNewsSubscribeFromSubscribeArray:(NSArray*)aList;

// 获取所有订阅数据列表（已订阅和未订阅的）
- (NSArray *)getSubscribeCenterAllSubscribesArray;

// 获取所有订阅中在rank list上的数据
- (NSArray *)getSubscribeCenterAllSubscribesOnRankListArray;

// 根据subTypeId获取对应的所有刊物数据
- (NSArray *)getSubscribeCenterSubItemsBySubTypeId:(NSString *)typeId;

// 根据subId获取对应的某一个“所有订阅”数据
- (SCSubscribeObject *)getSubscribeCenterSubscribeObjectBySubId:(NSString*)subId;

// 根据pubId获取对应的某一个“所有订阅”数据
- (SCSubscribeObject *)getSubscribeCenterSubscribeObjectByPubId:(NSString *)pubId;

// 根据pubIds获取对应的某一个“所有订阅”数据
- (SCSubscribeObject *)getSubscribeCenterSubscribeObjectByPubIds:(NSString*)pubIds;

// 获取所有未订阅所有订阅数据列表（未订阅）
- (NSArray*)getSubscribeCenterUnsubAllSubscribesArray;

// 获取推荐刊物列表数据
- (NSArray *)getSubscribeCenterRecommendedSubs;

// ************************** query *******************************************************************************************************
// ****************************************************************************************************************************************

#pragma mark - subtype list
// sub type list

// 批量添加
- (BOOL)addSubscribeCenterSubTypes:(NSArray *)typesArray bUpdateIfExist:(BOOL)bUPdateIfExist;

// 单个添加
- (BOOL)addSubscribeCenterSubType:(SCSubscribeTypeObject *)typeObj bUpdateIfExist:(BOOL)bUpdateIfExist;

// 单个更新
- (BOOL)updateSubscribeCenterSubType:(SCSubscribeTypeObject *)typeObj bAddIfNotExist:(BOOL)bAddIfNotExist;

// 保存新的刊物列表到数据库 (先删除掉服务端下架的，并删除对应的关系; 有则更新，没有就添加,并且更新对应的关系到关系表)
- (BOOL)setSubscribeCenterSubTypes:(NSArray *)subTypes;

// 获取刊物分类列表
- (NSArray *)getSubscribeCenterSubTypes;

// 删除type集合
- (BOOL)deleteSubscribeCenterSubTypesInArray:(NSArray *)subTypes;

// 根据typeId删除某个type数据
- (BOOL)deleteSubscribeCenterSubTypeByTypeId:(NSString *)typeId;

#pragma mark - relation for all sub and sub types

// 单条保存
- (BOOL)addSubscribeATypeRelation:(NSString *)typeId subId:(NSString *)subId;

// 保存
- (BOOL)setSubscribeTypeRelationSubIds:(NSArray *)subIds forTypeId:(NSString *)typeId;

// 获取对应typeId的所有订阅的subId集合
- (NSArray *)getSubscribeTypeRelationSubIdsForTypeId:(NSString *)typeId;

// 根据typeId集合 删除关系表中对应的所有关系
- (BOOL)deleteSubscribeTypeRelationInArray:(NSArray *)relationArray;

// 根据typeId删除关系表中对应的所有关系
- (BOOL)deleteSubscribeTypeRelationByTypeId:(NSString *)typeId;

#pragma mark - ad list
// 重置ad list
- (BOOL)setSubscribeCenterAdList:(NSArray *)adList ofType:(SNSubCenterAdListType)type;

// 获取ad list
- (NSArray *)getSubscribeCenterAdListForType:(SNSubCenterAdListType)type;

#pragma mark - sub comment list

// 保存刊物评论列表  先删除老数据 在添加新数据
- (BOOL)setSubscribeCenterSubCommentsArray:(NSArray *)commentArray forSubId:(NSString *)subId;

// 单个添加
- (BOOL)addSubscribeCenterSubComment:(SCSubscribeCommentObject *)commentObj;

// 批量添加
- (BOOL)addSubscribeCenterSubComments:(NSArray *)commentsArray;

// 通过subId 获取对应的所有comment 数据
- (NSArray *)getSubscribeCenterSubCommentsBySubId:(NSString *)subId;

@end
