//
//  SNTagTableCell.h
//  sohunews
//
//  Created by ivan on 3/12/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNTagPhotoTableItem.h"

@interface SNTagPhotoTableCell : TTTableViewCell {
    SNTagPhotoTableItem    *item;
    UIImageView *cellBgView;
    UIImageView *lineView;
    
    NSMutableArray *allBtns;
    
    NSString *selectedType;
    NSString *selectedId;
}
@property(nonatomic,retain)SNTagPhotoTableItem *item;
@property(nonatomic,retain)UIImageView *cellBgView;
@property(nonatomic,retain)NSMutableArray *allBtns;
@property(nonatomic,retain)NSString *selectedType;
@property(nonatomic,retain)NSString *selectedId;

-(void)selectedButton:(NSString *)aType strId:(NSString *)aId;

@end
