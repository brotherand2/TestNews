//
//  SNSelfCenterSearchCell.h
//  sohunews
//
//  Created by yangln on 14-9-28.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"

@interface SNSelfCenterSearchCell : SNTableViewCell {
    UIImage *_cellItemImage;
    UILabel *_cellItemLabel;
    UIImageView *_cellItemImageView;
    
    UIImageView *_bgImageView;
}

- (void)setCellItem;

@end
