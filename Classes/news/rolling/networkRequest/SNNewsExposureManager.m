//
//  SNNewsExposureManager.m
//  sohunews
//
//  Created by lhp on 3/28/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNNewsExposureManager.h"
#import "SNURLJSONResponse.h"
#import "SNUserManager.h"
#import "NSObject+YAJL.h"

#define kExposureFileName   (@"exposureNewsLink")

#define kExposureRequestInterval        10*60

static NSString * _dataFilePath() {
    NSArray *arr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = nil;
    if ([arr count] > 0) {
        filePath = [[arr objectAtIndex:0] stringByAppendingPathComponent:kExposureFileName];
    }
    return filePath;
}

typedef enum {
    NewsFromRecommend,                  //频道推荐
    NewsFromChannel,                    //频道新闻
    NewsFromSearch,                     //搜索
    NewsFromArticleRecommend,           //正文推荐
    NewsFromChannelSubscribe,           //频道刊物
    AdFromSquare,                       //广场广告
    AdFromBigPicture,                   //大图广告
    AdFromLoadingPage,                  //loading页广告
    liveFromLink,                       //直播间跳转链接
}SNNewsExposureFromType;

@interface SNNewsExposure: NSObject {
    SNNewsExposureFromType fromType;
    NSString *channelId;
    NSMutableArray *idListArray;
}
@property(nonatomic,assign)SNNewsExposureFromType fromType;
@property(nonatomic,strong)NSString *channelId;
@property (nonatomic, strong) NSMutableArray *idListArray;

- (void)recordWithNewsId:(NSString *) newId;
- (NSString *)getRecordString;
- (void)removeAllRecord;

@end

@implementation SNNewsExposure

@synthesize fromType;
@synthesize channelId;
@synthesize idListArray;

- (id)init
{
    self = [super init];
    if (self) {
        self.idListArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)exposureFromString
{
    NSString *fromString = nil;
    switch (fromType) {
        case NewsFromChannel:
            fromString = @"0";
            break;
        case NewsFromRecommend:
            fromString = @"1";
            break;
        case NewsFromArticleRecommend:
            fromString = @"2";
            break;
        case NewsFromSearch:
            fromString = @"3";
            break;
        case NewsFromChannelSubscribe:
            fromString = @"4";
            break;
        case AdFromSquare:
            fromString = @"5";
            break;
        case AdFromBigPicture:
            fromString = @"6";
            break;
        case AdFromLoadingPage:
            fromString = @"7";
            break;
        case liveFromLink:
            fromString = @"8";
            break;
        default:
            fromString = @"0";
            break;
    }
    return fromString;
}

- (NSString *)getRecordString
{
    NSString *recordString = nil;
    if (self.idListArray.count > 0) {
        NSString *fromString = [self exposureFromString];
        NSString *allIdString = [self getAllIdString];
        recordString = [NSString stringWithFormat:@"%@|%@|%@", fromString, self.channelId, allIdString];
    }
    return recordString;
}

- (NSString *)getAllIdString
{
//    NSString *idListString = nil;
//    for (NSString *idString in self.idListArray) {
//        idListString = !idListString ? idString : [idListString stringByAppendingFormat:@",%@", idString];
//    }
//    idListString = !idListString?@"":idListString;
    NSMutableString *idListString = [[NSMutableString alloc] init];
    [idListString setString:@""];
    for (NSString *idString in idListArray) {
        if([idListString length] <= 0){
            [idListString appendString:idString];
        }else{
            [idListString appendString:[NSString stringWithFormat:@",%@",idString]];
        }
    }
    return idListString;
}

- (void)recordWithNewsId:(NSString *) newId
{
    if (newId.length > 0) {
        [self.idListArray addObject:newId];
    }
}

- (void)removeAllRecord
{
    [self.idListArray removeAllObjects];
}

- (void)dealloc
{
}

@end

#define kRecommendExposureKey               @"kRecommendExposureKey"
#define kSearchExposureKey                  @"kSearchExposureKey"
#define kArticleRecommendKey                @"kArticleRecommendKey"
#define kChannelSubscribeKey                @"kChannelSubscribeKey"
#define kAdFromSquareKey                    @"kAdFromSquareKey"
#define kAdFromBigPictureKey                @"kAdFromBigPictureKey"
#define kAdFromLoadingPageKey               @"kAdFromLoadingPageKey"
#define kLiveFromLinkKey                    @"kLiveFromLinkKey"

@interface SNNewsExposureManager () {
    
    float timeInterval;
}

@property (nonatomic, strong) NSMutableDictionary *newsExposureDic;

@end


@implementation SNNewsExposureManager

+ (SNNewsExposureManager *)sharedInstance {
    static SNNewsExposureManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SNNewsExposureManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        sending = NO;
        timeInterval = [[NSDate date] timeIntervalSince1970];
        lastNewsDic = [[NSMutableDictionary alloc] init];
        self.newsExposureDic = [[NSMutableDictionary alloc] init];
        //[self readAllExposureNewsFromFile];
    }
    return self;
}

