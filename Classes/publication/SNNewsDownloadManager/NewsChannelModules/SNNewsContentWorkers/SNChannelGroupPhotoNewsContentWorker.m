 //
//  SNChannelGroupPhotoNewsContentWorker.m
//  sohunews
//
//  Created by handy wang on 1/10/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNChannelGroupPhotoNewsContentWorker.h"
#import "SNNewsPreloader.h"
//#import "JsKitFramework.h"
#import <JsKitFramework/JsKitFramework.h>
#import "SNPhotoGalleryRequest.h"

@implementation SNChannelGroupPhotoNewsContentWorker

- (void)startInThread {
    if (_isCanceled) {
        //进行下一个worker
        if ([_myDelegate respondsToSelector:@selector(didFinishWorking:)]) {
            [_myDelegate didFinishWorking:self];
        }
        _myDelegate = nil;
        return;
    }
    
    [self notifyStartingWorking];
    
    SNDebugLog(@"===INFO: Main thread:%d, begin fetching groupphoto news content ...", [NSThread isMainThread]);
    
    for (SNNewsContentWorkerNews *_news in _newsArray) {
        if (_isCanceled) {
            break;
        }
        [self fetchGroupPhotoDataWithWorkerNews:_news];
    }
    
    //进行下一个worker
    if ([_myDelegate respondsToSelector:@selector(didFinishWorking:)]) {
        [_myDelegate didFinishWorking:self];
    }
    _myDelegate = nil;
}

- (int)recommendCount {
    switch ((int)TTApplicationFrame().size.height) {
        case 548:
            return 8;
        case 568:
            return 8;
        case 460:
            return 6;
    }
    return 8;
}

- (void)fetchGroupPhotoDataWithChannelId:(NSString *)channelId newsId:(NSString *)newsId {
    @autoreleasepool {
        // 检测缓存中是否已经存在
        JsKitStorage *jsKitStorage = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
        id jsonData = [jsKitStorage getItem:[NSString stringWithFormat:@"article%@", newsId]];
        if (jsonData && [[SNDBManager currentDataBase] getGalleryByTermId:kDftChannelGalleryTermId newsId:newsId]) {
            return;
        }
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
        NSString *_urlString = nil;
        if (!!channelId && ![@"" isEqualToString:channelId]) {

            [params setValue:channelId forKey:@"channelId"];
            [params setValue:newsId forKey:@"newsId"];
            [params setValue:[NSString stringWithFormat:@"%zd",[self recommendCount]] forKey:@"moreCount"];
            
            [params setValue:@"news" forKey:@"from"];
            [params setValue:channelId forKey:@"fromId"];
        } else {
            SNDebugLog(@"===INFO: Give up fetching channel groupphoto, becauses channelID is empty");
            return;
        }
        
        [[[SNPhotoGalleryRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id rootData) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                @try {
                    if (!rootData) {
                        SNDebugLog(@"===INFO: Main thread:%d, Got empty groupphoto rootData", [NSThread isMainThread]);
                        return;
                    }
                    [jsKitStorage setItem:rootData forKey:[NSString stringWithFormat:@"article%@",newsId] withExpire:[NSNumber numberWithInt:172800]];
                    
                    [self parseAndSaveGroupPhotoJsonData:rootData channelID:channelId newsID:newsId];
                } @catch (NSException *exception) {
                    SNDebugLog(@"SNPhotoGalleryRequest exception reason--%@", exception.reason);
                } @finally {
                    
                }
            });
            
        } failure:^(SNBaseRequest *request, NSError *error) {
            SNDebugLog(@"%@",error.localizedDescription);
        }];
    }
}



