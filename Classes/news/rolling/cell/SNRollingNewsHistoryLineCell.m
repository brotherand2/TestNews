//
//  SNRollingNewsHistoryLineCell.m
//  sohunews
//
//  Created by wangyy on 2017/11/18.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNRollingNewsHistoryLineCell.h"
#import "NSCellLayout.h"

@implementation SNRollingNewsHistoryLineCell

@synthesize lineView = _lineView;
@synthesize titleView = _titleView;
@synthesize newsItem = _newsItem;

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    return 43;
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initLineView];
        [self initTitlView];
    }
    return self;
}

- (void)initTitlView{
    self.titleView = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleView.textColor = SNUICOLOR(kThemeTextRI1Color);
    self.titleView.font =  [UIFont systemFontOfSize:12];
    self.titleView.textAlignment = NSTextAlignmentCenter;
    self.titleView.backgroundColor = SNUICOLOR(kThemeBg5Color);
    self.titleView.centerX = self.centerX;
    [self addSubview:self.titleView];
}

- (void)initLineView{
    self.lineView = [[UIView alloc]initWithFrame:CGRectMake(CONTENT_LEFT, 0, kAppScreenWidth - 2 * CONTENT_LEFT, 0.5)];
    self.lineView.backgroundColor = SNUICOLOR(kThemeBg6Color);
    self.lineView.centerY = 21;
    [self addSubview:self.lineView];
}

- (void)setObject:(id)object {
    if (self.newsItem == object) {
        return;
    }
    if ([object isKindOfClass:[SNRollingNewsTableItem class]]) {
        self.newsItem = (SNRollingNewsTableItem *)object;
    }
    [self updateContentView];
}

- (void)updateContentView {
    NSString *string = self.newsItem.news.title;
    CGSize strSize = [string sizeWithFont:[UIFont systemFontOfSize:kThemeFontSizeC]];
    self.titleView.frame = CGRectMake(0, 0, strSize.width + 12, 15);
    self.titleView.centerX = kAppScreenWidth/2;
    self.titleView.centerY = 21;
    self.titleView.text = string;
}

- (void)updateTheme{
    [super updateTheme];
    self.titleView.textColor = SNUICOLOR(kThemeTextRI1Color);
    self.titleView.backgroundColor = SNUICOLOR(kThemeBgRIColor);
    self.lineView.backgroundColor = SNUICOLOR(kThemeBg6Color);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    ;
}

@end

