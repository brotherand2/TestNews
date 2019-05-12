//
//  SNWeiboSettingDelegate.m
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNWeiboSettingDelegate.h"
#import "SNWeiboSettingTableItem.h"


@implementation SNWeiboSettingDelegate
@synthesize weiboSettingController=_weiboSettingController;
@synthesize model=_model;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 106/2;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	id curCell = [tableView cellForRowAtIndexPath:indexPath];
	if ([curCell isKindOfClass:[SNWeiboSettingTableItem class]]) {
		//
	}
	else {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

-(void)dealloc
{
	 //(_model);
}

@end
