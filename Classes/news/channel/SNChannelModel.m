//
//  SNChannelModel.m
//  sohunews
//
//  Created by Cong Dan on 3/22/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNChannelModel.h"
#import "SNDBManager.h"
#import "SNChannelManageContants.h"
#import "SNUserLocationManager.h"
#import "SNUserManager.h"
#import "SNClientRegister.h"
#import "SNExternalLinkHandler.h"
#import "SNSaveChannelListService.h"
#import "SNRollingChannelListRequest.h"
#import "SNRollingNewsPublicManager.h"


@interface SNChannelModel()

@end

@implementation SNChannelModel

@synthesize channels, moreChannels,hasNewChannel = _hasNewChannel,firstLaunch = _firstLaunch;
@synthesize showLogo = _showLogo;
@synthesize icon = _icon;
@synthesize link = _link;

- (id)init {
    if (self = [super init]) {
        self.channels = [NSMutableArray array];
    }
    return self;
}

- (SNChannel *)createChannelByItem:(NewsChannelItem *)item {
    SNChannel *channel = [[SNChannel alloc] init];
    channel.channelCaterotyID = item.channelCategoryID;
    channel.channelCaterotyName = item.channelCategoryName;
    channel.channelId = item.channelId;    
    channel.channelName = item.channelName;
    channel.channelIcon = item.channelIcon;
    channel.channelType = item.channelType;
    channel.channelPosition = item.channelPosition;
    channel.channelTop = item.channelTop;
    [channel setChannelTopTimeBySeconds:item.channelTopTime];
    channel.isChannelSubed = item.isChannelSubed;
    channel.lastModify = item.lastModify;
    channel.currPosition = item.currPosition;
    channel.localType = item.localType;
    channel.isRecom = item.isRecom;
    channel.tips = item.tips;
    channel.link = item.link;
    channel.tipsInterval = item.tipsInterval;
    channel.channelShowType = item.channelShowType;
    channel.channelIconFlag = item.channelIconFlag;
    if ([channel isHomeChannel]) {
        channel.serverVersion = @"6";
    } else {
        channel.serverVersion = item.serverVersion;
    }
    //要闻改版的标志
    channel.isMixStream = item.isMixStream;
    
    return channel;
}

- (void)updateLocalChannel {
    int localIndex = -1;
    
    for (int i = 0; i < [self.channels count]; i++) {
        SNChannel *channel = [self.channels objectAtIndex:i];
        
        if ([channel.channelType isEqualToString:@"5"]) {
            localIndex = i;
            break;
        }
    }
    
    if (localIndex > 0) {
        SNChannel *oldChannel = [self.channels objectAtIndex:localIndex];
        oldChannel.channelName = [SNUserLocationManager sharedInstance].localChannelName;
        oldChannel.gbcode = [SNUserLocationManager sharedInstance].localChannelGBCode;
        if (oldChannel.link != nil && oldChannel.link.length != 0) {
            NSRange range = [oldChannel.link rangeOfString:oldChannel.channelName];
            if (range.location == NSNotFound) {
                oldChannel.link = nil;
            }
        }
        
        [self saveAsCache];
        [self didFinishLoad];
    }
}


- (void)request:(BOOL)bASyn {
    if (![SNUtility isRightP1]) {//确保p1有值
        [[SNClientRegister sharedInstance] registerClientAnywaySuccess:^(SNBaseRequest *request) {
            [self doRequest:bASyn];
        } fail:^(SNBaseRequest *request, NSError *error) {
            [self doRequest:bASyn];
        }];
    } else {
        [self doRequest:bASyn];
    }
}

