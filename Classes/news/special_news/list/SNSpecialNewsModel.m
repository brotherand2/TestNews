//
//  SNSpecialNewsModel.m
//  sohunews
//
//  Created by handy wang on 7/4/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNSpecialNewsModel.h"
#import "SNURLJSONResponse.h"
#import "SNSpecialNews.h"
#import "SNDBManager.h"
#import "NSDictionaryExtend.h"

@interface SNSpecialNewsModel()

- (void)readCacheFromDatabase;

- (void)requestAsychrously:(BOOL)asynchrously;

- (void)saveSpecialNewsToDB:(id)rootData;

- (void)parseFocusData:(id)data;

- (NSDictionary *)parseGuideData:(id)data;

- (NSMutableArray *)parseNormalData:(id)data;

- (void)parseNewsNode:(id)newsData intoTmpArray:(NSMutableArray *)tmpArray withForm:(NSString *)form andGroupName:(NSString *)groupName;

- (NSMutableArray *)parsePageNode:(id)pageData withForm:(NSString *)form;

- (void)finishedToLoad:(SNURLRequest *)request;

@end


@implementation SNSpecialNewsModel

@synthesize termId=_termId, pubId=_pubId, termName=_termName, shareContent = _shareContent;
@synthesize headlineNews = _headlineNews;
@synthesize listNews = _listNews;
@synthesize newsGroupNames = _newsGroupNames;

#pragma mark - Lifecycle

- (id)initWithTermId:(NSString *)termIdParam {
    if (self = [super init]) {
        _termId = [termIdParam copy];
        _headlineNews = [[NSMutableArray alloc] init];
        _listNews = [[NSMutableArray alloc] init];
        _newsGroupNames = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    
     //(_termName);
    
    
    
    _tmpNewsGroupNames = nil;
    
    
    [_snRequest cancel];
     //(_snRequest);
    
     //(_shareContent);
     //(_pubId);
    
}

#pragma mark - Public methods implementation

#pragma mark - Override

- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    
    if (self.isLoading) {
        return;
    }
    
    if (TTURLRequestCachePolicyLocal == cachePolicy) {
        [self readCacheFromDatabase];
        if (self.listNews.count > 0) {
            [super didFinishLoad];
        }
    } else {
        [self readCacheFromDatabase];
        [self requestAsychrously:YES];
    }
    
}

// Called by SNTableViewDragRefreshDelegate
- (NSDate *)refreshedTime {
    
	NSDate *time = nil;
    
    NSString *timeKey = [NSString stringWithFormat:@"specialnews_termid_%@_refresh_time", _termId];
	id data = [[NSUserDefaults standardUserDefaults] objectForKey:timeKey];
	if (data && [data isKindOfClass:[NSDate class]]) {
		time = data;
	}
    
	return time;
}

