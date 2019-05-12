//
//  SNBubbleBadgeObject.h
//  sohunews
//
//  Created by weibin cheng on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNBubbleNumberManager : NSObject

@property (nonatomic, assign) int ppfollowing;
@property (nonatomic, assign) int ppfollowed;
@property (nonatomic, assign) int ppreply;
@property (nonatomic, assign) int ppnotify;
@property (nonatomic, strong) NSDictionary* subMessage;
@property (nonatomic, assign) int feedback;
@property (nonatomic, assign) int livemsg;
@property (nonatomic, assign) int followingact;

+(SNBubbleNumberManager*)shareInstance;

-(void)postBubbleBadgeChangeNotification;

-(int)getTotalBadgeCount;
- (int)getSubMessageCount;

-(void)setNotifyCount:(int)count;
-(void)setReplyCount:(int)count;
-(void)resetFollowing;
-(void)resetFollowed;
-(void)resetReply;
-(void)resetNotify;
-(void)resetSubMessage:(NSString*)subId;
-(void)resetFollowingAct;
-(void)resetAll;


@end
