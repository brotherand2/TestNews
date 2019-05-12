//
//  CacheObjects.m
//  CacheMgr
//
//  Created by 李 雪 on 11-6-13.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CacheObjects.h"
#import "NSObject+YAJL.h"
#import "GTMNSString+HTML.h"

@implementation SubscribeItem

@synthesize ID;
@synthesize pubTypeName;
@synthesize subId;
@synthesize subType;
@synthesize pubId;
@synthesize pubName;
@synthesize pubIcon;
@synthesize pubType;
@synthesize pubPush;
@synthesize termId;
@synthesize termTime;
@synthesize lastTermLink;
@synthesize orderIndex;
@synthesize iconPath;
@synthesize status;
@synthesize noReadCount;
@synthesize noReadTermIds;
@synthesize defaultSub;
@synthesize downloaded;

- (id)copyWithZone:(NSZone *)zone {
	SubscribeItem *newItem = [[[self class] alloc] init];
	newItem.ID = self.ID;
	newItem.pubTypeName = self.pubTypeName;
	newItem.subId = self.subId;
    newItem.subType = self.subType;
	newItem.pubId = self.pubId;
	newItem.pubName = self.pubName;
	newItem.pubIcon = self.pubIcon;
	newItem.pubType = self.pubType;
	newItem.pubPush = self.pubPush;
	newItem.termId = self.termId;
    newItem.termTime = self.termTime;
	newItem.lastTermLink = self.lastTermLink;
	newItem.orderIndex = self.orderIndex;
	newItem.iconPath = self.iconPath;
	newItem.status = self.status;
	newItem.noReadCount = self.noReadCount;
	newItem.noReadTermIds = self.noReadTermIds;
	newItem.defaultSub = self.defaultSub;
    newItem.downloaded = self.downloaded;
	return newItem;
}

- (NSString *)toString {
    NSMutableString *_s = [[NSMutableString alloc] init];
    [_s appendFormat:SN_String("ID:%d, pubTypeName:%@, subId:%@, subType:%@, pubId:%@, pubName:%@, pubIcon:%@, pubType:%@, pubPush:%@, termId:%@, lastTermLink:%@, orderIndex:%@, iconPath:%@, status:%@, noReadCount:%@, noReadTermIds:%@, defaultSub:%@, downloaded:%@"), self.ID, self.pubTypeName, self.subId, self.subType, self.pubId, self.pubName, self.pubIcon, self.pubType, self.pubPush, self.termId, self.lastTermLink, self.orderIndex, self.iconPath, self.status, self.noReadCount, self.noReadTermIds, self.defaultSub, self.downloaded];
    return _s;
}



@end

@implementation SubscribeHomeImageItem
@synthesize ID;
@synthesize subId;
@synthesize pubId;
@synthesize termId;
@synthesize src;
@synthesize link;
@synthesize date;
@synthesize termName;
@synthesize pubName;
@synthesize termType;
@synthesize title;
@synthesize path;
@synthesize noReadCount;
@synthesize noReadTermIds;
@synthesize orderIndex;

- (id)copyWithZone:(NSZone *)zone {
	SubscribeHomeImageItem *newItem = [[[self class] alloc] init];
	newItem.ID = self.ID;
	newItem.subId = self.subId;
	newItem.pubId = self.pubId;
	newItem.termId	= self.termId;
	newItem.src = self.src;
	newItem.link = self.link;
	newItem.date = self.date;
	newItem.termName = self.termName;
	newItem.pubName = self.pubName;
	newItem.termType = self.termType;
	newItem.title = self.title;
	newItem.path = self.path;
	newItem.noReadCount = self.noReadCount;
	newItem.noReadTermIds = self.noReadTermIds;
	newItem.orderIndex	= self.orderIndex;
	return newItem;
}
@end

@implementation NewspaperItem
@synthesize ID;
@synthesize subId;
@synthesize pubId;
@synthesize termId;
@synthesize termName;
@synthesize pushName;
@synthesize termTitle;
@synthesize termLink;
@synthesize termZip;
@synthesize termTime;
@synthesize newspaperPath;
@synthesize readFlag;
@synthesize downloadFlag;
@synthesize downloadTime;
@synthesize normalLogo;
@synthesize nightLogo;
@synthesize publishTime;

//Transient property
@synthesize isEditMode;
//Transient property
@synthesize isSelected;

- (NSString *)realNewspaperPath {
    //注意:在进行覆盖安装的时候绝对路径会发生变化,,9082A3CC-637F-4C00-9AB6-E7C40F36D316会发生变化，所以要进行下面处理
    ///var/mobile/Applications/9082A3CC-637F-4C00-9AB6-E7C40F36D316/Library/Caches/Newspaper/12858/20120914/23722_10_0_9_0_31_5_74/mpaperhome_1_23722_1.html
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    
    NSRange range=[newspaperPath rangeOfString:@"/Newspaper"];
    if (range.location != NSNotFound) {
        NSString *realPath = [newspaperPath stringByReplacingCharactersInRange:NSMakeRange(0, range.location) withString:cacheDirectory];
        return realPath;
    }
    return newspaperPath;
}


@end

@implementation NewsArticleItem

@synthesize ID;
@synthesize channelId;
//@synthesize pubId;
@synthesize newsId;
@synthesize termId;
@synthesize type;
@synthesize title;
@synthesize newsMark;
@synthesize originFrom;
@synthesize originTitle;
@synthesize time;
@synthesize updateTime;
@synthesize from = source;
@synthesize commentNum;
@synthesize digNum;
@synthesize content;
@synthesize link;
@synthesize readFlag;
@synthesize nextName;
@synthesize nextId;
@synthesize nextNewsLink;
@synthesize nextNewsLink2;
@synthesize preName;
@synthesize preId;
@synthesize shareContent;
@synthesize shareImages;
@synthesize thumbnailImages;
@synthesize createAt;
@synthesize subId;
@synthesize cmtStatus;
@synthesize cmtHint;
@synthesize logoUrl;
@synthesize linkUrl;
@synthesize favour;
@synthesize tagChannelsStr;
@synthesize stocksStr;


- (NSString *)tagChannelsStr
{
    if (nil == _tagChannels || _tagChannels.count == 0) {
        return @"[]";
    }
    
    NSMutableArray *dbArray = [NSMutableArray array];
    
    for (NewsTagChannelItem *item in _tagChannels) {
        [dbArray addObject:@{@"name":item.name, @"link":item.link}];
    }
    
    NSData *tagChannelsData = [NSJSONSerialization dataWithJSONObject:dbArray options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:tagChannelsData encoding:NSUTF8StringEncoding];
}

