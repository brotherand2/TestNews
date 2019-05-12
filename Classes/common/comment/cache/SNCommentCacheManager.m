//
//  SNCommentCacheManager.m
//  sohunews
//
//  Created by jialei on 14-4-1.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import "SNCommentCacheManager.h"
#import "SNCommentConfigs.h"

@implementation SNCommentCacheManager

- (id)init
{
    if (self = [super init]) {
        [SNNotificationManager addObserver:self
                                                 selector:@selector(cacheComment:)
                                                     name:NotificationCommentCache
                                                   object:nil];
        
        [SNNotificationManager addObserver:self
                                                 selector:@selector(cacheCommentClean:)
                                                     name:NotificationCommentCacheClean
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [SNNotificationManager removeObserver:self];
    
}

- (void)cacheComment:(NSNotification *)notification
{
    SNSendCommentObject *obj = (SNSendCommentObject *)[notification object];
    self.cmtObj = obj;
}

- (void)cacheCommentClean:(NSNotification *)notification
{
    self.cmtObj = nil;
}

- (void)setCacheValue:(SNSendCommentObject *)obj
{
    obj.cmtImgae = self.cmtObj.cmtImgae;
    obj.cmtImagePath = self.cmtObj.cmtImagePath;
    obj.cmtAudioDuration = self.cmtObj.cmtAudioDuration;
    obj.cmtAudioPath = self.cmtObj.cmtAudioPath;
    obj.cmtText = self.cmtObj.cmtText;
}

@end
