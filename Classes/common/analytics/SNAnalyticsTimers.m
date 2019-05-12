//
//  SNAnalyticsTimers.m
//  sohunews
//
//  Created by jojo on 13-11-7.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNAnalyticsTimers.h"

@implementation SNAnalyticsTimer
@synthesize timeDiff = _timeDiff;
@synthesize page;
@synthesize isFired = _isFired;

+ (id)timer {
    return [[[self class] alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        _weakTime = [NSDate date];
    }
    return self;
}

- (void)fire {
    if (_isFired) {
        return;
    }
    
    _fireTime = [NSDate date];
    _timeDiff = MAX(lround([_fireTime timeIntervalSinceDate:_weakTime]), 1);
    _isFired = YES;
}

- (void)dealloc {
}

@end

//////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////

@implementation SNAnalyticsRollingSlideTimer
@synthesize slideCount;
@synthesize channelId = _channelId;

- (void)fire {
    if (self.isFired) {
        return;
    }
    
    [super fire];
}

- (void)dealloc {
}

@end

@implementation SNAnalyticsNewsReadTimer
@synthesize newsId = _newsId;
@synthesize isEnd = _isEnd;
@synthesize isFavour = _isFavour;
@synthesize subId = _subId;
@synthesize channelId = _channelId;
@synthesize groudId = _groudId;
@synthesize newsfrom = _newsfrom;
@synthesize recomInfo = _recomInfo;

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)fire {
    if (self.isFired) {
        return;
    }
    
    [super fire];
    
    // do upload action
    [self report];
}

- (void)report {
    // 新闻正文阅读时常统计
    NSString *reqUrl = [NSString stringWithFormat:kAnalyticsUrlNewsContentRead, self.page, self.timeDiff, self.isEnd ? @"true" : @"false"];
    reqUrl = [reqUrl stringByAppendingFormat:@"&isHot=%d&newsId=%@&gid=%@&channelId=%@&subId=%@&newsfrom=%@", self.isFavour, self.newsId, self.groudId, self.channelId, self.subId, self.newsfrom];
    if (self.recomInfo && [self.recomInfo length] > 0) {
       reqUrl = [reqUrl stringByAppendingFormat:@"&recomInfo=%@", self.recomInfo];
    }
    [SNNewsReport reportADotGif:reqUrl];
    
    NSString *pvUrl = [NSString stringWithFormat:@"_act=pv&page=16_%@",[self.link URLEncodedString]];
    pvUrl = [pvUrl stringByAppendingFormat:@"&recomInfo=%@&newsfrom=%@", self.recomInfo, self.newsfrom];
    [SNNewsReport reportADotGif:pvUrl];
}

- (void)reportTM {
    NSString *reqUrl = [NSString stringWithFormat:kAnalyticsUrlNewsContentRead, self.page, self.timeDiff, self.isEnd ? @"true" : @"false"];
    reqUrl = [reqUrl stringByAppendingFormat:@"&isHot=%d&newsId=%@&gid=%@&channelId=%@&subId=%@&newsfrom=%@", self.isFavour, self.newsId, self.groudId, self.channelId, self.subId, self.newsfrom];
    if (self.recomInfo && [self.recomInfo length] > 0) {
        reqUrl = [reqUrl stringByAppendingFormat:@"&recomInfo=%@", self.recomInfo];
    }
    [SNNewsReport reportADotGif:reqUrl];
}

- (void)dealloc {

}

@end
