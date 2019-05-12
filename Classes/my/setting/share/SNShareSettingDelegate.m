//
//  SNShareSettingDelegate.m
//  sohunews
//
//  Created by 李 雪 on 11-7-11.
//  Copyright 2011 Sohu.com Inc. All rights reserved.
//

#import "SNShareSettingDelegate.h"
#import "SNShareSettingTableItem.h"


@implementation SNShareSettingDelegate
@synthesize weiboSettingController=_weiboSettingController;
@synthesize model=_model;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 106/2;
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	id curCell = [tableView cellForRowAtIndexPath:indexPath];
	if ([curCell isKindOfClass:[SNShareSettingTableItem class]]) {
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