- (void)setTagChannelsStr:(NSString *)tagChannelsS
{
    if (nil == tagChannelsS || tagChannelsS.length == 0)
    {
        self.tagChannels = [[NSMutableArray alloc] init];
    }
    else
    {
        NSArray *dbArray = [NSJSONSerialization JSONObjectWithData:[tagChannelsS dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *channels = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dic in dbArray) {
            NewsTagChannelItem *item = [[NewsTagChannelItem alloc] init];
            
            item.name = dic[@"name"];
            item.link = dic[@"link"];
            
            [channels addObject:item];
        }
        
        self.tagChannels = channels;
    }
}

- (NSString *)stocksStr
{
    if (nil == _stocks || _stocks.count == 0) {
        return @"[]";
    }
    
    NSMutableArray *dbArray = [NSMutableArray array];
    
    for (NewsStockItem *item in _stocks) {
        [dbArray addObject:@{@"name":item.name, @"link":item.link}];
    }
    
    NSData *stocksData = [NSJSONSerialization dataWithJSONObject:dbArray options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:stocksData encoding:NSUTF8StringEncoding];
}

- (void)setStocksStr:(NSString *)stocksS
{
    if (nil == stocksS || stocksS.length == 0)
    {
        self.stocks = [[NSMutableArray alloc] init];
    }
    else
    {
        NSArray *dbArray = [NSJSONSerialization JSONObjectWithData:[stocksS dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSMutableArray *stocksArr = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dic in dbArray) {
            NewsStockItem *item = [[NewsStockItem alloc] init];
            
            item.name = dic[@"name"];
            item.link = dic[@"link"];
            
            [stocksArr addObject:item];
        }
        
        self.stocks = stocksArr;
    }
}


@end


@implementation NewsImageItem

@synthesize ID;
@synthesize termId;
@synthesize newsId;
@synthesize imageId;
@synthesize type;
@synthesize time;
@synthesize link;
@synthesize url;
@synthesize path;
@synthesize title;
@synthesize width;
@synthesize height;
@synthesize createAt;
@synthesize imgRect;


@end

@implementation NewsTagChannelItem

@synthesize name;
@synthesize link;


@end

@implementation NewsStockItem

@synthesize name;
@synthesize link;


@end

@implementation NewsChannelItem

@synthesize ID;
@synthesize channelCategoryName;
@synthesize channelCategoryID;
@synthesize channelIconFlag;
@synthesize channelName = name;
@synthesize channelId = channelID;
@synthesize channelIcon;
@synthesize channelType;
@synthesize channelPosition;
@synthesize channelTop;
@synthesize channelTopTime;
@synthesize isChannelSubed;
@synthesize lastModify;
@synthesize isSelected;
@synthesize downloadStatus = _downloadStatus;
@synthesize subId;
@synthesize currPosition;
@synthesize localType;
@synthesize isRecom;
@synthesize tips;
@synthesize link;
@synthesize tipsInterval;
@synthesize channelStatusDelete;
@synthesize serverVersion;
@synthesize channelShowType;
@synthesize isMixStream;

- (id)copyWithZone:(NSZone *)zone {
	NewsChannelItem *newPO = [[[self class] alloc] init];
	newPO.ID = self.ID;
    newPO.channelCategoryName = self.channelCategoryName;
    newPO.channelCategoryID = self.channelCategoryID;
    newPO.channelIconFlag = self.channelIconFlag;
    newPO.channelName = self.channelName;
	newPO.channelId = self.channelId;
	newPO.channelIcon = self.channelIcon;
	newPO.channelType = self.channelType;
	newPO.channelPosition = self.channelPosition;
   	newPO.channelTop = self.channelTop;
	newPO.channelTopTime = self.channelTopTime;
   	newPO.isChannelSubed = self.isChannelSubed;
   	newPO.lastModify = self.lastModify;
	newPO.isSelected = self.isSelected;
    newPO.downloadStatus = self.downloadStatus;
    newPO.subId = self.subId;
    newPO.channelStatusDelete = self.channelStatusDelete;
    newPO.serverVersion = self.serverVersion;
    newPO.channelShowType = self.channelShowType;
    newPO.isMixStream = self.isMixStream;

	return newPO;
}

-(BOOL)isChanged:(NewsChannelItem *)item
{
    if (self.isChannelSubed == nil) {
        self.isChannelSubed = @"0";
    }
    if (item.isChannelSubed == nil) {
        item.isChannelSubed = @"0";
    }
    if (![self.channelId isEqualToString:item.channelId]) {
        return YES;
    } else if (![self.isChannelSubed isEqualToString:item.isChannelSubed]){
        return YES;
    }
    return NO;
}


@end

@implementation WeiboHotChannelItem

- (BOOL)isLaterThan:(WeiboHotChannelItem *)other {
    CGFloat thisDate  = [self.channelTopTime floatValue];
    CGFloat otherDate = [other.channelTopTime floatValue];
    
    if (thisDate > otherDate) {
        return YES;
    }
    return NO;
}

- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [[(WeiboHotChannelItem *)object channelId] isEqualToString:self.channelId];
}

- (NSUInteger)hash {
    return [self.channelId integerValue];
}


@end

@implementation GalleryItem 
@synthesize ID;
@synthesize termId;
@synthesize newsId;
@synthesize gId;
@synthesize channelId;
@synthesize title;
@synthesize newsMark;
@synthesize originFrom;
@synthesize time;
@synthesize updateTime;
@synthesize type;
@synthesize commentNum;
@synthesize digNum;
@synthesize shareContent;
@synthesize gallerySubItems;

@synthesize nextId;
@synthesize nextNewsLink;
@synthesize nextNewsLink2;
@synthesize nextName;
@synthesize preId;
@synthesize preName;
@synthesize moreRecommends;
@synthesize from = source;

@synthesize isLike;
@synthesize likeCount;
@synthesize createAt;
@synthesize subId;
@synthesize stpAudCmtRsn;
@synthesize cmtStatus;
@synthesize cmtHint;


@end

@implementation RecommendGallery 
@synthesize ID;
@synthesize releatedTermId = rTermId;
@synthesize releatedNewsId = rNewsId;
@synthesize termId;
@synthesize newsId;
@synthesize title;
@synthesize time;
@synthesize type;
@synthesize iconUrl;
@synthesize iconPath;
@synthesize createAt;



@end

@implementation PhotoItem

@synthesize ID;
@synthesize termId;
@synthesize newsId;
@synthesize abstract;
@synthesize ptitle;
@synthesize shareLink;
@synthesize url;
@synthesize path;
@synthesize time;
@synthesize createAt;


@end

@implementation RollingNewsListItem

@synthesize ID;
@synthesize channelId;
@synthesize pubId;
@synthesize pubName;
@synthesize newsId;
@synthesize type;
@synthesize title;
@synthesize description;
@synthesize time;
@synthesize commentNum;
@synthesize digNum;
@synthesize listPic;
@synthesize link;
@synthesize readFlag;
@synthesize downloadFlag;
@synthesize form;
@synthesize listPicsNumber;
@synthesize timelineIndex;
@synthesize hasVideo;
@synthesize hasAudio;
@synthesize hasVote;
@synthesize updateTime;
@synthesize expired;
@synthesize createAt;
@synthesize isDownloadFinished;
@synthesize recomIconDay;
@synthesize recomIconNight;
@synthesize isWeather;
@synthesize city;
@synthesize tempHigh;
@synthesize tempLow;
@synthesize weatherIoc;
@synthesize weather;
@synthesize weak;
@synthesize liveTemperature;
@synthesize pm25;
@synthesize quality;
@synthesize wind;
@synthesize gbcode;
@synthesize date;
@synthesize localIoc;
@synthesize isRecom;
@synthesize recomType;
@synthesize liveStatus;
@synthesize local;
@synthesize thirdPartUrl;
@synthesize templateId;
@synthesize templateType;
@synthesize dataString;
@synthesize playTime;
@synthesize liveType;
@synthesize token;
@synthesize isFlash;
@synthesize position;
@synthesize morePageNum;
@synthesize isHasSponsorships;
@synthesize iconText;
@synthesize sponsorships;
@synthesize cursor;
@synthesize subId;
@synthesize isTopNews;
@synthesize isLatest;
@synthesize bgPic, redPacketTitle, sponsoredIcon, redPacketID;
@synthesize tvPlayTime,tvPlayNum,playVid,tvUrl,sourceName, siteValue;
@synthesize recomReasons,recomTime;
@synthesize blueTitle;
@synthesize recomInfo;
@synthesize trainCardId;

@end


@implementation NewsCommentItem

@synthesize ID;
@synthesize newsId;
@synthesize commentId;
@synthesize type;
@synthesize ctime;
@synthesize author;
@synthesize passport,linkStyle,spaceLink,pid;
@synthesize content;
@synthesize hadDing;
@synthesize digNum;
@synthesize imagePath;
@synthesize authorImage;
@synthesize audioPath;
@synthesize audioDuration;
@synthesize userComtId;

- (NSString *)digNum
{
    if([digNum isKindOfClass:[NSNumber class]]){
        return [(NSNumber *)digNum stringValue];
    }
    return digNum;
}


@end

@implementation NickNameObj

@synthesize ID;
@synthesize nickName;

-(id)initWithNickName:(NSString *)nick
{
    if (self=[super init]) {
        self.nickName=nick;
    }
    return self;
}

@end

@implementation CacheMgrURLRequest

@synthesize nRequestType;
@synthesize nRetryCount;
@synthesize urlRequestDelegate	= _urlRequestDelegate;
@synthesize url;
@synthesize path;

-(void)setTotalBytesDownloaded:(NSInteger)downloadedBytes
{
	_totalBytesDownloaded = downloadedBytes;
	if ([self isAllowResume] && [self.urlRequestDelegate respondsToSelector:@selector(requestUpdateProgress:receivedLen:totalLen:)]) {
		if (self.totalContentLength != 0 && self.totalBytesDownloaded != 0) {
			[self.urlRequestDelegate 
			 requestUpdateProgress:self.url 
			 receivedLen:self.totalBytesDownloaded 
			 totalLen:self.totalContentLength];
		}
		
	}
}


@end

@implementation NewspaperZipRequestItem
@synthesize newspaperInfo;

-(NewspaperZipRequestItem*)init
{
	if (self = [super init]) 
	{
		self.nRequestType	= CacheMgrURLRequestTypeNewspaperZip;
	}
	
	return  self;
}


@end

@implementation PhotoRequestItem
@synthesize photoInfo;

-(PhotoRequestItem*)init
{
	if (self = [super init]) 
	{
		self.nRequestType	= CacheMgrURLRequestTypeGalleryPhoto;
	}
	
	return  self;
}

@end

@implementation RecommendGalleryRequestItem
@synthesize recommendGalleryInfo;

-(RecommendGalleryRequestItem*)init
{
	if (self = [super init]) 
	{
		self.nRequestType	= CacheMgrURLRequestTypeRecommendGallery;
	}
	
	return  self;
}

@end

@implementation GroupPhotoItem

@synthesize ID;
@synthesize newsId;
@synthesize title;
@synthesize time;
@synthesize commentNum;
@synthesize favoriteNum;
@synthesize imageNum;
@synthesize images;
@synthesize type;
@synthesize typeId;
@synthesize sublink;
@synthesize timelineIndex;
@synthesize readFlag;
@synthesize createAt;

- (NSString *)timelineIndex
{
    if ([timelineIndex isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)timelineIndex stringValue];
    }
    return timelineIndex;
}


