//
//  SNPhotoSlideshow.m
//  sohunews
//
//  Created by Dan on 12/27/11.
//  Copyright (c) 2011 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoSlideshow.h"
#import "TBXML.h"
#import "SNDBManager.h"
//#import "SNURLJSONResponse.h"
#import "NSDictionaryExtend.h"
#import "SNSpaceId.h"
#import "SNRollingNewsPublicManager.h"
#import "SNPhotoGalleryRequest.h"

@implementation SNPhotoSlideshow

static int showTimes = 0;

@synthesize newsId = _newsId, termId = _termId, title, commentNum, photos = _photos, shareContent, moreRecommends, isOnlineMode = _isOnlineMode;
@synthesize photoList   = _photoList, allItems, channelId = _channelId, nextGid = _nextGid, type, typeId;
@synthesize galleryLoadType, slideshowDelegate = _slideshowDelegate, firstPhotoOfNextGroup, prevMoreRecommends, lastPhotoOfPrevGroup;
@synthesize subId;
@synthesize stpAudCmtRsn;

- (id)initWithTermId:(NSString*)termId newsId:(NSString*)newsId channelId:(NSString*)channelId isOnlineMode:(BOOL)isOnlineMode
{
    if(self = [super init])
    {
        self.termId         = termId;
        self.newsId         = newsId;
        self.channelId      = channelId;
        _isOnlineMode       = isOnlineMode;
        self.galleryLoadType = -1;
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasLoadAd"];//加个标志，避免同一界面请求两次广告
        [[NSUserDefaults standardUserDefaults] synchronize];

        // 只有在离线状态下，尝试初次加载广告信息；在线模式以接口返回的新广告数据为准；
        if (!isOnlineMode) {
            [self refreshAdData];
        }
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(recommendAdRefresh:)
                                                     name:kSNPhotoSlideshowRecommendAd
                                                   object:nil];
    }
    
    return self;
}

