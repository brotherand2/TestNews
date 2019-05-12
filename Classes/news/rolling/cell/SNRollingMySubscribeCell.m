//
//  SNRollingMySubscribeCell.m
//  sohunews
//
//  Created by lhp on 5/15/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNRollingMySubscribeCell.h"
#import "SNRollingNewsPublicManager.h"

@implementation SNRollingMySubscribeCell

+ (CGFloat)tableView:(UITableView *)tableView
  rowHeightForObject:(id)object {
    SNRollingNewsTableItem *newsItem = object;
    newsItem.news.title = newsItem.news.abstract;
    return MY_SUBSCRIBE_CELL_HEIGHT;
}

- (void)updateNewsContent {
    [super updateNewsContent];
    BOOL isUpdate = [[SNRollingNewsPublicManager sharedInstance] compareUpdateTimeWithDateString:self.item.news.updateTime];
    self.cellContentView.isMySubscribe = YES;
    self.cellContentView.updatedSubscribe = isUpdate;
    [self.cellContentView setNeedsDisplay];
}

- (void)setReadStyleByMemory {
    //不改变文字颜色
    [self setUnReadStyle];
}

- (void)updateTheme {
    [super updateTheme];
    [self.cellContentView setNeedsDisplay];
}

- (void)openNews {
    self.cellContentView.updatedSubscribe = NO;
    NSTimeInterval upDateTimeInterval = [[NSDate date] timeIntervalSince1970] * 1000;
    [[SNRollingNewsPublicManager sharedInstance] updateTimeWithDateString:[NSString stringWithFormat:@"%f", upDateTimeInterval]];
    [super openNews];
}

@end
