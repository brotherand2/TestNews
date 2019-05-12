//
//  SNSubscribeCenterDefines.h
//  sohunews
//
//  Created by jojo on 14-2-17.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNPreference.h"

#ifndef sohunews_SNSubscribeCenterDefines_h
#define sohunews_SNSubscribeCenterDefines_h

// urls


// my sub changed value info key
#define kSubcenterMySubDidChangedAddedSubIdArrayKey     (@"kSubcenterMySubDidChangedAddedSubIdArrayKey")
#define kSubcenterMySubDidChangedRemovedSubIdArrayKey   (@"kSubcenterMySubDidChangedRemovedSubIdArrayKey")

#define kDidFindNewSubscribeNotification                (@"kDidFindNewSubscribeNotification")
#define kNewSubscribeUpdateTime                         (@"kNewSubscribeUpdateTime")

#define kSubHomeDataRefreshTimeDiff                     (5 * 60)
#define kSubTypeSubsRefreshTimeDiff                     (5 * 60)
#define kSubMySubRefreshTimeDiff                        (30 * 60)

// keys for userdefaults
#define kSubHomeDataLastRefreshKey                      (@"kSubHomeDataLastRefreshKey")
#define kSubTypeSubsLastRefreshKey                      (@"kSubTypeSubsLastRefreshKey")
#define kSubMySubLastRefreshKey                         (@"kSubMySubLastRefreshKey")
#define kSubMySubLastTimestampKey                       (@"kSubMySubLastTimestampKey")

#define kSubTypeRankId                                  (@"-1") // 排行列表的typeId （本地）
#define kSubTypeRecomendId                              (@"-2") // 精品推荐的typeId （本地）

// 刊物订阅来源统计
#define kSubFromWave                                    (@"wave") // 摇一摇
#define kSubFromRank                                    (@"rank") // 排行
#define kSubFromOps                                     (@"ops") // 运营位的入口
#define kSubFromLoading                                 (@"loading") // loading页
#define kSubFromRecommend                               (@"recommend") // 刊物推荐
#define kSubFromPaperHome                               (@"paperHome") // 刊物首页
#define kSubFromPaperInfo                               (@"paperInfo") // 刊物详情
#define kSubFromSearch                                  (@"search") // 搜索
#define kSubFromMySubList                               (@"mysublist") // 我的订阅
#define kSubFromOther                                   (@"other") // 其他

// key defines
#define kTopicMySubRefresh                  (@"mySub")
#define kTopicMoreRecomSub                  (@"moreRecomSub")
#define kTopicMySubOrder                    (@"synchMySubOrder")
#define kTopicSubHomeDataRefresh            (@"homeData")
#define kTopicSubTypesRefresh               (@"subTypes")
#define kTopicSubItemsFortypeRefresh        (@"subItems")
#define kTopicSubMoreItemsFortypeRefresh    (@"moreSubItems")
#define kTopicRefreshSubRankList            (@"refreshSubRankList")
#define kTopicAddMySub                      (@"addMySub")
#define kTopicRemoveMySub                   (@"removeMySub")
#define kTopicAddOrRemoveMySubs             (@"addOrRemoveMySubs")
#define kTopicRefreshHomeMoreData           (@"homeMoreData")
#define kTopicRefreshSubMoreRankList        (@"refreshSubMoreRankList")
#define kTopicSyncMyPush                    (@"syncMyPush")
#define kTopicSyncMyPushArray               (@"syncMyPushArray")
#define kTopicPostSubComment                (@"postSubComment")
#define kTopicSubDetail                     (@"subDetail")
#define kTopicSubInfo                       (@"subInfo")
#define kTopicSubComment                    (@"subComment")
#define kTopicAddSubInfo                    (@"addSubInfo")
#define kTopicDelSubInfo                    (@"delSubInfo")
#define kTopicSubRecommend                  (@"kTopicSubRecommend")
#define kTopicAddMySubsAndPushSynch         (@"kTopicAddMySubsAndPushSynch")
#define kTopicSubQRInfo                     (@"kTopicSubQRInfo")

