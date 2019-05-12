//
//  SNCommonNewsDatasource.h
//  sohunews
//
//  Created by Diaochunmeng on 13-3-26.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNRollingNews;
@class SNRollingNewsModel;
@class SNSpecialNewsModel;
@class SNSpecialNews;
@class SNWeiboListTableItem;
@interface SNCommonNewsDatasource : NSObject
{
    //即时新闻
    NSMutableArray *newsList;
    NSMutableArray *photoList;
    NSMutableArray *specailList;
    NSMutableArray *weiboList;
    NSMutableArray *allList;
    SNRollingNewsModel *__weak newsModel;
    //专题
    NSMutableArray *_excludePhotoNewsIds;
    NSMutableArray *photoNewsIds;
    NSMutableArray *allNewsIds;
    SNSpecialNewsModel *__weak snModel;
    //微博
    NSMutableArray *allWeiwen;
    BOOL  isFromSub;
}

@property(nonatomic, strong)NSMutableArray *newsList;
@property(nonatomic, strong)NSMutableArray *photoList;
@property(nonatomic, strong)NSMutableArray *specailList;
@property(nonatomic, strong)NSMutableArray *weiboList;
@property(nonatomic, strong)NSMutableArray *allList;
@property (nonatomic,weak)SNRollingNewsModel *newsModel;

@property(nonatomic, strong)NSMutableArray *excludePhotoNewsIds;
@property(nonatomic, strong)NSMutableArray *photoNewsIds;
@property(nonatomic, strong)NSMutableArray *allNewsIds;
@property(nonatomic, weak)SNSpecialNewsModel *snModel;

@property(nonatomic, strong)NSMutableArray *allWeiwen;
@property(nonatomic, assign)BOOL isFromSub;

-(NSMutableDictionary*)getContentDictionary:(SNRollingNews*)aNews;
-(NSMutableDictionary*)getSpecialContentDictionary:(SNSpecialNews*)aSpecailNews;
+(NSMutableDictionary*)getContentRecommandDictionary:(NSDictionary*)aDic;
+(NSMutableDictionary*)getPhotoListRecommandDictionary:(NSDictionary*)aDic;
@end
