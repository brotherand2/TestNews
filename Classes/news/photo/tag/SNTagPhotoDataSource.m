//
//  SNTagDataSource.m
//  sohunews
//
//  Created by ivan on 3/12/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "CacheObjects.h"
#import "SNTagPhotoDataSource.h"
#import "SNTagPhotoTableItem.h"
#import "SNTagPhotoTableCell.h"

@implementation SNTagPhotoDataSource

@synthesize tagModel, controller;

-(id)init {
    if (self = [super init]) {
        SNTagPhotoModel *model = [[SNTagPhotoModel alloc] init];
        self.tagModel = model;
         //(model);
	}
	
	return self;
}

- (id<TTModel>)model {
	return self.tagModel;
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
    self.items      = [NSMutableArray array];
   
    for (int i = 0; i < 2; i++) {
        SNTagPhotoTableItem *item = [[SNTagPhotoTableItem alloc] init];
        item.controller = controller;
        item.allCategories = self.tagModel.allCategories;
        item.allTags = self.tagModel.allTags;
        item.row = i;
        [self.items addObject:item];
    }
     
}

#pragma mark -
#pragma mark TTTableViewDataSource

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SNTagPhotoTableItem *item = (SNTagPhotoTableItem*)[self tableView:tableView objectForRowAtIndexPath:indexPath];
    item.indexPath  = indexPath;
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
	if ([object isKindOfClass:[SNTagPhotoTableItem class ]]) {
		return [SNTagPhotoTableCell class];
	}
	return [super tableView:tableView cellClassForObject:object];
}

-(void)dealloc {
     //(tagModel);
}


@end
