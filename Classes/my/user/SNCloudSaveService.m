//
//  SNCloudSaveService.m
//  sohunews
//
//  Created by weibin cheng on 14-3-3.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNCloudSaveService.h"
#import "SNDatabase_CloudSave.h"
#import "NSObject+YAJL.h"
#import "SNChannelManageObject.h"
#import "SNUserManager.h"
#import "SNDBManager.h"
#import "SNBaseFavouriteObject.h"
#import "SNCloudSaveRequest.h"
#import "SNCloudGetRequest.h"
#import "SNCorpusNewsRequest.h"
#import "SNCorpusList.h"
#import "SNUserDataSynReuqest.h"

#define kCloudSave       (@"kcloudsave")
#define kCloudGet        (@"kcloudget")
#define kCloudGetFav     (@"kcloudgetFav")
#define kCloudGetChannel (@"kcloudgetchannel")

static NSInteger repeatCount = 1;

@interface SNCloudSaveService ()

@property (nonatomic, strong)NSDictionary *corpusDict;

@end

@implementation SNCloudSaveService
@synthesize cloudSaveDelegate = _cloudSaveDelegate;


-(NSString*)contentFromCloudSave:(SNCloudSave*)aCloudSave {
    if(aCloudSave==nil) {
        return nil;
    } else {
        return [SNMyFavourite generCloudLinkEx:aCloudSave._myFavouriteRefer contentLeveloneID:aCloudSave._contentLeveloneID contentLeveltwoID:aCloudSave._contentLeveltwoID showType:aCloudSave.showType];
    }
}

-(NSString*)contentFromFav:(SNMyFavourite*)aFav {
    if(aFav==nil)
        return nil;
    else
        return [SNMyFavourite generCloudLinkEx:aFav.myFavouriteRefer contentLeveloneID:aFav.contentLeveloneID contentLeveltwoID:aFav.contentLeveltwoID showType:aFav.showType];
}

-(BOOL)cloudSaveFavouriteArray:(NSArray*)aFavArray {
    return [self cloudHandleFavouriteArray:aFavArray delarray:nil];
}

-(BOOL)cloudSaveFavouriteArray:(NSArray*)aFavArray corpusDict:(NSDictionary *)corpusDict {
    self.corpusDict = corpusDict;
    return [self cloudHandleFavouriteArray:aFavArray delarray:nil];
}

-(BOOL)cloudDelFavouriteArray:(NSArray*)aFavArray {
    return [self cloudHandleFavouriteArray:nil delarray:aFavArray];
}


