//
//  SNChannelScrollTabItem.h
//  sohunews
//
//  Created by Cong Dan on 4/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNChannelScrollTabBar;

@interface SNChannelScrollTabItem : NSObject
{
    NSString* _title;
    NSString* _channelId;
    NSString* _isRecom;
    NSString* _tips;
    int _tipsInterval;
    BOOL _isLocalChannel;
    SNChannelScrollTabBar* _tabBar;
}

@property (nonatomic, copy)   NSString* title;
@property (nonatomic, copy)   NSString* channelId;
@property (nonatomic, copy)   NSString* isRecom;
@property (nonatomic, copy)   NSString* tips;
@property (nonatomic, assign) int tipsInterval;
@property (nonatomic, assign) BOOL isLocalChannel;

- (id)initWithTitle:(NSString*)title channelId:(NSString *)channelId;

@end
