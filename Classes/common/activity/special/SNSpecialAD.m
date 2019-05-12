//
//  SNSpecialAD.m
//  sohunews
//
//  Created by Huang Zhen on 2017/9/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSpecialAD.h"
#import "SNSpecialADTools.h"
#import "TMCache.h"

static const NSString * SNClosedSpecialADDateKey = @"SNClosedSpecialADDateKey";

@interface SNSpecialAD () {
    
    BOOL _cantSeeInDay;
    BOOL _limitExposureCount;
    NSArray <NSString *>* _pageCountArray;
    NSDate * _lastShowTime;
}

@end

@implementation SNSpecialAD

+ (SNSpecialAD *)createSpecialADWithDictionary:(NSDictionary *)dic {
    if (!dic) {
        return nil;
    }
    return [[SNSpecialAD alloc] initWithDic:dic];
}

- (instancetype)initWithDic:(NSDictionary *)dic {
    
    if (self = [super init]) {
        [self updateWithDic:dic];
    }
    return self;
}

- (void)updateWithDic:(NSDictionary *)dic {
    //"xAxisPercent"//素材在屏幕上的x，y 以百分比形式，float格式，比如0.65
    _xAxisPercent = [dic floatValueForKey:kSpecialActivityXAxisPercent defaultValue:0];
    
    //"yAxisPercent"//素材在屏幕上的x，y 以百分比形式，float格式，比如0.65
    _yAxisPercent = [dic floatValueForKey:kSpecialActivityYAxisPercent defaultValue:0];
    
    //"alignCenter"//水平居中，垂直居中，int值， 0无效，1水平，2垂直，3屏幕居中
    _alignCenter = [dic intValueForKey:kSpecialActivityAlignCenter defaultValue:0];
    
    //"alignSide"//右对齐和下对齐， int型，0无效，1右对齐，2下对齐，3屏幕右下角
    _alignSide = [dic intValueForKey:kSpecialActivityAlignSide defaultValue:0];
    
    //"materialRatio"//素材宽度，百分比，float型，比如0.35，根据屏幕宽度计算;素材高度，素材宽度*图片的比例
    _materialRatio = [dic floatValueForKey:kSpecialActivityMaterialRatio defaultValue:0];
    
    //"actUrl"//广告落地页URL
    _actUrl = [dic stringValueForKey:kSpecialActivityActUrl defaultValue:nil];
    
    //"material"//素材zip链接，ios和android都会根据上传的屏幕宽高，下发不同的素材，投放提供ios2套
    _material = [dic stringValueForKey:kSpecialActivityMaterial defaultValue:nil];
    
    //"expsMonitorUrl"//曝光URL，大数据使用
    _expsMonitorUrl = [dic stringValueForKey:kSpecialActivityExpsMonitorUrl defaultValue:nil];
    
    //"expsAdverUrl"//曝光URL，广告商使用
    _expsAdverUrl = [dic stringValueForKey:kSpecialActivityExpsAdverUrl defaultValue:nil];
    
    //"clickMonitorUrl"//点击URL，大数据使用
    _clickMonitorUrl = [dic stringValueForKey:kSpecialActivityClickMonitorUrl defaultValue:nil];
    
    //"clickAdverUrl"//点击URL，广告商使用
    _clickAdverUrl = [dic stringValueForKey:kSpecialActivityClickAdverUrl defaultValue:nil];
    
    //"playTimes"//帧动画播放次数
    _playTimes = [dic intValueForKey:kSpecialActivityPlayTimes defaultValue:1];
    
    //"displayTimeLength"//每帧动画播放时长，单位毫秒
    _displayTimeLength = [dic floatValueForKey:kSpecialActivityDisplayTimeLength defaultValue:84];
    _displayTimeLength = [dic floatValueForKey:kSpecialActivityPeroid defaultValue:84];

    //"adSwitch"//活动显示开关
    _adSwitch = [dic intValueForKey:kSpecialActivityAdSwitch defaultValue:0];
//    _adSwitch = YES;
    
    //广告失效时间
    _endTimeInterval = [dic floatValueForKey:kSpecialActivityEndTime defaultValue:0];
    //广告生效时间
    _startTimeInterval = [dic floatValueForKey:kSpecialActivityStartTime defaultValue:0];

    _statPoint = [dic stringValueForKey:kSpecialActivitystatPoint defaultValue:@"0900"];
    
    //广告位ID 唯一ID
    _spaceId = [dic stringValueForKey:kSpecialActivityChannelId defaultValue:SNArticleADDefaultSpaceID];
    
    //"md5Key"//MD5加密，用于校验
    NSString * newMd5Key = [dic stringValueForKey:kSpecialActivityMD5Key defaultValue:nil];
    if ([newMd5Key isEqualToString:_md5Key] && [SNSpecialADTools didDownloadResourceWithMajorkey:_spaceId]) {
        self.needRefreshResources = NO;
    }else{
        [SNSpecialADTools removeAdResourceWithMajorkey:_spaceId];
        self.needRefreshResources = YES;
        _md5Key = newMd5Key;
    }
    
    //当日展示次数限制
    if (![_spaceId isEqualToString:SNHomePageADDefaultSpaceID]) {
        _dayImpressionsLimit = _playTimes;
    }
    
    NSArray * pageCountArray = [dic arrayValueForKey:kSpecialActivityStatConfig defaultValue:nil];
    NSMutableArray * tmpArr = [NSMutableArray array];
    if (pageCountArray) {
        for (NSNumber * num in pageCountArray) {
            [tmpArr addObject:[NSString stringWithFormat:@"%@",num]];
        }
        [self associateWithDetailNewsOpenCount:tmpArr];
    }
}