// json data key
#define kSubListKey                         (@"subList")
#define kRecomSubListKey                    (@"recomSubList")
#define kNewCountKey                        (@"newCount")
#define kTypeListKey                        (@"typeList")
#define kSubAdListKey                       (@"adList")

#define kSubAddOrRemoveMySubStatusKey       (@"returnStatus")
#define kSubAddOrRemoveMySubMsgKey          (@"returnMsg")
#define kSubAddOrRemoveMySubSuccessRet      (@"200")
#define kSubAddMySubSuccess290Ret           (@"290")//订阅超过400份了
#define kSubAddOrRemoveMySubSubObjKey       (@"subscribe")
#define kRecomSubClick                      (@"kRecomSubClick")//标记是从订阅频道推荐流 订阅 或者 退订 刊物

#define kPostSubCommentResultKey            (@"result")

#define kSubCommentCtimeKey                 (@"ctime")
#define kSubCommentContentKey               (@"content")
#define kSubCommentStarGradeKey             (@"starGrade")
#define kSubCommentAuthorKey                (@"author")
#define kSubCommentCityKey                  (@"city")

#define kSubCommentSubscribe                (@"subscribe")
#define kSubCommentComment                  (@"comment")

// 功能插件 subId
// 摇一摇
#define kSubIdPluginShake                   ([SNPreference sharedInstance].testModeEnabled ? (@"1043") : (@"1089"))
// 阅读圈动态
#define kSubIdPluginTimeLine                ([SNPreference sharedInstance].testModeEnabled ? (@"1047") : (@"1088"))


typedef enum {
    SCServiceOperationTypeStart = 0,
    SCServiceOperationTypeRefreshMySub = 1,
    SCServiceOperationTypeSynchronizeMySubOrder,
    SCServiceOperationTypeRefreshSubTypeList,
    SCServiceOperationTypeRefreshSubTypeSubItems,
    SCServiceOperationTypeRefreshSubTypeMoreSubItems,
    SCServiceOperationTypeRefreshSubHomeData,
    SCServiceOperationTypeRefeshHomeMoreData,
    SCServiceOperationTypeAddMySubToServer,
    SCServiceOperationTypeRemoveMySubToServer,
    SCServiceOperationTypeAddOrRemoveMySubsToServer,
    SCServiceOperationTypeRefreshSubRankList,
    SCServiceOperationTypeRefreshSubMoreRankList,
    SCServiceOperationTypeSynchronizeMySubPush,
    SCServiceOperationTypeSynchronizeMySubsPushArray,
    SCServiceOperationTypePostSubComment,
    SCServiceOperationTypeSubDetail,
    SCServiceOperationTypeSubInfo,
    SCServiceOperationTypeSubInfoSubTypeIcon,
    SCServiceOperationTypeSubComment,
    SCServiceOperationTypeSubRecommend,
    SCServiceOperationTypeAddMySubsAndSynchPush,
    SCServiceOperationTypeSubQRInfo,
    SCServiceOperationTypeSubDetailUserInfo,
    SCServiceOperationTypeSubDetailSubTypeIcon,
    SCServiceOperationTypeMoreRecomSub,
    SCServiceOperationTypeEnd
}SCServiceOperationType;

typedef enum {
    SCServiceErrorCodeUpdateExistObjError = -100,
    SCServiceErrorCodeNoExistObj = -101,
    SCServiceErrorCodeNotAllSuccess = -102,
    SCServiceErrorCodeUnSuccess = -103,
    SCServiceErrorCodeNil = -104,
    SCServiceErrorCodeUnknown = -1001
}SCServiceErrorCode;

typedef enum {
    SNSubscribeCenterServiceStatusFail = -1,
    SNSubscribeCenterServiceStatusCanceld = 0,
    SNSubscribeCenterServiceStatusSuccess
}SNSubscribeCenterServiceStatus;

#endif
