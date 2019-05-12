//
//  SNUserTrack.m
//  sohunews
//
//  Created by jojo on 13-12-25.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNUserTrack.h"

@implementation SNUserTrack
@synthesize link2 = _link2;
@synthesize page;

+ (SNUserTrack *)trackWithPage:(SNCCPVPage)page link2:(NSString *)link2 {
    SNUserTrack *aTrack = [[SNUserTrack alloc] init];
    aTrack.page = page;
    aTrack.link2 = link2;
    
    return aTrack;
}

- (void)dealloc {
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SNUserTrack *otherTrack = (SNUserTrack *)object;
    
    return self.page == otherTrack.page;
}

- (NSUInteger)hash {
    return (NSUInteger)self.page;
}

- (NSString *)toFormatString {
    if (self.link2 && ( ![SNAPI isWebURL:self.link2])) {
        self.link2 = [self.link2 stringByReplacingOccurrencesOfString:@".xml" withString:@""];
        self.link2 = [self.link2 stringByReplacingOccurrencesOfString:@"&" withString:@"!!"];
        self.link2 = [self.link2 stringByReplacingOccurrencesOfString:@"," withString:@"@"];
        
        return [NSString stringWithFormat:@"%d_%@", self.page, [self.link2 URLEncodedString]];
    }
    else {
        return [NSString stringWithFormat:@"%d", self.page];
    }
}

@end