-(void)finishRequest:(TTURLRequest*)request {
    if (galleryLoadType == GalleryLoadTypePrev || galleryLoadType == GalleryLoadTypeNext || galleryLoadType == GalleryLoadTypeNone) {
        if (!self.isLoadingMore) {
            _loadedTime = request.timestamp;
            self.cacheKey = request.cacheKey;
        }
        
        if (_slideshowDelegate && [_slideshowDelegate respondsToSelector:@selector(didFinishPreLoad:)]) {
            [_slideshowDelegate didFinishPreLoad:self.galleryLoadType];
        }
        if (_slideshowDelegate && [_slideshowDelegate respondsToSelector:@selector(didFinishPreLoad:slideshow:)])
        {
            [_slideshowDelegate didFinishPreLoad:self.galleryLoadType slideshow:self];
        }
    } else {
        [super requestDidFinishLoad:request];
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
//    [_request cancel];
    
    for (SNPhoto *photo in _photos) {
        if ([photo isKindOfClass:[SNPhoto class]]) {
            photo.photoSource = nil;
        }
    }
    _sdkAdLastPic.delegate = nil;
    _sdkAdLastRecommend.delegate = nil;
    _sdkAd13371.delegate = nil;
    
}

- (int)recommendCount
{
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

//- (void)requestPhotoList
//{
//    NSString *url = nil;
//    
//    if ([self.termId isEqualToString:kDftSingleGalleryTermId]) {
//        url = [NSString stringWithFormat:kUrlSinglePhotoGallery, self.newsId, [self recommendCount]];
//        
//        if ([type isEqualToString:kGroupPhotoCategory]) {
//            url = [url stringByAppendingFormat:@"&from=cat&fromId=%@", self.typeId];
//        } else if ([type isEqualToString:kGroupPhotoTag]) {
//            url = [url stringByAppendingFormat:@"&from=tag&fromId=%@", self.typeId];
//        } else if ([type isEqualToString:kGroupPhotoTag]) {
//            url = [url stringByAppendingFormat:@"&from=tag&fromId=%@&channelId=%@", self.typeId, self.typeId];
//        } else {
//            url = [url stringByAppendingFormat:@"&from=rec"];
//        }
//        
//    } 
//    else if (![self.termId isEqualToString:kDftChannelGalleryTermId]) {
//        url = [NSString stringWithFormat:kUrlTermPhotoGallery, self.termId, self.newsId, [self recommendCount]];
//        url = [url stringByAppendingFormat:@"&from=paper&fromId=%@", self.termId];
//    } 
//    else if (self.channelId) {
//        url = [NSString stringWithFormat:kUrlChannelPhotoGallery, self.channelId, self.newsId, [self recommendCount]];
//        url = [url stringByAppendingFormat:@"&from=news&fromId=%@", self.channelId];
//    }
//    
//    if (_request) {
//        [_request cancel];
//    }
//    _request = [SNURLRequest requestWithURL:url delegate:self];
//    _request.response = [[SNURLJSONResponse alloc] init];
//    [_request send];
//}

- (void)requestPhotoList {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:10];
    if ([self.termId isEqualToString:kDftSingleGalleryTermId]) {
        // ?gid=%@&rt=json&showSdkAd=1&moreCount=%d
        [params setValue:self.newsId forKey:@"gid"];
        [params setValue:[NSString stringWithFormat:@"%zd",[self recommendCount]] forKey:@"moreCount"];
        
        if ([type isEqualToString:kGroupPhotoCategory]) {
            [params setValue:self.typeId forKey:@"fromId"];
        } else if ([type isEqualToString:kGroupPhotoTag]) {
            [params setValue:self.typeId forKey:@"fromId"];
        } else if ([type isEqualToString:kGroupPhotoTag]) {
            [params setValue:@"channel" forKey:@"from"];
            [params setValue:self.typeId forKey:@"fromId"];
            [params setValue:self.typeId forKey:@"channelId"];
        } else {
            [params setValue:@"rec" forKey:@"from"];
        }
        
    } else if (![self.termId isEqualToString:kDftChannelGalleryTermId]) {
        // ?termId=%@&newsId=%@&rt=json&showSdkAd=1&moreCount=%d
        [params setValue:self.termId forKey:@"termId"];
        [params setValue:self.newsId forKey:@"newsId"];
        [params setValue:[NSString stringWithFormat:@"%zd",[self recommendCount]] forKey:@"moreCount"];
        [params setValue:@"paper" forKey:@"from"];
        [params setValue:self.termId forKey:@"fromId"];
    }
    else if (self.channelId) {
        // ?channelId=%@&newsId=%@&rt=json&showSdkAd=1&moreCount=%
        [params setValue:self.channelId forKey:@"channelId"];
        [params setValue:self.newsId forKey:@"newsId"];
        [params setValue:[NSString stringWithFormat:@"%zd",[self recommendCount]] forKey:@"moreCount"];
        [params setValue:@"news" forKey:@"from"];
        [params setValue:self.channelId forKey:@"fromId"];
    }
    
    [[[SNPhotoGalleryRequest alloc] initWithDictionary:params] send:^(SNBaseRequest *request, id responseObject) {
        if (responseObject) {
            [self loadWithJsonData:responseObject];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                @try {
                    [self saveAsCache];
                } @catch (NSException *exception) {
                    SNDebugLog(@"SNPhotoGalleryRequest exception reason--%@", exception.reason);
                } @finally {
                    
                }
            });
            
            [self seedDataFromGalleryItem];
            [self finishRequest:nil];
            //[super requestDidFinishLoad:request];
        } else {
            //SNDebugLog(@"SNPhotoSlideshow Model - requestDidFinishLoad:  load gallery fail");
            [self didFailLoadWithError:nil];
        }

    } failure:^(SNBaseRequest *request, NSError *error) {
        SNDebugLog(@"%@",error.localizedDescription);
        if (_slideshowDelegate && [_slideshowDelegate respondsToSelector:@selector(didFailedPreLoad:slideshow:)])
        {
            [_slideshowDelegate didFailedPreLoad:self.galleryLoadType slideshow:self];
        }
    }];
}

- (BOOL)isLoaded {
	return self.photoList != nil;
}


- (void)seedDataFromGalleryItem
{
    GalleryItem *galleryItem = self.photoList;
    self.newsId = galleryItem.newsId;
    self.termId = galleryItem.termId;
    self.shareContent = galleryItem.shareContent;
    self.commentNum = galleryItem.commentNum;
    self.title = galleryItem.title;
    self.photoList = galleryItem;
    self.subId = galleryItem.subId;
    self.stpAudCmtRsn = galleryItem.stpAudCmtRsn;
    int i = 0;
    
    self.photos = [NSMutableArray array];
    
    for (PhotoItem *pi in galleryItem.gallerySubItems) {
        SNPhoto *photo = [[SNPhoto alloc] init];
        photo.termId = galleryItem.termId;
        photo.newsId = galleryItem.newsId;
        photo.caption = pi.ptitle;
        photo.url	= pi.url;
        photo.info  = pi.abstract;
        photo.link  = pi.shareLink;
        photo.index = i++;
        photo.photoSource = self;
        
        if (photo) {
            [self.photos addObject:photo];
        }
    }
    
    self.moreRecommends = galleryItem.moreRecommends;
}

- (id)initWithGalleryItem:(GalleryItem *)galleryItem isOnlineMode:(BOOL)isOnlineMode
{
    
    self = [super init];
    if (self) {
        [SNNotificationManager addObserver:self selector:@selector(slideShowViewClosed) name:kSliderShowViewClosedNotification object:nil];
        _isOnlineMode = isOnlineMode;
        self.photoList = galleryItem;
        [self seedDataFromGalleryItem];
    }
    
    return self;
}

