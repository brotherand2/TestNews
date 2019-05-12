//
//  SNBusinessStatInfo.h
//  sohunews
//
//  Created by jialei on 14-8-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNStatisticsConst.h"

@interface SNBusinessStatInfo : NSObject

@property (nonatomic, assign) SNStatisticsEventType statType;

//用于流类加载过滤token重复值(必须)
@property(nonatomic, strong) NSString *token;

//统计对象来源
@property(nonatomic, assign) SNBusinessStatisticsObjFrom objFrom;

//统计对象来源 的 唯一标识 (例如：objFrom=news&objFromId=${channelId})
@property(nonatomic, strong) NSString* objFromId;

//统计对象标识(objType=（1,2,3,4）时，传newsid objType=（5,6）时，传被推荐内容的newsid或g)
@property(nonatomic, strong) NSArray *objIDArray;

//统计模版类型
@property(nonatomic, assign) SNBusinessStatisticsObjType objType;

//流内模版类型，区分编辑流和推荐流，流内模版统计赋值
@property(nonatomic, strong) NSString *timelineMode;

//流内加载赋值，区分上拉和下拉加载
@property(nonatomic, strong) NSString *loadMode;

/*统计对象来源 (news, video, subScribe)
 *exps1 编辑流上拉
 *exps2	编辑流下拉
 *exps3	推荐上拉
 *exps4	推荐下拉
 *exps5	文章页相关推荐
 *exps6	组图相关推荐
 *exps7	LOADING页
 *exps8	编辑流
 *exps9	推荐流
 */
//(exp1 - exp8) 内部计算不需要赋值
@property(nonatomic, retain, readonly) NSString *urlObjType;
@property(nonatomic, assign, readonly) NSString *urlStatType;

@property(nonatomic, strong) NSString *position;

@property(nonatomic, strong) NSString *toChannelId;

//没有此参数或此参数为非1的值,则不是频道流置顶新闻
@property(nonatomic, assign) int isTopNews;

@property(nonatomic, strong) NSString *adId;

@property (nonatomic, strong) NSString *recomReasons;//推荐理由
@property (nonatomic, strong) NSString *recomTime;//推荐时间

@end