#pragma mark -
#pragma mark - Public

- (BOOL)availableWithPageCount:(NSUInteger)pageCount {
    return self.available && [self isAvailableByDetailNewsOpenCount:pageCount];
}

- (BOOL)isAvailableFromLifeCircle {
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970] * 1000;
    return nowTimeInterval <= _endTimeInterval && nowTimeInterval >= _startTimeInterval;
}

- (BOOL)available {
    
    if (![self isAvailableFromLifeCircle]) {
        //广告过期了 失效了
        return NO;
    }
    if (!_adSwitch) {
        //广告开关关闭
        return NO;
    }
    if (![self isAvailableFromClosed]) {
        //关闭
        return NO;
    }
    if (![self isAvailableByLimitExposureCount]) {
        //展示次数达到限制
        return NO;
    }
    return YES;
}

- (void)didShow {
    //用来计数广告展示次数
    _dayImpressions += 1;
    _lastShowTime = [NSDate date];
}

- (void)cantSeeInDay {
    _cantSeeInDay = YES;
    [self didManualClosedAD];
}

- (void)limitExposureCount {
    _limitExposureCount = YES;
}

- (void)associateWithDetailNewsOpenCount:(NSArray<NSString*> *)counts {
    _pageCountArray = [NSArray arrayWithArray:counts];
}


#pragma mark -
#pragma mark - Private

- (void)resetDayImpressions {
    _dayImpressions = 0;
}

- (BOOL)isAvailableByDetailNewsOpenCount:(NSUInteger)count {
    return _pageCountArray.count > 0 ? [_pageCountArray containsObject:[NSString stringWithFormat:@"%d",count]] : YES;
}

- (BOOL)isAvailableByLimitExposureCount {
    //每天9点重置曝光计数
    if (_lastShowTime && [SNSpecialADTools isNaturalDaythanDate: _lastShowTime withTimePoint:_statPoint]) {
        [self resetDayImpressions];
    }
    return _limitExposureCount ? _dayImpressions < _dayImpressionsLimit : YES;
}

- (BOOL)isAvailableFromClosed {
    if (_cantSeeInDay) {
        NSString * key = [NSString stringWithFormat:@"%@_%@",SNClosedSpecialADDateKey,_spaceId];
        NSDate * closedDate = [[TMCache sharedCache] objectForKey:key];
        return [SNSpecialADTools isNaturalDaythanDate: closedDate withTimePoint:_statPoint];
    }
    //如果没有设置过 "关闭后当天不再展示" 的逻辑，默认为广告一直可用
    return YES;
}

- (void)didManualClosedAD {
    NSDate * todayDate = [NSDate date];
    NSString * key = [NSString stringWithFormat:@"%@_%@",SNClosedSpecialADDateKey,_spaceId];
    [[TMCache sharedCache] setObject:todayDate forKey:key];
}


