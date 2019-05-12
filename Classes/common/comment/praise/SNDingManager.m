//
//  SNDingManager.m
//  sohunews
//
//  Created by lhp on 7/24/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNDingManager.h"

@interface SNDingManager ()

@end

@implementation SNDingManager

+ (SNDingManager *)sharedInstance {
    static SNDingManager *_sharedInstance = nil;
    @synchronized(self) {
        if (!_sharedInstance) {
            _sharedInstance = [[SNDingManager alloc] init];
        }
    }
    return _sharedInstance;
}

- (id)init{
    if (self = [super init]) {
        dingCommentsDic = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return self;
}

- (void)addCommentId:(NSString *) commentId {
    if (commentId) {
        [dingCommentsDic setObject:[NSNumber numberWithBool:YES] forKey:commentId];
    }
}

- (BOOL)isDingForCommentId:(NSString *) commentId {
    if (commentId) {
        BOOL isDing;
        NSNumber *dingNumber = [dingCommentsDic objectForKey:commentId];
        if (dingNumber) {
            isDing = YES;
        }else{
            isDing = NO;
        }
        return isDing;
    }else{
        return NO;
    }
}

- (void)dealloc{
     //(dingCommentsDic);
}

@end