@end

@implementation SNTagItem
@synthesize ID;
@synthesize tagId;
@synthesize tagName;
@synthesize tagValue;

- (NSString *)tagId
{
    if ([tagId isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)tagId stringValue];
    }
    return tagId;
}


@end

@implementation CategoryItem
@synthesize ID;
@synthesize categoryID = categoryId;
@synthesize name;
@synthesize icon;
@synthesize position;
@synthesize top;
@synthesize topTime;
@synthesize isSubed;
@synthesize lastModify;

- (NSString *)categoryID
{
    if ([categoryId isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)categoryId stringValue];
    }
    return categoryId;
}

/**
 * 用于用户编辑后比较有没有变化，主要比较categoryID和isSubed
 *   by guoyalun
 **/
-(BOOL)isChanged:(CategoryItem *)item
{
    SNDebugLog(@"self id =%@,issub ==%@",self.categoryID,self.isSubed);
    SNDebugLog(@"item id =%@,issub ==%@",item.categoryID,item.isSubed);
    
    if (self.isSubed == nil) {
        
        self.isSubed =  @"0";
    }
    if (item.isSubed == nil) {
        
        item.isSubed = @"0";
    }
    if (![self.categoryID isEqualToString:item.categoryID]) {
     
        return YES;
    } else if ( self.isSubed.length>0&& ![self.isSubed isEqualToString:item.isSubed]){
        
        return YES;
    }
    return NO;
}
/**
 * 设置topTime时转成秒的格式
 *  by guoyalun
 */
- (void)setTopTime:(NSString *)_topTime formatter:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:_topTime];
    if (date) {
        topTime = [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    } else {
        topTime = @"0";
    }
}

-(void)setTopTimeBySeconds:(NSString *)_topTime
{
    topTime = _topTime;
}

/**
 * 判断当前的CategoryItem的置顶时间是否更新
 * by guoyalun
 */
-(BOOL)isLaterThan:(CategoryItem *)other
{
    CGFloat thisDate  = [self.topTime floatValue];
    CGFloat otherDate = [other.topTime floatValue];
    SNDebugLog(@"thisDate %f",thisDate);
      SNDebugLog(@"otherDate %f",otherDate);
    if (thisDate > otherDate) {
        return YES;
    }
    return NO;
}
- (BOOL)isEqual:(id)object {
    BOOL ret = NO;
    if (!object) {
        return NO;
    }
    if ([object isKindOfClass:[self class]]) {
        if ([[(CategoryItem *)object categoryID] isEqualToString:self.categoryID]) {
            ret = YES;
        }
    }
    return ret;
}

- (NSUInteger)hash {
    return [self.categoryID integerValue];
}

@end

//Home V3接口数据“我的订阅”和“所有订阅”的父类
@implementation SubscribeHomePO

@synthesize ID;
@synthesize defaultSub;
@synthesize subscribeTypeName;
@synthesize subId;
@synthesize subKind;//1表示报纸订阅，2表示RSS订阅；
@synthesize subName;
@synthesize subIcon;
@synthesize subInfo;
@synthesize pubIds;
@synthesize termId;
@synthesize lastTermLink;
@synthesize myPush;
@synthesize moreInfo;
@synthesize unReadCount;

- (id)copyWithZone:(NSZone *)zone {
	SubscribeHomePO *newPO = [[[self class] alloc] init];
	newPO.ID = self.ID;
    newPO.defaultSub = self.defaultSub;
	newPO.subscribeTypeName = self.subscribeTypeName;
	newPO.subId = self.subId;
	newPO.subKind = self.subKind;
	newPO.subName = self.subName;
   	newPO.subIcon = self.subIcon;
	newPO.subInfo = self.subInfo;
   	newPO.pubIds = self.pubIds;
   	newPO.termId = self.termId;
	newPO.lastTermLink = self.lastTermLink;
    newPO.myPush = self.myPush;
	newPO.moreInfo = self.moreInfo;
    newPO.unReadCount = self.unReadCount;
	return newPO;
}

- (void)setLastTermLink:(NSString *)newLastTermLink {
	if (newLastTermLink && ![lastTermLink isEqualToString:newLastTermLink]) {
		 //(lastTermLink);
        
        //redirect表示是否需要重定向url来获取termId，不重定向的话，可以在response header里取termId
        NSString *_tmpLastTermLink = nil;
		if (NSNotFound == [newLastTermLink rangeOfString:@"&redirect"].location) {
			_tmpLastTermLink = [[newLastTermLink stringByAppendingFormat:@"&redirect=%d", 0] copy];
		} else {
			_tmpLastTermLink = [newLastTermLink copy];
		}
        
        //nested表示报纸里面是否可以嵌套报纸(paper://)，这里表示新版本支持nested=1
        if (NSNotFound == [_tmpLastTermLink rangeOfString:@"&nested"].location) {
			lastTermLink = [[_tmpLastTermLink stringByAppendingFormat:@"&nested=%d", 1] copy];
		} else {
            lastTermLink = [_tmpLastTermLink copy];
        }
        _tmpLastTermLink = nil;
	}
}

- (NSString *)toString {
    NSMutableString *_s = [[NSMutableString alloc] init];
    [_s appendFormat:SN_String("ID:%d, defaultSub:%@, subscribeTypeName:%@, subId:%@, subKind:%@, subName:%@, subIcon:%@, subInfo:%@, pubIds:%@, termId:%@, lastTermLink:%@, myPush:%@, moreInfo:%@, unReadCount:%@"), self.ID, self.defaultSub, self.subscribeTypeName, self.subId, self.subKind, self.subName, self.subIcon, self.subInfo, self.pubIds, self.termId, self.lastTermLink, self.myPush, self.moreInfo, self.unReadCount];
    return _s;
}

@end


//Home V3接口数据“我的订阅”类
@implementation SubscribeHomeMySubscribePO

@synthesize orderIndex;
@synthesize status;
@synthesize downloaded;
@synthesize pushName;
//Transient property
@synthesize termTime;
//Transient property
@synthesize downloadStatus;
//Transient property
@synthesize tmpDownloadZipPath;
//Transient property
@synthesize finalDownloadZipPath;
//Transient property
@synthesize termName;
//Transient property
@synthesize tmpProgress;
//Transient property
@synthesize isCanceled;
@synthesize isSelected;
//离线下载地址
@synthesize zipUrl;

- (id)init {
    if (self = [super init]) {
        downloadStatus = SNDownloadWait;
        isCanceled = NO;
    }
    return self;
}

- (NSString *)orderIndex
{
    if ([orderIndex isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)orderIndex stringValue];
    }
    return orderIndex;
}

- (id)copyWithZone:(NSZone *)zone {
	SubscribeHomeMySubscribePO *newPO = [super copyWithZone:zone];
	newPO.orderIndex = self.orderIndex;
    newPO.status = self.status;
	newPO.downloaded = self.downloaded;
    newPO.isCanceled = self.isCanceled;
    newPO.isSelected = self.isSelected;
    newPO.zipUrl = self.zipUrl;
	return newPO;
}

- (NSString *)toString {
    NSMutableString *_s = [[NSMutableString alloc] init];
    [_s appendFormat:SN_String("%@, orderIndex:%@, status:%@, downloaded:%@, termTime:%@, termName:%@, tmpProgress:%f, isCanceled:%d, isSelected:%@"), [super toString], self.orderIndex, self.status, self.downloaded, self.termTime, self.termName, [self.tmpProgress floatValue], self.isCanceled, self.isSelected];
    return _s;
}

- (NSString *)description {
    NSMutableString *_s = [[NSMutableString alloc] init];
    [_s appendFormat:SN_String("%@, orderIndex:%@, status:%@, downloaded:%@, termTime:%@, termName:%@, tmpProgress:%f, isCanceled:%d, isSelected:%@"), [super toString], self.orderIndex, self.status, self.downloaded, self.termTime, self.termName, [self.tmpProgress floatValue], self.isCanceled, self.isSelected];
    return _s;
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
    SubscribeHomeMySubscribePO *_po = (SubscribeHomeMySubscribePO *)object;
    return ([self.subId isEqualToString:_po.subId] && [self.termId isEqualToString:_po.termId]);
}

