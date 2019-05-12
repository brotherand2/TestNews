//
//  SNShareList.m
//  sohunews
//
//  Created by yanchen wang on 12-5-28.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "CacheObjects.h"
#import "SNDBManager.h"
#import "SNShareList.h"
#import "UIDevice-Hardware.h"
//#import "SNURLJSONResponse.h"
#import "NSDictionaryExtend.h"
#import "SNThemeManager.h"
#import "SNUserinfo.h"
#import "SNClientRegister.h"
#import "SNShareConfigs.h"
//#import "ASIHTTPRequest.h"
#import "SNGetThirdAppListRequest.h"

#define kShareListExpire    (60 * 60 * 24)
#define KeyForEnableShareItem(ITEM_ID) [NSString stringWithFormat:@"shareItemId_%@", (ITEM_ID)]
#define kShareListRefreshTopic          (@"kShareListRefreshTopic")


@interface SNShareList ()

- (void)refreshList;
- (void)setShareItemAppLevel:(ShareListItem *)item;

// 老版拍客数据迁移 会导致获取分享列表一直失败  需要强制注销重新获取一次
- (void)recoverShareList;

@end

@implementation SNShareList

@synthesize shareListState = _shareListState;
@synthesize shareList = _shareList;
@synthesize delegate = _delegate;
//@synthesize refreshRequest = _refreshRequest;

- (id)init {
    self = [super init];
    if (self) {
        _shareList = [[SNDBManager currentDataBase] shareList];
        if (_shareList && [_shareList count] > 0) {
            _shareListState &= 1<<ShareListReady;
        }
        else {
            _shareListState &= 1<<ShareListNoCache;
        }
    }
    return self;
}

- (void)dealloc {

}

/////////////////////////////////////////<-- private methods
- (void)refreshList {


    if (![[SNClientRegister sharedInstance] isRegisted]) {//确保p1有值
        [[SNClientRegister sharedInstance] registerClientAnywaySuccess:^(SNBaseRequest *request) {
            [self doRequest];
        } fail:^(SNBaseRequest *request, NSError *error) {
            [self doRequest];
        }];
    } else {
        [self doRequest];
    }
}

- (void)doRequest {

    
    [[[SNGetThirdAppListRequest alloc] init] send:^(SNBaseRequest *request, id jsonObj) {
        
        if ([jsonObj isKindOfClass:[NSArray class]]) {
            
            [self restoreShareListData:(NSArray *)jsonObj];
        }
        else if ([jsonObj isKindOfClass:[NSDictionary class]]) {
            // 服务器改了数据结构 有可能返回字典类型的数据
            NSDictionary *dic = jsonObj;
            
            NSArray *listArray = [dic arrayValueForKey:@"appList" defaultValue:nil];
            [self restoreShareListData:listArray];
        }
        
        if ([_shareList count] > 0 && [_delegate respondsToSelector:@selector(refreshShareListSucc)]) {
            [_delegate refreshShareListSucc];
        }
        else if ([_delegate respondsToSelector:@selector(refreshShareListGetNoData)]) {
            [_delegate refreshShareListGetNoData];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@-->%@ : error %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription]);
        _shareListState &= 1<<ShareListFail;
        if ([_delegate respondsToSelector:@selector(refreshShareListFail)]) {
            [_delegate refreshShareListFail];
        }
    }];
}

- (NSString *)loginTypeStrForAppId:(NSString *)appId {
    int appIntId = [appId intValue];
    
    switch (appIntId) {
        case 1: return @"sina";
        case 2: return @"t.qq";
        case 3: return @"";
        case 4: return @"renren";
        case 5: return @"kaixin";
        case 6: return @"qq";
        case 8: return @"wechat";
        default:
            break;
    }
    
    return @"";
}


