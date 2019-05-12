//
//  SNUserTrackRecorder.m
//  sohunews
//
//  Created by jojo on 13-12-25.
//  Copyright (c) 2013年 Sohu.com. All rights reserved.
//

#import "SNUserTrackRecorder.h"

@interface SNUserTrackRecorder ()

@property (nonatomic, strong) NSMutableDictionary *cachedTrackInfo; // key : class name --> value : memory address string

@end

@implementation SNUserTrackRecorder
@synthesize pushPage = _pushPage;
@synthesize loadingPage = _loadingPage;
@synthesize cachedTrackInfo = _cachedTrackInfo;

+ (SNUserTrackRecorder *)sharedRecorder {
    static SNUserTrackRecorder *_sInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sInstance = [[self alloc] init];
    });
    return _sInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [SNNotificationManager addObserver:self
                                                 selector:@selector(onNavigationDidPopViewControllerNotification:)
                                                     name:kPopViewControllerNotification
                                                   object:nil];
    }
    return self;
}

- (NSMutableArray *)tracksWithViewControllers:(NSArray *)controllers {
    NSMutableArray *tracks = [NSMutableArray array];
    if (self.pushPage) {
        [tracks addObject:self.pushPage];
    }
    if (self.loadingPage) {
        [tracks addObject:self.loadingPage];
    }
    for (UIViewController *vc in controllers) {
        if ([vc isKindOfClass:[UIViewController class]]) {
            SNCCPVPage page = [vc currentPage];
            NSString *link = [vc currentOpenLink2Url];
            if (page > SNCCPVPageStart) {
                SNUserTrack *aTack = [SNUserTrack trackWithPage:page link2:link];
                [tracks addObject:aTack];
            }
        }
    }
    return tracks;
}

- (NSMutableDictionary *)cachedTrackInfo {
    if (!_cachedTrackInfo) {
        _cachedTrackInfo = [[NSMutableDictionary alloc] init];
    }
    return _cachedTrackInfo;
}

- (BOOL)shouldReportTrackForObj:(id)obj {
    NSString *cls = NSStringFromClass([obj class]);
    NSString *ads = [self.cachedTrackInfo stringValueForKey:cls defaultValue:nil];
    if (!ads) {
        return YES;
    }
    
    return ![ads isEqualToString:[NSString stringWithFormat:@"%p", (void *)obj]];
}

- (void)cacheAlreadyReportedTrackForObj:(id)obj {
    NSString *cls = NSStringFromClass([obj class]);
    NSString *ads = [NSString stringWithFormat:@"%p", (void *)obj];
    if (cls && ads) {
        [self.cachedTrackInfo setObject:ads forKey:cls];
    }
}

- (void)clearCachedTrackInfoForObj:(id)obj {
    NSString *cls = NSStringFromClass([obj class]);
    if ([self.cachedTrackInfo objectForKey:cls]) {
        [self.cachedTrackInfo removeObjectForKey:cls];
    }
}

- (void)dealloc {
    [SNNotificationManager removeObserver:self];
}

#pragma mark - actions

- (void)onNavigationDidPopViewControllerNotification:(id)sender {
    self.loadingPage = nil;
    self.pushPage = nil;
}

@end

@implementation UIViewController (userTracks)

- (BOOL)reportPVAnalyzeWithCurrentNavigationController:(SNNavigationController *)navi dictInfo:(NSDictionary *)dictInfo{
    BOOL bRet = NO;
    if ([[SNUserTrackRecorder sharedRecorder] shouldReportTrackForObj:self]) {
        [[SNUserTrackRecorder sharedRecorder] cacheAlreadyReportedTrackForObj:self];
        
        NSMutableArray *tracks = [[SNUserTrackRecorder sharedRecorder] tracksWithViewControllers:navi.viewControllers];
        SNUserTrack *curPage = [SNUserTrack trackWithPage:[self currentPage] link2:[self currentOpenLink2Url]];
        if ([tracks count] > 0) {
            [tracks removeObject:curPage];
        }
        NSString *paramsString = [NSString stringWithFormat:@"_act=pv&page=%@&track=%@", [curPage toFormatString], [tracks toTracksString]];
        if (dictInfo) {
            paramsString = [dictInfo appendParamToUrlString:paramsString];
        }
        [SNNewsReport reportADotGifWithTrack:paramsString];
    }
    return bRet;
}

- (BOOL)reportPVAnalyzeWithCurrentNavigationController:(SNNavigationController *)navi {
    BOOL bRet = NO;
    if ([[SNUserTrackRecorder sharedRecorder] shouldReportTrackForObj:self]) {
        [[SNUserTrackRecorder sharedRecorder] cacheAlreadyReportedTrackForObj:self];
        
        NSMutableArray *tracks = [[SNUserTrackRecorder sharedRecorder] tracksWithViewControllers:navi.viewControllers];
        SNUserTrack *curPage = [SNUserTrack trackWithPage:[self currentPage] link2:[self currentOpenLink2Url]];
        if ([tracks count] > 0) {
            [tracks removeObject:curPage];
        }
        NSString *paramsString = [NSString stringWithFormat:@"_act=pv&page=%@&track=%@", [curPage toFormatString], [tracks toTracksString]];
        [SNNewsReport reportADotGifWithTrack:paramsString];
    }
    return bRet;
}

- (SNCCPVPage)currentPage {
    return SNCCPVPageStart;
}

- (NSString *)currentOpenLink2Url {
    return nil;
}

@end

@implementation NSArray (userTracks)

- (NSString *)toTracksString {
    NSMutableString *str = [NSMutableString stringWithString:@""];
    for (int i = 0; i < self.count; ++i) {
        SNUserTrack *aTrack = [self objectAtIndex:i];
        if ([aTrack isKindOfClass:[SNUserTrack class]]) {
            [str appendString:[aTrack toFormatString]];
            if (i < self.count - 1) {
                [str appendString:@","];
            }
        }
    }
    return str;
}

@end
