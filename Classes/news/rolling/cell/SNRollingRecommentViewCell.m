//
//  SNRollingRecommentViewCell.m
//  sohunews
//
//  Created by 赵青 on 15/12/2.
//  Copyright © 2015年 Sohu.com. All rights reserved.
//

#import "SNRollingRecommentViewCell.h"

@interface SNRollingRecommentViewCell () {
    UILabel *titleLabel;
    UIView *lineView;
}

@end

#define kRecommentViewCellHeight ((kAppScreenWidth > 375) ? 54 / 3 + 14 : 33 / 2 + 14)
#define kTitleLabelLeft ((kAppScreenWidth > 375) ? 54 / 3 : 33 / 2)
static CGFloat rowCellHeight = 0.0f;

@implementation SNRollingRecommentViewCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    if (rowCellHeight == 0.0f) {
        rowCellHeight = kRecommentViewCellHeight + 10;
    }
    return rowCellHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.showSlectedBg = NO;
        [self initContentView];
    }
    return self;
}

- (void)initContentView {
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kAppScreenWidth, 0.5f)];
    lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    lineView.clipsToBounds = NO;
    [self addSubview:lineView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kTitleLabelLeft, 115, kThemeFontSizeC +10)];
    titleLabel.text = @"推荐搜狐号";
    titleLabel.font = [UIFont systemFontOfSize:kThemeFontSizeC];
    titleLabel.textColor = SNUICOLOR(kThemeText5Color);
    titleLabel.backgroundColor = SNUICOLOR(kThemeRed1Color);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
}

- (void)updateTheme {
    [super updateTheme];
    titleLabel.backgroundColor = SNUICOLOR(kThemeRed1Color);
    titleLabel.textColor = SNUICOLOR(kThemeText5Color);
    lineView.backgroundColor = SNUICOLOR(kThemeBg1Color);
    [self setNeedsDisplay];
}

@end
