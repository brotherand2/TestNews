//
//  SNVideoObjects.m
//  sohunews
//
//  Created by chenhong on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNVideoObjects.h"
#import "SNVideoAd.h"
#import "STADManagerForNews.h"
#import "SNStatisticsManager.h"
#import "NSJSONSerialization+String.h"
#import "JSONKit.h"

@implementation SNVideoAuthor


- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self updateWithDict:dict];
    }
    return self;
}

- (void)updateWithDict:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        self.name   = [dict stringValueForKey:@"name" defaultValue:nil];
        self.type   = [dict intValueForKey:@"type" defaultValue:0];
        self.icon   = [dict stringValueForKey:@"icon" defaultValue:nil];
        self.subId  = [NSString stringWithFormat:@"%d",[dict intValueForKey:@"subId" defaultValue:0]];
    }
}

@end

@implementation SNVideoUrl


- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self updateWithDict:dict];
    }
    return self;
}

- (void)updateWithDict:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        self.m3u8   = [dict stringValueForKey:@"m3u8" defaultValue:nil];
        self.mp4    = [dict stringValueForKey:@"mp4" defaultValue:nil];
        self.mp4s   = [dict arrayValueForKey:@"mp4s" defaultValue:nil];
    }
}

- (NSString *)toJsonString {
    NSString *m3u8 = self.m3u8.length > 0 ? self.m3u8 : @"";
    NSString *mp4 = self.mp4.length > 0 ? self.mp4 : @"";
    NSString *mp4s = self.mp4s.count > 0 ? [self.mp4s JSONString] : @"[]";
    return [NSString stringWithFormat:@"{\"m3u8\":\"%@\", \"mp4\":\"%@\", \"mp4s\":%@}", m3u8, mp4, mp4s];
}

@end

@implementation SNVideoShare

- (void)dealloc {
     //(_content);
     //(_h5Url);
     //(_weixinContent);
}

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self updateWithDict:dict];
    }
    return self;
}

- (void)updateWithDict:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        self.content = [dict stringValueForKey:@"content" defaultValue:nil];
        self.h5Url = [dict stringValueForKey:@"h5Url" defaultValue:nil];
        self.weixinContent = [dict stringValueForKey:@"weixinContent" defaultValue:nil];
        self.ugcWordLimit = [dict intValueForKey:@"ugcWordLimit" defaultValue:0];
    }
}

@end

@implementation SNVideoSiteInfo

- (void)dealloc {
     //(_site);
     //(_site2);
     //(_siteId);
     //(_siteName);
     //(_adServer);
     //(_playById);
     //(_playAd);
}

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        [self updateWithDict:dict];
    }
    return self;
}

- (void)updateWithDict:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        self.site = [NSString stringWithFormat:@"%d", [dict intValueForKey:@"site" defaultValue:0]];
        self.site2 = [NSString stringWithFormat:@"%d", [dict intValueForKey:@"site2" defaultValue:0]];
        self.siteId = [dict stringValueForKey:@"siteId" defaultValue:nil];
        self.siteName = [dict stringValueForKey:@"siteName" defaultValue:nil];
        self.adServer = [dict stringValueForKey:@"adServer" defaultValue:nil];
        self.playById = [NSString stringWithFormat:@"%d", [dict intValueForKey:@"playById" defaultValue:0]];
        self.playAd = [NSString stringWithFormat:@"%d", [dict intValueForKey:@"playAd" defaultValue:0]];
    }
}

@end

@implementation SNVideoListInfo


- (void)updateWithDict:(NSDictionary *)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        self.count      = [dict intValueForKey:@"count" defaultValue:0];
        self.totalCount = [dict intValueForKey:@"totalCount" defaultValue:0];
        self.nextCursor = [dict longlongValueForKey:@"nextCursor" defaultValue:0];
        self.preCursor  = [dict stringValueForKey:@"preCursor" defaultValue:nil];
        self.hasnext    = [dict intValueForKey:@"hasnext" defaultValue:0];
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////SNVideoData///////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
@interface SNVideoData()

