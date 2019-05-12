//
//  SNTermGroupPhotoNewsContentWorker.m
//  sohunews
//
//  Created by handy wang on 1/10/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNTermGroupPhotoNewsContentWorker.h"
#import "SNASIRequest.h"
#import "NSJSONSerialization+String.h"

@implementation SNTermGroupPhotoNewsContentWorker

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

- (void)fetchGroupPhotoDataWithWorkerNews:(SNNewsContentWorkerNews *)workerNews {
    SNDebugLog(@"===INFO: Main thread:%d, Begin fetching groupphoto %@ json data...", [NSThread isMainThread], workerNews.newsTitle);
    
    [SNASIRequest setShouldUpdateNetworkActivityIndicator:NO];
    NSString *_urlString = nil;
    if (![workerNews.termID isEqualToString:kDftChannelGalleryTermId] && !!(workerNews.termID) && ![@"" isEqualToString:workerNews.termID]) {
        _urlString = [NSString stringWithFormat:kUrlTermPhotoGallery, workerNews.termID, workerNews.newsID, [self recommendCount]];
        _urlString = [_urlString stringByAppendingFormat:@"&from=paper&fromId=%@", workerNews.termID];
    } else {
        SNDebugLog(@"===INFO: Give up fetching term groupphoto, becauses termID is empty");
        return;
    }
    
    SNASIRequest *_request = [SNASIRequest requestWithURL:[NSURL URLWithString:_urlString]];
    SNDebugLog(@"===INFO: fetch term groupPhotoDataWithWorkerNews from url : %@", _request.url.absoluteString);
    [_request setValidatesSecureCertificate:NO];
    [_request setCachePolicy:ASIDoNotReadFromCacheCachePolicy|ASIDoNotWriteToCacheCachePolicy];
    _request.defaultResponseEncoding = NSUTF8StringEncoding;
    [_request setValidatesSecureCertificate:NO];
    [_request startSynchronous];

    NSString *jsonString = [_request responseString];
    if (!jsonString || [@"" isEqualToString:jsonString]) {
        SNDebugLog(@"===INFO: Main thread:%d, Got empty groupphoto %@ jsonstring", [NSThread isMainThread], workerNews.newsTitle);
        return;
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, Got group photo for %@ and jsonstring:%@", [NSThread isMainThread], workerNews.newsTitle, jsonString);
    }
    
    id rootData = [NSJSONSerialization JSONObjectWithString:jsonString
                                                    options:NSJSONReadingMutableLeaves
                                                      error:NULL];
    if (!rootData) {
        SNDebugLog(@"===INFO: Main thread:%d, Got empty groupphoto %@ rootData", [NSThread isMainThread], workerNews.newsTitle);
        return;
    }
    
    GalleryItem *_photoList = [self parseAndSaveGroupPhotoJsonData:rootData termID:workerNews.termID newsID:workerNews.newsID];
    
    if (!_photoList ||
        !(_photoList.gallerySubItems) || (_photoList.gallerySubItems.count <= 0) ||
        !(_photoList.moreRecommends) || (_photoList.moreRecommends.count <= 0)) {
        SNDebugLog(@"===INFO: Main thread:%d, Giveup fetching groupphoto %@ images because GalleryItem is nil",
                   [NSThread isMainThread], _photoList.title);
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
        SNDebugLog(@"===INFO: Main thread:%d, Ignore fetching images for GroupPhoto %@, because there is no images need fetching.", [NSThread isMainThread], _photoList.title);
        return;
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, Fetching GroupPhoto %@ images %@ ...", [NSThread isMainThread], _photoList.title, _imageURLArray);
    }
    
    SNDebugLog(@"===INFO: Main  thread:%d, Begin fetching GroupPhoto %@ images...", [NSThread isMainThread], _photoList.title);
    [[SNNewsImageFetcher sharedInstance] setDelegate:self];
    [[SNNewsImageFetcher sharedInstance] fetchImagesInThread:_imageURLArray forNewsContent:_photoList];
}

- (GalleryItem *)parseAndSaveGroupPhotoJsonData:(id)resData termID:(NSString *)termID newsID:(NSString *)newsID {
    SNDebugLog(@"===INFO: Main thread:%d, Parsing and saving a GalleryItem...", [NSThread isMainThread]);
    
    GalleryItem *_photoList = [[GalleryItem alloc] init];
    _photoList.termId   = termID ? termID : kDftChannelGalleryTermId;
    _photoList.newsId   = newsID;//组图推荐json里没有newsId，这里必须先赋值
    
	if ([resData isKindOfClass:[NSDictionary class]]) {
//        self.nextGid                = [resData objectForKey:kNextGid];
        _photoList.type         = [resData objectForKey:kType];
		_photoList.title        = [resData objectForKey:kTitle];
		_photoList.commentNum   = [resData objectForKey:kCommentNum];
		_photoList.shareContent = [resData objectForKey:kShareContent];
        _photoList.time         = [resData objectForKey:kTime];
        _photoList.nextId       = [resData objectForKey:kNextId];
        _photoList.nextName     = [resData objectForKey:kNextName];
        _photoList.preId        = [resData objectForKey:kPreId];
        _photoList.preName      = [resData objectForKey:kPreName];
        _photoList.from         = [resData objectForKey:kFrom];
        _photoList.isLike       = [resData objectForKey:kIsLike];
        _photoList.likeCount    = [resData objectForKey:kLikeCount];
        
        NSDictionary *subInfoDic = [resData objectForKey:@"subInfo"];
        if (subInfoDic && [subInfoDic isKindOfClass:[NSDictionary class]]) {
            SCSubscribeObject *subObj = [SCSubscribeObject subscribeObjFromJsonDic:subInfoDic];
            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
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
                photo.width         = [pDic[@"width"] floatValue];
                photo.height        = [pDic[@"height"] floatValue];
				if (photo) {
					[photos addObject:photo];
					 //(photo);
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
            photo.width         = [gallery[@"width"] floatValue];
            photo.height        = [gallery[@"height"] floatValue];
			if (photo) {
				[photos addObject:photo];
				 //(photo);
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
    }
    SNDebugLog(@"===INFO: Main thread:%d, Finish parsing a GalleryItem.", [NSThread isMainThread]);
    
	[[SNDBManager currentDataBase] addSingleGalleryIfNotExist:_photoList];
    SNDebugLog(@"===INFO: Main thread:%d, Finish saving a GalleryItem.", [NSThread isMainThread]);

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
