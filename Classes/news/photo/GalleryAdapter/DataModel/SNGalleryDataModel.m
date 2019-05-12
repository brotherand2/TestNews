//
//  SNGalleryDataModel.m
//  sohunews
//
//  Created by HuangZhen on 07/03/2017.
//  Copyright © 2017 Sohu.com. All rights reserved.
//

#import "SNGalleryDataModel.h"
#import <JsKitFramework/JKNotificationCenter.h>
#import "SNDBManager.h"
#import "SNArticle.h"
#import "CacheObjects.h"
#import "SNCommentConfigs.h"
#import "SNGalleryRequest.h"


@interface SNGalleryDataModel ()

@property (nonatomic, copy) NSString * newsId;

@end

@implementation SNGalleryDataModel

- (void)getJsKitStorageItemWithNewsId:(NSString *)newsId type:(SNGalleryBrowserType)type completed:(FetchGalleryDataCompleteBlock)completeBlock {
    
    NSString *methodStr = nil;
    if (newsId.length > 0) {
        methodStr = [NSString stringWithFormat:@"article%@", newsId];
    }
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    id jsonData = [jsKitStorage getItem:methodStr];
    //取缓存
    if (jsonData && [jsonData isKindOfClass:[NSDictionary class]]) {
        if (type == SNGalleryBrowserTypeImage) {
            completeBlock([self getArticle:(NSDictionary *)jsonData]);
        } else if (type == SNGalleryBrowserTypeGroup) {
            completeBlock([self getGalleryItem:(NSDictionary *)jsonData]);
        }
    }else{
        //没有缓存，去下载
        SNGalleryRequest * request = [[SNGalleryRequest alloc] init];
        request.gid = nil;
        request.newsId = newsId;
        request.channelId = self.channelId;
        [request send:^(SNBaseRequest *request, id responseObject) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                if (type == SNGalleryBrowserTypeImage) {
                    completeBlock([self getArticle:(NSDictionary *)responseObject]);
                } else if (type == SNGalleryBrowserTypeGroup) {
                    completeBlock([self getGalleryItem:(NSDictionary *)responseObject]);
                }
                [jsKitStorage setItem:responseObject forKey:methodStr];
            }else{
                completeBlock(nil);
            }
        } failure:^(SNBaseRequest *request, NSError *error) {
            completeBlock(nil);
        }];
    }
}

- (void)getJsKitStorageItemWithGroupId:(NSString *)groupId type:(SNGalleryBrowserType)type completed:(FetchGalleryDataCompleteBlock)completeBlock {

    NSString *methodStr = nil;
    if (groupId.length > 0) {
        methodStr = [NSString stringWithFormat:@"gallery%@", groupId];
    }
    JsKitStorage *jsKitStorage  = [[JsKitStorageManager manager] storageForWebApp:@"newssdk.sohu.com"];
    id jsonData = [jsKitStorage getItem:methodStr];
    //取缓存
    if (jsonData && [jsonData isKindOfClass:[NSDictionary class]]) {
        if (type == SNGalleryBrowserTypeImage) {
            completeBlock([self getArticle:(NSDictionary *)jsonData]);
        } else if (type == SNGalleryBrowserTypeGroup) {
            completeBlock([self getGalleryItem:(NSDictionary *)jsonData]);
        }
    }else{
        //没有缓存，去下载
        SNGalleryRequest * request = [[SNGalleryRequest alloc] init];
        request.gid = groupId;
        request.newsId = nil;
        request.channelId = self.channelId;
        [request send:^(SNBaseRequest *request, id responseObject) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                if (type == SNGalleryBrowserTypeImage) {
                    completeBlock([self getArticle:(NSDictionary *)responseObject]);
                } else if (type == SNGalleryBrowserTypeGroup) {
                    completeBlock([self getGalleryItem:(NSDictionary *)responseObject]);
                }
//                [jsKitStorage setItem:responseObject forKey:methodStr];
            }else{
                completeBlock(nil);
            }
        } failure:^(SNBaseRequest *request, NSError *error) {
            completeBlock(nil);
        }];
    }
}