//////////////////////////////////Extended for timeline
//---App换量相关
@property(nonatomic, copy, readwrite)NSString      *appContent;
//---

//////////////////////////////////Extended for videoplayer


//////////////////////////////////Extended for download

@end
#pragma mark - Video数据对象集
#pragma mark - SNVideoData
@implementation SNVideoData

//////////////////////////////////Extended for videoplayer
- (id)init {
    self = [super init];
    if (self) {
        self.totalTimeMap = [NSMutableDictionary dictionary];
        self.playedTimeMap = [NSMutableDictionary dictionary];
        _isNewsVideo = NO;
    }
    return self;
}

//////////////////////////////////Extended for timeline
- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            self.totalTimeMap = [NSMutableDictionary dictionary];
            self.playedTimeMap = [NSMutableDictionary dictionary];
            
            self.vid        = [dict stringValueForKey:@"vid" defaultValue:nil];
            self.messageId  = [dict stringValueForKey:@"id" defaultValue:nil];
            self.title      = [dict stringValueForKey:@"title" defaultValue:@"无标题"];
            self.abstract   = [dict stringValueForKey:@"content" defaultValue:nil];
            self.columnName = [dict stringValueForKey:@"columnName" defaultValue:nil];
            self.link2      = [dict stringValueForKey:@"link2" defaultValue:nil];
            
            self.poster     = [dict stringValueForKey:@"pic" defaultValue:nil];
            self.poster_4_3 = [dict stringValueForKey:@"pic_4_3" defaultValue:nil];
            self.smallImageUrl  = [dict stringValueForKey:@"smallPic" defaultValue:nil];
            self.wapUrl         = [dict stringValueForKey:@"url" defaultValue:nil];
            self.videoUrl   = [[SNVideoUrl alloc] initWithDict:dict[@"playurl"]];
            self.author     = [[SNVideoAuthor alloc] initWithDict:dict[@"author"]];
            self.share      = [[SNVideoShare alloc] initWithDict:dict[@"share"]];
            self.siteInfo   = [[SNVideoSiteInfo alloc] initWithDict:dict[@"siteInfo"]];
            
            self.type       = [dict intValueForKey:@"type" defaultValue:0];
            self.status     = [dict intValueForKey:@"status" defaultValue:0];
            self.columnId   = [dict intValueForKey:@"columnId" defaultValue:0];
            self.duration   = [dict intValueForKey:@"duration" defaultValue:0];
            self.action     = [dict intValueForKey:@"action" defaultValue:0];
            self.playType   = [dict intValueForKey:@"playType" defaultValue:0];
            self.playCount  = [dict intValueForKey:@"playCount" defaultValue:0];
            self.downloadType = [dict intValueForKey:@"download" defaultValue:0];
            
            self.templatePicUrl = [dict stringValueForKey:@"templatePic" defaultValue:nil];
            self.multipleType = [dict intValueForKey:@"multipleType" defaultValue:0];
            
            self.mediaLink = [dict stringValueForKey:@"mediaLink" defaultValue:nil];//视频媒体页
            self.templateType = [dict stringValueForKey:kTemplateType defaultValue:@""];
            self.uninterestInterval = [dict intValueForKey:@"no_interest_inteval" defaultValue:0];
            
            //---App换量相关--------------------------------------------------------
            if (self.multipleType == TimelineVideoType_AppBanner) {
                self.bannerImgURLOfOpenApp = [dict stringValueForKey:kTimelineAppContent_IconOpen defaultValue:nil];
                self.bannerImgURLOfDownloadApp = [dict stringValueForKey:kTimelineAppContent_IconDownload defaultValue:nil];
                self.bannerImgURLOfUpgradeApp = [dict stringValueForKey:kTimelineAppContent_IconUpgrade defaultValue:nil];
                self.appDownloadLink = [dict stringValueForKey:kTimelineAppContent_AppDownloadLink defaultValue:nil];
                self.appIdOfAppWillBeOpen = [dict stringValueForKey:kTimelineAppContent_AppIdOfAppWillBeOpen defaultValue:nil];
                self.appURLSchemaOfAppWillBeOpen = [dict stringValueForKey:kTimelineAppContent_AppURLSchemaOfAppWillBeOpen defaultValue:nil];
                self.appContent = [NSString stringWithFormat:
                                   @"{\
                                   \"%@\":\"%@\",\
                                   \"%@\":\"%@\",\
                                   \"%@\":\"%@\",\
                                   \"%@\":\"%@\",\
                                   \"%@\":\"%@\",\
                                   \"%@\":\"%@\"\
                                   }",
                                   kTimelineAppContent_IconOpen, self.bannerImgURLOfOpenApp,
                                   kTimelineAppContent_IconDownload, self.bannerImgURLOfDownloadApp,
                                   kTimelineAppContent_IconUpgrade, self.bannerImgURLOfUpgradeApp,
                                   kTimelineAppContent_AppDownloadLink, self.appDownloadLink,
                                   kTimelineAppContent_AppIdOfAppWillBeOpen, self.appIdOfAppWillBeOpen,
                                   kTimelineAppContent_AppURLSchemaOfAppWillBeOpen, self.appURLSchemaOfAppWillBeOpen];
            }
            //---------------------------------------------------------------------
            
            NSDictionary* banerDic = [dict objectForKey:@"banner"];
            if([banerDic isKindOfClass:[NSDictionary class]])
            {
                self.bannerString = [NSJSONSerialization stringWithJSONObject:banerDic
                                                                      options:NSJSONWritingPrettyPrinted
                                                                        error:NULL];
                //[banerDic JSONStringWithOptions:JKSerializeOptionValidFlags error:nil];
                SNVideoBannerData* banner = [[SNVideoBannerData alloc] initWithDic:banerDic];
                self.banerData = banner;
            }
            NSArray* entryArray = [dict objectForKey:@"entry"];
            if([entryArray isKindOfClass:[NSArray class]])
            {
                self.entryString = [NSJSONSerialization stringWithJSONObject:entryArray
                                                                     options:NSJSONWritingPrettyPrinted
                                                                       error:NULL];
                //[entryArray JSONStringWithOptions:JKSerializeOptionValidFlags error:nil];
                NSMutableArray* array = [NSMutableArray arrayWithCapacity:6];
                for(NSDictionary* entryDic in entryArray)
                {
                    if([entryDic isKindOfClass:[NSDictionary class]])
                    {
                        SNVideoEntryData* entry = [[SNVideoEntryData alloc] initWithDic:entryDic];
                        [array addObject:entry];
                    }
                }
                self.entryData = array;
            }
        }
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [[(SNVideoData *)object messageId] isEqualToString:self.messageId];
}

