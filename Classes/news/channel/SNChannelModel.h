//
//  SNChannelModel.h
//  sohunews
//
//  Created by Cong Dan on 3/22/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNChannel;
@interface SNChannelModel : TTURLRequestModel {
    NSMutableArray *channels;
    NSMutableArray *moreChannels;
    SNURLRequest *_request;
    BOOL            isNotFirst;
    BOOL           _hasNewChannel;
    BOOL           _firstLaunch;
    BOOL           _showLogo;
    NSString       *_icon;
    NSString       *_link;
}

@property(nonatomic, strong)NSMutableArray *channels;
@property(nonatomic, strong)NSMutableArray *moreChannels;
@property(nonatomic, assign)BOOL            hasNewChannel;
@property(nonatomic, assign)BOOL            firstLaunch;
@property(nonatomic, assign)BOOL            showLogo;
@property(nonatomic, strong)NSString       *icon;
@property(nonatomic, strong)NSString       *link;
@property (nonatomic, strong) NSString *savedIDString;

- (void)cacheChannelsInMutiThread;
- (NSArray *)subedChannels;
- (NSArray *)unsubedChannels;
- (SNChannel *)createChannelByItem:(NewsChannelItem *)item;
- (void)updateLocalChannel;

//数组保护
- (void)removeAllObjects;
- (void)addObjectsFromArray:(NSArray *)array;
- (void)addObjectForArray:(SNChannel *)channel;
- (void)removeObjectFromArray:(SNChannel *)channel;

@end