- (NSString *)commentNum {
	
//	//接口返回的实际数据少一条
//	if ([commentNum intValue] > 0) {
//		return [NSString stringWithFormat:@"%d", [commentNum intValue] - 1];
//	} 
	//评论数为-1的表示不可评论，但要显示为0
//	else if ([commentNum intValue] == -1) {
//		return @"0";
//	}
    if ([commentNum intValue] > 0)
    {
        return commentNum;
    }
    else if ([commentNum intValue] == -1)
    {
        return @"0";
    }
	return @"0";
}

- (NSString *)convertToLocalPathFromURL:(NSString *)url {
	
	if ([SNAPI isWebURL:url]) {
		return url;
	} 
	
	NSString *newsFolder	= [[SNDBManager currentDataBase] getNewsPaperFolderByTermId:self.termId];
	NSString *localImgPath	= [newsFolder stringByAppendingPathComponent:url];
	return localImgPath;
	
}




//	XML数据示例:
//<root>
//	<newsId>7789</newsId>
//	<type>新闻</type>
//	<title>80后夫妇闯荡生活路</title>
//	<time>2011-05-16 07:40</time>
//	<from>搜狐网</from>
//	<commentNum>0</commentNum>
//	<digNum>0</digNum>
//	<gallery>
//		<photo>
//			<ptitle>80后夫妇闯荡生活路</ptitle>
//			<pic>http://221.179.173.205/mpaper/1/20101025/365_5_74/cover.png</pic>
//			<abstract>艰辛生活路艰辛生活路艰辛生活路</abstract>
//		</photo>
//		<photo>
//			<ptitle>80后夫妇闯荡生活路</ptitle>
//			<pic>http://221.179.173.205/mpaper/1/20101025/365_5_74/cover.png</pic>
//			<abstract>艰辛生活路艰辛生活路艰辛生活路</abstract>
//		</photo>
//	</gallery>
//	<nextName>姚明亮相北京车展</nextName>
//	<nextId>7790</nextId>
//	<preName>姚明亮相上海车展</preName>
//	<preId>7788</preName>
//</root>
- (void)loadWithXMLData:(NSData *)xmlData {	
	@autoreleasepool {
	
		SNDebugLog(@"loadWithXMLData %@", [NSString stringWithCString:[xmlData bytes] encoding:NSUTF8StringEncoding]);
    
    self.photoList  = [[GalleryItem alloc] init];
    self.photoList.newsId   = self.newsId;
    self.photoList.termId   = self.termId;
		
		TBXML *tbxml = [TBXML tbxmlWithXMLData:xmlData];
		
		TBXMLElement *root = tbxml.rootXMLElement;
    
		self.photoList.title		    = [TBXML textForElement:[TBXML childElementNamed:kTitle parentElement:root]];
		self.photoList.commentNum		= [TBXML textForElement:[TBXML childElementNamed:kCommentNum parentElement:root]];
		self.photoList.shareContent     = [TBXML textForElement:[TBXML childElementNamed:kShareContent parentElement:root]];
    
    self.photoList.nextId       = [TBXML textForElement:[TBXML childElementNamed:kNextId parentElement:root]];
    self.photoList.nextName     = [TBXML textForElement:[TBXML childElementNamed:kNextName parentElement:root]];
    self.photoList.preId        = [TBXML textForElement:[TBXML childElementNamed:kPreId parentElement:root]];
    self.photoList.preName      = [TBXML textForElement:[TBXML childElementNamed:kPreName parentElement:root]];
    self.photoList.from         = [TBXML textForElement:[TBXML childElementNamed:kFrom parentElement:root]];
    
    TBXMLElement *subEles = [TBXML childElementNamed:@"subInfo" parentElement:root];
    if (subEles != nil) {
        self.photoList.subId = [TBXML textForElement:[TBXML childElementNamed:@"subId" parentElement:subEles]];
        SCSubscribeObject *subObj = [SCSubscribeObject subscribeObjFromXMLData:subEles];
        subObj.subId = self.photoList.subId;
        [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
    }
		
    //图集
		TBXMLElement *gallery = [TBXML childElementNamed:kGallery parentElement:root];
		TBXMLElement *photoE = [TBXML childElementNamed:kPhoto parentElement:gallery];
		NSMutableArray *photos = [[NSMutableArray alloc] init];
		while (photoE) {
			PhotoItem *photo    = [[PhotoItem alloc] init];
        photo.termId        = self.termId;
        photo.newsId        = self.newsId;
			photo.ptitle        = [TBXML textForElement:[TBXML childElementNamed:kPTitle parentElement:photoE]];
			photo.url           = [TBXML textForElement:[TBXML childElementNamed:kPic parentElement:photoE]];
        
			photo.url           = [self convertToLocalPathFromURL:photo.url];
        
			photo.abstract		= [TBXML textForElement:[TBXML childElementNamed:kAbstract parentElement:photoE]];
			photo.shareLink		= [TBXML textForElement:[TBXML childElementNamed:kShareLink parentElement:photoE]];
        photo.width         = [[TBXML textForElement:[TBXML childElementNamed:@"width" parentElement:photoE]] floatValue];
        photo.height        = [[TBXML textForElement:[TBXML childElementNamed:@"height" parentElement:photoE]] floatValue];
			[photos addObject:photo];
			
			photoE = [TBXML nextSiblingNamed:kPhoto searchFromElement:photoE];
		}
    
    self.photoList.gallerySubItems  = photos;
    
    //更多推荐
    //推荐组图不再具备 termId和newsId属性，只有一个gid属性。访问推荐组图时，也只用带上gid一个参数么日不用带上termId和newsId。为简化此情况的处理，同新闻组图共存与一个数据库表中，推荐组图仍保留termId和newsId，但termId 始终为0,newsId对应gid。在请求下载推荐组图时，如果发现组图termId为0，只带参数gid,否则，带上termId和newsId。
    
    TBXMLElement    *more           = [TBXML childElementNamed:kMore parentElement:root];
    TBXMLElement    *groupPic       = [TBXML childElementNamed:kGroupPic parentElement:root];
    NSMutableArray  *moreRecommend  = [[NSMutableArray alloc] init];
    while (groupPic) {
        RecommendGallery *recommend = [[RecommendGallery alloc] init];
        recommend.releatedTermId    = self.termId;
        recommend.releatedNewsId    = self.newsId;
        recommend.termId            = kDftSingleGalleryTermId;
        recommend.newsId            = [TBXML textForElement:[TBXML childElementNamed:kGroupPicId parentElement:groupPic]];
        recommend.title             = [TBXML textForElement:[TBXML childElementNamed:kGroupPicTitle parentElement:groupPic]];
        recommend.iconUrl           = [TBXML textForElement:[TBXML childElementNamed:kGroupPicIconUrl parentElement:groupPic]];
        [moreRecommend addObject:recommend];
        
        groupPic    = [TBXML nextSiblingNamed:kGroupPic searchFromElement:more];
    }
    
    self.photoList.moreRecommends = moreRecommend;
    
    
    // 4.0广告 解析定向回传参数 by jojo
    TBXMLElement *adInfoControls = [TBXML childElementNamed:@"adControlInfos" parentElement:root];
    
    if (adInfoControls) {
        NSMutableArray *adInfosArray = [NSMutableArray array];
        TBXMLElement *adInfoElm = [TBXML childElementNamed:@"adControlInfo" parentElement:adInfoControls];
        if (adInfoElm) {
            SNAdControllInfo *adInfoObj = [[SNAdControllInfo alloc] initWithXMLElement:adInfoElm];
            [adInfosArray addObject:adInfoObj];
            
            while (!!(adInfoElm = [TBXML nextSiblingNamed:@"adControlInfo" searchFromElement:adInfoElm])) {
                SNAdControllInfo *adInfoObj = [[SNAdControllInfo alloc] initWithXMLElement:adInfoElm];
                [adInfosArray addObject:adInfoObj];
            }
        }
        
        // 缓存本地数据库
        [[SNDBManager currentDataBase] adInfoAddOrUpdateAdInfos:adInfosArray withType:SNAdInfoTypePhotoListNews dataId:self.newsId categoryId:self.termId];
        
        // 在主线程 load广告数据
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshAdDataWithAdInfoControls:adInfosArray];
        });
    }
    
    // 解析shareRead
    TBXMLElement *shareRead = [TBXML childElementNamed:@"shareRead" parentElement:root];
    if (shareRead) {
        SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromXMLObj:shareRead];
        if (obj) {
            [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypePhoto contentId:self.newsId];
        }
    }
    
	}
}