-(BOOL)cloudHandleFavouriteArray:(NSArray*)aSaveArray delarray:(NSArray*)aDelArray {
    BOOL isCollectNews = NO;//v5.2.2
    if (aSaveArray || _isGetFavouriteList) {
        isCollectNews = YES;
    } else {
        if ([aDelArray count] > 0) {
            for (int i = 0; i < [aDelArray count]; i++) {
                SNCloudSave *cloudSaveFavourite = (SNCloudSave *)[aDelArray objectAtIndex:i];
                [[SNDBManager currentDataBase] deleteMyCloudSave:cloudSaveFavourite];
            }
        }
    }

    if(![SNUtility isRightP1])
        return NO;

    NSArray* localSaves = [[[SNDBManager currentDataBase] getMyFavourites] mutableCopy];
    if((aSaveArray==nil || [aSaveArray count]==0) && (aDelArray==nil || [aDelArray count]==0) && (localSaves==nil || [localSaves count]==0)) {
        return NO;
    }
    //合并
    NSMutableArray* saveArray = [NSMutableArray arrayWithCapacity:0];
    [saveArray addObjectsFromArray:aSaveArray];
    //[saveArray addObjectsFromArray:localSaves];
    
    for(NSInteger i = 0; i < [localSaves count]; i++) {
        if ([saveArray containsObject:[localSaves objectAtIndex:i]] == NO)
            [saveArray addObject:[localSaves objectAtIndex:i]];
    }
    
    //拼接增加和删除串
    NSString* content = nil;
    NSMutableString* contents = [NSMutableString stringWithCapacity:0];
    for(NSInteger i=0; i<[saveArray count]; i++) {
        id object = [saveArray objectAtIndex:i];
        if([object isKindOfClass:[SNMyFavourite class]])
            content = [self contentFromFav:(SNMyFavourite*)object];
        else if([object isKindOfClass:[SNCloudSave class]]) {
            content = [self contentFromCloudSave:(SNCloudSave*)object];
        }
        
        if([contents length]>0) {
            [contents appendString:@","];
        }
        [contents appendString: content];
    }
    
    NSMutableString* delContents = [NSMutableString stringWithCapacity:0];
    for(NSInteger i=0; i<[aDelArray count]; i++) {
        id object = [aDelArray objectAtIndex:i];
        if ([object isKindOfClass:[SNCloudSave class]])
            content = ((SNCloudSave*)object)._link;
        
        if ([delContents length]>0)
            [delContents appendString:@","];
        if (content && [content isKindOfClass:[NSString class]]) {
            [delContents appendString: content];
        }
    }
    
    if([contents length]==0 && [delContents length]==0)
        return NO;

    // 可变参数拼接
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:0];
    
    if (isCollectNews) {
        NSString *entry = [self.corpusDict objectForKey:kCollectionFrom];
        if (entry) {
            [params setValue:entry forKey:@"entry"];
        }
        NSString *h5wt = [self.corpusDict objectForKey:kH5WebType];
        if (h5wt) {
            [params setObject:h5wt forKey:kH5WebType];
        }
    }
    
    if ([aSaveArray count] > 0) {
        SNCloudSave *cloudSave = [aSaveArray objectAtIndex:0];
        if (cloudSave.templateType && contents) {
            [contents appendFormat:@"&templateType=%@", cloudSave.templateType];
        }
    }
    
    NSString* contentFull = @"";
    NSString* saveContentFull = [NSString stringWithFormat:@"\"add\":\"%@\"", contents];
    NSString* delContentFull = [NSString stringWithFormat:@"\"del\":\"%@\"", delContents];

    if([contents length]>0 && [delContents length]>0) {//这个可能用不到
        contentFull = [NSString stringWithFormat:@"{%@,%@}", saveContentFull, delContentFull];
        [params setObject:contentFull forKey:@"contents"];
    }
    else if([contents length]>0) {
        [params setObject:contents forKey:@"contents"];
    }
    else if([delContents length]>0) {
        [params setObject:delContents forKey:@"contents"];
    }
    NSString *corpusId = [NSString stringWithFormat:@"%@", [self.corpusDict objectForKey:kCorpusID]];
    [params setValue:corpusId forKey:kCorpusID];

    NSArray *userInfo = aSaveArray!=nil ? aSaveArray : aDelArray;
    // request
    [[[SNCloudSaveRequest alloc] initWithDictionary:params andIsCollectNews:isCollectNews]
     send:^(SNBaseRequest *request, id responseObject) {
         if([responseObject isKindOfClass:[NSDictionary class]]) {
             
             NSNumber* code = [responseObject objectForKey:@"status"];
             NSString* msg = [responseObject objectForKey:@"statusText"];
             
             if(code.integerValue == 200 && userInfo.count > 0) {  //本地发起的保存本地收藏操作
                 //删除所有本地数据
//                 NSArray* array = [[SNDBManager currentDataBase] getMyFavourites];
//                 [[SNDBManager currentDataBase] deleteMyFavourites:array];
//                 //更新新的云存储
////                 [self performSelector:@selector(cloudGetRequest:) withObject:[NSNumber numberWithInt:SNCloudGetFavourite]];
//                 [self cloudGetRequest:SNCloudGetFavourite];
                 //通知
                 if([_cloudSaveDelegate respondsToSelector:@selector(notifyCloudSaveSuccess:responseObject:userInfo:)])
                     [_cloudSaveDelegate notifyCloudSaveSuccess:request responseObject:responseObject userInfo:userInfo];
             } else if (code.integerValue == 200) {  //本地发起的保存频道操作
                 //通知
                 if ([_cloudSaveDelegate respondsToSelector:@selector(notifyCloudSaveSuccess:responseObject:userInfo:)])
                     [_cloudSaveDelegate notifyCloudSaveSuccess:request responseObject:responseObject userInfo:userInfo];
             } else {
                 if ([_cloudSaveDelegate respondsToSelector:@selector(notifyCloudSaveFailure:userInfo:stutas:msg:)])
                     [_cloudSaveDelegate notifyCloudSaveFailure:request userInfo:userInfo stutas:[code intValue] msg:msg];
             }
         } else {
             if ([_cloudSaveDelegate respondsToSelector:@selector(notifyCloudSaveFailure:userInfo:stutas:msg:)])
                 [_cloudSaveDelegate notifyCloudSaveFailure:request  userInfo:userInfo stutas:0 msg:NSLocalizedString(@"network error", nil)];
         }
         
     } failure:^(SNBaseRequest *request, NSError *error) {
         
         if(_cloudSaveDelegate && [_cloudSaveDelegate respondsToSelector:@selector(notifyCloudSaveFailure:userInfo:didFailLoadWithError:)])
             [_cloudSaveDelegate notifyCloudSaveFailure:request userInfo:userInfo didFailLoadWithError:error];
     }];
    return YES;
}