- (void)doRequest:(BOOL)bASyn {
    NSString *savedChannelIDStrings = [SNUserDefaults objectForKey:kSavedChannelIDStingKey];
    if (savedChannelIDStrings) {
        [SNUserDefaults removeObjectForKey:kSavedChannelIDStingKey];
        return;
    }
    //频道ID
    NSString *upString = [self getUpStrings];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:1];
    if (upString && ![upString isEqualToString:@""]) {
        [params setValue:[upString URLEncodedString] forKey:@"up"];
    } else {
        [params setValue:@"1,2,3,4,5,6" forKey:@"up"];
    }

    [[[SNRollingChannelListRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id rootData) {
        [SNRollingNewsPublicManager sharedInstance].isReloadChannelList = YES;
        if (![request.url containsString:@"p1="]) {
            [SNNotificationManager postNotificationName:kRollingChannelChangedNotification object:[NSNumber numberWithBool:NO]];
            return;
        }
        
        self.moreChannels = [NSMutableArray array];
        id channelData = nil;
        
        if ([rootData isKindOfClass:[NSDictionary class]]) {
            channelData = [rootData objectForKey:kChannelData];
        } else {
            [SNNotificationManager postNotificationName:kRollingChannelChangedNotification object:[NSNumber numberWithBool:NO]];
            return;
        }
        
        self.showLogo = NO;
        NSDictionary *iconDic = [rootData objectForKey:kTopIcon];
        
        if (iconDic && [iconDic isKindOfClass:[NSDictionary class]]) {
            NSString *isShow = [iconDic stringValueForKey:kIsShow defaultValue:@""];
            
            self.icon = [iconDic objectForKey:kIcon];
            self.link = [iconDic objectForKey:kLink];
            
            if (isShow && [isShow isEqualToString:@"1"]) {
                self.showLogo = YES;
            }
        }
        
        if ([channelData isKindOfClass:[NSArray class]]) {
            NSArray *channelArray = (NSArray *)channelData;
            NSString *savedCategoryNames = nil;
            for (NSInteger index = 0;
                 index < [channelArray count]; index ++) {
                NSDictionary *channelInfoDict = [channelArray objectAtIndex:index];
                
                NSArray *channelList = [channelInfoDict objectForKey:kChannelList];
                if ([channelList count] > 0) {
                    for (NSDictionary *channelDict in channelList) {
                        SNChannel *channel = [[SNChannel alloc] init];
                        channel.channelCaterotyName = [channelDict objectForKey:kChannelCategoryName];
                        channel.channelCaterotyID = [channelDict stringValueForKey:kChannelCategoryID defaultValue:@""];;
                        channel.channelIconFlag = [channelDict stringValueForKey:kChannelIconFlag defaultValue:@""];
                        channel.channelName = [channelDict objectForKey:kName];
                        channel.channelId = [channelDict stringValueForKey:kId defaultValue:@""];
                        channel.channelIcon = [channelDict objectForKey:kIcon];
                        channel.channelType = [channelDict stringValueForKey:kType defaultValue:@""];
                        channel.channelPosition = [channelDict objectForKey:kPosition];
                        channel.channelTop = [channelDict stringValueForKey:kTop defaultValue:@"0"];
                        if (index == 0) {
                            channel.currPosition = @"0";//已添加频道
                        } else {
                            channel.currPosition = @"1";//待添加频道
                        }
                        channel.localType = [channelDict stringValueForKey:kLocalType defaultValue:@"0"];
                        [channel setChannelTopTime:[channelDict objectForKey:kTopTime] formatter:@"yyyy-MM-dd HH:mm:ss"];
                        channel.isRecom = [channelDict stringValueForKey:kIsRecomAllowed defaultValue:@""];
                        channel.tipsInterval = [channelDict intValueForKey:kTipsInterval defaultValue:0];
                        channel.link = [channelDict objectForKey:kLink];
                        channel.serverVersion = [channelDict stringValueForKey:kServerVersion defaultValue:@""];
                        channel.channelShowType = [channelDict stringValueForKey:kChannelShowType defaultValue:@""];
                        channel.isMixStream = [channelDict intValueForKey:kIsMixStream defaultValue:0];
                        //频道刷新时间间隔 5.3 wangyy
                        if ([channel.channelId isEqualToString:@"1"]) {
                            NSNumber *interval = (NSNumber *)[channelDict objectForKey:@"interval" defalutObj:nil];
                            [SNUserDefaults setObject:interval forKey:@"kRefreshChannelInterval"];
                            
                            if (channel.isMixStream == 2) {
                                [SNNewsFullscreenManager setFullScreanSwitch:YES];
                            } else {
                                [SNNewsFullscreenManager setFullScreanSwitch:NO];
                            }
                        }
                        
                        [self.moreChannels addObject:channel];
                        
                        //同步置顶区显示的置顶条数
                        if ([channel isNewChannel]) {
                            int topCount = [channelDict intValueForKey:kTopCount defaultValue:1];
                            NSString *key = [NSString stringWithFormat:@"%@_%@", kTopCount, channel.channelId];
                            [SNUserDefaults setInteger:topCount forKey:key];
                        }
                    }
                }
                if (index > 0) {
                    if (!savedCategoryNames) {
                        savedCategoryNames = [channelInfoDict objectForKey:kChannelCategoryName];
                    }
                    else {
                        savedCategoryNames = [savedCategoryNames stringByAppendingFormat:@",%@", [channelInfoDict objectForKey:kChannelCategoryName]];
                    }
                }
            }
            if (savedCategoryNames) {
                [SNUserDefaults setObject:savedCategoryNames forKey:kSavedChannelCategoryKey];
            }
        }
        
        if (self.moreChannels.count > 0) {
            //---Added by Handy：为了让self.channels的数据是由数据库的数据初始化的，
            //这样就可以使得SNChannelModel多实例时，各个实例多次请求接口后merge的数据库的数据都不会影响到其它实例，
            //因为这些个实列都是把数据库的数据(self.channels)和接口数据(self.moreChannels)进行merge;
            [self loadChannelsFromLocalDB];
            //---
            
            if ([[SNExternalLinkHandler sharedInstance] isLoadFromTag]) {
                [SNNotificationManager postNotificationName:kRollingChannelChangedNotification object:[NSNumber numberWithBool:NO]];
                return;
            }
            
            [self removeAllObjects];
            [self addObjectsFromArray:self.moreChannels];
            
            for (int i =0; i < [self.channels count]; i++) {
                SNChannel *channel = [self.channels objectAtIndex:i];
                if ([channel.currPosition isEqualToString:@"0"]) {
                    channel.isChannelSubed = @"1";
                }
                if ([channel.channelType isEqualToString:@"5"]) {
                    if ([channel.channelId isEqualToString:@"-1"]) {
                        [[SNUserLocationManager sharedInstance] clearLocalChannel];
                    }
                }
            }
            
            if ([request.url containsString:@"p1="]) {
                if (![SNUserDefaults integerForKey:kRequestRollingChannelsWithP1]) {
                    [SNUserDefaults setInteger:1 forKey:kRequestRollingChannelsWithP1];
                }
            }
            
            [self saveAsCache];
            [SNNotificationManager postNotificationName:kProcessChannelFromSearchNotification object:nil];
            [SNNotificationManager postNotificationName:kRollingChannelChangedNotification object:[NSNumber numberWithBool:YES]];
            
            // 记录更新时间
            [SNUserDefaults setObject:[NSDate date] forKey:kChannelModelRefreshTime];
            [SNUserDefaults setBool:NO forKey:kLaunchAppKey];
        } else {
            [SNNotificationManager postNotificationName:kRollingChannelChangedNotification object:[NSNumber numberWithBool:NO]];
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        [SNNotificationManager postNotificationName:kRollingChannelChangedNotification object:[NSNumber numberWithBool:NO]];
    }];
}

- (NSString *)getUpStrings {
    if (self.savedIDString.length > 0) {
        return self.savedIDString;
    }
    NSString *upString = nil;
    NSMutableArray *channelListArray = [NSMutableArray array];
    if (channels.count == 0) {
        NSArray *channelList = [[SNDBManager currentDataBase] getNewsChannelList];
        for (NewsChannelItem *item in channelList) {
            SNChannel *channel = [self createChannelByItem:item];
            [channelListArray addObject:channel];
        }
    } else {
        [channelListArray addObjectsFromArray:channels];
    }
    for (SNChannel *channel in channelListArray) {
        if ([channel.isChannelSubed isEqualToString:@"1"]) {
            upString =  !upString?channel.channelId:[upString stringByAppendingFormat:@",%@",channel.channelId];
        }
    }
    
    return upString;
}


- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    [super load:cachePolicy more:more];
    
    if (TTURLRequestCachePolicyLocal == cachePolicy) {
        NSArray *channelList = [[SNDBManager currentDataBase] getNewsChannelList];
        
        for (NewsChannelItem *item in channelList) {
            SNChannel *channel = [self createChannelByItem:item];
            if (channel.channelTopTime&&channel.channelTopTime.length>0) {
                isNotFirst = YES;
            }
            [self addObjectForArray:channel];
        }
        [super requestDidFinishLoad:nil];
    } else {
        [self request:YES];
    }
}