- (void)restoreShareListData:(NSArray *)itemList {
    if ([itemList count] > 0) {
        NSMutableArray *mutArr = [[NSMutableArray alloc] initWithCapacity:6];
        for (NSDictionary *dicInfo in itemList) {
            ShareListItem *item = [[ShareListItem alloc] init];
            item.status = [NSString stringWithFormat:@"%d", [[dicInfo objectForKey:@"status" defalutObj:[NSNumber numberWithInt:1]] intValue]];
            item.appID = [NSString stringWithFormat:@"%d", [[dicInfo objectForKey:@"id" defalutObj:[NSNumber numberWithInt:0]] intValue]];
            item.appName = [dicInfo objectForKey:@"name" defalutObj:@""];
            item.appIconUrl = [dicInfo objectForKey:@"icon_shine_url" defalutObj:@""];
            item.appGrayIconUrl = [dicInfo objectForKey:@"icon_gray_url" defalutObj:@""];
            item.userName = [dicInfo objectForKey:@"user_name" defalutObj:@""];
            item.requestUrl = [dicInfo stringValueForKey:@"request_url" defaultValue:@""];
            item.openId = [dicInfo objectForKey:@"openId" defalutObj:@""];
            [self setShareItemAppLevel:item];
            
            [mutArr addObject:item];
        }
        
        // fix 某些用户 由于从拍客一键分享数据库迁移失败  导致请求新的搜狐passport分享列表一直失败的问题
        if (mutArr.count == 0) {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                [self recoverShareList];
            });
        }
        
         //(_shareList);
        
//        _shareList = [[NSArray arrayWithArray:mutArr] retain];
        _shareList = [NSArray arrayWithObject:[mutArr objectAtIndex:0]];//只保留新浪微博
        // update database
        [[SNDBManager currentDataBase] setShareList:_shareList];
        // 更新下sharelist排序
        NSArray *newArray = [[SNDBManager currentDataBase] shareList];
        if (newArray) {
             //(_shareList);
            _shareList = newArray;
        }
        [SNNotificationManager postNotificationName:kSharelistDidChangedNotification object:SharelistRestoreObject];
        SNDebugLog(@"sharelist did changed u should update");
        _shareListState &= 1<<ShareListReady;
    }
}

- (void)setShareItemAppLevel:(ShareListItem *)item {
    // 新版的一键分享平台  都用服务器的所有项目 不再筛选
    item.appLevel = 1;
    
    /*
    // todo 网易微博?? 筛选列表
    NSString *appName = item.appName;
    if ([appName rangeOfString:@"新浪微博"].location != NSNotFound) {
        item.appLevel = ShareAppLevelSina;
    }
    else if ([appName rangeOfString:@"腾讯微博"].location != NSNotFound) {
        item.appLevel = ShareAppLevelQQ;
    }
    else if ([appName rangeOfString:@"搜狐微博"].location != NSNotFound) {
        item.appLevel = ShareAppLevelSohu;
    }
    else if ([appName rangeOfString:@"网易微博"].location != NSNotFound) {
        item.appLevel = ShareAppLevelNetease;
    }
    else if ([appName rangeOfString:@"人人网"].location != NSNotFound) {
        item.appLevel = ShareAppLevelRenren;
    }
    else if ([appName rangeOfString:@"QQ空间"].location != NSNotFound) {
        item.appLevel = ShareAppLevelQzone;
    }
    else if ([appName rangeOfString:@"开心网"].location != NSNotFound) {
        item.appLevel = ShareAppLevelKaixin;
    }
    else {
        item.appLevel = ShareAppLevelEnd;
    }
     */
}

- (void)recoverShareList {
    [SNUserinfoEx clearUserinfoFromUserDefaults];
    [[SNDBManager currentDataBase] deleteMyFavouriteAll];
}

/////////////////////////////////////////--> private methods
+ (SNShareList *)shareInstance {
    static SNShareList *_shareInstance = nil;
    @synchronized(self){
        if (!_shareInstance) {
            _shareInstance  = [[SNShareList alloc] init];
        }
    }
    return _shareInstance;
}
+ (BOOL)shouldRefreshShareList {
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:kShareListLastRefreshTimeKey];
    if (lastDate) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kShareListLastRefreshTimeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return NO;
    }
//    if (lastDate && [lastDate isKindOfClass:[NSDate class]]) {
//        NSTimeInterval tim = [lastDate timeIntervalSinceNow];
        // 这种情况才对
//        if (tim < 0) {
//            return (ABS(tim) > 60 * 30);
//        }
        // 这种情况基本不可能 除非是设置手机时间往后退了
//    }
    return YES;
}