-(BOOL)cloudGetRequest:(SNCloudGetType)cloudGetType
{
    if(![SNUtility isRightP1]) return NO;
    
    [[[SNCloudGetRequest alloc] initWithCloudGetType:cloudGetType] send:^(SNBaseRequest *request, id responseObject) {

        switch (cloudGetType) {
            case SNCloudGetAll: {
                if([responseObject isKindOfClass:[NSDictionary class]]) {
                    // 如果收藏数据量太大，直接在主线程搞会卡死ui 这里放到子线程处理数据 回调到主线程 by jojo on 2013-09-23
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        //获取收藏了列表的操作完成
                        NSArray* cloudFav = (NSArray*)[responseObject objectForKey:@"1"];
                        [self handleFavouriteItems:cloudFav];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //获取频道的列表的操作同时完成
                            [self handleChannelItems:responseObject];
                            [self handleCategoryItems:responseObject];
                            
                            //Notify
                            if([_cloudSaveDelegate respondsToSelector:@selector(notifyCloudGetSuccess)])
                                [_cloudSaveDelegate notifyCloudGetSuccess];
                        });
                    });
                } else {
                    if ([_cloudSaveDelegate respondsToSelector:@selector(notifyCloudGetFailure:msg:)])
                        [_cloudSaveDelegate notifyCloudGetFailure:0 msg:NSLocalizedString(@"network error", nil)];
                }
            }
                break;
            case SNCloudGetChannels: {
                if([responseObject isKindOfClass:[NSDictionary class]]) {
                    [self handleChannelItems:responseObject];
                    [self handleCategoryItems:responseObject];
                }
            }
                break;
            case SNCloudGetFavourite: {
                if ([responseObject isKindOfClass:[NSDictionary class]]) {//5.2.2
                    NSDictionary *dataInfoDict = [responseObject objectForKey:@"data"];
                    NSArray *favArray = [dataInfoDict objectForKey:@"favorites"];
                    if (!([favArray count] > 20)) {
                        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kFavouritePageTag];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                    // 如果收藏数据量太大，直接在主线程搞会卡死ui 这里放到子线程处理数据 回调到主线程 by jojo on 2013-09-23
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        //获取收藏了列表的操作完成
                        NSArray* cloudFav = favArray;
                        [SNCloudSaveService handleFavouriteItems:cloudFav];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //Notify
                            if([_cloudSaveDelegate respondsToSelector:@selector(notifyCloudGetSuccess)])
                                [_cloudSaveDelegate notifyCloudGetSuccess];
                        });
                    });
                } else {
                    if ([_cloudSaveDelegate respondsToSelector:@selector(notifyCloudGetFailure:msg:)])
                        [_cloudSaveDelegate notifyCloudGetFailure:0 msg:NSLocalizedString(@"network error", nil)];
                }

            }
                break;
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        if (_cloudSaveDelegate && [_cloudSaveDelegate respondsToSelector:@selector(notifyCloudGetFailure:didFailLoadWithError:)])
            [_cloudSaveDelegate notifyCloudGetFailure:request didFailLoadWithError:error];
    }];
    
    return YES;
}


