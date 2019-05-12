//
//  NotificationController.m
//  sohunews WatchKit App Extension
//
//  Created by iEvil on 12/4/15.
//  Copyright © 2015 Sohu.com. All rights reserved.
//

#import "NotificationController.h"
#import "SNWDefine.h"

@interface NotificationController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *customLabel;

@property (copy, nonatomic) NSString *link;
@end


@implementation NotificationController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    [self sendHandoff];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
    [self stopHandoff];
}

/*
- (void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    // This method is called when a local notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}
*/

- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    // This method is called when a remote notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
    //
    // After populating your dynamic notification interface call the completion block.
    id apsDic = remoteNotification[@"aps"];
    
    NSString *alertStr = nil;
    if (apsDic) {
        if ([apsDic isKindOfClass:[NSDictionary class]]) {
            if ([apsDic[@"alert"] isKindOfClass:[NSDictionary class]]) {
                alertStr = apsDic[@"alert"][@"body"];
            } else if ([apsDic[@"alert"] isKindOfClass:[NSString class]]) {
                alertStr = apsDic[@"alert"];
            }
        } else if ([apsDic isKindOfClass:[NSString class]]) {
            alertStr = apsDic;
        }
    }
    
    [self.customLabel setText:alertStr];
    
    self.link = remoteNotification[@"url"];
    
    completionHandler(WKUserNotificationInterfaceTypeCustom);
}

- (void)sendHandoff {
    if (_link.length > 0) {
        [self updateUserActivity:snw_handoff_view_detail_identifier userInfo:@{snw_handoff_news_url : _link, snw_handoff_version : snw_handoff_current_version} webpageURL:nil];
    }
}

- (void)stopHandoff {
    [self invalidateUserActivity];
}

@end
