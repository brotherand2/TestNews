//
//  AppDelegate+Log.m
//  iPhoneVideo
//
//  Created by LHL on 15/12/21.
//  Copyright © 2015年 SOHU. All rights reserved.
//

#import "AppDelegate+Log.h"
#import "WSMVVideoStatisticManager.h"

@implementation sohunewsAppDelegate (Log)

- (void)logStatType:(SHStatType)statType params:(NSDictionary *)params{
    switch (statType) {
        case SHLoad:{
            WSMVVideoStatisticModel *model = [[[WSMVVideoStatisticModel alloc] init] autorelease];
            if (params && [params isKindOfClass:[NSDictionary class]]) {
                model.channelId = [NSString stringWithFormat:@"%@",params[@"channelId"]];
                model.screen = [NSString stringWithFormat:@"%@",params[@"screen"]];
            }
            [[WSMVVideoStatisticManager sharedIntance] statNewVideoLoad:model];
        }
            break;
            
        case SHPV:{
            WSMVVideoStatisticModel *model = [[[WSMVVideoStatisticModel alloc] init] autorelease];
            if (params && [params isKindOfClass:[NSDictionary class]]) {
                model.channelId = [NSString stringWithFormat:@"%@",params[@"channelId"]];
                model.screen = [NSString stringWithFormat:@"%@",params[@"screen"]];
                model.siteId = [NSString stringWithFormat:@"%@",params[@"siteId"]];
                model.vid = [NSString stringWithFormat:@"%@",params[@"vid"]];
                model.columnId = [NSString stringWithFormat:@"%@",params[@"columnId"]];
                model.recomInfo = [NSString stringWithFormat:@"%@",params[@"recomInfo"]];
            }
            [[WSMVVideoStatisticManager sharedIntance] statNewVideoPV:model];
        }
            break;
            
        case SHVV:{
            WSMVVideoStatisticModel *model = [[[WSMVVideoStatisticModel alloc] init] autorelease];
            if (params && [params isKindOfClass:[NSDictionary class]]) {
                model.channelId = [NSString stringWithFormat:@"%@",params[@"channelId"]];
                model.offline = [NSString stringWithFormat:@"%@",params[@"offline"]];
                model.siteId = [NSString stringWithFormat:@"%@",params[@"siteId"]];
                model.vid = [NSString stringWithFormat:@"%@",params[@"vid"]];
                model.columnId = [NSString stringWithFormat:@"%@",params[@"columnId"]];
                model.page = [NSString stringWithFormat:@"%@",params[@"page"]];
                model.playtimeInSeconds = [params[@"ptime"] doubleValue];
                model.totalTimeInSeconds = [params[@"ttime"] doubleValue];
                model.recomInfo = [NSString stringWithFormat:@"%@",params[@"recomInfo"]];
            }
            [[WSMVVideoStatisticManager sharedIntance] statNewVideoVV:model];
        }
            break;
        case SHNewsVidChange: {
            [[WSMVVideoStatisticManager sharedIntance] pgcVideoStaticWithType:@"end" model:[self getVideoStatisticModel:params]];
        }
            break;
        case SHNewsVidFinish: {
            [[WSMVVideoStatisticManager sharedIntance] pgcVideoStaticWithType:@"tm" model:[self getVideoStatisticModel:params]];
        }
            break;
        default:
            break;
    }
    
    [SNUtility banUniversalLinkOpenInSafari];
}

- (WSMVVideoStatisticModel *)getVideoStatisticModel:(NSDictionary *)params {
    WSMVVideoStatisticModel *model = [[WSMVVideoStatisticModel alloc] init];
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        model.channelId = [params stringValueForKey:@"channelId" defaultValue:@""];
        model.vid = [params stringValueForKey:@"vid" defaultValue:@""];
        model.totalTimeInSeconds = [params[@"newsTime"] doubleValue];
        model.newsId = [params stringValueForKey:@"newsId" defaultValue:@""];
        model.recomInfo = [params stringValueForKey:@"recomInfo" defaultValue:@""];
    }
    return [model autorelease];
}

@end
