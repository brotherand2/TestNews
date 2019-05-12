//
//  SNTagTableViewController.h
//  sohunews
//
//  Created by ivan.qi on 3/6/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "CacheObjects.h"
#import "SNTableViewController.h"

@protocol SNTagPhotoTableViewControllerDelegate <NSObject> 

-(void)selectedCategory:(CategoryItem *)aCategory;
-(void)selectedTag:(TagItem *)aTag;

@end

@interface SNTagPhotoTableViewController : SNTableViewController {
    id<SNTagPhotoTableViewControllerDelegate> delegate;
    NSString *targetType;
    NSString *typeId;
    BOOL _isViewReleased;
}
@property(nonatomic,assign)id<SNTagPhotoTableViewControllerDelegate> delegate;
@property(nonatomic,copy)NSString *targetType;
@property(nonatomic,copy)NSString *typeId;

-(void)changeAllCellsItemStatus:(NSString *)aType strId:(NSString *)aId;
-(void)clickOnCategoryBtn:(CategoryItem *)aCategory;
-(void)clickOnTagBtn:(TagItem *)aTag;

-(void)reCreateModel;

-(void)updateTheme;

@end
