//
//  sohunews
//
//  Created by Handy Wang on 7/7/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNSpecialHeadlineNewsTableItem.h"
#import "SNRollingNewsOnePicHeadlineCell.h"
#import "SNLabel.h"

@interface SNSpecialHeadlineNewsTableCell : SNRollingNewsOnePicHeadlineCell {
    SNSpecialHeadlineNewsTableItem *_specialItem;
}

@property(nonatomic, strong)SNSpecialHeadlineNewsTableItem *specialItem;
@property(nonatomic, strong)SNLabel *abstractLabel;

@end
