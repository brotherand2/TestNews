//
//  SNLiveContentObjects.m
//  sohunews
//
//  Created by Chen Hong on 12-6-14.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNLiveContentObjects.h"
#import "NSDictionaryExtend.h"
#import "SNUserManager.h"
#import "SNVideoConst.h"

@implementation SNLiveContentMatchInfoObject

- (void)updateByLiveGameItem:(LivingGameItem *)livingGameItem {
    self.homeTeamTitle       = livingGameItem.hostName;
    self.visitingTeamTitle   = livingGameItem.visitorName;
    self.homeTeamScore       = livingGameItem.hostTotal;
    self.visitingTeamScore   = livingGameItem.visitorTotal;
    self.homeTeamIconURL     = livingGameItem.hostPic;
    self.visitingTeamIconURL = livingGameItem.visitorPic;
    self.homeTeamInfoURL     = livingGameItem.hostInfo;
    self.visitingTeamInfoURL = livingGameItem.visitorInfo;
    self.matchTitle          = livingGameItem.title;
    self.liveTime            = livingGameItem.liveTime;
    self.liveType            = livingGameItem.liveType;
    self.liveStatus          = livingGameItem.status;
}

- (void)updateByLiveInfoDictonary:(NSDictionary *)info {
    self.homeTeamTitle       = [info objectForKey:@"hostTeam"];
    self.visitingTeamTitle   = [info objectForKey:@"visitorTeam"];
    self.homeTeamScore       = [NSString stringWithFormat:@"%d", [[info objectForKey:@"hostTotal"] intValue]];
    self.visitingTeamScore   = [NSString stringWithFormat:@"%d", [[info objectForKey:@"vistorTotal"] intValue]];
    self.homeTeamIconURL     = [info objectForKey:@"hostIcon"];
    self.visitingTeamIconURL = [info objectForKey:@"visitorIcon"];
    self.matchTitle          = [info objectForKey:@"title"];
    self.liveTime            = [info objectForKey:@"liveDate"];
    self.liveType            = [NSString stringWithFormat:@"%d", [[info objectForKey:@"liveType"] intValue]];
    self.liveStatus          = [NSString stringWithFormat:@"%d", [[info objectForKey:@"liveStatus"] intValue]];
    self.liveStatistics      = [info stringValueForKey:@"statistics" defaultValue:nil];
    self.statisticsType      = [NSString stringWithFormat:@"%d", [[info objectForKey:@"statisticsType"] intValue]];
    self.homeTeamSupportNum  = [NSString stringWithFormat:@"%d", [info intValueForKey:@"hostSupport" defaultValue:0]];
    self.visitingTeamSupportNum = [NSString stringWithFormat:@"%d", [info intValueForKey:@"vistorSupport" defaultValue:0]];
    self.onlineCount         = [NSString stringWithFormat:@"%d", [info intValueForKey:@"oneLineCount" defaultValue:1]];
    self.shareContent        = [info stringValueForKey:@"shrCont" defaultValue:nil];
    
    self.needLogin           = [info intValueForKey:@"needLogin" defaultValue:0];
    self.comtStatus          = [info intValueForKey:@"comtStatus" defaultValue:0];
    self.comtHint            = [info stringValueForKey:@"comtHint" defaultValue:nil];
    self.catId               = [info stringValueForKey:@"catId" defaultValue:nil];
    self.subCatId            = [info stringValueForKey:@"subCatId" defaultValue:nil];
    self.statisticsUrl       = [info stringValueForKey:@"statisticsUrl" defaultValue:nil];
    
    self.isWorldCup          = (_subCatId && [_subCatId intValue] == 133);
    
    self.pubType             = [info stringValueForKey:@"pubType" defaultValue:@"0"];
    
    // 初始化角色数据
    self.allRoles = nil;
    NSArray *allRoles = [info arrayValueForKey:@"allRoles" defaultValue:nil];
    for (NSDictionary *dict in allRoles) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            SNLiveRoomRole *role = [[SNLiveRoomRole alloc] initWithDict:dict];
            if (!self.allRoles) {
                self.allRoles = [NSMutableArray arrayWithCapacity:allRoles.count];
            }
            [self.allRoles addObject:role];
        }
    }
    
    // 置顶数据
    NSDictionary *topObj = [info objectForKey:@"topInfo" ofClass:[NSDictionary class] defaultObj:nil];
    //NSDictionary *topObj = @{@"top":@"测试top", @"topLink":@"live://3456"};
    if (topObj) {
        self.top = [[SNLiveRoomTopObject alloc] init];
        self.top.top = [[topObj stringValueForKey:@"top" defaultValue:nil] trim];
        self.top.topImage = [topObj stringValueForKey:@"topImage" defaultValue:nil];
        self.top.topLink = [topObj stringValueForKey:@"topLink" defaultValue:nil];
    } else {
        self.top = nil;
    }
    
    // 直播数据
    NSDictionary *mediaInfo = [info objectForKey:@"mediaInfo" ofClass:[NSDictionary class] defaultObj:nil];
    if (mediaInfo.count > 0) {
        if (self.mediaObj == nil) {
            self.mediaObj = [[SNLiveRoomMediaObject alloc] init];
        }
        
        [self.mediaObj updateWithDict:mediaInfo];
    } else {
        self.mediaObj = nil;
    }

    // 界面控制
    NSDictionary *ctrlInfo = [info objectForKey:@"ctrlInfo" ofClass:[NSDictionary class] defaultObj:nil];
    if (ctrlInfo.count > 0) {
        self.ctrlInfo = [[SNLiveRoomControlInfo alloc] initWithDict:ctrlInfo];
    } else {
        self.ctrlInfo = nil;
    }
}