// Called by SNTableViewDragRefreshDelegate
- (void)setRefreshedTime {
	NSString *timeKey = [NSString stringWithFormat:@"specialnews_termid_%@_refresh_time", _termId];
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:timeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Private methods implementation

- (void)readCacheFromDatabase {

    //headlines
    NSArray *_tmpHeadlineNews = [[SNDBManager currentDataBase] getSpecialHeadlineNewsListByTermId:_termId];
    _tmpHeadlineNews = [[_tmpHeadlineNews reverseObjectEnumerator] allObjects];
    @synchronized(_headlineNews) {
        [self.headlineNews removeAllObjects];
        [self.headlineNews addObjectsFromArray:_tmpHeadlineNews];
    }


    //group name array
    NSMutableArray *_iTmpNewsGroupNames = [[NSMutableArray alloc] init];
    
    if ((self.headlineNews && self.headlineNews.count > 0) || [self isThereANormalNewsNeedDisplayAsHeadlineNews]) {
        [_iTmpNewsGroupNames addObject:NSLocalizedString(@"specialnews_section_name_focus", @"")];
    }
    
    //list news
    NSMutableDictionary *_tmpGroupNameAndNewsListMap = [[NSMutableDictionary alloc] init];
    NSMutableArray *_tmpListNewsGroupNameArray = [[NSMutableArray alloc] init];
    NSArray *_tmpNormalNewsArrayFromDB = [[SNDBManager currentDataBase] getSpecialNormalNewsListByTermId:_termId];
    for (SNSpecialNews *_tmpNews in _tmpNormalNewsArrayFromDB) {
        NSMutableArray *_tmpOneGroupNewsArray = [_tmpGroupNameAndNewsListMap objectForKey:_tmpNews.groupName];
        
        if (!self.termName && _tmpNews.termName.length > 0) {
            self.termName = _tmpNews.termName;
        }
        
        if (!_tmpOneGroupNewsArray) {
            _tmpOneGroupNewsArray = [[NSMutableArray alloc] init];
            [_tmpOneGroupNewsArray addObject:_tmpNews];
            [_tmpGroupNameAndNewsListMap setObject:_tmpOneGroupNewsArray forKey:_tmpNews.groupName];
            
            [_tmpListNewsGroupNameArray addObject:_tmpNews.groupName];
            [_iTmpNewsGroupNames addObject:_tmpNews.groupName];
        } else {
            [_tmpOneGroupNewsArray addObject:_tmpNews];
        }
    }
    @synchronized(_newsGroupNames) {
        [self.newsGroupNames removeAllObjects];
        [self.newsGroupNames addObjectsFromArray:_iTmpNewsGroupNames];
    }

    
    //---list news
    NSMutableArray *_tmpListNewsArray = [[NSMutableArray alloc] init];
    for (NSString *_tmpGroupName in _tmpListNewsGroupNameArray) {
        NSMutableDictionary *_tmpOneGroupMap= [NSMutableDictionary dictionaryWithObject:[_tmpGroupNameAndNewsListMap objectForKey:_tmpGroupName] forKey:_tmpGroupName];
        if (_tmpOneGroupMap.count > 0) {
            [_tmpListNewsArray addObject:_tmpOneGroupMap];
        }
    }
    
    SNDebugLog(@"++++ %@", _tmpListNewsArray);
    
    @synchronized(_listNews) {
        [self.listNews removeAllObjects];
        [self.listNews addObjectsFromArray:_tmpListNewsArray];
    }
    
    //--- share content
    RollingNewsListItem *newItem = [[SNDBManager currentDataBase] getRollingNewsListItemByNewsId:self.termId];
    if (newItem) {
        self.shareContent = newItem.listPicsNumber;
    }
 
    _iTmpNewsGroupNames = nil;
    
    _tmpListNewsArray = nil;
    
    _tmpGroupNameAndNewsListMap = nil;
    
    _tmpListNewsGroupNameArray = nil;
}

- (BOOL)isThereANormalNewsNeedDisplayAsHeadlineNews {    
    NSArray *_tmpNormalNewsArrayFromDB = [[SNDBManager currentDataBase] getSpecialNormalNewsListByTermId:_termId];
    for (SNSpecialNews *_normalNews in _tmpNormalNewsArrayFromDB) {
        if ([@"1" isEqualToString:_normalNews.isFocusDisp]) {
            return YES;
        }
    }
    return NO;
}

- (void)requestAsychrously:(BOOL)asynchrously {
	NSString *url = [NSString stringWithFormat:kUrlSpecialNewsList, _termId];
	SNDebugLog(@"SNRollingNewsModel url %@", url);
	if (!_snRequest) {
		_snRequest = [SNURLRequest requestWithURL:url delegate:self];
		_snRequest.cachePolicy = TTURLRequestCachePolicyNoCache;
	} else {
		_snRequest.urlPath = url;
	}
    
    if (isRefreshManually) {
        _snRequest.isShowNoNetWorkMessage = YES;
    } else {
        _snRequest.isShowNoNetWorkMessage = NO;
    }
	
	_snRequest.response = [[SNURLJSONResponse alloc] init];
	if (asynchrously) {
		[_snRequest send];
	} else {
		[_snRequest sendSynchronously];
	}
}

- (void)finishedToLoad:(SNURLRequest *)request {
    [super requestDidFinishLoad:request];
}

#pragma mark - Private parse json data

- (void)saveSpecialNewsToDB:(id)rootData {
    @autoreleasepool {
        if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
            
            self.termId = [rootData objectForKey:kSNTermId];
            self.pubId = [rootData objectForKey:kSNPubId];
            self.termName = [rootData objectForKey:kSNTermName];
            
            id _focusData = [rootData objectForKey:kSNFocus];
            id _guideData = [rootData objectForKey:kSNGuide];
            id _normalData = [rootData objectForKey:kSNNormal];
            id _shareContentData = [rootData objectForKey:kSNShareContent];
            
            _tmpNewsGroupNames = [[NSMutableArray alloc] init];
            
            //focus
            [self parseFocusData:_focusData];
            
            
            NSMutableArray *_tmpListNews = [[NSMutableArray alloc] init];
            
            //guide头条
            NSDictionary *_guideNewsSectionDic = [self parseGuideData:_guideData];
            if (_guideNewsSectionDic) {
                [_tmpListNews addObject:_guideNewsSectionDic];
            }
            
            //normal
            NSArray *_normalNewsSections = [self parseNormalData:_normalData];
            if (_normalNewsSections.count > 0) {
                [_tmpListNews addObjectsFromArray:_normalNewsSections];
            }
            
            //各个新闻分组的名称集合
            if (_tmpNewsGroupNames.count > 0) {
                @synchronized(_newsGroupNames) {
                    [_newsGroupNames removeAllObjects];
                    [_newsGroupNames addObjectsFromArray:_tmpNewsGroupNames];
                }
            }
            _tmpNewsGroupNames = nil;
            
            //所有除焦点新闻外的新闻列表
            if (_tmpListNews.count > 0) {
                @synchronized(_listNews) {
                    [_listNews removeAllObjects];
                    [_listNews addObjectsFromArray:_tmpListNews];
                    
                    //注意：_listNews是一个二维数组
                    NSMutableArray *_allListNews = [[NSMutableArray alloc] init];
                    for (id _tmpDic in _tmpListNews) {
                        NSArray *_keys = [_tmpDic allKeys];
                        NSArray *_newsArrayInOneSection = [_tmpDic objectForKey:[_keys objectAtIndex:0]];
                        [_allListNews addObjectsFromArray:_newsArrayInOneSection];
                    }
                    
                    //从数据库中移除已删除的专题项
                    NSArray *currentList = [[SNDBManager currentDataBase] getSpecialNormalNewsListByTermId:self.termId];
                    NSArray *newList = _allListNews;
                    NSMutableArray *tobeRemovedList = [NSMutableArray arrayWithArray:currentList];
                    [tobeRemovedList removeObjectsInArray:newList];
                    for (SNSpecialNews *news in tobeRemovedList) {
                        [[SNDBManager currentDataBase] deleteSpecialNewsByTermId:news.termId newsId:news.newsId];
                    }
                    
                    [[SNDBManager currentDataBase] addMultiSpecialNewsList:_allListNews updateIfExist:YES];
                    _allListNews = nil;
                    
                    // 缓存sharecontent 保存在rolling news list表里面的  listpicNumber字段 add by jojo
                    if ([self.termId length] > 0 && _shareContentData && [_shareContentData isKindOfClass:[NSString class]]) {
                        self.shareContent = _shareContentData;
                        [[SNDBManager currentDataBase] updateRollingNewsListItemByNewsId:self.termId withValuePairs:
                         [NSDictionary dictionaryWithObject:_shareContentData forKey:TB_ROLLINGNEWSLIST_LISTPICSNUMBER]];
                    }
                }
            }
            _tmpListNews = nil;
            
            // 解析阅读圈 分享内容  by jojo
            NSDictionary *shareReadDicInfo = [rootData dictionaryValueForKey:@"shareRead" defalutValue:nil];
            if (shareReadDicInfo) {
                SNTimelineOriginContentObject *obj = [SNTimelineOriginContentObject timelineOriginContentObjFromDic:shareReadDicInfo];
                if (obj) [[SNDBManager currentDataBase] addOrReplaceOneTimelineOriginObj:obj withContentType:SNTimelineContentTypeSpecial contentId:self.termId];
            }
            
        }
        
        [super performSelectorOnMainThread:@selector(finishedToLoad:) withObject:nil waitUntilDone:NO];
    }
}

