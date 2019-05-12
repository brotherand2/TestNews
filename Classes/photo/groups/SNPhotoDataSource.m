//
//  SNHotDataSource.m
//  sohunews
//
//  Created by ivan on 3/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "CacheObjects.h"
#import "SNPhotoDataSource.h"
#import "SNPhotosTableController.h"
#import "SNPhotoTableItem.h"
#import "SNPhotoTableOneCell.h"
#import "SNPhotoTableFourCell.h"
#import "SNTableAutoLoadMoreCell.h"
#import "SNTableMoreButton.h"

@implementation SNPhotoDataSource

@synthesize hotPhotoModel;

-(id)init {
    if (self = [super init]) {
        SNPhotoModel *model = [[SNPhotoModel alloc] init];
        self.hotPhotoModel = model;
        TT_RELEASE_SAFELY(model);
	}
	return self;
}

-(id)initWithType:(NSString *)aType andId:(NSString *)aId {
    if (self = [super init]) {
        SNPhotoModel *model = [[SNPhotoModel alloc] init];
        model.targetType = aType;
        model.typeId = aId;
        self.hotPhotoModel = model;
        TT_RELEASE_SAFELY(model);
	}
	return self;
}

-(id)initWithType:(NSString *)aType 
            andId:(NSString *)aId 
       latestPage:(int)pageWhenViewReleased
  lastMinTimeline:(NSString *)lastMinTimeline
       lastOffset:(NSString *)lastOffset {
    if (self = [super init]) {
        SNPhotoModel *model = [[SNPhotoModel alloc] init];
        model.targetType = aType;
        model.typeId = aId;
        model.pageWhenViewReleased = pageWhenViewReleased;
        model.timelineWhenViewReleased =  lastMinTimeline;
        model.lastOffset = lastOffset;
        //model.isRecreate = YES;
        self.hotPhotoModel = model;
        TT_RELEASE_SAFELY(model);
	}
	return self;
}

- (id<TTModel>)model {
	return self.hotPhotoModel;
}

- (UIImage*)imageForEmpty {
    NSString *name = [[SNThemeManager sharedThemeManager] themeFileName:@"tb_empty_bg.png"];
	return [[UIImage imageNamed:name] scaledImage];
}

- (NSString*)titleForEmpty {
	return NSLocalizedString(@"photoGroupNoNews", @"");
}

- (NSString*)subtitleForEmpty {
	return NSLocalizedString(@"photoGroupRefresh", @"");
}

- (UIImage*)imageForError:(NSError*)error {
    return [[UIImage imageNamed:@"tb_error_bg.png"] scaledImage];
}

- (NSString*)titleForError:(NSError*)error {
//    return NSLocalizedString(@"photoGroupNoNews", @"");
    return nil;
}

- (NSString*)subtitleForError:(NSError*)error {
//    return NSLocalizedString(@"photoGroupRefresh", @"");
    return nil;
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
    _photosTableController.currentViewPage = self.hotPhotoModel.page;
    _photosTableController.currentOffSet = self.hotPhotoModel.lastOffset;
    if ([self.hotPhotoModel.hotPhotos count] > 0) {
        //GroupPhotoItem *firstPhoto = (GroupPhotoItem *)[self.hotPhotoModel.hotPhotos objectAtIndex:0];
        GroupPhotoItem *lastPhoto = (GroupPhotoItem *)[self.hotPhotoModel.hotPhotos lastObject];
        _photosTableController.currentMinTimeline = [lastPhoto timelineIndex];
    }
    
    //if (!self.hotPhotoModel.more || self.hotPhotoModel.isQueryTargetChanged) {
    if (!self.hotPhotoModel.more || self.hotPhotoModel.isQueryTargetChanged) {
        self.hotPhotoModel.isQueryTargetChanged = NO;
        self.items = [NSMutableArray array];
        self.newsIds = [NSMutableArray array];
    }
    
    NSMutableArray *news = self.hotPhotoModel.hotPhotos;
    
    //删除more button
    if ([self.items count] > 0) {
        [self.items removeLastObject];
    }
    
    //添加本次查询的项
    for (GroupPhotoItem *photoNews in news) {
        SNPhotoTableItem *item = [[SNPhotoTableItem alloc] init];
        item.controller = _photosTableController;
        item.hotPhotoNews = photoNews;
        [self.newsIds addObject:photoNews.newsId];
        item.allItems = self.newsIds;
        [self.items addObject:item];
        [item release];
    }
    
    //添加more button
    if (!self.hotPhotoModel.hasNoMore) {
        SNTableMoreButton *moreBtn = [SNTableMoreButton itemWithText:NSLocalizedString(@"Loading...", @"Loading...")];
        moreBtn.model = self.model;
        [self.items addObject:moreBtn];
    }
   
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.f && !self.hotPhotoModel.more == YES) {
        
        if (_photosTableController.isPhotoList) {
            _photosTableController.tableView.contentInset = UIEdgeInsetsZero;
        }else {
            _photosTableController.tableView.contentInset = UIEdgeInsetsMake(kHeaderHeightWithoutBottom, 0.f, kToolbarViewHeight, 0.f);
            _photosTableController.tableView.contentOffset = CGPointMake(0.f, -kHeaderHeightWithoutBottom);
        }
        
    }
}

-(void)changeFavNum:(int)favNum byNewsId:(NSString *)newsId {
    for (id item in self.items) {
        if ([item isKindOfClass:[SNPhotoTableItem class]]) {
            SNPhotoTableItem *photoItem = (SNPhotoTableItem *)item;
            if ([photoItem.hotPhotoNews.newsId isEqualToString:newsId]) {
                photoItem.hotPhotoNews.favoriteNum = [NSString stringWithFormat:@"%d", favNum];
                break;
            }
        }
    }
}

-(void)changePhotoNewsReadStyle:(NSString *)newsId {
    for (id item in self.items) {
        if ([item isKindOfClass:[SNPhotoTableItem class]]) {
            SNPhotoTableItem *photoItem = (SNPhotoTableItem *)item;
            if ([photoItem.hotPhotoNews.newsId isEqualToString:newsId]) {
                photoItem.hotPhotoNews.readFlag = 1;
                break;
            }
        }
    }
}

/*-(void)freeCachedImages {
    for (id item in self.items) {
        if ([item isKindOfClass:[SNPhotoTableItem class]]) {
            SNPhotoTableItem *pItem = (SNPhotoTableItem *)item;
            [pItem freeImagesDic];
        }
    }
}*/

#pragma mark -
#pragma mark TTTableViewDataSource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self tableView:tableView objectForRowAtIndexPath:indexPath];
    if (![obj isKindOfClass:[SNTableMoreButton class]]) {
        SNPhotoTableItem *item = (SNPhotoTableItem*)[self tableView:tableView objectForRowAtIndexPath:indexPath];
        item.indexPath  = indexPath;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
	if ([object isKindOfClass:[SNPhotoTableItem class ]]) {
        SNPhotoTableItem *dataItem  = (SNPhotoTableItem*)object;
        NSMutableArray *imagePaths  = dataItem.hotPhotoNews.images;
        if ([imagePaths count] < 4) {
            return [SNPhotoTableOneCell class];
        } else {
            return [SNPhotoTableFourCell class];
        }
		
	} else if ([object isKindOfClass:[TTTableMoreButton class]]) {
        return [SNTableAutoLoadMoreCell class];
	}
    
	return [super tableView:tableView cellClassForObject:object];
}

-(void)dealloc {
    TT_RELEASE_SAFELY(hotPhotoModel);
    [super dealloc];
}


@end
