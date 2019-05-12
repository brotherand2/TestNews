//
//  SNPhotoListModel.m
//  sohunews
//
//  Created by 雪 李 on 11-12-14.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//

#import "SNPhotoListModel.h"
#import "SNURLJSONResponse.h"
#import "TBXML.h"
#import "SNDBManager.h"
#import "SNDatabase_Photo.h"
#import "SNDatabase_Gallery.h"
#import "NSDictionaryExtend.h"
#import "SNPhotoListTableItem.h"
#import "SNPhoto.h"

@interface SNPhotoListModel()
@property (nonatomic, retain) NSMutableDictionary *requestDic;
- (void)preloadImage;
@end

@interface SNPhotoListModel(loadData) 
- (void)loadWithJsonData:(id)resData;
- (void)loadWithXMLData:(NSData *)xmlData;
@end

@implementation SNPhotoListModel
@synthesize title;
@synthesize termId  = _termId;
@synthesize newsId  = _newsId;
@synthesize channelId = _channelId;
@synthesize nextGid = _nextGid;
@synthesize photoList   = _photoList;
@synthesize requestDic = _requestDic;
@synthesize userInfo = _userInfo;
@synthesize photoListItems = _photoListItems;
@synthesize delegate = _delegate;
@synthesize sdkAdLastPic = _sdkAdLastPic;
@synthesize sdkAdLastRecommend = _sdkAdLastRecommend;
@synthesize sdkAdTextPic = _sdkAdTextPic;
@synthesize sdkAdNewsRecommend = _sdkAdNewsRecommend;

- (NSMutableDictionary *)requestDic {
    if (!_requestDic) {
        _requestDic = [[NSMutableDictionary alloc] init];
    }
    return _requestDic;
}

- (SNPhotoListModel*)initWithTermId:(NSString*)termId
                             newsId:(NSString*)newsId 
                          channelId:(NSString*)channelId 
                       isOnlineMode:(BOOL)isOnlineMode
                      userInfo:(NSDictionary *)userInfo
{
    if(self = [super init])
    {
        self.termId         = termId;
        self.newsId         = newsId;
        self.channelId      = channelId;
        _isOnlineMode       = isOnlineMode;
        self.userInfo       = userInfo;
        
        [self reloadSdkAdData];
    }
    
    return self;
}

- (void)preloadImage {
    if (self.requestDic.count > 1) {
        return;
    }
    NSString *netMode = [[SNUtility getApplicationDelegate] checkNetMode];
    if ([netMode isEqualToString:@"wifi"]) {
        _preLoadNum = 3;
    }
    else {
        _preLoadNum = 2;
    }
    
    int loadNum = _preLoadNum;
    for (PhotoItem *item in self.photoList.gallerySubItems) {
        if (self.requestDic.count >= _preLoadNum) {
            break;
        }
        
        if ([item url] && ![item path]) {
            [[SNDBManager currentDataBase] downloadPhoto:item delegate:self];
            --loadNum;
            [self.requestDic setObject:item forKey:item.url];
            SNDebugLog(@"requestDic number:%d", self.requestDic.count);
        }
        if (!loadNum) {
            break;
        }
    }
}

- (int)recommendCount
{
    switch ((int)TTApplicationFrame().size.height)
    {
        case 548:
            return 8;
        case 568:
            return 8;
        case 460:
            return 6;
    }
    
    return 6;
}

