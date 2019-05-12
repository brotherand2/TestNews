//
//  SNBubbleBadgeObject.m
//  sohunews
//
//  Created by weibin cheng on 13-9-5.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNBubbleBadgeObject.h"
#import "SNCheckManager.h"

static SNBubbleNumberManager* _snBubbleObject = nil;

@implementation SNBubbleNumberManager
@synthesize ppfollowed = _ppfollowed;
@synthesize ppfollowing = _ppfollowing;
@synthesize ppnotify = _ppnotify;
@synthesize ppreply = _ppreply;
@synthesize subMessage = _subMessage;
@synthesize feedback = _feedback;
@synthesize followingact = _followingact;
+(SNBubbleNumberManager*)shareInstance
{
    @synchronized(self)
    {
        if(_snBubbleObject == nil)
        {
            _snBubbleObject = [[SNBubbleNumberManager alloc] init];
        }
    }
    return _snBubbleObject;
}

-(void)postBubbleBadgeChangeNotification
{
    [SNNotificationManager postNotificationName:kSNBubbleBadgeChangeNotification object:nil];
}


-(int)getTotalBadgeCount
{
    
//    int total = _feedback;
//    if([SNCheckManager checkNewVersion])
//        total += 1;
//    total += fabs(_ppreply) + fabs(_ppfollowing) + fabs(_ppfollowed) + fabs(_ppnotify);
    int total = fabs(_ppfollowing) + fabs(_ppfollowed);
//    if(_subMessage)
//    {
//        NSArray* allValue = [_subMessage allValues];
//        for(NSString* value in allValue)
//        {
//            total += [value intValue];
//        }
//    }
    return total;
}

- (int)getSubMessageCount {
    int total = 0;
    if(_subMessage)
    {
        NSArray* allValue = [_subMessage allValues];
        for(NSString* value in allValue)
        {
            total += [value intValue];
        }
    }
    return total;
}

-(void)resetFollowing
{
    self.ppfollowing = 0;
    [self postBubbleBadgeChangeNotification];
}

-(void)resetFollowed
{
    self.ppfollowed = 0;
    [self postBubbleBadgeChangeNotification];
}

-(void)resetReply
{
    self.ppreply = 0;
    [self postBubbleBadgeChangeNotification];
}

-(void)resetNotify
{
    self.ppnotify = 0;
    [self postBubbleBadgeChangeNotification];
}

-(void)resetSubMessage:(NSString*)subId
{
    if(subId.length > 0)
    {
        [self.subMessage setValue:[NSString stringWithFormat:@"%d", 0] forKey:subId];
    }
}
-(void)resetFollowingAct
{
    self.followingact = 0;
    [self postBubbleBadgeChangeNotification];
}
-(void)setFeedback:(int)feedback
{
    _feedback = feedback;
    //[SNBubbleNumberManager postBubbleBadgeChangeNotification];
    [self performSelectorOnMainThread:@selector(postBubbleBadgeChangeNotification) withObject:nil waitUntilDone:NO];
}

-(void)resetAll
{
    self.feedback = 0;
    self.ppfollowed = 0;
    self.ppfollowing = 0;
    self.ppnotify = 0;
    self.ppreply = 0;
    self.subMessage = nil;
    self.livemsg = 0;
    self.followingact = 0;
    [self postBubbleBadgeChangeNotification];
}

-(void)setNotifyCount:(int)count
{
    self.ppnotify = count;
    [self postBubbleBadgeChangeNotification];
}
-(void)setReplyCount:(int)count
{
    self.ppreply = count;
    [self postBubbleBadgeChangeNotification];
}
@end