- (SNNewsExposureFromType)getNewsExposureFromTypeWithString:(NSString *) fromString
{
    int fromValue = [fromString intValue];
    SNNewsExposureFromType fromType;
    switch (fromValue) {
        case 0:
            fromType = NewsFromChannel;
            break;
        case 1:
            fromType = NewsFromRecommend;
            break;
        case 2:
            fromType = NewsFromArticleRecommend;
            break;
        case 3:
            fromType = NewsFromSearch;
            break;
        case 4:
            fromType = NewsFromChannelSubscribe;
            break;
        case 5:
            fromType = AdFromSquare;
            break;
        case 6:
            fromType = AdFromBigPicture;
            break;
        case 7:
            fromType = AdFromLoadingPage;
            break;
        case 8:
            fromType = liveFromLink;
            break;
        default:
            fromType = NewsFromChannel;
            break;
    }
    return fromType;
}

- (SNNewsExposure *)getNewsExposureWithForKey:(NSString *) key type:(SNNewsExposureFromType) fromType
{
    SNNewsExposure *newsExposure = [self.newsExposureDic objectForKey:key];
    if (!newsExposure) {
        newsExposure = [[SNNewsExposure alloc] init];
        newsExposure.fromType = fromType;
        [self.newsExposureDic setObject:newsExposure forKey:key];
    }
    return newsExposure;
}

- (NSString *)getNewsExposureIdWithTemplateType:(NSString *) templateType newsId:(NSString *) newsId
{
    NSString *newsExposureId = nil;
    if (templateType.length > 0) {
        int templateValue = [templateType intValue];
        switch (templateValue) {
            case 4:
                newsExposureId = @"w0";
                break;
            case 8:
                if (newsId.length > 0) {
                    newsExposureId = [NSString stringWithFormat:@"ty%@",newsId];
                }else {
                    newsExposureId = @"ty0";
                }
                break;
            case 10:
                newsExposureId = @"f0";
                break;
            case 11:
                if (newsId.length > 0) {
                    newsExposureId = [NSString stringWithFormat:@"a%@",newsId];
                }else {
                    newsExposureId = @"a0";
                }
                break;
            case 16:
                newsExposureId = @"m0";
                break;
            default:
                break;
        }
    }
    return newsExposureId;
}


- (NSString *)getNewsExposureIdWithLink:(NSString *) link queryDic:(NSDictionary *)queryDic
{
    NSString *newsExposureId = nil;
    NSString *newsId = [queryDic stringValueForKey:kNewsId defaultValue:@""];
    NSString *termId = [queryDic stringValueForKey:kTermId defaultValue:@""];
    NSString *subId = [queryDic stringValueForKey:kSubId defaultValue:@""];
    NSString *vedioId = [queryDic stringValueForKey:kVid defaultValue:@""];
    NSString *liveId = [queryDic stringValueForKey:kLiveIdKey defaultValue:@""];
    NSString *rootId = [queryDic stringValueForKey:kRootId defaultValue:@""];
    NSString *gId = [queryDic stringValueForKey:kGid defaultValue:@""];
    NSString *token = [queryDic stringValueForKey:kToken defaultValue:@""];
    NSString *position = [queryDic stringValueForKey:kPos defaultValue:@""];
    NSString *templateType = [queryDic stringValueForKey:kTemplateType defaultValue:@""];
    
    if ([link hasPrefix:kProtocolNews]) {
        newsExposureId = [NSString stringWithFormat:@"n%@",newsId];
    }else if([link hasPrefix:kProtocolLive]) {
        newsExposureId = [NSString stringWithFormat:@"l%@",liveId];
    }else if ([link hasPrefix:kProtocolPhoto]) {
        gId = [gId isEqualToString:@""] ? newsId : gId;
        newsExposureId = [NSString stringWithFormat:@"g%@",gId];
    }else if ([link hasPrefix:kProtocolWeibo]) {
        newsExposureId = [NSString stringWithFormat:@"r%@",rootId];
    }else if ([link hasPrefix:kProtocolVideo]) {
        newsExposureId = [NSString stringWithFormat:@"v%@",vedioId];
    }else if ([link hasPrefix:kProtocolPaper] || [link hasPrefix:kProtocolDataFlow]) {
        if (termId.length > 0) {
            newsExposureId = [NSString stringWithFormat:@"t%@",termId];
        }else if (subId.length > 0){
            newsExposureId = [NSString stringWithFormat:@"s%@",subId];
        }
    }else if ([link hasPrefix:kProtocolHTTP] || [link hasPrefix:kProtocolHTTPS]) {
        newsExposureId = [NSString stringWithFormat:@"h%@",newsId];
    }
    
    //特殊模板曝光统计ID
    if (templateType.length > 0) {
        NSString *exposureId = [self getNewsExposureIdWithTemplateType:templateType newsId:newsId];
        newsExposureId = exposureId ? exposureId : newsExposureId;
    }

    newsExposureId = [newsExposureId stringByAppendingFormat:@"_%@_%@_%@",token,templateType,position];
    return newsExposureId;
}

