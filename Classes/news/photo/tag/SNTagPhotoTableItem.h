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
    SNTagPhotoTableViewController *__weak controller;
    
    NSIndexPath *indexPath;
    int row;
}

@property(nonatomic,strong)NSMutableArray *allTags;
@property(nonatomic,readwrite)int row;
@property(nonatomic,strong)NSMutableArray *allCategories;
@property(nonatomic,strong)NSIndexPath  *indexPath;
@property(nonatomic, weak)SNTagPhotoTableViewController *controller;

@end