- (NSUInteger)hash {
    return [self.termId intValue];
}


//以下两个方法是为了支持SNNewsPaperWebController，因为旧版接口数据有pubId和pubName两个避属性，但HomeV3接口的数据不一样；
- (NSString *)pubId {
    return [self pubIds];
}

- (NSString *)pubName {
    return [self subName];
}

@end

// subscribe center V3.2
@implementation SCSubscribeObject
@synthesize ID;
@synthesize defaultSub;
@synthesize subId;
@synthesize subName;
@synthesize subIcon;
@synthesize subInfo;
@synthesize moreInfo;
@synthesize pubIds;
@synthesize termId;
@synthesize lastTermLink;
@synthesize isPush;
@synthesize defaultPush;
@synthesize publishTime;
@synthesize unReadCount;
@synthesize subPersonCount;
@synthesize topNews;
@synthesize topNews2;
@synthesize isSubscribed;
@synthesize isDownloaded;
@synthesize isOnRank;
@synthesize isTop;
@synthesize topTime;
@synthesize indexValue;
@synthesize starGrade;
@synthesize commentCount;
@synthesize openTimes;
@synthesize backPromotion;
@synthesize templeteType;
@synthesize status;
@synthesize isSelected;

@synthesize link = _link;
@synthesize subShowType;
@synthesize openContext;

//Transient Properties
@synthesize termName;
@synthesize downloadStatus;
@synthesize tmpDownloadZipPath;
@synthesize finalDownloadZipPath;
@synthesize isSpecifiedTerm;
@synthesize from;
//Download ZipUrl
@synthesize zipUrl;
@synthesize stickTop;
@synthesize buttonTxt;
@synthesize needLogin;
@synthesize canOffline;
@synthesize userInfo;

// for sub detail view controller
@synthesize showComment, showRecmSub;


@synthesize topNewsAbstracts;
@synthesize topNewsLink;
@synthesize topNewsPics; // 存数据库时序列化为json string
@synthesize topNewsPicsString; // topNewsPics数组序列化为json string
@synthesize sortIndex;

@synthesize topNewsString;
@synthesize topNewsArray;

- (id)copyWithZone:(NSZone *)zone {
	SCSubscribeObject *newPO = [[[self class] alloc] init];
    newPO.ID = self.ID;
    newPO.defaultSub = self.defaultSub;
    newPO.subId = self.subId;
    newPO.subName = self.subName;
    newPO.subIcon = self.subIcon;
    newPO.subInfo = self.subInfo;
    newPO.moreInfo = self.moreInfo;
    newPO.pubIds = self.pubIds;
    newPO.termId = self.termId;
    newPO.lastTermLink = self.lastTermLink;
    newPO.isPush = self.isPush;
    newPO.defaultPush = self.defaultPush;
    newPO.publishTime = self.publishTime;
    newPO.unReadCount = self.unReadCount;
    newPO.subPersonCount = self.subPersonCount;
    newPO.topNews = self.topNews;
    newPO.topNews2 = self.topNews2;
    newPO.isSubscribed = self.isSubscribed;
    newPO.isDownloaded = self.isDownloaded;
    newPO.isOnRank = self.isOnRank;
    newPO.isTop = self.isTop;
    newPO.topTime = self.topTime;
    newPO.indexValue = self.indexValue;
    newPO.starGrade = self.starGrade;
    newPO.commentCount = self.commentCount;
    newPO.openTimes = self.openTimes;
    newPO.backPromotion = self.backPromotion;
    newPO.templeteType = self.templeteType;
    newPO.status = self.status;
    newPO.isSelected = self.isSelected;
    newPO.zipUrl = self.zipUrl;
    newPO.stickTop = self.stickTop;
    newPO.buttonTxt = self.buttonTxt;
    newPO.needLogin = self.needLogin;
    newPO.canOffline = self.canOffline;
    newPO.userInfo = self.userInfo;
    
    newPO.link = self.link;
    newPO.subShowType = self.subShowType;
    
    newPO.openContext = self.openContext;
    
    //Transient properties
    newPO.termName = self.termName;
    newPO.downloadStatus = self.downloadStatus;
    newPO.tmpDownloadZipPath = self.tmpDownloadZipPath;
    newPO.finalDownloadZipPath = self.finalDownloadZipPath;
    newPO.isSpecifiedTerm = self.isSpecifiedTerm;
    newPO.from = self.from;
    
    newPO.topNewsAbstracts = self.topNewsAbstracts;
    newPO.topNewsLink = self.topNewsLink;
    newPO.topNewsPics = self.topNewsPics;
    newPO.topNewsPicsString = self.topNewsPicsString;
    newPO.sortIndex = self.sortIndex;
    
    newPO.countShowText = self.countShowText;
    
	return newPO;
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
    SCSubscribeObject *_po = (SCSubscribeObject *)object;
    return ([self.subId isEqualToString:_po.subId]);
}

- (NSUInteger)hash {
    return [self.subId intValue];
}

- (NSString *)toString {
    return [NSString stringWithFormat:@"\n%@ -- defaultPush=%@\n subID=%@\n subName=%@\n subIcon=%@\n subInfo=%@\n moreInfo=%@\n pubIds=%@\n termID=%@\n lastTermLink=%@\n isPush=%@\n defaultPush=%@\n publishTime=%@\n unReadCount=%@\n subPersonCount=%@\n topNews=%@\n topNews2=%@\n isSubscribed=%@\n isDownloaded=%@\n isOnRank=%@\n isTop=%@\n topTime=%@\n indexValue=%@\n starGrade=%@\n commentCount=%@\n openTimers=%@\n backPromotion=%@\n templeteType = %@\n status = %@\n isSelected = %@\n termName = %@\n downloadStatus = %d\n tmpDownloadZipPath = %@\n finalDownloadZipPath = %@\n isSpecifiedTerm = %d\n from=%d\n", NSStringFromClass([self class]), self.defaultSub, self.subId, self.subName, self.subIcon, self.subInfo, self.moreInfo, self.pubIds, self.termId, self.lastTermLink, self.isPush, self.defaultPush, self.publishTime, self.unReadCount, self.subPersonCount, self.topNews, self.topNews2, self.isSubscribed, self.isDownloaded, self.isOnRank, self.isTop, self.topTime, self.indexValue, self.starGrade, self.commentCount, self.openTimes, self.backPromotion, self.templeteType, self.status, self.isSelected, self.termName, self.downloadStatus, self.tmpDownloadZipPath, self.finalDownloadZipPath, self.isSpecifiedTerm, self.from];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n%@ -- defaultPush=%@\n subID=%@\n subName=%@\n subIcon=%@\n subInfo=%@\n moreInfo=%@\n pubIds=%@\n termID=%@\n lastTermLink=%@\n isPush=%@\n defaultPush=%@\n publishTime=%@\n unReadCount=%@\n subPersonCount=%@\n topNews=%@\n topNews2=%@\n isSubscribed=%@\n isDownloaded=%@\n isOnRank=%@\n isTop=%@\n topTime=%@\n indexValue=%@\n starGrade=%@\n commentCount=%@\n openTimers=%@\n backPromotion=%@\n templeteType = %@\n status = %@\n isSelected = %@\n termName = %@\n downloadStatus = %d\n tmpDownloadZipPath = %@\n finalDownloadZipPath = %@\n isSpecifiedTerm = %d\n from=%d\n", NSStringFromClass([self class]), self.defaultSub, self.subId, self.subName, self.subIcon, self.subInfo, self.moreInfo, self.pubIds, self.termId, self.lastTermLink, self.isPush, self.defaultPush, self.publishTime, self.unReadCount, self.subPersonCount, self.topNews, self.topNews2, self.isSubscribed, self.isDownloaded, self.isOnRank, self.isTop, self.topTime, self.indexValue, self.starGrade, self.commentCount, self.openTimes, self.backPromotion, self.templeteType, self.status, self.isSelected, self.termName, self.downloadStatus, self.tmpDownloadZipPath, self.finalDownloadZipPath, self.isSpecifiedTerm, self.from];
}

- (NSString *)indexValue {
    NSString *isSubed = [@"1" isEqualToString:self.isTop] ? @"1" : @"0";
    indexValue = [[NSString alloc] initWithFormat:@"%@%@", isSubed, self.publishTime];
    return indexValue;
}