- (SNArticle *)getArticle:(id)jsonData
{
    SNArticle * article = nil;
    if ([jsonData isKindOfClass:[NSDictionary class]]) {
        article = [[SNArticle alloc] init];
        if (self.channelId) {
            article.channelId= self.channelId;
        }
        if (self.termId) {
            article.termId   = self.termId;
        }
        article.newsId       = [jsonData objectForKey:kNewsId];
        article.optimizeRead = [jsonData objectForKey:kOptimizeRead];
        article.time         = [jsonData objectForKey:kTime];
        article.title        = [jsonData objectForKey:kTitle];
        article.originFrom   = [jsonData objectForKey:kOriginFrom];
        article.originTitle  = [jsonData objectForKey:kOriginTitle];
        article.h5link       = [jsonData objectForKey:kH5link];
        article.favIcon      = [jsonData objectForKey:kFavIcon];
        article.newsMark     = [jsonData objectForKey:kNewsMark];
        article.content      = [jsonData objectForKey:kContent];
        article.updateTime   = [[jsonData objectForKey:kUpdateTime] stringValue];
        article.newsType     = [jsonData objectForKey:kNewsType];
        article.nextId       = [jsonData stringValueForKey:kNextGid defaultValue:@""];
        
        NSMutableDictionary *subInfoDic = [NSMutableDictionary dictionaryWithDictionary:[jsonData objectForKey:@"subInfo"]];
        if (subInfoDic && [subInfoDic isKindOfClass:[NSDictionary class]]) {
            article.subId = [NSString stringWithFormat:@"%@", [subInfoDic objectForKey:@"subId"]];
            [subInfoDic setValue:article.subId forKey:@"subId"];
            [subInfoDic setValue:[NSString stringWithFormat:@"%@", [subInfoDic objectForKey:@"needLogin"]] forKey:@"needLogin"];
            SCSubscribeObject *subObj = [SCSubscribeObject subscribeObjFromJsonDic:subInfoDic];
            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
        }
        
        NSArray *tvAdInfos = [jsonData objectForKey:@"tvAdInfos"];
        if (tvAdInfos && [tvAdInfos isKindOfClass:[NSArray class]]) {
            article.tvAdInfos = tvAdInfos;
        }
        
        NSArray *tvInfos = [jsonData objectForKey:@"tvInfos"];
        if (tvInfos && [tvInfos isKindOfClass:[NSArray class]]) {
            article.tvInfos = tvInfos;
        }
        
        
        NSDictionary *comtRel = [jsonData objectForKey:@"comtRel"];
        if (comtRel) {
            article.comtRemarkTips = [comtRel objectForKey:kCmtRemarkTips];
            article.comtHint       = [comtRel objectForKey:kCmtHint];
            article.comtStatus     = [[comtRel objectForKey:kCmtStatus] stringValue];
            [SNUtility setCmtRemarkTips:article.comtRemarkTips];
        }
        
        NSDictionary* mediaDic  = [jsonData objectForKey:kMedia];
        if(mediaDic)
        {
            article.mediaName = [mediaDic objectForKey:kMediaName];
            article.mediaLink = [mediaDic objectForKey:kMediaLink];
        }
        
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        NSArray *photoArray = [jsonData objectForKey:kPhotos];
        //数组
        if (photoArray) {
            for (NSDictionary *pDic in photoArray) {
                NewsImageItem *imageItem = [[NewsImageItem alloc] init];
                imageItem.termId        = self.termId;
                imageItem.newsId        = self.newsId;
                imageItem.type          = NEWSSHAREIMAGE_TYPE;
                imageItem.url           = [pDic objectForKey:kPic];
                if (imageItem.url) {
                    imageItem.url = [imageItem.url trim];
                }
                imageItem.title   = [pDic objectForKey:@"description"];
                imageItem.width = [pDic[@"width"] floatValue];
                imageItem.height = [pDic[@"height"] floatValue];
                if (imageItem) {
                    [photos addObject:imageItem];
                }
            }
            article.newsImageItems = photos;
        }
    }
    return article;
}

