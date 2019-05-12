//
//  SNTagModel.m
//  sohunews
//
//  Created by ivan.qi on 3/12/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNTagPhotoModel.h"
#import "SNURLJSONResponse.h"
#import "SNDBManager.h"
#import "SNChannelManageContants.h"
#import "NSObject+YAJL.h"
#import "SNKeywordRequest.h"

@interface SNTagPhotoModel(Private)

-(void)requestTags:(BOOL)isASyn;
-(void)parseJsonData:(id)aData;

@end

@implementation SNTagPhotoModel

@synthesize allTags, allCategories, oldCategories;

- (id)init {
	self = [super init];
	if (self) {
        _isFirst = YES;
        isNotInit=NO;
    }
	return self;
}

- (BOOL)isLoaded {
	return (self.allTags != nil  || self.allCategories != nil);
}
//发起网络请求获取hot photo news
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more 
{
    [super load:cachePolicy more:more];
    
    
    if (!self.isLoading) {
        if (_isFirst) {
            _isFirst = NO;
            NSMutableArray *cachedTags = [[[SNDBManager currentDataBase] getAllCachedTag] mutableCopy];
            self.allTags = cachedTags;
             //(cachedTags);
            
            NSMutableArray *cachedCategories = [[[SNDBManager currentDataBase] getAllCachedCategory] mutableCopy];
            self.allCategories = cachedCategories;
            for (CategoryItem *item in self.allCategories) {
                if (item.top&&item.top.length>0) {
                    isNotInit=YES;
                    break ;
                }
            }
            
             //(cachedCategories);
            
            [self didFinishLoad];
        }
        
//		[self requestTags:YES];
        [self requestTags];
    }
}

//- (void)requestTags:(BOOL)isASyn {
//	if (!_request) {
//		_request = [SNURLRequest requestWithURL:SNLinks_Path_Photo_Tags delegate:self];
//        _request.isShowNoNetWorkMessage = NO;
//		_request.cachePolicy = TTURLRequestCachePolicyNone;
//        //_request.cacheExpirationAge	= 60*5;    // 5 分钟;
//	} else {
//		_request.urlPath = SNLinks_Path_Photo_Tags;
//	}
//	
//	_request.response = [[SNURLJSONResponse alloc] init];
//	if (isASyn) {
//		[_request send];
//	} else {
//		[_request sendSynchronously];
//	}
//}

- (void)requestTags {
    
    [[[SNKeywordRequest alloc] init] send:^(SNBaseRequest *request, id rootData) {
        self.allTags = [NSMutableArray array];
        self.oldCategories = [NSMutableArray arrayWithArray:self.allCategories]; // cache old
        
        SNDebugLog(@"%@",rootData);
        [self parseJsonData:rootData];
        [self saveAsCacheByRequest];
        
    } failure:^(SNBaseRequest *request, NSError *error) {
        
        SNDebugLog(@"didFailLoadWithError---%@", [error localizedDescription]);
        NSMutableArray *cachedTags = [[[SNDBManager currentDataBase] getAllCachedTag] mutableCopy];
        self.allTags = cachedTags;
        
        NSMutableArray *cachedCategories = [[[SNDBManager currentDataBase] getAllCachedCategory] mutableCopy];
        self.allCategories = cachedCategories;
    }];
}

- (void)saveAsCache {
    if (self.allTags) {
        [[SNDBManager currentDataBase] addMultiTag:self.allTags];
    }
    if (self.allCategories&&self.allCategories.count>0) {
        BOOL update=NO;
        NSArray *cacheCategories=[[SNDBManager currentDataBase] getAllCachedCategory];
        if(cacheCategories.count!=self.allCategories.count)
        {
            SNDebugLog(@"count %d",update);
            
            update=YES;

        }
        else{
            for (int i=0; i<self.allCategories.count; i++) {
                CategoryItem *item1=[self.allCategories objectAtIndex:i];
                CategoryItem *item2=[cacheCategories objectAtIndex:i];
                if ([item1 isChanged:item2]) {
                    update=YES;
                    SNDebugLog(@"if %d",update);

                    break;
                }
            }
        }
        SNDebugLog(@"%d",update);
        [[SNDBManager currentDataBase] addMultiCategory:self.allCategories updateTopTime:update];
    }
    
}
- (void)saveAsCacheByRequest {
    if (self.allTags) {
        [[SNDBManager currentDataBase] addMultiTag:self.allTags];
    }
    if (self.allCategories&&self.allCategories.count>0) {
        [[SNDBManager currentDataBase] addMultiCategory:self.allCategories updateTopTime:NO];
    }
    isNotInit = YES;
}


