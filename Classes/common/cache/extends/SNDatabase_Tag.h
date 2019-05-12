//
//  SNDatabase_GroupTag.h
//  sohunews
//
//  Created by ivan on 3/12/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//
#import "SNDatabase.h"

@interface SNDatabase(Tag) 

-(NSMutableArray*)getAllCachedTag;

-(BOOL)addMultiTag:(NSArray*)aTagArray;

@end
