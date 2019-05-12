//
//  SNRollingGroupPhotoDataSource.m
//  sohunews
//
//  Created by Dan Cong on 10/26/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNRollingGroupPhotoDataSource.h"
#import "SNRollingGroupPhotoModel.h"
#import "SNPhotoTableItem.h"
#import "SNTableMoreButton.h"

@implementation SNRollingGroupPhotoDataSource

- (id)initWithChannelId:(NSString *)channelId {
    if (self = [super init]) {
        SNRollingGroupPhotoModel *model = [[SNRollingGroupPhotoModel alloc] init];
        model.targetType = kGroupPhotoChannel;
        model.typeId = channelId;
        model.pageWhenViewReleased = 0;
        model.timelineWhenViewReleased = @"";
        model.isRecreate = YES;
        self.hotPhotoModel = model;
	}
	return self;
}

- (void)tableViewDidLoadModel:(UITableView *)tableView {
    self.items = [NSMutableArray array];
    self.newsIds = [NSMutableArray array];
    
    NSMutableArray *tableItems = [NSMutableArray array];
    
    //添加本次查询的项
    for (GroupPhotoItem *photoNews in self.hotPhotoModel.allPhotos) {
        SNPhotoTableItem *item = [[SNPhotoTableItem alloc] init];
        item.controller = (id)self.controller;//这里是SNRollingNewsTableController，不是以前的PhotosController了
        item.hotPhotoNews = photoNews;
        [self.newsIds addObject:photoNews.newsId];
        item.allItems = self.newsIds;
        [tableItems addObject:item];
    }
    
    self.items = [NSMutableArray array];
    [self.items addObjectsFromArray:tableItems];
    
    //添加more button
    if (!self.hotPhotoModel.hasNoMore && self.items.count > 0) {
        SNTableMoreButton *moreBtn = [SNTableMoreButton itemWithText:NSLocalizedString(@"Loading...", @"Loading...")];
        moreBtn.model = self.model;
        [self.items addObject:moreBtn];
    }
}

@end