+ (BOOL)couldItemShare:(ShareListItem *)item {
    if (item) {
        int status = [item.status intValue];
        if (status == 0 && [SNShareList isItemEnable:item]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isItemEnable:(ShareListItem *)item {
    if (item) {
        NSString *key = KeyForEnableShareItem(item.appID);
        NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (value) {
            return ([value intValue] >= 1);
        }
        else {
            return YES; // 没有存储状态的也可以分享
        }
    }
    return NO;
}

+ (void)saveItemStatusToUserDefaults:(ShareListItem *)item enable:(BOOL)enable{
    if (item) {
        NSString *key = KeyForEnableShareItem(item.appID);
        NSString *value = enable ? @"1" : @"0";
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [SNNotificationManager postNotificationName:kShareItemEnableChangedNotification object:nil];
    }
}

+ (void)clearAppEnableMark {
    NSDictionary *userDefaultsDic = [[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] copy];
    BOOL needSynch = NO;
    for (id key in [userDefaultsDic allKeys]) {
        if ([key isKindOfClass:[NSString class]] && [key rangeOfString:@"shareItemId_"].location != NSNotFound) {
            needSynch = YES;
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        }
    }
    if (needSynch) {
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSString *)iconNameByItem:(ShareListItem *)item {
    NSString *appName = item.appName;
    NSString *iconName = nil;
    BOOL isBinded = ([item.status intValue] == 0);
    if ([item.appID intValue] == 1 || [appName rangeOfString:@"新浪微博"].location != NSNotFound) {
        iconName = isBinded ? @"sinaWeibo.png" : @"sinaWeiboD.png";
    }
    else if ([item.appID intValue] == 2 || [appName rangeOfString:@"腾讯微博"].location != NSNotFound) {
        iconName = isBinded ? @"qqWeibo.png" : @"qqWeiboD.png";
    }
    else if ([item.appID intValue] == 3 || [appName rangeOfString:@"搜狐微博"].location != NSNotFound) {
        iconName = isBinded ? @"sohuWeibo.png" : @"sohuWeiboD.png";
    }
    else if ([appName rangeOfString:@"网易微博"].location != NSNotFound) {
        iconName = isBinded ? @"163Weibo.png" : @"163WeiboD.png";
    }
    else if ([item.appID intValue] == 4 || [appName rangeOfString:@"人人网"].location != NSNotFound) {
        iconName = isBinded ? @"renren.png" : @"renrenD.png";
    }
    else if ([item.appID intValue] == 6 || [appName rangeOfString:@"QQ空间"].location != NSNotFound) {
        iconName = isBinded ? @"qzone.png" : @"qzoneD.png";
    }
    else if ([item.appID intValue] == 5 || [appName rangeOfString:@"开心网"].location != NSNotFound) {
        iconName = isBinded ? @"kaixin.png" : @"kaixinD.png";
    }
    
    return iconName;
}

/*
 case 1: return @"sina";
 case 2: return @"t.qq";
 case 3: return @"";
 case 4: return @"renren";
 case 5: return @"kaixin";
 case 6: return @"qq";
 case 7: return @"wechat",
 */

+ (NSString *)appIdByAppName:(NSString *)appName {
    if ([appName isEqualToString:@"sina"]) {
        return @"1";
    }
    if ([appName isEqualToString:@"weibo"]) {
        return @"1";
    }
    else if ([appName isEqualToString:@"t.qq"]) {
        return @"2";
    }
    else if ([appName isEqualToString:@"renren"]) {
        return @"4";
    }
    else if ([appName isEqualToString:@"kaixin"]) {
        return @"5";
    }
    else if ([appName isEqualToString:@"qq"]) {
        return kQQSSOLoginAppId; // for qq sso test by jojo
        return @"6";
    }
    else if ([appName isEqualToString:@"wechat"]) {//微信登录
        return @"8";
    }
    return nil;
}

- (void)refreshShareListForce {
    [self refreshShareList:NO];
}

- (void)refreshShareList:(BOOL)bCheckExpire {
    if (bCheckExpire) {
        if ([SNShareList shouldRefreshShareList]) {
            [self refreshList];
        }
    }
    else {
        [self refreshList];
    }
}

- (ShareListItem *)itemByAppId:(NSString *)appId {
    if ([appId length] > 0 && [_shareList count] > 0) {
        for (ShareListItem *item in _shareList) {
            if ([item.appID compare:appId options:NSNumericSearch] == NSOrderedSame) {
                return item;
            }
        }
    }
    return nil;
}

- (NSArray *)itemsCouldShare {
    if ([_shareList count] > 0) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:6];
        for (ShareListItem *item in _shareList) {
            if ([SNShareList couldItemShare:item]) {
                [array addObject:item];
            }
        }
        if ([array count] > 0) {
            return array;
        }
    }
    return nil;
}

- (NSArray *)itemsBinded {
    if ([_shareList count] > 0) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:6];
        for (ShareListItem *item in _shareList) {
            if ([item.status intValue] == 0) {
                [array addObject:item];
            }
        }
        if ([array count] > 0) {
            return array;
        }
    }
    return nil;
}

