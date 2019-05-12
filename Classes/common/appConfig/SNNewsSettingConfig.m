//
//  SNCameraConfig.m
//  sohunews
//
//  Created by H on 16/5/26.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNNewsSettingConfig.h"
#import "SNAppConfigConst.h"
#import "NSDictionaryExtend.h"
/*
 "smc.client.focus.theme": "{
 "gradientBgTransparency": "0",//渐变背景色透明度
 "sourceWordBgColourTransparency": "0.6",//来源字背景色透明度
 "newsWordColour": "FFFFFF",//文本新闻字色
 "newsBgColour": "#343434",//文本新闻背景色
 "sourceWordColour": "#FFFFFF",//来源字色
 "sourceWordBgColour": "#E42000",//来源字背景色
 "commentWordColour": "#FFFFFF",//评论字色
 "newsRegionImage": "#656565",//文本新闻区域原点
 "gradientBgColour": "#343434",//渐变背景色
 "splitLineColor": "#656565"//分割线背景色
 
 "night_newsWordColour": "#808080",//文本新闻夜间色
 "night_newsBgColour": "#242424",//文本新闻背景夜间色
 "night_sourceWordColour": "#969696",//来源夜间色
 "night_sourceWordBgColour": "#862718",//来源背景夜间色
 "night_commentWordColour": "#969696",//评论夜间色
 "night_newsRegionImage": "#656565",//文本新闻区域原点夜间色
 "night_gradientBgColour": "#242424",//渐变背景夜间色
 "night_splitLineColor": "#656565"//分割线背景夜间色
 @"newsWordClickedColour"
 @"night_newsWordClickedColour"
}"
 
 "smc.client.secondStart.channelId": "1",    //第二次进入客户端的默认频道
 "smc.client.history.saveDays": "3",            //阅读历史保留量
 "smc.client.history.pullTimes": "7",        //上拉刷新多少次出历史记录
 */

@interface SNNewsSettingConfig() {
    NSInteger _pSNSaveDays;
    NSInteger _pSNPullTimes;
    NSString *_pSNDefaultEnterChannelID;
    
    NSString *_pSNSourceWordBgColourTransparency;
    NSString *_pSNGradientBgTransparency;
    NSString *_pSNSplitLineTransparency;
    NSString *_pSNNewsRegionImageTransparency;
    NSString *_pSNBottomSplitLineTransparency;
    
    NSString *_pSNNewsWordColour;
    NSString *_pSNNewsBgColour;
    NSString *_pSNSourceWordColour;
    NSString *_pSNSourceWordBgColour;
    NSString *_pSNCommentWordColour;
    NSString *_pSNNewsRegionImage;
    NSString *_pSNGradientBgColour;
    NSString *_pSNSplitLineColor;
    NSString *_pSNewsWordClickedColour;
    
    NSString *_pNight_SNNewsWordColour;
    NSString *_pNight_SNNewsBgColour;
    NSString *_pNight_SNSourceWordColour;
    NSString *_pNight_SNSourceWordBgColour;
    NSString *_pNight_SNCommentWordColour;
    NSString *_pNight_SNNewsRegionImage;
    NSString *_pNight_SNGradientBgColour;
    NSString *_pNight_SNSplitLineColor;
    NSString *_pNight_SNewsWordClickedColour;
}
@end

@implementation SNNewsSettingConfig
- (instancetype)init {
    if (self = [super init]) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSNumber *tSaveDays = [userDefault valueForKey:kNewsSaveDays];
        if (tSaveDays) {
            _pSNSaveDays = [tSaveDays integerValue];
        } else {
            _pSNSaveDays = 3;
        }
        
        NSNumber *tPullTimes = [userDefault valueForKey:kNewsPullTimes];
        if (tPullTimes) {
            _pSNPullTimes = [tPullTimes integerValue];
        } else {
            _pSNPullTimes = 7;
        }

        NSString *tDefaultEnterChannelID = [userDefault valueForKey:kNewsDefaultEnterChannelID];
        if (tDefaultEnterChannelID) {
            _pSNDefaultEnterChannelID = tDefaultEnterChannelID;
        } else {
           _pSNDefaultEnterChannelID = @"1";
        }
    }
    return self;
}

- (NSInteger)getNewsSaveDays {
    return _pSNSaveDays;
}

- (NSInteger)getNewsPullTimes {
    return _pSNPullTimes;
}

- (NSString *)getNewsDefaultEnterChannelID {
    return _pSNDefaultEnterChannelID;
}

- (NSString *)getBottomSplitLineTransparency {
    return _pSNBottomSplitLineTransparency;
}

- (NSString *)getSourceWordBgColourTransparency {
    return _pSNSourceWordBgColourTransparency;
}

- (NSString *)getNewsGradientBgTransparency {
    return _pSNGradientBgTransparency;
}

- (NSString *)getSplitLineTransparency {
    return _pSNSplitLineTransparency;
}

- (NSString *)getNewsRegionImageTransparency {
    return _pSNNewsRegionImageTransparency;
}

- (NSString *)getNewsWorldColour {
    return _pSNNewsWordColour;
}

- (NSString *)getNewsBgColour {
    return _pSNNewsBgColour;
}

- (NSString *)getNewsSourceWordColour {
    return _pSNSourceWordColour;
}

- (NSString *)getNewsSourceWordBgColour {
    return _pSNSourceWordBgColour;
}

- (NSString *)getNewsCommentWordColour {
    return _pSNCommentWordColour;
}

- (NSString *)getNewsRegionImage {
    return _pSNNewsRegionImage;
}