- (NSUInteger)hash {
    return [self.messageId integerValue];
}

//////////////////////////////////Extended for videoplayer
- (NSTimeInterval)totalTime {
    NSTimeInterval _all = 0;
    for (NSString *_key in self.totalTimeMap.allKeys) {//key是视频片段的order
        _all += [[self.totalTimeMap valueForKey:_key] doubleValue];
    }
    return _all;
}

- (NSTimeInterval)playedTime {
    NSTimeInterval _all = 0;
    for (NSString *_key in self.playedTimeMap.allKeys) {//key是视频片段的order
        _all += [[self.playedTimeMap valueForKey:_key] doubleValue];
    }
    return _all;
}

- (void)setTitle:(NSString *)title {
    if (!!title && title != _title) {
        _title = nil;
        _title = title;
        
        //计算高度
        if (self.title.length <= 0) {
            _recommendCellHeight = 0;
        }
        else {
            CGSize _size = CGSizeMake(kWSMVRecommendVideoTableViewWidth-kWSMVRecommendVideoCellHeadlineLabelMarginLeft
                                      -kWSMVRecommendVideoCellHeadlineLabelMarginRight,
                                      NSIntegerMax);
            CGSize _actualSize = [self.title sizeWithFont:
                                  [UIFont systemFontOfSize:kWSMVRecommendVideoCellHeadlineLabelFontSize] constrainedToSize:_size];
            _recommendCellHeight = _actualSize.height;
            if (_recommendCellHeight > 36) {//字号为14的情况下，两行文字的总高度是36
                _recommendCellHeight = 36;
            }
        }
        _recommendCellHeight += (kWSMVRecommendVideoCellHeadlineLabelMarginTop+kWSMVRecommendVideoCellHeadlineLabelMarginBottom);
    }
}

