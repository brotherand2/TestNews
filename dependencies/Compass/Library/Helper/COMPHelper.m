//
//  COMPHelper.m
//  Compass
//
//  Created by 李耀忠 on 26/09/2017.
//  Copyright © 2017 Beijing Sohu New Media Information Technology Co. Ltd. All rights reserved.
//

#import "COMPHelper.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

//static CGPoint point;

@implementation COMPHelper

//+ (void)load {
//    CGSize size = [UIScreen mainScreen].bounds.size;
//    point = CGPointMake(size.width / 2, size.height / 2);
//}

+ (int64_t)timestampInMiniseconds {
    int64_t ts = (int64_t)([[NSDate date] timeIntervalSince1970] * 1000);
    return ts;
}

//+ (UIViewController*)topMostViewController {
//    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
//}
//
//+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)viewController {
//    if ([viewController isKindOfClass:[UITabBarController class]]) {
//        UITabBarController* tabBarController = (UITabBarController*)viewController;
//        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
//    } else if ([viewController isKindOfClass:[UINavigationController class]]) {
//        UINavigationController* navContObj = (UINavigationController*)viewController;
//        return [self topViewControllerWithRootViewController:navContObj.visibleViewController];
//    } else if (viewController.presentedViewController && !viewController.presentedViewController.isBeingDismissed) {
//        UIViewController* presentedViewController = viewController.presentedViewController;
//        return [self topViewControllerWithRootViewController:presentedViewController];
//    } else if (viewController.childViewControllers.count > 0) {
//        UIView *hitTestView = [viewController.view hitTest:point withEvent:nil];
//        id nextResponder = hitTestView.nextResponder;
//        while (nextResponder != viewController) {
//            if ([nextResponder isKindOfClass:[UIViewController class]])
//            {
//                return [self topViewControllerWithRootViewController:(UIViewController *)nextResponder];
//            }
//
//            nextResponder = [nextResponder nextResponder];
//        }
//        return viewController;
//    } else {
//        return viewController;
//    }
//}

#pragma mark - 获取设备当前网络IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;

    NSDictionary *addresses = [self getIPAddresses];

    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";

    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];

    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];

        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];

    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (NSString *)currentDateString {
    NSDateFormatter *formtter = [[NSDateFormatter alloc] init];
    formtter.dateFormat = @"YYYY-MM-dd";

    NSString *date = [formtter stringFromDate:[NSDate date]];
    return date;
}

@end
