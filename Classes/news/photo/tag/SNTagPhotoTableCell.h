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
@property(nonatomic,strong)SNTagPhotoTableItem *item;
@property(nonatomic,strong)UIImageView *cellBgView;
@property(nonatomic,strong)NSMutableArray *allBtns;
@property(nonatomic,strong)NSString *selectedType;
@property(nonatomic,strong)NSString *selectedId;

-(void)selectedButton:(NSString *)aType strId:(NSString *)aId;

@end