//焦点新闻
- (void)parseFocusData:(id)data {
    
    NSMutableArray *_tmpHeadlineNewsArray = [[NSMutableArray alloc] init];
    
    if ([data isKindOfClass:[NSArray class]]) {
        for (id _news in data) {
            [self parseNewsNode:_news intoTmpArray:_tmpHeadlineNewsArray 
                       withForm:kSNSpecialNewsForm_Headline andGroupName:NSLocalizedString(SN_String("specialnews_section_name_focus"), @"")];
        }
    } 
    else if ([data isKindOfClass:[NSDictionary class]]) {
        
        id _news = [data objectForKey:kSNNews];
        [self parseNewsNode:_news intoTmpArray:_tmpHeadlineNewsArray 
                   withForm:kSNSpecialNewsForm_Headline andGroupName:NSLocalizedString(SN_String("specialnews_section_name_focus"), @"")];
        
    }
    
    if (_tmpHeadlineNewsArray.count > 0) {
        @synchronized(_headlineNews) {
            if (_tmpHeadlineNewsArray && _tmpHeadlineNewsArray.count > 0) {
                //更新到数据库
                [_headlineNews removeAllObjects];
                [_headlineNews addObjectsFromArray:_tmpHeadlineNewsArray];
                
                SNDebugLog(SN_String("INFO: %@--%@, Begin saving headline news into DataBase."), NSStringFromClass(self.class), NSStringFromSelector(_cmd));
                
                //从数据库中移除已删除的专题项
                NSArray *currentList = [[SNDBManager currentDataBase] getSpecialHeadlineNewsListByTermId:self.termId];
                NSArray *newList = _tmpHeadlineNewsArray;
                NSMutableArray *tobeRemovedList = [NSMutableArray arrayWithArray:currentList];
                [tobeRemovedList removeObjectsInArray:newList];
                for (SNSpecialNews *news in tobeRemovedList) {
                    [[SNDBManager currentDataBase] deleteSpecialNewsByTermId:news.termId newsId:news.newsId];
                }
                
                [[SNDBManager currentDataBase] addMultiSpecialNewsList:_tmpHeadlineNewsArray updateIfExist:YES];
                SNDebugLog(SN_String("INFO: %@--%@, Finish saving headline news into DataBase."), NSStringFromClass(self.class), NSStringFromSelector(_cmd));
                
                [_tmpNewsGroupNames addObject:NSLocalizedString(SN_String("specialnews_section_name_focus"), @"")];
            }
        }
    }
    _tmpHeadlineNewsArray = nil;
}

