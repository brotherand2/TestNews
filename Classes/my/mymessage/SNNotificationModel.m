//
//  SNNotificationModel.m
//  sohunews
//
//  Created by weibin cheng on 13-6-24.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//
#define CELL_CONTENT_FONT_SIZE 12
#define CELL_CONTENT_WIDTH 190
#define CELL_CONTENT_HEIGHT 15

#define kSNNotificationPid (@"pid")
#define kSNNotificationMsgid (@"msgId")
#define kSNNotificationType (@"type")
#define kSNNotificationAlert (@"alert")
#define kSNNotificationNickName (@"fnickName")
#define KSNNotificationHeadUrl (@"fheadurl")
#define kSNNotificationData (@"data")
#define kSNNotificationTime (@"time")
#define kSNNotificationUrl  (@"url")

#define kSNMaxNotificationId (@"maxnotificaitonid")
#define kSNNotificationTimerInterval (30*1)


#import "SNURLDataResponse.h"

#import "NSObject+YAJL.h"

#import "SNNotificationModel.h"
#import "SNDataBase_Notification.h"
#import "SNDBManager.h"
#import "NSDictionaryExtend.h"
#import "SNCheckManager.h"
#import "SNUserManager.h"
#import "NSDictionaryExtend.h"


@implementation SNNotificationItem
@synthesize pid = _pid;
@synthesize msgid = _msgid;
@synthesize type = _type;
@synthesize alert = _alert;
@synthesize nickName = _nickName;
@synthesize dataPid = _dataPid;
@synthesize headUrl = _headUrl;
@synthesize time = _time;
@synthesize ID = _ID;
@synthesize height = _height;

-(void)parseNotificationDic:(NSDictionary*) dic
{
//    self.pid = [dic objectForKey:kSNNotificationPid];
//    self.msgid = [dic objectForKey:kSNNotificationMsgid];
    self.type = [dic stringValueForKey:kSNNotificationType defaultValue:nil];
    self.alert = [dic stringValueForKey:kSNNotificationAlert defaultValue:nil];
    self.time = [dic stringValueForKey:kSNNotificationTime defaultValue:nil];
    self.nickName = [dic stringValueForKey:kSNNotificationNickName defaultValue:nil];
    self.headUrl = [dic stringValueForKey:KSNNotificationHeadUrl defaultValue:nil];
    self.url = [dic stringValueForKey:kSNNotificationUrl defaultValue:nil];
//    NSDictionary* dataDic = [dic objectForKey:kSNNotificationData];
//    if(dataDic)
//    {
//        self.dataPid = [dataDic objectForKey:kSNNotificationPid];
//        self.nickName = [dataDic objectForKey:kSNNotificationNickName];
//        self.headUrl = [dataDic objectForKey:KSNNotificationHeadUrl];
//    }
}

-(BOOL)isSupportNotification
{
//    int type = [self.type intValue];
//    if(type==21 || type==22)
//        return YES;
//    else
//        return NO;
    return YES;
}

-(NSInteger)height
{
    if(_height > 0)
        return _height;
    if([self.alert length] == 0)
        return 58;
     if(self.nickName.length > 0)
    {
        CGSize size = [self.alert sizeWithFont:[UIFont systemFontOfSize:CELL_CONTENT_FONT_SIZE]];
        int line = size.width / CELL_CONTENT_WIDTH;
        if(((int)size.width) % CELL_CONTENT_WIDTH == 0)
        {
            --line;
        }
        return 58 + line*CELL_CONTENT_HEIGHT;
    }
    else
    {
        return 58;
    }
}
@end

