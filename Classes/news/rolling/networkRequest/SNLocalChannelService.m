//
//  SNLocalChannelServicer.m
//  sohunews
//
//  Created by lhp on 3/27/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNLocalChannelService.h"
#import "SNChannel.h"
#import "SNUserLocationManager.h"
#import "SNLocalChannelListRequest.h"

@interface SNLocalChannelService ()

@end


@implementation SNLocalChannelService
@synthesize localChannels;
@synthesize searchedChannels;
@synthesize delegate;
@synthesize letterChannels;
@synthesize keyWord;

- (id)init
{
    self = [super init];
    if (self) {
        localChannels = [[NSMutableArray alloc] init];
        searchedChannels = [[NSMutableArray alloc] init];
        letterChannels = [[NSMutableDictionary alloc] init];
        self.originChannelArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setKeyWord:(NSString *)keyWordString
{
    if (keyWordString) {
        [searchedChannels removeAllObjects];
        
        NSMutableArray *allChannelsArray = [NSMutableArray array];
        for (NSArray *array in localChannels) {
            [allChannelsArray addObjectsFromArray:array];
        }
        
        NSPredicate *namePredicate = [NSPredicate predicateWithFormat:@"SELF.channelName contains[cd] %@ ",keyWordString];
        NSArray *filteredArray = [allChannelsArray filteredArrayUsingPredicate:namePredicate];
        if (filteredArray) {
            self.searchedChannels = [NSMutableArray arrayWithArray:filteredArray];
        }
        
        if (delegate && [delegate respondsToSelector:@selector(requestDidFinishLoad)]) {
            [delegate requestDidFinishLoad];
        }
    }
}

- (NSArray *)titleArray
{
    NSMutableArray *titles = [NSMutableArray array];
    [titles addObject:@"当前所在城市"];
    [titles addObject:kHistorySearchCity];
    if (letterChannels.allKeys.count >0) {
        NSArray *keysSorted = [letterChannels.allKeys sortedArrayUsingSelector:@selector(compare:)];
        [titles addObjectsFromArray:keysSorted];
    }
    return titles;
}

- (NSArray *)titleSectionArray
{
    NSMutableArray *titles = [NSMutableArray array];
    [titles addObject:kLocationText];
    [titles addObject:kHistoryText];
    if (letterChannels.allKeys.count >0) {
        NSArray *keysSorted = [letterChannels.allKeys sortedArrayUsingSelector:@selector(compare:)];
        [titles addObjectsFromArray:keysSorted];
    }
    return titles;
}


- (void)sendGetChannelRequest:(NSString *)channelId {
    
    [[[SNLocalChannelListRequest alloc] initWithChannelId:channelId] send:^(SNBaseRequest *request, id rootData) {
        
        NSArray *channelsArray = nil;

        if ([rootData isKindOfClass:[NSDictionary class]]) {
            channelsArray = [rootData objectForKey:kChannel];
        }
        
        if (channelsArray && [channelsArray isKindOfClass:[NSArray class]]) {
            if ([self.originChannelArray count] > 0) {
                [self.originChannelArray removeAllObjects];
            }
            self.originChannelArray = [NSMutableArray arrayWithArray:channelsArray];
            [localChannels removeAllObjects];
            [letterChannels removeAllObjects];
            
            for (NSDictionary *channelDic in channelsArray) {
                SNChannel *channel = [[SNChannel alloc] init];
                channel.channelName = [channelDic objectForKey:kName];
                channel.channelId = [channelDic stringValueForKey:kId defaultValue:@""];
                channel.gbcode = [channelDic stringValueForKey:kGbcode defaultValue:@""];
                
                NSString *letter = [channelDic objectForKey:@"initial"];
                if (letter) {
                    if ([letterChannels objectForKey:letter]) {
                        NSMutableArray *channelsArray = [letterChannels objectForKey:letter];
                        [channelsArray addObject:channel];
                    }else {
                        NSMutableArray *newChannelArray = [NSMutableArray array];
                        [newChannelArray addObject:channel];
                        [letterChannels setObject:newChannelArray forKey:letter];
                    }
                }
                //(channel);
            }
            
            NSArray *keysSorted = [letterChannels.allKeys sortedArrayUsingSelector:@selector(compare:)];
            for (NSString *key in keysSorted) {
                NSMutableArray *channelArray = [letterChannels objectForKey:key];
                [localChannels addObject:channelArray];
            }
        }
        
        if (delegate && [delegate respondsToSelector:@selector(requestDidFinishLoad)]) {
            [delegate requestDidFinishLoad];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        
        if (delegate && [delegate respondsToSelector:@selector(requestDidFinishLoad)]) {
            [delegate requestDidFinishLoad];
        }
    }];
}

- (void)dealloc {
    self.delegate = nil;
}

@end