- (void)fetchGroupPhotoDataWithWorkerNews:(SNNewsContentWorkerNews *)workerNews {
    @autoreleasepool {
        [SNASIRequest setShouldUpdateNetworkActivityIndicator:NO];
        NSString *_urlString = nil;
        if (!![self channelID] && ![@"" isEqualToString:[self channelID]]) {
            _urlString = [NSString stringWithFormat:kUrlChannelPhotoGallery, [self channelID], workerNews.newsID, [self recommendCount]];
            _urlString = [_urlString stringByAppendingFormat:@"&from=news&fromId=%@", [self channelID]];
        } else {
            return;
        }
        
        SNASIRequest *_request = [SNASIRequest requestWithURL:[NSURL URLWithString:_urlString]];
        [_request setValidatesSecureCertificate:NO];
        [_request setCachePolicy:ASIDoNotReadFromCacheCachePolicy|ASIDoNotWriteToCacheCachePolicy];
        _request.defaultResponseEncoding = NSUTF8StringEncoding;
        [_request setValidatesSecureCertificate:NO];
        [_request startSynchronous];
        
        NSString *jsonString = [_request responseString];
        if (!jsonString || [@"" isEqualToString:jsonString]) {
            return;
        }
        
        id rootData = [NSJSONSerialization JSONObjectWithString:jsonString
                                                        options:NSJSONReadingMutableLeaves
                                                          error:NULL];
        if (!rootData) {
            return;
        }
        
        JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
        [jsKitStorage setItem:rootData forKey:[NSString stringWithFormat:@"article%@",workerNews.newsID] withExpire:[NSNumber numberWithInt:172800]];
        
        GalleryItem *_photoList = [self parseAndSaveGroupPhotoJsonData:rootData channelID:[self channelID] newsID:workerNews.newsID];
        
        if (!_photoList ||
            !(_photoList.gallerySubItems) || (_photoList.gallerySubItems.count <= 0) ||
            !(_photoList.moreRecommends) || (_photoList.moreRecommends.count <= 0)) {
            return;
        }
        
        NSMutableArray *_imageURLArray = [NSMutableArray array];
        for (PhotoItem *_photoItem in _photoList.gallerySubItems) {
            if (!!(_photoItem.url) && ![@"" isEqualToString:_photoItem.url]) {
                [_imageURLArray addObject:_photoItem.url];
            }
        }
        for (RecommendGallery *_recommendGallery in _photoList.moreRecommends) {
            if (!!(_recommendGallery.iconUrl) && ![@"" isEqualToString:_recommendGallery.iconUrl]) {
                [_imageURLArray addObject:_recommendGallery.iconUrl];
            }
        }
        
        if (_imageURLArray.count <= 0) {
            return;
        }
        
        [[SNNewsImageFetcher sharedInstance] setDelegate:self];
        [[SNNewsImageFetcher sharedInstance] fetchImagesInThread:_imageURLArray forNewsContent:_photoList];

    }
}