- (void)requestPhotoList
{
    NSString *url = nil;
    
    if ([self.termId isEqualToString:kDftSingleGalleryTermId]) {
        url = [NSString stringWithFormat:kUrlSinglePhotoGallery, self.newsId, [self recommendCount]];
        url = [url stringByAppendingFormat:@"&from=rec"];
    } else if (self.termId && ![self.termId isEqualToString:kDftChannelGalleryTermId]) {
        url = [NSString stringWithFormat:kUrlTermPhotoGallery, self.termId, self.newsId, [self recommendCount]];
        url = [url stringByAppendingFormat:@"&from=paper&fromId=%@", self.termId];
    } else if (self.channelId) {
        url = [NSString stringWithFormat:kUrlChannelPhotoGallery, self.channelId, self.newsId, [self recommendCount]];
        url = [url stringByAppendingFormat:@"&from=news&fromId=%@", self.channelId];
    } else if (self.newsId) {
        url = [NSString stringWithFormat:kUrlNewsIdPhotoGallery, self.newsId, [self recommendCount]];
    }
    
    SNURLRequest *request = [SNURLRequest requestWithURL:url delegate:self];
    request.response = [[[SNURLJSONResponse alloc] init] autorelease];
    [request send];
}

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more 
{
    if (self.isLoading) {
        return;
    }
    self.photoListItems = [NSMutableArray array];
    TT_RELEASE_SAFELY(_requestDic);
    if (_isOnlineMode) {
        BOOL needsRefresh = NO;
        
        if (self.channelId && self.newsId) {
            RollingNewsListItem *listItemCache = [[SNDBManager currentDataBase] getRollingNewsListItemByChannelId:self.channelId newsId:self.newsId];
            needsRefresh = listItemCache ? [listItemCache.expired isEqualToString:@"1"] : NO;
        } else if (![self.termId isEqualToString:kDftChannelGalleryTermId] && self.newsId) {
            SNSpecialNews *listItemCache = [[SNDBManager currentDataBase] getSpecialNewsByTermId:self.termId newsId:self.newsId];
            needsRefresh = listItemCache ? [listItemCache.expired isEqualToString:@"1"] : NO;
        }
        
        self.photoList  = [[SNDBManager currentDataBase] getGalleryByTermId:self.termId newsId:self.newsId];
        [self createPhotoItems];
        if (self.photoList != nil) {
            if (self.channelId && ![self.termId isEqualToString:kDftSingleGalleryTermId]) {
                [[SNDBManager currentDataBase] markRollingNewsListItemAsReadAndNotExpiredByChannelId:self.channelId newsId:self.newsId];
            } else if (![self.termId isEqualToString:kDftSingleGalleryTermId] && self.newsId) {
                [[SNDBManager currentDataBase] markSpecialNewsListItemAsReadAndNotExpiredByTermId:self.termId newsId:self.newsId];
            }
           
            // 检查updateTime
            if (!needsRefresh) {
                NSString *updateTime = [self.userInfo stringValueForKey:kUpdateTime defaultValue:nil];
                needsRefresh = [updateTime isKindOfClass:[NSString class]] &&
                                [self.photoList.updateTime isKindOfClass:[NSString class]] &&
                                ![updateTime isEqualToString:self.photoList.updateTime];
            }

            if (self.delegate && [self.delegate respondsToSelector:@selector(photoListModelDidFinishLoad)])
            {
                NSObject *obj = (NSObject *)self.delegate;
                [obj performSelectorOnMainThread:@selector(photoListModelDidFinishLoad)
                                                withObject:nil
                                             waitUntilDone:[NSThread isMainThread]];
            }
//            [self didFinishLoad];
        }
        else
        {
            needsRefresh = YES;
        }
        
        if (needsRefresh) {
            [self requestPhotoList];
        }
    }
    else
    {
        NewspaperItem *newspaper	= [[SNDBManager currentDataBase] getNewspaperByTermId:self.termId];

        NSString *newspaperPath = [self.userInfo stringValueForKey:kNewsPaperDir defaultValue:nil];

		if (newspaper != nil || newspaperPath.length) {
            NSString *newsFilePath = nil;
            NSString *newsFileName	= [NSString stringWithFormat:@"%@_%@.xml", self.termId, self.newsId];
            
            if (newspaperPath) {
                newsFilePath = [newspaperPath stringByAppendingPathComponent:newsFileName];
            } else {
                NSString *realpath = [newspaper realNewspaperPath];
                NSRange rangeLastPath	= [realpath rangeOfString:@"/" options: NSBackwardsSearch];
                if (rangeLastPath.location != NSNotFound) {
                    newsFilePath	= [[realpath substringToIndex:rangeLastPath.location]
                                       stringByAppendingPathComponent:newsFileName];
                }
            }
				
            NSFileManager *fm	= [NSFileManager defaultManager];
            if (newsFilePath && [fm fileExistsAtPath:newsFilePath]) {
                
                NSData *newsData	= [NSData dataWithContentsOfFile:newsFilePath];
                [self loadWithXMLData:newsData];
                if (self.delegate && [self.delegate respondsToSelector:@selector(photoListModelDidFinishLoad)])
                {
                    NSObject *obj = (NSObject *)self.delegate;
                    [obj performSelectorOnMainThread:@selector(photoListModelDidFinishLoad)
                                                    withObject:nil
                                                 waitUntilDone:[NSThread isMainThread]];
                }
            }
            else {
                SNDebugLog(@"SNPhotoListModel-load : news file not exist,path = %@",newsFilePath);
                [self didFailLoadWithError:nil];
            }
		}
		else {
			SNDebugLog(@"SNPhotoListModel-load : Can't find newspaper,newsid = %@",self.newsId);
            [self didFailLoadWithError:nil];
		}
    }
}

