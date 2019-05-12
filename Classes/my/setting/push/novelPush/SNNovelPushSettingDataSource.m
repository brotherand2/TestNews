//
//  SNNovelPushSettingDataSource.m
//  sohunews
//
//  Created by H on 2016/11/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNNovelPushSettingDataSource.h"
#import "SNPushSettingTableCell.h"
#import "SNPushSettingModel.h"

@implementation SNNovelPushSettingDataSource
#pragma mark -
#pragma mark TTTableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[SNPushSettingModel instance].settingNovels count];
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
    UIView * blankFooter = [[UIView alloc] init];
    [tableView setTableFooterView:blankFooter];

    if ([SNPushSettingModel instance].settingNovels.count <= 0) {
        return;
    }
    self.items = [NSMutableArray array];
    
    for (NSObject * item in [SNPushSettingModel instance].settingNovels) {
        [self.items addObject:item];
    }
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id)object {
    return [SNPushSettingTableCell class];
}

@end