- (NSString *)lastTermLink {
    if (lastTermLink == nil||[lastTermLink isKindOfClass:[NSNull class]]) {
        //NSString *linkUrl = [NSString stringWithFormat:kLastTermLinkUrl, self.subId];
        NSString *linkUrl = [NSString stringWithFormat:kUrlSubPaper, self.subId];
        lastTermLink = [linkUrl copy];
    }
    return lastTermLink;
}
- (void)setLastTermLink:(NSString *)newLastTermLink {
	if (newLastTermLink && ![lastTermLink isEqualToString:newLastTermLink]) {
		 //(lastTermLink);
        
        //redirect表示是否需要重定向url来获取termId，不重定向的话，可以在response header里取termId
        NSString *_tmpLastTermLink = nil;
		if (NSNotFound == [newLastTermLink rangeOfString:@"&redirect"].location) {
			_tmpLastTermLink = [[newLastTermLink stringByAppendingFormat:@"&redirect=%d", 0] copy];
		} else {
			_tmpLastTermLink = [newLastTermLink copy];
		}
        
        //nested表示报纸里面是否可以嵌套报纸(paper://)，这里表示新版本支持nested=1
        if (NSNotFound == [_tmpLastTermLink rangeOfString:@"&nested"].location) {
			lastTermLink = [[_tmpLastTermLink stringByAppendingFormat:@"&nested=%d", 1] copy];
		} else {
            lastTermLink = [_tmpLastTermLink copy];
        }
        _tmpLastTermLink = nil;
	}
}

- (NSString *)link {
    if ([_link rangeOfString:@"subId"].location == NSNotFound && [SNUtility isProtocolV2:_link]) {
        return [_link stringByAppendingFormat:@"&subId=%@", self.subId];
    }
    return _link;
}

- (void)updateTopTime {
    self.topTime = [NSString stringWithFormat:@"%lld", (long long)(1000 * [[NSDate date] timeIntervalSince1970])];
}

- (void)setTopNewsPics:(NSArray *)_topNewsPics {
    if (topNewsPics != _topNewsPics && [_topNewsPics isKindOfClass:[NSArray class]]) {
         //(topNewsPics);
        topNewsPics = _topNewsPics;
        
        // update topNewsPicsString
         //(topNewsPicsString);
        topNewsPicsString = [[topNewsPics yajl_JSONString] copy];
    }
}

- (void)setTopNewsPicsString:(NSString *)_topNewsPicsString {
    if (topNewsPicsString != _topNewsPicsString) {
         //(topNewsPicsString);
        topNewsPicsString = [_topNewsPicsString copy];
        
        if (!topNewsPics && topNewsPicsString) {
            NSError *err = nil;
            id arrayObj = [topNewsPicsString yajl_JSON:&err];
            
            SNDebugLog(@"%@-%@: json string to array error %@",
                       NSStringFromClass([self class]),
                       NSStringFromSelector(_cmd),
                       err);
            
            if ([arrayObj isKindOfClass:[NSArray class]]) {
                topNewsPics = arrayObj;
            }
        }
    }
}


// 解析方法
+ (SCSubscribeObject *)subscribeObjFromJsonDic:(NSDictionary *)jsonObj {
    SCSubscribeObject *subObj = nil;
    if (jsonObj && [jsonObj isKindOfClass:[NSDictionary class]]) {
        subObj = [[SCSubscribeObject alloc] init];
        
        subObj.defaultSub = [jsonObj objectForKey:@"defaultSub"];
        subObj.subId = [jsonObj objectForKey:@"subId"];
        subObj.subName = [jsonObj objectForKey:@"subName"];
        subObj.subIcon = [jsonObj objectForKey:@"subIcon"];
        subObj.subInfo = [jsonObj objectForKey:@"subInfo"];
        subObj.moreInfo = [jsonObj objectForKey:@"moreInfo"];
        subObj.pubIds = [jsonObj objectForKey:@"pubIds"];
        subObj.termId = [jsonObj objectForKey:@"termId"];
        subObj.lastTermLink = [jsonObj objectForKey:@"lastTermLink"];
        subObj.isPush = [jsonObj objectForKey:@"isPush"];
        subObj.publishTime = [jsonObj objectForKey:@"publishTime"];
        subObj.unReadCount = [jsonObj objectForKey:@"unReadCount"];
        subObj.subPersonCount = [jsonObj objectForKey:@"subPersonCount"];
        subObj.topNews = [[jsonObj stringValueForKey:@"topNews" defaultValue:@""] gtm_stringByUnescapingFromHTML];
        //subObj.topNews2 = [jsonObj objectForKey:@"topNews2"];
        subObj.isSubscribed = [jsonObj objectForKey:@"isSubscribed"];
        subObj.starGrade = [jsonObj objectForKey:@"starGrade"];
        subObj.commentCount = [jsonObj objectForKey:@"commentCount"];
        subObj.templeteType = [jsonObj objectForKey:@"templeteType"];
        
        // 3.4 增加两个新的字段  来支持订阅中心嵌入新闻、微博、组图、直播等频道 by jojo
        subObj.link = [jsonObj stringValueForKey:@"link" defaultValue:nil];
        // 有一种情况 解析正文等所属刊物是 link对应的key wei subLink 所以如果用link解析不到，再用subLink解析一下；
        if (!subObj.link) subObj.link = [jsonObj stringValueForKey:@"subLink" defaultValue:nil];
        
        subObj.subShowType = [jsonObj stringValueForKey:@"subShowType" defaultValue:nil];
        //3.5
        subObj.stickTop = [jsonObj stringValueForKey:@"stickTop" defaultValue:nil];
        subObj.buttonTxt = [jsonObj stringValueForKey:@"buttonTxt" defaultValue:nil];
        
        // 3.5.1
        subObj.needLogin = [jsonObj stringValueForKey:@"needLogin" defaultValue:nil];
        subObj.canOffline = [jsonObj stringValueForKey:@"canOffline" defaultValue:nil];
        
        // 3.6 for sub detail view controller ps. 为了兼容之前的  下面这两个属性 默认值为1
        subObj.showComment = [jsonObj stringValueForKey:@"showComment" defaultValue:@"1"];
        subObj.showRecmSub = [jsonObj stringValueForKey:@"showRecmSub" defaultValue:@"1"];
        
        
        // 5.0 for 订阅频道流改版
        NSMutableArray *topNewsArray = [jsonObj objectForKey:@"topNews"];
        subObj.topNewsArray = topNewsArray;
        if (topNewsArray && [topNewsArray isKindOfClass:[NSArray class]]) {
            subObj.topNewsString = [subObj.topNewsArray yajl_JSONString];
        }
        //5.1累计阅读数/累计播放数
        subObj.countShowText = [jsonObj objectForKey:@"countShowText"];
        /*
        // 4.3 for 订阅tab改版
        subObj.topNewsAbstracts = [[jsonObj stringValueForKey:@"topNewsAbstracts" defaultValue:@""] gtm_stringByUnescapingFromHTML];
        subObj.topNewsLink = [[jsonObj stringValueForKey:@"topNewsLink" defaultValue:@""] gtm_stringByUnescapingFromHTML];
        subObj.topNewsPics = [jsonObj arrayValueForKey:@"topNewsPics" defaultValue:nil];
        */
    }
    return subObj;
}