@implementation SNNotificationModel
@synthesize itemArray = _itemArray;
@synthesize notificationRequest = _notificationRequest;
@synthesize notificationDelegate = _notificationDelegate;
@synthesize nextCursor = _nextCursor;
@synthesize preCursor = _preCursor;
@synthesize allNum = _allNum;
@synthesize hasMore = _hasMore;
//+(SNNotificationModel*)shareNotificationModel
//{
//    @synchronized(self){
//        if(shareNotificaionModel == nil)
//        {
//            shareNotificaionModel = [[SNNotificationModel alloc] init];
//            [shareNotificaionModel loadAllLocalNotification];
//        }
//    }
//    return shareNotificaionModel;
//}
-(id)init
{
    self = [super init];
    if(self)
    {
        _itemArray  = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void)dealloc
{
    [_notificationRequest cancel];
}

-(void)loadAllLocalNotification
{
    if(_itemArray)
       [_itemArray removeAllObjects];
    NSArray* array = [[SNDBManager currentDataBase] getAllNotification];
    [_itemArray addObjectsFromArray:array];
}
-(void)removeAllNotification
{
    [_itemArray removeAllObjects];
}

-(NSDate*)getLastRefreshDate
{
    return _refreshDate;
}
-(BOOL)isNotificationItemExist:(NSString *)msgId
{
    for(SNNotificationItem* item in _itemArray)
    {
        if([item.msgid isEqualToString:msgId])
            return YES;
    }
    return NO;
}

-(void)parseTimelineArray:(NSArray*)array
{
    if(![SNUserManager isLogin])
        return;
    for(NSString* str in array)
    {
        NSDictionary* dic = [str yajl_JSON];
        //NSString* pid = [dic stringValueForKey:kSNNotificationPid defaultValue:@""];
        //if([pid isEqualToString:userinfo._pid])
        {
            SNNotificationItem* model = [[SNNotificationItem alloc] init];
            [model parseNotificationDic:dic];
            if(![self isNotificationItemExist:model.msgid])
            {
                [_itemArray addObject:model];
            }
        }
    }
}

-(void)parseNotiArray:(NSArray*)array
{
    if(![SNUserManager isLogin])
        return;
    int maxMsgId = [SNNotificationModel getMaxMsgId];
    int replyMsgCount = 0;
    int notificationMsgCount = 0;
    int socialMsgCount = 0;
    NSMutableArray* modelArray = [NSMutableArray arrayWithCapacity:5];
    for(NSString* str in array)
    {
        NSDictionary* dic = [str yajl_JSON];
        int type = [[dic objectForKey:kSNNotificationType] intValue];
        NSString* msgId = [dic objectForKey:kSNNotificationMsgid];
        if(msgId && [msgId intValue] > maxMsgId)
            maxMsgId = [msgId intValue];
        NSString* pid = [dic objectForKey:kSNNotificationPid];
        if(![pid isEqualToString:[SNUserManager getPid]])
            continue;
        if((type == 1) || (type == 2) || (type == 3))
            continue;
        else if((type == 21) || (type == 22))
        {
            NSString* pid = [dic objectForKey:kSNNotificationPid];
            if([pid isEqualToString:[SNUserManager getPid]])
            {
                SNNotificationItem* model = [[SNNotificationItem alloc] init];
                [model parseNotificationDic:dic];
                if(![self isNotificationItemExist:model.msgid])
                {
                    [modelArray addObject:model];
                    [[SNDBManager currentDataBase] addSingleNotification:model];
                }
            }
            ++notificationMsgCount;
            ++socialMsgCount;
            continue;
        }
        else if(type == 23)
        {
            ++socialMsgCount;
            continue;
        }
        else if((type == 24) || (type == 25))
        {
            ++socialMsgCount;
            ++replyMsgCount;
            continue;
        }
        else if(type == 51)
        {
            ++replyMsgCount;
            continue;
        }
        else if([SNCheckManager checkNewVersion])
        {
            NSString* pid = [dic objectForKey:kSNNotificationPid];
            if([pid isEqualToString:[SNUserManager getPid]])
            {
                SNNotificationItem* model = [[SNNotificationItem alloc] init];
                [model parseNotificationDic:dic];
                if(![self isNotificationItemExist:model.msgid])
                {
                    [modelArray addObject:model];
                    [[SNDBManager currentDataBase] addSingleNotification:model];
                }
            }
        }
    }
    if(socialMsgCount > 0)
    {
        NSNumber* number = [NSNumber numberWithInteger:socialMsgCount];
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:number, kSNMessgeNum,nil];
        [SNNotificationManager postNotificationName:kSNSocialMessageNotification object:nil userInfo:dic];
    }
//    if(replyMsgCount > 0)
//        [SNUtility getApplicationDelegate].toMeCommentNum = replyMsgCount;
//    if(notificationMsgCount > 0)
//        [SNUtility getApplicationDelegate].notificationNum = notificationMsgCount;
    [self saveMaxMsgId:[NSString stringWithFormat:@"%d", maxMsgId]];
    if([modelArray count] == 0)
        return;
    if([_itemArray count] > 0)
    {
        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [modelArray count])];
        [_itemArray insertObjects:modelArray atIndexes:indexSet];
    }
    else
    {
        [_itemArray addObjectsFromArray:modelArray];
    }
}
//-(void)requestNewNotification
//{
//    if(self.notificationRequest)
//    {
//        [self.notificationRequest cancel];
//        self.notificationRequest = nil;
//    }
//    NSString* url = [SNUtility addParamsToURLForReadingCircle:SNLinks_Path_PPNotify];
////    int msgId = [SNNotificationModel getMaxMsgId];
////    if(msgId >= 0)
////    {
////        url = [NSString stringWithFormat:@"%@&maxMsgId=%d", url, msgId];
////    }
//    SNDebugLog(@"%@", url);
//    
//    SNURLRequest* request = [SNURLRequest requestWithURL:url delegate:self];
//    request.cachePolicy = TTURLRequestCachePolicyNoCache;
//    request.timeOut = 30;
//    request.response = [[SNURLDataResponse alloc] init];
//    [request send];
//    self.notificationRequest = request;
//}

