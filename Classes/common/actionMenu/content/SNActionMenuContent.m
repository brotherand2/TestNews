//
//  SNActionMenuContent.m
//  sohunews
//
//  Created by Dan Cong on 12/10/13.
//  Copyright (c) 2013 Sohu.com. All rights reserved.
//

#import "SNActionMenuContent.h"

@implementation SNActionMenuContent

- (void)interpretContext:(NSDictionary *)contentDic
{
    self.content = [contentDic objectForKey:kShareInfoKeyContent];
    
    if (!self.content) {
        self.content = NSLocalizedString(@"SMS share to friends",@"");
    }
    
    self.shareLogId = [contentDic objectForKey:kShareInfoKeyNewsId];
    if (self.shareLogId.length == 0) {
        self.shareLogId = [contentDic objectForKey:kRedPacketIDKey];
    }
    self.shareLogType = [contentDic objectForKey:kShareInfoKeyShareType];
    self.shareLogContent = self.content;
    self.shareLogSudId = [contentDic objectForKey:kShareInfoLogKeySubId];
    
    self.comment = [contentDic objectForKey:kShareInfoKeyShareComment];
    self.shareTitle = [contentDic objectForKey:kShareInfoKeyTitle];
    self.shaereTargetName = [contentDic objectForKey:kShareTargetNameKey];
    //保存分享信息
    self.shareContentDic = contentDic;
}

- (void)share
{
    //do nothing, to be overrided
}

- (void)log
{
    // 实时统计，直接走起
    if (ShareTargetUnknown != self.shareTarget) {
        [self.shareContentDic setValue:[NSNumber numberWithInteger:self.shareTarget] forKey:kShareTargetKey];
        [self.shareContentDic setValue:self.shareLogContent forKey:kShareContentKey];
        [self.shareContentDic setValue:self.shareLogType forKey:kShareInfoKeyShareType];
        [SNNewsReport reportShareWithInfo:self.shareContentDic];
    }
}

- (NSString *)getLinkFromString:(NSString *)content {
    return [SNUtility getLinkFromShareContent:content];
}

- (NSString *)removeLinkFromString:(NSString *)content {
    NSString *linkStr = [self getLinkFromString:content];
    if (!linkStr) {
        return content;
    }
    NSRange lingkRange = [content rangeOfString:linkStr];
    NSMutableString *mutStr = [NSMutableString stringWithString:content];
    
    return [self removeLinkFromString:[mutStr stringByReplacingCharactersInRange:lingkRange withString:@""]];
}

- (NSString *)removeAtTailFromString:(NSString *)content {
    // 由于直接去掉@搜狐新闻客户端 后面的内容  不合理  所以改为只去掉@搜狐新闻客户端这个字符串 by jojo on 2013-09-24
    if (content && [content isKindOfClass:[NSString class]]) {
        return [content stringByReplacingOccurrencesOfString:@"@搜狐新闻客户端" withString:@""];
    }
    if (content) {
        NSString *atString = @"@搜狐新闻";
        NSRange atRange = [content rangeOfString:atString];
        if (atRange.location != NSNotFound) {
            return [content stringByReplacingCharactersInRange:NSMakeRange(atRange.location, [content length] - atRange.location) withString:@""];
        }
    }
    return content;
}

-(NSString*)getShareContent:(NSString*)strContent
{
    // 不再主动添加@搜狐新闻客户端  以服务器给的数据为准 by jojo
    return strContent;
    
    NSString *strShare = nil;
    NSRange range = [strContent rangeOfString:@"@搜狐新闻客户端"];
    if(range.length > 0){
        strShare = strContent;
    }
    else{
        strShare = [strContent stringByAppendingFormat:@" %@", @"@搜狐新闻客户端"];//@前必须有空格
    }
    return strShare;
}

- (void)useShareCommentAsContent {
    
    NSString *comment = self.comment;
    
    if (!comment) {
        return;
    }
    
    NSString *content = self.content;
    
    // "xxxx" [title] http://xxxx @搜狐新闻客户端
    content = [self getLinkFromString:content]; // get link
    if ([content length] == 0) {
        content = @"";
    }
    content = [content stringByAppendingString:@" @搜狐新闻客户端"]; // add @string
    
    NSString *shareTitle = self.shareTitle;
    content = [NSString stringWithFormat:@" [%@] %@", shareTitle, content];
    NSInteger tailLen = [content length];
    NSInteger headLen = [comment length];
    NSInteger volumLen = 140 - tailLen - 2;
    if (headLen > volumLen) {
        comment = [comment substringToIndex:volumLen - 3];
        comment = [comment stringByAppendingString:@"..."];
    }
    
    if(comment.length>0)
        content = [NSString stringWithFormat:@"\"%@\"%@", comment, content];
    
    self.content = content;
}

- (void)dealloc
{
    _delegate = nil;
        
}

@end
