//
//  SNMessage.m
//  sohunews
//
//  Created by chenhong on 13-12-4.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNMessage.h"

@implementation SNMessage

- (id)initWithMsgId:(NSString *)msgId
               body:(NSString *)body
          timestamp:(NSString *)ts
{
    self = [super init];
    if (self) {
        self.msgId = msgId;
        self.body = body;
        self.timestamp = ts;
    }
    return self;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"\nmsgId = %@\nbody=%@\nts=%@", _msgId, _body, _timestamp];
}

@end
