//
//  SNSpecialNewsDelegate.m
//  sohunews
//
//  Created by handy wang on 7/4/12.
//  Copyright (c) 2012 Sohu.com Inc. All rights reserved.
//

#import "SNSpecialNewsDelegate.h"
#import "SNSpecialNewsModel.h"

#import "SNLiveHeaderView.h"
#import "SNSpecialHeadlineNewsTableCell.h"

#define HEADER_HEIGHT                                   (72.0/2)

@implementation SNSpecialNewsDelegate

- (void)reload {
    
    //Use cache firstly
    [_model load:TTURLRequestCachePolicyLocal more:NO];
    
    BOOL hasNoCache = YES;
    SNSpecialNewsModel *_snModel = (SNSpecialNewsModel *)_model;
    hasNoCache = _snModel.listNews.count == 0;
    
    if (hasNoCache) {
        [_model load:TTURLRequestCachePolicyNetwork more:NO];
    } else {
        //Query server every 5 min
        if ([self shouldReload]) {
            [_model load:TTURLRequestCachePolicyNetwork more:NO]; 
        }
    }
    
}

- (BOOL)shouldReload {

    NSString *termId = ((SNSpecialNewsModel *)_model).termId;
    NSTimeInterval interval = kSpecialNewsRefreshInterval;
    
    NSString *timeKey = [NSString stringWithFormat:@"specialnews_termid_%@_refresh_time", termId];
    id data = [[NSUserDefaults standardUserDefaults] objectForKey:timeKey];
    if (data && [data isKindOfClass:[NSDate class]]) {
        return [(NSDate *)[data dateByAddingTimeInterval:interval] compare:[NSDate date]] < 0;
    } else {
        return YES;
    }
    
}

- (SNSpecialNewsModel *)getSpecialNewsModel {
    return (SNSpecialNewsModel *)_model;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    SNSpecialNewsModel *_snModel = (SNSpecialNewsModel *)_model;
    if (_snModel.newsGroupNames.count <= 0) {
        return 0;
    }
    
    //有焦点新闻
    if (_snModel.headlineNews.count > 0 && section == 0) {
        return 0;
    }
    
    //无焦点新闻，但有新闻要显示为焦点
    NSString *_sectionTitle = [_snModel.newsGroupNames objectAtIndexWithRangeCheck:section]; //0801: fix out of bounds
    NSString *_focusSectionName = NSLocalizedString(SN_String("specialnews_section_name_focus"), @"");
    if (_snModel.headlineNews.count == 0 && section == 0 && [_sectionTitle isEqualToString:_focusSectionName]) {
        return 0;
    }

    if (_sectionTitle && ![@"" isEqualToString:_sectionTitle]) {
        return HEADER_HEIGHT;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SNSpecialNewsModel *_snModel = (SNSpecialNewsModel *)_model;
    if (_snModel.newsGroupNames.count <= 0) {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }

    NSString *_sectionTitle = [_snModel.newsGroupNames objectAtIndex:section];
    if (_sectionTitle && ![@"" isEqualToString:_sectionTitle]) {
        SNLiveHeaderView *_sectionHeaderView = [[SNLiveHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, HEADER_HEIGHT)];
        _sectionHeaderView.titleLabel.text = _sectionTitle;
        return _sectionHeaderView;
    } else {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
}

@end