- (GalleryItem *)getGalleryItem:(id)resData
{
    GalleryItem * photoList = nil;
    if ([resData isKindOfClass:[NSDictionary class]]) {
        photoList = [[GalleryItem alloc] init];
        photoList.newsId       = [resData objectForKey:kNewsId];
        photoList.type         = [resData objectForKey:kType];
        photoList.gId          = [resData objectForKey:@"gid"];
        photoList.title        = [resData objectForKey:kTitle];
        photoList.commentNum   = [resData objectForKey:kCommentNum];
        photoList.shareContent = [resData objectForKey:kShareContent];
        photoList.newsMark     = [resData objectForKey:kNewsMark];
        photoList.originFrom   = [resData objectForKey:kOriginFrom];
        photoList.time         = [resData objectForKey:kTime];
        photoList.nextId       = [resData objectForKey:@"nextGid"];
        photoList.nextName     = [resData objectForKey:kNextName];
        photoList.preId        = [resData objectForKey:kPreId];
        //        photoList.preName      = [resData objectForKey:kPreName];
        //        photoList.from         = [resData objectForKey:kFrom];
        photoList.isLike       = [resData objectForKey:kIsLike];
        photoList.likeCount    = [resData objectForKey:kLikeCount];
        photoList.termId       = [resData objectForKey:kTermId];
        NSDictionary* mediaDic  = [resData objectForKey:kMedia];
        if(mediaDic)
        {
            photoList.mediaName = [mediaDic objectForKey:kMediaName];
            photoList.mediaLink = [mediaDic objectForKey:kMediaLink];
        }
        NSMutableDictionary *subInfoDic = [NSMutableDictionary dictionaryWithDictionary:[resData objectForKey:@"subInfo"]];
        if (subInfoDic && [subInfoDic isKindOfClass:[NSDictionary class]]) {
            photoList.subId = [NSString stringWithFormat:@"%@", [subInfoDic objectForKey:@"subId"]];
            [subInfoDic setValue:photoList.subId forKey:@"subId"];
            [subInfoDic setValue:[NSString stringWithFormat:@"%@", [subInfoDic objectForKey:@"needLogin"]] forKey:@"needLogin"];
            SCSubscribeObject *subObj = [SCSubscribeObject subscribeObjFromJsonDic:subInfoDic];
            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
        }
        
        NSMutableArray * photos = [[NSMutableArray alloc] init];
        id gallery = [resData objectForKey:kGallery];
        //数组
        if ([gallery isKindOfClass:[NSArray class]]) {
            for (NSDictionary *pDic in gallery) {
                PhotoItem *photo    = [[PhotoItem alloc] init];
                photo.termId        = photoList.termId;
                photo.newsId        = photoList.newsId;
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
            photo.termId        = photoList.termId;
            photo.newsId        = photoList.newsId;
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
        
        photoList.gallerySubItems  = photos;
        
        //更多推荐
        //推荐组图不再具备 termId和newsId属性，只有一个gid属性。访问推荐组图时，也只用带上gid一个参数,不用带上termId和newsId。为简化此情况的处理，同新闻组图共存与一个数据库表中，推荐组图仍保留termId和newsId，但termId 始终为0,newsId对应gid。在请求下载推荐组图时，如果发现组图termId为0，只带参数gid,否则，带上termId和newsId。
        NSMutableArray *moreRecommend = [[NSMutableArray alloc] init];
        id more = [resData objectForKey:kMore];
        if ([more isKindOfClass:[NSArray class]]) {
            for (NSDictionary *pDic in more) {
                RecommendGallery *recommend = [[RecommendGallery alloc] init];
                recommend.releatedTermId    = photoList.termId;
                recommend.releatedNewsId    = photoList.newsId;
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
            recommend.releatedTermId    = photoList.termId;
            recommend.releatedNewsId    = photoList.newsId;
            recommend.termId            = kDftSingleGalleryTermId;
            recommend.newsId            = [more objectForKey:kGroupPicId];
            recommend.title             = [more objectForKey:kGroupPicTitle];
            recommend.iconUrl           = [more objectForKey:kGroupPicIconUrl];
            if (recommend.iconUrl) {
                recommend.iconUrl = [recommend.iconUrl trim];
            }
            [moreRecommend addObject:recommend];
        }
        
        photoList.moreRecommends = moreRecommend;
    }
    return photoList;
}

@end
