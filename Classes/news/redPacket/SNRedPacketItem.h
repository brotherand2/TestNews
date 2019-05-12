//
//  SNRedPacketItem.h
//  sohunews
//
//  Created by wangyy on 16/3/8.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNRedPacketItem : NSObject

@property (nonatomic, copy) NSString *sponsoredIcon;
@property (nonatomic, copy) NSString *sponsoredTitle;
@property (nonatomic, copy) NSString *moneyValue;
@property (nonatomic, copy) NSString *moneyTitle;
@property (nonatomic, assign) int redPacketType; //1普通红包，2任务红包
@property (nonatomic, assign) int redPacketInValid; //0 无效，1有效
@property (nonatomic, copy) NSString *redPacketId;
@property (nonatomic, assign) BOOL showAnimated;    //是否显示红包动画
@property (nonatomic, assign) float delayTime;  //红包动画延迟时间
@property (nonatomic, assign) BOOL isSlideUnlockRedpacket; //是否滑动验证红包
@property (nonatomic, strong) NSString *slideUnlockRedPacketText; //滑动提示语句
@property (nonatomic, strong) NSString *jumpUrl;//任务红包跳转URL
@property (nonatomic, strong) NSString *nid;//红包唯一标记
@end
