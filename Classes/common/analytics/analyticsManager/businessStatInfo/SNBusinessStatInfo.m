//
//  SNBusinessStatInfo.m
//  sohunews
//
//  Created by jialei on 14-8-13.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNBusinessStatInfo.h"

const NSString *StatisticsEventTypeNameMapping[] = {
    [SNStatisticsEventTypeLoad] = @"load",
    [SNStatisticsEventTypeShow] = @"show",
    [SNStatisticsEventTypeClick] = @"clk",
    [SNStatisticsEventTypeUninterested] = @"unintr"
};

@interface SNBusinessStatInfo()

@property (nonatomic, retain)NSDictionary *timelineTypeDic;

@end

@implementation SNBusinessStatInfo

- (id)init
{
    self = [super init];
    if (self) {
        self.statType = @"";
        self.token = @"";
        self.objFrom = 0;
        self.objFromId = @"";
        self.timelineMode = @"";
        self.loadMode = @"";
        self.timelineTypeDic = @{@"00" : @"exps1",    //编辑流上拉
                                 @"01" : @"exps2",    //编辑流下拉
                                 @"10" : @"exps3",    //推荐上拉
                                 @"11" : @"exps4",    //推荐下拉
                                 @"0" : @"exps8",     //编辑流
                                 @"1" : @"exps9",
                                 @"13" : @"exps13",  //焦点图
                                 @"17" : @"exps17",
                                 @"19" : @"exps19",//流内智能报盘
                                 
                                 };    //推荐流
    }
    return self;
}

- (NSString *)urlObjType
{
    NSMutableString *type = [NSMutableString stringWithString:@"exps"];
    switch (self.objType) {
        case SNBusinessStatisticsObjTypeTimeline: {
            NSString *typeKey = [NSString stringWithFormat:@"%@%@", self.timelineMode, self.loadMode];
            NSString *typeValue = _timelineTypeDic[typeKey];
            return typeValue;
        }
        case SNBusinessStatisticsObjTypeArticleRecommend:
            [type appendFormat:@"%ld", (long)SNBusinessStatisticsObjTypeArticleRecommend];
            return type;
        case SNBusinessStatisticsObjTypeGalleryRecommend:
            [type appendFormat:@"%ld", (long)SNBusinessStatisticsObjTypeGalleryRecommend];
            return type;
        case SNBusinessStatisticsObjTypeLoading:
            [type appendFormat:@"%ld", (long)SNBusinessStatisticsObjTypeLoading];
            return type;
        case SNBusinessStatisticsObjTypeSubRecom:
            [type appendFormat:@"%ld", (long)SNBusinessStatisticsObjTypeSubRecom];
            return type;
        case SNBusinessStatisticsObjTypeRedPacket:
            [type appendFormat:@"%ld", (long)SNBusinessStatisticsObjTypeRedPacket];
            return type;
        case SNBusinessStatisticsObjTypeZNPaopan:
            [type appendFormat:@"%ld", (long)SNBusinessStatisticsObjTypeZNPaopan];
            return type;
        default:
            return nil;
    }
    return type;
}

- (NSString *)urlStatType
{
    return (NSString *)StatisticsEventTypeNameMapping[self.statType];
}

@end
