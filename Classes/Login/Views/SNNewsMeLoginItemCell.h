//
//  SNNewsMeLoginItemCell.h
//  sohunews
//
//  Created by wang shun on 2017/9/25.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNNewsMeLoginItemCell : UICollectionViewCell
@property (nonatomic,strong) NSDictionary* dic;

- (void)setInfo:(NSDictionary*)info;

@end