- (NSString *)subtitle {
    //1社交媒体、3搜狐视频推荐
    if (self.author.type == VideoAuthorType_SocialMedia || self.author.type == VideoAuthorType_SohuRecommend) {
        self.subtitle    = self.author.name;
    }
    //0机构自媒体、2个人自媒体
    else {
        if (self.columnName.length <= 0) {
            self.subtitle    = self.author.name;
        }
        else if (self.author.name.length <= 0) {
            self.subtitle    = self.columnName;
        }
        else {
            self.subtitle    = [NSString stringWithFormat:@"%@ 来自 %@", self.columnName, self.author.name];
        }
    }
    
    return _subtitle;
}

- (NSMutableArray *)sources {
    if (self.videoUrl.m3u8.length > 0) {
        self.sources = [NSMutableArray arrayWithObject:self.videoUrl.m3u8];
    }
    else if (self.videoUrl.mp4s.count > 0) {
        NSMutableArray *_tmpArray = [self.videoUrl.mp4s mutableCopy];
        self.sources = _tmpArray;
         //(_tmpArray);
    }
    else if (self.videoUrl.mp4.length > 0) {
        self.sources = [NSMutableArray arrayWithObject:self.videoUrl.mp4];
    }
    
    return _sources;
}

- (void)uploadLoadStatistics:(NSString*)fromId
{
    if(self.multipleType != 3)
        return;
    SNStatLoadInfo* info = [[SNStatLoadInfo alloc] init];
    info.objFrom = @"video";
    info.objFromId = fromId;
    info.objType = @"3";
    info.objLabel = SNStatInfoUseTypeTimelinePopularize;
    NSMutableArray* objid = [NSMutableArray arrayWithCapacity:6];
    if(self.banerData.bannerId)
    {
        [objid addObject:self.banerData.bannerId];
    }
    if(self.entryData)
    {
        for(SNVideoEntryData* entry in self.entryData)
        {
            if(entry.entryId)
                [objid addObject:entry.entryId];
        }
    }
    info.adIDArray = objid;
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}

- (void)uploadDisplayStatistics:(NSString*)fromId;
{
    if(self.multipleType != 3)
        return;
    SNStatExposureInfo* info = [[SNStatExposureInfo alloc] init];
    info.objFrom = @"video";
    info.objType = @"3";
    info.objLabel = SNStatInfoUseTypeTimelinePopularize;
    info.objFromId = fromId;
    NSMutableArray* objid = [NSMutableArray arrayWithCapacity:6];
    if(self.banerData.bannerId)
    {
        [objid addObject:self.banerData.bannerId];
    }
    if(self.entryData)
    {
        for(SNVideoEntryData* entry in self.entryData)
        {
            if(entry.entryId)
                [objid addObject:entry.entryId];
        }
    }
    info.adIDArray = objid;
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}

- (void)uploadClickStatistics:(NSString*)dataId fromId:(NSString *)fromId;
{
    if(self.multipleType != 3)
        return;
    SNStatClickInfo* info = [[SNStatClickInfo alloc] init];
    info.objFrom = @"video";
    info.objType = @"3";
    info.objFromId = fromId;
    info.objLabel = SNStatInfoUseTypeTimelinePopularize;
    info.adIDArray = [NSArray arrayWithObjects:dataId, nil];
    [[SNStatisticsManager shareInstance] uploadStaticsEvent:info];
}