+ (SCSubscribeObject *)subscribeObjFromXMLData:(TBXMLElement *)xmlElm {
    SCSubscribeObject *subObj = nil;
    if (xmlElm) {
        subObj = [[SCSubscribeObject alloc] init];
        
        NSString *defaultSub = [TBXML textForElement:[TBXML childElementNamed:@"defaultSub" parentElement:xmlElm]];
        if (defaultSub.length > 0) subObj.defaultSub = defaultSub;
        
        NSString *subId = [TBXML textForElement:[TBXML childElementNamed:@"subId" parentElement:xmlElm]];
        if (subId.length > 0) subObj.subId = subId;
        
        NSString *subName = [TBXML textForElement:[TBXML childElementNamed:@"subName" parentElement:xmlElm]];
        if (subName.length > 0) subObj.subName = subName;
        
        NSString *subIcon = [TBXML textForElement:[TBXML childElementNamed:@"subIcon" parentElement:xmlElm]];
        if (subIcon.length > 0) subObj.subIcon = subIcon;
        
        NSString *subInfo = [TBXML textForElement:[TBXML childElementNamed:@"subInfo" parentElement:xmlElm]];
        if (subInfo.length > 0) subObj.subInfo = subInfo;
        
        NSString *moreInfo = [TBXML textForElement:[TBXML childElementNamed:@"moreInfo" parentElement:xmlElm]];
        if (moreInfo.length > 0) subObj.moreInfo = moreInfo;
        
        NSString *pubIds = [TBXML textForElement:[TBXML childElementNamed:@"pubIds" parentElement:xmlElm]];
        if (pubIds.length > 0) subObj.pubIds = pubIds;
        
        NSString *termId = [TBXML textForElement:[TBXML childElementNamed:@"termId" parentElement:xmlElm]];
        if (termId.length > 0) subObj.termId = termId;
        
        NSString *lastTermLink = [TBXML textForElement:[TBXML childElementNamed:@"lastTermLink" parentElement:xmlElm]];
        if (lastTermLink.length > 0) subObj.lastTermLink = lastTermLink;
        
        NSString *isPush = [TBXML textForElement:[TBXML childElementNamed:@"isPush" parentElement:xmlElm]];
        if (isPush.length > 0) subObj.isPush = isPush;
        
        NSString *publishTime = [TBXML textForElement:[TBXML childElementNamed:@"publishTime" parentElement:xmlElm]];
        if (publishTime.length > 0) subObj.publishTime = publishTime;
        
        NSString *unReadCount = [TBXML textForElement:[TBXML childElementNamed:@"unReadCount" parentElement:xmlElm]];
        if (unReadCount.length > 0)  subObj.unReadCount = unReadCount;
        
        NSString *subPersonCount = [TBXML textForElement:[TBXML childElementNamed:@"subPersonCount" parentElement:xmlElm]];
        if (subPersonCount.length > 0) subObj.subPersonCount = subPersonCount;
        
        NSString *topNews = [[TBXML textForElement:[TBXML childElementNamed:@"topNews" parentElement:xmlElm]] gtm_stringByUnescapingFromHTML];
        if (topNews.length > 0) subObj.topNews = topNews;
        
        NSString *isSubscribed = [TBXML textForElement:[TBXML childElementNamed:@"isSubscribed" parentElement:xmlElm]];
        if (isSubscribed.length > 0) subObj.isSubscribed = isSubscribed;
        
        NSString *starGrade = [TBXML textForElement:[TBXML childElementNamed:@"starGrade" parentElement:xmlElm]];
        if (starGrade.length > 0) subObj.starGrade = starGrade;
        
        NSString *commentCount = [TBXML textForElement:[TBXML childElementNamed:@"commentCount" parentElement:xmlElm]];
        if (commentCount.length > 0) subObj.commentCount = commentCount;
        
        NSString *templeteType = [TBXML textForElement:[TBXML childElementNamed:@"templeteType" parentElement:xmlElm]];
        if (templeteType.length > 0) subObj.templeteType = templeteType;
        
        NSString *link = [TBXML textForElement:[TBXML childElementNamed:@"link" parentElement:xmlElm]];
        if (link.length > 0)
            subObj.link = link;
        else {
            // 有一种情况 解析正文等所属刊物是 link对应的key wei subLink 所以如果用link解析不到，再用subLink解析一下；
            link = [TBXML textForElement:[TBXML childElementNamed:@"subLink" parentElement:xmlElm]];
            if (link.length > 0) subObj.link = link;
        }
        
        NSString *stickTop = [TBXML textForElement:[TBXML childElementNamed:@"stickTop" parentElement:xmlElm]];
        if (stickTop.length > 0) subObj.stickTop = stickTop;
        
        NSString *subShowType = [TBXML textForElement:[TBXML childElementNamed:@"subShowType" parentElement:xmlElm]];
        if (subShowType.length > 0) subObj.subShowType = subShowType;
        
        NSString *buttonTxt = [TBXML textForElement:[TBXML childElementNamed:@"buttonTxt" parentElement:xmlElm]];
        if (buttonTxt.length > 0) subObj.buttonTxt = buttonTxt;
        
        NSString *needLogin = [TBXML textForElement:[TBXML childElementNamed:@"needLogin" parentElement:xmlElm]];
        if (needLogin.length > 0) subObj.needLogin = needLogin;
        
        NSString *canOffline = [TBXML textForElement:[TBXML childElementNamed:@"canOffline" parentElement:xmlElm]];
        if (canOffline.length > 0) subObj.canOffline = canOffline;
        
        // 3.6 for sub detail view controller ps. 为了兼容之前的  下面这两个属性 默认值为1
        NSString *showComment = [TBXML textForElement:[TBXML childElementNamed:@"showComment" parentElement:xmlElm]];
        if (showComment.length > 0) {
            subObj.showComment = showComment;
        }
        else {
            subObj.showComment = @"1";
        }
        
        NSString *showRec = [TBXML textForElement:[TBXML childElementNamed:@"showRecmSub" parentElement:xmlElm]];
        if (showRec.length > 0) {
            subObj.showRecmSub = showRec;
        }
        else {
            subObj.showRecmSub = @"1";
        }
        
        NSString *countShowText = [TBXML textForElement:[TBXML childElementNamed:@"countShowText" parentElement:xmlElm]];
        if (countShowText.length > 0) {
            subObj.countShowText = countShowText;
        }
    }
    return subObj;
}

- (int)statusValueWithFlag:(SCSubObjStatusFlag)flag {
    if ([self.status length] > 0) {
        long long value = [self.status longLongValue];
        if (flag == SCSubObjStatusFlagSubStatus) {
            return value & (1 << 1 | 1);
        }
        else {
            return ((value >> flag) & 1);
        }
    }
    return 0;
}

- (BOOL)setStatusValue:(int)value forFlag:(SCSubObjStatusFlag)flag {
    long long tmpValue = 0;
    
    if ([self.status length] > 0) {
        tmpValue = [self.status longLongValue];
    }
    SNDebugLog(@"v1 = %lld", tmpValue);
    if (flag == SCSubObjStatusFlagSubStatus) {
        value &= (1 << 1 | 1);
        if (value & 1) {
            tmpValue |= 1;
        } else {
            tmpValue &= ~1;
        }
        
        if (value & (1<<1)) {
            tmpValue |= (1<<1);
        } else {
            tmpValue &= ~(1<<1);
        }

        SNDebugLog(@"v2 = %lld", tmpValue);
    }
    else {
        value &= 1;
        if (value) {
            tmpValue |= (1 << flag);
        }
        else {
            tmpValue &= ~(1 << flag);
        }
    }
    
    BOOL bModified = (tmpValue != [self.status longLongValue]);

    self.status = [NSString stringWithFormat:@"%lld", tmpValue];

    SNDebugLog(@"status=%@", self.status);
    
    return bModified;
}

- (SubscribeHomeMySubscribePO *)toSubscribeHomeMySubscribePO {
    SubscribeHomeMySubscribePO *_tempSubHomeMySubPO = [[SubscribeHomeMySubscribePO alloc] init];
    _tempSubHomeMySubPO.defaultSub                  = self.defaultSub;
    _tempSubHomeMySubPO.subId                       = self.subId;
    _tempSubHomeMySubPO.subName                     = self.subName;
    _tempSubHomeMySubPO.subIcon                     = self.subIcon;
    _tempSubHomeMySubPO.subInfo                     = self.subInfo;
    _tempSubHomeMySubPO.pubIds                      = self.pubIds;
    _tempSubHomeMySubPO.termId                      = self.termId;
    _tempSubHomeMySubPO.lastTermLink                = self.lastTermLink;
    _tempSubHomeMySubPO.myPush                      = self.isPush;
    _tempSubHomeMySubPO.moreInfo                    = self.moreInfo;
    _tempSubHomeMySubPO.downloaded                  = self.isDownloaded;
    _tempSubHomeMySubPO.isSelected                  = self.isSelected;
    _tempSubHomeMySubPO.termTime                    = self.publishTime;
    _tempSubHomeMySubPO.termName                    = self.termName;

    return _tempSubHomeMySubPO;
}

- (BOOL)open {
    BOOL bRet = NO;
    if (self.link.length > 0) {
        NSMutableDictionary *tempDic = nil;
        
        if (self.openContext) {
            tempDic = [NSMutableDictionary dictionaryWithDictionary:self.openContext];
        }
        else {
            tempDic = [NSMutableDictionary dictionary];
        }
        
        if (![tempDic objectForKey:kChannelSubId]) {
            [tempDic setObject:self.subId forKey:kChannelSubId];
        }
        
        if ([SNUtility openProtocolUrl:self.link context:tempDic])
            bRet = YES;
    }
    
    // clean open context
    self.openContext = nil;
    return bRet;
}

- (BOOL)openDetail {
    BOOL bRet = NO;
    
    if (self.subId.length > 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:self forKey:@"subObj"];
        if (self.openContext.count > 0) {
            [dic setValuesForKeysWithDictionary:self.openContext];
        }
        TTURLAction *action = [[[TTURLAction actionWithURLPath:@"tt://subDetail"] applyAnimated:YES] applyQuery:dic];
        [[TTNavigator navigator] openURLAction:action];
        bRet = YES;
    }
    
    // clean open context
    self.openContext = nil;
    return bRet;
}

- (BOOL)isPlugin {
    return [subShowType isEqualToString:kPluginSubShowType];
}

