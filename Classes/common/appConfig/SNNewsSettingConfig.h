//
//  SNCameraConfig.h
//  sohunews
//
//  Created by H on 16/5/26.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

//要闻改版相关配置
@interface SNNewsSettingConfig : NSObject
- (NSInteger)getNewsSaveDays;
- (NSInteger)getNewsPullTimes;
- (NSString *)getNewsDefaultEnterChannelID;

- (NSString *)getSourceWordBgColourTransparency;
- (NSString *)getNewsGradientBgTransparency;
- (NSString *)getSplitLineTransparency;
- (NSString *)getNewsRegionImageTransparency;
- (NSString *)getBottomSplitLineTransparency;

- (NSString *)getNewsBgColour;
- (NSString *)getNewsWorldColour;
- (NSString *)getNewsSourceWordColour;
- (NSString *)getNewsSourceWordBgColour;
- (NSString *)getNewsCommentWordColour;
- (NSString *)getNewsRegionImage;
- (NSString *)getNewsGradientBgColour;
- (NSString *)getNewsSplitLineColor;
- (NSString *)getNewsWordClickedColour;

//夜间
- (NSString *)getNight_NewsWorldColour;
- (NSString *)getNight_NewsBgColour;
- (NSString *)getNight_NewsSourceWordColour;
- (NSString *)getNight_NewsSourceWordBgColour;
- (NSString *)getNight_NewsCommentWordColour;
- (NSString *)getNight_NewsRegionImage;
- (NSString *)getNight_NewsGradientBgColour;
- (NSString *)getNight_NewsSplitLineColor;
- (NSString *)getNight_NewsWordClickedColour;

- (void)updateWithDic:(NSDictionary *)dic;
@end
