//
//  SNNewsNotificationManager.h
//  sohunews
//
//  Created by lhp on 12/18/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNNewsNotificationManager : NSObject {
    
    NSString *channelId;
    NSString *message;
    int time;
}

@property(nonatomic,strong)NSString *channelId;
@property(nonatomic,strong)NSString *message;
@property(nonatomic,assign)int time;

+ (SNNewsNotificationManager *)sharedInstance;
- (void)start;
- (void)invalideteTimer;
- (BOOL)isHomeChannel;

@end
