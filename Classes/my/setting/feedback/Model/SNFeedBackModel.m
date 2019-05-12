//
//  SNFeedBackModel.m
//  sohunews
//
//  Created by 李腾 on 2016/10/16.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNFeedBackModel.h"

@implementation SNFeedBackModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.fbID forKey:@"id"];
    [aCoder encodeObject:self.date forKey:@"date"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.fbID = [aDecoder decodeObjectForKey:@"id"];
        self.date = [aDecoder decodeObjectForKey:@"date"];

    }
    return self;
}


@end