- (void)requestNewNotification {
    
    if(self.notificationRequest)
    {
        [self.notificationRequest cancel];
        self.notificationRequest = nil;
    }
    self.notificationRequest = [[SNNotifyTimeLineRequest alloc] initWithDictionary:[SNUtility paramsDictionaryForReadingCircle]];
    __weak typeof(self)weakself = self;
    [self.notificationRequest send:^(SNBaseRequest *request, id responseObject) {
        [weakself requestDidFinishLoadWithResponse:responseObject];
    } failure:^(SNBaseRequest *request, NSError *error) {
        [weakself requestDidFailLoadWithError:error];
    }];
}

-(BOOL)isSupportNotification:(NSInteger)index
{
    if(index >= 0 && index < [_itemArray count])
    {
        SNNotificationItem* item = [_itemArray objectAtIndex:index];
        return [item isSupportNotification];
    }
    else
        return NO;
}

-(SNNotificationItem*)getNotificationItem:(NSInteger)index
{
    if(index >= 0 && index < [_itemArray count])
    {
        SNNotificationItem* item = [_itemArray objectAtIndex:index];
        return item;
    }
    else
        return nil;
}
+(NSString*)generateMaxMsgKey
{
    
    if([SNUserManager isLogin])
    {
        if(![[SNUserManager getPid] isEqualToString:@"-1"])
        {
            NSString* str = [NSString stringWithFormat:@"snmaxmsgid_%@", [SNUserManager getPid]];
            return str;
        }
        else
            return nil;
    }
    else
        return nil;
}