//JSON参数示例:
//{
//	"commentNum":"-1",
//	"digNum":"0",
//	"from":"中国经济周刊",
//	"gallery":[
//	{
//		"abstract":"搜狐娱乐讯 2011年1月10日上海消息，近日，女演员刘涛飞抵上海虹桥机场....",
//		"pic":"http://221.179.173.138/img7/adapt/wb/grouppic/Img2335835_a_310_1000.jpg",
//		"ptitle":"刘涛现身机场煲电话粥 名牌傍身双助理伺候"
//	},
//	{
//		"pic":"http://221.179.173.138/img7/adapt/wb/grouppic/Img2335836_a_310_1000.jpg",
//		"ptitle":"刘涛现身机场煲电话粥 名牌傍身双助理伺候"
//	}
//	 ],
//	"newsId":"7788",
//	"time":"2011-01-11 00:00",
//	"title":"12312313",
//	"type":"组图"
//}

- (void)loadWithJsonData:(id)resData {
    //SNDebugLog(@"%@",resData);
    
    self.photoList  = [[GalleryItem alloc] init];
    self.photoList.termId   = self.termId ? self.termId : kDftSingleGalleryTermId;;
    self.photoList.newsId   = self.newsId;//组图推荐json里没有newsId，这里必须先赋值
    
	if ([resData isKindOfClass:[NSDictionary class]]) {
        //self.photoList.newsId       = [resData objectForKey:kNewsId]; 组图推荐json里没有newsId，会导致为0
        self.nextGid                = [resData objectForKey:kNextGid];
        self.photoList.type         = [resData objectForKey:kType];
		self.photoList.title        = [resData objectForKey:kTitle];
		self.photoList.commentNum   = [resData objectForKey:kCommentNum];
		self.photoList.shareContent = [resData objectForKey:kShareContent];
        self.photoList.time = resData[@"time"];
        
        self.photoList.nextId       = [resData objectForKey:kNextId];
        self.photoList.nextName     = [resData objectForKey:kNextName];
        self.photoList.preId        = [resData objectForKey:kPreId];
        self.photoList.preName      = [resData objectForKey:kPreName];
        self.photoList.from         = [resData objectForKey:kFrom];
        
        self.photoList.nextNewsLink = [resData objectForKey:kNextNewsLink];
        self.photoList.nextNewsLink2= [resData objectForKey:kNextNewsLink2];
        
        self.photoList.isLike       = [resData objectForKey:kIsLike];
        self.photoList.likeCount    = [resData objectForKey:kLikeCount];
        self.photoList.stpAudCmtRsn = [resData objectForKey:kStpAudCmtRsn];
        
        NSDictionary *subInfoDic = [resData objectForKey:@"subInfo"];
        if (subInfoDic && [subInfoDic isKindOfClass:[NSDictionary class]]) {
            self.photoList.subId = [subInfoDic objectForKey:@"subId"];
            SCSubscribeObject *subObj = [SCSubscribeObject subscribeObjFromJsonDic:subInfoDic];
            subObj.subId = self.photoList.subId;
            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
        }
		
		NSMutableArray * photos = [[NSMutableArray alloc] init];
		id gallery = [resData objectForKey:kGallery];
		//数组
		if ([gallery isKindOfClass:[NSArray class]]) {
			for (NSDictionary *pDic in gallery) {
				PhotoItem *photo    = [[PhotoItem alloc] init];
                photo.termId        = self.termId;
                photo.newsId        = self.newsId;
				photo.ptitle        = [pDic objectForKey:kPTitle];
				photo.url           = [pDic objectForKey:kPic];
				photo.abstract      = [pDic objectForKey:kAbstract];
				photo.shareLink     = [pDic objectForKey:kShareLink];
                photo.width         = [pDic[@"width"] floatValue];
                photo.height        = [pDic[@"height"] floatValue];
				if (photo) {
					[photos addObject:photo];					
				}
			}
		} 
		//单个
		else if ([gallery isKindOfClass:[NSDictionary class]]) {
			PhotoItem *photo    = [[PhotoItem alloc] init];
            photo.termId        = self.termId;
            photo.newsId        = self.newsId;
			photo.ptitle        = [gallery objectForKey:kPTitle];
			photo.url           = [gallery objectForKey:kPic];
			photo.abstract      = [gallery objectForKey:kAbstract];
			photo.shareLink     = [gallery objectForKey:kShareLink];
            photo.width         = [gallery[@"width"] floatValue];
            photo.height        = [gallery[@"height"] floatValue];
			if (photo) {
				[photos addObject:photo];				
			}
		}
        
        self.photoList.gallerySubItems  = photos;
        
        //更多推荐
        //推荐组图不再具备 termId和newsId属性，只有一个gid属性。访问推荐组图时，也只用带上gid一个参数么日不用带上termId和newsId。为简化此情况的处理，同新闻组图共存与一个数据库表中，推荐组图仍保留termId和newsId，但termId 始终为0,newsId对应gid。在请求下载推荐组图时，如果发现组图termId为0，只带参数gid,否则，带上termId和newsId。
        NSMutableArray *moreRecommend = [[NSMutableArray alloc] init];
        id more = [resData objectForKey:kMore];
        if ([more isKindOfClass:[NSArray class]]) {
            for (NSDictionary *pDic in more) {
                RecommendGallery *recommend = [[RecommendGallery alloc] init];
                recommend.releatedTermId    = self.termId;
                recommend.releatedNewsId    = self.newsId;
                recommend.termId            = kDftSingleGalleryTermId;
                recommend.newsId            = [pDic objectForKey:kGroupPicId];
                recommend.title             = [pDic objectForKey:kGroupPicTitle];
                recommend.iconUrl           = [pDic objectForKey:kGroupPicIconUrl];
                [moreRecommend addObject:recommend];
            }
        }
        else if([more isKindOfClass:[NSDictionary class]]){
            RecommendGallery *recommend = [[RecommendGallery alloc] init];
            recommend.releatedTermId    = self.termId;
            recommend.releatedNewsId    = self.newsId;
            recommend.termId            = kDftSingleGalleryTermId;
            recommend.newsId            = [more objectForKey:kGroupPicId];
            recommend.title             = [more objectForKey:kGroupPicTitle];
            recommend.iconUrl           = [more objectForKey:kGroupPicIconUrl];
            [moreRecommend addObject:recommend];
        }
        
        self.photoList.moreRecommends = moreRecommend;
        
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
                                                                 dataId:self.newsId
                                                             categoryId:self.termId];
                
                
                // 在主线程 load广告数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshAdDataWithAdInfoControls:parsedAdInfos];
                });
            }
        });
        
        // 解析shareRead by jojo
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *shareReadDic = [resData dictionaryValueForKey:@"shareRead" defalutValue:nil];
            SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:shareReadDic];
            if (obj) {
                [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypePhoto contentId:self.newsId];
            }
        });
    }
}


