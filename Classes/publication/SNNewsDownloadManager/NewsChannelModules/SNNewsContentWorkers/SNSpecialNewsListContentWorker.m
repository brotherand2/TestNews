//
//  SNSpecialNewsListContentWorker.m
//  sohunews
//
//  Created by handy wang on 1/11/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNSpecialNewsListContentWorker.h"
#import "SNNewsType.h"
#import "SNSpecialArticleNewsContentWorker.h"
#import "SNTermGroupPhotoNewsContentWorker.h"
#import "NSJSONSerialization+String.h"

@interface SNSpecialNewsListContentWorker() {
    SNNewsContentWorker *_runningSpecialNewsContentWorker;
}
@property(nonatomic, strong)SNNewsContentWorker *runningSpecialNewsContentWorker;
@end

@implementation SNSpecialNewsListContentWorker
@synthesize runningSpecialNewsContentWorker = _runningSpecialNewsContentWorker;

#pragma mark - Lifecycle

- (void)dealloc  {
     //(_specialNewsArray);
     //(_runningSpecialNewsContentWorker);
}

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
    
    SNDebugLog(@"===INFO: Main thread:%d, begin fetching specialnews list content ...", [NSThread isMainThread]);
    
    for (SNNewsContentWorkerNews *_news in _newsArray) {
        if (_isCanceled) {
            break;
        }
        
        //获取SpecialNewsList数据并存入本地数据库以及下载SpecialNews列表的图片；
        _specialNewsArray = [[self fetchSpecialNewsListWithWorkerNews:_news] mutableCopy];
        
        //下载每个专题新闻的正文页内容
        _runningWorkerNews = _news;
        [self scheduleANewsContentWorkerToWorkInThread];
        
         //(_runningWorkerNews);
         //(_specialNewsArray);
    }
    
    //进行下一个worker
    if ([_myDelegate respondsToSelector:@selector(didFinishWorking:)]) {
        [_myDelegate didFinishWorking:self];
    }
    _myDelegate = nil;
}

- (void)cancel {
    [super cancel];
    
    if (!!_runningSpecialNewsContentWorker) {
        [_runningSpecialNewsContentWorker cancel];
    }
}

#pragma mark - Fetch专题新闻列表

- (NSArray *)fetchSpecialNewsListWithWorkerNews:(SNNewsContentWorkerNews *)workerNews {
    SNDebugLog(@"===INFO: Main thread:%d, Begin fetching specialnews %@ json data...", [NSThread isMainThread], workerNews.newsTitle);
    
    [SNASIRequest setShouldUpdateNetworkActivityIndicator:NO];
    //由于历史原因，对于即时新闻列表中的专题新闻来说，newsID就是去获取专题列表时需要的termID;
    NSString *_urlString = [NSString stringWithFormat:kUrlSpecialNewsList, workerNews.newsID];
    SNASIRequest *_request = [SNASIRequest requestWithURL:[NSURL URLWithString:_urlString]];
    [_request setValidatesSecureCertificate:NO];
    [_request setCachePolicy:ASIDoNotReadFromCacheCachePolicy|ASIDoNotWriteToCacheCachePolicy];
    _request.defaultResponseEncoding = NSUTF8StringEncoding;
    [_request setValidatesSecureCertificate:NO];
    [_request startSynchronous];
    
    NSString *jsonString = [_request responseString];
    if (!jsonString || [@"" isEqualToString:jsonString]) {
        SNDebugLog(@"===INFO: Main thread:%d, Got empty specialnews list %@ jsonstring from %@.", [NSThread isMainThread], workerNews.newsTitle, _urlString);
        return nil;
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, Got specialnews jsonstring:%@, [%@], from %@", [NSThread isMainThread], jsonString, workerNews.newsTitle, _urlString);
    }
    
    id rootData = [NSJSONSerialization JSONObjectWithString:jsonString
                                                    options:NSJSONReadingMutableLeaves
                                                      error:NULL];
    if (!rootData) {
        SNDebugLog(@"===INFO: Main thread:%d, Got empty special list %@ rootData, from %@", [NSThread isMainThread], workerNews.newsTitle, _urlString);
        return nil;
    }
    
    //保存SpecialNews列表数据到数据库
    NSArray *_allNews = [self saveSpecialNewsToDB:rootData termID:workerNews.newsID];
    
    //下载SpecialNews列表中的所有图片
    if (!!_allNews && (_allNews.count>0)) {
        NSMutableArray *_imgeURLArray = [NSMutableArray array];
        for (SNSpecialNews *_specialNews in _allNews) {
            if (!!(_specialNews.pic) && ![@"" isEqualToString:_specialNews.pic]) {
                [_imgeURLArray addObject:_specialNews.pic];
            }
            if (!!(_specialNews.picArray) && (_specialNews.picArray.count > 0)) {
                for (NSString *_picURLString in _specialNews.picArray) {
                    [_imgeURLArray addObject:_picURLString];
                }
            }
        }
        if (!!_imgeURLArray && (_imgeURLArray.count > 0)) {
            SNDebugLog(@"===INFO: Main thread:%d, Begin fetching SpecialNewsList %@ images:%@", [NSThread isMainThread], workerNews.newsTitle, _imgeURLArray);
            [[SNNewsImageFetcher sharedInstance] setDelegate:self];
            [[SNNewsImageFetcher sharedInstance] fetchImagesInThread:_imgeURLArray forNewsContent:workerNews];
        } else {
            SNDebugLog(@"===INFO: Main thread:%d, Ignore fetching SpecialNewsList %@ images array is empty.", [NSThread isMainThread], workerNews.newsTitle);
        }
         //(_imgeURLArray);
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, Ignore fetching SpecialNewsList %@ images and contens, because SpecialNewsList is empty.",
                   [NSThread isMainThread], workerNews.newsTitle);
    }
    
    return _allNews;
}