- (NSArray *)subedCategories {
    NSMutableArray *subedCategories = [NSMutableArray array];
    if (self.allCategories) {
        for (CategoryItem *item in self.allCategories) {
            if ([item.isSubed isEqualToString:@"1"]) {
                [subedCategories addObject:item];
            }
        }
    }
    return subedCategories;
}

- (void)requestDidFinishLoad:(id)data {
    self.allTags = [NSMutableArray array];
    self.oldCategories = [NSMutableArray arrayWithArray:self.allCategories]; // cache old
    //self.allCategories = [NSMutableArray array];
	
	SNURLJSONResponse *dataResponse = (SNURLJSONResponse *)_request.response;
	id rootData = dataResponse.rootObject;
    
    SNDebugLog(@"%@",rootData);
    //for test
//    NSData *adata = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"]];
//    rootData = [[adata yajl_JSON] retain];
    //////////////////////////////////
    
    [self parseJsonData:rootData];
    [self saveAsCacheByRequest];
    [super requestDidFinishLoad:_request];
}

- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error {
    SNDebugLog(@"didFailLoadWithError---%@", [error localizedDescription]);
    NSMutableArray *cachedTags = [[[SNDBManager currentDataBase] getAllCachedTag] mutableCopy];
    self.allTags = cachedTags;
     //(cachedTags);
    
    NSMutableArray *cachedCategories = [[[SNDBManager currentDataBase] getAllCachedCategory] mutableCopy];
    self.allCategories = cachedCategories;
     //(cachedCategories);
    
    [super requestDidFinishLoad:request];
}

