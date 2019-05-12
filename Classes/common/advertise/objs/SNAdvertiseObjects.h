//
//  SNAdvertiseObjects.h
//  sohunews
//
//  Created by jojo on 13-12-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

// 每一个具体广告的数据结构
@interface SNAdInfo : NSObject

@property (nonatomic, copy) NSString *adId;
@property (nonatomic, copy) NSString *adSpaceId; // 决定具体是哪个页面哪个位置的广告
@property (nonatomic, strong) NSMutableDictionary *filterInfo; // 需要回传给广告sdk的参数集，不需要关心里面的结构
@property (nonatomic, copy) NSString *expiretime;
@property (nonatomic, strong) NSString *appChannel;
@property (nonatomic, strong) NSString *newsChannel;
@property (nonatomic, strong) NSString *gbcode;
// init
- (id)initWithJsonDic:(NSDictionary *)dic;
- (id)initWithXMLElement:(TBXMLElement *)elm;

- (NSDictionary *)toDictionary;
- (NSString *)toJsonString;

@end

// 每个接口返回的广告数据根节点
@interface SNAdControllInfo : NSObject

@property (nonatomic, copy) NSString *sdkIdentify; // 标志某个广告位 目前都是搜狐自己的广告 "sohu"
@property (nonatomic, strong) NSMutableArray *adInfos; // 广告数据集 objects of SNAdInfo
@property (nonatomic, copy) NSString *newsID;   //lijian 2015.03.26 添加新闻ID
//@property (nonatomic, retain)NSString *newsChannel;
//@property (nonatomic, retain)NSString *appChannel;

// init
- (id)initWithJsonDic:(NSDictionary *)dic;
- (id)initWithXMLElement:(TBXMLElement *)elm;

- (NSString *)toJsonString;

@end


@interface SNAdLiveInfo : SNAdInfo

@property (nonatomic, copy) NSString *viewmonitor;
@property (nonatomic, copy) NSString *clickmonitor;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *clickUrl;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, assign) NSInteger reportID;

@property (nonatomic, copy) NSString *gbCode;
@property (nonatomic, copy) NSString *adpType;
@property (nonatomic, copy) NSString * blockId;
@property (nonatomic, copy) NSString *dsp_source;

- (BOOL)isValid;

@end
