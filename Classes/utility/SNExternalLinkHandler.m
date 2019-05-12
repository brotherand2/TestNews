//
//  SNExternalLinkHandler.m
//  sohunews
//
//  Created by Xiang WeiJia on 12/25/14.
//  Copyright (c) 2014 Sohu.com. All rights reserved.
//

#import "SNExternalLinkHandler.h"
#import "SNNewsChannelType.h"
#import "SNDBManager.h"
#import "sohunewsAppDelegate.h"
#import "SNRollingNewsViewController.h"

#import "SNConsts.h"

@interface SNExternalLinkHandler()

@property (nonatomic, strong) NSURL *externalLink;
@property (nonatomic) BOOL fromTag;

@end

static SNExternalLinkHandler* externalInstance = nil;

@implementation SNExternalLinkHandler

@synthesize isAppLoad;

+ (SNExternalLinkHandler *) sharedInstance
{
    if (nil == externalInstance) {
        externalInstance = [[SNExternalLinkHandler alloc] init];
    }
    
    return externalInstance;
}

#define kChannelIdKey @"channelId"
#define kChannelNameKey @"channelName"

- (NSURL *)loadExternalLinkFromConfigFile {
    
    BOOL isFirstStart = [[NSUserDefaults standardUserDefaults] boolForKey:kNewUserGuideHadBeenShown];

    if (!isFirstStart) {
        NSString *path = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"tag.txt"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSString *tag = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
            
            return [NSURL URLWithString:tag];
        }
    }
    
    return nil;
}

+ (NSMutableString *)trimUrl:(NSMutableString *)url {
    
    // 开始容错，处理各种头
    
    // 删除 sohunews://
    NSRange range = [url rangeOfString:@"sohunews://pr/" options:NSCaseInsensitiveSearch];
    
    if (0 == range.location) {
        [url deleteCharactersInRange:range];
    }
    
    if ([url characterAtIndex:0] == ':') {
        [url deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    
    if ([url characterAtIndex:0] == '/') {
        [url deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    
    if ([url characterAtIndex:0] == '/') {
        [url deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    
    // 修补只有channel没有:的情况
    // 有可能处理之后的url是 channel// 7时补充:的位置
    if ([url characterAtIndex:7] != ':') {
        [url insertString:@":" atIndex:7];
    }
    
    return url;
}

- (void)setExternalLink:(NSURL *)externalLink {
    _externalLink = [NSURL URLWithString:externalLink.absoluteString];
    
    _fromTag = YES;
}

- (BOOL)handleExternalLinker {
    
    if (nil == _externalLink || _externalLink.absoluteString.length == 0) {
        return NO;
    }
    
    NSURL *link = self.externalLink;
    
    self.externalLink = nil;
    
    [SNUtility openProtocolUrl:link.absoluteString];
    
    return YES;
}

- (BOOL)isLoadFromTag
{
    BOOL result = _fromTag;

    _fromTag = NO;
    
    return result;
}

@end
