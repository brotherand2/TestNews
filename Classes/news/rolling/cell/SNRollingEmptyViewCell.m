//
//  SNRollingEmptyViewCell.m
//  sohunews
//
//  Created by ZhaoQing on 15/7/14.
//  Copyright (c) 2015年 Sohu.com. All rights reserved.
//

#import "SNRollingEmptyViewCell.h"

static CGFloat rowHeight = 0.0f;
#define kAddSubscribeCellHeight (kAppScreenHeight - kHeaderTotalHeight - kHeaderHeight - 35)
#define kImageViewTop ((kAppScreenWidth > 375) ? 260 / 3 : 158 / 2)
#define kImageViewWidth ((kAppScreenWidth > 375) ? 204 / 3 : 124 / 2)
#define kImageViewHeight ((kAppScreenWidth > 375) ? 210 / 3 : 128 / 2)
#define kTitleLabelTop ((kAppScreenWidth > 375) ? 56 / 3 : 34 / 2)

@implementation SNRollingEmptyViewCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    if (rowHeight == 0.0f) {
        rowHeight = kAddSubscribeCellHeight;
    }
    return rowHeight;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = NO;
        [self initContentView];
    }
    return self;
}

- (void)initContentView {
    addImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kAppScreenWidth / 2 - kImageViewWidth / 2, kImageViewTop, kImageViewWidth, kImageViewHeight)];
    addImageView.image = [UIImage imageNamed:@"mysubcribeempty_v5.png"];
    [self addSubview:addImageView];

    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,addImageView.bottom + kTitleLabelTop, kAppScreenWidth, kThemeFontSizeD + 1)];
    titleLabel.text = @"尚未订阅任何内容";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeD];
    titleLabel.textColor = [[SNThemeManager sharedThemeManager] currentThemeColorForKey:kThemeText3Color];
    [self addSubview:titleLabel];
}

- (void)updateTheme {
    [super updateTheme];
    addImageView.image = [UIImage imageNamed:@"mysubcribeempty_v5.png"];
    titleLabel.textColor = SNUICOLOR(kThemeText3Color);
    [self setNeedsDisplay];
}

@end
