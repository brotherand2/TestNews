//
//  SNFeedBackBaseCell.h
//  sohunews
//
//  Created by 李腾 on 2016/10/15.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNTableViewCell.h"
#import "SNFeedBackModel.h"

@interface SNFeedBackBaseCell : UITableViewCell

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIImageView *chatBubble;
@property (nonatomic, strong) UIImageView *warningView;
 

- (void)setDataWithModel:(SNFeedBackModel *)fbModel;

@end
