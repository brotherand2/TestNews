//
//  SNTagTableItem.h
//  sohunews
//
//  Created by ivan on 3/12/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SNTagPhotoTableViewController.h"

@interface SNTagPhotoTableItem : TTTableItem {
    NSMutableArray *allTags;
    NSMutableArray *allCategories;
    SNTagPhotoTableViewController *controller;
    
    NSIndexPath *indexPath;
    int row;
}

@property(nonatomic,retain)NSMutableArray *allTags;
@property(nonatomic,readwrite)int row;
@property(nonatomic,retain)NSMutableArray *allCategories;
@property(nonatomic,retain)NSIndexPath  *indexPath;
@property(nonatomic, assign)SNTagPhotoTableViewController *controller;

@end