- (void)clearLastExposureNews
{
    [lastNewsDic removeAllObjects];
}

- (void)exposureNewsInfoWithDic:(NSDictionary *) newsDic
{
    if (newsDic.allKeys.count == 0) {
        return;
    }
    
    NSMutableDictionary *newExposureDic = [NSMutableDictionary dictionaryWithDictionary:newsDic];
    [newExposureDic removeObjectsForKeys:lastNewsDic.allKeys];
    for (NSString *key in newExposureDic.allKeys) {
        NSString *link = [newExposureDic objectForKey:key];
        if (link.length > 0) {
            NSRange range = [link rangeOfString:@"://"];
            if (range.length > 0) {
                NSDictionary *queryDic = [SNUtility getParemsInfoWithLink:link];
                [self recordNewsWithLink:link queryDic:queryDic addNewLink:YES];
            }
        }
    }
    
    if ([newsDic.allKeys count] >0) {
        [lastNewsDic removeAllObjects];
        [lastNewsDic setDictionary:newsDic];
    }
    
    [self checkExposureRequestSend];
}

- (void)exposureNewsInfoWithLink:(NSString *) newsLink
{
    if (newsLink.length > 0) {
        NSRange range = [newsLink rangeOfString:@"://"];
        if (range.length > 0) {
            NSDictionary *queryDic = [SNUtility getParemsInfoWithLink:newsLink];
            [self recordNewsWithLink:newsLink queryDic:queryDic addNewLink:YES];
        }
        [self checkExposureRequestSend];
    }
}

- (void)checkExposureRequestSend
{
    return;//lijian 2017.02.07，不用了该功能，废弃！

    float nowTime = [[NSDate date] timeIntervalSince1970];
    //曝光记录大于500条或时间间隔超过20分钟发送请求
//   float second = nowTime-timeInterval;
    if ((exposureNewsArray.count >= 500 || nowTime-timeInterval > kExposureRequestInterval) && !sending) {
        [self sendExposureRequest];
    }
}

- (NSMutableString *)getIdStringWith:(NSMutableString *) idString newId:(NSString *) newIdString
{
    if (idString) {
        [idString appendFormat:@",%@",newIdString];
    }else {
       idString = [NSMutableString stringWithString:newIdString];
    }
    return idString;
}

- (void)recordNewsWithLink:(NSString *) link queryDic:(NSDictionary *)queryDic addNewLink:(BOOL) addLink
{
    if ([queryDic.allKeys count] > 0) {
        NSString *from = [queryDic stringValueForKey:kExposureFrom defaultValue:@"0"];
        NSString *channelId = [queryDic stringValueForKey:kChannelId defaultValue:@""];
        NSString *exposureId = [self getNewsExposureIdWithLink:link queryDic:queryDic];
        NSString *channelKey = [NSString stringWithFormat:@"channel_%@",channelId];
        
        SNNewsExposureFromType fromType = [self getNewsExposureFromTypeWithString:from];
        SNNewsExposure *newsExposure = nil;
        switch (fromType) {
            case NewsFromChannel:
                newsExposure  = [self getNewsExposureWithForKey:channelKey type:NewsFromChannel];
                newsExposure.channelId = channelId;
                break;
            case NewsFromRecommend:
                newsExposure  = [self getNewsExposureWithForKey:kRecommendExposureKey type:NewsFromRecommend];
                newsExposure.channelId = channelId;
                break;
            case NewsFromArticleRecommend:
                newsExposure  = [self getNewsExposureWithForKey:kArticleRecommendKey type:NewsFromArticleRecommend];
                newsExposure.channelId = @"";
                break;
            case NewsFromSearch:
                newsExposure  = [self getNewsExposureWithForKey:kSearchExposureKey type:NewsFromSearch];
                newsExposure.channelId = @"";
                break;
            case NewsFromChannelSubscribe:
                newsExposure  = [self getNewsExposureWithForKey:kChannelSubscribeKey type:NewsFromChannelSubscribe];
                newsExposure.channelId = channelId;
                break;
            case AdFromSquare:
                newsExposure  = [self getNewsExposureWithForKey:kAdFromSquareKey type:AdFromSquare];
                newsExposure.channelId = @"";
                break;
            case AdFromBigPicture:
                newsExposure  = [self getNewsExposureWithForKey:kAdFromBigPictureKey type:AdFromBigPicture];
                newsExposure.channelId = @"";
                break;
            case AdFromLoadingPage:
                newsExposure  = [self getNewsExposureWithForKey:kAdFromLoadingPageKey type:AdFromLoadingPage];
                newsExposure.channelId = @"";
                break;
            case liveFromLink:
                newsExposure  = [self getNewsExposureWithForKey:kLiveFromLinkKey type:liveFromLink];
                newsExposure.channelId = @"";
                break;
            default:
                newsExposure  = [self getNewsExposureWithForKey:channelKey type:NewsFromChannel];
                newsExposure.channelId = channelId;
                break;
        }
        [newsExposure recordWithNewsId:exposureId];
        
        if (addLink) {
            [self addNewsRecordWithLink:link];
        }
    }
}

