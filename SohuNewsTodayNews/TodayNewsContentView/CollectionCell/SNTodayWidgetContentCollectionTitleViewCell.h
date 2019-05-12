//
//  SNTodayWidgetContentCollectionTitleViewCell.h
//  sohunews
//
//  Created by wangyy on 15/10/29.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTodayWidgetConst.h"
#import "SNTodayWidgetNews.h"
#import "UIImageView+WebCache.h"
#import "NSString+Utilities.h"
#import "SNDevice.h"

@interface SNTodayWidgetContentCollectionTitleViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *newsTitleLabel;
@property (nonatomic, strong) UIImageView *newsCommentCountIcon;
@property (nonatomic, strong) UILabel *newsCommentCountLabel;

- (void)configureCellWithRowNews:(SNTodayWidgetNews *)newsItem;
+ (CGFloat)cellHeightForNews:(SNTodayWidgetNews *)news width:(float)width;
+ (CGFloat)getImageHeight;
+ (CGFloat)getImageDistance;

@end
