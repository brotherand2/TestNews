//
//  SNAdvertiseObjects.m
//  sohunews
//
//  Created by jojo on 13-12-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNAdvertiseObjects.h"
#import "NSObject+YAJL.h"
#import "SNUserManager.h"

#define kAdObjKeyAdId                           (@"adId")
#define kAdObjKeyAdSpaceId                      (@"itemspaceid") // 为适应 广告sever的key值  有adSpaceId 改为itemspaceid
#define kAdObjKeyItemSpaceId                    (@"itemspaceid") // 回传给sdk时  需要对key做一下替换  替换adSpaceId
#define kAdObjKeyExpiretime                     (@"expiretime")
#define kAdObjKeyFilterInfo                     (@"filterInfo")

#define kAdObjKeySdk                            (@"sdk")
#define kAdObjKeyNewsID                         (@"newsId")
#define kAdObjKeyAdInfos                        (@"adInfos")
#define kAdObjKeyAdInfo                         (@"adInfo")

#define kAdObjKeyAdId2                          (@"adid")
#define kAdObjKeyClickMonitor                   (@"clickmonitor")
#define kAdObjKeyImpressionid                   (@"impressionid")
#define kAdObjKeyMonitorkey                     (@"monitorkey")
#define kAdObjKeyImageUrl                       (@"file")
#define kAdObjKeyClickUrl                       (@"click")
#define kAdObjKeyViewmonitor                    (@"viewmonitor")
#define kAdObjKeySize                           (@"size")

#define kAdObjKeyGBCode                         (@"gbcode")
#define kAdObjKeyADPType                        (@"adp_type")


#pragma mark - SNAdInfo

@implementation SNAdInfo
@synthesize adId = _adId;
@synthesize adSpaceId = _adSpaceId;
@synthesize expiretime = _expiretime;

@synthesize filterInfo = _filterInfo;

- (void)setFilterInfo:(NSMutableDictionary *)filterInfo
{
    _filterInfo = [NSMutableDictionary dictionaryWithDictionary:filterInfo];
}

- (id)initWithJsonDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.adId = [dic stringValueForKey:kAdObjKeyAdId defaultValue:nil];
        self.adSpaceId = [dic stringValueForKey:kAdObjKeyAdSpaceId defaultValue:nil];
        self.expiretime = [dic stringValueForKey:kAdObjKeyExpiretime defaultValue:nil];
        
        NSDictionary *filterDic = [dic dictionaryValueForKey:kAdObjKeyFilterInfo defalutValue:nil];
        if (filterDic) {
            self.filterInfo = [NSMutableDictionary dictionaryWithDictionary:filterDic];
        }
        
        if (self.adSpaceId) {
            [self.filterInfo setObject:self.adSpaceId forKey:kAdObjKeyItemSpaceId];
        }
    }
    return self;
}

- (id)initWithXMLElement:(TBXMLElement *)elm {
    self = [super init];
    if (self) {
        self.adId = [TBXML textForElement:[TBXML childElementNamed:kAdObjKeyAdId parentElement:elm]];
        self.adSpaceId = [TBXML textForElement:[TBXML childElementNamed:kAdObjKeyAdSpaceId parentElement:elm]];
        self.expiretime = [TBXML textForElement:[TBXML childElementNamed:kAdObjKeyExpiretime parentElement:elm]];
        
        TBXMLElement *filterElm = [TBXML childElementNamed:kAdObjKeyFilterInfo parentElement:elm];
        if (!!filterElm) {
            NSMutableDictionary *filterDic = [NSMutableDictionary dictionary];
            TBXMLElement *childElm = filterElm->firstChild;
            
            while (!!childElm) {
                NSString *elmName = [TBXML elementName:childElm];
                NSString *elmText = [TBXML textForElement:childElm];
                
                if (elmName && elmText) {
                    [filterDic setObject:elmText forKey:elmName];
                }
                
                childElm = childElm->nextSibling;
            }
            
            self.filterInfo = filterDic;
        }
        
        if (self.adSpaceId) {
            [self.filterInfo setObject:self.adSpaceId forKey:kAdObjKeyItemSpaceId];
        }
    }
    return self;
}

- (NSString *)appChannel {
    return [self.filterInfo stringValueForKey:@"appchn" defaultValue:nil];
}

- (NSString *)newsChannel {
    return [self.filterInfo stringValueForKey:@"newschn" defaultValue:nil];
}

- (NSString *)gbcode {
    return [self.filterInfo stringValueForKey:@"debugloc" defaultValue:nil];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.adId) {
        [dic setObject:self.adId forKey:kAdObjKeyAdId];
    }
    if (self.adSpaceId) {
        [dic setObject:self.adSpaceId forKey:kAdObjKeyAdSpaceId];
    }
    if (self.expiretime) {
        [dic setObject:self.expiretime forKey:kAdObjKeyExpiretime];
    }
    if (self.filterInfo) {
        [dic setObject:self.filterInfo forKey:kAdObjKeyFilterInfo];
    }
    return dic;
}

- (NSString *)toJsonString {
    return [[self toDictionary] yajl_JSONString];
}

- (void)dealloc {
}

@end

#pragma mark - SNAdControllInfo

