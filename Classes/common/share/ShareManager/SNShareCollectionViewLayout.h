//
//  SNShareCollectionViewLayout.h
//  sohunews
//
//  Created by wang shun on 2017/1/20.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNShareCollectionViewLayout : UICollectionViewLayout

@property (nonatomic) CGFloat minimumLineSpacing;              // 最小 Item 行间距

@property (nonatomic) CGFloat minimumInteritemSpacing;         // 最小 Item 列间距

@property (nonatomic) CGSize  itemSize;                        // Item 尺寸

@property (nonatomic) UIEdgeInsets sectionInset;               // Item 内边距

- (instancetype)init;

@end