- (NewsChannelItem *)createDBItem:(SNChannel *)channel {
    NewsChannelItem *item = [[NewsChannelItem alloc] init];
    item.channelCategoryName = channel.channelCaterotyName;
    item.channelCategoryID = channel.channelCaterotyID;
    item.channelIconFlag = channel.channelIconFlag;
    item.channelId = channel.channelId;    
    item.channelName = channel.channelName;
    item.channelIcon = channel.channelIcon;
    item.channelType = channel.channelType;
    item.channelPosition = channel.channelPosition;
    item.channelTop = channel.channelTop;
    item.channelTopTime = channel.channelTopTime;
    item.isChannelSubed = channel.isChannelSubed;
    item.lastModify = channel.lastModify;
    item.currPosition = channel.currPosition;
    item.localType = channel.localType;
    item.isRecom = channel.isRecom;
    item.tips = channel.tips;
    item.tipsInterval = channel.tipsInterval;
    item.link = channel.link;
    item.gbcode = channel.gbcode;
    item.serverVersion = channel.serverVersion;
    item.channelShowType = channel.channelShowType;
    item.isMixStream = channel.isMixStream;
    return item;
}

- (void)updateChannels:(NSMutableArray *)items  {
    @autoreleasepool {
        if (items.count > 0) {
            //首先比较用户编辑后有没有发生变化
            NSArray *oldChannelItems = [[SNDBManager currentDataBase] getNewsChannelList];
            BOOL update = NO;
            if (oldChannelItems.count != items.count) {
                update = YES;
            } else {
                for (int i = 0; i < items.count; i++) {
                    NewsChannelItem *item1 = [items objectAtIndex:i];
                    NewsChannelItem *item2 = [oldChannelItems objectAtIndex:i];
                    if ([item1 isChanged:item2]) {
                        update = YES;
                        break;
                    }
                }
            }
            
            [[SNDBManager currentDataBase] setNewsChannelList:items updateTopTime:update];
        }
    }
}