- (void)saveAsCache {
	if (!self.photoList) {
		return;
	}
	
	[[SNDBManager currentDataBase] addSingleGalleryIfNotExist:self.photoList];
	SNDebugLog(@"SNPhotoSlideshow - saveAsCache: save Gallery Cache complete termId=%@ newsId=%@"
               , self.photoList.termId, self.photoList.newsId);
    
    if (self.channelId && ![self.termId isEqualToString:kDftSingleGalleryTermId]) {
//        [[SNDBManager currentDataBase] markRollingNewsListItemAsReadByChannelId:self.channelId newsId:self.newsId];
        [SNRollingNewsPublicManager saveReadNewsWithNewsId:self.newsId ChannelId:self.channelId];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTModel

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more 
{
    if (self.isLoading) {
        return;
    }

    //already has data
    if (self.photos) {
        [self finishRequest:nil];
        //[super requestDidFinishLoad:nil];
        return;
    }
    
    
//    if (_isOnlineMode) {
    if (YES) {
        self.photoList  = [[SNDBManager currentDataBase] getGalleryByTermId:self.termId newsId:self.newsId];
        if (self.photoList != nil) {
            
            [self seedDataFromGalleryItem];
            [self finishRequest:nil];
            //[super requestDidFinishLoad:nil];
//            [self refreshAdData];
        }
        else
        {
            [self requestPhotoList];
        }
    }
    else
    {
        NewspaperItem *newspaper	= [[SNDBManager currentDataBase] getNewspaperByTermId:self.termId];
		if (newspaper != nil) {
            NSString *realpath = [newspaper realNewspaperPath];
			NSRange rangeLastPath	= [realpath rangeOfString:@"/" options: NSBackwardsSearch];
			if (rangeLastPath.location == NSNotFound) {
			}
			else {
				NSString *newsFileName	= [NSString stringWithFormat:@"%@_%@.xml", self.termId, self.newsId];
				NSString *newsFilePath	= [[realpath substringToIndex:rangeLastPath.location] 
										   stringByAppendingPathComponent:newsFileName];
				
				NSFileManager *fm	= [NSFileManager defaultManager];
				if ([fm fileExistsAtPath:newsFilePath]) {
					
					NSData *newsData	= [NSData dataWithContentsOfFile:newsFilePath];
					[self loadWithXMLData:newsData]; 
                    //[self didFinishLoad];
                    
                    [self seedDataFromGalleryItem];
                    [self finishRequest:nil];
                    //[super requestDidFinishLoad:nil];
				}
				else {
                    [self didFailLoadWithError:nil];
				}
			}
		}
		else {
            [self didFailLoadWithError:nil];
		}
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoSource

- (BOOL)hasMoreRecommend
{
    return self.moreRecommends.count > 0;
}

- (BOOL)hasFirstPhotoOfNextGroup
{
    return firstPhotoOfNextGroup != nil;
}

- (BOOL)hasPrevMoreRecommends
{
    return prevMoreRecommends && prevMoreRecommends.count > 0;
}

- (BOOL)hasLastPhotoOfPrevGroup {
    return lastPhotoOfPrevGroup != nil;
}

- (BOOL)hasSdkAdData {
    return self.sdkAdLastPic.dataState == SNAdDataStateReady;
}

- (NSInteger)numberOfPhotos {
    NSInteger count = self.photos.count;
    
    if ([self hasPrevMoreRecommends]) {
        count += 1;
    } else if ([self hasLastPhotoOfPrevGroup]) {
        count += 1;
    }
    
    if ([self hasMoreRecommend]) {
        count += 1;
    }
    
    if ([self hasFirstPhotoOfNextGroup]) {
        count += 1;
    }
    
    // 如果有广告数据 插入一页
    if ([self hasSdkAdData]) {
        count += 1;
    }
    
	return count;
}

- (NSInteger)maxPhotoIndex {
    NSInteger maxIndex = 0;
    if (self.photos && self.photos.count > 0) {
        maxIndex = self.photos.count - 1;
    }
    
    if ([self hasPrevMoreRecommends]) {
        maxIndex += 1;
    } else if  ([self hasLastPhotoOfPrevGroup]) {
        maxIndex += 1;
    }
    
    if ([self hasMoreRecommend]) {
        maxIndex += 1;
    }
    
    if ([self hasFirstPhotoOfNextGroup]) {
        maxIndex += 1;
    }
    
    if ([self hasSdkAdData]) {
        maxIndex += 1;
    }
    
	return maxIndex;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)photoIndex {
	if (photoIndex >= 0 && photoIndex < self.photos.count) {
		id photo = [self.photos objectAtIndex:photoIndex];
		if (photo == [NSNull null]) {
			return nil;
		} else {
			return photo;
		}
	} else {
		return nil;
	}
}

//- (void)requestDidStartLoad:(TTURLRequest*)request
//{
//    [super requestDidStartLoad:request];
//}


/**
 * The request has loaded data and been processed into a response.
 *
 * If the request is served from the cache, this is the only delegate method that will be called.
 */
//- (void)requestDidFinishLoad:(TTURLRequest*)request
//{
//    //解析,获取 _photoList
//    SNURLJSONResponse *dataRes = (SNURLJSONResponse *)request.response;
//    id resData = dataRes.rootObject;
//	if (resData) {
//		[self loadWithJsonData:resData];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self saveAsCache];
//        });
//        
//        [self seedDataFromGalleryItem];
//        [self finishRequest:request];
//        //[super requestDidFinishLoad:request];
//	} else {
//		//SNDebugLog(@"SNPhotoSlideshow Model - requestDidFinishLoad:  load gallery fail");
//        [self didFailLoadWithError:nil];
//	}
//    
//}


/**
 * The request failed to load.
 */
//- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
//{
//    SNDebugLog(@"SNPhotoSlideshow Model - didFailLoadWithError ,%@", [error localizedDescription]);
//    [super request:request didFailLoadWithError:error];
//    if (_slideshowDelegate && [_slideshowDelegate respondsToSelector:@selector(didFailedPreLoad:slideshow:)])
//    {
//        [_slideshowDelegate didFailedPreLoad:self.galleryLoadType slideshow:self];
//    }
//}

- (void)slideShowViewClosed {
    showTimes = 0;
}

#pragma mark - load ad sdk data
//组图新闻进组图
- (void)refreshAdData {
    return;
    showTimes ++;
    if ([[SNAdvertiseManager sharedManager] isSDKAdEnable] && (showTimes > 2)) {//正文进slider页会两次请求广告，应大数据那边要求跳过这两次
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *cId = (self.channelId ? self.channelId :
                             (self.termId ? self.termId : (kAdInfoDefaultCategoryId)));
 
            NSArray *adCtrlInfos = [[SNDBManager currentDataBase] adInfoGetAdInfosByType:SNAdInfoTypePhotoListNews
                                                                                  dataId:self.newsId
                                                                              categoryId:cId];
            
            if (adCtrlInfos.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL ret = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasLoadAd"];
                    if (ret) {
                        return ;
                    }
                    SNAdControllInfo *adCtrlInfo = adCtrlInfos[0];
                    for (SNAdInfo *adInfo in adCtrlInfo.adInfos) {
                        [adInfo.filterInfo setObject:self.newscate ? :@"" forKey:@"newscate"];
                        if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdSlideshowTail] &&
                            !self.sdkAdLastPic) {
                            self.sdkAdLastPic = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                               adInfoParam:adInfo.filterInfo];
                            self.sdkAdLastPic.delegate = self;
                            self.sdkAdLastPic.appChannel = adInfo.appChannel;
                            self.sdkAdLastPic.newsChannel = adInfo.newsChannel;
                            self.sdkAdLastPic.gbcode = adInfo.gbcode;
                            self.sdkAdLastPic.adId = adInfo.adId;
                            [self.sdkAdLastPic refreshAdData:NO];
                        }
                        if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdGroupPicRecommendTail] &&
                            !self.sdkAdLastRecommend ) {
                            self.sdkAdLastRecommend = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                                     adInfoParam:adInfo.filterInfo];
                            self.sdkAdLastRecommend.delegate = self;
                            self.sdkAdLastRecommend.appChannel = adInfo.appChannel;
                            self.sdkAdLastRecommend.newsChannel = adInfo.newsChannel;
                            self.sdkAdLastRecommend.gbcode = adInfo.gbcode;
                            self.sdkAdLastRecommend.adId = adInfo.adId;
                            [self.sdkAdLastRecommend refreshAdData:NO];
                        }
                        if (([adInfo.adSpaceId isEqualToString:SpaceId13371] || [adInfo.adSpaceId isEqualToString:SpaceId12716])
                            &&!self.sdkAd13371 )
                        {
                            self.sdkAd13371 = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                                     adInfoParam:adInfo.filterInfo];
                            self.sdkAd13371.delegate = self;
                            self.sdkAd13371.appChannel = adInfo.appChannel;
                            self.sdkAd13371.newsChannel = adInfo.newsChannel;
                            self.sdkAd13371.gbcode = adInfo.gbcode;
                            self.sdkAd13371.adId = adInfo.adId;
                            [self.sdkAd13371 refreshAdData:NO];
                        }
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLoadAd"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                });
            }
        });
    }
}

