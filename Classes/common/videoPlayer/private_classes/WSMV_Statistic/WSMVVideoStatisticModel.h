//
//  WSMVVideoStatisticModel.h
//  sohunews
//
//  Created by handy wang on 10/21/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSMVVideoStatisticModel : NSObject

@property (nonatomic, copy)NSString             *vid;
@property (nonatomic, copy)NSString             *messageId;
@property (nonatomic, copy)NSString             *newsId;
@property (nonatomic, copy)NSString             *subId;
@property (nonatomic, copy)NSString             *channelId;
@property (nonatomic, assign)int                refer;
@property (nonatomic, assign)NSTimeInterval     playtimeInSeconds;
@property (nonatomic, assign)NSTimeInterval     totalTimeInSeconds;
@property (nonatomic, assign)BOOL               succeededToFFL;
@property (nonatomic, copy)NSString             *siteId;
@property (nonatomic, copy)NSString             *columnId;
@property (nonatomic, weak)NSString           *offline;
@property (nonatomic, weak)NSString           *page;
@property (nonatomic, weak)NSString           *screen;
@property (nonatomic, copy)NSString           *recomInfo;

#pragma mark - Public
- (NSString *)networkReachability;
@end