- (NSArray *)saveSpecialNewsToDB:(id)rootData termID:(NSString *)termID {
    if (rootData && [rootData isKindOfClass:[NSDictionary class]]) {
        
        NSMutableArray *_acutalAllNewsArray = [NSMutableArray array];
        
        id _focusData = [rootData objectForKey:kSNFocus];
        id _guideData = [rootData objectForKey:kSNGuide];
        id _normalData = [rootData objectForKey:kSNNormal];
        
        //focus焦点新闻
        NSArray *_focusNewsArray = [self parseFocusData:_focusData termID:termID];
        if (!!_focusNewsArray && (_focusNewsArray.count > 0)) {
            [_acutalAllNewsArray addObjectsFromArray:_focusNewsArray];
        }
        
        NSMutableArray *_tmpListNews = [[NSMutableArray alloc] init];
        
        //guide头条
        NSDictionary *_guideNewsSectionDic = [self parseGuideData:_guideData termID:termID];
        if (_guideNewsSectionDic) {
            [_tmpListNews addObject:_guideNewsSectionDic];
        }
        
        //normal
        NSArray *_normalNewsSections = [self parseNormalData:_normalData termID:termID];
        if (_normalNewsSections.count > 0) {
            [_tmpListNews addObjectsFromArray:_normalNewsSections];
        }
        
        //所有除焦点新闻外的新闻列表
        if (_tmpListNews.count > 0) {
            NSMutableArray *_allListNews = [[NSMutableArray alloc] init];
            for (id _tmpDic in _tmpListNews) {
                NSArray *_keys = [_tmpDic allKeys];
                NSArray *_newsArrayInOneSection = [_tmpDic objectForKey:[_keys objectAtIndex:0]];
                [_allListNews addObjectsFromArray:_newsArrayInOneSection];
            }
            [[SNDBManager currentDataBase] addMultiSpecialNewsList:_allListNews updateIfExist:NO];

            if (!!_allListNews && (_allListNews.count > 0)) {
                [_acutalAllNewsArray addObjectsFromArray:_allListNews];
            }
            
            _allListNews = nil;
        }
        _tmpListNews = nil;
        
        return _acutalAllNewsArray;
    }
    
    return nil;
}