- (void)refreshAdDataWithAdInfoControls:(NSArray *)adCtrlInfos {
    if ([[SNAdvertiseManager sharedManager] isSDKAdEnable]) {
        if (adCtrlInfos.count > 0) {
            SNAdControllInfo *adCtrlInfo = adCtrlInfos[0];
            for (SNAdInfo *adInfo in adCtrlInfo.adInfos) {
                if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdSlideshowTail] &&
                    !self.sdkAdLastPic) {
                    self.sdkAdLastPic = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                       adInfoParam:adInfo.filterInfo];
                    self.sdkAdLastPic.delegate = self;
                    self.sdkAdLastPic.appChannel = adInfo.appChannel;
                    self.sdkAdLastPic.newsChannel = adInfo.newsChannel;
                    self.sdkAdLastPic.gbcode = adInfo.gbcode;
                    self.sdkAdLastPic.adId = adInfo.adId;
                    [self.sdkAdLastPic refreshAdData:NO];
                }
                if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdGroupPicRecommendTail] &&
                    !self.sdkAdLastRecommend) {
                    self.sdkAdLastRecommend = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                             adInfoParam:adInfo.filterInfo];
                    self.sdkAdLastRecommend.delegate = self;
                    self.sdkAdLastRecommend.appChannel = adInfo.appChannel;
                    self.sdkAdLastRecommend.newsChannel = adInfo.newsChannel;
                    self.sdkAdLastRecommend.gbcode = adInfo.gbcode;
                    self.sdkAdLastRecommend.adId = adInfo.adId;
                    [self.sdkAdLastRecommend refreshAdData:NO];
                }
                
                if (([adInfo.adSpaceId isEqualToString:SpaceId13371] || [adInfo.adSpaceId isEqualToString:SpaceId12716]) &&
                    !self.sdkAd13371) {
                    self.sdkAd13371 = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                             adInfoParam:adInfo.filterInfo];
                    self.sdkAd13371.delegate = self;
                    self.sdkAd13371.appChannel = adInfo.appChannel;
                    self.sdkAd13371.newsChannel = adInfo.newsChannel;
                    self.sdkAd13371.gbcode = adInfo.gbcode;
                    self.sdkAd13371.adId = adInfo.adId;
                    [self.sdkAd13371 refreshAdData:NO];
                }
            }
        }
    }
}

