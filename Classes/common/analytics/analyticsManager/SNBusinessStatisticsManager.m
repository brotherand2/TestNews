


//
//  SNBusinessStatisticsManager.m
//  sohunews
//
//  Created by jialei on 14-8-12.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNBusinessStatisticsManager.h"
//#import "ASIFormDataRequest.h"
//#import "AFNetworking.h"
#import "SNExposureRequest.h"


@interface SNBusinessStatisticsManager()

@property (nonatomic, strong)NSMutableDictionary *stateInfoDic;

@property (nonatomic, strong) dispatch_queue_t uploadQueue;
//@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end

@implementation SNBusinessStatisticsManager

+ (SNBusinessStatisticsManager *)shareInstance
{
    static dispatch_once_t oneToken;
    static SNBusinessStatisticsManager *instance = nil;
    
    dispatch_once(&oneToken, ^
    {
        instance = [[SNBusinessStatisticsManager alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    if(self = [super init])
    {
        // 并不是一个serail的队列，因为1分钟运行一次，根本没有线程冲突的机会
        _uploadQueue = dispatch_queue_create("SNBusinessStatisticsManager", NULL);
        _stateInfoDic = [NSMutableDictionary dictionary];
        
//        _manager = [AFHTTPRequestOperationManager manager];
//        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        //_manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//        [_manager.requestSerializer setValue:@"gzip,deflate" forHTTPHeaderField:@"Accept-Encoding"];

        [self uploadLoop];
    }
    
    return self;
}

- (void)uploadLoop
{
    // 1分钟上传1次
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 300),
                   _uploadQueue,
                   ^()
    {
        [self uploadLoop];
        [self upload];
    });
}

- (void)updateStatisticsInfo:(SNBusinessStatInfo *)statInfo
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSMutableString *infoKey = [[NSMutableString alloc] initWithFormat:@"%@_", statInfo.urlStatType];
        
        [infoKey appendFormat:@"%ld_", statInfo.objFrom];
        [infoKey appendFormat:@"%@_", (statInfo.objFromId ? : @"")];
        
        NSString *expString = statInfo.urlObjType;
        if ([statInfo.urlObjType isEqualToString:@"exps9"]) {
            NSString *tail = @"";
            if (statInfo.recomReasons && !statInfo.recomTime) {
                tail = @"+1";
            }
            else if (!statInfo.recomReasons && statInfo.recomTime) {
                tail = @"+2";
            }
            else if (statInfo.recomReasons && statInfo.recomTime) {
                tail = @"+12";
            }
            
            expString = [expString stringByAppendingFormat:@"%@", tail];
        }
        
        [infoKey appendFormat:@"%@_", (expString ? : @"")];
        [infoKey appendFormat:@"%@_", (statInfo.token ? : @"")];
        
        //组装保存数据的字典
        __strong NSMutableSet *objIdSet = [NSMutableSet set];
        NSString *key = infoKey.copy;
        if (key && key.length > 0 ) {
            @synchronized (_stateInfoDic) {
              objIdSet = [self.stateInfoDic objectForKey:key];
            }
        }

        __strong NSMutableString *idString = [[NSMutableString alloc] init];
        
        if (objIdSet && objIdSet.count > 0)
        {
            [objIdSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
             {
                 NSString *objId = (NSString *)obj;
                 [idString appendFormat:@"%@,", objId];
             }];
            
            [self addObjIdsToIdSet:statInfo.objIDArray set:objIdSet];
        }
        else
        {
            NSMutableSet *newIdSet = [[NSMutableSet alloc] init];
            
            if (newIdSet)
            {
                [self addObjIdsToIdSet:statInfo.objIDArray set:newIdSet];
                [newIdSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop)
                 {
                     NSString *objId = (NSString *)obj;
                     [idString appendFormat:@"%@,", objId];
                 }];
                objIdSet = newIdSet;
            }
        }
        
        if (idString.length > 0) {
            NSRange lastRange = NSMakeRange(idString.length - 1, 1);
            [idString deleteCharactersInRange:lastRange];
        }
        
        [infoKey appendFormat:@"%@_", idString];
        
        if (statInfo.isTopNews == 1) {
            [infoKey appendFormat:@"%@_", (statInfo.position ? : @"0")];
            [infoKey appendFormat:@"%@_", (statInfo.toChannelId ? : @"0")];
            [infoKey appendFormat:@"%d_", statInfo.isTopNews];
        }
        else if ([statInfo.urlObjType isEqualToString:@"exps19"]){
            [infoKey appendFormat:@"%@_", (statInfo.adId ? : @"0")];
        }
        else if (statInfo.position != nil && statInfo.toChannelId != nil) {
            [infoKey appendFormat:@"%@_", (statInfo.position ? : @"0")];
            [infoKey appendFormat:@"%@_", (statInfo.toChannelId ? : @"0")];
        }
        
        if (infoKey.length > 0) {
            NSRange lastRange = NSMakeRange(infoKey.length - 1, 1);
            [infoKey deleteCharactersInRange:lastRange];
        }
        
        if (objIdSet && objIdSet.count > 0 && infoKey.length > 0) {
            @synchronized (_stateInfoDic) {
                [self.stateInfoDic setValue:objIdSet forKey:infoKey];
            }
        }
    });
}

#pragma mark- private function
//把不在集合中的objId加入到集合中
- (void)addObjIdsToIdSet:(NSArray *)objs set:(NSMutableSet *)idSet
{
    for (NSString *objId in objs)
    {
        if (![idSet containsObject:objId])
        {
            [idSet addObject:objId];
        }
    }
}

//timer回调方法，上传封装好的统计数据
- (void)upload
{
    NSString *uploadData = [[self parseStatInfo] copy];
    if (uploadData.length == 0) {
        if ([SNUserDefaults objectForKey:kUpLoadDataKey]) {
            uploadData = [[SNUserDefaults objectForKey:kUpLoadDataKey] copy];
        }
        else {
            return;
        }
    }
    else {
        [SNUserDefaults setObject:uploadData forKey:kUpLoadDataKey];
    }
    
    @synchronized (_stateInfoDic) {
        [self.stateInfoDic removeAllObjects];
    }
    
    [[[SNExposureRequest alloc] initWithUploadString:uploadData] send:^(SNBaseRequest *request, id responseObject) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [SNUserDefaults removeObjectForKey:kUpLoadDataKey];
        });
    } failure:nil];
}

/*
 *组装上传数据，
 *格式：@statType_objFrom_objFromId_objType_token_objId(,objId)@statType_objFrom_objFromId_objType_token_objId(,objId)
 *return NSString *  组装好的字符串
 */
- (NSString *)parseStatInfo
{
    NSMutableString *baseInfoString = [[NSMutableString alloc] init];
    @synchronized (_stateInfoDic) {
        for (NSString *key in self.stateInfoDic) {
              [baseInfoString appendFormat:@"@%@", key];
        }
    }
    
    return baseInfoString;
}

@end
