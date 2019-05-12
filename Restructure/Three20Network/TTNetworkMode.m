//
//  TTNetworkMode.m
//  Three20Network
//
//  Created by guoyalun on 7/31/13.
//
//

#import "TTNetworkMode.h"
#import "Reachability.h"

@implementation TTNetworkMode

+ (BOOL)isWWANmode
{
    Reachability *_internetReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [_internetReach currentReachabilityStatus];
    if (ReachableViaWWAN == netStatus ||
        ReachableVia2G == netStatus ||
        ReachableVia3G == netStatus ||
        ReachableVia4G == netStatus ) {
        return YES;
    }
    return NO;
}


@end