- (void)adViewDidAppearWithCarrier:(SNAdDataCarrier *)carrier {
    [self didFinishLoad];
    //组图上报广告加载成功数据
    //组图加载在正文页上报
//    [carrier reportForLoadTrack];
}

- (void)adViewDidFailToLoadWithCarrier:(SNAdDataCarrier *)carrier {
    if (self.sdkAdLastPic == carrier) {
        self.sdkAdLastPic = nil;
    }
    
    if (self.sdkAdLastRecommend == carrier) {
        self.sdkAdLastRecommend = nil;
    }
    
    if (self.sdkAd13371 == carrier) {
        self.sdkAd13371 = nil;
    }
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasLoadAd"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

//更新组图大图广告
- (void)recommendAdRefresh:(NSNotification *)notification {
    NSDictionary *dic = [notification userInfo];
    
    if (dic && dic.count > 0) {
        NSString *newsId = dic[@"kNewsId"];
        SNAdDataCarrier *carrier = dic[@"kCarrier"];
        if (newsId.length > 0 ){//&& [newsId isEqualToString:_newsId]) {
            if ([kSNAdSpaceIdGroupPicRecommendTail isEqualToString:carrier.adSpaceId]) {
                self.sdkAdLastRecommend = carrier;
                [self.groupPicturesSlideshowViewController displayCurrentSlideshowView];
                if (dic.count > 2 && [dic[@"kIsLastGroup"] isEqualToString:@"1"]) {
                    [carrier reportForDisplayTrack];
                }
            }
            else if ([SpaceId13371 isEqualToString:carrier.adSpaceId] || [SpaceId12716 isEqualToString:carrier.adSpaceId])
            {
                self.sdkAd13371 = carrier;
                [self.groupPicturesSlideshowViewController displayCurrentSlideshowView];
                if (dic.count > 2 && [dic[@"kIsLastGroup"] isEqualToString:@"1"]) {
                    [carrier reportForDisplayTrack];
                }
            }
            else if ([kSNAdSpaceIdSlideshowTail isEqualToString:carrier.adSpaceId]) {
                self.sdkAdLastPic = carrier;
            }
            else if([SpaceId12716 isEqualToString:carrier.adSpaceId] || [SpaceId13371 isEqualToString:carrier.adSpaceId])
            {
                self.sdkAd13371 = carrier;
                [self.groupPicturesSlideshowViewController displayCurrentSlideshowView];
                if (dic.count > 2 && [dic[@"kIsLastGroup"] isEqualToString:@"1"]) {
                    [carrier reportForDisplayTrack];
                }
            }
        }
    }
}

@end