- (NewsChannelItem*)getChannelWithId:(NSString*)aId array:(NSArray*)aArray {
    if(aId==nil || aArray==nil || [aArray count]==0) {
        return nil;
    } else {
        for(NSInteger i=0; i<[aArray count]; i++) {
            NewsChannelItem* item = (NewsChannelItem*)[aArray objectAtIndex:i];
            if(item.channelId && [item.channelId isEqualToString:aId])
                return item;
        }
        //default
        return nil;
    }
}

- (CategoryItem*)getCategoryWithId:(NSString*)aId array:(NSArray*)aArray {
    if(aId==nil || aArray==nil || [aArray count]==0)
        return nil;
    else {
        for(NSInteger i=0; i<[aArray count]; i++) {
            CategoryItem* item = (CategoryItem*)[aArray objectAtIndex:i];
            if(item.categoryID && [item.categoryID isEqualToString:aId])
                return item;
        }
        //default
        return nil;
    }
}

+ (void)handleFavouriteItems:(NSArray*)cloudFav {
    if(cloudFav!=nil && [cloudFav isKindOfClass:[NSArray class]]) {
        //删除所有云端数据
        //        [[SNDBManager currentDataBase] deleteMyCloudSaves];
        //更新云端数据到本地数据库,同时删除本地重复数据
        for(NSDictionary* dic in cloudFav) {
            SNCloudSave* item = [[SNCloudSave alloc] init];
            item._link = [dic objectForKey:@"link"];
            item._title = [dic objectForKey:@"title"];
//            SNDebugLog(@"item._title %@", item._title);
            item._collectTime = [dic objectForKey:@"collectTime"];
            
            if([item parserLink]) {
                [[SNDBManager currentDataBase] saveMyCloudSave:item];
                
                //删除本地可能存在的重复数据
                SNMyFavourite* myfavourite = [[SNMyFavourite alloc] init];
                myfavourite.myFavouriteRefer = item._myFavouriteRefer;
                myfavourite.contentLeveloneID = item._contentLeveloneID;
                myfavourite.contentLeveltwoID = item._contentLeveltwoID;
                [[SNDBManager currentDataBase] deleteMyFavourite:myfavourite];
            } else {
                SNDebugLog(@"link can't be resloved!!! %@",item._link);
            }
        }
    }
}

- (void)handleChannelItems:(id)aRootData {
    NSDictionary* channels = (NSDictionary*)[aRootData objectForKey:@"2"];
    NSString* content = (NSString*)[channels objectForKey:@"content"];
    NSString* timestamp = (NSString*)[channels objectForKey:@"timestamp"];
    
    NSArray* array = [self arrayFromString:content];
    NSMutableArray* cachedChannels = [[[SNDBManager currentDataBase] getNewsChannelList] mutableCopy];
    NSMutableArray* channelsArray = [NSMutableArray arrayWithCapacity:0];
    
    if(cachedChannels!=nil && [cachedChannels count]>0 && array!=nil && [array count]>0 && channels!=nil) {
        //比较本地时间和服务端时间，本地时间如果比服务端时间还晚，那么本地数据为准
        /*
         NewsChannelItem* channel = [cachedChannels objectAtIndex:0];
         if(channel!=nil && channel.lastModify!=nil && timestamp!=nil)
         {
         NSDate* timestampDate = [[NSDate alloc] initWithTimeIntervalSince1970: [timestamp doubleValue]];
         NSDate* localDate = [[NSDate alloc] initWithTimeIntervalSince1970: [channel.lastModify doubleValue]];
         if([localDate compare:timestampDate]!=NSOrderedAscending)
         return;
         }*/
        
        //已经订阅里进行排序
        //NSMutableString* str = [NSMutableString stringWithCapacity:0];
        //[str appendString:@"别报bug_收到的云频道_测试用:"];
        for(NSInteger i=0; i<[array count]; i++) {
            NSString* catId = (NSString*)[array objectAtIndex:i];
            NewsChannelItem* item = [self getChannelWithId:catId array:cachedChannels];
            
            if(item!=nil) {
                item.isChannelSubed = @"1";
                item.channelPosition = [NSString stringWithFormat:@"%ld",(long)i];
                item.lastModify = timestamp;
                [channelsArray addObject:item];
                [cachedChannels removeObject:item];
                
                //[str appendString:@" "];
                //[str appendString:item.channelName];
                //[str appendString:@" "];
            }
        }

        
        //未订阅项
        for(NSInteger i=0; i<[cachedChannels count]; i++) {
            NewsChannelItem* item = (NewsChannelItem*)[cachedChannels objectAtIndex:i];
            item.lastModify = timestamp;
            item.isChannelSubed = @"0";
        }
    }
    [channelsArray addObjectsFromArray:cachedChannels];
    
    if ([channelsArray count]>0) {
        [[SNDBManager currentDataBase] setNewsChannelList:channelsArray updateTopTime:NO];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kChannelCloudSyn]; //同步过了
        [SNNotificationManager postNotificationName:kRefreshChannelsNowNotification object:nil]; //全局通知更新
        
        //Notify
        if([_cloudSaveDelegate respondsToSelector:@selector(notifyCloudGetSuccess)])
            [_cloudSaveDelegate notifyCloudGetSuccess];
    }
}