- (void)updateChannelsByRequest:(NSMutableArray *)items {
    @autoreleasepool {
        if (items.count > 0) {
            [[SNDBManager currentDataBase] setNewsChannelList:items updateTopTime:NO];
            isNotFirst = YES;
        }
    }
}

- (BOOL)isChannelChangedIgnoringOrder:(NSMutableArray *)chs {
    BOOL bNeedNotify = NO;
    if (self.channels.count == chs.count) {
        for (int i = 0; i < chs.count; i++) {
            SNChannel *oldChannel = [self.channels objectAtIndex:i];
            SNChannel *newChannel = [chs objectAtIndex:i];
            if (![oldChannel isEqual:newChannel]) {
                bNeedNotify = YES;
                break;
            } else if (![oldChannel.channelName isEqualToString:newChannel.channelName]) {
                bNeedNotify = YES;
                break;
            } else {
                continue;
            }
        }
    } else {
        bNeedNotify = YES;
    }
    return bNeedNotify;
}

- (void)sortChannels {
    NSMutableArray *addChannels = [NSMutableArray arrayWithArray:self.moreChannels];
    [addChannels removeObjectsInArray:self.channels];//用来放新增加的频道
    NSMutableArray *oldChannels = [NSMutableArray arrayWithArray:self.channels];
    [oldChannels removeObjectsInArray:self.moreChannels];//服务器控制要删除的频道

    if (addChannels.count > 0) {
        if ((self.channels.count - oldChannels.count) < kChannelMaxVolum) {
            if ([SNUserDefaults integerForKey:kRequestRollingChannelsWithP1] == 1) {
                self.hasNewChannel = YES;
            }
        }
        [addChannels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SNChannel *channel = (SNChannel *)obj;
            channel.add = YES;
        }];
    }
    
    NSMutableArray *oldSubedChannels = [NSMutableArray arrayWithArray:[self subedChannels]]; // 老的用户选中的频道
    [oldSubedChannels removeObjectsInArray:oldChannels]; // 过滤掉服务器需要删除的频道，剩下选中的频道
    
    NSMutableArray *channelArray = [NSMutableArray arrayWithCapacity:self.moreChannels.count];//用来盛放最终的频道列表
    for (SNChannel *channel  in self.moreChannels) {
        if ([channel.channelTop isEqualToString:@"2"]) {
            //首先添加置顶不可编辑
            channel.isChannelSubed = @"1";
            [channelArray addObject:channel];
        } else if ([channel.channelTop isEqualToString:@"1"]) {
            //其次置顶可编辑的频道
            NSInteger index = [self.channels indexOfObject:channel];
            
            //置顶的频道如果是原有的
            if (index != NSNotFound) {
                SNChannel *tmpChannel = [self.channels objectAtIndex:index];
                if ([channel isLaterThan:tmpChannel]) {
                    channel.isChannelSubed = @"1";
                    [channelArray addObject:channel];
                } else {
                    continue ;
                }
            }
            //置顶的频道如果是新添加的
            else {
                channel.isChannelSubed = @"1";
                if ([channel.currPosition isEqualToString:@"2"]) {
                    channel.isChannelSubed = @"0";
                }
                [channelArray addObject:channel];
            }
        } else {
            break;
        }
    }
    
    //原来选择的频道出去置顶的频道
    [oldSubedChannels removeObjectsInArray:channelArray];
    
    for (SNChannel *channel in oldSubedChannels) {
        NSInteger index = [self.moreChannels indexOfObject:channel];
        SNChannel *newChannel = [self.moreChannels objectAtIndex:index];
        newChannel.isChannelSubed = @"1";
        [channelArray addObject:newChannel];
    }
    
    //addChannels中是新添加的普通的频道
    [addChannels removeObjectsInArray:channelArray];
    
    [self removeAllObjects];
    [self addObjectsFromArray:channelArray];
    for (SNChannel *channel in addChannels) {
        channel.isChannelSubed = @"1";
        if ([channel.currPosition isEqualToString:@"2"]) {
            channel.isChannelSubed = @"0";
        }
        [self addObjectForArray:channel];
    }
    
    if (self.channels.count == 0) {
        SNChannel *channel=[self.moreChannels objectAtIndex:0];
        channel.isChannelSubed = @"1";
    }
    if (self.channels.count > kChannelMaxNum) {
        for (int i = kChannelMaxNum; i < self.channels.count; i++) {
            SNChannel *channel = [self.channels objectAtIndex:i];
            channel.isChannelSubed = @"0";
        }
    }
    
    [self.moreChannels removeObjectsInArray:self.channels];
    [self.channels addObjectsFromArray:self.moreChannels];
}