@implementation SNAdControllInfo
@synthesize sdkIdentify = _sdkIdentify;
@synthesize adInfos = _adInfos;
@synthesize newsID = _newsID;

- (id)initWithJsonDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        self.sdkIdentify = [dic stringValueForKey:kAdObjKeySdk defaultValue:nil];
        self.newsID = [dic stringValueForKey:kAdObjKeyNewsID defaultValue:nil];
        self.adInfos = [NSMutableArray array];
        
        NSArray *adInfosArray = [dic arrayValueForKey:kAdObjKeyAdInfos defaultValue:nil];
        
        for (NSDictionary *adInfoDic in adInfosArray) {
            if ([adInfoDic isKindOfClass:[NSDictionary class]]) {
                SNAdInfo *adInfo = [[SNAdInfo alloc] initWithJsonDic:adInfoDic];
                
                //lijian 2015.03.26 广告sdk增加newsid
                if(nil != adInfo.filterInfo){
                    if((self.newsID && [self.newsID length] > 0)){
                        [adInfo.filterInfo setObject:self.newsID forKey:kAdObjKeyNewsID];
                    }
                    if ([SNUserManager getCid]) {
                        [adInfo.filterInfo setObject:[SNUserManager getCid] forKey:@"cid"];
                    }
                }
                
                [self.adInfos addObject:adInfo];
            }
        }
    }
    return self;
}

- (id)initWithXMLElement:(TBXMLElement *)elm {
    self = [super init];
    if (self) {
        self.sdkIdentify = [TBXML textForElement:[TBXML childElementNamed:kAdObjKeySdk parentElement:elm]];
        self.adInfos = [NSMutableArray array];
        
        TBXMLElement *adInfosElm = [TBXML childElementNamed:kAdObjKeyAdInfos parentElement:elm];
        if (!!adInfosElm) {
            TBXMLElement *anAdInfoElm = [TBXML childElementNamed:kAdObjKeyAdInfo parentElement:adInfosElm];
            if (!!anAdInfoElm) {
                SNAdInfo *adInfo = [[SNAdInfo alloc] initWithXMLElement:anAdInfoElm];
                [self.adInfos addObject:adInfo];
                
                while (!!(anAdInfoElm = [TBXML nextSiblingNamed:kAdObjKeyAdInfo searchFromElement:anAdInfoElm])) {
                    SNAdInfo *adInfo = [[SNAdInfo alloc] initWithXMLElement:anAdInfoElm];
                    [self.adInfos addObject:adInfo];
                }
            }
        }
    }
    return self;
}

- (NSString *)toJsonString {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.sdkIdentify) {
        [dic setObject:self.sdkIdentify forKey:kAdObjKeySdk];
    }
    //lijian 2015j.03.31 添加数据库的内容
    if (self.newsID) {
        [dic setObject:self.newsID forKey:kAdObjKeyNewsID];
    }
    if (self.adInfos) {
        NSMutableArray *adInfoDics = [NSMutableArray array];
        for (SNAdInfo *adInfo in self.adInfos) {
            if ([adInfo isKindOfClass:[SNAdInfo class]]) {
                NSDictionary *dic = [adInfo toDictionary];
                if (dic) {
                    [adInfoDics addObject:dic];
                }
            }
        }
        [dic setObject:adInfoDics forKey:kAdObjKeyAdInfos];
    }
    
    return [dic translateDictionaryToJsonString];
}

- (void)dealloc {
}

@end


@implementation SNAdLiveInfo

- (id)initWithJsonDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        
        //广告用参数
        self.gbCode = [dic stringValueForKey:kAdObjKeyGBCode defaultValue:nil];
        self.adpType = [dic stringValueForKey:kAdObjKeyADPType defaultValue:nil];
        
        NSDictionary *data = [dic dictionaryValueForKey:@"data" defalutValue:nil];
        if(nil != data){
            self.adId = [data stringValueForKey:kAdObjKeyAdId2 defaultValue:nil];
            self.adSpaceId = [data stringValueForKey:kAdObjKeyAdSpaceId defaultValue:nil];
            self.clickmonitor = [data stringValueForKey:kAdObjKeyClickMonitor defaultValue:nil];
            self.viewmonitor = [data stringValueForKey:kAdObjKeyViewmonitor defaultValue:nil];
            self.size = [data stringValueForKey:kAdObjKeySize defaultValue:nil];
            
            id sourceDic = [data objectForKey:@"resource"];
            if([sourceDic isKindOfClass:[NSDictionary class]]){
                self.imgUrl = [sourceDic stringValueForKey:kAdObjKeyImageUrl defaultValue:nil];
                self.clickUrl = [sourceDic stringValueForKey:kAdObjKeyClickUrl defaultValue:nil];
            }
            
            NSString *error = [data stringValueForKey:@"error" defaultValue:nil];
            if(nil != error && [error isEqualToString:@"1"]){
                return nil;
            }
        }
    }

    return self;
}

- (void)dealloc
{
    self.adId = nil;
    self.adSpaceId = nil;
    
    
}

- (BOOL)isValid
{
    if(   (nil != self.adId && [self.adId length] > 0)
       && (nil != self.imgUrl && [self.imgUrl length] > 0) ){
        return YES;
    }
    
    return NO;
}
@end