//头条(导读)新闻
- (NSDictionary *)parseGuideData:(id)data {
    
    NSMutableDictionary *_tmpGuideNewsSectionDic = [[NSMutableDictionary alloc] init];
    NSMutableArray *_tmpGuideNewsSectionRows = [[NSMutableArray alloc] init];
    
    if ([data isKindOfClass:[NSArray class]]) {
        for (id _news in data) {
            [self parseNewsNode:_news intoTmpArray:_tmpGuideNewsSectionRows 
                       withForm:kSNSpecialNewsForm_Normal andGroupName:NSLocalizedString(SN_String("specialnews_section_name_guide"), @"")];
        }
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        
        id _news = [data objectForKey:kSNNews];
        [self parseNewsNode:_news intoTmpArray:_tmpGuideNewsSectionRows 
                   withForm:kSNSpecialNewsForm_Normal andGroupName:NSLocalizedString(SN_String("specialnews_section_name_guide"), @"")];
        
    }
    
    if (_tmpGuideNewsSectionRows.count > 0) {
        NSString *_groupName = NSLocalizedString(SN_String("specialnews_section_name_guide"), @"");
        
        [_tmpGuideNewsSectionDic setObject:_tmpGuideNewsSectionRows forKey:_groupName];
        
        [_tmpNewsGroupNames addObject:_groupName];
    }
    _tmpGuideNewsSectionRows = nil;
    
    if (_tmpGuideNewsSectionDic.count > 0) {
        return _tmpGuideNewsSectionDic;
    } else {
        _tmpGuideNewsSectionDic = nil;
        return nil;
    }
}

