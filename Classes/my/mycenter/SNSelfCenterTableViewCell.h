//
//  SNSelfCenterTableViewCell.h
//  sohunews
//
//  Created by yangln on 14-9-24.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"
#import "SNMyCustomButton.h"

@interface SNSelfCenterTableViewCell : SNTableViewCell {
    UIImage *_cellItemImage;
    UILabel *_cellItemLabel;
    UIImageView *_cellItemImageView;
    UIImageView *_cellItemSeperateImageView;
    
    UIImageView *_bgImageView;

    SNMyCustomButton *_customButton;
    NSInteger _typeTag;
}

- (void)setCellItem:(NSString *)imageName text:(NSString *)text tag:(NSInteger)tag;
- (void)setCellItemSeperateLine:(NSInteger)row;
- (void)reSetBubble:(NSIndexPath *)indexPath;
@end
