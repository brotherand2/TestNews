//
//  SNChannel.m
//  sohunews
//
//  Created by Cong Dan on 3/22/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNChannel.h"
#import "SNNewsChannelType.h"

#define kCodeChannelName @"kCodeChannelName"
#define kCodeChannelID @"kCodeChannelID"
#define kCodeChannelGbcode @"kCodeChannelGbcode"

@implementation SNChannel

@synthesize channelName;
@synthesize channelId;
@synthesize channelIcon;
@synthesize channelType;
@synthesize channelPosition;
@synthesize channelTop;
@synthesize channelTopTime;
@synthesize isChannelSubed;
@synthesize lastModify;
@synthesize currPosition;
@synthesize localType;
@synthesize isRecom;
@synthesize tips;
@synthesize link;
@synthesize add;
@synthesize tipsInterval;
@synthesize serverVersion;
@synthesize isMixStream;

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.channelName forKey:kCodeChannelName];
    [aCoder encodeObject:self.channelId forKey:kCodeChannelID];
    [aCoder encodeObject:self.gbcode forKey:kCodeChannelGbcode];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.channelName = [aDecoder decodeObjectForKey:kCodeChannelName];
        self.channelId = [aDecoder decodeObjectForKey:kCodeChannelID];
        self.gbcode = [aDecoder decodeObjectForKey:kCodeChannelGbcode];
    }
    return self;
}

/**
 *  设置置顶时间的时候要进行格式转换
 *  by guoyalun
 */
- (void)setChannelTopTime:(NSString *)_channelTopTime
                formatter:(NSString *)formate {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formate];
    NSDate *date = [formatter dateFromString:_channelTopTime];
    if (date) {
        channelTopTime = [NSString stringWithFormat:@"%f", [date timeIntervalSince1970]];
    } else {
        channelTopTime = @"0";
    }
}

- (void)setChannelTopTimeBySeconds:(NSString *)_channelTopTime {
    channelTopTime = _channelTopTime;
}

/**
 * 判断当前的NSChannel的置顶时间是否更新
 * by guoyalun
 */
- (BOOL)isLaterThan:(SNChannel *)other {
    CGFloat thisDate  = [self.channelTopTime floatValue];
    CGFloat otherDate = [other.channelTopTime floatValue];
    
    if (thisDate > otherDate) {
        return YES;
    }
    return NO;
}

- (BOOL)orderChangedByItem:(NewsChannelItem *)item {
    if (![self.channelId isEqualToString:item.channelId]) {
        return YES;
    } else if (![self.isChannelSubed isEqualToString:item.isChannelSubed]) {
        return YES;
    } else if (![self.channelName isEqualToString:item.channelName]) {
        return YES;
    }
    return NO;
}

- (BOOL)isLocalChannel {
    if (self.channelType &&
        [self.channelType isEqualToString:@"5"]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isH5Channel {
    if (self.channelShowType &&
        [self.channelShowType isEqualToString:@"1"]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isHomeChannel {
    BOOL isHome = NO;
    if (self.channelId &&
        [self.channelId isEqualToString:@"1"]) {
        isHome = YES;
    }
    return isHome;
}

- (BOOL)isNewChannel {
    //优先检测服务端返回的isMixStream字段
    if (self.isMixStream > 0) {
        return YES;
    }
    
    if (self.serverVersion &&
        ([self.serverVersion isEqualToString:@"6"])) {
        return YES;
    }
    return NO;
}

- (BOOL)isSurpportNewChannel {
    if (self.channelType &&
        [self.channelType intValue] == NewsChannelTypeNews) {
        return YES;
    }
    return NO;
}

/////////////////////////////////////////////////////////////////
//  NSMutableArray removeObjectsInArray: 
//  requires that all elements in otherArray respond to hash and isEqual:.
/////////////////////////////////////////////////////////////////
- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    SNChannel *c = (SNChannel *)object;
    return [self.channelId isEqualToString:c.channelId];
}

- (NSUInteger)hash {
    return [self.channelId intValue];
}

- (NSComparisonResult)sortChannelList:(SNChannel *)elementChannel {
    int topValue = [self.channelTop intValue];
    int localTypeValue = [elementChannel.localType intValue];
    int currPositionValue = [elementChannel.currPosition intValue];
    if (localTypeValue == 1 && currPositionValue == 0) {
        [SNUserDefaults setObject:[NSNumber numberWithBool:YES] forKey:kLocalChannelSorted];
        if (topValue == 2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    } else {
        return NSOrderedAscending;
    }
}

@end