//其它普通新闻，其下有多个版面新闻(page),版面新闻下面有两种新闻结构：一种是只有一个新闻列表和多个栏目新闻，每个栏目新闻下面只有一个新闻列表；
- (NSMutableArray *)parseNormalData:(id)data {
    
    NSMutableArray *_pageAndColumnNews = [[NSMutableArray alloc] init];
    
    if ([data isKindOfClass:[NSArray class]]) {
        for (id _page in data) {
            NSMutableArray *_tmpArray = [self parsePageNode:_page withForm:kSNSpecialNewsForm_Normal];
            if (_tmpArray.count > 0) {
                [_pageAndColumnNews addObjectsFromArray:_tmpArray];
            }
        }
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        
        id _page = [data objectForKey:kSNPage];
        NSMutableArray *_tmpArray = [self parsePageNode:_page withForm:kSNSpecialNewsForm_Normal];
        if (_tmpArray.count > 0) {
            [_pageAndColumnNews addObjectsFromArray:_tmpArray];
        }
    }
    
    if (_pageAndColumnNews.count > 0) {
        return _pageAndColumnNews;
    } else {
        _pageAndColumnNews = nil;
        
        return nil;
    }
}

//解析版面
- (NSMutableArray *)parsePageNode:(id)pageData withForm:(NSString *)form {
    if ([pageData isKindOfClass:[NSDictionary class]]) {
        
        NSMutableArray *_tmpSections = [[NSMutableArray alloc] init];
        NSMutableDictionary *_tmpPageNewsSectionDic = [[NSMutableDictionary alloc] init];
        NSMutableArray *_tmpPageNewsSectionRows = [[NSMutableArray alloc] init];
        
        NSString *_pageName = [pageData objectForKey:kSNName];

        //版面下的普通新闻列表
        id _newsList = [pageData objectForKey:kSNNewsList];
        if ([_newsList isKindOfClass:[NSArray class]]) {
            
            for (id _news in _newsList) {
                [self parseNewsNode:_news intoTmpArray:_tmpPageNewsSectionRows withForm:form andGroupName:nil];
            }
            
        } else if ([_newsList isKindOfClass:[NSDictionary class]]) {
            
            id _news = [_newsList objectForKey:kSNNews];
            [self parseNewsNode:_news intoTmpArray:_tmpPageNewsSectionRows withForm:form andGroupName:nil];
            
        }
        if (_tmpPageNewsSectionRows.count > 0) {
            NSString *_groupName = (_pageName ? _pageName : NSLocalizedString(@"specialnews_section_name_default", @""));
            
            for (SNSpecialNews *_tmpNews in _tmpPageNewsSectionRows) {
                [_tmpNews setGroupName:_groupName];
            }
            [_tmpPageNewsSectionDic setObject:_tmpPageNewsSectionRows forKey:_groupName];
            
            [_tmpNewsGroupNames addObject:_groupName];
        }
        _tmpPageNewsSectionRows = nil;
        
        if (_tmpPageNewsSectionDic.count > 0) {
            [_tmpSections addObject:_tmpPageNewsSectionDic];
        }
         //(_tmpPageNewsSectionDic);
        
        
        //版面下的栏目新闻列表
        id _column = [pageData objectForKey:kSNColumn];
        if (_column) {
            NSArray *_tmpSubSections = [self parsePageNode:_column withForm:form];
            if (_tmpSubSections.count > 0) {
                [_tmpSections addObjectsFromArray:_tmpSubSections];
            }
        }

        if (_tmpSections.count > 0) {
            return _tmpSections;
        } else {
            _tmpSections = nil;
            
            return nil;
        }

    }
    //column栏目中有多个数据的情况
    else if ([pageData isKindOfClass:[NSArray class]]) {
        NSMutableArray *_array = [NSMutableArray array];
        for (id _data in pageData) {
            [_array addObjectsFromArray:[self parsePageNode:_data withForm:form]];
        }
        return _array;
    } else {
        return nil;
    }
}