#pragma mark -
#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        
        _xAxisPercent   = [aDecoder decodeFloatForKey:@"xAxisPercent"];
        _yAxisPercent   = [aDecoder decodeFloatForKey:@"yAxisPercent"];
        _alignCenter    = [aDecoder decodeIntegerForKey:@"alignCenter"];
        _alignSide      = [aDecoder decodeIntegerForKey:@"alignSide"];
        
        _materialRatio  = [aDecoder decodeFloatForKey:@"materialRatio"];
        _actUrl         = [aDecoder decodeObjectForKey:@"actUrl"];
        _material       = [aDecoder decodeObjectForKey:@"material"];
        _expsMonitorUrl = [aDecoder decodeObjectForKey:@"expsMonitorUrl"];
        _expsAdverUrl   = [aDecoder decodeObjectForKey:@"expsAdverUrl"];
        _clickMonitorUrl= [aDecoder decodeObjectForKey:@"clickMonitorUrl"];
        _clickAdverUrl  = [aDecoder decodeObjectForKey:@"clickAdverUrl"];

        _adSwitch       = [aDecoder decodeBoolForKey:@"adSwitch"];
        _dayImpressions = [aDecoder decodeIntegerForKey:@"dayImpressions"];
        _dayImpressionsLimit = [aDecoder decodeIntegerForKey:@"dayImpressionsLimit"];
        _endTimeInterval = [aDecoder decodeFloatForKey:@"endTimeInterval"];
        _startTimeInterval = [aDecoder decodeFloatForKey:@"startTimeInterval"];

        _md5Key     = [aDecoder decodeObjectForKey:@"md5Key"];
        _statPoint     = [aDecoder decodeObjectForKey:@"statPoint"];
        _playTimes  = [aDecoder decodeIntegerForKey:@"playTimes"];
        _displayTimeLength = [aDecoder decodeFloatForKey:@"displayTimeLength"];
        _spaceId    = [aDecoder decodeObjectForKey:@"spaceId"];
        
        _cantSeeInDay       = [aDecoder decodeBoolForKey:@"cantSeeInDay"];
        _limitExposureCount = [aDecoder decodeBoolForKey:@"limitExposureCount"];
        _pageCountArray     = [aDecoder decodeObjectForKey:@"pageCountArray"];
        _lastShowTime       = [aDecoder decodeObjectForKey:@"lastShowTime"];
        
        self.needRefreshResources = [aDecoder decodeBoolForKey:@"needRefreshResources"];
        
    }
    return self;
}
//归档
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeFloat:self.xAxisPercent forKey:@"xAxisPercent"];
    [aCoder encodeFloat:self.yAxisPercent forKey:@"yAxisPercent"];
    [aCoder encodeInteger:self.alignCenter forKey:@"alignCenter"];
    [aCoder encodeInteger:self.alignSide forKey:@"alignSide"];

    [aCoder encodeFloat:self.materialRatio forKey:@"materialRatio"];
    [aCoder encodeObject:self.actUrl forKey:@"actUrl"];
    [aCoder encodeObject:self.material forKey:@"material"];
    [aCoder encodeObject:self.expsMonitorUrl forKey:@"expsMonitorUrl"];
    [aCoder encodeObject:self.expsAdverUrl forKey:@"expsAdverUrl"];
    [aCoder encodeObject:self.clickMonitorUrl forKey:@"clickMonitorUrl"];
    [aCoder encodeObject:self.clickAdverUrl forKey:@"clickAdverUrl"];
    
    [aCoder encodeBool:self.adSwitch forKey:@"adSwitch"];
    [aCoder encodeInteger:self.dayImpressions forKey:@"dayImpressions"];
    [aCoder encodeInteger:self.dayImpressionsLimit forKey:@"dayImpressionsLimit"];

    [aCoder encodeFloat:self.endTimeInterval forKey:@"endTimeInterval"];
    [aCoder encodeFloat:self.startTimeInterval forKey:@"startTimeInterval"];
    [aCoder encodeObject:self.md5Key forKey:@"md5Key"];
    [aCoder encodeObject:self.statPoint forKey:@"statPoint"];

    [aCoder encodeInteger:self.playTimes forKey:@"playTimes"];
    [aCoder encodeFloat:self.displayTimeLength forKey:@"displayTimeLength"];
    [aCoder encodeObject:self.spaceId forKey:@"spaceId"];

    [aCoder encodeBool:_cantSeeInDay forKey:@"cantSeeInDay"];
    [aCoder encodeBool:_limitExposureCount forKey:@"limitExposureCount"];
    [aCoder encodeObject:_pageCountArray forKey:@"pageCountArray"];
    [aCoder encodeObject:_lastShowTime forKey:@"lastShowTime"];
    
    [aCoder encodeBool:self.needRefreshResources forKey:@"needRefreshResources"];
}


@end
