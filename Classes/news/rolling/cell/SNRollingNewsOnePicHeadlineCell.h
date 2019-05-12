//
//  SNRollingNewsOnePicHeadlineCell.h
//  sohunews
//
//  Created by wang yanchen on 13-1-15.
//  Copyright (c) 2013年 Sohu.com Inc. All rights reserved.
//

#import "SNRollingNewsHeadlineItem.h"
#import "SNCellImageView.h"
#import "SNWebImageView.h"

@interface SNRollingNewsOnePicHeadlineCell : TTTableViewCell {
    SNRollingNewsHeadlineItem *_item;
    NSString *_currentTheme;
    UILabel *_titleLabel;
    UIImageView *_titleMarkView;
    UIImageView *_videoIcon;
}

@property (nonatomic, strong) SNRollingNewsHeadlineItem *item;
@property (nonatomic, strong) SNCellImageView *headlineView;
@property (nonatomic, copy) NSString *currentTheme;

- (void)initSubViews;

- (NSString *)headlinePicUrl;
- (NSString *)headlineTitle;

- (BOOL)headlineHasVideo;
- (void)updateTheme;
- (void)updateNews;

// get height
+ (CGFloat)cellHeight;

@end
