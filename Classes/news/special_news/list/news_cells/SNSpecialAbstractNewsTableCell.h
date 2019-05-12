//
//  SNSpecialTextNewsTableCell.h
//  sohunews
//
//  Created by Chen Hong on 11/15/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNLabel.h"

@interface SNSpecialAbstractNewsTableCell : TTTableLinkedItemCell {
    SNLabel *_abstractLabel;
    BOOL isNewItem;
}

@property(nonatomic, strong, readonly)SNLabel *abstractLabel;

-(void)updateTheme;

@end
