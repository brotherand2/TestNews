//
//  SNDatabase_Category.h
//  sohunews
//
//  Created by ivan on 3/14/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNDatabase.h"

@interface SNDatabase(Category) 

-(NSMutableArray*)getAllCachedCategory;

-(BOOL)addMultiCategory:(NSArray*)aCategoryArray updateTopTime:(BOOL)update;

-(NSArray*)getSubedCategoryList;
-(NSArray*)getUnSubedCategoryList;
-(CategoryItem*)getFirstCachedCategory;
@end