+(int)getMaxMsgId
{
    //为了每个用户记录唯一的key，采用新的generateMaxMsgKey，并且兼容以前的key
    if([SNNotificationModel generateMaxMsgKey])
    {
        NSString* newMaxMsg = [[NSUserDefaults standardUserDefaults] objectForKey:[SNNotificationModel generateMaxMsgKey]];
        if(newMaxMsg && [newMaxMsg length]>0)
            return [newMaxMsg intValue];
    }
    
    NSString* maxMsg = [[NSUserDefaults standardUserDefaults] objectForKey:kSNMaxNotificationId];
    if(maxMsg && [maxMsg length]>0)
        return [maxMsg intValue];
    else
        return -1;
}
+(void)resetMaxMsgId
{
//    NSString* key = [SNNotificationModel generateMaxMsgKey];
//    if(key)
//    {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
//    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSNMaxNotificationId];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)saveMaxMsgId:(NSString*)str
{
    if(str && [SNNotificationModel generateMaxMsgKey])
    {
        //[[NSUserDefaults standardUserDefaults] setObject:str forKey:kSNMaxNotificationId];
        [[NSUserDefaults standardUserDefaults] setObject:str forKey:[SNNotificationModel generateMaxMsgKey]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
-(void)reset
{
    if(self.notificationRequest)
    {
        [self.notificationRequest cancel];
        self.notificationRequest = nil;
    }
    [_itemArray removeAllObjects];
    self.preCursor = nil;
    self.nextCursor = nil;
    self.allNum = 0;
    _hasMore = NO;
}

//-(void)refresh
//{
//    [self reset];
//    //NSString* url = [SNUtility addParamsToURLForReadingCircle:SNLinks_Path_PPNotify];
//    SNURLRequest* request = [SNURLRequest requestWithURL:SNLinks_Path_PPNotify delegate:self];
//    request.cachePolicy = TTURLRequestCachePolicyNoCache;
//    request.timeOut = 30;
//    request.response = [[SNURLDataResponse alloc] init];
//    [request send];
//    self.notificationRequest = request;
//}

-(void)refresh {
    [self reset];
    self.notificationRequest = [[SNNotifyTimeLineRequest alloc] init];
    __weak typeof(self)weakself = self;
    [self.notificationRequest send:^(SNBaseRequest *request, id responseObject) {
        [weakself requestDidFinishLoadWithResponse:responseObject];
    } failure:^(SNBaseRequest *request, NSError *error) {
        [weakself requestDidFailLoadWithError:error];
    }];
}


//-(void)loadMore
//{
//    if(!_hasMore)
//        return;
//    NSString* url = [NSString stringWithFormat:@"%@&nextCursor=%@", SNLinks_Path_PPNotify, self.nextCursor];
//    SNURLRequest* request = [SNURLRequest requestWithURL:url delegate:self];
//    request.cachePolicy = TTURLRequestCachePolicyNoCache;
//    request.timeOut = 30;
//    request.response = [[SNURLDataResponse alloc] init];
//    [request send];
//    self.notificationRequest = request;
//}

-(void)loadMore {
    if(!_hasMore) return;
    self.notificationRequest = [[SNNotifyTimeLineRequest alloc] initWithDictionary:@{@"nextCursor":self.nextCursor}];
    __weak typeof(self)weakself = self;
    [self.notificationRequest send:^(SNBaseRequest *request, id responseObject) {
        [weakself requestDidFinishLoadWithResponse:responseObject];
    } failure:^(SNBaseRequest *request, NSError *error) {
        [weakself requestDidFailLoadWithError:error];
    }];
}

- (void)requestDidFinishLoadWithResponse:(id)responseObject {
    _refreshDate = [[NSDate alloc] init];
    
    if(responseObject == nil) return;
    //NSDictionary* result = [dic objectForKey:@"result"];
    int count = 0;
    //if([[result objectForKey:@"code"] intValue] == 200)
    {
        NSArray* notiArray = [responseObject objectForKey:@"notifys"];
        if([notiArray isKindOfClass:[NSArray class]])
        {
            if([notiArray count] > 0)
            {
                _hasMore = YES;
                count  = (int)[notiArray count];
                [self parseTimelineArray:notiArray];
            }
            else
            {
                _hasMore = NO;
            }
        }
    }
    self.preCursor = [responseObject stringValueForKey:@"preCursor" defaultValue:@""];
    self.nextCursor = [responseObject stringValueForKey:@"nextCursor" defaultValue:@""];
    self.allNum = [responseObject intValueForKey:@"allNum" defaultValue:0];
    _hasMore = ![_preCursor isEqualToString:_nextCursor];
    if(_notificationDelegate && [_notificationDelegate respondsToSelector:@selector(didFinishLoadNotificaiton:)])
    {
        [_notificationDelegate didFinishLoadNotificaiton:count];
    }

}

-(void)requestDidFailLoadWithError:(NSError *)error {
    if(_notificationDelegate && [_notificationDelegate respondsToSelector:@selector(didFailLoadWithError:)])
    {
        [_notificationDelegate didFailLoadWithError:error];
    }
}



//#pragma -mark TTURLRequestDelegate
//-(void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error
//{
//    if(_notificationDelegate && [_notificationDelegate respondsToSelector:@selector(didFailLoadWithError:)])
//    {
//        [_notificationDelegate didFailLoadWithError:error];
//    }
//}
//
//-(void)requestDidFinishLoad:(TTURLRequest *)request
//{
//    _refreshDate = [[NSDate alloc] init];
//    SNURLDataResponse* response = request.response;
//    NSDictionary* dic = [response.data yajl_JSON];
//    SNDebugLog(@"%@", dic);
//    if(dic == nil)
//        return;
//    //NSDictionary* result = [dic objectForKey:@"result"];
//    int count = 0;
//    //if([[result objectForKey:@"code"] intValue] == 200)
//    { 
//        NSArray* notiArray = [dic objectForKey:@"notifys"];
//        if([notiArray isKindOfClass:[NSArray class]])
//        {
//            if([notiArray count] > 0)
//            {
//                _hasMore = YES;
//                count  = (int)[notiArray count];
//                [self parseTimelineArray:notiArray];
//            }
//            else
//            {
//                _hasMore = NO;
//            }
//        }
//    }
//    self.preCursor = [dic stringValueForKey:@"preCursor" defaultValue:@""];
//    self.nextCursor = [dic stringValueForKey:@"nextCursor" defaultValue:@""];
//    self.allNum = [dic intValueForKey:@"allNum" defaultValue:0];
//    _hasMore = ![_preCursor isEqualToString:_nextCursor];
//    if(_notificationDelegate && [_notificationDelegate respondsToSelector:@selector(didFinishLoadNotificaiton:)])
//    {
//        [_notificationDelegate didFinishLoadNotificaiton:count];
//    }
//}
//
//-(void)requestDidCancelLoad:(TTURLRequest *)request
//{
//    
//}
@end