- (NSString *)getNewsGradientBgColour {
    return _pSNGradientBgColour;
}

- (NSString *)getNewsSplitLineColor {
    return _pSNSplitLineColor;
}

- (NSString *)getNewsWordClickedColour {
    return _pSNewsWordClickedColour;
}

//夜间
- (NSString *)getNight_NewsWorldColour {
    return _pNight_SNNewsWordColour;
}

- (NSString *)getNight_NewsBgColour {
    return _pNight_SNNewsBgColour;
}

- (NSString *)getNight_NewsSourceWordColour {
    return _pNight_SNSourceWordColour;
}

- (NSString *)getNight_NewsSourceWordBgColour {
    return _pNight_SNSourceWordBgColour;
}

- (NSString *)getNight_NewsCommentWordColour {
    return _pNight_SNCommentWordColour;
}

- (NSString *)getNight_NewsRegionImage {
    return _pNight_SNNewsRegionImage;
}

- (NSString *)getNight_NewsGradientBgColour {
    return _pNight_SNGradientBgColour;
}

- (NSString *)getNight_NewsSplitLineColor {
    return _pNight_SNSplitLineColor;
}

- (NSString *)getNight_NewsWordClickedColour {
    return _pNight_SNewsWordClickedColour;
}

- (void)updateWithDic:(NSDictionary *)dic {
    _pSNSaveDays = [dic intValueForKey:kNewsSaveDays defaultValue:_pSNSaveDays];
    _pSNPullTimes = [dic intValueForKey:kNewsPullTimes defaultValue:_pSNPullTimes];
    _pSNDefaultEnterChannelID = [dic stringValueForKey:kNewsDefaultEnterChannelID
                                    defaultValue:_pSNDefaultEnterChannelID];
    
    //存储默认值
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithInteger:_pSNSaveDays] forKey:kNewsSaveDays];
    [userDefault setObject:[NSNumber numberWithInteger:_pSNPullTimes] forKey:kNewsPullTimes];
    [userDefault setObject:_pSNDefaultEnterChannelID forKey:kNewsDefaultEnterChannelID];
    
    NSDictionary *theme = [dic valueForKey:kNewsTheme];
    if (theme.count > 0) {
        _pSNGradientBgTransparency = [theme stringValueForKey:kNewsThemeGradientBgTransparency
                                                defaultValue:nil];
        _pSNSourceWordBgColourTransparency = [theme stringValueForKey:kNewsThemeSourceWordBgColourTransparency
                                                        defaultValue:nil];
        _pSNBottomSplitLineTransparency = [theme stringValueForKey:kNewsThemeBottomSplitLineTransparency defaultValue:nil];
        _pSNSplitLineTransparency = [theme stringValueForKey:kNewsThemeSplitLineTransparency
                                                defaultValue:nil];
        _pSNNewsRegionImageTransparency = [theme stringValueForKey:kNewsThemeNewsRegionImageTransparency
                                                      defaultValue:nil];
        
        _pSNNewsBgColour = [theme stringValueForKey:kNewsThemeNewsBgColour
                                      defaultValue:nil];
        _pSNNewsWordColour = [theme stringValueForKey:kNewsThemeWordColour
                                        defaultValue:nil];
        _pSNSourceWordColour = [theme stringValueForKey:kNewsThemeSourceWordColour
                                          defaultValue:nil];
        _pSNSourceWordBgColour = [theme stringValueForKey:kNewsThemeSourceWordBgColour
                                            defaultValue:nil];
        _pSNCommentWordColour = [theme stringValueForKey:kNewsThemeCommentWordColour
                                           defaultValue:nil];
        _pSNNewsRegionImage = [theme stringValueForKey:kNewsThemeNewsRegionImage
                                         defaultValue:nil];
        _pSNGradientBgColour = [theme stringValueForKey:kNewsThemeGradientBgColour
                                          defaultValue:nil];
        _pSNSplitLineColor = [theme stringValueForKey:kNewsThemeSplitLineColor
                                               defaultValue:nil];
        _pSNewsWordClickedColour = [theme stringValueForKey:kNewsThemeWordClickedColour
                                               defaultValue:nil];
        
        //夜间
        _pNight_SNNewsBgColour = [theme stringValueForKey:kNightNewsThemeNewsBgColour
                                            defaultValue:nil];
        _pNight_SNNewsWordColour = [theme stringValueForKey:kNightNewsThemeWordColour
                                              defaultValue:nil];
        _pNight_SNSourceWordColour = [theme stringValueForKey:kNightNewsThemeSourceWordColour
                                                defaultValue:nil];
        _pNight_SNSourceWordBgColour = [theme stringValueForKey:kNightNewsThemeSourceWordBgColour
                                                  defaultValue:nil];
        _pNight_SNCommentWordColour = [theme stringValueForKey:kNightNewsThemeCommentWordColour
                                                 defaultValue:nil];
        _pNight_SNNewsRegionImage = [theme stringValueForKey:kNightNewsThemeNewsRegionImage
                                               defaultValue:nil];
        _pNight_SNGradientBgColour = [theme stringValueForKey:kNightNewsThemeGradientBgColour
                                                defaultValue:nil];
        _pNight_SNSplitLineColor = [theme stringValueForKey:kNightNewsThemeSplitLineColor
                                                     defaultValue:nil];
        _pNight_SNewsWordClickedColour = [theme stringValueForKey:kNightNewsThemeWordClickedColour
                                                     defaultValue:nil];
    }
}

@end
