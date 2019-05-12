//
//  SNStoryRequest.m
//  sohunews
//
//  Created by chuanwenwang on 2016/12/13.
//  Copyright © 2016年 Sohu.com. All rights reserved.
//

#import "SNStoryRequest.h"

@implementation SNStoryDetailRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryDetailRequestURL;
}

@end

@implementation SNStoryChapterListRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryChapterListRequestURL;
}

@end

@implementation SNStoryChapterContentRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryChapterContentRequestURL;
}

@end

@implementation SNStoryPurchaseChapterContentRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryPurchaseChapterContentRequestURL;
}

@end

@implementation SNStoryDownloadAvailableChapterContentRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryDownloadAvailableChapterContentRequestURL;
}

@end

@implementation SNStoryHotWordsSearchRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryHotWordsSearchRequestURL;
}

@end

@implementation SNBookAddShelfRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryAddToShelfRequestURL;
}

@end

@implementation SNDelBookFromShelfRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryDelFromShelfRequestURL;
}

@end

@implementation SNGetShelfBooksRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryQueryShelfRequestURL;
}

@end

@implementation SNShelfBookRemindRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryShelfRemindRequestURL;
}

@end

@implementation SNBookHadReadRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryBookHasReadRequestURL;
}

@end

@implementation SNStoryBookAdd_AnchorRequest

- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryBookAdd_AnchorRequestURL;
}

@end

@implementation SNStoryBookGet_AnchorRequest


- (SNRequestMethod)sn_requestMethod {
    return SNRequestMethodGet;
}

-(NSString *)sn_customUrl
{
    return StoryBookGet_AnchorRequestURL;
}
@end