- (BOOL)isLoaded {
	return _photoList != nil;
}

- (NSString *)convertToLocalPathFromURL:(NSString *)url {
	
	if ([url hasPrefix:@"http"]) {
		return url;
	} 
	
    NSString *newsFolder = [_userInfo stringValueForKey:kNewsPaperDir defaultValue:nil];
    if (newsFolder.length == 0) {
        newsFolder	= [[SNDBManager currentDataBase]
                       getNewsPaperFolderByTermId:self.termId];
    }
	NSString *localImgPath	= [newsFolder stringByAppendingPathComponent:url];
	return localImgPath;
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
    self.photoList  = [[[GalleryItem alloc] init] autorelease];
    self.photoList.termId   = self.termId ? self.termId : kDftSingleGalleryTermId;
    self.photoList.newsId   = self.newsId;//组图推荐json里没有newsId，这里必须先赋值
    if (self.photoListItems.count > 0) {
        [self.photoListItems removeAllObjects];
    }
    
    SNDebugLog(@"SNPhotoListModel - loadWithJsonData: termId=%@ newsId=%@"
               , self.termId, self.newsId);
    
	if ([resData isKindOfClass:[NSDictionary class]]) {
		//self.photoList.newsId       = [resData objectForKey:kNewsId]; 组图推荐json里没有newsId，会导致为0
        SNDebugLog(@"SNPhotoListModel - loadWithJsonData: newsId=%@",[resData objectForKey:kNewsId]);
        self.nextGid                = [resData objectForKey:kNextGid];
        self.photoList.type         = [resData objectForKey:kType];
		self.photoList.title        = [resData objectForKey:kTitle];
		self.photoList.commentNum   = [resData objectForKey:kCommentNum];
		self.photoList.shareContent = [resData objectForKey:kShareContent];
        self.photoList.time         = [resData objectForKey:kTime];
        self.photoList.updateTime   = [resData objectForKey:kUpdateTime];
        self.photoList.nextId       = [resData objectForKey:kNextId];
        self.photoList.nextNewsLink = [resData objectForKey:kNextNewsLink];
        self.photoList.nextNewsLink2= [resData objectForKey:kNextNewsLink2];
        self.photoList.nextName     = [resData objectForKey:kNextName];
        self.photoList.preId        = [resData objectForKey:kPreId];
        self.photoList.preName      = [resData objectForKey:kPreName];
        self.photoList.from         = [resData objectForKey:kFrom];
        self.photoList.isLike       = [resData objectForKey:kIsLike];
        self.photoList.likeCount    = [resData objectForKey:kLikeCount];
        self.photoList.cmtStatus      = [resData objectForKey:kCmtStatus];
        self.photoList.cmtHint      = [resData objectForKey:kCmtHint];
        
        if (!self.photoList.updateTime) {
            self.photoList.updateTime = [_userInfo stringValueForKey:kUpdateTime defaultValue:nil];
        }
        
        NSDictionary *subInfoDic = [resData objectForKey:@"subInfo"];
        if (subInfoDic && [subInfoDic isKindOfClass:[NSDictionary class]]) {
            self.photoList.subId = [subInfoDic objectForKey:@"subId"];
            SCSubscribeObject *subObj = [SCSubscribeObject subscribeObjFromJsonDic:subInfoDic];
            subObj.subId = self.photoList.subId;
            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
        }
		
		NSMutableArray * photos = [[NSMutableArray alloc] init];
		id gallery = [resData objectForKey:kGallery];
        int itemIndex = 0;
		//数组
		if ([gallery isKindOfClass:[NSArray class]]) {
			for (NSDictionary *pDic in gallery) {
				PhotoItem *photo    = [[PhotoItem alloc] init];
                photo.termId        = self.termId;
                photo.newsId        = self.newsId;
				photo.ptitle        = [pDic objectForKey:kPTitle];
				photo.url           = [pDic objectForKey:kPic];
                if (photo.url) {
                    photo.url = [SNUtility stringTrimming:photo.url];
                }
				photo.abstract      = [pDic objectForKey:kAbstract];
				photo.shareLink     = [pDic objectForKey:kShareLink];
                photo.width         = [pDic[@"width"] floatValue];
                photo.height        = [pDic[@"height"] floatValue];
				if (photo) {
                    SNPhotoListTableItem *item  = [[SNPhotoListTableItem alloc] initWithItem:photo];
                    item.index  = itemIndex++;
                    item.photo  = photo;
//                    float height = [SNPhotoListTableCell tableView:tableView rowHeightForObject:item];
//                    item.cellHeight = height;
                    [self.photoListItems addObject:item];
					[photos addObject:photo];
					TT_RELEASE_SAFELY(photo);
                    TT_RELEASE_SAFELY(item);
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
            if (photo.url) {
                photo.url = [SNUtility stringTrimming:photo.url];
            }
			photo.abstract      = [gallery objectForKey:kAbstract];
			photo.shareLink     = [gallery objectForKey:kShareLink];
            photo.width         = [gallery[@"width"] floatValue];
            photo.height        = [gallery[@"height"] floatValue];
			if (photo) {
                SNPhotoListTableItem *item  = [[SNPhotoListTableItem alloc] initWithItem:photo];
                item.index  = itemIndex;

                [self.photoListItems addObject:item];
				[photos addObject:photo];
                
				TT_RELEASE_SAFELY(photo);
                TT_RELEASE_SAFELY(item);
			}
		}
        
        self.photoList.gallerySubItems  = photos;
        [photos release];
        
        //更多推荐
        //推荐组图不再具备 termId和newsId属性，只有一个gid属性。访问推荐组图时，也只用带上gid一个参数,不用带上termId和newsId。为简化此情况的处理，同新闻组图共存与一个数据库表中，推荐组图仍保留termId和newsId，但termId 始终为0,newsId对应gid。在请求下载推荐组图时，如果发现组图termId为0，只带参数gid,否则，带上termId和newsId。
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
                if (recommend.iconUrl) {
                    recommend.iconUrl = [SNUtility stringTrimming:recommend.iconUrl];
                }
                
                [moreRecommend addObject:recommend];
                [recommend release];
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
            if (recommend.iconUrl) {
                recommend.iconUrl = [SNUtility stringTrimming:recommend.iconUrl];
            }
            [moreRecommend addObject:recommend];
            [recommend release];
        }
        
        self.photoList.moreRecommends = moreRecommend;
        [moreRecommend release];
        
        // 4.0广告 解析接口返回的广告定向数据 并且缓存之 by jojo
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *adInfoControls = [(NSDictionary *)resData arrayValueForKey:@"adControlInfos" defaultValue:nil];
            if (adInfoControls) {
                NSMutableArray *parsedAdInfos = [NSMutableArray array];
                for (NSDictionary *adInfoDic in adInfoControls) {
                    if ([adInfoDic isKindOfClass:[NSDictionary class]]) {
                        SNAdControllInfo *adControlInfo = [[SNAdControllInfo alloc] initWithJsonDic:adInfoDic];
                        [parsedAdInfos addObject:adControlInfo];
                        TT_RELEASE_SAFELY(adControlInfo);
                    }
                }
                // 添加到缓存
                [[SNDBManager currentDataBase] adInfoAddOrUpdateAdInfos:parsedAdInfos
                                                               withType:SNAdInfoTypePhotoListNews
                                                                 dataId:self.newsId
                                                             categoryId:self.termId];
                
                
                // 在主线程 load广告数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadSdkAdDataWithAdCtrlInfos:parsedAdInfos];
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
    
    if (![SNUtility getApplicationDelegate].shouldDownloadImagesManually) {
        [self preloadImage];        
    }
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
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	SNDebugLog(@"loadWithXMLData %@", [NSString stringWithCString:[xmlData bytes] encoding:NSUTF8StringEncoding]);
    
    self.photoList  = [[[GalleryItem alloc] init] autorelease];
    self.photoList.termId   = self.termId;
    self.photoList.newsId   = self.newsId;
	
	TBXML *tbxml = [TBXML tbxmlWithXMLData:xmlData];
	
	TBXMLElement *root = tbxml.rootXMLElement;
    
	self.photoList.title		    = [TBXML textForElement:[TBXML childElementNamed:kTitle parentElement:root]];
	self.photoList.commentNum		= [TBXML textForElement:[TBXML childElementNamed:kCommentNum parentElement:root]];
	self.photoList.shareContent     = [TBXML textForElement:[TBXML childElementNamed:kShareContent parentElement:root]];
    
    self.photoList.nextId       = [TBXML textForElement:[TBXML childElementNamed:kNextId parentElement:root]];
    self.photoList.nextNewsLink = [TBXML textForElement:[TBXML childElementNamed:kNextNewsLink parentElement:root]];
    self.photoList.nextNewsLink2= [TBXML textForElement:[TBXML childElementNamed:kNextNewsLink parentElement:root]];
    self.photoList.nextName     = [TBXML textForElement:[TBXML childElementNamed:kNextName parentElement:root]];
    self.photoList.preId        = [TBXML textForElement:[TBXML childElementNamed:kPreId parentElement:root]];
    self.photoList.preName      = [TBXML textForElement:[TBXML childElementNamed:kPreName parentElement:root]];
    self.photoList.from         = [TBXML textForElement:[TBXML childElementNamed:kFrom parentElement:root]];
    self.photoList.time         = [TBXML textForElement:[TBXML childElementNamed:kTime parentElement:root]];
    self.photoList.updateTime   = [TBXML textForElement:[TBXML childElementNamed:kUpdateTime parentElement:root]];
    self.photoList.cmtStatus    = [TBXML textForElement:[TBXML childElementNamed:kCmtStatus parentElement:root]];
    self.photoList.cmtHint      = [TBXML textForElement:[TBXML childElementNamed:kCmtHint parentElement:root]];
    
    TBXMLElement *subEles = [TBXML childElementNamed:@"subInfo" parentElement:root];
    if (subEles != nil) {
        self.photoList.subId = [TBXML textForElement:[TBXML childElementNamed:@"subId" parentElement:subEles]];
        if (self.photoList.subId.length > 0) {
            SCSubscribeObject *subObj = [SCSubscribeObject subscribeObjFromXMLData:subEles];
            subObj.subId = self.photoList.subId;
            [[SNDBManager currentDataBase] updateSubscribeCenterSubscribeObject:subObj addIfNotExist:YES];
        }
    }
    
    // 解析shareRead by jojo
    TBXMLElement *shareReadElm = [TBXML childElementNamed:@"shareRead" parentElement:root];
    SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromXMLObj:shareReadElm];
    if (obj) [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypePhoto contentId:self.newsId];
	
    //图集
	TBXMLElement *gallery = [TBXML childElementNamed:kGallery parentElement:root];
	TBXMLElement *photoE = [TBXML childElementNamed:kPhoto parentElement:gallery];
	NSMutableArray *photos = [[NSMutableArray alloc] init];
    
    int itemIndex = 0;
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
        
        if (photo) {
            SNPhotoListTableItem *item  = [[SNPhotoListTableItem alloc] initWithItem:photo];
            item.index  = itemIndex++;
            
            [self.photoListItems addObject:item];
            //[photos addObject:photo];
            
            //TT_RELEASE_SAFELY(photo);
            TT_RELEASE_SAFELY(item);
        }
        SNDebugLog(@"SNPhotoListModel - loadWithXMLData:photo.url = %@", photo.url);
		TT_RELEASE_SAFELY(photo);
		
		photoE = [TBXML nextSiblingNamed:kPhoto searchFromElement:photoE];
	}
    
    self.photoList.gallerySubItems  = photos;
    [photos release];
    
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
        [recommend release];

        groupPic    = [TBXML nextSiblingNamed:kGroupPic searchFromElement:more];
    }
    
    self.photoList.moreRecommends = moreRecommend;
    [moreRecommend release];
    
	[pool release];
}

