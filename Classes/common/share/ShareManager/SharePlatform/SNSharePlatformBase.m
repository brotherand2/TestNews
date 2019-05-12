//
//  SNSharePlatformBase.m
//  sohunews
//
//  Created by wang shun on 2017/1/23.
//  Copyright © 2017年 Sohu.com. All rights reserved.
//

#import "SNSharePlatformBase.h"

@implementation SNSharePlatformBase

- (instancetype)initWithOption:(NSInteger)option{
    if (self = [super init]) {
        self.optionPlatform = option;
        self.shareTarget = ShareTargetUnknown;
    }
    return self;
}

- (void)shareTo:(NSDictionary*)dic Upload:(UploadBlock)method{
    
}

- (NSString *)getLinkFromString:(NSString *)content {
    return [SNUtility getLinkFromShareContent:content];
}

//访问shareOn参数
- (NSDictionary*)getShareParams:(NSDictionary *)dic{
    
    NSString* content = [dic objectForKey:@"content"];
    if (!content) {
        content = NSLocalizedString(@"SMS share to friends",@"");
    }
    
    NSString* shareLogId = [self.shareData objectForKey:kShareInfoKeyNewsId];
    if (shareLogId == nil || shareLogId.length == 0) {
        NSObject* redpacketId = [self.shareData objectForKey:kRedPacketIDKey];
        if (redpacketId != nil) {
            [self.shareData setObject:redpacketId forKey:@"shareLogId"];
        }
    }
    else{

        [self.shareData setObject:shareLogId?:@"" forKey:@"shareLogId"];
    }
    
    [self.shareData setObject:content?:@"" forKey:@"shareLogContent"];//多余

    

//    self.shareLogId = [self.shareData objectForKey:kShareInfoKeyNewsId];
//    if (self.shareLogId.length == 0) {
//        self.shareLogId = [self.shareData objectForKey:kRedPacketIDKey];
//    }
    
//    self.shareLogType = [self.shareData objectForKey:kShareInfoKeyShareType];
//    self.shareLogContent = self.content;
//    self.shareLogSudId = [self.shareData objectForKey:kShareInfoLogKeySubId];
//
//    self.comment = [self.shareData objectForKey:kShareInfoKeyShareComment];
//    self.shareTitle = [self.shareData objectForKey:kShareInfoKeyTitle];
//    self.shaereTargetName = [self.shareData objectForKey:kShareTargetNameKey];
    
    return self.shareData;
}

- (BOOL)isVideo {
    NSString* mediaUrl = [self.shareData objectForKey:@"mediaUrl"];
    if (mediaUrl && [mediaUrl isEqualToString:@"(null)"]) {
        return NO;
    }
    return mediaUrl.length > 0;
}

- (BOOL)isOnlyImage {
    
    NSString* webUrl = [self.shareData objectForKey:@"webUrl"];
    NSString* imageData = [self.shareData objectForKey:@"imageData"];
    
    return imageData.length > 0 && webUrl.length == 0;
}


- (void)log{
    // 实时统计，直接走起
    if (self.shareData) {
        [self.shareData setValue:[NSNumber numberWithInteger:self.shareTarget] forKey:kShareTargetKey];
    
        NSString* shareLogContent = [self.shareData objectForKey:@"shareLogContent"];
        NSString* shareLogType = [self.shareData objectForKey:@"shareLogType"];
    
        [self.shareData setValue:shareLogContent forKey:kShareContentKey];
        [self.shareData setValue:shareLogType forKey:kShareInfoKeyShareType];
        [SNNewsReport reportShareWithInfo:self.shareData];
    }
}

- (NSString *)description{
    NSString* classname = [NSString stringWithFormat:@"%@\n shareData:%@\n",NSStringFromClass([self class]),self.shareData];
    return classname;
}

@end
