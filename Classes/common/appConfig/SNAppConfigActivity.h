//
//  SNAppConfigActivity.h
//  sohunews
//
//  Created by chenhong on 14-5-14.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNAppConfigActivity : NSObject

@property(nonatomic, strong) NSArray *activityOpenChannels;//活动的频道，这个值是频道的id，每个频道以“，”分割
@property(nonatomic, copy) NSString *activityPulldownStr;//下拉的文案
@property(nonatomic, copy) NSString *activityShotBeforeStr;//射门前的文案

@property(nonatomic, strong) NSArray *activityShotFailStrArray;//射门后未射中的文案，这个是根据实际情况有多种文案，每个文案以“|”分割，需要客户端根据文案的个数，取随机的一个
@property(nonatomic, copy) NSString *activityShotFailIcon;//射门后未射中的一个icon
@property(nonatomic, copy) NSString *activityShotFailBtnName;//射门后未射中的一个link按钮名称
@property(nonatomic, copy) NSString *activityShotFailShareIcon;//未射中分享的icon
@property(nonatomic, copy) NSString *activityShotFailShareStr;//未射中分享的文案
@property(nonatomic, copy) NSString *activityShotFailShareLink;
@property(nonatomic, copy) NSString *activityShotFailShareTitle;
@property(nonatomic, copy) NSString *activityBgImgUrl;//背景图片url

- (void)updateWithDic:(NSDictionary *)configDic;

@end
