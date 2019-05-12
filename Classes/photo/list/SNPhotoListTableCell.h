//
//  SNPhotoListTableCell.h
//  sohunews
//
//  Created by 雪 李 on 11-12-14.
//  Copyright (c) 2011年 Sohu.com Inc. All rights reserved.
//

#import "SNMTLabel.h"

@class SNPhotoListTableItem;
@class SNWebImageView;
@interface SNPhotoListTableCell : TTTableViewCell<NSMTlabelMenuDelegate>
{
    SNPhotoListTableItem    *_item;
    CGSize _infoSize;
    CGSize _imageSize;
    
    UIView *containerView;
//    SNWebImageView *webImageView;
    
    SNMTLabel *abstractLabel;
    
    UIImage *_defaultImage;
    UIImageView *_defaultImageView;
}

@property(nonatomic,retain)SNPhotoListTableItem *item;
@property(nonatomic,readonly)CGSize imageSize;
@property(nonatomic,retain)UIImageView *webImageView;
@property(nonatomic,retain)UIView *containerView;
@property(nonatomic,retain)SNMTLabel *abstractLabel;
@property(nonatomic,assign)id delegate;

- (CGRect)getImageRect;
- (void)showImage:(BOOL)bShow;

@end
