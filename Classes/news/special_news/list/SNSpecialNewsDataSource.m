//
//  SNSpecialNewsDataSource.m
//  sohunews
//
//  Created by handy wang on 7/4/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//


#import "SNSpecialNewsDataSource.h"
#import "SNSpecialNews.h"
#import "SNSpecialHeadlineNewsTableItem.h"
#import "SNSpecialNewsTableItem.h"
#import "SNSpecialNewsTableCell.h"
#import "SNSpecialHeadlineNewsTableCell.h"
#import "SNSpecialTextNewsTableCell.h"
#import "SNSpecialGroupPhotoNewsTableCell.h"
#import "SNSpecialAbstractNewsTableCell.h"
#import "SNCommonNewsDatasource.h"

@interface SNSpecialNewsDataSource()

- (void)createHeadlineItemInto:(NSMutableArray *)allItems allIds:(NSMutableArray*)allIds
              withPhotoNewsIds:(NSMutableArray *)photoNewsIds excludePhotoNewsIds:(NSMutableArray *)excludePhotoNewsIds;

- (void)addHeadlineItemInto:(NSMutableArray *)allItems withNews:(SNSpecialNews *)news allIds:(NSMutableArray*)allIds
               photoNewsIds:(NSMutableArray *)photoNewsIds excludePhotoNewsIds:(NSMutableArray *)excludePhotoNewsIds;

- (void)createSpecialNewsTableItemInto:(NSMutableArray *)oneSectionItems withSpecialNews:(SNSpecialNews *)specialNews allIds:(NSMutableArray*)allIds photoNewsIds:(NSMutableArray *)photoNewsIds excludePhotoNewsIds:(NSMutableArray *)excludePhotoNewsIds;

@end


@implementation SNSpecialNewsDataSource
@synthesize dataSource = _dataSource;

#pragma mark - Lifecycle methods

- (id)initWithTermId:(NSString *)termIdParam {
	if (self = [super init]) {
		_snModel = [[SNSpecialNewsModel alloc] initWithTermId:termIdParam];
	}
	return self;
}