//////////////////////////////////
- (void)dealloc {
    _title = nil;
    
    //////////////////////////////////Extended for timeline
    
    //////////////////////////////////Extended for videoplayer

    
    
    
     //(_entryData);
     //(_banerData);
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////SNVideoDataDownload///////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - SNVideoDataDownload
@implementation SNVideoDataDownload
- (id)init {
    self = [super init];
    if (self) {
        self.state = SNVideoDownloadState_Waiting;
        self.eachSegmentDownloadBytes   = [NSMutableDictionary dictionary];
        self.eachSegmentTotalBytes      = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.vid = nil;
}

- (void)setDownloadProgress:(CGFloat)downloadProgress {
    _downloadProgress = downloadProgress;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    //Do nothing
    SNDebugLog(@"INFO: Property %@ doesnt exist in %@", key, NSStringFromClass(self.class));
}

- (NSString *)description {
    return [NSString stringWithFormat:@"title:%@, vid: %@, videoSources:%@, downloadURL:%@, videoType:%@, localRelativePath:%@, localM3U8URL:%@, eachSegmentDownloadBytes:%@, eachSegmentTotalBytes:%@, downloadBytes:%f, totalBytes:%f, downloadProgress:%f",
            self.title, self.vid, self.videoSources, self.downloadURL, self.videoType, self.localRelativePath, self.localM3U8URL, self.eachSegmentDownloadBytes, self.eachSegmentTotalBytes, self.downloadBytes, self.totalBytes, self.downloadProgress];
}

@end

@implementation SNVideoBannerData

- (id)initWithDic:(NSDictionary*)dic
{
    self = [super init];
    if(self)
    {
        [self parseFromDic:dic];
    }
    return self;
}

- (void)dealloc
{
     //(_title);
     //(_iconOpen);
     //(_iconDown);
     //(_appDownloadLink);
     //(_appId);
     //(_urlScheme);
     //(_version);
}

- (void)parseFromDic:(NSDictionary*)dic
{
    self.title = [dic stringValueForKey:@"title" defaultValue:nil];
    self.iconOpen = [dic stringValueForKey:@"iconOpen" defaultValue:nil];
    self.iconDown = [dic stringValueForKey:@"iconDown" defaultValue:nil];
    self.appDownloadLink = [dic stringValueForKey:@"appDownloadLink" defaultValue:nil];
    self.appId = [dic stringValueForKey:@"appId" defaultValue:nil];
    self.urlScheme = [dic stringValueForKey:@"urlScheme" defaultValue:nil];
    self.version = [dic stringValueForKey:@"sersion" defaultValue:nil];
    self.bannerId = [dic stringValueForKey:@"id" defaultValue:nil];
}
@end

@implementation SNVideoEntryData

- (id)initWithDic:(NSDictionary*)dic
{
    self = [super init];
    if(self)
    {
        [self parseFromDic:dic];
    }
    return self;
}
- (void)dealloc
{
     //(_title);
     //(_icon);
     //(_urlScheme);
     //(_appId);
     //(_version);
     //(_appDownloadLink);
     //(_link);
}

- (void)parseFromDic:(NSDictionary*)dic
{
    self.title = [dic stringValueForKey:@"title" defaultValue:nil];
    self.icon = [dic stringValueForKey:@"icon" defaultValue:nil];
    self.urlScheme = [dic stringValueForKey:@"urlScheme" defaultValue:nil];
    self.version = [dic stringValueForKey:@"version" defaultValue:nil];
    self.appId = [dic stringValueForKey:@"appId" defaultValue:nil];
    self.appDownloadLink = [dic stringValueForKey:@"appDownloadLink" defaultValue:nil];
    self.entryId = [dic stringValueForKey:@"id" defaultValue:nil];
    self.linkType = [dic intValueForKey:@"linkType" defaultValue:0];
    self.link = [dic stringValueForKey:@"link" defaultValue:nil];
}
@end