- (void)parseNewsNode:(id)newsData intoTmpArray:(NSMutableArray *)tmpArray withForm:(NSString *)form andGroupName:(NSString *)groupName {
    if ([newsData isKindOfClass:[NSDictionary class]]) {
        NSString *_newsId       = [newsData objectForKey:kSNNewsId];
        NSString *_newsType     = [newsData objectForKey:kSNNewsType];
        NSString *_title        = [newsData objectForKey:kSNTitle];
        NSString *_abstract     = [newsData objectForKey:kSNAbstract];
        NSString *_isFocusDisp  = [newsData objectForKey:kSNIsFocusDisp];
        NSString *_link         = [newsData objectForKey:kSNLink2];
        NSString *_hasVideo     = [newsData objectForKey:@"isHasTV"];
        NSString *_updateTime   = [newsData objectForKey:TB_SPECIALNEWSLIST_UPDATETIME];
        
        SNSpecialNews *_tmpNews = [[SNSpecialNews alloc] init];
        _tmpNews.termId         = _termId;
        _tmpNews.termName       = self.termName;
        _tmpNews.newsId         = _newsId;
        _tmpNews.newsType       = _newsType;
        _tmpNews.title          = _title;
        _tmpNews.abstract       = _abstract;
        _tmpNews.isFocusDisp    = _isFocusDisp;
        _tmpNews.link           = _link;
        _tmpNews.form           = form;
        _tmpNews.groupName      = groupName;
        _tmpNews.hasVideo       = _hasVideo;
        _tmpNews.updateTime     = _updateTime;
        
        //微闻，直播，专题没有newsid，服务器会返回0，导致数据库索引错乱
        if(_tmpNews.newsId!=nil && [_tmpNews.newsId isEqualToString:@"0"])
            _tmpNews.newsId = _link;
        
        id _picObj = [newsData objectForKey:kSNPic];
        if ([kSNGroupPhotoNewsType isEqualToString:_tmpNews.newsType]) {
            if ([_picObj isKindOfClass:[NSArray class]]) {
                _tmpNews.picArray   = [newsData objectForKey:kSNPic];
            } else if ([_picObj isKindOfClass:[NSString class]]) {
                _tmpNews.pic        = _picObj;
            }
        } else {
            _tmpNews.pic            = _picObj;
        }
        
        //update isRead flag from database    
        BOOL _isRead = [[SNDBManager currentDataBase] checkSpecialNewsReadOrNotByTermId:_tmpNews.termId newsId:_tmpNews.newsId];
        _tmpNews.isRead = (_isRead ? @"1" : @"0");
        
        [tmpArray addObject:_tmpNews];
        
        _tmpNews = nil;
    }
}

#pragma mark - TTURLRequestDelegate methods implementation

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    [self performSelectorOnMainThread:@selector(finishedToLoad:) withObject:nil waitUntilDone:NO];
    
    [self setRefreshedTime];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
    
	SNURLJSONResponse *dataRes = (SNURLJSONResponse *)request.response;
	id rootData = dataRes.rootObject;
	
	SNDebugLog(@"INFO: %@--%@, Special news json data : %@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), rootData);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self saveSpecialNewsToDB:rootData];
    });
    
    [self setRefreshedTime];
}

- (void)setNewsAsRead:(NSString *)newsId
{
    for(SNSpecialNews *_specialNews in self.headlineNews)
    {
        if ([newsId isEqualToString:_specialNews.newsId])
        {
            _specialNews.isRead = @"1";
            [[SNDBManager currentDataBase] markSpecialNewsAsReadByTermId:_specialNews.termId newsId:newsId];
            SNDebugLog(@"news %@ isRead", newsId);
            return;
        }
    }
    
    //列表新闻(guidenews and normalnews)
    for (NSDictionary *_specialNewsDic in self.listNews)
    {
        NSString *_newsSectionName = [[_specialNewsDic allKeys] objectAtIndex:0];
        NSArray *_oneSectionNewsArray = [_specialNewsDic objectForKey:_newsSectionName];
        
        for (SNSpecialNews *_specialNews in _oneSectionNewsArray)
        {
            if ([newsId isEqualToString:_specialNews.newsId])
            {
                _specialNews.isRead = @"1";
                [[SNDBManager currentDataBase] markSpecialNewsAsReadByTermId:_specialNews.termId newsId:newsId];
                SNDebugLog(@"news %@ isRead", newsId);
                return;
            }
        }
    }
}
@end
