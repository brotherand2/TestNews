//
//  SNMyMessage.m
//  sohunews
//
//  Created by jialei on 13-7-18.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNMyMessage.h"

@implementation SNMyMessage

@synthesize content;
@synthesize commentType;
@synthesize fromLink;
@synthesize shareId;
@synthesize myContent;
@synthesize nickName;
@synthesize msgId;
@synthesize gender;
@synthesize pid;
@synthesize headUrl;
@synthesize ctime;
@synthesize city;
@synthesize shareObj;
@synthesize cmtStatus;
@synthesize cmtHint;
@synthesize isCommentOpen;
@synthesize isCommentFloorOpen;


- (id)init
{
    self = [super init];
    if (self)
    {
        self.isCommentFloorOpen = NO;
        self.isCommentOpen = NO;
    }
    return self;
}


@end


@implementation SNMyMessageItem


-(void)dealloc {
     //(_socialMsg);
    
}


@end
