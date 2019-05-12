//
//  SNRollingTrainCollectionBaseCell.h
//  sohunews
//
//  Created by HuangZhen on 2017/10/27.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRollingNews.h"

@interface SNRollingTrainCollectionBaseCell : UICollectionViewCell

@property (nonatomic, strong) SNRollingNews * news;

- (void)setItem:(SNRollingNews *)item;

- (void)updateTheme;

- (void)cellIsDisplaying;
- (void)cellFullDisplaying;
- (void)cellDidEndDisplaying;

@end