- (BOOL)isMediaLiveMode {
    if (_mediaObj) {
        return (_mediaObj.mediaType == LiveMediaVideo ||
                _mediaObj.mediaType == LiveMediaSound);
    }
    return NO;
}

- (BOOL)isForbiddenAudio {
    return (_comtStatus == 1 || _comtStatus == 2 || _comtStatus == 4);
}

- (BOOL)isForbiddenPic {
    return (_comtStatus == 1 || _comtStatus == 3 || _comtStatus == 4);
}

- (BOOL)hasH5Statistics {
    return (_statisticsUrl && _statisticsUrl.length > 0);
}

@end

#pragma mark -
@implementation SNLiveRoomTopObject
@synthesize top, topImage, topLink;


- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SNLiveRoomTopObject *topObj = (SNLiveRoomTopObject *)object;
    
    return (((topObj.top == nil && top == nil) || [topObj.top isEqualToString:top]) &&
            ((topObj.topImage == nil && topImage == nil) || [topObj.topImage isEqualToString:topImage]) &&
            ((topObj.topLink == nil && topLink == nil) || [topObj.topLink isEqualToString:topLink]));
}

- (NSUInteger)hash {
    return top.length + topImage.length + topLink.length;
}

@end

#pragma mark -
@implementation SNLiveRoomRole
@synthesize rName, nColor, dColor;

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.rName  = [dict stringValueForKey:@"rName" defaultValue:nil];
        self.nColor = [dict stringValueForKey:@"nColor" defaultValue:nil];
        self.dColor = [dict stringValueForKey:@"nColor" defaultValue:nil];
    }
    return self;
}


@end

#pragma mark -
@implementation SNLiveRoomControlInfo

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.compAudLen  = [dict intValueForKey:@"compAudLen" defaultValue:60];
        self.inputShowType = [dict intValueForKey:@"inputShowType" defaultValue:0];
    }
    return self;
}

@end

#pragma mark -
@implementation SNLiveRoomReplyObject

@synthesize commentId, rid, author, createTime, content, mergeType, imgUrl, showAllReplyContent, contentH1, contentH2;


@end

#pragma mark -
@implementation SNLiveRoomMediaObject