- (void)addNewsRecordWithLink:(NSString *) link
{
    if (link.length >0) {
        [exposureNewsArray addObject:link];
    }
}

- (void)readAllExposureNewsFromFile
{
    NSString *filePath = _dataFilePath();
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        exposureNewsArray = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    }
    if (!exposureNewsArray) {
        exposureNewsArray = [[NSMutableArray alloc] init];
    }
    
    for (NSString *link in exposureNewsArray) {
        if (link.length > 0) {
            NSRange range = [link rangeOfString:@"://"];
            if (range.length > 0) {
                NSDictionary *queryDic = [SNUtility getParemsInfoWithLink:link];
                [self recordNewsWithLink:link queryDic:queryDic addNewLink:NO];
            }
        }
    }
}

- (void)saveAllExposureNewsToFile
{
    NSString *filePath = _dataFilePath();
    [exposureNewsArray writeToFile:filePath atomically:YES];//只存不删？
}

//发现上面这个东西只存不删的啊、？？ 做个清理的方法
- (void)clearAllExposureNewsInFile {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSFileManager * fm = [NSFileManager defaultManager];
        NSString * filePath = _dataFilePath();
        if ([fm fileExistsAtPath:filePath]) {
            [fm removeItemAtPath:filePath error:nil];
        }
    });
}

- (void)sendExposureRequest// 已经不再调用这个方法，涉及TT请求暂时不做修改.liteng 2017.2.20
{
    NSString *recordString = nil;
    for (NSString *exposureKey in self.newsExposureDic.allKeys) {
        SNNewsExposure *newsExposure = [self.newsExposureDic objectForKey:exposureKey];
        NSString *exposureRecord = [newsExposure getRecordString];
        if (exposureRecord) {
            recordString = !recordString?exposureRecord:[recordString stringByAppendingFormat:@"@%@",exposureRecord];
        }
    }
    
    if (recordString.length > 0) {
        sending = YES;
   
        NSString *urlFull = SNLinks_Path_News_Exposure;
        if(!exposureRequest) {
            exposureRequest = [TTURLRequest requestWithURL:urlFull delegate:self];
            exposureRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
        } else {
            [exposureRequest cancel];
            exposureRequest.urlPath = urlFull;
        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        if ([SNUserManager getP1]) {
            [params setObject:[SNUserManager getP1] forKey:@"p1"];
        }
        [params setObject:recordString forKey:@"value"];
        
        NSMutableString* postBodyString = [NSMutableString stringWithString:@""];
        for (NSString *key in [params allKeys]) {
            NSString* p = [NSString stringWithFormat:@"%@=%@",key,[[params valueForKey:key] URLEncodedString]];
            if([postBodyString length]==0)
                [postBodyString appendString:p];
            else
                postBodyString = [NSMutableString stringWithFormat:@"%@&%@",postBodyString,p];
        }
		
        exposureRequest.response = [[SNURLJSONResponse alloc] init];
        [exposureRequest setHttpMethod:@"POST"];
        [exposureRequest setContentType:@"application/x-www-form-urlencoded"];
        [exposureRequest setHttpBody:[postBodyString dataUsingEncoding:NSUTF8StringEncoding]];
        [exposureRequest send];
    }
}

#pragma mark -
#pragma mark TTURLRequestDelegate

- (void)requestDidFinishLoad:(TTURLRequest*)request
{
    sending = NO;
    timeInterval = [[NSDate date] timeIntervalSince1970];
    
    //清空缓存
    [exposureNewsArray removeAllObjects];
    [self saveAllExposureNewsToFile];
    
    for (NSString *exposureKey in self.newsExposureDic.allKeys) {
        SNNewsExposure *newsExposure = [self.newsExposureDic objectForKey:exposureKey];
        [newsExposure removeAllRecord];
    }
    
    SNDebugLog(@"ExposureNews succeed!");
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    sending = NO;
    SNDebugLog(@"ExposureNews failed!");
}

- (void)dealloc
{
    [exposureRequest cancel];
}

@end