//焦点新闻
- (NSArray *)parseFocusData:(id)data termID:(NSString *)termID {
    NSMutableArray *_tmpHeadlineNewsArray = [[NSMutableArray alloc] init];
    
    if ([data isKindOfClass:[NSArray class]]) {
        for (id _news in data) {
            [self parseNewsNode:_news intoTmpArray:_tmpHeadlineNewsArray
                       withForm:kSNSpecialNewsForm_Headline
                   andGroupName:NSLocalizedString(SN_String("specialnews_section_name_focus"), @"")
                         termID:termID];
        }
    }
    else if ([data isKindOfClass:[NSDictionary class]]) {
        
        id _news = [data objectForKey:kSNNews];
        [self parseNewsNode:_news intoTmpArray:_tmpHeadlineNewsArray
                   withForm:kSNSpecialNewsForm_Headline
               andGroupName:NSLocalizedString(SN_String("specialnews_section_name_focus"), @"")
                     termID:termID];
        
    }
    
    if (_tmpHeadlineNewsArray && _tmpHeadlineNewsArray.count > 0) {
        //更新到数据库
        SNDebugLog(SN_String("INFO: %@--%@, Begin saving headline news into DataBase."), NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        [[SNDBManager currentDataBase] clearSpecialHeadlineNewsByTermId:termID];
        [[SNDBManager currentDataBase] addMultiSpecialNewsList:_tmpHeadlineNewsArray updateIfExist:YES];
        SNDebugLog(SN_String("INFO: %@--%@, Finish saving headline news into DataBase."), NSStringFromClass(self.class), NSStringFromSelector(_cmd));
        return _tmpHeadlineNewsArray;
    } else {
        _tmpHeadlineNewsArray = nil;
        return nil;
    }
}

//头条(导读)新闻
- (NSDictionary *)parseGuideData:(id)data termID:(NSString *)termID {
    
    NSMutableDictionary *_tmpGuideNewsSectionDic = [[NSMutableDictionary alloc] init];
    NSMutableArray *_tmpGuideNewsSectionRows = [[NSMutableArray alloc] init];
    
    if ([data isKindOfClass:[NSArray class]]) {
        for (id _news in data) {
            [self parseNewsNode:_news intoTmpArray:_tmpGuideNewsSectionRows
                       withForm:kSNSpecialNewsForm_Normal
                   andGroupName:NSLocalizedString(SN_String("specialnews_section_name_guide"), @"")
                         termID:termID];
        }
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        
        id _news = [data objectForKey:kSNNews];
        [self parseNewsNode:_news intoTmpArray:_tmpGuideNewsSectionRows
                   withForm:kSNSpecialNewsForm_Normal
               andGroupName:NSLocalizedString(SN_String("specialnews_section_name_guide"), @"")
                     termID:termID];
        
    }
    
    if (_tmpGuideNewsSectionRows.count > 0) {
        NSString *_groupName = NSLocalizedString(SN_String("specialnews_section_name_guide"), @"");
        [_tmpGuideNewsSectionDic setObject:_tmpGuideNewsSectionRows forKey:_groupName];
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
- (NSMutableArray *)parseNormalData:(id)data termID:(NSString *)termID {
    
    NSMutableArray *_pageAndColumnNews = [[NSMutableArray alloc] init];
    
    if ([data isKindOfClass:[NSArray class]]) {
        for (id _page in data) {
            NSMutableArray *_tmpArray = [self parsePageNode:_page withForm:kSNSpecialNewsForm_Normal termID:termID];
            if (_tmpArray.count > 0) {
                [_pageAndColumnNews addObjectsFromArray:_tmpArray];
            }
        }
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        
        id _page = [data objectForKey:kSNPage];
        NSMutableArray *_tmpArray = [self parsePageNode:_page withForm:kSNSpecialNewsForm_Normal termID:termID];
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
- (NSMutableArray *)parsePageNode:(id)pageData withForm:(NSString *)form termID:(NSString *)termID {
    if ([pageData isKindOfClass:[NSDictionary class]]) {
        
        NSMutableArray *_tmpSections = [[NSMutableArray alloc] init];
        NSMutableDictionary *_tmpPageNewsSectionDic = [[NSMutableDictionary alloc] init];
        NSMutableArray *_tmpPageNewsSectionRows = [[NSMutableArray alloc] init];
        
        NSString *_pageName = [pageData objectForKey:kSNName];
        
        //版面下的普通新闻列表
        id _newsList = [pageData objectForKey:kSNNewsList];
        if ([_newsList isKindOfClass:[NSArray class]]) {
            
            for (id _news in _newsList) {
                [self parseNewsNode:_news intoTmpArray:_tmpPageNewsSectionRows withForm:form andGroupName:nil termID:termID];
            }
            
        } else if ([_newsList isKindOfClass:[NSDictionary class]]) {
            
            id _news = [_newsList objectForKey:kSNNews];
            [self parseNewsNode:_news intoTmpArray:_tmpPageNewsSectionRows withForm:form andGroupName:nil termID:termID];
            
        }
        if (_tmpPageNewsSectionRows.count > 0) {
            NSString *_groupName = (_pageName ? _pageName : NSLocalizedString(SN_String("specialnews_section_name_default"), @""));
            
            for (SNSpecialNews *_tmpNews in _tmpPageNewsSectionRows) {
                [_tmpNews setGroupName:_groupName];
            }
            [_tmpPageNewsSectionDic setObject:_tmpPageNewsSectionRows forKey:_groupName];
        }
        _tmpPageNewsSectionRows = nil;
        
        if (_tmpPageNewsSectionDic.count > 0) {
            [_tmpSections addObject:_tmpPageNewsSectionDic];
        }
         //(_tmpPageNewsSectionDic);
        
        
        //版面下的栏目新闻列表
        id _column = [pageData objectForKey:kSNColumn];
        if (_column) {
            NSArray *_tmpSubSections = [self parsePageNode:_column withForm:form termID:termID];
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
            [_array addObjectsFromArray:[self parsePageNode:_data withForm:form termID:termID]];
        }
        return _array;
    } else {
        return nil;
    }
}

- (void)parseNewsNode:(id)newsData intoTmpArray:(NSMutableArray *)tmpArray withForm:(NSString *)form andGroupName:(NSString *)groupName termID:(NSString *)termID {
    if ([newsData isKindOfClass:[NSDictionary class]]) {
        NSString *_newsId       = [newsData objectForKey:kSNNewsId];
        NSString *_newsType     = [newsData objectForKey:kSNNewsType];
        NSString *_title        = [newsData objectForKey:kSNTitle];
        NSString *_abstract     = [newsData objectForKey:kSNAbstract];
        NSString *_isFocusDisp  = [newsData objectForKey:kSNIsFocusDisp];
        NSString *_link         = [newsData objectForKey:kSNLink];
        NSString *_hasVideo     = [newsData objectForKey:@"isHasTV"];
        
        SNSpecialNews *_tmpNews = [[SNSpecialNews alloc] init];
        _tmpNews.termId         = termID;
        _tmpNews.newsId         = _newsId;
        _tmpNews.newsType       = _newsType;
        _tmpNews.title          = _title;
        _tmpNews.abstract       = _abstract;
        _tmpNews.isFocusDisp    = _isFocusDisp;
        _tmpNews.link           = _link;
        _tmpNews.form           = form;
        _tmpNews.groupName      = groupName;
        _tmpNews.hasVideo = _hasVideo;
        
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


#pragma mark - SNNewsImageFetcherDelegate

- (void)finishedToFetchImagesInThreadForNewsContent:(id)newsContent {
    if ([newsContent isKindOfClass:[SNNewsContentWorkerNews class]]) {
        SNNewsContentWorkerNews *_workerNews = (SNNewsContentWorkerNews *)newsContent;
        SNDebugLog(@"===INFO: Main thread:%d, finish downloading images for worker news %@ .", [NSThread isMainThread], _workerNews.newsTitle);
    } else {
        SNDebugLog(@"===INFO: Main thread:%d, finish downloading images for GroupPhoto.", [NSThread isMainThread]);
    }
}

#pragma mark - Fetch 专题新闻正文页和图片

- (NSArray *)waitingItems {
    if (!_specialNewsArray || (_specialNewsArray.count <= 0)) {
        SNDebugLog(@"===INFO: There is no undownloaded rolling news items.");
        return nil;
    }
    
    NSPredicate *_predicate = [NSPredicate predicateWithFormat:@"isDownloadFinished==0"];//未下载的新闻
    return [_specialNewsArray filteredArrayUsingPredicate:_predicate];
}

- (void)scheduleANewsContentWorkerToWorkInThread {
    if (_isCanceled) {
        _isCanceled = NO;
        return;
    }
    
    NSArray *_waitingItems = [self waitingItems];
    if (!_waitingItems || _waitingItems.count <= 0) {
         //(_runningSpecialNewsContentWorker);
        SNDebugLog(@"===INFO: Main thread:%d, ExitPoint, finish downloading for 专题(SpecialNews) %@.", [NSThread isMainThread], _runningWorkerNews.newsTitle);
        return;
    }
    
    SNSpecialNews *_specialNews = [_waitingItems objectAtIndex:0];
    SNDebugLog(@"===INFO: Creating a running content worker for news %@ of special news %@...", _specialNews.title, _runningWorkerNews.newsTitle);
    if (!!(_specialNews.newsId) && ![@"" isEqualToString:_specialNews.newsId]
        && !!(_specialNews.newsType) && ![@"" isEqualToString:_specialNews.newsType]
        && !!(_specialNews.title) && ![@"" isEqualToString:_specialNews.title]) {
        
        int _type = [_specialNews.newsType intValue];
        switch (_type) {
            case SNNewsType_FocusNews: {//集点新闻，暂不支持
                break;
            }
            case SNNewsType_PhotoAndTextNews: {//图文新闻
                [self createOrUpdateArticleNewsWorker:_specialNews];
                break;
            }
            case SNNewsType_GroupPhotoNews: {//组图新闻
                [self createOrUpdateGroupPhotoNewsWorker:_specialNews];
                break;
            }
            case SNNewsType_TextNews: {//文本新闻
                [self createOrUpdateArticleNewsWorker:_specialNews];
                break;
            }
            case SNNewsType_TitleNews: {//标题新闻
                [self createOrUpdateArticleNewsWorker:_specialNews];
                break;
            }
            case SNNewsType_OutterLinkNews: {//外链新闻，暂不支持
                break;
            }
            case SNNewsType_LiveNews: {//直播
                break;
            }
            case SNNewsType_SpecialNews: {//专题新闻，专题套专题暂不支持
                break;
            }
            case SNNewsType_NewspaperNews: {//报纸，暂不支持
                break;
            }
            case SNNewsType_VoteNews: {//含有投票的新闻(实际上就是有article的新闻)
                [self createOrUpdateArticleNewsWorker:_specialNews];
                break;
            }
            default:
                break;
        }
        
        _specialNews.isDownloadFinished = YES;
    }
    
    if (!!_runningSpecialNewsContentWorker) {
        SNDebugLog(@"===INFO: Start a running content worker for news %@ of special news %@...", _specialNews.title, _runningWorkerNews.newsTitle);
        [_runningSpecialNewsContentWorker startInThread];
    } else {
        SNDebugLog(@"===INFO: Give up start content worker for news %@ of special %@ with nil _runningSpecialNewsContentWorker.", _specialNews.title, _runningWorkerNews.newsTitle);
    }
}

- (void)createOrUpdateArticleNewsWorker:(SNSpecialNews *)specialNews {
    self.runningSpecialNewsContentWorker = [[SNSpecialArticleNewsContentWorker alloc] initWithDelegate:self];
    [_runningSpecialNewsContentWorker appenNewsID:specialNews.newsId termID:specialNews.termId newsTitle:specialNews.title newsType:specialNews.newsType];
}

- (void)createOrUpdateGroupPhotoNewsWorker:(SNSpecialNews *)specialNews {
    self.runningSpecialNewsContentWorker = [[SNTermGroupPhotoNewsContentWorker alloc] initWithDelegate:self];
    [_runningSpecialNewsContentWorker appenNewsID:specialNews.newsId termID:specialNews.termId newsTitle:specialNews.title newsType:specialNews.newsType];
}

#pragma mark - SNNewsContentWorkerDelegate

- (void)didFinishWorking:(SNNewsContentWorker *)worker {
    [self scheduleANewsContentWorkerToWorkInThread];
}

@end
