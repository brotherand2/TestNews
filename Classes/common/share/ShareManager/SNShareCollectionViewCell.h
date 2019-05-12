//
//  SNShareCollectionViewCell.h
//  sohunews
//
//  Created by wang shun on 2017/1/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNShareCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *label;

- (void)setDataWithDict:(NSDictionary *)dict;
- (void)setImageViewStateWithHightlighted:(BOOL)hightlight andDict:(NSDictionary *)dict;

@end