- (void)parseJsonData:(id)rootData {
    @autoreleasepool {
        id categoriesData = [rootData objectForKey:kCategories];
        
        if ([categoriesData isKindOfClass:[NSArray class]]) {
            NSMutableArray *newItems = [NSMutableArray array];
            for (NSDictionary *categoryDic in categoriesData) {
                CategoryItem *category = [[CategoryItem alloc] init];
                NSNumber *cId = (NSNumber *)[categoryDic objectForKey:kId];
                category.categoryID    = [cId stringValue];
                category.name          = [categoryDic objectForKey:kName];
                category.icon          = [categoryDic objectForKey:kIcon];
                category.position      = [categoryDic objectForKey:kPosition];
                category.top           = [categoryDic objectForKey:kTop];
                [category setTopTime:[categoryDic objectForKey:kTopTime] formatter:@"yyyy-MM-dd HH:mm:ss"];
                [newItems addObject:category];
            }
            BOOL bNeedNotify = NO;
            if (newItems.count > 0) {
                
                //非预装的用户
                if ((isNotInit&&[[NSUserDefaults standardUserDefaults] boolForKey:kCategoryEdit]) || [[NSUserDefaults standardUserDefaults] boolForKey:kCatagoryCloudSyn])
                {
                    if([[NSUserDefaults standardUserDefaults] boolForKey:kCatagoryCloudSyn])
                    {
                         //(allCategories);
                        allCategories = [[[SNDBManager currentDataBase] getAllCachedCategory] mutableCopy];
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kCatagoryCloudSyn]; //处理过同步了
                    }
                    
                    //新增的频道
                    NSMutableArray *addCategorys = [NSMutableArray arrayWithArray:newItems];
                    [addCategorys removeObjectsInArray:self.allCategories];
                    
                    NSMutableArray *subed = [NSMutableArray arrayWithArray:[self subedCategories]];
                    
                    // 个数变了
                    if (newItems.count != self.oldCategories.count) {
                        bNeedNotify = YES;
                    } else {
                        for (int i = 0; i < newItems.count; i++) {
                            CategoryItem *oldItem = [self.oldCategories objectAtIndex:i];
                            CategoryItem *newItem = [newItems objectAtIndex:i];
                            if (![newItem isEqual:oldItem]) {
                                bNeedNotify = YES;
                                break ;
                            } else if (![oldItem.name isEqualToString:newItem.name]) {
                                bNeedNotify = YES;
                                break ;
                            } else if ([newItem isLaterThan:oldItem]) {
                                bNeedNotify = YES;
                                break ;
                            } else {
                                continue ;
                            }
                        }
                    }
                    // 需要删除的
                    [self.oldCategories removeObjectsInArray:newItems];
                    // 剩余的选中的
                    [subed removeObjectsInArray:self.oldCategories];
                    
                    NSMutableArray *itemsArray = [NSMutableArray arrayWithCapacity:newItems.count];
                    //初装用户,频道列表被完全覆盖
                    for (CategoryItem *item in newItems) {
                        if ([item.top isEqualToString:@"2"]) {
                            item.isSubed = @"1";
                            [itemsArray addObject:item];
                        } else if([item.top isEqualToString:@"1"]){
                            NSInteger index = [self.allCategories indexOfObject:item];
                            if (index != NSNotFound) {
                                CategoryItem *tmpItem = [self.allCategories objectAtIndex:index];
                                if ([item isLaterThan:tmpItem]) {
                                    item.isSubed = @"1";
                                    [itemsArray addObject:item];
                                }
                            } else {
                                item.isSubed = @"1";
                                [itemsArray addObject:item];
                            }
                            
                        } else {
                            break;
                        }
                    }
                    [subed removeObjectsInArray:itemsArray];
                    for (CategoryItem *item in subed) {
                        NSInteger index = [newItems indexOfObject:item];
                        CategoryItem *_item = [newItems objectAtIndex:index];
                        _item.isSubed = @"1";
                        [itemsArray addObject:_item];
                    }
                    [newItems removeObjectsInArray:itemsArray];
                    [self.allCategories removeAllObjects];
                    [self.allCategories addObjectsFromArray:itemsArray];
                    [addCategorys removeObjectsInArray:itemsArray];
                    for (CategoryItem *item in addCategorys) {
                        item.isSubed = @"1";
                        [self.allCategories addObject:item];
                    }
                    
                    if(self.allCategories.count == 0)
                    {
                        CategoryItem *item = [newItems objectAtIndex:0];
                        item.isSubed = @"1";
                    }
                    //初装用户,频道列表被完全覆盖
                    if (self.allCategories.count > kChannelMaxNum) {
                        for (int i = kChannelMaxNum ;i < self.allCategories.count; i++) {
                            CategoryItem *item = [self.allCategories objectAtIndex:i];
                            item.isSubed = @"0";
                        }
                    }
                    [newItems removeObjectsInArray:addCategorys];
                    [self.allCategories addObjectsFromArray:newItems];
                    
                }
                //初装用户,频道列表被完全覆盖
                else {
                    for (int i = 0; i < newItems.count; i++) {
                        if (i < kChannelMaxNum) {
                            CategoryItem *item = [newItems objectAtIndex:i];
                            item.isSubed = @"1";
                        } else {
                            break;
                        }
                    }
                    [self.allCategories removeAllObjects];
                    [self.allCategories addObjectsFromArray:newItems];
                }
                
            } else {
                bNeedNotify = YES;  //如果服务端返回的频道个数为0，不保存数据到数据库中
            }
            while (self.allCategories.count > kChannelMaxVolum) {
                [self.allCategories removeLastObject];
            }
            if (bNeedNotify) {
                [SNNotificationManager postNotificationName:kPhotoChannelChangedNotification object:nil];
            }
        }
        
        id tagsData = [rootData objectForKey:kTags];
        if ([tagsData isKindOfClass:[NSArray class]]) {
            for (NSDictionary *tagDic in tagsData) {
                SNTagItem *tag = [[SNTagItem alloc] init];
                NSNumber *tagId = (NSNumber *)[tagDic objectForKey:kTagId];
                tag.tagId    = [tagId stringValue];
                tag.tagName  = [tagDic objectForKey:kTagName];
                [self.allTags addObject:tag];
            }
        }
    }
}

- (void)cancelAllRequest {
	if (_request) {
		[_request cancel];
	}
}

-(void)dealloc {
     //(allTags);
     //(allCategories);
     //(oldCategories);
     //(_request);
}


@end