- (void)saveAsCache {
	if (!self.photoList) {
		return;
	}
	
	[[SNDBManager currentDataBase] addSingleGalleryOrUpdate:self.photoList];
	SNDebugLog(@"SNPhotoListModel - saveAsCache: save Gallery Cache complete termId=%@ newsId=%@"
               , self.photoList.termId, self.photoList.newsId);
    
    if (self.channelId && ![self.termId isEqualToString:kDftSingleGalleryTermId]) {
        [[SNDBManager currentDataBase] markRollingNewsListItemAsReadAndNotExpiredByChannelId:self.channelId newsId:self.newsId];
    } else if (![self.termId isEqualToString:kDftSingleGalleryTermId] && self.newsId) {
        [[SNDBManager currentDataBase] markSpecialNewsListItemAsReadAndNotExpiredByTermId:self.termId newsId:self.newsId];
    }
    
}


- (void)dealloc
{
    [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];

    for (NSString *url in [_requestDic allKeys]) {
        [[SNDBManager currentDataBase] removeDelegatesForURL:url];
        [[SNDBManager currentDataBase] cancelPhotoDownloadByUrl:url];
    }
    
    //[[SNDBManager currentDataBase] cleanupAllPhotoDownload];
    
    TT_RELEASE_SAFELY(_requestDic);
    TT_RELEASE_SAFELY(_termId);
    TT_RELEASE_SAFELY(_newsId);
    TT_RELEASE_SAFELY(_channelId);
    TT_RELEASE_SAFELY(_photoList);
    TT_RELEASE_SAFELY(_nextGid);
    TT_RELEASE_SAFELY(_userInfo);
    TT_RELEASE_SAFELY(_photoListItems);
    
    _sdkAdLastPic.delegate = nil;
    _sdkAdLastRecommend.delegate = nil;
    _sdkAdNewsRecommend.delegate = nil;
    _sdkAdTextPic.delegate = nil;
    
    TT_RELEASE_SAFELY(_sdkAdLastPic);
    TT_RELEASE_SAFELY(_sdkAdLastRecommend);
    TT_RELEASE_SAFELY(_sdkAdTextPic);
    TT_RELEASE_SAFELY(_sdkAdNewsRecommend);
    
    [super dealloc];
}

