//
//  SNHotTableItem.h
//  sohunews
//
//  Created by ivan on 3/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "CacheObjects.h"
#import <Foundation/Foundation.h>
#import "SNPhotosTableController.h"

@interface SNPhotoTableItem : TTTableLinkedItem {
    GroupPhotoItem *hotPhotoNews;
    NSMutableDictionary *imagesDic;
    
    NSIndexPath *indexPath;
    SNPhotosTableController *controller;
    
    NSMutableArray *allItems;
}

@property(nonatomic,retain)GroupPhotoItem *hotPhotoNews;
@property(nonatomic,retain)NSMutableDictionary *imagesDic;
@property(nonatomic,retain)NSIndexPath  *indexPath;
@property(nonatomic,retain)NSMutableArray *allItems;
@property(nonatomic,assign)SNPhotosTableController *controller;

//-(void)freeImagesDic;

//-(void)fetchCellImage:(NSString *)imagePath tag:(int)tag;
//- (void)cacheCellImageToMemory:(UIImage *)aImg urlPath:(NSString *)aPath;

@end