- (void)handleCategoryItems:(id)aRootData {
    NSDictionary* channelsPhoto = (NSDictionary*)[aRootData objectForKey:@"3"];
    NSString* content = (NSString*)[channelsPhoto objectForKey:@"content"];
    NSString* timestamp = (NSString*)[channelsPhoto objectForKey:@"timestamp"];
    
    NSArray* array = [self arrayFromString:content];
    NSMutableArray* cachedCategories = [[[SNDBManager currentDataBase] getAllCachedCategory] mutableCopy];
    NSMutableArray* categories = [NSMutableArray arrayWithCapacity:0];
    
    if (cachedCategories!=nil && [cachedCategories count]>0 && array!=nil && [array count]>0 && channelsPhoto!=nil) {
        /*
         //比较本地时间和服务端时间，本地时间如果比服务端时间还晚，那么本地数据为准
         CategoryItem* channel = [cachedCategories objectAtIndex:0];
         if(channel!=nil && channel.lastModify!=nil && timestamp!=nil)
         {
         NSDate* timestampDate = [[NSDate alloc] initWithTimeIntervalSince1970: [timestamp doubleValue]];
         NSDate* localDate = [[NSDate alloc] initWithTimeIntervalSince1970: [channel.lastModify doubleValue]];
         if([localDate compare:timestampDate]!=NSOrderedAscending)
         return;
         }*/
        
        //已经订阅里进行排序
        //NSMutableString* str = [NSMutableString stringWithCapacity:0];
        //[str appendString:@"别报bug_收到的云频道_组图_测试用:"];
        for(NSInteger i=0; i<[array count]; i++) {
            NSString* catId = (NSString*)[array objectAtIndex:i];
            CategoryItem* item = (CategoryItem*)[self getCategoryWithId:catId array:cachedCategories];
            
            if (item!=nil) {
                item.isSubed = @"1";
                item.position = [NSString stringWithFormat:@"%ld",(long)i];
                item.lastModify = timestamp;
                [categories addObject:item];
                [cachedCategories removeObject:item];
                
                //[str appendString:@" "];
                //[str appendString:item.name];
                //[str appendString:@" "];
            }
        }
        
        //未订阅项
        for (NSInteger i=0; i<[cachedCategories count]; i++) {
            CategoryItem* item = (CategoryItem*)[cachedCategories objectAtIndex:i];
            item.lastModify = timestamp;
            item.isSubed = @"0";
        }
    }
    [categories addObjectsFromArray:cachedCategories];
    
    if ([categories count]>0) {
        [[SNDBManager currentDataBase] addMultiCategory:categories updateTopTime:NO];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kCatagoryCloudSyn]; //同步过了
        [SNNotificationManager postNotificationName:kRefreshCategoriesNowNotification object:nil]; //全局通知更新
        
        //Notify
        if([_cloudSaveDelegate respondsToSelector:@selector(notifyCloudGetSuccess)])
            [_cloudSaveDelegate notifyCloudGetSuccess];
    }
}