- (BOOL)mergeNewAndOldChannels {
    self.hasNewChannel = NO;
    NSMutableArray *temp = [NSMutableArray arrayWithArray:self.channels];
    
    BOOL localChannel = NO;
    BOOL channelSorted = NO;
    for (SNChannel *channel in self.moreChannels) {
        if ([channel.currPosition isEqualToString:@"0"] &&
            [channel.localType isEqualToString:@"1"]) {
            localChannel = YES;
        }
    }
    
    //频道请求多次会导致上次请求判断出的新增频道，在下次请求结果比较时变成不是新增的。所以需要传递add属性。
    BOOL hasAdd = NO;
    for (SNChannel *channel in self.moreChannels) {
        if ([self.channels containsObject:channel]) {
            NSUInteger index = [self.channels indexOfObject:channel];
            if (index < [self.channels count]) {
                SNChannel *myChannel = [self.channels objectAtIndex:index];
                channel.add = myChannel.add;
                if (myChannel.add) {
                    hasAdd = YES;
                }
            }
        }
    }
    if (hasAdd) {
        self.hasNewChannel = YES;
    }
    
    if (!isNotFirst) {
        self.firstLaunch = YES;
    }
    if (isNotFirst && [SNUserDefaults boolForKey:kChannelEdit]) {
        [self sortChannels];
    }
    else if([SNUserDefaults boolForKey:kChannelCloudSyn])
    {
        [self sortChannels];
    }
    else //如果用户首次运行，则直接用服务器端的数据进行覆盖，顺序都和服务端保持一直
    {
        if (localChannel) {
            channelSorted = YES;
            [self.moreChannels sortUsingSelector:NSSelectorFromString(@"sortChannelList:")];// 此处代码有崩溃
        }

        for (int i = 0; i < self.moreChannels.count; i++) {
            if (i < kChannelMaxNum) {
                SNChannel *channel=[self.moreChannels objectAtIndex:i];
                channel.isChannelSubed = @"1";
                if ([channel.currPosition isEqualToString:@"2"]) {
                    channel.isChannelSubed = @"0";
                }
                
            } else {
                break;
            }
        }
        if (isNotFirst) {
            [self.moreChannels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (![self.channels containsObject:obj]) {
                    if (idx<kChannelMaxVolum) {
                        self.hasNewChannel = YES;
                    }
                    [(SNChannel *)obj setAdd:YES];
                }
            }];
        }
        [self removeAllObjects];
        [self addObjectsFromArray:self.moreChannels];
   }
    
    while (self.channels.count > kChannelMaxVolum) {
        @synchronized (channels) {
            [self.channels removeLastObject];
        }
    }
   
    //如果存在tab中的本地频道
    if (![SNUserDefaults objectForKey:kLocalChannelSorted] && localChannel) {
        for (SNChannel *channel in self.channels) {
            if ([channel.currPosition isEqualToString:@"0"] && [channel.localType isEqualToString:@"1"]) {
                channel.isChannelSubed = @"1";
            }
        }
        channelSorted = YES;
        [self.channels sortUsingSelector:NSSelectorFromString(@"sortChannelList:")]; // 此处代码有崩溃
        [self cacheChannelsInMutiThread];
    }
    
    BOOL bNeedNotify = [self isChannelChangedIgnoringOrder:temp];
    if (localChannel && channelSorted) {
        bNeedNotify = YES;
    }
    
    return bNeedNotify;
}