- (NSString *)succSubMsg {
    NSString *msg = nil;
    if ([self isPlugin]) {
        msg = [self.subName length] > 0 ? [NSString stringWithFormat:@"《%@》已使用", self.subName] : @"已使用";
    } else {
        msg = [self.subName length] > 0 ? [NSString stringWithFormat:@"《%@》订阅成功", self.subName] : @"订阅成功";
    }
    return msg;
}

- (NSString *)failSubMsg {
    NSString *msg = nil;
    if ([self isPlugin]) {
        msg = [self.subName length] > 0 ? [NSString stringWithFormat:@"《%@》使用失败", self.subName] : @"使用失败";
    } else {
        msg = [self.subName length] > 0 ? [NSString stringWithFormat:@"《%@》订阅失败", self.subName] : @"订阅失败";
    }
    return msg;
}

- (NSString *)succUnsubMsg {
    NSString *msg = nil;
    if ([self isPlugin]) {
        msg = [self.subName length] > 0 ? [NSString stringWithFormat:@"《%@》已停用", self.subName] : @"已停用";
    } else {
        msg = [self.subName length] > 0 ? [NSString stringWithFormat:@"《%@》已退订", self.subName] : @"已退订";
    }
    return msg;
}

- (NSString *)failUnsubMsg {
    NSString *msg = nil;
    if ([self isPlugin]) {
        msg = [self.subName length] > 0 ? [NSString stringWithFormat:@"《%@》停用失败", self.subName] : @"停用失败";
    } else {
        msg = [self.subName length] > 0 ? [NSString stringWithFormat:@"《%@》退订失败", self.subName] : @"退订失败";
    }
    return msg;
}

- (NSArray *)userInfoListArray {
    NSMutableArray *userInfoList = nil;
    if (self.userInfo.length > 0) {
        NSError *error = nil;
        id userInfoObj = [self.userInfo yajl_JSON:&error];
        if (error) {
            SNDebugLog(@"%@--%@ json serialize failed with error:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription]);
            return nil;
        }
        
        userInfoList = [NSMutableArray array];
        
        if (userInfoObj && [userInfoObj isKindOfClass:[NSDictionary class]])
            [userInfoList addObject:userInfoObj];
        else if (userInfoObj && [userInfoObj isKindOfClass:[NSArray class]])
            [userInfoList addObjectsFromArray:userInfoObj];
    }
    
    return userInfoList;
}

@end

@implementation SCSubscribeTypeObject
@synthesize ID,typeId, typeName, typeIcon, subId, subName;

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
    SCSubscribeTypeObject *_po = (SCSubscribeTypeObject *)object;
    return [self.typeId isEqualToString:_po.typeId];
}

- (NSUInteger)hash {
    return [self.typeId intValue];
}

- (NSString *)toString {
    return [NSString stringWithFormat:@"typeId = %@ typeName=%@", self.typeId, self.typeName];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"typeId = %@ typeName=%@", self.typeId, self.typeName];
}


@end

@implementation SCSubscribeAdObject
@synthesize ID,adType, adName, adImage=adImg, refId, refLink, refText, type;

- (NSString *)description {
    return [NSString stringWithFormat:@"adType=%@ adName=%@ adImage=%@ refId=%@ reflink=%@ refText=%@",
            adType, adName, adImg, refId, refLink, refText];
}

- (NSString *)toString {
    return [NSString stringWithFormat:@"adType=%@ adName=%@ adImage=%@ refId=%@ reflink=%@ refText=%@",
            adType, adName, adImg, refId, refLink, refText];
}


@end

@implementation SCSubscribeCommentObject
@synthesize ID,subId, author, ctime, content = _content, starGrade, city, contentLinesNum;

- (void)setContent:(NSString *)content {
    if (_content != content) {
        _content = [content copy];
    }
    
    if ([_content length] == 0) {
        self.contentLinesNum = 1;
    }
    else {
        // 重新计算高度
        CGFloat contentWidth = TTApplicationFrame().size.width - 2 * 10;
        CGFloat fontSize = (28 / 2);
        UIFont *font = [UIFont systemFontOfSize:fontSize];
        
        if ([_content sizeWithFont:font].width < contentWidth) {
            self.contentLinesNum = 1;
        }
        else {
            CGSize size = [_content sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, CGFLOAT_MAX)];
            self.contentLinesNum = size.height / (fontSize + 1);
        }
    }
}


@end

@implementation ShareListItem

@synthesize ID;
@synthesize appLevel;
@synthesize status;
@synthesize appID = _appID;
@synthesize appName;
@synthesize appIconUrl;
@synthesize appGrayIconUrl;
@synthesize userName;
@synthesize requestUrl;
@synthesize openId;

- (NSString *)description {
    return [NSString stringWithFormat:@"status=%@\nappLevel=%d\nappID=%@\nappName=%@\nappIconUrl=%@\nappGrayIconUrl=%@\nuserName=%@\nrequestUrl=%@\nopenId=%@\n",
            self.status, self.appLevel, self.appID, self.appName, self.appIconUrl, self.appGrayIconUrl, self.userName, self.requestUrl, self.openId];
}


@end

@implementation LivingGameItem

@synthesize ID;
@synthesize reserveFlag = flag;
@synthesize isToday;
@synthesize isFocus;
@synthesize liveId;
@synthesize livePic;
@synthesize isHot;
@synthesize liveType;
@synthesize liveCat;
@synthesize liveSubCat;
@synthesize title;
@synthesize status;
@synthesize liveTime;
@synthesize liveDay;
@synthesize liveDate;
@synthesize mediaType;

@synthesize visitorId;
@synthesize visitorName;
@synthesize visitorPic;
@synthesize visitorInfo;
@synthesize visitorTotal = _visitorTotal;

@synthesize hostId;
@synthesize hostName;
@synthesize hostPic;
@synthesize hostInfo;
@synthesize hostTotal = _hostTotal;

@synthesize createAt;

- (id)init {
    self = [super init];
    if (self) {
        self.reserveFlag = @"";
        self.isToday = @"";
        self.isFocus = @"";
        self.liveId = @"";
        self.livePic = @"";
        self.isHot = @"";
        self.liveType = @"";
        self.liveCat = @"";
        self.liveSubCat = @"";
        self.title = @"";
        self.status = @"";
        self.liveTime = @"";
        self.liveDay = @"";
        self.liveDate = @"";
        
        self.visitorId = @"";
        self.visitorName = @"";
        self.visitorPic = @"";
        self.visitorInfo = @"";
        self.visitorTotal = @"";
        
        self.hostId = @"";
        self.hostName = @"";
        self.hostPic = @"";
        self.hostInfo = @"";
        self.hostTotal = @"";
        self.pubType = @"";
        self.blockId = @"";
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dicInfo {
    self = [super init];
    if (self) {
        self.liveType = [dicInfo objectForKey:@"liveType" defalutObj:@""];
        self.liveCat = [dicInfo objectForKey:@"subsName" defalutObj:@""];
        self.liveSubCat = [dicInfo objectForKey:@"liveSubCat" defalutObj:@"赛事"];
        self.liveId = [dicInfo objectForKey:@"liveId" defalutObj:@""];
        self.title = [dicInfo objectForKey:@"title" defalutObj:@""];
        self.status = [dicInfo objectForKey:@"status" defalutObj:@""];
        self.isHot = [dicInfo objectForKey:@"isHot" defalutObj:@""];
        self.liveTime = [dicInfo objectForKey:@"liveTime" defalutObj:@""];
        self.mediaType = [dicInfo intValueForKey:@"mediaType" defaultValue:0];
        
        self.visitorId = [dicInfo objectForKey:@"vistorId" defalutObj:@""];
        self.visitorName = [dicInfo objectForKey:@"vistorName" defalutObj:@""];
        self.visitorPic = [dicInfo objectForKey:@"vistorPic" defalutObj:@""];
        self.visitorInfo = [dicInfo objectForKey:@"vistorInfo" defalutObj:@""];
        self.visitorTotal = [dicInfo objectForKey:@"vistorTotal" defalutObj:@""];
        
        self.hostId = [dicInfo objectForKey:@"hostId" defalutObj:@""];
        self.hostName = [dicInfo objectForKey:@"hostName" defalutObj:@""];
        self.hostPic = [dicInfo objectForKey:@"hostPic" defalutObj:@""];
        self.hostInfo = [dicInfo objectForKey:@"hostInfo" defalutObj:@""];
        self.hostTotal = [dicInfo objectForKey:@"hostTotal" defalutObj:@""];
        
        self.livePic = [dicInfo objectForKey:@"livePic" defalutObj:@""];
        
        self.liveDay = [dicInfo objectForKey:@"liveDay" defalutObj:@""];
        self.liveDate = [dicInfo objectForKey:@"liveDate" defalutObj:@""];
        
        self.pubType = [dicInfo objectForKey:@"pubType" defalutObj:@""];
        self.blockId = [dicInfo stringValueForKey:@"blockId" defaultValue:@""];
    }
    return self;
}

// visitorTotal & hostTotal 服务器可能会返回number类型的数据 by jojo
- (void)setVisitorTotal:(NSString *)visitorTotal {
    if (_visitorTotal != visitorTotal) {
         //(_visitorTotal);
        _visitorTotal = [[NSString stringWithFormat:@"%d", [visitorTotal intValue]] copy];
    }
}

- (void)setHostTotal:(NSString *)hostTotal {
    if (_hostTotal != hostTotal) {
         //(_hostTotal);
        _hostTotal = [[NSString stringWithFormat:@"%d", [hostTotal intValue]] copy];
    }
}


@end

@implementation LiveCategoryItem

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.subId = [dict stringValueForKey:@"subId" defaultValue:nil];
        self.name = [dict stringValueForKey:@"name" defaultValue:nil];
        self.link = [dict stringValueForKey:@"link" defaultValue:nil];
    }
    return self;
}