#pragma mark -
#pragma mark TTURLRequestDelegate
/**
 * The request has begun loading.
 *
 * This method will not be called if the data is loaded immediately from the cache.
 * @see requestDidFinishLoad:
 */
- (void)requestDidStartLoad:(id)data
{
    if ([data isKindOfClass:[TTURLRequest class]]) {
        TTURLRequest *request = data;
        [super requestDidStartLoad:request];
    }    
}

/**
 * The request has loaded some more data.
 *
 * Check the totalBytesLoaded and totalBytesExpected properties for details.
 */
- (void)requestDidUploadData:(TTURLRequest*)request
{
    [super requestDidUploadData:request];
}

/**
 * The request has loaded data and been processed into a response.
 *
 * If the request is served from the cache, this is the only delegate method that will be called.
 */
- (void)requestDidFinishLoad:(id)data
{
    if ([data isKindOfClass:[TTURLRequest class]]) {
        //解析,获取 _photoList
        
        TTURLRequest *request = data;
        SNURLJSONResponse *dataRes = (SNURLJSONResponse *)request.response;
        id resData = dataRes.rootObject;
        if (resData) {
            SNDebugLog(@"%@",resData);
            
            [self loadWithJsonData:resData];
            [self saveAsCache];
            if (self.delegate && [self.delegate respondsToSelector:@selector(photoListModelDidFinishLoad)]) {
                NSObject *obj = (NSObject *)self.delegate;
                [obj performSelectorOnMainThread:@selector(photoListModelDidFinishLoad)
                                                withObject:nil
                                             waitUntilDone:[NSThread isMainThread]];
            }
            
        } else {
            SNDebugLog(@"SNPhotoListModel - requestDidFinishLoad:  load gallery fail");
            if (self.delegate && [self.delegate respondsToSelector:@selector(photoListModelDidFailToLoadWithError:)]) {
                NSObject *obj = (NSObject *)self.delegate;
                [obj performSelectorOnMainThread:@selector(photoListModelDidFailToLoadWithError:)
                                                withObject:nil
                                             waitUntilDone:[NSThread isMainThread]];
            }
        }
//        [super requestDidFinishLoad:request];
    }
    else if ([data isKindOfClass:[NSString class]]) {
        NSString *url = data;
        [self.requestDic removeObjectForKey:url];
        SNDebugLog(@"requestDic number:%d", self.requestDic.count);
        [self preloadImage];
    }
}