- (id<TTModel>)model {
	return _snModel;
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
    if ((_snModel.headlineNews.count + _snModel.listNews.count) <= 0) {
        return;
    }

    NSMutableArray *_tmpSelfItems = [[NSMutableArray alloc] init];
    
    NSMutableArray *_excludePhotoNewsIds = [[NSMutableArray alloc] init];
    NSMutableArray *_photoNewsIds = [[NSMutableArray alloc] init];
    NSMutableArray *_allIds = [[NSMutableArray alloc] init];
    
    self.dataSource = nil;
    _dataSource = [[SNCommonNewsDatasource alloc] init];
    _dataSource.snModel = _snModel;
    _dataSource.excludePhotoNewsIds = _excludePhotoNewsIds;
    _dataSource.photoNewsIds = _photoNewsIds;
    _dataSource.allNewsIds = _allIds;
    
    //焦点新闻
    [self createHeadlineItemInto:_tmpSelfItems allIds:_allIds withPhotoNewsIds:_photoNewsIds excludePhotoNewsIds:_excludePhotoNewsIds];
    
    
//    //打印headlines个数的日志
//    if ([SNPreference sharedInstance].debugModeEnabled) {
//        if (_tmpSelfItems.count > 0) {
//            NSArray *_sectionOneAllNews = [_tmpSelfItems objectAtIndex:0];
//            if (_sectionOneAllNews.count > 0) {
//                id _obj = [_sectionOneAllNews objectAtIndex:0];
//                if (_obj && [_obj isKindOfClass:[SNSpecialHeadlineNewsTableItem class]]) {
//                    //SNSpecialHeadlineNewsTableItem  *_headlineNewsItem = (SNSpecialHeadlineNewsTableItem *)_obj;
//                    SNDebugLog(SN_String("INFO: %@--%@, after FocusNews headline news count is %d"),
//                               NSStringFromClass(self.class), NSStringFromSelector(_cmd), [[_headlineNewsItem headlines] count]);
//                }
//            }
//        }
//    }
    
    //列表新闻(guidenews and normalnews)
    for (NSDictionary *_specialNewsDic in _snModel.listNews) {
        
        NSMutableArray *_oneSectionItems = [[NSMutableArray alloc] init];
        
        SNDebugLog(SN_String("_specialNewsDic : %@"), _specialNewsDic);
        NSString *_newsSectionName = [[_specialNewsDic allKeys] objectAtIndex:0];
        NSArray *_oneSectionNewsArray = [_specialNewsDic objectForKey:_newsSectionName];
        
        for (SNSpecialNews *_specialNews in _oneSectionNewsArray) {
            //有图模式
            if ([kSNIsFocusDisp_NO isEqualToString:[_specialNews isFocusDisp]]) {
                [self createSpecialNewsTableItemInto:_oneSectionItems withSpecialNews:_specialNews  allIds:_allIds
                                        photoNewsIds:_photoNewsIds excludePhotoNewsIds:_excludePhotoNewsIds];
            }
            else {
                [self addHeadlineItemInto:_tmpSelfItems withNews:_specialNews allIds:_allIds photoNewsIds:_photoNewsIds excludePhotoNewsIds:_excludePhotoNewsIds];
            }
        }
        
        if (_oneSectionItems.count > 0) {
            [_tmpSelfItems addObject:_oneSectionItems];
        }
        else {
            //有图模式下：如果某一个区段有新闻数据，但是全是isFocusDisp为YES，那么应该把section名称从_snModel.newsGroupNames中删除
            @synchronized(_snModel.newsGroupNames) {
                NSInteger _index = [_snModel.listNews indexOfObject:_specialNewsDic];
                if (_index != NSNotFound) {
                    [_snModel.newsGroupNames removeObjectAtIndex:_index];
                }
            }
        }
        
        _oneSectionItems = nil;
    }
    
    //打印headlines个数的日志
    if ([SNPreference sharedInstance].debugModeEnabled) {
        if (_tmpSelfItems.count > 0) {
            NSArray *_sectionOneAllNews = [_tmpSelfItems objectAtIndex:0];
            if (_sectionOneAllNews.count > 0) {
                id _obj = [_sectionOneAllNews objectAtIndex:0];
                if (_obj && [_obj isKindOfClass:[SNSpecialHeadlineNewsTableItem class]]) {
                    //SNSpecialHeadlineNewsTableItem  *_headlineNewsItem = (SNSpecialHeadlineNewsTableItem *)_obj;
                    //SNDebugLog(SN_String("INFO: %@--%@, after NormalNews headline news count is %d"), NSStringFromClass(self.class), NSStringFromSelector(_cmd), [[_headlineNewsItem headlines] count]);
                }
            }
        }
    }

    SNDebugLog(@"%@--%@, all sections count is %d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _tmpSelfItems.count);
    
    if (_tmpSelfItems.count > 0) {
        @synchronized(self.items) {
            self.items = [NSMutableArray array];
            [self.items addObjectsFromArray:_tmpSelfItems];
        }
    }
    
    if (_snModel.newsGroupNames.count > 0) {
        @synchronized(self.sections) {
            self.sections = [NSMutableArray array];
            [self.sections addObjectsFromArray:_snModel.newsGroupNames];
        }
    }
    
    _tmpSelfItems = nil;
    
    _excludePhotoNewsIds = nil;
    
    _photoNewsIds = nil;
    
    _allIds = nil;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        tableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0.f, 0.f, 0.f);
        tableView.contentOffset = CGPointMake(0.f, -kHeaderHeightWithoutBottom);
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    NSInteger _count = self.items.count;
    SNDebugLog(@"%@--%@, Section count %d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), _count);
    return _count;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger _count = [(NSArray *)[self.items objectAtIndex:section] count];
    SNDebugLog(@"%@--%@, Section %d, row count is %d", NSStringFromClass(self.class), NSStringFromSelector(_cmd), section, _count);
    return _count;
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
    
    if ([object isKindOfClass:[SNSpecialHeadlineNewsTableItem class]]) {
        return [SNSpecialHeadlineNewsTableCell class];
    }
    else if ([object isKindOfClass:[SNSpecialNewsTableItem class]]) {
        SNSpecialNewsTableItem *_tmpItem = (SNSpecialNewsTableItem *)object;
        
        if ([kSNTextNewsType isEqualToString:_tmpItem.news.newsType]) {
            return [SNSpecialAbstractNewsTableCell class];
        } else if ([kSNPhotoAndTextNewsType isEqualToString:_tmpItem.news.newsType] ||
                   [kSNVoteNewsType isEqualToString:_tmpItem.news.newsType]) {
            if (!_tmpItem.news.pic || [@"" isEqualToString:_tmpItem.news.pic]) {
                return [SNSpecialTextNewsTableCell class];
            } else {
                return [SNSpecialNewsTableCell class];
            }
        } else if ([kSNGroupPhotoNewsType isEqualToString:_tmpItem.news.newsType]) {
            return [SNSpecialGroupPhotoNewsTableCell class];
        } else {
            return [SNSpecialTextNewsTableCell class];
        }
    }

    return [super tableView:tableView cellClassForObject:object];
}

- (void)dealloc {
	 //(_snModel);
     //(_dataSource);
	
}

#pragma mark - Public methods implementation

#pragma mark - Override

- (UIImage*)imageForEmpty {
	return [UIImage imageNamed:@"tb_empty_bg.png"];
}

- (NSString*)titleForEmpty {
	return NSLocalizedString(@"NoRollingNews", @"");
}

- (NSString*)subtitleForEmpty {
	return NSLocalizedString(@"RefreshRollingNews", @"");
}

- (UIImage*)imageForError:(NSError*)error {
    return [UIImage imageNamed:@"tb_error_bg"];
}

- (NSString*)titleForError:(NSError*)error {
    //	return NSLocalizedString(@"NoRollingNews", @"");
    return nil;
}

- (NSString*)subtitleForError:(NSError*)error {
    //	return NSLocalizedString(@"RefreshRollingNews", @"");
    return nil;
}

#pragma mark - Private methods implementation

- (void)createHeadlineItemInto:(NSMutableArray *)allItems allIds:(NSMutableArray*)allIds
              withPhotoNewsIds:(NSMutableArray *)photoNewsIds excludePhotoNewsIds:(NSMutableArray *)excludePhotoNewsIds {
    
    if (_snModel.headlineNews.count > 0) {
        SNSpecialHeadlineNewsTableItem *_specialHeadlineNewsTableItem = [[SNSpecialHeadlineNewsTableItem alloc] init];
        _specialHeadlineNewsTableItem.snModel = _snModel;
        _specialHeadlineNewsTableItem.termId = _snModel.termId;
        _specialHeadlineNewsTableItem.dataSource = _dataSource;
        
        //直接赋值会有bug。如果直接赋值，在方法addHeadlineItemInto里添加isFocusDisp的News时到_specialHeadlineNewsTableItem.headlines时操作的也是_snModel.headlineNews，
        //这种情况会发生在进入新闻页后返回到专题列表页重load数据时，会再次运行tableViewDidLoadModel方法而_snModel.headlineNews的内容没变，
        //从而会再次创建_specialHeadlineNewsTableItem时_snModel.headlineNews已经有了上一次的数据，而导致_specialHeadlineNewsTableItem.headlines里的数据成倍增加；
        NSMutableArray *_tmpHeadlineNewsArray = [_snModel.headlineNews mutableCopy];
        _specialHeadlineNewsTableItem.headlines = _tmpHeadlineNewsArray;
         //(_tmpHeadlineNewsArray);
        
        [allItems addObject:[NSArray arrayWithObject:_specialHeadlineNewsTableItem]];
        
        for (SNSpecialNews *_news in _snModel.headlineNews) {
            
            if ([kSNGroupPhotoNewsType isEqualToString:_news.newsType]) {
                _news.type = NEWS_ITEM_TYPE_GROUP_PHOTOS;
                [photoNewsIds addObject:_news.newsId];
                [allIds addObject:_news];
            } else {
                _news.type = NEWS_ITEM_TYPE_NORMAL;
                [excludePhotoNewsIds addObject:_news.newsId];
                [allIds addObject:_news];
            }
        }
        _specialHeadlineNewsTableItem.excludePhotoNewsIds = excludePhotoNewsIds;
        _specialHeadlineNewsTableItem.photoNewsIds = photoNewsIds;
        _specialHeadlineNewsTableItem.allNewsIds = allIds;
        
        _specialHeadlineNewsTableItem = nil;
    }
}

- (void)addHeadlineItemInto:(NSMutableArray *)allItems withNews:(SNSpecialNews *)news allIds:(NSMutableArray*)allIds
               photoNewsIds:(NSMutableArray *)photoNewsIds excludePhotoNewsIds:(NSMutableArray *)excludePhotoNewsIds {
    
    if ([kSNIsFocusDisp_NO isEqualToString:[news isFocusDisp]]) {
        return;
    }
    
    id _obj = nil;
    
    if (allItems.count > 0) {
        NSArray * arr = [allItems objectAtIndex:0];
        if (arr.count > 0) {
            _obj = [arr objectAtIndex:0];
        }
    }
    
    if (_obj == nil) {
        return;
    }
    
    //Datasource的items里有SNSpecialHeadlineNewsTableItem
    if ([_obj isKindOfClass:[SNSpecialHeadlineNewsTableItem class]]) {
        SNSpecialHeadlineNewsTableItem *_specialHeadlineNewsTableItem = (SNSpecialHeadlineNewsTableItem *)_obj;
        [_specialHeadlineNewsTableItem.headlines addObject:news];
        
        if ([kSNGroupPhotoNewsType isEqualToString:news.newsType]) {
            [_specialHeadlineNewsTableItem.photoNewsIds addObject:news.newsId];
            [_specialHeadlineNewsTableItem.allNewsIds addObject:news.newsId];
        } else {
            [_specialHeadlineNewsTableItem.excludePhotoNewsIds addObject:news.newsId];
            [_specialHeadlineNewsTableItem.allNewsIds addObject:news.newsId];
        }
    } 
    
    //Datasource的items里没有SNSpecialHeadlineNewsTableItem
    else {
        SNSpecialHeadlineNewsTableItem *_specialHeadlineNewsTableItem = [[SNSpecialHeadlineNewsTableItem alloc] init];
        _specialHeadlineNewsTableItem.termId = _snModel.termId;
        _specialHeadlineNewsTableItem.headlines = [NSMutableArray arrayWithObject:news];
        _specialHeadlineNewsTableItem.dataSource = _dataSource;
        if (allItems.count > 0) {
            [allItems insertObject:[NSArray arrayWithObject:_specialHeadlineNewsTableItem] atIndex:0];
        } else {
            [allItems addObject:[NSArray arrayWithObject:_specialHeadlineNewsTableItem]];
        }
        
        if ([kSNGroupPhotoNewsType isEqualToString:news.newsType]) {
            [photoNewsIds addObject:news.newsId];
            [allIds addObject:news];
        } else {
            [excludePhotoNewsIds addObject:news.newsId];
            [allIds addObject:news];
        }
        
        _specialHeadlineNewsTableItem.excludePhotoNewsIds = excludePhotoNewsIds;
        _specialHeadlineNewsTableItem.photoNewsIds = photoNewsIds;
        _specialHeadlineNewsTableItem.allNewsIds = allIds;
        
        _specialHeadlineNewsTableItem = nil;
    }
}

- (void)createSpecialNewsTableItemInto:(NSMutableArray *)oneSectionItems withSpecialNews:(SNSpecialNews *)specialNews allIds:(NSMutableArray*)allIds photoNewsIds:(NSMutableArray *)photoNewsIds excludePhotoNewsIds:(NSMutableArray *)excludePhotoNewsIds {

    SNSpecialNewsTableItem *_specialNewsItem = [[SNSpecialNewsTableItem alloc] init];
    _specialNewsItem.snModel = _snModel;
    _specialNewsItem.dataSource = _dataSource;
    
    if ([kSNPhotoAndTextNewsType isEqualToString:specialNews.newsType] || /*[kSNTextNewsType isEqualToString:specialNews.newsType]
        ||*/ [kSNVoteNewsType isEqualToString:specialNews.newsType] || [kSNkSpecialNormal isEqualToString:specialNews.newsType])
    {
        _specialNewsItem.excludePhotoNewsIds = excludePhotoNewsIds;
        _specialNewsItem.type = NEWS_ITEM_TYPE_NORMAL;
        specialNews.type = NEWS_ITEM_TYPE_NORMAL;
        [excludePhotoNewsIds addObject:specialNews.newsId];
        [allIds addObject:specialNews];
    }
    else if ([kSNGroupPhotoNewsType isEqualToString:specialNews.newsType])
    {
        _specialNewsItem.photoNewsIds = photoNewsIds;
        _specialNewsItem.type = NEWS_ITEM_TYPE_GROUP_PHOTOS;
        specialNews.type = NEWS_ITEM_TYPE_GROUP_PHOTOS;
        [photoNewsIds addObject:specialNews.newsId];
        [allIds addObject:specialNews];
    }
    else //暂不支持连续
    {
        
    }
    
    _specialNewsItem.allNews = allIds;
    _specialNewsItem.termId = _snModel.termId;
    _specialNewsItem.news = specialNews;
    [oneSectionItems addObject:_specialNewsItem];
    _specialNewsItem = nil;

}

@end
