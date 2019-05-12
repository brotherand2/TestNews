//
//  SNNovelPushSettingDelegate.m
//  sohunews
//
//  Created by H on 2016/11/9.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNNovelPushSettingDelegate.h"
#import "SNPushSettingTableCell.h"

@implementation SNNovelPushSettingDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{    
    
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SNPushSettingTableCell cellHeight];
}

@end
