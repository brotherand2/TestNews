//
//  SNPushSettingDelegate.m
//  sohunews
//
//  Created by 李 雪 on 11-7-1.
//  update by sampanli
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNPushSettingDelegate.h"
#import "SNPushSettingItem.h"
#import "SNPushSettingTableItem.h"
#import "SNPushSettingModel.h"
#import "SNPushSettingTableCell.h"
#import "SNSLib.h"

@implementation SNPushSettingDelegate
@synthesize pushSettingController=_pushSettingController;
@synthesize model = _model;

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	id curCell = [tableView cellForRowAtIndexPath:indexPath];
	if ([curCell isKindOfClass:[SNPushSettingTableItem class]]) {
		//SNPushSettingItem *item = [self.model.settingSections objectAtIndex:indexPath.row];
		//打开or关闭通知
		
	}
	else {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
        if ([curCell isKindOfClass:[SNPushSettingTableCell class]]) {
            if (((SNPushSettingTableCell *)curCell).isNovelPushSetting) {
                TTURLAction *action = [[TTURLAction actionWithURLPath:@"tt://novelPushSeting"] applyAnimated:YES];
                [[TTNavigator navigator] openURLAction:action];
                return;
            }
            else if (((SNPushSettingTableCell *)curCell).isSNSPushSetting) {
                SNNavigationController *naviController = [TTNavigator navigator].topViewController.flipboardNavigationController;
                [naviController pushViewController:[SNSLib remoteNotificationSettingController] animated:YES];
                return;
            }
        }
        if (PushSettingSwith) {
            [curCell openPushViewWithIndex:indexPath.row];
        }
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SNPushSettingTableCell cellHeight];
}
-(void)dealloc
{
}

@end