- (void)updateShareList {
    [[SNDBManager currentDataBase] setShareList:_shareList];
}

//- (void)requestDidFinishLoad:(TTURLRequest*)request {
//    
//    TTUserInfo *userInfo = request.userInfo;
//    if ([userInfo.topic isEqualToString:kShareListRefreshTopic]) {
//        SNURLJSONResponse *jsonObj = request.response;
//        //SNDebugLog(@"%@", jsonObj.rootObject);
//        if ([jsonObj.rootObject isKindOfClass:[NSArray class]]) {
//            // refresh last refresh time
////            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kShareListLastRefreshTimeKey];
////            [[NSUserDefaults standardUserDefaults] synchronize];
//            
//            [self restoreShareListData:(NSArray *)jsonObj.rootObject];
//        }
//        else if ([jsonObj.rootObject isKindOfClass:[NSDictionary class]]) {
//            // 服务器改了数据结构 有可能返回字典类型的数据
//            NSDictionary *dic = jsonObj.rootObject;
//            
//            NSArray *listArray = [dic arrayValueForKey:@"appList" defaultValue:nil];
//            [self restoreShareListData:listArray];
//        }
//        
//        if ([_shareList count] > 0 && [_delegate respondsToSelector:@selector(refreshShareListSucc)]) {
//            [_delegate refreshShareListSucc];
//        }
//        else if ([_delegate respondsToSelector:@selector(refreshShareListGetNoData)]) {
//            [_delegate refreshShareListGetNoData];
//        }
//    }
//}
//
//- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
//    SNDebugLog(@"%@-->%@ : error %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [error localizedDescription]);
//    
//    TTUserInfo *userInfo = request.userInfo;
//    if ([userInfo.topic isEqualToString:kShareListRefreshTopic]) {
//        SNDebugLog(@"sharelist refresh fail with error=%@", [error localizedDescription]);
//        _shareListState &= 1<<ShareListFail;
//        if ([_delegate respondsToSelector:@selector(refreshShareListFail)]) {
//            [_delegate refreshShareListFail];
//        }
//    }
//}
//
//- (void)requestDidCancelLoad:(TTURLRequest*)request {
//    SNDebugLog(@"%@", NSStringFromSelector(_cmd));
//}

//#pragma mark ASIHTTPRequestDelegate
//- (void)requestFinished:(ASIHTTPRequest *)request
//{
//    if (request == self.refreshRequest)
//    {
//        id jsonObj = [NSJSONSerialization JSONObjectWithData:request.responseData
//                                                     options:NSJSONReadingMutableLeaves
//                                                       error:NULL];
//        //[request.responseData objectFromJSONData];
//        if ([jsonObj isKindOfClass:[NSArray class]]) {
//            
//            [self restoreShareListData:(NSArray *)jsonObj];
//        }
//        else if ([jsonObj isKindOfClass:[NSDictionary class]]) {
//            // 服务器改了数据结构 有可能返回字典类型的数据
//            NSDictionary *dic = jsonObj;
//            
//            NSArray *listArray = [dic arrayValueForKey:@"appList" defaultValue:nil];
//            [self restoreShareListData:listArray];
//        }
//        
//        if ([_shareList count] > 0 && [_delegate respondsToSelector:@selector(refreshShareListSucc)]) {
//            [_delegate refreshShareListSucc];
//        }
//        else if ([_delegate respondsToSelector:@selector(refreshShareListGetNoData)]) {
//            [_delegate refreshShareListGetNoData];
//        }
//    }
//}

//- (void)requestFailed:(ASIHTTPRequest *)request
//{
//    SNDebugLog(@"%@-->%@ : error %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), [request.error localizedDescription]);
//    if(request == self.refreshRequest)
//    {
//        _shareListState &= 1<<ShareListFail;
//        if ([_delegate respondsToSelector:@selector(refreshShareListFail)]) {
//            [_delegate refreshShareListFail];
//        }
//    }
//}
@end
