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
    SNPhotosTableController *__weak controller;
    
    NSMutableArray *allItems;
}

@property(nonatomic,strong)GroupPhotoItem *hotPhotoNews;
@property(nonatomic,strong)NSMutableDictionary *imagesDic;
@property(nonatomic,strong)NSIndexPath  *indexPath;
@property(nonatomic,strong)NSMutableArray *allItems;
@property(nonatomic,weak)SNPhotosTableController *controller;

//-(void)freeImagesDic;

//-(void)fetchCellImage:(NSString *)imagePath tag:(int)tag;
//- (void)cacheCellImageToMemory:(UIImage *)aImg urlPath:(NSString *)aPath;

@end