/**
 * The request failed to load.
 */
- (void)request:(id)data didFailLoadWithError:(NSError*)error {
    if ([data isKindOfClass:[TTURLRequest class]]) {
        TTURLRequest *request = data;
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoListModelDidFailToLoadWithError:)]) {
            NSObject *obj = (NSObject *)self.delegate;
            [obj performSelectorOnMainThread:@selector(photoListModelDidFailToLoadWithError:)
                                            withObject:nil
                                         waitUntilDone:[NSThread isMainThread]];
        }
        SNDebugLog(@"SNPhotoListModel - didFailLoadWithError ,%@", [error localizedDescription]);
        [super request:request didFailLoadWithError:error];
    } else if ([data isKindOfClass:[NSString class]]) {
        NSString *url = data;
        [self.requestDic removeObjectForKey:url];
        [self preloadImage];
    }
}

/**
 * The request was canceled.
 */
- (void)requestDidCancelLoad:(id)data
{
    if ([data isKindOfClass:[TTURLRequest class]]) {
        TTURLRequest *request = data;
        [super requestDidCancelLoad:request];
    }    
    else if ([data isKindOfClass:[NSString class]]) {
        NSString *url = data;
        [self.requestDic removeObjectForKey:url];
    }
}



///////////////////////////////////////////////////////////////////////////////////////////////////
// TTPhotoSource

