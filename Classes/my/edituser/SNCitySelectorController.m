//
//  SNCitySelectorController.m
//  sohunews
//
//  Created by Diaochunmeng on 12-12-21.
//  Copyright (c) 2012年 Sohu.com Inc. All rights reserved.
//

#import "SNCitySelectorController.h"

@interface SNCitySelectorController ()

@end

@implementation SNCitySelectorController
@synthesize _citySelectorControllerDelegate;

-(id)init
{
    if(self=[super initWithNavigatorURL:nil query:nil])
	{
	}
	return self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if([_citySelectorControllerDelegate respondsToSelector:@selector(notifyCitySelectedViewDisappear)])
        [_citySelectorControllerDelegate notifyCitySelectedViewDisappear];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary* selectiCityInfo  = [super cityInfoDicByIndexpath:indexPath];
    NSString* city = (NSString*)[selectiCityInfo objectForKey:@"city"];
    NSString* province = (NSString*)[selectiCityInfo objectForKey:@"province"];
    if(city!=nil && [city length]>0 && province!=nil && [province length]>0 && [_citySelectorControllerDelegate respondsToSelector:@selector(notifyCitySelected:province:)])
        [_citySelectorControllerDelegate notifyCitySelected:city province:province];
    
    //pop
    [self.flipboardNavigationController popViewControllerAnimated:YES];
}
@end
