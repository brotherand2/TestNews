//
//  SNLiveNewsTableViewDelegate.m
//  sohunews
//
//  Created by chenhong on 14-3-11.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNLiveNewsTableViewDelegate.h"
#import "SNLiveModel.h"
#import "SNLiveHeaderView.h"

#define HEADER_HEIGHT                   (72.0 / 2)

@implementation SNLiveNewsTableViewDelegate

#pragma mark - override super methods
- (BOOL)isModelEmpty {
    SNLiveModel *livingModel = (SNLiveModel *)_model;
    BOOL hasNoCache = ((livingModel.livingGamesToday.count + livingModel.livingGamesForecast.count) == 0);
    if (livingModel.needRefreshOnStart) {
        hasNoCache = YES;
        //TODO: remove? should be in loadNetWork
        livingModel.needRefreshOnStart = NO;
    }
    return hasNoCache;
}

- (BOOL)shouldReloadLocalWithChannelId:(NSString *)channelId {
    SNLiveModel *livingModel = (SNLiveModel *)_model;
    
    if (![livingModel.channelID isEqualToString:channelId]) {
        return YES;
    }
    else if (livingModel.livingGamesToday.count + livingModel.livingGamesForecast.count == 0) {
        return YES;
    }
    return NO;
}

- (void)loadNetwork {
    [super loadNetwork];
    SNLiveModel *livingModel = (SNLiveModel *)_model;
    livingModel.needRefreshOnStart = NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    SNLiveModel *livigModel = (SNLiveModel *)_model;
    id sectionTitle = [livigModel.sectionsArray objectAtIndex:section];
    
    // v5.2.1 数据结构有变化
    if ([sectionTitle isKindOfClass:[NSDictionary class]]) {
        sectionTitle = ((NSDictionary *)sectionTitle)[@"name"];
    }
    
    NSArray *itemArray = livigModel.items[section];
    
    if ([sectionTitle length] > 0 && [itemArray count] > 0) {
        return HEADER_HEIGHT;
    } else {
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SNLiveModel *livigModel = (SNLiveModel *)_model;
    
    
    id sectionTitleDict = [livigModel.sectionsArray objectAtIndex:section];
    
    NSString *sectionTitle = sectionTitleDict;
    if ([sectionTitleDict isKindOfClass:[NSDictionary class]]) {
        sectionTitle = sectionTitleDict[@"name"];
    }

    if ([sectionTitle length] > 0) {
        SNLiveHeaderView *headerView = [[SNLiveHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, HEADER_HEIGHT)];
        headerView.titleLabel.text = sectionTitle;
        
        // 增加“更多”的点击操作 v5.2.2
        if ([sectionTitleDict isKindOfClass:[NSDictionary class]]) {
            headerView.dataDict = sectionTitleDict;
        } else {
            headerView.dataDict = nil;
        }
        
        [headerView setMoreActionBlock:^(NSDictionary *dict) {
            TTURLAction *urlAction = [[[TTURLAction actionWithURLPath:@"tt://liveMore"] applyAnimated:YES] applyQuery:dict];
            [[TTNavigator navigator] openURLAction:urlAction];
        }];
        
        return headerView;
    }
    else {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
}

#pragma mark -

@end