- (NSInteger)numberOfPhotos {
	return _photoList.gallerySubItems.count;
}

- (NSInteger)maxPhotoIndex {
	return _photoList.gallerySubItems.count - 1;
}

- (id<TTPhoto>)photoAtIndex:(NSInteger)photoIndex {
	if (photoIndex >= 0 && photoIndex < _photoList.gallerySubItems.count) {
		id photo = [_photoList.gallerySubItems objectAtIndex:photoIndex];
		if (photo == [NSNull null]) {
			return nil;
		} else {
			return photo;
		}
	} else {
		return nil;
	}
}

- (void)addPhotoListItem:(NSMutableArray *)photos addIndex:(int)index addObject:(PhotoItem *)photo
{
    SNPhotoListTableItem *item  = [[SNPhotoListTableItem alloc] init];
    item.index  = index;
    item.photo  = photo;

    [photos addObject:item];
    [item release];
}

- (void)createPhotoItems
{
    int cellIndex = 0;
    for (PhotoItem *photoItem in self.photoList.gallerySubItems) {
        SNPhotoListTableItem *item  = [[[SNPhotoListTableItem alloc] initWithItem:photoItem] autorelease];
        item.index = cellIndex++;
        
        [self.photoListItems addObject:item];
    }
}

#pragma mark - ad sdk
- (void)reloadSdkAdData {
    if ([[SNAdvertiseManager sharedManager] isSDKAdEnable]) {
        NSArray *adCtrlInfos = [[SNDBManager currentDataBase] adInfoGetAdInfosByType:SNAdInfoTypePhotoListNews
                                                                              dataId:self.newsId
                                                                          categoryId:self.termId];
        if (adCtrlInfos.count > 0) {
            SNAdControllInfo *adCtrlInfo = adCtrlInfos[0];
            for (SNAdInfo *adInfo in adCtrlInfo.adInfos) {
                if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdSlideshowTail] &&
                    !self.sdkAdLastPic) {
                    self.sdkAdLastPic = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                       adInfoParam:adInfo.filterInfo];
                    self.sdkAdLastPic.delegate = self;
                    [self.sdkAdLastPic refreshAdData:NO];
                }
                else if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdGroupPicRecommendTail] &&
                         !self.sdkAdLastRecommend) {
                    self.sdkAdLastRecommend = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                             adInfoParam:adInfo.filterInfo];
                    self.sdkAdLastRecommend.delegate = self;
                    [self.sdkAdLastRecommend refreshAdData:NO];
                }
                else if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdArticleRecommendTail] &&
                         !self.sdkAdNewsRecommend) {
                    self.sdkAdNewsRecommend = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                             adInfoParam:adInfo.filterInfo];
                    self.sdkAdNewsRecommend.delegate = self;
                    [self.sdkAdNewsRecommend refreshAdData:NO];
                }
                else if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdArticleAd] &&
                         !self.sdkAdTextPic) {
                    self.sdkAdTextPic = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                             adInfoParam:adInfo.filterInfo];
                    self.sdkAdTextPic.delegate = self;
                    [self.sdkAdTextPic refreshAdData:NO];
                }
            }
        }
    }
}

