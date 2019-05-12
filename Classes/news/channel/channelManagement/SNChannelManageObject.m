//
//  SNChannelManageObject.m
//  sohunews
//
//  Created by jojo on 13-10-15.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNChannelManageObject.h"
#import "SNVideoChannelObjects.h"

@implementation SNChannelManageObject
@synthesize ID, name, isSubed;
@synthesize localType;
@synthesize objType;
@synthesize orignalObj;
@synthesize channelTop;
@synthesize addNew;
@synthesize channelViewClassString = _channelViewClassString;
@synthesize serverVersion = _serverVersion;
@synthesize isMixStream = _isMixStream;

- (id)initWithObj:(id)obj type:(SNChannelManageObjType)type {
    self = [super init];
    if (self) {
        self.objType = type;
        self.orignalObj = obj;
        switch (type) {
            case SNChannelManageObjTypeChannel: {
                if ([obj isKindOfClass:[SNChannel class]]) {
                    SNChannel *channel = (SNChannel *)obj;
                    self.channelCategoryName = channel.channelCaterotyName;
                    self.channelCategoryID = channel.channelCaterotyID;
                    self.channelIconFlag = channel.channelIconFlag;
                    self.ID = channel.channelId;
                    self.name = channel.channelName;
                    self.isSubed = channel.isChannelSubed;
                    self.channelTop=channel.channelTop;
                    self.localType = channel.localType;
                    self.channelType = channel.channelType;
                    self.serverVersion = channel.serverVersion;
                    self.channelShowType = channel.channelShowType;
                    self.isMixStream = channel.isMixStream;
                    break;
                }
            }
            case SNChannelManageObjTypeCategory: {
                if ([obj isKindOfClass:[CategoryItem class]]) {
                    CategoryItem *item = (CategoryItem *)obj;
                    self.ID = item.categoryID;
                    self.name = item.name;
                    self.isSubed = item.isSubed;
                    self.channelTop=item.top;
                    break;
                }
            }
            case SNChannelManageObjTypeWeibo: {
                if ([obj isKindOfClass:[WeiboHotChannelItem class]]) {
                    WeiboHotChannelItem *weiboChannel = (WeiboHotChannelItem *)obj;
                    self.ID = weiboChannel.channelId;
                    self.name = weiboChannel.channelName;
                    self.isSubed = weiboChannel.isChannelSubed;
                    self.channelTop = weiboChannel.channelTop;
                    break;
                }
            }
            case SNChannelManageObjTypeVideo: {
                if ([obj isKindOfClass:[SNVideoChannelObject class]]) {
                    SNVideoChannelObject *ch = (SNVideoChannelObject *)obj;
                    self.ID = ch.channelId;
                    self.name = ch.title;
                    self.isSubed = ch.up;
                    if (ch.sortable.length > 0) {
                        self.channelTop = (![ch.sortable isEqualToString:@"1"] ? @"2" : @"");
                    }
                    break;
                }
            }
            default: {
                self.ID = @"";
                self.name = @"";
                self.isSubed = @"";
                break;
            }
        }
    }
    
    return self;
}

- (void)dealloc {
}

- (BOOL)isEqual:(id)object {
    BOOL ret = NO;
    if ([object isKindOfClass:[SNChannelManageObject class]]) {
        if ([(SNChannelManageObject *)object objType] == self.objType) {
            if ([[(SNChannelManageObject *)object ID] isEqualToString:self.ID]) {
                ret = YES;
            }
        }
    }
    return ret;
}

- (NSUInteger)hash {
    return [self.ID integerValue];
}

@end