- (NSArray*)arrayFromString:(NSString*)aString {
    if(aString==nil || [aString length]==0)
        return  nil;
    
    NSString* split = @",";
    NSCharacterSet* set = [NSCharacterSet characterSetWithCharactersInString:split];
    return [aString componentsSeparatedByCharactersInSet:set];
}

+ (void)corpusDataCloudSync:(void(^)())completion {
    
    if ([SNUserManager isLogin] && ![self checkServerSynced]) { // 登录状态下未触发过同步
        __weak typeof(self)weakself = self;
        [self triggerCorpusSynCompletion:^(BOOL success) {
            if (success) {
                /// 删除本地收藏夹列表
                [SNCorpusList deleteLocalCorpusList];
                [self synCloudFavoriteData];
            }
            if (completion) {
                completion();
            }
        }];
    } else {
        if (completion) {
            completion();
        }
    }
}

+ (BOOL)checkServerSynced {
    return [SNUserDefaults boolForKey:kSNCorpusServerSynced];
}

+ (void)deleteAllLocalCorpusData {
    /// 删除本地的收藏数据
    [[SNDBManager currentDataBase] deleteMyFavouriteAll];
    
    /// 删除本地收藏夹列表
    [SNCorpusList deleteLocalCorpusList];
}

+ (void)triggerCorpusSynCompletion:(void(^)(BOOL success))completion {
    // 用于触发服务端收藏同步
    [[[SNUserDataSynReuqest alloc] init] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            NSString *status = [dict stringValueForKey:@"status" defaultValue:@""];
            if (31030000 == status.integerValue) {
                [SNUserDefaults setBool:YES forKey:kSNCorpusServerSynced];// 已触发过同步
                if (completion) {
                    completion(YES);
                    return;
                }
            }
        }
        if (completion) {
            completion(NO);
        }
    } failure:^(SNBaseRequest *request, NSError *error) {
        if (completion) {
            completion(NO);
        }
    }];
}

+ (void)synCloudFavoriteData {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        /// 删除本地的收藏数据
        [[SNDBManager currentDataBase] deleteMyFavouriteAll];
        
        /// 重新获取收藏夹列表
        [SNCorpusList resaveCorpusList];
        
        /// 循环请求收藏的新闻
        repeatCount = 1;
        [self requestCloudFavoriteWithPageNumber:1 completion:^{
            SNDebugLog(@"≠≠≠≠≠≠≠≠≠收藏同步≠≠≠≠≠≠≠≠");
        }];
    });
}

+ (void)requestCloudFavoriteWithPageNumber:(NSInteger)pageNumber completion:(void(^)())completion {
    if(![SNUtility isRightP1] || ![SNUtility isConnectedToNetwork]) return;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:2];
    [param setValue:@(pageNumber) forKey:@"page"];
    [param setValue:@(0) forKey:kCorpusID];
    [[[SNCorpusNewsRequest alloc] initWithDictionary:param andCorpusName:kCorpusMyFavourite] send:^(SNBaseRequest *request, id responseObject) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @try {
                NSInteger status = [(NSString *)[responseObject objectForKey:kStatus] integerValue];
                if (status == 200) {
                    NSDictionary *data = [responseObject objectForKey:@"data"];
                    if (data && [data isKindOfClass:[NSDictionary class]]) {
                        NSArray *array = [data objectForKey:@"favorites"];
                        if (array && [array isKindOfClass:[NSArray class]]) {
                            if (array.count > 0) {
                                [SNCloudSaveService handleFavouriteItems:array];
                                [self requestCloudFavoriteWithPageNumber:pageNumber+1 completion:completion];
                            } else {
                                if (completion) completion();
                            }
                        }
                    }
                } else {
                    if (repeatCount > 5) return;
                    repeatCount +=1;
                    [self requestCloudFavoriteWithPageNumber:pageNumber completion:completion];
                }
            } @catch (NSException *exception) {
                SNDebugLog(@"SNCorpusNewsRequest exception reason--%@", exception.reason);
            } @finally {
                
            }
        });
    } failure:^(SNBaseRequest *request, NSError *error) {
        if (repeatCount > 5) return;
        repeatCount +=1;
        [self requestCloudFavoriteWithPageNumber:pageNumber completion:completion];
    }];
}

@end