- (void)updateWithDict:(NSDictionary *)dict {
    self.mediaTitle = [dict stringValueForKey:@"mediaTitle" defaultValue:nil];
    self.mediaImage = [dict stringValueForKey:@"mediaImage" defaultValue:nil];
    self.mediaUrl = [dict stringValueForKey:@"mediaUrl" defaultValue:nil];
    self.mediaSize = [dict stringValueForKey:@"mediaSize" defaultValue:nil];
    self.mediaLength = [dict stringValueForKey:@"mediaLength" defaultValue:nil];
    self.mediaType = [dict intValueForKey:@"mediaType" defaultValue:0];
    self.displayMode = [dict intValueForKey:@"mDispMode" defaultValue:0];
    
    self.site = [dict stringValueForKey:SNVideoConst_kSite defaultValue:nil];
    self.site2 = [dict stringValueForKey:SNVideoConst_kSite2 defaultValue:nil];
    self.siteName = [dict stringValueForKey:SNVideoConst_kSiteName defaultValue:nil];
    self.siteId = [dict stringValueForKey:SNVideoConst_kSiteId defaultValue:nil];
    self.playById = [dict stringValueForKey:SNVideoConst_kPlayById defaultValue:nil];
    self.playAd = [dict stringValueForKey:SNVideoConst_kPlayAd defaultValue:nil];
    self.adServer = [dict stringValueForKey:SNVideoConst_kAdServer defaultValue:nil];
    self.vid = [dict stringValueForKey:SNVideoConst_kVid defaultValue:nil];
}

@end

#pragma mark -
@implementation SNLiveRoomAuthorInfo
@synthesize authorimg, passport, spaceLink, pid, linkStyle, gender, role, signList;

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.authorimg   = [dict stringValueForKey:@"authorimg" defaultValue:nil];
        self.passport    = [dict stringValueForKey:@"passport" defaultValue:nil];
        self.spaceLink   = [dict stringValueForKey:kSpaceLink defaultValue:nil];
        self.pid         = [dict stringValueForKey:kPid defaultValue:nil];
        self.linkStyle   = [dict objectForKey:@"linkStyle"];
        self.gender      = [dict intValueForKey:@"gen" defaultValue:0];
        self.role        = [dict intValueForKey:@"role" defaultValue:UINT8_MAX];
                
        self.signList   = [dict arrayValueForKey:@"signList" defaultValue:nil];
    }
    return self;
}


- (BOOL)isLogin {
    return (passport.length > 0);
}

@end

#pragma mark -
@implementation SNLiveRoomBaseObject
@synthesize authorInfo=_authorInfo;


@end

#pragma mark -
@implementation SNLiveContentObject

@synthesize author, action, actionTeam, actionTime, contentId, contentPic, contentPicSmall, hostScore, visitorScore, /*isKeyEvent,*/ quarter;
@synthesize link, replyComment, replyContent, mediaInfo, showAllContent, contentH1, contentH2,contentPicLink;

- (BOOL)hasSound {
    return (mediaInfo.mediaType == LiveMediaSound && mediaInfo.mediaUrl.length > 0);
}

- (BOOL)hasVideo {
    return ((mediaInfo.mediaType == LiveMediaVideo) && mediaInfo.mediaUrl.length > 0);
}

- (BOOL)hasGIF {
    return (mediaInfo.mediaType == LiveMediaGIF);
}

- (BOOL)hasReply {
    return (replyComment && replyComment.author.length && (replyComment.content.length ||
            replyComment.imageUrl.length || replyComment.audUrl.length));
}

- (BOOL)hasReplyCont {
    return (replyContent && replyContent.author.length);
}


@end

#pragma mark -
@implementation SNLiveCommentObject

@synthesize commentId, author, createTime, content, imageUrl, rid, audUrl, audLen;
@synthesize replyComment, replyContent, showAllComment, contentH1, contentH2;



- (BOOL)hasReply {
    return (replyComment && replyComment.author.length && (replyComment.content.length || replyComment.imageUrl.length || replyComment.audUrl.length));
}

- (BOOL)hasReplyCont {
    return (replyContent && replyContent.author.length);
}

- (BOOL)hasSound {
    return (audUrl.length > 0);
}

- (BOOL)isMyComment {
    NSString *passport = [SNUserManager getUserId];
    if (passport.length > 0 && _authorInfo.passport.length > 0) {
        return [passport isEqualToString:_authorInfo.passport];
    }
    
    NSString *nickName = [SNUserManager getNickName];
    if (nickName!=nil && [nickName length] > 0) {
        return [nickName isEqualToString:author];
    } else {
        return NO;
    }
}

@end



@implementation SNLiveRollAdContentObject

-(id)init
{
    self = [super init];
    if (self) {
        _adInfo = [[SNAdLiveInfo alloc] init];
    }
    return self;
}


@end

