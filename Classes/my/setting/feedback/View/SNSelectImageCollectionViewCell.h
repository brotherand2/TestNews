//
//  SNSelectImageCollectionViewCell.h
//  sohunews
//
//  Created by 李腾 on 2016/10/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNSelectImageCollectionViewCell;
@protocol SNSelectImageCollectionViewCellDelegate <NSObject>

@optional
- (void)removeImageWithCell:(SNSelectImageCollectionViewCell *)cell;

@end

@interface SNSelectImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) UIImageView *imageView;

@property (nonatomic, weak) UIButton *delBtn;

@property (nonatomic, weak) id<SNSelectImageCollectionViewCellDelegate> delegate;


@end
