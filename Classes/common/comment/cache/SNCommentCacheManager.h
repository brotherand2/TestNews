//
//  SNCommentCacheManager.h
//  sohunews
//
//  Created by jialei on 14-4-1.
//  Copyright (c) 2014年 Sohu.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNSendCommentObject.h"

@interface SNCommentCacheManager : NSObject
{
}

@property (nonatomic, strong)SNSendCommentObject *cmtObj;

- (void)setCacheValue:(SNSendCommentObject *)obj;

@end