- (void)reloadSdkAdDataWithAdCtrlInfos:(NSArray *)adCtrlInfos {
    if ([[SNAdvertiseManager sharedManager] isSDKAdEnable]) {
        if (adCtrlInfos.count > 0) {
            SNAdControllInfo *adCtrlInfo = adCtrlInfos[0];
            for (SNAdInfo *adInfo in adCtrlInfo.adInfos) {
                if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdSlideshowTail] &&
                    !self.sdkAdLastPic) {
                    self.sdkAdLastPic = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                       adInfoParam:adInfo.filterInfo];
                    self.sdkAdLastPic.delegate = self;
                    [self.sdkAdLastPic refreshAdData:NO];
                }
                else if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdGroupPicRecommendTail] &&
                         !self.sdkAdLastRecommend) {
                    self.sdkAdLastRecommend = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                             adInfoParam:adInfo.filterInfo];
                    self.sdkAdLastRecommend.delegate = self;
                    [self.sdkAdLastRecommend refreshAdData:NO];
                }
                else if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdArticleRecommendTail] &&
                         !self.sdkAdNewsRecommend) {
                    self.sdkAdNewsRecommend = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                             adInfoParam:adInfo.filterInfo];
                    self.sdkAdNewsRecommend.delegate = self;
                    [self.sdkAdNewsRecommend refreshAdData:NO];
                }
                else if ([adInfo.adSpaceId isEqualToString:kSNAdSpaceIdArticleAd] &&
                         !self.sdkAdTextPic) {
                    self.sdkAdTextPic = [[SNAdvertiseManager sharedManager] generateNormalAdDataCarrierWithSpaceId:adInfo.adSpaceId
                                                                                                       adInfoParam:adInfo.filterInfo];
                    self.sdkAdTextPic.delegate = self;
                    [self.sdkAdTextPic refreshAdData:NO];
                }
            }
        }
    }
}

#pragma mark - SNAdDataCarrierDelegate

- (void)adViewDidAppearWithCarrier:(SNAdDataCarrier *)carrier {
    SNDebugLog(@"%@-%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (self.sdkAdTextPic == carrier ||
        self.sdkAdNewsRecommend == carrier) {
        // sdk广告曝光统计
        [carrier reportForDisplayTrack];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoListModelDidFinishLoadRecommendAds)]) {
            [self.delegate photoListModelDidFinishLoadRecommendAds];
        }
    }
}

- (void)adViewDidFailToLoadWithCarrier:(SNAdDataCarrier *)carrier {
    SNDebugLog(@"%@-%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    if (self.sdkAdLastPic == carrier) {
        self.sdkAdLastPic.delegate = nil;
        self.sdkAdLastPic = nil;
    }
    
    if (self.sdkAdLastRecommend == carrier) {
        self.sdkAdLastRecommend.delegate = nil;
        self.sdkAdLastRecommend = nil;
    }
    
    if (self.sdkAdNewsRecommend == carrier) {
        self.sdkAdNewsRecommend.delegate = nil;
        self.sdkAdNewsRecommend = nil;
    }
    
    if (self.sdkAdTextPic == carrier) {
        self.sdkAdTextPic.delegate = self;
        self.sdkAdTextPic = nil;
    }
}

@end
