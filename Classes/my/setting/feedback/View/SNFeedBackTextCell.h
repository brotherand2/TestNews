//
//  SNFeedBackTextCell.h
//  sohunews
//
//  Created by 李腾 on 2016/10/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFeedBackBaseCell.h"

#define kQuestionTitle @"questionTitle"
#define kQuestionId    @"questionId"
#define kQuestionCount 3
#define kDefaultEachQuestionHeight 38

@protocol FeedBackTextCellDelegate <NSObject>

@optional
- (void)resendFeedBackWithFbModel:(SNFeedBackModel *)fbModel;

@end

@interface SNFeedBackTextCell : SNFeedBackBaseCell

@property (nonatomic, strong) UILabel *recordLabel;
@property (nonatomic, weak  ) id<FeedBackTextCellDelegate> delegate;
@property (nonatomic, strong) NSArray *questionArray;
@property (nonatomic, assign) CGFloat FirstRowHeight;

@end
