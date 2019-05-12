//
//  SNChannelManageViewV2.h
//  sohunews
//
//  Created by jojo on 13-10-14.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNChannelManageObject.h"
#import "SNChannelManageContants.h"

@interface SNChannelManageViewV2 : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL hasEditedChannel;
@property (nonatomic, strong) NSMutableArray *subedChannels;
@property (nonatomic, strong) NSMutableArray *unsubedChannels;
@property (nonatomic, strong) NSMutableArray *otherChannels;
@property (nonatomic, strong) NSMutableArray *localChannels;
@property (nonatomic, copy) NSString *currentSelectedChannelId;
@property (nonatomic, assign) BOOL shouldHideLocalsChannel; // 视频频道编辑是暂时不需要本地频道的类型的  总感觉这么不太好
@property (nonatomic, assign) BOOL isNotNewsTab; //非新闻tab

- (void)setSubedArray:(NSArray *)subedArray andUnsubedArray:(NSArray *)unsubedArray isRollingNewsTab:(BOOL)isRollingNewsTab;
- (NSArray *)subedArray;
- (NSArray *)unsubedArray;

@end

@protocol SNChannelManageViewV2Delegate <NSObject>

@optional
- (void)channelManageViewDidSelectChannel:(SNChannelManageObject *)channelObject;
- (void)channelManageViewWillClose:(SNChannelManageViewV2 *)channelManageView;

@end
