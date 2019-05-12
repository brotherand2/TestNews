//
//  SNNewsContentWorker.m
//  sohunews
//
//  Created by handy wang on 1/9/13.
//  Copyright (c) 2013 Sohu.com Inc. All rights reserved.
//

#import "SNNewsContentWorker.h"
#import "SNNewsChannelModule.h"

@implementation SNNewsContentWorkerNews
@synthesize newsID = _newsID;
@synthesize termID = _termID;
@synthesize newsTitle = _newsTitle;
@synthesize newsType = _newsType;

- (id)initWithNewsID:(NSString *)newsID newsTitle:(NSString *)newsTitle newsType:(NSString *)newsType {
    if (self = [super init]) {
        _newsID = [newsID copy];
        _newsTitle = [newsTitle copy];
        _newsType = [newsType copy];
    }
    return self;
}

- (id)initWithNewsID:(NSString *)newsID termID:(NSString *)termID newsTitle:(NSString *)newsTitle newsType:(NSString *)newsType {
    if (self = [self initWithNewsID:newsID newsTitle:newsTitle newsType:newsType]) {
        _termID = [termID copy];
    }
    return self;
}

- (void)dealloc {
     //(_newsID);
     //(_termID);
     //(_newsTitle);
     //(_newsType);
}

- (NSString *)description {
    NSMutableString *_descStr = [NSMutableString string];
    [_descStr appendFormat:@"SNNewsContentWorkerNews:{newsID:%@, newsTitle:%@, newsType:%@}", _newsID, _newsTitle, _newsType];
    return _descStr;
}

@end


@implementation SNNewsContentWorker
@synthesize delegate = _myDelegate;
@synthesize isCanceled = _isCanceled;

#pragma mark - Life cycle

- (id)initWithDelegate:(id)delegateParam {
    if (self = [super init]) {
        _myDelegate = delegateParam;
        _newsArray = [NSMutableArray array];
    }
    return self;
}

- (void)cancel {
    _isCanceled = YES;
}

-(NSNumber*)isCancel
{
    return [NSNumber numberWithBool:_isCanceled];
}

- (void)dealloc {
    _isCanceled = NO;
    
     //(_newsArray);
    _myDelegate = nil;
    
}

#pragma mark - Public methods

- (void)appenNewsID:(NSString *)newsID newsTitle:(NSString *)newsTitle newsType:(NSString *)newsType {
    SNNewsContentWorkerNews *_news = [[SNNewsContentWorkerNews alloc] initWithNewsID:newsID newsTitle:newsTitle newsType:newsType];
    [_newsArray addObject:_news];
     //(_news);
}

- (void)appenNewsID:(NSString *)newsID termID:(NSString *)termID newsTitle:(NSString *)newsTitle newsType:(NSString *)newsType {
    SNNewsContentWorkerNews *_news = [[SNNewsContentWorkerNews alloc] initWithNewsID:newsID termID:termID newsTitle:newsTitle newsType:newsType];
    [_newsArray addObject:_news];
     //(_news);
}

- (void)startInThread {
    [self notifyStartingWorking];
    
    //--------------------
    /**
     * This is implementation by default for SNNewsChannelModule running well.
     * Actually, you should callback SNNewsChannelModule by one of SNNewsContentWorkerDelegate methods(didStartWorking, didFinishWorking, didFailedToWork) depending on your actual job's result.
     */
    [self endInMainThread];
    //--------------------
}

- (void)endInMainThread {
    //进行下一个worker
    if ([_myDelegate respondsToSelector:@selector(didFinishWorking:)]) {
        [_myDelegate didFinishWorking:self];
    }
    _myDelegate = nil;
}

//This method neednt override in sub class. Otherwise, override this method at your own risk.
- (void)notifyStartingWorking {
    SNDebugLog(@"===INFO: Main thread:%d, %@ is working...", [NSThread isMainThread], NSStringFromClass(self.class));
    if ([_myDelegate respondsToSelector:@selector(didStartWorking:)]) {
        [_myDelegate didStartWorking:self];
    }
}

- (NSString *)channelID {
    if ([_myDelegate isKindOfClass:[SNNewsChannelModule class]]) {
        return ((SNNewsChannelModule *)_myDelegate).channelID;
    } else {
        return nil;
    }
}

@end
