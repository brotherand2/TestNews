//
//  SNAppConfigTabBar.m
//  sohunews
//
//  Created by Scarlett on 16/8/5.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNAppConfigTabBar.h"
#import "SNAppConfigConst.h"

@implementation SNAppConfigTabBar

- (void)updateWithDict:(NSDictionary *)dict {
    NSDictionary *tabDict = [dict objectForKey:kBottomTabBarConfig];
    
    NSDictionary *newsDict = [tabDict objectForKey:@"news"];
    NSDictionary *videoDict = [tabDict objectForKey:@"video"];
    NSDictionary *snsDict = [tabDict objectForKey:@"sns"];
    NSDictionary *myselfDict = [tabDict objectForKey:@"myself"];
    
    NSString *newsName = [newsDict stringValueForKey:@"name" defaultValue:@""];
    NSString *videoName = [videoDict stringValueForKey:@"name" defaultValue:@""];
    NSString *snsName = [snsDict stringValueForKey:@"name" defaultValue:@""];
    NSString *myselfName = [myselfDict stringValueForKey:@"name" defaultValue:@""];
    
    self.tabBarTextArray = [[NSArray alloc] initWithObjects:newsName, videoName, snsName, myselfName, nil];
}

- (void)dealloc {
}

@end