- (void)saveAsCache {
    NSMutableArray *items = [NSMutableArray array];
    for (SNChannel *channel in self.channels) {
        [items addObject:[self createDBItem:channel]];
    }

    [self updateChannelsByRequest:items];
}

#pragma mark -
- (void)loadChannelsFromLocalDB {
    NSArray *channelList = [[SNDBManager currentDataBase] getNewsChannelList];
    for (NewsChannelItem *item in channelList) {
        SNChannel *channel = [self createChannelByItem:item];
        if (channel.channelTop&&channel.channelTop.length>0) {
            isNotFirst = YES;
        }
    }
}

- (void)cacheChannelsInMutiThread {
    NSMutableArray *items = [NSMutableArray array];
    for (SNChannel *channel in self.channels) {
        [items addObject:[self createDBItem:channel]];
    }
    [self updateChannels:items];
}

- (NSArray *)unsubedChannels {
    NSMutableArray *tmpArray = [NSMutableArray array];
    @synchronized (channels) {
        for (SNChannel *ch in self.channels) {
            if ([ch.isChannelSubed isEqualToString:@"0"]) {
                [tmpArray addObject:ch];
            }
        }
    }
    
    return [NSArray arrayWithArray:tmpArray];
}

- (NSArray *)subedChannels {
    NSMutableArray *tmpArray = [NSMutableArray array];
    @synchronized (channels) {
        for (SNChannel *ch in self.channels) {
            if ([ch.isChannelSubed isEqualToString:@"1"]) {
                [tmpArray addObject:ch];
            }
        }
    }

    return [NSArray arrayWithArray:tmpArray];
}

//数组保护
- (void)removeAllObjects {
    @synchronized (channels) {
        [self.channels removeAllObjects];
    }
}

- (void)addObjectsFromArray:(NSArray *)array {
    @synchronized (channels) {
        [self.channels addObjectsFromArray:array];
    }
}

- (void)addObjectForArray:(SNChannel *)channel {
    @synchronized (channels) {
        [self.channels addObject:channel];
    }
}
- (void)removeObjectFromArray:(SNChannel *)channel {
    @synchronized (channels) {
        [self.channels removeObject:channel];
    }
}

@end