- (GalleryItem *)parseAndSaveGroupPhotoJsonData:(id)resData channelID:(NSString *)channelID newsID:(NSString *)newsID {
    //SNDebugLog(@"===INFO: Main thread:%d, Parsing and saving a GalleryItem...", [NSThread isMainThread]);
    
    GalleryItem *_photoList = [[GalleryItem alloc] init];
    _photoList.termId   = kDftChannelGalleryTermId;
    _photoList.newsId   = newsID;//组图推荐json里没有newsId，这里必须先赋值
    
	if ([resData isKindOfClass:[NSDictionary class]]) {
//        self.nextGid                = [resData objectForKey:kNextGid];
        _photoList.type         = [resData objectForKey:kType];
		_photoList.title        = [resData objectForKey:kTitle];
		_photoList.commentNum   = [resData objectForKey:kCommentNum];
		_photoList.shareContent = [resData objectForKey:kShareContent];
        _photoList.newsMark     = [resData objectForKey:kNewsMark];
        _photoList.originFrom   = [resData objectForKey:kOriginFrom];
        _photoList.time         = [resData objectForKey:kTime];
        _photoList.nextId       = [resData objectForKey:kNextId];
        _photoList.nextName     = [resData objectForKey:kNextName];
        _photoList.preId        = [resData objectForKey:kPreId];
        _photoList.preName      = [resData objectForKey:kPreName];
        _photoList.from         = [resData objectForKey:kFrom];
        _photoList.isLike       = [resData objectForKey:kIsLike];
        _photoList.likeCount    = [resData objectForKey:kLikeCount];
        NSDictionary* mediaDic  = [resData objectForKey:kMedia];
        if(mediaDic)
        {
            _photoList.mediaName = [mediaDic objectForKey:kMediaName];
            _photoList.mediaLink = [mediaDic objectForKey:kMediaLink];
        }
        NSDictionary *subInfoDic = [resData objectForKey:@"subInfo"];
        if (subInfoDic && [subInfoDic isKindOfClass:[NSDictionary class]]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                _photoList.subId = [subInfoDic objectForKey:@"subId"];
                SCSubscribeObject *subObj = [SCSubscribeObject subscribeObjFromJsonDic:subInfoDic];
                subObj.subId = _photoList.subId;
                [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
            });
        }
		
		NSMutableArray * photos = [[NSMutableArray alloc] init];
		id gallery = [resData objectForKey:kGallery];
		//数组
		if ([gallery isKindOfClass:[NSArray class]]) {
			for (NSDictionary *pDic in gallery) {
				PhotoItem *photo    = [[PhotoItem alloc] init];
                photo.termId        = _photoList.termId;
                photo.newsId        = _photoList.newsId;
				photo.ptitle        = [pDic objectForKey:kPTitle];
				photo.url           = [pDic objectForKey:kPic];
                if (photo.url) {
                    photo.url = [photo.url trim];
                }
				photo.abstract      = [pDic objectForKey:kAbstract];
				photo.shareLink     = [pDic objectForKey:kShareLink];
                photo.width = [pDic[@"width"] floatValue];
                photo.height = [pDic[@"height"] floatValue];
				if (photo) {
					[photos addObject:photo];
				}
			}
		}
		//单个
		else if ([gallery isKindOfClass:[NSDictionary class]]) {
			PhotoItem *photo    = [[PhotoItem alloc] init];
            photo.termId        = _photoList.termId;
            photo.newsId        = _photoList.newsId;
			photo.ptitle        = [gallery objectForKey:kPTitle];
			photo.url           = [gallery objectForKey:kPic];
            if (photo.url) {
                photo.url = [photo.url trim];
            }
			photo.abstract      = [gallery objectForKey:kAbstract];
			photo.shareLink     = [gallery objectForKey:kShareLink];
            photo.width = [gallery[@"width"] floatValue];
            photo.height = [gallery[@"height"] floatValue];
			if (photo) {
				[photos addObject:photo];
			}
		}
        
        _photoList.gallerySubItems  = photos;
        
        //更多推荐
        //推荐组图不再具备 termId和newsId属性，只有一个gid属性。访问推荐组图时，也只用带上gid一个参数,不用带上termId和newsId。为简化此情况的处理，同新闻组图共存与一个数据库表中，推荐组图仍保留termId和newsId，但termId 始终为0,newsId对应gid。在请求下载推荐组图时，如果发现组图termId为0，只带参数gid,否则，带上termId和newsId。
        NSMutableArray *moreRecommend = [[NSMutableArray alloc] init];
        id more = [resData objectForKey:kMore];
        if ([more isKindOfClass:[NSArray class]]) {
            for (NSDictionary *pDic in more) {
                RecommendGallery *recommend = [[RecommendGallery alloc] init];
                recommend.releatedTermId    = _photoList.termId;
                recommend.releatedNewsId    = _photoList.newsId;
                recommend.termId            = kDftSingleGalleryTermId;
                recommend.newsId            = [pDic objectForKey:kGroupPicId];
                recommend.title             = [pDic objectForKey:kGroupPicTitle];
                recommend.iconUrl           = [pDic objectForKey:kGroupPicIconUrl];
                if (recommend.iconUrl) {
                    recommend.iconUrl = [recommend.iconUrl trim];
                }
                
                [moreRecommend addObject:recommend];
            }
        }
        else if([more isKindOfClass:[NSDictionary class]]){
            RecommendGallery *recommend = [[RecommendGallery alloc] init];
            recommend.releatedTermId    = _photoList.termId;
            recommend.releatedNewsId    = _photoList.newsId;
            recommend.termId            = kDftSingleGalleryTermId;
            recommend.newsId            = [more objectForKey:kGroupPicId];
            recommend.title             = [more objectForKey:kGroupPicTitle];
            recommend.iconUrl           = [more objectForKey:kGroupPicIconUrl];
            if (recommend.iconUrl) {
                recommend.iconUrl = [recommend.iconUrl trim];
            }
            [moreRecommend addObject:recommend];
            
        }
        
        _photoList.moreRecommends = moreRecommend;
        
        // 4.0广告 解析接口返回的广告定向数据 并且缓存之 by jojo
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *adInfoControls = [(NSDictionary *)resData arrayValueForKey:@"adControlInfos" defaultValue:nil];
            if (adInfoControls) {
                NSMutableArray *parsedAdInfos = [NSMutableArray array];
                for (NSDictionary *adInfoDic in adInfoControls) {
                    if ([adInfoDic isKindOfClass:[NSDictionary class]]) {
                        SNAdControllInfo *adControlInfo = [[SNAdControllInfo alloc] initWithJsonDic:adInfoDic];
                        [parsedAdInfos addObject:adControlInfo];
                    }
                }
                // 添加到缓存
                [[SNDBManager currentDataBase] adInfoAddOrUpdateAdInfos:parsedAdInfos
                                                               withType:SNAdInfoTypePhotoListNews
                                                                 dataId:_photoList.newsId
                                                             categoryId:_photoList.termId];
            }
        });
        
        // 解析shareRead by jojo
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *shareReadDic = [resData dictionaryValueForKey:@"shareRead" defalutValue:nil];
            SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:shareReadDic];
            if (obj) {
                [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypePhoto contentId:newsID];
            }
        });
    }
    //SNDebugLog(@"===INFO: Main thread:%d, Finish parsing a GalleryItem.", [NSThread isMainThread]);
    
	[[SNDBManager currentDataBase] addSingleGalleryIfNotExist:_photoList];
    //SNDebugLog(@"===INFO: Main thread:%d, Finish saving a GalleryItem.", [NSThread isMainThread]);
    
    [[SNDBManager currentDataBase] markRollingNewsListItemAsNotExpiredByChannelId:channelID newsId:newsID];

    return _photoList;
}

#pragma mark - 下载某个GroupPhoto图片完成
- (void)finishedToFetchImagesInThreadForNewsContent:(id)newsContent {
    if ([newsContent isKindOfClass:[GalleryItem class]]) {
        GalleryItem *_photoList = (GalleryItem *)newsContent;
        SNDebugLog(@"===INFO: Main thread:%d, finish downloading images for GroupPhoto %@ .", [NSThread isMainThread], _photoList.title);
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, finish downloading images for GroupPhoto.", [NSThread isMainThread]);
    }
}

@end