@end

@implementation CommentFloor

@synthesize ID;
@synthesize commentJson;
@synthesize ctime;
@synthesize commentId;
@synthesize newsId;
@synthesize type;
@synthesize topicId;
@synthesize newsType;
@synthesize digNum;
@synthesize hadDing;
@synthesize createAt;


@end

@implementation City

@synthesize city; // 城市名
@synthesize code; // 城市代码，用于请求天气时用
@synthesize gbcode; // 城市的国标码
@synthesize index; // 城市首字母索引
@synthesize province; // 省份


@end

@implementation WeatherReport

@synthesize ID;
@synthesize city;
@synthesize cityCode;
@synthesize cityGbcode;
@synthesize shareLink;
@synthesize weatherIndex;
@synthesize chuanyi; // 穿衣指数
@synthesize date; // 日期
@synthesize chineseDate;
@synthesize ganmao; // 感冒指数
@synthesize jiaotong; // 交通指数
@synthesize lvyou; // 旅游建议 
@synthesize platformId; // ?
@synthesize tempHigh; // 最高气温 
@synthesize tempLow; // 最低气温
@synthesize weather; // 天气
@synthesize weatherIconUrl = weatherIoc; //
@synthesize weatherLocalIconUrl = weatherLocalIoc; //
@synthesize wind; // 风力
@synthesize wuran = wuranservice; // 污染指数
@synthesize yundong; // 运动
@synthesize pm25;
@synthesize quality;
@synthesize copywriting;
@synthesize morelink;

- (id)initWithDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.chineseDate = [dict stringValueForKey:@"chineseDate" defaultValue:@""];
        self.chuanyi = [dict stringValueForKey:@"chuanyi" defaultValue:@""];
        self.date = [dict stringValueForKey:@"date" defaultValue:@""];
        self.ganmao = [dict stringValueForKey:@"ganmao" defaultValue:@""];
        self.jiaotong = [dict stringValueForKey:@"jiaotong" defaultValue:@""];
        self.lvyou = [dict stringValueForKey:@"lvyou" defaultValue:@""];
        self.platformId = [dict stringValueForKey:@"platformId" defaultValue:@""];
        self.tempHigh = [dict stringValueForKey:@"tempHigh" defaultValue:@""];
        self.tempLow = [dict stringValueForKey:@"tempLow" defaultValue:@""];
        self.weather = [dict stringValueForKey:@"weather" defaultValue:@""];
        self.weatherIconUrl = [dict stringValueForKey:@"weatherLocalIoc" defaultValue:@""];
        self.weatherLocalIconUrl = [dict stringValueForKey:@"background" defaultValue:@""];
        self.wind = [dict stringValueForKey:@"wind" defaultValue:@""];
        self.wuran = [dict stringValueForKey:@"wuranservice" defaultValue:@""];
        self.yundong = [dict stringValueForKey:@"yundong" defaultValue:@""];
        self.pm25 = [dict stringValueForKey:@"pm25" defaultValue:@""];
        self.quality = [dict stringValueForKey:@"quality" defaultValue:@""];
        NSDictionary *shareDic = [dict dictionaryValueForKey:@"shareRead" defalutValue:nil];
        if (shareDic) {
            self.shareContent = [shareDic stringValueForKey:@"content" defaultValue:nil];
            self.ugcWordLimit = [shareDic intValueForKey:@"ugcWordLimit" defaultValue:0];
        }
    }
    return self;
}


@end

@implementation VotesInfo

@synthesize ID,newsID, topicID, isVoted, voteXML, isOver, createAt;

- (id)init {
    self = [super init];
    if (self) {
        self.newsID = @"";
        self.topicID = @"";
        self.isVoted = @"";
        self.voteXML = @"";
        self.isOver = @"";
    }
    return self;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"%@:\nnewsID=%@\ntopicID=%@\nisVoted=%@\nisOver=%@\nvoteXML=%@",
            NSStringFromClass([self class]),
            self.newsID,
            self.topicID,
            self.isVoted,
            self.isOver,
            self.voteXML];
}

@end

// 微热议
@implementation WeiboHotItem
@synthesize ID,weiboId, nick, head, homeUrl, wapUrl, isVip, time, title, type, icon, commentCount, content, abstract, focusPic, weight, userJson, pageNo, readMark, usersList = _usersList;
@synthesize newsId, resourceList, shareContent, cellHeight;
@synthesize createAt;
@synthesize isDownloadFinished;

- (BOOL)isEqual:(id)object {
    if (!object) {
        return NO;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    return [self.weiboId isEqualToString:[(WeiboHotItem *)object weiboId]];
}

- (NSUInteger)hash {
    return [self.weiboId integerValue];
}


- (void)setUserJson:(NSString *)json {
    userJson = [json copy];
    [self usersList];
}

- (NSArray *)usersList {
    if (_usersList && [_usersList count] > 0) {
        return _usersList;
    }
    
    if ([self.userJson length] > 0) {
        NSError *error = nil;
        id json = [self.userJson yajl_JSON:&error];
        if (error) {
            SNDebugLog(@"%@--%@ json serialize failed with error:%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription]);
            return nil;
        }
        if (json && [json isKindOfClass:[NSArray class]]) {
            NSMutableArray *users = [NSMutableArray array];
            int index = 0;
            for (NSDictionary *userObj in json) {
                if (index >= 5) {
                    break;
                }
                if ([userObj isKindOfClass:[NSDictionary class]]) {
                    WeiboHotUserItem *userItem = [[WeiboHotUserItem alloc] init];
                    userItem.userId = [userObj stringValueForKey:@"id" defaultValue:@""];
                    userItem.nick = [userObj stringValueForKey:@"nick" defaultValue:@""];
                    userItem.head = [userObj stringValueForKey:@"head" defaultValue:@""];
                    userItem.isVip = [userObj stringValueForKey:@"isVip" defaultValue:@""];
                    [users addObject:userItem];
                    index++;
                }
            }
            _usersList = [[NSArray alloc] initWithArray:users];
            return _usersList;
        }
    }
    return nil;
}

@end

@implementation WeiboHotUserItem
@synthesize userId, head, nick, isVip;


@end

@implementation WeiboHotItemDetail
@synthesize ID,weiboId,nick,isVip,head,homeUrl,title,time,weiboType,source,commentCount,content,newsId,wapUrl,shareContent,resourceJSON,resourceList,cellHeight, createAt,stpAudCmtRsn;

- (NSArray *)resourceList
{
    return [self.resourceJSON yajl_JSON];
}


@end


@implementation WeiboHotCommentItem

@synthesize ID, commentId, head, type, homeUrl, spaceLink, pid, linkStyle, nick, isVip, time, content, weiboId, cellHeight, createAt, audUrl, audLen;
@synthesize image,imageSmall,imageBig, userComtId ,gender;
@synthesize isOpenComment;


- (BOOL)isSameWith:(WeiboHotCommentItem *)obj {
    if ([commentId isEqualToString:obj.commentId]) {
        return YES;
    }
    if([userComtId isEqualToString:obj.userComtId])
    {
        return YES;
    }
    // 5分钟之内内容相同，认为是同一条
    if ([content isEqualToString:obj.content] &&
        ABS([time longLongValue] - [obj.time longLongValue]) < 5 * 60 * 1000 ) {
        return YES;
    }
    
    return NO;
}

- (BOOL)hasImage{
    if (imageSmall && imageSmall.length > 0) {
        return YES;
    }else{
        return NO;
    }
}

@end

@implementation SearchHistoryItem
@synthesize content,time,isClear;

- (NSString *)description {
    return [NSString stringWithFormat:@"%@:content = %@ time = %@", NSStringFromClass([self class]), content, time];
}

@end

@implementation SearchSuggestItem
@synthesize content;
@synthesize keyword;

@end

